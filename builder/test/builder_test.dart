// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:builder/src/builder.dart';
import 'package:builder/src/commits_cache.dart';
import 'package:builder/src/firestore.dart';
import 'package:builder/src/result.dart';
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
// to point to a json key to a service account or run
// `gcloud auth application-default login`.
// To run against the staging database, use a service account.
// with write access to dart_ci_staging datastore.

late FirestoreService firestore;
late http.Client client;
late CommitsCache commitsCache;
// The real commits we will test on, fetched from Firestore
const index = 81010;
const previousIndex = index - 1;
const previousBlamelistEnd = previousIndex - 1;
const previousBlamelistStart = previousBlamelistEnd - 3;
const previousBuildPreviousIndex = previousBlamelistStart - 1;
late Commit commit;
late Commit previousCommit;
late Commit previousBlamelistEndCommit;
late Commit previousBlamelistStartCommit;
late Commit previousBuildPreviousCommit;

final buildersToRemove = <String>{};
final testsToRemove = <String>{};

void registerChangeForDeletion(Map<String, dynamic> change) {
  buildersToRemove.add(change['builder_name']!);
  testsToRemove.add(change['name']!);
}

Future<void> removeBuildersAndResults() async {
  Future<void> deleteDocuments(List<SafeDocument> documents) async {
    for (final document in documents) {
      await firestore.deleteDocument(document.name);
    }
  }

  for (final test in testsToRemove) {
    await deleteDocuments(await firestore.query(
        from: 'results', where: fieldEquals(fName, test)));
  }
  for (final builder in buildersToRemove) {
    await deleteDocuments(await firestore.query(
        from: 'builds', where: fieldEquals('builder', builder)));
  }
}

Future<void> loadCommits() async {
  commit = await commitsCache.getCommitByIndex(index);
  previousCommit = await commitsCache.getCommitByIndex(previousIndex);
  previousBlamelistStartCommit =
      await commitsCache.getCommitByIndex(previousBlamelistStart);
  previousBlamelistEndCommit =
      await commitsCache.getCommitByIndex(previousBlamelistEnd);
  previousBuildPreviousCommit =
      await commitsCache.getCommitByIndex(previousBuildPreviousIndex);
}

Build makeBuild(Map<String, dynamic> firstChange) => Build(
    BuildInfo.fromResult(firstChange, <String>{firstChange[fConfiguration]}),
    commitsCache,
    firestore);

Map<String, dynamic> makeChange(String name, String result,
    {bool flaky = false}) {
  final results = result.split('/');
  final previous = results[0];
  final current = results[1];
  final expected = results[2];
  final change = {
    fName: '${name}_test',
    fConfiguration: '${name}_configuration',
    'suite': 'unused_field',
    'test_name': 'unused_field',
    'time_ms': 2384,
    fResult: current,
    fPreviousResult: previous,
    fExpected: expected,
    fMatches: current == expected,
    fChanged: current != previous,
    fCommitHash: commit.hash,
    'commit_time': 1583906489,
    fBuildNumber: '99997',
    fBuilderName: 'builder_$name',
    fFlaky: flaky,
    fPreviousFlaky: false,
    fPreviousCommitHash: previousCommit.hash,
    'previous_commit_time': 1583906489,
    'bot_name': 'fake_bot_name',
    'previous_build_number': '306',
  };
  registerChangeForDeletion(change);
  return change;
}

Map<String, dynamic> makePreviousChange(String name, String result) {
  return makeChange(name, result)
    ..[fCommitHash] = previousBlamelistEndCommit.hash
    ..[fPreviousCommitHash] = previousBuildPreviousCommit.hash;
}

