// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:http/http.dart' as http;

import 'firestore.dart';

void info(Object message) {
  print("Info: $message");
}

void error(Object message) {
  print("Error: $message");
}

const prefix = ")]}'\n";

bool isChangedResult(Map<String, dynamic> result) =>
    result['changed'] && !result['flaky'] && !result['previous_flaky'];

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
  Set<String> tryApprovals = {};
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
    await Future.forEach(results.where(isChangedResult), storeChange);
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
    var endCommit = await firestore.getCommit(commitHash);
    if (endCommit == null) {
      await getMissingCommits();
      endCommit = await firestore.getCommit(commitHash);
      if (endCommit == null) {
        error('Result received with unknown commit hash $commitHash');
      }
    }
    endIndex = endCommit['index'];
    // If this is a new builder, use the current commit as a trivial blamelist.
    if (firstResult['previous_commit_hash'] == null) {
      startIndex = endIndex;
    } else {
      final startCommit =
          await firestore.getCommit(firstResult['previous_commit_hash']);
      startIndex = startCommit['index'] + 1;
    }
    Future<void> fetchApprovals(Map<String, dynamic> commit) async {
      if (commit.containsKey('review')) {
        for (final result in await firestore.tryApprovals(commit['review'])) {
          tryApprovals.add(testResult(result));
        }
      }
    }

    await fetchApprovals(endCommit);
    for (var index = startIndex; index < endIndex; ++index) {
      await fetchApprovals(await firestore.getCommitByIndex(index));
    }
  }

  /// This function is idempotent, so every call of it should write the
  /// same info to new Firestore documents.  It is save to call multiple
  /// times simultaneously.
  Future<void> getMissingCommits() async {
    final lastCommit = await firestore.getLastCommit();
    final lastHash = lastCommit['id'];
    final lastIndex = lastCommit['index'];

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
      info('Found no new commits between $lastHash and master');
      return;
    }
    commitsFetched = commits.length;
    final first = commits.last as Map<String, dynamic>;
    if (first['parents'].first != lastHash) {
      error('First new commit ${first['parents'].first} is not'
          ' a child of last known commit $lastHash when fetching new commits');
      throw ('First new commit ${first['parents'].first} is not'
          ' a child of last known commit $lastHash when fetching new commits');
    }
    if (!commits.any((commit) => commit['commit'] == commitHash)) {
      info('Did not find commit $commitHash when fetching new commits');
      return;
    }
    var index = lastIndex + 1;
    for (Map<String, dynamic> commit in commits.reversed) {
      final review = _review(commit);
      await firestore.addCommit(commit['commit'], {
        'author': commit['author']['email'],
        'created': parseGitilesDateTime(commit['committer']['time']),
        'index': index,
        'title': commit['message'].split('\n').first,
        if (review != null) 'review': review
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
    final failure = !change['matches'];
    var approved;
    String result = await firestore.findResult(change, startIndex, endIndex);
    Map<String, dynamic> activeResult =
        await firestore.findActiveResult(change);
    if (result == null) {
      approved = tryApprovals.contains(testResult(change));
      await firestore.storeResult(change, startIndex, endIndex,
          approved: approved, failure: failure);
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

    if (activeResult != null) {
      // Log error message if any expected invariants are violated
      if (activeResult['blamelist_end_index'] >= startIndex ||
          !activeResult['active_configurations']
              .contains(change['configuration'])) {
        error('Unexpected active result when processing new change:\n'
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

String testResult(Map<String, dynamic> change) => [
      change['name'],
      change['result'],
      change['previous_result'] ?? 'new test',
      change['expected']
    ].join(' ');

class Statistics {
  int results = 0;
  int changes = 0;
  int newRecords = 0;
  int modifiedRecords = 0;
  int commitsFetched = 0;

  void report() {
    info("Number of changed results processed: $changes");
    info("Number of results processed: $results");
    info("Number of firestore records produced: $newRecords");
    info("Number of firestore records modified: $modifiedRecords");
    info("Number of commits fetched: $commitsFetched");
  }
}
