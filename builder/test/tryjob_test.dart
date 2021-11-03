// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:builder/src/firestore.dart';
import 'package:googleapis/firestore/v1.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'package:builder/src/firestore.dart' as fs;
import 'package:builder/src/commits_cache.dart';
import 'package:builder/src/tryjob.dart';
import 'fakes.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;

// These tests read and write data from the staging Firestore database.
// They create a fake review, and fake try builds against that review.
// They attempt to remove these records in the cleanup, even if tests fail.
// Requires the environment variable GOOGLE_APPLICATION_CREDENTIALS
// to point to a json key to a service account.
// To run against the staging database, use a service account.
// with write access to dart_ci_staging datastore.
// The test must be compiled with nodejs, and run using the 'node' command.

const fakeReview = 123;
const buildBaseCommit = 69191;
const buildBaseCommitHash = 'b681bfd8d275b84b51f37919f0edc0d8563a870f';
const buildBuildbucketId = 'a fake buildbucket ID';
const ciResultsCommitIndex = 69188;
const ciResultsCommitHash = '7b6adc6083c9918c826f5b82d25fdf6da9d90499';
const reviewForCommit69190 = 138293;
const patchsetForCommit69190 = 2;
const tryBuildForCommit69190 = '99998';
const reviewForCommit69191 = 138500;
const patchsetForCommit69191 = 7;
const tryBuildForCommit69191 = '99999';
const earlierTryBuildsBaseCommit = '8ae984c54ab36a05422af6f250dbaa7da70fc461';
const earlierTryBuildsResultsCommit = earlierTryBuildsBaseCommit;

const fakeSuite = 'fake_test_suite';
const fakeTestName = 'subdir/a_dart_test';
const otherFakeTestName = 'another_dart_test';
const fakeTest = '$fakeSuite/$fakeTestName';
const otherFakeTest = '$fakeSuite/$otherFakeTestName';
const fakeConfiguration = 'a configuration';
const otherConfiguration = 'another configuration';
const fakeBuilderName = 'fake_builder-try';

Set<String> fakeBuilders = {fakeBuilderName};
Set<String> fakeTests = {fakeTest, otherFakeTest};

void registerChangeForDeletion(Map<String, dynamic> change) {
  fakeBuilders.add(change['builder_name']);
  fakeTests.add(change['name']);
}

fs.FirestoreService firestore;
http.Client client;
CommitsCache commitsCache;

void main() async {
  final baseClient = http.Client();
  final mockClient = HttpClientMock();
  addFakeReplies(mockClient);
  client = await clientViaApplicationDefaultCredentials(
      scopes: ['https://www.googleapis.com/auth/cloud-platform'],
      baseClient: baseClient);
  final api = FirestoreApi(client);
  firestore = FirestoreService(api, client);
  if (!await firestore.isStaging()) {
    throw (TestFailure('Error: test is being run on production'));
  }

  if (!await firestore.isStaging()) {
    throw 'Test cannot be run on production database';
  }
  commitsCache = CommitsCache(firestore, mockClient);
  setUpAll(addFakeResultsToLandedReviews);
  tearDownAll(() async {
    await deleteFakeReviewAndResults();
    baseClient.close();
  });

  test('create fake review', () async {
    registerChangeForDeletion(unchangedChange);
    final tryjob = Tryjob('refs/changes/$fakeReview/2', buildBuildbucketId,
        buildBaseCommitHash, commitsCache, firestore, mockClient);
    await tryjob.process([unchangedChange]);
    expect(tryjob.success, true);
  });

  test('failure coming from a landed CL not in base', () async {
    registerChangeForDeletion(changeMatchingLandedCL);
    final tryjob = Tryjob('refs/changes/$fakeReview/2', buildBuildbucketId,
        buildBaseCommitHash, commitsCache, firestore, mockClient);
    await tryjob.process([changeMatchingLandedCL]);
    expect(tryjob.success, true);
  });

  // TODO(karlklose): These tests do not apply to the new model of processing a
  // build in one step.

  // test('process result on different configuration', () async {
  //   final changeOnDifferentConfiguration = Map<String, dynamic>.from(baseChange)
  //     ..['configuration'] = otherConfiguration;

  //   registerChangeForDeletion(changeOnDifferentConfiguration);
  //   final tryjob = Tryjob('refs/changes/$fakeReview/2', buildBuildbucketId,
  //       buildBaseCommitHash, commitsCache, firestore, mockClient);
  //   await tryjob.process([changeOnDifferentConfiguration]);
  //   expect(tryjob.success, false);
  // });

  // test('process result where different result landed last', () async {
  //   final otherNameChange = Map<String, dynamic>.from(baseChange)
  //     ..['name'] = otherFakeTest;
  //   registerChangeForDeletion(otherNameChange);
  //   final tryjob = Tryjob('refs/changes/$fakeReview/2', buildBuildbucketId,
  //       buildBaseCommitHash, commitsCache, firestore, mockClient);
  //   await tryjob.process([otherNameChange]);
  //   expect(tryjob.success, false);
  // });

  test('test becomes flaky', () async {
    final flakyTest = <String, dynamic>{
      'name': 'flaky_test',
      'result': 'RuntimeError',
      'flaky': true,
      'matches': false,
      'changed': true,
      'build_number': '99995',
      'builder_name': 'flaky_test_builder-try',
    };

    final flakyChange = Map<String, dynamic>.from(baseChange)
      ..addAll(flakyTest);
    final flakyTestBuildbucketId = 'flaky_buildbucket_ID';
    registerChangeForDeletion(flakyChange);
    final tryjob = Tryjob('refs/changes/$fakeReview/2', flakyTestBuildbucketId,
        buildBaseCommitHash, commitsCache, firestore, mockClient);
    await tryjob.process([flakyChange]);
    expect(tryjob.success, true);
    expect(tryjob.countNewFlakes, 1);
    expect(tryjob.countUnapproved, 0);
  });

  test('new failure', () async {
    final failingTest = <String, dynamic>{
      'name': 'failing_test',
      'result': 'RuntimeError',
      'matches': false,
      'changed': true,
      'build_number': '99994',
      'builder_name': 'failing_test_builder-try',
    };

    final failingChange = Map<String, dynamic>.from(baseChange)
      ..addAll(failingTest);
    final failingTestBuildbucketId = 'failing_buildbucket_ID';
    registerChangeForDeletion(failingChange);
    final tryjob = Tryjob(
        'refs/changes/$fakeReview/2',
        failingTestBuildbucketId,
        buildBaseCommitHash,
        commitsCache,
        firestore,
        mockClient);
    await tryjob.process([failingChange]);
    expect(tryjob.success, false);
    expect(tryjob.countNewFlakes, 0);
    expect(tryjob.countUnapproved, 1);
  });
}

