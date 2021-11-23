// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:builder/src/commits_cache.dart';
import 'package:builder/src/firestore.dart';
import 'package:builder/src/tryjob.dart';
import 'package:googleapis/firestore/v1.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

// These tests read and write data from the staging Firestore database.
// They use existing commits and reviews, and add new results from
// a new fake builder for new tests, where the builder and test names are unique
// to this test code and the records for them are removed afterward.
// The test cleanup function removes these records, even if tests fail.
// Requires the environment variable GOOGLE_APPLICATION_CREDENTIALS
// to point to a json key to a service account.
// To run against the staging database, use a service account.
// with write access to dart_ci_staging datastore.

FirestoreService firestore;
http.Client client;
CommitsCache commitsCache;
// The real commits and reviews we will test on, fetched from Firestore
const testCommitsStart = 80836;
Map<String, String> data;

final buildersToRemove = <String>{};
final testsToRemove = <String>{};

void registerChangeForDeletion(Map<String, dynamic> change) {
  buildersToRemove.add(change['builder_name']);
  testsToRemove.add(change['name']);
}

Future<void> removeTryBuildersAndResults() async {
  Future<void> deleteDocuments(RunQueryResponse response) async {
    for (final document in response.map((r) => r.document)) {
      await firestore.deleteDocument(document.name);
    }
  }

  for (final test in testsToRemove) {
    await deleteDocuments(await firestore.query(
        from: 'try_results', where: fieldEquals('name', test)));
  }
  for (final builder in buildersToRemove) {
    await deleteDocuments(await firestore.query(
        from: 'try_builds', where: fieldEquals('builder', builder)));
  }
}

Future<Map<String, String>> loadTestCommits(int startIndex) async {
  // Get review data for the last two landed CLs before or at startIndex.
  final reviews = await firestore.query(
      from: 'reviews',
      orderBy: orderBy('landed_index', false),
      where: fieldLessThanOrEqual('landed_index', startIndex),
      limit: 2);
  final firstReview = reviews.first.document;
  final String index = firstReview.fields['landed_index'].integerValue;
  final String review = firstReview.name.split('/').last;
  final secondReview = reviews.last.document;
  final String landedIndex = secondReview.fields['landed_index'].integerValue;
  final String landedReview = secondReview.name.split('/').last;
  // expect(int.parse(index), greaterThan(int.parse(landedIndex)));
  final String baseIndex = (int.parse(landedIndex) - 1).toString();

  final patchsets = await firestore.query(
    from: 'patchsets',
    parent: 'reviews/$review',
    orderBy: orderBy('number', true),
  );
  final patchset = patchsets.last.document.fields['number'].integerValue;
  final previousPatchset = '1';
  final landedPatchsets = await firestore.query(
    from: 'patchsets',
    parent: 'reviews/$landedReview',
    orderBy: orderBy('number', true),
  );
  final landedPatchset =
      landedPatchsets.last.document.fields['number'].integerValue;

  // Get commit hashes for the landed reviews, and for a commit before them
  var commits = {
    for (final index in [index, landedIndex, baseIndex])
      index: (await firestore.query(
              from: 'commits',
              where: fieldEquals('index', int.parse(index)),
              limit: 1))
          .first
          .document
          .name
          .split('/')
          .last
  };
  return {
    'index': index,
    'commit': commits[index],
    'review': review,
    'patchset': patchset,
    'patchsetRef': 'refs/changes/$review/$patchset',
    'previousPatchset': previousPatchset,
    'landedIndex': landedIndex,
    'landedCommit': commits[landedIndex],
    'landedReview': landedReview,
    'landedPatchset': landedPatchset,
    'landedPatchsetRef': 'refs/changes/$landedReview/$landedPatchset',
    'baseIndex': baseIndex,
    'baseCommit': commits[baseIndex]
  };
}

Tryjob makeTryjob(String name) => Tryjob(data['patchsetRef'], 'bbID_$name',
    data['landedCommit'], commitsCache, firestore, client);

Tryjob makeLandedTryjob(String name) => Tryjob(data['landedPatchsetRef'],
    'bbID_$name', data['baseCommit'], commitsCache, firestore, client);

Map<String, dynamic> makeChange(String name, String result,
    {bool flaky = false}) {
  final results = result.split('/');
  final previous = results[0];
  final current = results[1];
  final expected = results[2];
  final change = {
    'name': '${name}_test',
    'configuration': '${name}_configuration',
    'suite': 'unused_field',
    'test_name': 'unused_field',
    'time_ms': 2384,
    'result': current,
    'previous_result': previous,
    'expected': expected,
    'matches': current == expected,
    'changed': current != previous,
    'commit_hash': data['patchsetRef'],
    'commit_time': 1583906489,
    'build_number': '99997',
    'builder_name': 'builder_$name',
    'flaky': flaky,
    'previous_flaky': false,
    'previous_commit_hash': data['baseCommit'],
    'previous_commit_time': 1583906489,
    'bot_name': 'fake_bot_name',
    'previous_build_number': '306',
  };
  registerChangeForDeletion(change);
  return change;
}

Map<String, dynamic> makeLandedChange(String name, String result) {
  return makeChange(name, result)..['commit_hash'] = data['landedPatchsetRef'];
}

Future<void> checkTryBuild(String name, {bool success, bool truncated}) async {
  final buildbucketId = 'bbID_$name';
  final buildDocuments = await firestore.query(
      from: 'try_builds', where: fieldEquals('buildbucket_id', buildbucketId));
  expect(buildDocuments.length, 1);
  expect(
      buildDocuments.single.document.fields['success'].booleanValue, success);
  if (truncated != null) {
    expect(buildDocuments.single.document.fields['truncated'].booleanValue,
        truncated);
  } else {
    expect(buildDocuments.single.document.fields.containsKey('truncated'),
        isFalse);
  }
}

