// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:math' show max, min;

import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:node_http/node_http.dart' as http;

void info(Object message) {
  print("Info: $message");
}

void error(Object message) {
  print("Error: $message");
}

void main() {
  functions['receiveChanges'] =
      functions.pubsub.topic('results').onPublish(receiveChanges);
}

// Cloud functions run the cloud function many times in the same isolate.
// Use static initializer to run global initialization once.
Firestore firestore = createFirestore();

Firestore createFirestore() {
  final app = FirebaseAdmin.instance.initializeApp();
  return app.firestore()
    ..settings(FirestoreSettings(timestampsInSnapshots: true));
}

Future<void> receiveChanges(Message message, EventContext context) async {
  final results = (message.json as List).cast<Map<String, dynamic>>();
  final stats = Statistics();
  var buildInfo = await storeBuildInfo(results, stats);
  await Future.forEach(results.where(isChangedResult),
  (result) => storeChange(result, buildInfo, stats));
  stats.report();
}

class Statistics {
  int results = 0;
  int changes = 0;
  int newRecords = 0;
  int modifiedRecords = 0;
  int commitsFetched = 0;
  String builder;
  int buildNumber;

  void report() {
    info("Number of changed results processed: $changes");
    info("Number of results processed: $results");
    info("Number of firestore records produced: $newRecords");
    info("Number of firestore records modified: $modifiedRecords");
    info("Number of commits fetched: $commitsFetched");
  }
}

Future<Map<String, int>> storeBuildInfo(
    List<Map<String, dynamic>> results, Statistics stats) async {
  stats.results = results.length;
  // Get indices of change.  Range includes startIndex and endIndex.
  final change = results.first;
  final hash = change['commit_hash'] as String;
  final docRef = await firestore.document('commits/$hash');
  var docSnapshot = await docRef.get();
  if (!docSnapshot.exists) {
    await getMissingCommits(hash, stats);
    docSnapshot = await docRef.get();
    if (!docSnapshot.exists) {
      error('Result received with unknown commit hash $hash');
    }
  }
  final endIndex = docSnapshot.data.getInt('index');
  // If this is a new builder, use the current commit as a trivial blamelist.
  var startIndex = endIndex;
  if (change['previous_commit_hash'] != null) {
    final commit = await firestore
        .document('commits/${change['previous_commit_hash']}')
        .get();
    startIndex = commit.data.getInt('index') + 1;
  }

  final String builder = change['builder_name'];
  stats.builder = builder;
  final int buildNumber = int.parse(change['build_number']);
  stats.buildNumber = buildNumber;
  final Set<String> configurations =
  results.map((change) => change['configuration'] as String)
  .toSet();
  for (final configuration in configurations) {
    final record = await firestore.document('configurations/$configuration').get();
    if (!record.exists || record.data.getString('builder') != builder) {
      await firestore.document('configurations/$configuration')
          .setData(DocumentData.fromMap({'builder': builder}));
      if (!record.exists) {
        info('Configuration document $configuration -> $builder created');
      } else {
        info('Configuration document changed: $configuration -> $builder '
            '(was ${record.data.getString("builder")}');
      }
    }
  }

  final documentRef = firestore.document('builds/$builder:$endIndex');
  final record = await documentRef.get();
  if (!record.exists) {
    await documentRef
        .setData(DocumentData.fromMap(
        {'builder': builder, 'build_number': buildNumber, 'index': endIndex}));
    info('Created build record: '
        'builder: $builder, build_number: $buildNumber, index: $endIndex');

  } else if (record.data.getInt('index') != endIndex) {
      error('Build $buildNumber of $builder had commit index ${record.data.getInt('index')},'
          'should be $endIndex.');
  }
 return {"startIndex": startIndex, "endIndex": endIndex};
}

