// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_admin_interop/firebase_admin_interop.dart';
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

void main() {
  final firestore = fs.FirestoreServiceImpl();

  test('Test chunk storing', () async {
    final builder = 'test_builder';
    final index = 123;
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
    });

    test('Test tryjob result processing', () async {
      // Set up database with approved results on previous patchset.
      await firestore.storePatchset(testReview.toString(), testPreviousPatchset,
          {'number': testPreviousPatchset});
      final previousFailingChange =
          Map<String, dynamic>.from(tryjobFailingChange)
            ..addAll(
                {"commit_hash": testPreviousPatchsetPath, "build_number": 307});
      await Tryjob(testPreviousPatchsetPath, 1, firestore, null)
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
      await Tryjob(testReviewPath, null, firestore, null)
          .process([tryjobPassingChange, tryjobFailingChange]);
      // Send second & final chunk with an unchanged failure.
      await Tryjob(testReviewPath, 2, firestore, null)
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
      await Tryjob(testReviewPath, null, firestore, null)
          .process([tryjobOtherFailingChange, tryjobFailingChange]);
      final reference = fs.firestore
          .document('try_builds/$testBuilder:$testReview:$testPatchset');
      document = await reference.get();
      expect(document.exists, isTrue);
      expect(document.data.getBool('success'), isFalse);
      expect(document.data.getBool('completed'), isNull);
      expect(document.data.getInt('num_chunks'), isNull);
      expect(document.data.getInt('processed_chunks'), 1);
      // Send second chunk.
      await Tryjob(testReviewPath, 3, firestore, null)
          .process([tryjobExistingFailure]);
      document = await reference.get();
      expect(document.data.getBool('success'), isFalse);
      expect(document.data.getBool('completed'), isNull);
      expect(document.data.getInt('num_chunks'), 3);
      expect(document.data.getInt('processed_chunks'), 2);
      // Send third and final chunk.
      await Tryjob(testReviewPath, null, firestore, null)
          .process([tryjobPassingChange]);
      document = await reference.get();
      expect(document.data.getBool('success'), isFalse);
      expect(document.data.getBool('completed'), isTrue);
      expect(document.data.getInt('num_chunks'), 3);
      expect(document.data.getInt('processed_chunks'), 3);

      // Send first chunk of a third run, with only one chunk.
      await Tryjob(testReviewPath, 1, firestore, null)
          .process([tryjobPassingChange]);
      document = await reference.get();
      expect(document.data.getBool('success'), isTrue);
      expect(document.data.getBool('completed'), isTrue);
      expect(document.data.getInt('num_chunks'), 1);
      expect(document.data.getInt('processed_chunks'), 1);
    });
  });
}
