// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:builder/src/firestore.dart';
import 'package:test/test.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis/firestore/v1.dart';

import 'test_data.dart';

// These tests read and write data from the Firestore database, and
// should only be run locally against the dart-ci-staging project.
// Requires the environment variable GOOGLE_APPLICATION_CREDENTIALS
// to point to a json key to a service account
// with write access to dart_ci_staging datastore.
// Set the database with 'firebase use --add dart-ci-staging'

void main() async {
  final baseClient = http.Client();
  final client = await clientViaApplicationDefaultCredentials(
      scopes: ['https://www.googleapis.com/auth/cloud-platform'],
      baseClient: baseClient);
  final api = FirestoreApi(client);
  final firestore = FirestoreService(api, client);
  if (!await firestore.isStaging()) {
    throw (TestFailure(
        'Error: firestore_test_nodejs.dart is being run on production'));
  }

  const testDatabaseName =
      'projects/dart-ci-staging/databases/(default)/documents';
  const testReviewDocument = '$testDatabaseName/reviews/$testReview';
  const removeActiveConfigurationTestName =
      'firestore_test/Remove_active_configuration';
  final createdResult = {
    ...activeFailureResult,
    'name': removeActiveConfigurationTestName
  };

  tearDownAll(() => baseClient.close());

  group('Try results', () {
    setUp(() async {
      if (await firestore.documentExists(testReviewDocument)) {
        await firestore.deleteDocument(testReviewDocument);
      }
    });

    tearDown(() async {
      // Delete database records created by the tests.
      var snapshot = await firestore.query(
          from: 'try_builds', where: fieldEquals('review', testReview));
      for (final doc in snapshot) {
        await firestore.deleteDocument(doc.name);
      }

      snapshot = await firestore.query(
          from: 'patchsets', parent: 'reviews/$testReview/');
      for (final doc in snapshot) {
        await firestore.deleteDocument(doc.name);
      }
      snapshot = await firestore.query(
          from: 'results',
          where: fieldEquals('name', removeActiveConfigurationTestName));
      for (final doc in snapshot) {
        await firestore.deleteDocument(doc.name);
      }
      await firestore.deleteDocument(testReviewDocument);
    });

    test('Remove active configuration', () async {
      // Remove the two active configurations from createdResultDocument,
      // checking that the document is updated correctly at each stage.
      final createdResultDocument = await firestore.storeResult(createdResult);
      final name = removeActiveConfigurationTestName;

      var foundActiveResults =
          await firestore.findActiveResults(name, testConfiguration);
      var activeResult = foundActiveResults.single;
      expect(createdResultDocument.name, activeResult.name);

      await firestore.removeActiveConfiguration(
          activeResult, testConfiguration);
      foundActiveResults =
          await firestore.findActiveResults(name, testConfiguration);
      expect(foundActiveResults, isEmpty);
      foundActiveResults =
          await firestore.findActiveResults(name, 'configuration 2');
      activeResult = foundActiveResults.single;

      expect(activeResult.fields, contains('active'));
      await firestore.removeActiveConfiguration(
          activeResult, 'configuration 2');
      final document = await firestore.getDocument(createdResultDocument.name!);
      expect(document.fields, isNot(contains('active')));
      expect(document.fields, isNot(contains('active_configurations')));
      await firestore.deleteDocument(createdResultDocument.name!);
    });

    test('approved try result fetching', () async {
      await firestore.storeReview(
          testReview.toString(),
          taggedMap({
            'subject': 'test review: approved try result fetching',
          }));
      await firestore.storePatchset(
        testReview.toString(),
        1,
        'REWORK',
        'Initial upload',
        1,
        1,
      );
      await firestore.storePatchset(
        testReview.toString(),
        2,
        'REWORK',
        'change',
        2,
        2,
      );
      await firestore.storePatchset(
        testReview.toString(),
        3,
        'NO_CODE_CHANGE',
        'Edit commit message',
        2,
        3,
      );
      final tryResult = {
        'review': testReview,
        'configuration': 'test_configuration',
        'name': 'test_suite/test_name',
        'patchset': 1,
        'result': 'RuntimeError',
        'expected': 'Pass',
        'previous_result': 'Pass',
      };
      await firestore.storeTryChange(tryResult, testReview, 1);
      final tryResult2 = Map<String, dynamic>.from(tryResult);
      tryResult2['patchset'] = 2;
      tryResult2['name'] = 'test_suite/test_name_2';
      await firestore.storeTryChange(tryResult2, testReview, 2);
      tryResult['patchset'] = 3;
      tryResult['name'] = 'test_suite/test_name';
      tryResult['expected'] = 'CompileTimeError';
      await firestore.storeTryChange(tryResult, testReview, 3);
      // Set the results on patchsets 1 and 2 to approved.
      final snapshot = await firestore.query(
          from: 'try_results',
          where: compositeFilter([
            fieldEquals('approved', false),
            fieldEquals('review', testReview),
            fieldLessThanOrEqual('patchset', 2)
          ]));
      for (final response in snapshot) {
        await firestore.approveResult(response.toDocument());
        //await firestore.updateDocument(response.document.name, {'approved': taggedValue(true)});
      }

      // Should return only the approved change on patchset 2,
      // not the one on patchset 1 or the unapproved change on patchset 3.
      final approvals = await firestore.tryApprovals(testReview);
      tryResult2['configurations'] = [tryResult2['configuration']];
      tryResult2['approved'] = true;
      tryResult2.remove('configuration');
      expect(1, approvals.length);
      final approval = untagMap(approvals.single.fields);
      expect(approval, tryResult2);
    });
  });
}
