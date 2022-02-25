// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:pool/pool.dart';

import 'commits_cache.dart';
import 'firestore.dart';
import 'result.dart';
import 'reverted_changes.dart';
import 'status.dart';
import 'tryjob.dart' show Tryjob;

/// A Build holds information about a CI build, and can
/// store the changed results from that build, using an injected
/// [FirestoreService] object.
/// Tryjob builds are represented by the class [Tryjob] instead.
class Build {
  final FirestoreService firestore;
  final CommitsCache commitsCache;
  final BuildInfo info;
  final TestNameLock testNameLock = TestNameLock();
  late final int startIndex;
  late int endIndex;
  late Commit endCommit;
  late List<Commit> commits;
  late final Future<void> reviewsFetched = _fetchReviewsAndReverts();
  Map<String, int> tryApprovals = {};
  List<RevertedChanges> allRevertedChanges = [];

  bool success = true; // Changed to false if any unapproved failure is seen.
  int countChanges = 0;
  int? commitsFetched;
  List<String> approvalMessages = [];
  int countApprovalsCopied = 0;

  Build(this.info, this.commitsCache, this.firestore);

  void log(String string) => firestore.log(string);

  Future<BuildStatus> process(List<Map<String, dynamic>> changes) async {
    log('store build commits info');
    await storeBuildCommitsInfo();
    log('update build info');
    if (!await firestore.updateBuildInfo(
        info.builderName, info.buildNumber, endIndex)) {
      // This build's results have already been recorded.
      log('build already uploaded to database, exiting');
      // TODO(karlklose): add a flag to overwrite builder results.
      exit(1);
    }
    final configurations =
        changes.map((change) => change['configuration'] as String).toSet();
    await update(configurations);
    log('storing ${changes.length} change(s)');
    await Pool(30).forEach(changes, guardedStoreChange).drain();
    log('complete builder record');
    await firestore.completeBuilderRecord(info.builderName, endIndex, success);
    final status = BuildStatus()..success = success;
    try {
      status.unapprovedFailures = {
        for (final configuration in configurations)
          configuration: await unapprovedFailuresForConfiguration(configuration)
      }..removeWhere((key, value) => value.isEmpty);
    } catch (e) {
      log('Failed to fetch unapproved failures: $e');
      status.unapprovedFailures = {'failed': []};
      status.success = false;
    }
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
    return status;
  }

  Future<void> update(Iterable<String> configurations) async {
    await storeConfigurationsInfo(configurations);
  }

  /// Stores the commit info for the blamelist of result.
  /// If the info is already there does nothing.
  /// Saves the commit indices of the start and end of the blamelist.
  Future<void> storeBuildCommitsInfo() async {
    // Get indices of change.  Range includes startIndex and endIndex.
    final commit = await commitsCache.getCommit(info.commitRef);
    endCommit = commit;
    endIndex = endCommit.index;
    // If this is a new builder, use the current commit as a trivial blamelist.
    if (info.previousCommitHash == null) {
      startIndex = endIndex;
    } else {
      final startCommit =
          await commitsCache.getCommit(info.previousCommitHash!);
      startIndex = startCommit.index + 1;
      if (startIndex > endIndex) {
        throw ArgumentError('Results received with empty blamelist\n'
            'previous commit: ${info.previousCommitHash}\n'
            'built commit: ${info.commitRef}');
      }
    }
  }

  /// This async function is run exactly once, initializing the late final
  /// field reviewsFetched the first time that field is referenced.
  Future<void> _fetchReviewsAndReverts() async {
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
    await reviewsFetched;
    transformChange(change);
    final failure = isFailure(change);
    bool approved;
    var result = await firestore.findResult(change, startIndex, endIndex);
    var activeResults = await firestore.findActiveResults(
        change['name'], change['configuration']);
    if (result == null) {
      final approvingIndex = tryApprovals[testResult(change)] ??
          allRevertedChanges
              .firstWhereOrNull(
                  (revertedChange) => revertedChange.approveRevert(change))
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
      // Log error message if any expected invariants are violated
      if (activeResult.getInt(fBlamelistEndIndex)! >= startIndex ||
          !(activeResult
                  .getList(fActiveConfigurations)
                  ?.contains(change['configuration']) ??
              false)) {
        log('Unexpected active result when processing new change:\n'
            'Active result: ${untagMap(activeResult.fields)}\n\n'
            'Change: $change\n\n'
            'approved: $approved');
      }
      // Removes the configuration from the list of active configurations.
      await firestore.removeActiveConfiguration(
          activeResult, change['configuration']);
    }
  }

  Future<List<SafeDocument>> unapprovedFailuresForConfiguration(
      String configuration) async {
    final failures = await firestore.findUnapprovedFailures(
        configuration, BuildStatus.unapprovedFailuresLimit + 1);
    await Future.forEach(failures, addBlamelistCommits);
    return failures;
  }

  Future<void> addBlamelistCommits(SafeDocument result) async {
    final startCommit = await commitsCache
        .getCommitByIndex(result.getInt(fBlamelistStartIndex)!);
    result.fields[fBlamelistStartCommit] = taggedValue(startCommit.hash);
    final endCommit =
        await commitsCache.getCommitByIndex(result.getInt(fBlamelistEndIndex)!);
    result.fields[fBlamelistEndCommit] = taggedValue(endCommit.hash);
  }
}

Map<String, dynamic> constructResult(
    Map<String, dynamic> change, int startIndex, int endIndex,
    {required bool approved, int? landedReviewIndex, required bool failure}) {
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
