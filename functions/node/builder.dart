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
  String builderName;
  int buildNumber;
  int startIndex;
  int endIndex;
  Set<String> tryApprovals;

  Statistics stats = Statistics();

  Build(this.commitHash, this.firstResult, this.firestore, this.httpClient)
      : builderName = firstResult['builder_name'],
        buildNumber = int.parse(firstResult['build_number']);

  Future<void> process(List<Map<String, dynamic>> results) async {
    final configurations =
        results.map((change) => change['configuration'] as String).toSet();
    await update(configurations);
    await Future.forEach(
        results.where(isChangedResult), (result) => storeChange(result));
    stats.report();
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
    var commit = await firestore.getCommit(commitHash);
    if (commit == null) {
      await getMissingCommits();
      commit = await firestore.getCommit(commitHash);
      if (commit == null) {
        error('Result received with unknown commit hash $commitHash');
      }
    }
    endIndex = commit['index'];
    if (commit.containsKey('review')) {
      tryApprovals = {
        for (final result in await firestore.tryApprovals(commit['review']))
          testResult(result)
      };
    }
    // If this is a new builder, use the current commit as a trivial blamelist.
    if (firstResult['previous_commit_hash'] == null) {
      startIndex = endIndex;
    } else {
      commit = await firestore.getCommit(firstResult['previous_commit_hash']);
      startIndex = commit['index'] + 1;
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
    stats.commitsFetched = commits.length;
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
    firestore.storeChange(change, startIndex, endIndex,
        approved: tryApprovals?.contains(testResult(change)) ?? false);
    stats.changes++;
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
      change['previous_result'],
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
