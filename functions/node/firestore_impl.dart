// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:math' show max, min;
import 'package:firebase_admin_interop/firebase_admin_interop.dart';

import 'firestore.dart';

void info(Object message) {
  print("Info: $message");
}

void error(Object message) {
  print("Error: $message");
}

// Cloud functions run the cloud function many times in the same isolate.
// Use static initializer to run global initialization once.
Firestore firestore = createFirestore();

Firestore createFirestore() {
  final app = FirebaseAdmin.instance.initializeApp();
  return app.firestore()
    ..settings(FirestoreSettings(timestampsInSnapshots: true));
}

class FirestoreServiceImpl implements FirestoreService {
  Future<bool> hasPatchset(String review, String patchset) => firestore
      .document('reviews/$review/patchsets/$patchset')
      .get()
      .then((s) => s.exists);

  Future<Map<String, dynamic>> getCommit(String hash) => firestore
      .document('commits/$hash')
      .get()
      .then((s) => s.exists ? s.data.toMap() : null);

  Future<Map<String, dynamic>> getLastCommit() async {
    QuerySnapshot lastCommit = await firestore
        .collection('commits')
        .orderBy('index', descending: true)
        .limit(1)
        .get();
    final result = lastCommit.documents.first.data.toMap();
    result['id'] = lastCommit.documents.first.documentID;
    return result;
  }

  Future<void> addCommit(String id, Map<String, dynamic> data) async {
    data['created'] = Timestamp.fromDateTime(data['created']);
    final docRef = firestore.document('commits/$id');
    await docRef.setData(DocumentData.fromMap(data));
  }

  Future<void> updateConfiguration(String configuration, String builder) async {
    final record =
        await firestore.document('configurations/$configuration').get();
    if (!record.exists || record.data.getString('builder') != builder) {
      await firestore
          .document('configurations/$configuration')
          .setData(DocumentData.fromMap({'builder': builder}));
      if (!record.exists) {
        info('Configuration document $configuration -> $builder created');
      } else {
        info('Configuration document changed: $configuration -> $builder '
            '(was ${record.data.getString("builder")}');
      }
    }
  }

  Future<void> updateBuildInfo(
      String builder, int buildNumber, int index) async {
    final documentRef = firestore.document('builds/$builder:$index');
    final record = await documentRef.get();
    if (!record.exists) {
      await documentRef.setData(DocumentData.fromMap(
          {'builder': builder, 'build_number': buildNumber, 'index': index}));
      info('Created build record: '
          'builder: $builder, build_number: $buildNumber, index: $index');
    } else if (record.data.getInt('index') != index) {
      error(
          'Build $buildNumber of $builder had commit index ${record.data.getInt('index')},'
          'should be $index.');
    }
  }

  Future<String> findResult(
      Map<String, dynamic> change, int startIndex, int endIndex) async {
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
        .limit(5) // We will pick the right one, probably the latest.
        .get();

    bool blamelistIncludesChange(DocumentSnapshot groupDocument) {
      var group = groupDocument.data;
      var groupStart = group.getInt('blamelist_start_index');
      var groupEnd = group.getInt('blamelist_end_index');
      return startIndex <= groupEnd && endIndex >= groupStart;
    }

    return snapshot.documents
        .firstWhere(blamelistIncludesChange, orElse: () => null)
        ?.documentID;
  }

  Future<void> storeResult(
          Map<String, dynamic> change, int startIndex, int endIndex,
          {bool approved = false}) =>
      firestore.collection('results').add(DocumentData.fromMap({
            'name': change['name'],
            'result': change['result'],
            'previous_result': change['previous_result'] ?? 'new test',
            'expected': change['expected'],
            'blamelist_start_index': startIndex,
            'blamelist_end_index': endIndex,
            'configurations': <String>[change['configuration']],
            if (approved) 'approved': true
          }));

  Future<bool> updateResult(
      String result, String configuration, int startIndex, int endIndex) {
    DocumentReference reference = firestore.document('results/$result');

    // Update the change group in a transaction.
    Future<bool> updateGroup(Transaction transaction) =>
        transaction.get(reference).then((resultSnapshot) {
          final data = resultSnapshot.data;
          bool approved = data.getBool('approved') ?? false;
          // Add the new configuration and narrow the blamelist.
          final newStart =
              max(startIndex, data.getInt('blamelist_start_index'));
          final newEnd = min(endIndex, data.getInt('blamelist_end_index'));
          final update = UpdateData.fromMap({
            'blamelist_start_index': newStart,
            'blamelist_end_index': newEnd,
          });
          update.setFieldValue('configurations',
              Firestore.fieldValues.arrayUnion([configuration]));
          reference.updateData(update);
          return approved;
        });

    return firestore.runTransaction(updateGroup);
  }