void main() async {
  final baseClient = http.Client();
  client = await clientViaApplicationDefaultCredentials(
      scopes: ['https://www.googleapis.com/auth/cloud-platform'],
      baseClient: baseClient);
  final api = FirestoreApi(client);
  firestore = FirestoreService(api, client);
  if (!await firestore.isStaging()) {
    throw (TestFailure('Error: test is being run on production'));
  }
  commitsCache = CommitsCache(firestore, client);
  data = await loadTestCommits(testCommitsStart);

  tearDownAll(() async {
    await removeTryBuildersAndResults();
    baseClient.close();
  });

  test('unchanged', () async {
    final unchangedChange = makeChange('unchanged', 'Pass/Pass/Pass');
    final tryjob = makeTryjob('unchanged');
    await tryjob.process([unchangedChange]);
    await checkTryBuild('unchanged', success: true);
    expect(tryjob.counter.changes, 0);
  });

  test('failure', () async {
    final failingChange = makeChange('failure', 'Pass/RuntimeError/Pass');
    final tryjob = makeTryjob('failure');
    await tryjob.process([failingChange]);
    await checkTryBuild('failure', success: false);
    // Add a second failing configuration for the test.
    final otherConfigurationChange = {
      ...failingChange,
      'configuration': 'other_configuration',
      'builder': 'other_builder',
    };
    registerChangeForDeletion(otherConfigurationChange);
    final otherTryjob = makeTryjob('other_configuration');
    await otherTryjob.process([otherConfigurationChange]);
    await checkTryBuild('other_configuration', success: false);
    final result = await firestore.query(
        from: 'try_results', where: fieldEquals('name', 'failure_test'));
    expect(result.length, 1);
    expect(
        result
            .single.document.fields['configurations'].arrayValue.values.length,
        2);
  });

  test('landedFailure', () async {
    final landedChange =
        makeLandedChange('landedFailure', 'Pass/RuntimeError/Pass');
    final landedTryjob = makeLandedTryjob('landedFailure');
    await landedTryjob.process([landedChange]);
    // This change has a base revision containing the landed failure, but
    // CI results that don't contain it. The failure is seen in the landed
    // try results, and ignored.
    final failingChange = makeChange('landedFailure', 'Pass/RuntimeError/Pass');
    final tryjob = makeTryjob('landedFailure2');
    await tryjob.process([failingChange]);
    await checkTryBuild('landedFailure2', success: true);
  });

  test('flaky', () async {
    final flakyChange =
        makeChange('flaky', 'Pass/RuntimeError/Pass', flaky: true);
    final tryjob = makeTryjob('flaky');
    await tryjob.process([flakyChange]);
    await checkTryBuild('flaky', success: true);
    expect(tryjob.success, true);
    expect(tryjob.counter.newFlakes, 1);
    expect(tryjob.counter.unapprovedFailures, 0);
  });

  test('truncatedPass', () async {
    final passingChange = makeChange('truncatedPass', 'RuntimeError/Pass/Pass');
    final tryjob = makeTryjob('truncatedPass');
    final failingChange = makeChange('truncatedPass', 'Pass/RuntimeError/Pass')
      ..['name'] = 'truncated_pass_2_test';
    registerChangeForDeletion(failingChange);
    tryjob.counter.passes = ChangeCounter.maxReportedSuccesses;
    await tryjob.process([passingChange, failingChange]);
    await checkTryBuild('truncatedPass', success: false, truncated: true);
    expect(tryjob.counter.passes, ChangeCounter.maxReportedSuccesses + 1);
    expect(tryjob.counter.unapprovedFailures, 1);
    expect(tryjob.counter.failures, 1);
    expect(tryjob.counter.hasTooManyPassingChanges, isTrue);
    expect(tryjob.counter.hasTooManyFailingChanges, isFalse);
    expect(tryjob.counter.hasTruncatedChanges, isTrue);
    final existingResult = await firestore.query(
        from: 'try_results',
        where: fieldEquals('name', 'truncated_pass_2_test'));
    expect(existingResult.length, 1);
    final truncatedResult = await firestore.query(
        from: 'try_results', where: fieldEquals('name', 'truncatedPass_test'));
    expect(truncatedResult, isEmpty);
  });

  test('truncated', () async {
    final failingChange = makeChange('truncated', 'Pass/RuntimeError/Pass');
    final tryjob = makeTryjob('truncated');
    final truncatedChange = {...failingChange, 'name': 'truncated_2_test'};
    registerChangeForDeletion(truncatedChange);
    tryjob.counter.failures = ChangeCounter.maxReportedFailures - 1;
    await tryjob.process([failingChange, truncatedChange]);
    await checkTryBuild('truncated', success: false, truncated: true);
    expect(tryjob.counter.failures, ChangeCounter.maxReportedFailures + 1);
    expect(tryjob.counter.hasTooManyFailingChanges, isTrue);
    expect(tryjob.counter.hasTruncatedChanges, isTrue);
    final existingResult = await firestore.query(
        from: 'try_results', where: fieldEquals('name', 'truncated_test'));
    expect(existingResult.length, 1);
    final truncatedResult = await firestore.query(
        from: 'try_results', where: fieldEquals('name', 'truncated_2_test'));
    expect(truncatedResult, isEmpty);
  });
}
