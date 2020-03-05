// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pool/pool.dart';

import 'firestore.dart';
import 'result.dart';
import 'reverted_changes.dart';

const prefix = ")]}'\n";

Iterable<int> range(int start, int end) sync* {
  for (int i = start; i < end; ++i) yield i;
}

const months = const {
  'Jan': '01',
  'Feb': '02',
  'Mar': '03',
  'Apr': '04',
  'May': '05',
  'Jun': '06',
  'Jul': '07',
  'Aug': '08',
  'Sep': '09',
  'Oct': '10',
  'Nov': '11',
  'Dec': '12'
};

DateTime parseGitilesDateTime(String gitiles) {
  final parts = gitiles.split(' ');
  final year = parts[4];
  final month = months[parts[1]];
  final day = parts[2].padLeft(2, '0');
  return DateTime.parse('$year-$month-$day ${parts[3]} ${parts[5]}');
}

/// A Builder holds information about a CI build, and can
/// store the changed results from that build, using an injected
/// Firestore() object.
/// Tryjob builds are represented by a subclass Tryjob of this class.
class Build {
  final FirestoreService firestore;
  final http.BaseClient httpClient;
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

  Build(this.commitHash, this.firstResult, this.countChunks, this.firestore,
      this.httpClient)
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
      "Processed ${results.length} results from $builderName build $buildNumber",
      if (countChanges > 0) "Stored $countChanges changes",
      if (commitsFetched != null) "Fetched $commitsFetched new commits",
      if (!success) "Found unapproved new failures",
      if (countApprovalsCopied > 0) ...[
        "$countApprovalsCopied approvals copied",
        ...approvalMessages,
        if (countApprovalsCopied > 10) "..."
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
    endCommit = await firestore.getCommit(commitHash);
    if (endCommit == null) {
      await getMissingCommits();
      endCommit = await firestore.getCommit(commitHash);
      if (endCommit == null) {
        throw 'Result received with unknown commit hash $commitHash';
      }
    }
    endIndex = endCommit[fIndex];
    // If this is a new builder, use the current commit as a trivial blamelist.
    if (firstResult['previous_commit_hash'] == null) {
      startIndex = endIndex;
    } else {
      final startCommit =
          await firestore.getCommit(firstResult['previous_commit_hash']);
      startIndex = startCommit[fIndex] + 1;
      if (startIndex > endIndex) {
        throw ArgumentError("Results received with empty blamelist\n"
            "previous commit: ${firstResult['previous_commit_hash']}\n"
            "built commit: $commitHash");
      }
    }
  }

  /// This async function's implementation runs exactly once.
  /// Later invocations return the same future returned by the first invocation.
  Future<void> fetchReviewsAndReverts() => _awaitCommits ??= () async {
        commits = [
          for (var index = startIndex; index < endIndex; ++index)
            await firestore.getCommitByIndex(index),
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

  /// This function is idempotent, so every call of it should write the
  /// same info to new Firestore documents.  It is save to call multiple
  /// times simultaneously.
  Future<void> getMissingCommits() async {
    final lastCommit = await firestore.getLastCommit();
    final lastHash = lastCommit[fHash];
    final lastIndex = lastCommit[fIndex];

    final logUrl = 'https://dart.googlesource.com/sdk/+log/';
    final range = '$lastHash..master';
    final parameters = ['format=JSON', 'topo-order', 'n=1000'];
    final url = '$logUrl$range?${parameters.join('&')}';
    final response = await httpClient.get(url);
    final protectedJson = response.body;
    if (!protectedJson.startsWith(prefix))
      throw Exception('Gerrit response missing prefix $prefix: $protectedJson');
    final commits = jsonDecode(protectedJson.substring(prefix.length))['log']
        as List<dynamic>;
    if (commits.isEmpty) {
      print('Found no new commits between $lastHash and master');
      return;
    }
    commitsFetched = commits.length;
    final first = commits.last as Map<String, dynamic>;
    if (first['parents'].first != lastHash) {
      throw 'First new commit ${first['parents'].first} is not'
          ' a child of last known commit $lastHash when fetching new commits';
    }
    if (!commits.any((commit) => commit['commit'] == commitHash)) {
      throw 'Did not find commit $commitHash when fetching new commits';
    }
    var index = lastIndex + 1;
    for (Map<String, dynamic> commit in commits.reversed) {
      final review = _review(commit);
      var reverted = _revert(commit);
      var relanded = _reland(commit);
      if (relanded != null) {
        reverted = null;
      }
      if (reverted != null) {
        final revertedCommit = await firestore.getCommit(reverted);
        if (revertedCommit != null && revertedCommit[fRevertOf] != null) {
          reverted = null;
          relanded = revertedCommit[fRevertOf];
        }
      }
      await firestore.addCommit(commit['commit'], {
        fAuthor: commit['author']['email'],
        fCreated: parseGitilesDateTime(commit['committer']['time']),
        fIndex: index,
        fTitle: commit['message'].split('\n').first,
        if (review != null) fReview: review,
        if (reverted != null) fRevertOf: reverted,
        if (relanded != null) fRelandOf: relanded,
      });
      if (review != null) {
        await landReview(commit, index);
      }
      ++index;
    }
  }

  /// This function is idempotent and may be called multiple times
  /// concurrently.
  Future<void> landReview(Map<String, dynamic> commit, int index) async {
    int review = _review(commit);
    // Optimization to avoid duplicate work: if another instance has linked
    // the review to its landed commit, do nothing.
    if (await firestore.reviewIsLanded(review)) return;
    await firestore.linkReviewToCommit(review, index);
    await firestore.linkCommentsToCommit(review, index);
  }

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
              .add("Copied approval of result ${testResult(change)}");
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

final reviewRegExp = RegExp(
    '^Reviewed-on: https://dart-review.googlesource.com/c/sdk/\\+/(\\d+)\$',
    multiLine: true);

int _review(Map<String, dynamic> commit) {
  final match = reviewRegExp.firstMatch(commit['message']);
  if (match != null) return int.parse(match.group(1));
  return null;
}

final revertRegExp =
    RegExp('^This reverts commit ([\\da-f]+)\\.\$', multiLine: true);

String _revert(Map<String, dynamic> commit) =>
    revertRegExp.firstMatch(commit['message'])?.group(1);

final relandRegExp =
    RegExp('^This is a reland of ([\\da-f]+)\\.?\$', multiLine: true);

String _reland(Map<String, dynamic> commit) =>
    relandRegExp.firstMatch(commit['message'])?.group(1);

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