void addFakeReplies(HttpClientMock client) {
  when(client.get(any))
      .thenAnswer((_) => Future(() => ResponseFake(FakeReviewGerritLog)));
}

Future<void> addFakeResultsToLandedReviews() async {
  var tryjob = Tryjob(matchingLandedChange['commit_hash'], buildBuildbucketId,
      earlierTryBuildsBaseCommit, commitsCache, firestore, client);
  await tryjob.process([matchingLandedChange, overriddenMatchingLandedChange]);
  expect(tryjob.success, false);
  tryjob = Tryjob(
      overridingUnmatchingLandedChange['commit_hash'],
      buildBuildbucketId,
      earlierTryBuildsBaseCommit,
      commitsCache,
      firestore,
      client);
  await tryjob.process([overridingUnmatchingLandedChange]);
  expect(tryjob.success, false);
}

Future<void> deleteFakeReviewAndResults() async {
  Future<void> deleteDocuments(List<RunQueryResponse> response) async {
    for (final document in response.map((r) => r.document)) {
      await firestore.deleteDocument(document.name);
    }
  }

  for (final test in fakeTests) {
    await deleteDocuments(await firestore.query(
        from: 'try_results', where: fieldEquals('name', test)));
  }
  for (final builder in fakeBuilders) {
    await deleteDocuments(await firestore.query(
        from: 'try_builds', where: fieldEquals('builder', builder)));
  }

  final patchsets =
      await firestore.query(from: 'patchsets', parent: 'reviews/$fakeReview/');
  for (final doc in patchsets) {
    if (doc.document != null) {
      await firestore.deleteDocument(doc.document.name);
    }
  }

  await firestore.deleteDocument(firestore.documents + '/reviews/$fakeReview');
}

Map<String, dynamic> baseChange = {
  'name': fakeTest,
  'configuration': fakeConfiguration,
  'suite': fakeSuite,
  'test_name': fakeTestName,
  'time_ms': 2384,
  'result': 'RuntimeError',
  'previous_result': 'Pass',
  'expected': 'Pass',
  'matches': false,
  'changed': true,
  'commit_hash': 'refs/changes/$fakeReview/2',
  'commit_time': 1583906489,
  'build_number': '99997',
  'builder_name': fakeBuilderName,
  'flaky': false,
  'previous_flaky': false,
  'previous_commit_hash': ciResultsCommitHash,
  'previous_commit_time': 1583906489,
  'bot_name': 'luci-dart-try-xenial-70-8fkh',
  'previous_build_number': '306',
};

