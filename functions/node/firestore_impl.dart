// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:math' show max, min;
import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:node_interop/node.dart';
import 'package:retry/retry.dart';

import 'firestore.dart';

// Cloud functions run the cloud function many times in the same isolate.
// Use static initializer to run global initialization once.
Firestore firestore = createFirestore();

Firestore createFirestore() {
  final app = FirebaseAdmin.instance.initializeApp();
  return app.firestore()
    ..settings(FirestoreSettings(timestampsInSnapshots: true));
}

class ActiveRequest {
  final String type;
  final String info;
  final DateTime start;

  ActiveRequest(this.type, this.info) : start = DateTime.now();

  String toString() => 'Request $type of $info started at $start';
}

class FirestoreServiceError {
  final ActiveRequest request;
  final DateTime errorTime;
  final Set<ActiveRequest> activeRequests;
  final firestoreError;

  FirestoreServiceError(this.request, this.firestoreError, this.activeRequests)
      : errorTime = DateTime.now();

  String toString() => '''
Error in ${request.type} of ${request.info}:
$firestoreError
Request failed at $errorTime, after running for ${errorTime.difference(request.start)}

Concurrent Firestore requests pending:
${activeRequests.join('\n')}''';
}

class FirestoreServiceImpl implements FirestoreService {
  int documentsFetched = 0;
  int documentsWritten = 0;
  Set<ActiveRequest> activeRequests = {};

  Future<T> traceRequest<T>(
      String type, String info, Future<T> firestoreCall()) async {
    final request = ActiveRequest(type, info);
    activeRequests.add(request);
    T result;
    try {
      result = await firestoreCall();
      if (result is QuerySnapshot && result.isNotEmpty) {
        documentsFetched += result.documents.length;
      } else if (result is DocumentSnapshot && result.exists) {
        documentsFetched++;
      }
    } catch (e) {
      throw FirestoreServiceError(request, e, activeRequests);
    }
    activeRequests.remove(request);
    return result;
  }

  Future<DocumentSnapshot> getDocument(DocumentReference reference) =>
      traceRequest('get document', reference.path, reference.get);

  Future<QuerySnapshot> runQuery(DocumentQuery query, String debugInfo) =>
      traceRequest('run query', debugInfo, query.get);

  Future<void> setDocument(
          DocumentReference reference, Map<String, dynamic> data) =>
      traceRequest('set document', reference.path, () {
        documentsWritten++;
        return reference.setData(
            DocumentData.fromMap(data), SetOptions(merge: true));
      });

  Future<void> updateDocument(
          DocumentReference reference, Map<String, dynamic> data) =>
      traceRequest('update document', reference.path, () {
        documentsWritten++;
        return reference.updateData(UpdateData.fromMap(data));
      });

  // Because we can't read the number of documents written from a
  // WriteBatch object, increment documentsWritten where we add writes
  // to the write batch at use sites.
  Future<void> commitBatch(WriteBatch batch, String info) =>
      traceRequest('commit batch', info, batch.commit);

  // The update function may be run multiple times, if the transaction retries.
  // Increment documentsWritten and documentsRead in the update function body.
  // The counts will include reads and attempted writes during retries.
  Future<T> runTransaction<T>(String info, Future<T> update(Transaction t)) =>
      traceRequest<T>(
          'run transaction', info, () => firestore.runTransaction(update));

  Future<void> add(CollectionReference reference, Map<String, dynamic> data) =>
      traceRequest('add document', reference.path, () {
        documentsWritten++;
        return reference.add(DocumentData.fromMap(data));
      });

  Future<bool> isStaging() =>
      runQuery(firestore.collection('staging'), 'staging')
          .then((s) => s.isNotEmpty);

  Future<bool> hasPatchset(String review, String patchset) =>
      getDocument(firestore.document('reviews/$review/patchsets/$patchset'))
          .then((s) => s.exists);

  Map<String, dynamic> _commit(DocumentSnapshot document) {
    if (document.exists) {
      return document.data.toMap()..['hash'] = document.documentID;
    }
    return null;
  }

  Future<Map<String, dynamic>> getCommit(String hash) =>
      getDocument(firestore.document('commits/$hash'))
          .then((document) => _commit(document));

  Future<Map<String, dynamic>> getCommitByIndex(int index) => runQuery(
          firestore.collection('commits').where('index', isEqualTo: index),
          'commits where index == $index')
      .then((s) => _commit(s.documents.first));

  Future<Map<String, dynamic>> getLastCommit() async {
    QuerySnapshot lastCommit = await runQuery(
        firestore
            .collection('commits')
            .orderBy('index', descending: true)
            .limit(1),
        'commits by descending index, limit 1');
    return _commit(lastCommit.documents.first);
  }

