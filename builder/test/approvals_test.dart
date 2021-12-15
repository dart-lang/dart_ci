// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:builder/src/builder.dart';
import 'package:builder/src/commits_cache.dart';
import 'package:builder/src/firestore.dart';
import 'package:builder/src/result.dart';
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

late final FirestoreService firestore;
late final http.Client client;
late final CommitsCache commitsCache;
// The real commits and reviews we will test on, fetched from Firestore.
// These globals are populated by loadTestCommits().
const testCommitsStart = 80801;
const reviewWithComments = '215021';
late final String index1; // Index of the final commit in the test range
late final String commit1; // Hash of that commit
late final String review; // CL number of that commit's Gerrit review
late final String lastPatchset; // Final patchset in that review
late final String lastPatchsetRef; // 'refs/changes/[review]/[patchset]'
late final String patchsetGroup; // First patchset in the final patchset group
late final String patchsetGroupRef;
late final String earlyPatchset; // Patchset not in the final patchset group
late final String earlyPatchsetRef;
// Earlier commit with a review
late final String index2;
late final String commit2;
late final String review2;
late final String patchset2;
late final String patchset2Ref;
// Commits before commit2
late final String index3;
late final String commit3;
late final String index4;
late final String commit4;

final buildersToRemove = <String>{};
final testsToRemove = <String>{};

void registerChangeForDeletion(Map<String, dynamic> change) {
  buildersToRemove.add(change['builder_name'] as String);
  testsToRemove.add(change['name'] as String);
}

Future<void> removeBuildersAndResults() async {
  Future<void> deleteDocuments(List<SafeDocument> documents) async {
    for (final document in documents) {
      await firestore.deleteDocument(document.name);
    }
  }

  for (final test in testsToRemove) {
    await deleteDocuments(await firestore.query(
        from: 'try_results', where: fieldEquals('name', test)));
  }
  for (final test in testsToRemove) {
    await deleteDocuments(await firestore.query(
        from: 'results', where: fieldEquals('name', test)));
  }
  for (final builder in buildersToRemove) {
    await deleteDocuments(await firestore.query(
        from: 'try_builds', where: fieldEquals('builder', builder)));
  }
  for (final builder in buildersToRemove) {
    await deleteDocuments(await firestore.query(
        from: 'builds', where: fieldEquals('builder', builder)));
  }
  for (final builder in buildersToRemove) {
    await deleteDocuments(await firestore.query(
        from: 'configurations', where: fieldEquals('builder', builder)));
  }
}

Future<void> loadTestCommits(int startIndex) async {
  // Get review data for the last two landed CLs before or at startIndex.
  final reviews = await firestore.query(
      from: 'reviews',
      orderBy: orderBy('landed_index', false),
      where: fieldLessThanOrEqual('landed_index', startIndex),
      limit: 2);
  final firstReview = reviews.first;
  index1 = firstReview.fields['landed_index']!.integerValue!;
  review = firstReview.name.split('/').last;
  final secondReview = reviews.last;
  index2 = secondReview.fields['landed_index']!.integerValue!;
  review2 = secondReview.name.split('/').last;
  index3 = (int.parse(index2) - 1).toString();
  index4 = (int.parse(index2) - 2).toString();

  final patchsets = await firestore.query(
    from: 'patchsets',
    parent: 'reviews/$review',
    orderBy: orderBy('number', true),
  );
  final patchsetFields = patchsets.last.fields;
  lastPatchset = patchsetFields['number']!.integerValue!;
  lastPatchsetRef = 'refs/changes/$review/$lastPatchset';
  patchsetGroup = patchsetFields['patchset_group']!.integerValue!;
  patchsetGroupRef = 'refs/changes/$review/$patchsetGroup';
  earlyPatchset = '1';
  earlyPatchsetRef = 'refs/changes/$review/$earlyPatchset';
  final patchsets2 = await firestore.query(
    from: 'patchsets',
    parent: 'reviews/$review2',
    orderBy: orderBy('number', true),
  );
  patchset2 = patchsets2.last.fields['number']!.integerValue!;
  patchset2Ref = 'refs/changes/$review/$patchset2';

  // Get commit hashes for the landed reviews, and for a commit before them
  var commits = {
    for (final index in [index1, index2, index3, index4])
      index: (await firestore.query(
              from: 'commits',
              where: fieldEquals('index', int.parse(index)),
              limit: 1))
          .first
          .name
          .split('/')
          .last
  };
  commit1 = commits[index1]!;
  commit2 = commits[index2]!;
  commit3 = commits[index3]!;
  commit4 = commits[index4]!;
}

