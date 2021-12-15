// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:pool/pool.dart';

import 'commits_cache.dart';
import 'firestore.dart';
import 'result.dart';
import 'reverted_changes.dart';
import 'tryjob.dart' show Tryjob;

/// A Builder holds information about a CI build, and can
/// store the changed results from that build, using an injected
/// [FirestoreService] object.
/// Tryjob builds are represented by the class [Tryjob] instead.
class Build {
  final FirestoreService firestore;
  final CommitsCache commitsCache;
  final BuildInfo info;
  final TestNameLock testNameLock = TestNameLock();
  int startIndex;
  int endIndex;
  Commit endCommit;
  List<Commit> commits;
  Map<String, int> tryApprovals = {};
  List<RevertedChanges> allRevertedChanges = [];

  bool success = true; // Changed to false if any unapproved failure is seen.
  int countChanges = 0;
  int commitsFetched;
  List<String> approvalMessages = [];
  int countApprovalsCopied = 0;

  Build(this.info, this.commitsCache, this.firestore);

  void log(String string) => firestore.log(string);

  Future<void> process(List<Map<String, dynamic>> changes) async {
    log('store build commits info');
    await storeBuildCommitsInfo();
    log('update build info');
    if (!await firestore.updateBuildInfo(
        info.builderName, info.buildNumber, endIndex)) {
      // This build's results have already been recorded.
      log('build up-to-date, exiting');
      // TODO(karlklose): add a flag to overwrite builder results.
      return;
    }
    final configurations =
        changes.map((change) => change['configuration'] as String).toSet();
    await update(configurations);
    log('storing ${changes.length} change(s)');
    await Pool(30).forEach(changes, guardedStoreChange).drain();
    log('complete builder record');
    await firestore.completeBuilderRecord(info.builderName, endIndex, success);

    final report = [
      'Processed ${changes.length} results from ${info.builderName}'
          ' build ${info.buildNumber}',
      if (countChanges > 0) 'Stored $countChanges changes',
      if (commitsFetched != null) 'Fetched $commitsFetched new commits',
      '${firestore.documentsFetched} documents fetched',
      '${firestore.documentsWritten} documents written',
      if (!success) 'Found unapproved new failures',
      if (countApprovalsCopied > 0) ...[
        '$countApprovalsCopied approvals copied',
        ...approvalMessages,
        if (countApprovalsCopied > 10) '...'
      ]
    ];
    log(report.join('\n'));
  }

  Future<void> update(Iterable<String> configurations) async {
    await storeConfigurationsInfo(configurations);
  }

  /// Stores the commit info for the blamelist of result.
  /// If the info is already there does nothing.
  /// Saves the commit indices of the start and end of the blamelist.
  Future<void> storeBuildCommitsInfo() async {
    // Get indices of change.  Range includes startIndex and endIndex.
    endCommit = await commitsCache.getCommit(info.commitRef);
    if (endCommit == null) {
      throw 'Result received with unknown commit hash ${info.commitRef}';
    }
    endIndex = endCommit.index;
    // If this is a new builder, use the current commit as a trivial blamelist.
    if (info.previousCommitHash == null) {
      startIndex = endIndex;
    } else {
      final startCommit = await commitsCache.getCommit(info.previousCommitHash);
      startIndex = startCommit.index + 1;
      if (startIndex > endIndex) {
        throw ArgumentError('Results received with empty blamelist\n'
            'previous commit: ${info.previousCommitHash}\n'
            'built commit: ${info.commitRef}');
      }
    }
  }

  /// This async function's implementation runs exactly once.
  /// Later invocations return the same future returned by the first invocation.
  Future<void> fetchReviewsAndReverts() async {
    commits = [
      for (var index = startIndex; index < endIndex; ++index)
        await commitsCache.getCommitByIndex(index),
      endCommit
    ];
    for (final commit in commits) {
      final index = commit.index;
      final review = commit.review;
      final reverted = commit.revertOf;
      if (review != null) {
        tryApprovals.addAll({
          for (final result in await firestore.tryApprovals(review))
            testResult(result.fields): index
        });
      }
      if (reverted != null) {
        allRevertedChanges
            .add(await getRevertedChanges(reverted, index, firestore));
      }
    }
  }

  Future<void> storeConfigurationsInfo(Iterable<String> configurations) async {
    for (final configuration in configurations) {
      await firestore.updateConfiguration(configuration, info.builderName);
    }
  }

  Future<void> guardedStoreChange(Map<String, dynamic> change) =>
      testNameLock.guardedCall(storeChange, change);

  Future<void> storeChange(Map<String, dynamic> change) async {
    countChanges++;
    await fetchReviewsAndReverts();
    transformChange(change);
    final failure = isFailure(change);
    bool approved;
    var result = await firestore.findResult(change, startIndex, endIndex);
    var activeResults = await firestore.findActiveResults(
        change['name'], change['configuration']);
    if (result == null) {
      final approvingIndex = tryApprovals[testResult(change)] ??
          allRevertedChanges
              .firstWhere(
                  (revertedChange) => revertedChange.approveRevert(change),
                  orElse: () => null)
              ?.revertIndex;
      approved = approvingIndex != null;
      final newResult = constructResult(change, startIndex, endIndex,
          approved: approved,
          landedReviewIndex: approvingIndex,
          failure: failure);
      await firestore.storeResult(newResult);
      if (approved) {
        countApprovalsCopied++;
        if (countApprovalsCopied <= 10) {
          approvalMessages
              .add('Copied approval of result ${testResult(change)}');
        }
      }
    } else {
      approved = await firestore.updateResult(
          result, change['configuration'], startIndex, endIndex,
          failure: failure);
    }
    if (failure && !approved) success = false;

    for (final activeResult in activeResults) {
      final resultRecord = ResultRecord(activeResult.fields);
      // Log error message if any expected invariants are violated
      if (resultRecord.blamelistEndIndex >= startIndex ||
          !resultRecord.containsActiveConfiguration(change['configuration'])) {
        // log('Unexpected active result when processing new change:\n'
        //     'Active result: ${untagMap(activeResult.fields)}\n\n'
        //     'Change: $change\n\n'
        //     'approved: $approved');
      }
      // Removes the configuration from the list of active configurations.
      await firestore.removeActiveConfiguration(
          activeResult, change['configuration']);
    }
  }
}

Map<String, dynamic> constructResult(
    Map<String, dynamic> change, int startIndex, int endIndex,
    {bool approved, int landedReviewIndex, bool failure}) {
  return {
    fName: change[fName],
    fResult: change[fResult],
    fPreviousResult: change[fPreviousResult],
    fExpected: change[fExpected],
    fBlamelistStartIndex: startIndex,
    fBlamelistEndIndex: endIndex,
    if (startIndex != endIndex && approved) fPinnedIndex: landedReviewIndex,
    fConfigurations: <String>[change['configuration']],
    fApproved: approved,
    if (failure) fActive: true,
    if (failure) fActiveConfigurations: <String>[change['configuration']]
  };
}