  Future<void> addCommit(String id, Map<String, dynamic> data) async {
    data['created'] = Timestamp.fromDateTime(data['created']);
    await setDocument(firestore.document('commits/$id'), data);
  }

  Future<void> updateConfiguration(String configuration, String builder) async {
    final record =
        await getDocument(firestore.document('configurations/$configuration'));
    if (!record.exists || record.data.getString('builder') != builder) {
      await setDocument(firestore.document('configurations/$configuration'),
          {'builder': builder});
      if (!record.exists) {
        console
            .log('Configuration document $configuration -> $builder created');
      } else {
        console
            .log('Configuration document changed: $configuration -> $builder '
                '(was ${record.data.getString("builder")}');
      }
    }
  }

  Future<void> updateBuildInfo(
      String builder, int buildNumber, int index) async {
    final documentRef = firestore.document('builds/$builder:$index');
    final record = await getDocument(documentRef);
    if (!record.exists) {
      await setDocument(documentRef,
          {'builder': builder, 'build_number': buildNumber, 'index': index});
      console.log('Created build record: '
          'builder: $builder, build_number: $buildNumber, index: $index');
    } else if (record.data.getInt('index') != index) {
      throw ('Build $buildNumber of $builder had commit index ${record.data.getInt('index')},'
          'should be $index.');
    }
  }