Map<String, dynamic> changeMatchingLandedCL = Map.from(baseChange);

Map<String, dynamic> unchangedChange = Map.from(baseChange)
  ..addAll({
    'name': otherFakeTest,
    'test_name': otherFakeTestName,
    'result': 'Pass',
    'matches': true,
    'changed': false,
    'configuration': otherConfiguration,
    'build_number': '99997'
  });

Map<String, dynamic> matchingLandedChange = Map.from(baseChange)
  ..addAll({
    'commit_hash': 'refs/changes/$reviewForCommit69190/$patchsetForCommit69190',
    'build_number': tryBuildForCommit69190,
    'previous_commit_hash': earlierTryBuildsResultsCommit,
  });

Map<String, dynamic> overriddenMatchingLandedChange =
    Map.from(matchingLandedChange)
      ..addAll({
        'name': otherFakeTest,
        'test_name': otherFakeTestName,
      });

Map<String, dynamic> overridingUnmatchingLandedChange =
    Map.from(overriddenMatchingLandedChange)
      ..addAll({
        'commit_hash':
            'refs/changes/$reviewForCommit69191/$patchsetForCommit69191',
        'result': 'CompileTimeError',
        'build_number': tryBuildForCommit69191,
      });

String FakeReviewGerritLog = '''
)]}'
{
  "id": "sdk~master~Ie212fae88bc1977e34e4d791c644b77783a8deb1",
  "project": "sdk",
  "branch": "master",
  "hashtags": [],
  "change_id": "Ie212fae88bc1977e34e4d791c644b77783a8deb1",
  "subject": "A fake review",
  "status": "MERGED",
  "created": "2020-03-17 12:17:05.000000000",
  "updated": "2020-03-17 12:17:25.000000000",
  "submitted": "2020-03-17 12:17:25.000000000",
  "submitter": {
    "_account_id": 5260,
    "name": "commit-bot@chromium.org",
    "email": "commit-bot@chromium.org"
  },
  "insertions": 61,
  "deletions": 155,
  "total_comment_count": 0,
  "unresolved_comment_count": 0,
  "has_review_started": true,
  "submission_id": "$fakeReview",
  "_number": $fakeReview,
  "owner": {
  },
  "current_revision": "82f3f81fc82d06c575b0137ddbe71408826d8b46",
  "revisions": {
    "82f3f81fc82d06c575b0137ddbe71408826d8b46": {
      "kind": "REWORK",
      "_number": 2,
      "created": "2020-02-17 12:17:25.000000000",
      "uploader": {
        "_account_id": 5260,
        "name": "commit-bot@chromium.org",
        "email": "commit-bot@chromium.org"
      },
      "ref": "refs/changes/23/$fakeReview/2",
      "fetch": {
        "rpc": {
          "url": "rpc://dart/sdk",
          "ref": "refs/changes/23/$fakeReview/2"
        },
        "http": {
          "url": "https://dart.googlesource.com/sdk",
          "ref": "refs/changes/23/$fakeReview/2"
        },
        "sso": {
          "url": "sso://dart/sdk",
          "ref": "refs/changes/23/$fakeReview/2"
        }
      },
      "commit": {
        "parents": [
          {
            "commit": "d2d00ff357bd64a002697b3c96c92a0fec83328c",
            "subject": "[cfe] Allow unassigned late local variables"
          }
        ],
        "author": {
          "name": "gerrit_user",
          "email": "gerrit_user@example.com",
          "date": "2020-02-17 12:17:25.000000000",
          "tz": 0
        },
        "committer": {
          "name": "commit-bot@chromium.org",
          "email": "commit-bot@chromium.org",
          "date": "2020-02-17 12:17:25.000000000",
          "tz": 0
        },
        "subject": "A fake review",
        "message": "A fake review\\n\\nReviewed-by: XXX\\nCommit-Queue: XXXXXX\\n"
      },
      "description": "Rebase"
    },
    "8bae95c4001a0815e89ebc4c89dc5ad42337a01b": {
      "kind": "REWORK",
      "_number": 1,
      "created": "2020-02-17 12:17:05.000000000",
      "uploader": {
      },
      "ref": "refs/changes/23/$fakeReview/1",
      "fetch": {
        "rpc": {
          "url": "rpc://dart/sdk",
          "ref": "refs/changes/23/$fakeReview/1"
        },
        "http": {
          "url": "https://dart.googlesource.com/sdk",
          "ref": "refs/changes/23/$fakeReview/1"
        },
        "sso": {
          "url": "sso://dart/sdk",
          "ref": "refs/changes/23/$fakeReview/1"
        }
      }
    }
  },
  "requirements": []
}
''';