  Future<bool> storeTryChange(
      Map<String, dynamic> change, int review, int patchset) async {
    String name = change['name'];
    String result = change['result'];
    String expected = change['expected'];
    String previousResult = change['previous_result'] ?? 'new test';
    // Find an existing TryResult for this test on this patchset.
    QuerySnapshot snapshot = await firestore
        .collection('try_results')
        .where('review', isEqualTo: review)
        .where('patchset', isEqualTo: patchset)
        .where('name', isEqualTo: name)
        .where('result', isEqualTo: result)
        .where('previous_result', isEqualTo: previousResult)
        .where('expected', isEqualTo: expected)
        .limit(1)
        .get();
    if (snapshot.isEmpty) {
      // Is the previous result for this test on this review approved?
      QuerySnapshot previous = await firestore
          .collection('try_results')
          .where('review', isEqualTo: review)
          .where('name', isEqualTo: name)
          .where('result', isEqualTo: result)
          .where('previous_result', isEqualTo: previousResult)
          .where('expected', isEqualTo: expected)
          .orderBy('patchset', descending: true)
          .limit(1)
          .get();
      // Create a TryResult for this test on this patchset.
      final approved = previous.isNotEmpty &&
          previous.documents.first.data.getBool('approved') == true;
      await firestore.collection('try_results').add(DocumentData.fromMap({
            'name': name,
            'result': result,
            'previous_result': previousResult,
            'expected': expected,
            'review': review,
            'patchset': patchset,
            'configurations': <String>[change['configuration']],
            if (approved) 'approved': true
          }));
      return approved;
    } else {
      // Update the TryResult for this test, adding this configuration.
      final update = UpdateData()
        ..setFieldValue('configurations',
            Firestore.fieldValues.arrayUnion([change['configuration']]));
      await snapshot.documents.first.reference.updateData(update);
      // Return true if this result is approved
      return snapshot.documents.first.data.getBool('approved') == true;
    }
  }

  Future<void> storeReview(String review, Map<String, dynamic> data) =>
      firestore.document('reviews/$review').setData(DocumentData.fromMap(data));

  Future<void> storePatchset(
          String review, int patchset, Map<String, dynamic> data) =>
      firestore
          .document('reviews/$review/patchsets/$patchset')
          .setData(DocumentData.fromMap(data));

  /// Returns true if a review record in the database has a landed_index field,
  /// or if there is no record for the review in the database.  Reviews with no
  /// test failures have no record, and don't need to be linked when landing.
  Future<bool> reviewIsLanded(int review) =>
      firestore.document('reviews/$review').get().then((document) =>
          !document.exists || document.data.getInt('landed_index') != null);

  Future<void> linkReviewToCommit(int review, int index) => firestore
      .document('reviews/$review')
      .updateData(UpdateData.fromMap({'landed_index': index}));

  Future<void> linkCommentsToCommit(int review, int index) async {
    QuerySnapshot comments = await firestore
        .collection('comments')
        .where('review', isEqualTo: review)
        .get();
    if (comments.isEmpty) return;
    final batch = firestore.batch();
    for (final comment in comments.documents) {
      batch.updateData(
          comment.reference,
          UpdateData.fromMap(
              {'blamelist_start_index': index, 'blamelist_end_index': index}));
    }
    await batch.commit();
  }

  Future<List<Map<String, dynamic>>> tryApprovals(int review) async {
    QuerySnapshot approvals = await firestore
        .collection('try_results')
        .where('approved', isEqualTo: true)
        .where('review', isEqualTo: review)
        .get();
    return [for (final document in approvals.documents) document.data.toMap()];
  }

  Future<void> storeChunkStatus(String builder, int index, bool success) async {
    final document = firestore.document('builds/$builder:$index');

    Future<void> updateStatus(Transaction transaction) async {
      final snapshot = await transaction.get(document);
      final data = snapshot.data.toMap();
      final int chunks = data['num_chunks'];
      final int processedChunks = data['processed_chunks'] ?? 0;
      final bool completed = chunks == processedChunks + 1;

      final update = UpdateData.fromMap({
        'processed_chunks': processedChunks + 1,
        'success': (data['success'] ?? true) && success,
        if (completed) 'completed': true
      });
      transaction.update(document, update);
    }

    return firestore.runTransaction(updateStatus);
  }

  Future<void> storeBuildChunkCount(
      String builder, int index, int numChunks) async {
    return firestore
        .document('builds/$builder:$index')
        .updateData(UpdateData.fromMap({'num_chunks': numChunks}));
  }

  Future<void> storeTryChunkStatus(
      String builder, int review, int patchset, bool success) async {
    final reference =
        firestore.document('try_builds/$builder:$review:$patchset');
    final snapshot = await reference.get();

    if (!snapshot.exists || snapshot.data.getBool('completed') != null) {
      await _createTryBuildRecord(builder, review, patchset);
    }
    Future<void> updateStatus(Transaction transaction) async {
      final snapshot = await transaction.get(reference);
      final data = snapshot.data.toMap();
      final int chunks = data['num_chunks'];
      final int processedChunks = data['processed_chunks'] ?? 0;
      final bool completed = chunks == processedChunks + 1;

      final update = UpdateData.fromMap({
        'processed_chunks': processedChunks + 1,
        'success': (data['success'] ?? true) && success,
        if (completed) 'completed': true
      });
      transaction.update(reference, update);
    }

    return firestore.runTransaction(updateStatus);
  }

  Future<void> storeTryBuildChunkCount(
      String builder, int review, int patchset, int numChunks) async {
    final reference =
        firestore.document('try_builds/$builder:$review:$patchset');
    final snapshot = await reference.get();
    if (!snapshot.exists || snapshot.data.getInt('num_chunks') != null) {
      await _createTryBuildRecord(builder, review, patchset);
    }
    await reference.updateData(UpdateData.fromMap({'num_chunks': numChunks}));
  }

  Future<void> _createTryBuildRecord(
          String builder, int review, int patchset) =>
      firestore
          .document('try_builds/$builder:$review:$patchset')
          .setData(DocumentData.fromMap({
            'builder': builder,
            'review': review,
            'patchset': patchset,
          }));
}