  Future<String> findResult(
      Map<String, dynamic> change, int startIndex, int endIndex) async {
    String name = change['name'];
    String result = change['result'];
    String previousResult = change['previous_result'] ?? 'new test';
    QuerySnapshot snapshot = await runQuery(
        firestore
            .collection('results')
            .orderBy('blamelist_end_index', descending: true)
            .where('name', isEqualTo: name)
            .where('result', isEqualTo: result)
            .where('previous_result', isEqualTo: previousResult)
            .where('expected', isEqualTo: change['expected'])
            .limit(5) // We will pick the right one, probably the latest.
        ,
        'results by descending blamelist_end_index where name == $name,'
        'result == $result, previous_result == $previousResult, '
        'expected == ${change['expected']}, limit 5');

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

  Future<void> storeResult(Map<String, dynamic> result) =>
      firestore.collection('results').add(DocumentData.fromMap(result));

  Future<bool> updateResult(
      String result, String configuration, int startIndex, int endIndex,
      {bool failure}) {
    DocumentReference reference = firestore.document('results/$result');

    // Update the result in a transaction.
    Future<bool> updateResultTransaction(Transaction transaction) =>
        transaction.get(reference).then((resultSnapshot) {
          documentsFetched++;
          final data = resultSnapshot.data;
          // Allow missing 'approved' field during transition period.
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
          if (failure) {
            update.setBool('active', true);
            update.setFieldValue('active_configurations',
                Firestore.fieldValues.arrayUnion([configuration]));
          }
          transaction.update(reference, update);
          documentsWritten++;
          return approved;
        });

    return runTransaction(
        'update result ${reference.path}', updateResultTransaction);
  }

  Future<List<Map<String, dynamic>>> findRevertedChanges(int index) async {
    QuerySnapshot pinned = await runQuery(
        firestore.collection('results').where('pinned_index', isEqualTo: index),
        "results where pinned_index == $index");
    QuerySnapshot unpinned = await runQuery(
        firestore
            .collection('results')
            .where('blamelist_end_index', isEqualTo: index),
        'results where blamelist_end_index == $index');
    return [
      for (final document in pinned.documents) document.data.toMap(),
      for (final document in unpinned.documents)
        if (document.data.getInt('blamelist_start_index') == index &&
            document.data.getInt('pinned_index') == null)
          document.data.toMap(),
    ];
  }

  Future<bool> storeTryChange(
      Map<String, dynamic> change, int review, int patchset) async {
    String name = change['name'];
    String result = change['result'];
    String expected = change['expected'];
    String previousResult = change['previous_result'] ?? 'new test';
    // Find an existing TryResult for this test on this patchset.
    QuerySnapshot snapshot = await runQuery(
        firestore
            .collection('try_results')
            .where('review', isEqualTo: review)
            .where('patchset', isEqualTo: patchset)
            .where('name', isEqualTo: name)
            .where('result', isEqualTo: result)
            .where('previous_result', isEqualTo: previousResult)
            .where('expected', isEqualTo: expected)
            .limit(1),
        'try_results where review == $review, patchset == $patchset, '
        'name == $name, result == $result, '
        'previous_result == ${previousResult}, expected == $expected, '
        'limit 1');
    if (snapshot.isEmpty) {
      // Is the previous result for this test on this review approved?
      QuerySnapshot previous = await runQuery(
          firestore
              .collection('try_results')
              .where('review', isEqualTo: review)
              .where('name', isEqualTo: name)
              .where('result', isEqualTo: result)
              .where('previous_result', isEqualTo: previousResult)
              .where('expected', isEqualTo: expected)
              .orderBy('patchset', descending: true)
              .limit(1),
          'try_results where review == $review, '
          'name == $name, result == $result, '
          'previous_result == ${previousResult}, expected == $expected, '
          'order by descending patchset, limit 1');
      // Create a TryResult for this test on this patchset.
      // Allow a missing 'approved' field during a transition period
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
            'approved': approved
          }));
      return approved;
    } else {
      // Update the TryResult for this test, adding this configuration.
      await updateDocument(snapshot.documents.first.reference, {
        'configurations':
            Firestore.fieldValues.arrayUnion([change['configuration']])
      });
      // Return true if this result is approved
      return snapshot.documents.first.data.getBool('approved') == true;
    }
  }

  Future<void> updateActiveResult(
      Map<String, dynamic> activeResult, String configuration) async {
    final document = firestore.document('results/${activeResult['id']}');
    if (activeResult['active_configurations'].length > 1) {
      await updateDocument(document, {
        'active_configurations':
            Firestore.fieldValues.arrayRemove([configuration])
      });
      activeResult = (await getDocument(document)).data.toMap();
      if (!activeResult.containsKey('active_configurations') ||
          activeResult['active_configurations'].isNotEmpty) return;
    }
    return updateDocument(document, {
      'active_configurations': Firestore.fieldValues.delete(),
      'active': Firestore.fieldValues.delete()
    });
  }

  Future<List<Map<String, dynamic>>> findActiveResults(
      Map<String, dynamic> change) async {
    QuerySnapshot snapshot = await runQuery(
        firestore
            .collection('results')
            .where('active_configurations',
                arrayContains: change['configuration'])
            .where('active', isEqualTo: true)
            .where('name', isEqualTo: change['name']),
        'results where active_configurations contains '
        '${change['configuration']}, active == true, '
        'name == ${change['name']}');
    final results = [
      for (final document in snapshot.documents)
        document.data.toMap()..['id'] = document.documentID
    ];
    if (results.length > 1) {
      console.error([
        'Multiple active results for the same configuration and test',
        ...results
      ].join('\n'));
    }
    return results;
  }

  Future<void> storeReview(String review, Map<String, dynamic> data) =>
      setDocument(firestore.document('reviews/$review'), data);

  Future<void> storePatchset(
          String review, int patchset, Map<String, dynamic> data) =>
      setDocument(
          firestore.document('reviews/$review/patchsets/$patchset'), data);

  /// Returns true if a review record in the database has a landed_index field,
  /// or if there is no record for the review in the database.  Reviews with no
  /// test failures have no record, and don't need to be linked when landing.
  Future<bool> reviewIsLanded(int review) =>
      getDocument(firestore.document('reviews/$review')).then((document) =>
          !document.exists || document.data.getInt('landed_index') != null);

  Future<void> linkReviewToCommit(int review, int index) => updateDocument(
      firestore.document('reviews/$review'), {'landed_index': index});

  Future<void> linkCommentsToCommit(int review, int index) async {
    QuerySnapshot comments = await firestore
        .collection('comments')
        .where('review', isEqualTo: review)
        .get();
    if (comments.isEmpty) return;
    final batch = firestore.batch();
    for (final comment in comments.documents) {
      documentsWritten++;
      batch.updateData(
          comment.reference,
          UpdateData.fromMap(
              {'blamelist_start_index': index, 'blamelist_end_index': index}));
    }
    await commitBatch(batch, 'linkCommentsToCommit');
  }

  Future<List<Map<String, dynamic>>> tryApprovals(int review) async {
    final patchsets = await runQuery(
        firestore
            .collection('reviews/$review/patchsets')
            .orderBy('number', descending: true)
            .limit(1),
        'reviews/$review/patchsets by descending number limit 1');
    if (patchsets.isEmpty) return [];
    final lastPatchsetGroup =
        patchsets.documents.first.data.getInt('patchset_group');
    QuerySnapshot approvals = await runQuery(
        firestore
            .collection('try_results')
            .where('approved', isEqualTo: true)
            .where('review', isEqualTo: review)
            .where('patchset', isGreaterThanOrEqualTo: lastPatchsetGroup),
        'try_results where approved == true, review == $review, '
        'patchset >= $lastPatchsetGroup');
    return [for (final document in approvals.documents) document.data.toMap()];
  }

  Future<List<Map<String, dynamic>>> tryResults(
      int review, String configuration) async {
    final patchsets = await runQuery(
        firestore
            .collection('reviews/$review/patchsets')
            .orderBy('number', descending: true)
            .limit(1),
        'reviews/$review/patchsets by descending number limit 1');
    if (patchsets.isEmpty) return [];
    final lastPatchsetGroup =
        patchsets.documents.first.data.getInt('patchset_group');
    QuerySnapshot approvals = await runQuery(
        firestore
            .collection('try_results')
            .where('review', isEqualTo: review)
            .where('configurations', arrayContains: configuration)
            .where('patchset', isGreaterThanOrEqualTo: lastPatchsetGroup),
        'try_results where review == $review, '
        'configurations contains $configuration, '
        'patchset >= $lastPatchsetGroup');
    return [for (final document in approvals.documents) document.data.toMap()];
  }

  Future<void> storeChunkStatus(String builder, int index, bool success) async {
    final document = firestore.document('builds/$builder:$index');
    // Compute activeFailures outside transaction, because it runs queries.
    // Because "completed" might be true inside transaction, but not now,
    // we must compute activeFailures always, not just on last chunk.
    Future<void> updateStatus(Transaction transaction) async {
      final snapshot = await transaction.get(document);
      documentsFetched++;
      final data = snapshot.data.toMap();
      final int chunks = data['num_chunks'];
      final int processedChunks = data['processed_chunks'] ?? 0;
      final bool completed = chunks == processedChunks + 1;
      final update = UpdateData.fromMap({
        'processed_chunks': processedChunks + 1,
        'success': (data['success'] ?? true) && success,
        if (completed) 'completed': true,
      });
      transaction.update(document, update);
      documentsWritten++;
    }

    await retry(
        () => runTransaction(
            'update build status ${document.path}', updateStatus),
        retryIf: (e) {
      console.error("Retrying storeChunkStatus failed transaction: $e");
      return e.toString().contains('Please try again.');
    });
  }

  Future<void> storeBuildChunkCount(
      String builder, int index, int numChunks) async {
    return updateDocument(firestore.document('builds/$builder:$index'),
        {'num_chunks': numChunks});
  }

  Future<void> storeTryChunkStatus(String builder, int buildNumber,
      String buildbucketID, int review, int patchset, bool success) async {
    await _ensureTryBuildRecord(
        builder, buildNumber, buildbucketID, review, patchset);
    final reference =
        firestore.document('try_builds/$builder:$review:$patchset');

    Future<void> updateStatus(Transaction transaction) async {
      final snapshot = await transaction.get(reference);
      documentsFetched++;
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
      documentsWritten++;
    }

    await retry(
        () => runTransaction(
            'update try build status ${reference.path}', updateStatus),
        retryIf: (e) {
      console.error("Retrying storeTryChunkStatus failed transaction: $e");
      return e.toString().contains('Please try again.');
    });
  }

  Future<void> storeTryBuildChunkCount(String builder, int buildNumber,
      String buildbucketID, int review, int patchset, int numChunks) async {
    await _ensureTryBuildRecord(
        builder, buildNumber, buildbucketID, review, patchset);

    await updateDocument(
        firestore.document('try_builds/$builder:$review:$patchset'),
        {'num_chunks': numChunks});
  }

  Future<void> _ensureTryBuildRecord(String builder, int buildNumber,
      String buildbucketID, int review, int patchset) async {
    final reference =
        firestore.document('try_builds/$builder:$review:$patchset');
    var snapshot = await getDocument(reference);
    if (snapshot.exists && snapshot.data.getInt('build_number') > buildNumber) {
      throw ArgumentError("Received chunk from previous build $buildNumber"
          " after chunk from a later build");
    }
    if (snapshot.exists && snapshot.data.getInt('build_number') < buildNumber) {
      Future<void> deleteEarlierBuild(Transaction transaction) async {
        final snapshot = await transaction.get(reference);
        documentsFetched++;
        if (snapshot.exists &&
            snapshot.data.getInt('build_number') < buildNumber) {
          transaction.delete(reference);
          documentsWritten++;
        }
      }

      try {
        await runTransaction(
            'delete earlier build on patchset: ${reference.path}',
            deleteEarlierBuild);
      } finally {
        snapshot = await getDocument(reference);
      }
    }

    if (!snapshot.exists) {
      await setDocument(reference, {
        'builder': builder,
        'build_number': buildNumber,
        if (buildbucketID != null) 'buildbucket_id': buildbucketID,
        'review': review,
        'patchset': patchset,
      });
    }
  }
}