Future<void> storeChange(Map<String, dynamic> change,
    Map<String, int> buildInfo, Statistics stats) async {
  stats.changes++;
  String name = change['name'];
  String result = change['result'];
  String previousResult = change['previous_result'] ?? 'new test';
  QuerySnapshot snapshot = await firestore
      .collection('results')
      .orderBy('blamelist_end_index', descending: true)
      .where('name', isEqualTo: name)
      .where('result', isEqualTo: result)
      .where('previous_result', isEqualTo: previousResult)
      .where('expected', isEqualTo: change['expected'])
      .limit(5)
      .get();

  // Find an existing change group with a blamelist that intersects this change.
   final startIndex = buildInfo['startIndex'];
   final endIndex = buildInfo['endIndex'];

  bool blamelistIncludesChange(DocumentSnapshot groupDocument) {
    var group = groupDocument.data;
    var groupStart = group.getInt('blamelist_start_index');
    var groupEnd = group.getInt('blamelist_end_index');
    return startIndex <= groupEnd && endIndex >= groupStart;
  }

  DocumentSnapshot group = snapshot.documents
      .firstWhere(blamelistIncludesChange, orElse: () => null);

  if (group == null) {
    info("Adding group for $name");
    return firestore.collection('results').add(DocumentData.fromMap({
          'name': name,
          'result': result,
          'previous_result': previousResult,
          'expected': change['expected'],
          'blamelist_start_index': startIndex,
          'blamelist_end_index': endIndex,
          'trivial_blamelist': startIndex == endIndex,
          'configurations': <String>[change['configuration']]
        }));
  }

  // Update the change group in a transaction.
  // Add new configuration and narrow the blamelist.
  Future<void> updateGroup(Transaction transaction) async {
    final DocumentSnapshot groupSnapshot =
        await transaction.get(group.reference);
    final data = groupSnapshot.data;
    final newStart = max(startIndex, data.getInt('blamelist_start_index'));
    final newEnd = min(endIndex, data.getInt('blamelist_end_index'));
    final updateMap = <String, dynamic>{
      'blamelist_start_index':
          max(startIndex, data.getInt('blamelist_start_index')),
      'blamelist_end_index': min(endIndex, data.getInt('blamelist_end_index'))
    };
    updateMap['trivial_blamelist'] = (updateMap['blamelist_start_index'] ==
        updateMap['blamelist_end_index']);
    final update = UpdateData.fromMap({
      'blamelist_start_index': newStart,
      'blamelist_end_index': newEnd,
      'trivial_blamelist': newStart == newEnd
    });
    update.setFieldValue('configurations',
        Firestore.fieldValues.arrayUnion([change['configuration']]));
    group.reference.updateData(update);
  }

  return firestore.runTransaction(updateGroup);
}

bool isChangedResult(Map<String, dynamic> result) =>
    result['changed'] && !result['flaky'] && !result['previous_flaky'];

Future<void> getMissingCommits(String hash, Statistics stats) async {
  final client = http.NodeClient();
  final QuerySnapshot lastCommit = await firestore
      .collection('commits')
      .orderBy('index', descending: true)
      .limit(1)
      .get();
  final lastHash = lastCommit.documents.first.documentID;
  final lastIndex = lastCommit.documents.first.data.getInt('index');

  final logUrl = 'https://dart.googlesource.com/sdk/+log/';
  final range = '$lastHash..master';
  final parameters = ['format=JSON', 'topo-order', 'n=1000'];
  final url = '$logUrl$range?${parameters.join('&')}';
  final response = await client.get(url);
  final log = response.body;
  // Expect XSSI protection.
  if (!log.startsWith(")]}'")) {
    error('Got response from gerrit API without XSSI protection: ' + log);
    throw ('Got response from gerrit API without XSSI protection: ' + log);
  }
  // Remove first line when XSSI protection is there.
  final commits =
      jsonDecode(log.substring(log.indexOf('\n') + 1))['log'] as List<dynamic>;
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
  if (!commits.any((commit) => commit['commit'] == hash)) {
    info('Did not find commit $hash when fetching new commits');
    return;
  }
  var index = lastIndex + 1;
  for (Map<String, dynamic> commit in commits.reversed) {
    // Create new commit document for this commit.
    final docRef = firestore.document('commits/${commit['commit']}');
    final data = DocumentData.fromMap({
      'author': commit['author']['email'],
      'created': Timestamp.fromDateTime(
          parseGitilesDateTime(commit['committer']['time'])),
      'index': index,
      'title': commit['message'].split('\n').first
    });
    await docRef.setData(data);
    ++index;
  }
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
  info("parts $parts");
  final month = months[parts[1]];
  final day = parts[2].padLeft(2, '0');
  return DateTime.parse('$year-$month-$day ${parts[3]} ${parts[5]}');
}