Tryjob makeTryjob(String name, Map<String, dynamic> firstChange,
        {String? baseCommit}) =>
    Tryjob(BuildInfo.fromResult(firstChange) as TryBuildInfo, 'bbID_$name',
        baseCommit ?? commit4, commitsCache, firestore, client);

const newFailure = 'Pass/RuntimeError/Pass';
Map<String, dynamic> makeTryChange(
    String name, String result, String patchsetRef,
    {String? testName}) {
  final results = result.split('/');
  final previous = results[0];
  final current = results[1];
  final expected = results[2];
  final change = {
    'name': '${testName ?? name}_test',
    'configuration': '${name}_configuration',
    'suite': 'unused_field',
    'test_name': 'unused_field',
    'time_ms': 2384,
    'result': current,
    'previous_result': previous,
    'expected': expected,
    'matches': current == expected,
    'changed': current != previous,
    'commit_hash': patchsetRef,
    'commit_time': 1583906489,
    'build_number': '99997',
    'builder_name': 'builder_$name',
    'flaky': false,
    'previous_flaky': false,
    'previous_commit_hash': commit4,
    'previous_commit_time': 1583906489,
    'bot_name': 'fake_bot_name',
    'previous_build_number': '306',
  };
  registerChangeForDeletion(change);
  return change;
}

Map<String, dynamic> makeChange(
    String name, String result, String commit, String previousCommit,
    {String? testName}) {
  final change = {
    ...makeTryChange(name, result, '', testName: testName),
    'commit_hash': commit,
    'previous_commit_hash': previousCommit,
  };
  return change;
}