void main() async {
  final baseClient = http.Client();
  client = await clientViaApplicationDefaultCredentials(
      scopes: ['https://www.googleapis.com/auth/cloud-platform'],
      baseClient: baseClient);
  final api = FirestoreApi(client);
  firestore = FirestoreService(api, client);
  if (!firestore.isStaging) {
    throw (TestFailure('Error: test is being run on production'));
  }
  commitsCache = CommitsCache(firestore, client);
  await loadCommits();

  tearDownAll(() async {
    await removeBuildersAndResults();
    baseClient.close();
  });

  test('existing failure', () async {
    final failingPreviousChange =
        makePreviousChange('failure', 'Pass/RuntimeError/Pass')
          ..[fName] = 'previous_failure_test';
    registerChangeForDeletion(failingPreviousChange); // Name changed.
    final previousBuild = makeBuild(failingPreviousChange);
    final previousStatus = await previousBuild.process([failingPreviousChange]);
    expect(previousStatus.success, isFalse);
    expect(previousStatus.unapprovedFailures.values.first, hasLength(1));

    final failingChange = makeChange('failure', 'Pass/RuntimeError/Pass');
    final build = makeBuild(failingChange);
    final status = await build.process([failingChange]);
    expect(status.success, isFalse);
    expect(status.truncatedResults, isFalse);
    expect(status.unapprovedFailures, isNotEmpty);
    expect(status.unapprovedFailures.keys, contains('failure_configuration'));
    final failures = status.unapprovedFailures['failure_configuration']!;
    final previousFailure = failures
        .where((failure) => failure.getString(fName) == 'previous_failure_test')
        .single;
    final failure = failures
        .where((failure) => failure.getString(fName) == 'failure_test')
        .single;
    expect(previousFailure.getStringOrNull(fBlamelistEndCommit),
        previousBlamelistEndCommit.hash);
    expect(previousFailure.getStringOrNull(fBlamelistStartCommit),
        previousBlamelistStartCommit.hash);
    expect(failure.getStringOrNull(fBlamelistEndCommit), commit.hash);
    expect(failure.getStringOrNull(fBlamelistStartCommit), commit.hash);
    final message = status.toJson();
    expect(message, matches(r'There are unapproved failures\\n'));
    expect(
        message,
        matches(
            r'previous_failure_test   \(Pass -> RuntimeError , expected Pass \) at 44baaf\.\.ebe06b'));
    expect(
        message,
        matches(
            r'failure_test   \(Pass -> RuntimeError , expected Pass \) at 2368c2'));

    // Check a build with no changed results.
    // Another build with the same blamelist and configuration is allowed,
    // although it should not happen in practice. This build has no changes.
    final unchangedChange =
        makeChange('failure', 'RuntimeError/RuntimeError/Pass');
    final unchangedBuild = makeBuild(unchangedChange);
    final unchangedStatus = await unchangedBuild.process([]);
    expect(unchangedStatus.success, isTrue);
    expect(unchangedStatus.unapprovedFailures, isNotEmpty);
    expect(unchangedStatus.unapprovedFailures['failure_configuration']!,
        isNotEmpty);
  });

  test('existing approved failure', () async {
    final failingOtherConfigurationChange =
        makeChange('other', 'Pass/RuntimeError/Pass')
          ..[fName] = 'approved_failure_test'
          ..[fPreviousCommitHash] = previousBuildPreviousCommit.hash;
    registerChangeForDeletion(failingOtherConfigurationChange);
    final otherConfigurationBuild = makeBuild(failingOtherConfigurationChange);
    final otherStatus = await otherConfigurationBuild
        .process([failingOtherConfigurationChange]);
    expect(otherStatus.success, isFalse);
    expect(otherStatus.unapprovedFailures, isNotEmpty);
    expect(
        otherStatus.unapprovedFailures.keys, contains('other_configuration'));
    final result = (await firestore.findActiveResults(
            'approved_failure_test', 'other_configuration'))
        .single;
    expect(result.getInt(fBlamelistEndIndex), index);
    expect(result.getInt(fBlamelistStartIndex), previousBlamelistStart);
    await firestore.approveResult(result.toDocument());
    final failingChange =
        makeChange('approved_failure', 'Pass/RuntimeError/Pass');
    final build = makeBuild(failingChange);
    final status = await build.process([failingChange]);
    expect(status.success, isTrue);
    expect(status.truncatedResults, isFalse);
    expect(status.unapprovedFailures, isEmpty);
    final changedResult = (await firestore.findActiveResults(
            'approved_failure_test', 'other_configuration'))
        .single;
    expect(result.name, changedResult.name);
    // Check blamelist narrowing.
    expect(changedResult.getInt(fBlamelistEndIndex), index);
    expect(changedResult.getInt(fBlamelistStartIndex), index);
  });
}
