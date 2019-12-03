// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'package:node_http/node_http.dart' as http;
// For testing, use instead: import 'package:http/http.dart' as http;
// TODO(whesse): Inject http Client() through dependency injection.

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
  final String commitHash;
  final Map<String, dynamic> firstResult;
  String builderName;
  int buildNumber;
  int startIndex;
  int endIndex;

  Statistics stats = Statistics();

  Build(this.commitHash, this.firstResult, this.firestore)
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
    // If this is a new builder, use the current commit as a trivial blamelist.
    if (firstResult['previous_commit_hash'] == null) {
      startIndex = endIndex;
    } else {
      commit = await firestore.getCommit(firstResult['previous_commit_hash']);
      startIndex = commit['index'] + 1;
    }
  }

  Future<void> getMissingCommits() async {
    final lastCommit = await firestore.getLastCommit(commitHash);
    final lastHash = lastCommit['id'];
    final lastIndex = lastCommit['index'];

    final logUrl = 'https://dart.googlesource.com/sdk/+log/';
    final range = '$lastHash..master';
    final parameters = ['format=JSON', 'topo-order', 'n=1000'];
    final url = '$logUrl$range?${parameters.join('&')}';
    final client = http.NodeClient();
    // For testing, use http.Client();  TODO(whesse): Inject correct http.
    final response = await client.get(url);
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
      await firestore.addCommit(commit['commit'], {
        'author': commit['author']['email'],
        'created': parseGitilesDateTime(commit['committer']['time']),
        'index': index,
        'title': commit['message'].split('\n').first
      });
      ++index;
    }
  }

  Future<void> storeConfigurationsInfo(Iterable<String> configurations) async {
    for (final configuration in configurations) {
      await firestore.updateConfiguration(configuration, builderName);
    }
  }

  Future<void> storeChange(Map<String, dynamic> change) async {
    firestore.storeChange(change, startIndex, endIndex);
    stats.changes++;
  }
}

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
