// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../firestore_impl.dart' as fs;
import '../commits_cache.dart';
import '../tryjob.dart';
import 'fakes.dart';

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

fs.FirestoreServiceImpl firestore;
HttpClientMock client;
CommitsCache commitsCache;

void main() async {
  firestore = fs.FirestoreServiceImpl();
  if (!await firestore.isStaging()) {
    throw 'Test cannot be run on production database';
  }
  client = HttpClientMock();
  commitsCache = CommitsCache(firestore, client);
  addFakeReplies(client);
  setUpAll(addFakeResultsToLandedReviews);
  tearDownAll(deleteFakeReviewAndResults);

  test('create fake review', () async {
    final tryjob = Tryjob('refs/changes/$fakeReview/2', 1, buildBuildbucketId,
        buildBaseCommitHash, commitsCache, firestore, client);
    await tryjob.process([unchangedChange]);
    expect(tryjob.success, true);
  });

  test('process spurious result', () async {
    final tryjob = Tryjob(
        'refs/changes/$fakeReview/2',
        null,
        buildBuildbucketId,
        buildBaseCommitHash,
        commitsCache,
        firestore,
        client);
    await tryjob.process([changeMatchingLandedCL]);
    expect(tryjob.success, true);
  });

  test('process result on different configuration', () async {
    final tryjob = Tryjob(
        'refs/changes/$fakeReview/2',
        null,
        buildBuildbucketId,
        buildBaseCommitHash,
        commitsCache,
        firestore,
        client);
    await tryjob.process(
        [changeMatchingLandedCL..['configuration'] = otherConfiguration]);
    expect(tryjob.success, false);
  });

  test('process result where different result landed last', () async {
    final tryjob = Tryjob(
        'refs/changes/$fakeReview/2',
        null,
        buildBuildbucketId,
        buildBaseCommitHash,
        commitsCache,
        firestore,
        client);
    await tryjob.process([changeMatchingLandedCL..['name'] = otherFakeTest]);
    expect(tryjob.success, false);
  });
}

void addFakeReplies(HttpClientMock client) {
  when(client.get(any))
      .thenAnswer((_) => Future(() => ResponseFake(FakeReviewGerritLog)));
}

Future<void> addFakeResultsToLandedReviews() async {
  var tryjob = Tryjob(
      matchingLandedChange['commit_hash'],
      1,
      buildBuildbucketId,
      earlierTryBuildsBaseCommit,
      commitsCache,
      firestore,
      client);
  await tryjob.process([matchingLandedChange, overriddenMatchingLandedChange]);
  expect(tryjob.success, false);
  tryjob = Tryjob(
      overridingUnmatchingLandedChange['commit_hash'],
      1,
      buildBuildbucketId,
      earlierTryBuildsBaseCommit,
      commitsCache,
      firestore,
      client);
  await tryjob.process([overridingUnmatchingLandedChange]);
  expect(tryjob.success, false);
}

Future<void> deleteFakeReviewAndResults() async {
  deleteDocuments(query) async {
    for (final document in (await query.get()).documents) {
      await document.reference.delete();
    }
  }

  await deleteDocuments(fs.firestore
      .collection('try_results')
      .where('name', isEqualTo: fakeTest));
  await deleteDocuments(fs.firestore
      .collection('try_results')
      .where('name', isEqualTo: otherFakeTest));
  await deleteDocuments(fs.firestore
      .collection('try_builds')
      .where('builder', isEqualTo: fakeBuilderName));
  await deleteDocuments(
      fs.firestore.collection('reviews/$fakeReview/patchsets'));
  await fs.firestore.document('reviews/$fakeReview').delete();
}

Map<String, dynamic> changeMatchingLandedCL = {
  "name": fakeTest,
  "configuration": fakeConfiguration,
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

Map<String, dynamic> unchangedChange = Map.from(changeMatchingLandedCL)
  ..addAll({
    'name': otherFakeTest,
    'test_name': otherFakeTestName,
    'result': 'Pass',
    'matches': true,
    'changed': false,
    'configuration': otherConfiguration,
    'build_number': '99997'
  });

Map<String, dynamic> matchingLandedChange = Map.from(changeMatchingLandedCL)
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