Build makeBuild(String commit, Map<String, dynamic> change) {
  return Build(BuildInfo.fromResult(change), commitsCache, firestore);
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
  await loadTestCommits(testCommitsStart);

  tearDownAll(() async {
    await removeBuildersAndResults();
    baseClient.close();
  });

  test('commit range', () async {
    // If the review does not have a final patchset group with multiple
    // patchsets, find one that does and set testCommitsStart to that index.
    expect(lastPatchset, isNot(patchsetGroup));
    expect(patchsetGroup, isNot(earlyPatchset));
    expect(int.parse(index2), lessThan(int.parse(index1)));
    // reviewWithComments should have some comments, to test linking
    final comments = await firestore.query(
        from: 'comments',
        where: fieldEquals('review', int.parse(reviewWithComments)));
    expect(comments, isNotEmpty);
  });

  test('approvals', () async {
    // Test that approvals are copied from approved try results in the
    // blamelist range of a CI build
    final change1 = makeTryChange('approvals', newFailure, lastPatchsetRef);
    await makeTryjob('approvals', change1).process([change1]);
    var documents = await firestore.query(
        from: 'try_results', where: fieldEquals('name', 'approvals_test'));
    await firestore.approveResult(documents.single.toDocument());
    final change2 = makeTryChange('approvals', newFailure, patchsetGroupRef,
        testName: 'approvals_2');
    await makeTryjob('approvals', change2).process([change2]);
    documents = await firestore.query(
        from: 'try_results', where: fieldEquals('name', 'approvals_2_test'));
    await firestore.approveResult(documents.single.toDocument());

    final change3 = makeChange('approvals', newFailure, commit1, commit4);
    final change3a = makeChange('approvals', newFailure, commit1, commit4)
      ..['configuration'] = 'second_approvals_configuration';
    final change4 = makeChange('approvals', newFailure, commit1, commit4,
        testName: 'approvals_2');
    await makeBuild(commit1, change3).process([change3, change3a, change4]);
    await checkBuild(change3['builder_name'], index1, success: true);
    await checkResult(change3, index3, index1, {
      'approved': true,
    });
    // Add a second configuration to an existing test failure, narrowing
    // the blamelist
    final change5 = makeChange('approvals_3', newFailure, commit1, commit3,
        testName: 'approvals');
    await makeBuild(commit1, change5).process([change5]);
    await checkBuild(change5['builder_name'], index1, success: true);
    await checkResult(change5, index2, index1, {
      'approved': true,
      'configurations': [
        change3['configuration'],
        change3a['configuration'],
        change5['configuration']
      ],
    });
  });

  test('link_review', () async {
    // The linkReviewToCommit and linkCommentsToCommit functions are
    // idempotent, they just add some fields to documents.
    // Remove the links from comments and review and recreate them.
    expect(reviewWithComments, isNot(review));
    expect(reviewWithComments, isNot(review2));
    expect(
        await firestore.reviewIsLanded(int.parse(reviewWithComments)), isTrue);
    var commentsQuery = await firestore.query(
        from: 'comments',
        where: fieldEquals('review', int.parse(reviewWithComments)));
    final landedIndex =
        commentsQuery.first.fields[fBlamelistStartIndex]!.integerValue!;
    for (final item in commentsQuery) {
      final fields = item.fields;
      expect(fields[fBlamelistStartIndex]!.integerValue, landedIndex);
      expect(fields[fBlamelistEndIndex]!.integerValue, landedIndex);
      expect(fields[fReview]!.integerValue, reviewWithComments);
      fields.remove(fBlamelistStartIndex);
      fields.remove(fBlamelistEndIndex);
      await firestore.updateFields(
          item.toDocument(), [fBlamelistStartIndex, fBlamelistEndIndex]);
    }
    var reviewDocument = await firestore
        .getDocument('${firestore.documents}/reviews/$reviewWithComments');
    expect(reviewDocument.fields!['landed_index']!.integerValue, landedIndex);
    reviewDocument.fields!.remove('landed_index');
    await firestore.updateFields(reviewDocument, ['landed_index']);

    await firestore.linkReviewToCommit(
        int.parse(reviewWithComments), int.parse(landedIndex));
    await firestore.linkCommentsToCommit(
        int.parse(reviewWithComments), int.parse(landedIndex));
    commentsQuery = await firestore.query(
        from: 'comments',
        where: fieldEquals('review', int.parse(reviewWithComments)));
    for (final item in commentsQuery) {
      final fields = item.fields;
      expect(fields[fBlamelistStartIndex]!.integerValue, landedIndex);
      expect(fields[fBlamelistEndIndex]!.integerValue, landedIndex);
      expect(fields[fReview]!.integerValue, reviewWithComments);
    }
    reviewDocument = await firestore
        .getDocument('${firestore.documents}/reviews/$reviewWithComments');
    expect(reviewDocument.fields!['landed_index']!.integerValue, landedIndex);
  });
}

Future<void> checkTryBuild(String name,
    {bool? success, bool? truncated}) async {
  final buildbucketId = 'bbID_$name';
  final buildDocuments = await firestore.query(
      from: 'try_builds', where: fieldEquals('buildbucket_id', buildbucketId));
  expect(buildDocuments.length, 1);
  final document = buildDocuments.single;
  expect(document.getBool('success'), success);
  if (truncated != null) {
    expect(document.getBool('truncated'), truncated);
  } else {
    expect(document.fields.containsKey('truncated'), isFalse);
  }
}

Future<void> checkBuild(String? builder, String index, {bool? success}) async {
  final document = await firestore
      .getDocument('${firestore.documents}/builds/$builder:$index');
  expect(document.fields!['success']!.booleanValue, success);
}

Future<void> checkResult(Map<String, dynamic> change, String startIndex,
    String endIndex, Map<String, dynamic> expected) async {
  expect([fConfigurations, fApproved], containsAll(expected.keys));
  final resultName = await firestore.findResult(
      change, int.parse(startIndex), int.parse(endIndex));
  expect(resultName, isNotNull);
  final resultDocument = await firestore.getDocument(resultName!);
  final data = untagMap(resultDocument.fields!);
  expect(data[fName], change[fName]);
  expect(data[fBlamelistStartIndex], int.parse(startIndex));
  expect(data[fBlamelistEndIndex], int.parse(endIndex));
  expect(data[fConfigurations],
      unorderedEquals(expected[fConfigurations] ?? data[fConfigurations]));
  expect(data[fApproved], expected[fApproved] ?? data[fApproved]);
}
