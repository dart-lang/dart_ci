// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:node_interop/node.dart';
import 'package:test/test.dart';

import '../firestore_impl.dart' as fs;
import '../tryjob.dart';
import 'test_data.dart';

// These tests read and write data from the Firestore database, and
// should only be run locally against the dart-ci-staging project.
// Requires the environment variable GOOGLE_APPLICATION_CREDENTIALS
// to point to a json key to a service account
// with write access to dart_ci_staging datastore.
// Set the database with 'firebase use --add dart-ci-staging'
// The test must be compiled with nodejs, and run using the 'node' command.

void main() async {
  final firestore = fs.FirestoreServiceImpl();
  if (!await firestore.isStaging()) {
    console
        .error('Error: firestore_test_nodejs.dart is being run on production');
    throw (TestFailure(
        'Error: firestore_test_nodejs.dart is being run on production'));
  }

  test('Test chunk storing', () async {
    final builder = testBuilder;
    final configuration = testConfiguration;
    final index = 123;

    await firestore.updateConfiguration(configuration, builder);
    final failingResultReference = await fs.firestore
        .collection('results')
        .add(DocumentData.fromMap(activeFailureResult));

    final document = fs.firestore.document('builds/$builder:$index');

    await document.delete();
    await firestore.updateBuildInfo(builder, 3456, index);
    await firestore.storeChunkStatus(builder, index, true);
    await firestore.storeBuildChunkCount(builder, index, 4);
    await firestore.storeChunkStatus(builder, index, true);

    DocumentSnapshot snapshot = await document.get();
    var data = snapshot.data.toMap();
    expect(data['success'], isTrue);
    expect(data['num_chunks'], 4);
    expect(data['processed_chunks'], 2);
    expect(data['completed'], isNull);

    await firestore.storeChunkStatus(builder, index, false);
    await firestore.storeChunkStatus(builder, index, true);

    snapshot = await document.get();
    data = snapshot.data.toMap();
    expect(data['success'], isFalse);
    expect(data['num_chunks'], 4);
    expect(data['processed_chunks'], 4);
    expect(data['completed'], isTrue);
    expect(data['active_failures'], isTrue);
    await document.delete();
    await failingResultReference.delete();
    await fs.firestore.document('configurations/$testConfiguration').delete();
  });

  group('Try results', () {
    tearDown(() async {
      // Delete database records created by the tests.
      var snapshot = await fs.firestore
          .collection('try_builds')
          .where('review', isEqualTo: testReview)
          .get();
      for (final doc in snapshot.documents) {
        await doc.reference.delete();
      }
      snapshot = await fs.firestore
          .collection('try_results')
          .where('review', isEqualTo: testReview)
          .get();
      for (final doc in snapshot.documents) {
        await doc.reference.delete();
      }
      snapshot =
          await fs.firestore.collection('reviews/$testReview/patchsets').get();
      for (final doc in snapshot.documents) {
        await doc.reference.delete();
      }
      await fs.firestore.document('reviews/$testReview').delete();
    });

    test('approved try result fetching', () async {
      await firestore.storeReview(testReview.toString(), {
        'subject': 'test review: approved try result fetching',
      });
      await firestore.storePatchset(testReview.toString(), 1, {
        'kind': 'REWORK',
        'description': 'Initial upload',
        'patchset_group': 1,
        'number': 1,
      });
      await firestore.storePatchset(testReview.toString(), 2, {
        'kind': 'REWORK',
        'description': 'change',
        'patchset_group': 2,
        'number': 2,
      });
      await firestore.storePatchset(testReview.toString(), 3, {
        'kind': 'NO_CODE_CHANGE',
        'description': 'Edit commit message',
        'patchset_group': 2,
        'number': 3,
      });
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
      final snapshot = await fs.firestore
          .collection('try_results')
          .where('approved', isEqualTo: false)
          .where('review', isEqualTo: testReview)
          .where('patchset', isLessThanOrEqualTo: 2)
          .get();
      for (final document in snapshot.documents) {
        await document.reference
            .updateData(UpdateData.fromMap({'approved': true}));
      }

      // Should return only the approved change on patchset 2,
      // not the one on patchset 1 or the unapproved change on patchset 3.
      final approvals = await firestore.tryApprovals(testReview);
      tryResult2['configurations'] = [tryResult2['configuration']];
      tryResult2['approved'] = true;
      tryResult2.remove('configuration');
      expect(approvals, [tryResult2]);
    });

    test('Test tryjob result processing', () async {
      // Set up database with approved results on previous patchset.
      await firestore.storePatchset(testReview.toString(), testPreviousPatchset,
          {'number': testPreviousPatchset});
      final previousFailingChange = Map<String, dynamic>.from(
          tryjobFailingChange)
        ..addAll(
            {'commit_hash': testPreviousPatchsetPath, 'build_number': '307'});
      final buildID0 = 'test buildbucket id 0';
      await Tryjob(testPreviousPatchsetPath, 1, buildID0, null, null, firestore,
              null)
          .process([previousFailingChange]);
      var snapshot = await fs.firestore
          .collection('try_results')
          .where('name', isEqualTo: previousFailingChange['name'])
          .where('review', isEqualTo: testReview)
          .where('patchset', isEqualTo: testPreviousPatchset)
          .get();
      expect(snapshot.isNotEmpty, isTrue);
      expect(snapshot.documents.length, 1);
      await snapshot.documents.first.reference
          .updateData(UpdateData.fromMap({'approved': true}));

      await firestore.storePatchset(testReview.toString(), testPatchset,
          {'number': testPreviousPatchset});
      // Send first chunk with a previously approved result and a passing result
      final buildID1 = 'test buildbucket id 1';
      await Tryjob(testReviewPath, null, buildID1, null, null, firestore, null)
          .process([tryjobPassingChange, tryjobFailingChange]);
      // Send second & final chunk with an unchanged failure.
      await Tryjob(testReviewPath, 2, buildID1, null, null, firestore, null)
          .process([tryjobExistingFailure, tryjobFailingChange]);
      // Verify state
      snapshot = await fs.firestore
          .collection('try_builds')
          .where('builder', isEqualTo: testBuilder)
          .where('review', isEqualTo: testReview)
          .where('patchset', isEqualTo: testPatchset)
          .get();
      expect(snapshot.documents.length, 1);
      DocumentSnapshot document = snapshot.documents.first;
      expect(document.documentID, '$testBuilder:$testReview:$testPatchset');
      expect(document.data.getInt('build_number'), int.parse(testBuildNumber));
      expect(document.data.getString('buildbucket_id'), buildID1);
      expect(document.data.getBool('success'), isTrue);
      expect(document.data.getBool('completed'), isTrue);
      // Verify that sending a result twice only adds its configuration once
      // to the try result.
      snapshot = await fs.firestore
          .collection('try_results')
          .where('name', isEqualTo: 'test_suite/failing_test')
          .where('review', isEqualTo: testReview)
          .where('patchset', isEqualTo: testPatchset)
          .get();
      expect(snapshot.documents.length, 1);
      document = snapshot.documents.first;
      expect(document.data.getList('configurations'), ['test_configuration']);
      expect(document.data.getBool('approved'), isTrue);

      // Send first chunk of second run on the same patchset, with an approved
      // failure and an unapproved failure.
      final buildID2 = 'test buildbucket id 2';
      await Tryjob(testReviewPath, null, buildID2, null, null, firestore, null)
          .process([tryjob2OtherFailingChange, tryjob2FailingChange]);
      final reference = fs.firestore
          .document('try_builds/$testBuilder:$testReview:$testPatchset');
      document = await reference.get();
      expect(document.exists, isTrue);
      expect(document.data.getBool('success'), isFalse);
      expect(document.data.getBool('completed'), isNull);
      expect(document.data.getString('buildbucket_id'), buildID2);
      expect(document.data.getInt('num_chunks'), isNull);
      expect(document.data.getInt('processed_chunks'), 1);
      // Send second chunk.
      await Tryjob(testReviewPath, 3, buildID2, null, null, firestore, null)
          .process([tryjob2ExistingFailure]);
      document = await reference.get();
      expect(document.data.getBool('success'), isFalse);
      expect(document.data.getBool('completed'), isNull);
      expect(document.data.getString('buildbucket_id'), buildID2);
      expect(document.data.getInt('num_chunks'), 3);
      expect(document.data.getInt('processed_chunks'), 2);
      // Send third and final chunk.
      await Tryjob(testReviewPath, null, buildID2, null, null, firestore, null)
          .process([tryjob2PassingChange]);
      document = await reference.get();
      expect(document.data.getBool('success'), isFalse);
      expect(document.data.getBool('completed'), isTrue);
      expect(document.data.getString('buildbucket_id'), buildID2);
      expect(document.data.getInt('num_chunks'), 3);
      expect(document.data.getInt('processed_chunks'), 3);

      // Send first chunk of a third run, with only one chunk.
      final buildID3 = 'test buildbucket id 3';
      await Tryjob(testReviewPath, 1, buildID3, null, null, firestore, null)
          .process([tryjob3PassingChange]);
      document = await reference.get();
      expect(document.data.getBool('success'), isTrue);
      expect(document.data.getBool('completed'), isTrue);
      expect(document.data.getString('buildbucket_id'), buildID3);
      expect(document.data.getInt('num_chunks'), 1);
      expect(document.data.getInt('processed_chunks'), 1);
    });
  });
}
