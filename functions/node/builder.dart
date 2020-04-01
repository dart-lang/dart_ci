// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:pool/pool.dart';

import 'commits_cache.dart';
import 'firestore.dart';
import 'result.dart';
import 'reverted_changes.dart';

/// A Builder holds information about a CI build, and can
/// store the changed results from that build, using an injected
/// Firestore() object.
/// Tryjob builds are represented by a subclass Tryjob of this class.
class Build {
  final FirestoreService firestore;
  final CommitsCache commitsCache;
  final String commitHash;
  final Map<String, dynamic> firstResult;
  final int countChunks;
  String builderName;
  int buildNumber;
  int startIndex;
  int endIndex;
  Map<String, dynamic> endCommit;
  Future<void> _awaitCommits;
  List<Map<String, dynamic>> commits;
  Map<String, int> tryApprovals = {};
  List<RevertedChanges> allRevertedChanges = [];

  bool success = true; // Changed to false if any unapproved failure is seen.
  int countChanges = 0;
  int commitsFetched;
  List<String> approvalMessages = [];
  int countApprovalsCopied = 0;

  Build(this.commitHash, this.firstResult, this.countChunks, this.commitsCache,
      this.firestore)
      : builderName = firstResult['builder_name'],
        buildNumber = int.parse(firstResult['build_number']);

  Future<void> process(List<Map<String, dynamic>> results) async {
    final configurations =
        results.map((change) => change['configuration'] as String).toSet();
    await update(configurations);
    await Pool(30).forEach(results.where(isChangedResult), storeChange).drain();
    if (countChunks != null) {
      await firestore.storeBuildChunkCount(builderName, endIndex, countChunks);
    }
    await firestore.storeChunkStatus(builderName, endIndex, success);

    final report = [
      'Processed ${results.length} results from $builderName build $buildNumber',
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
    print(report.join('\n'));
  }

  Future<void> update(Iterable<String> configurations) async {
    await storeBuildCommitsInfo();
    await storeConfigurationsInfo(configurations);
    await firestore.updateBuildInfo(builderName, buildNumber, endIndex);
  }

  /// Stores the commit info for the blamelist of result.
  /// If the info is already there does nothing.
  /// Saves the commit indices of the start and end of the blamelist.
  Future<void> storeBuildCommitsInfo() async {
    // Get indices of change.  Range includes startIndex and endIndex.
    endCommit = await commitsCache.getCommit(commitHash);
    if (endCommit == null) {
      throw 'Result received with unknown commit hash $commitHash';
    }
    endIndex = endCommit[fIndex];
    // If this is a new builder, use the current commit as a trivial blamelist.
    if (firstResult['previous_commit_hash'] == null) {
      startIndex = endIndex;
    } else {
      final startCommit =
          await commitsCache.getCommit(firstResult['previous_commit_hash']);
      startIndex = startCommit[fIndex] + 1;
      if (startIndex > endIndex) {
        throw ArgumentError('Results received with empty blamelist\n'
            'previous commit: ${firstResult['previous_commit_hash']}\n'
            'built commit: $commitHash');
      }
    }
  }

  /// This async function's implementation runs exactly once.
  /// Later invocations return the same future returned by the first invocation.
  Future<void> fetchReviewsAndReverts() => _awaitCommits ??= () async {
        commits = [
          for (var index = startIndex; index < endIndex; ++index)
            await commitsCache.getCommitByIndex(index),
          endCommit
        ];
        for (final commit in commits) {
          final index = commit[fIndex];
          final review = commit[fReview];
          final reverted = commit[fRevertOf];
          if (review != null) {
            tryApprovals.addAll({
              for (final result in await firestore.tryApprovals(review))
                testResult(result): index
            });
          }
          if (reverted != null) {
            allRevertedChanges
                .add(await getRevertedChanges(reverted, index, firestore));
          }
        }
      }();

  Future<void> storeConfigurationsInfo(Iterable<String> configurations) async {
    for (final configuration in configurations) {
      await firestore.updateConfiguration(configuration, builderName);
    }
  }

  Future<void> storeChange(Map<String, dynamic> change) async {
    countChanges++;
    await fetchReviewsAndReverts();
    final failure = isFailure(change);
    var approved;
    String result = await firestore.findResult(change, startIndex, endIndex);
    List<Map<String, dynamic>> activeResults =
        await firestore.findActiveResults(change);
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
        if (countApprovalsCopied <= 10)
          approvalMessages
              .add('Copied approval of result ${testResult(change)}');
      }
    } else {
      approved = await firestore.updateResult(
          result, change['configuration'], startIndex, endIndex,
          failure: failure);
    }
    if (failure && !approved) success = false;

    for (final activeResult in activeResults) {
      // Log error message if any expected invariants are violated
      if (activeResult[fBlamelistEndIndex] >= startIndex ||
          !activeResult[fActiveConfigurations]
              .contains(change['configuration'])) {
        print('Unexpected active result when processing new change:\n'
            'Active result: $activeResult\n\n'
            'Change: $change\n\n'
            'approved: $approved');
      }
      // Removes the configuration from the list of active configurations.
      // Mark the active result inactive when we remove the last active config.
      firestore.updateActiveResult(activeResult, change['configuration']);
    }
  }
}

Map<String, dynamic> constructResult(
        Map<String, dynamic> change, int startIndex, int endIndex,
        {bool approved, int landedReviewIndex, bool failure}) =>
    {
      fName: change[fName],
      fResult: change[fResult],
      fPreviousResult: change[fPreviousResult] ?? 'new test',
      fExpected: change[fExpected],
      fBlamelistStartIndex: startIndex,
      fBlamelistEndIndex: endIndex,
      if (startIndex != endIndex && approved) fPinnedIndex: landedReviewIndex,
      fConfigurations: <String>[change['configuration']],
      fApproved: approved,
      if (failure) fActive: true,
      if (failure) fActiveConfigurations: <String>[change['configuration']]
    };

String testResult(Map<String, dynamic> change) => [
      change['name'],
      change['result'],
      change['previous_result'] ?? 'new test',
      change['expected']
    ].join(' ');
