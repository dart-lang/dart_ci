// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:math' show max, min;
import 'package:firebase_functions_interop/firebase_functions_interop.dart';

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

  Future<Map<String, dynamic>> getLastCommit(String hash) async {
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

  Future<void> storeChange(
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

    // Find an existing change group with a blamelist that intersects this change.

    bool blamelistIncludesChange(DocumentSnapshot groupDocument) {
      var group = groupDocument.data;
      var groupStart = group.getInt('blamelist_start_index');
      var groupEnd = group.getInt('blamelist_end_index');
      return startIndex <= groupEnd && endIndex >= groupStart;
    }

    DocumentSnapshot group = snapshot.documents
        .firstWhere(blamelistIncludesChange, orElse: () => null);

    if (group == null) {
      return firestore.collection('results').add(DocumentData.fromMap({
            'name': name,
            'result': result,
            'previous_result': previousResult,
            'expected': change['expected'],
            'blamelist_start_index': startIndex,
            'blamelist_end_index': endIndex,
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
      final update = UpdateData.fromMap({
        'blamelist_start_index': newStart,
        'blamelist_end_index': newEnd,
      });
      update.setFieldValue('configurations',
          Firestore.fieldValues.arrayUnion([change['configuration']]));
      group.reference.updateData(update);
    }

    return firestore.runTransaction(updateGroup);
  }

  Future<void> storeTryChange(
      Map<String, dynamic> change, int review, int patchset) async {
    String name = change['name'];
    String result = change['result'];
    String expected = change['expected'];
    String reviewPath = change['commit_hash'];
    String previousResult = change['previous_result'] ?? 'new test';
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
      return firestore.collection('try_results').add(DocumentData.fromMap({
            'name': name,
            'result': result,
            'previous_result': previousResult,
            'expected': expected,
            'review': review,
            'patchset': patchset,
            'configurations': <String>[change['configuration']]
          }));
    } else {
      final update = UpdateData()
        ..setFieldValue('configurations',
            Firestore.fieldValues.arrayUnion([change['configuration']]));
      snapshot.documents.first.reference.updateData(update);
    }
  }

  Future<void> storeReview(String review, Map<String, dynamic> data) =>
      firestore.document('reviews/$review').setData(DocumentData.fromMap(data));

  Future<void> storePatchset(
          String review, String patchset, Map<String, dynamic> data) =>
      firestore
          .document('reviews/$review/patchsets/$patchset')
          .setData(DocumentData.fromMap(data));
}
