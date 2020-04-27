// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase/firebase.dart' as firebase;
import 'package:firebase/firestore.dart' as firestore;
import 'package:quiver/iterables.dart' as iterables;

class FirestoreService {
  static const bool loginEnabled = true;

  firebase.App app;
  bool get isLoggedIn => app?.auth()?.currentUser != null;

  Future logIn() async {
    if (isLoggedIn) return;
    if (loginEnabled) {
      final provider = firebase.GoogleAuthProvider();
      provider.addScope('openid https://www.googleapis.com/auth/datastore');
      try {
        final user = await app.auth().signInWithPopup(provider);
        // Our application settings already disallow non-org users,
        // so we don't even get to this additional check.
        if (!user.user.email.endsWith('@google.com')) await logOut();
      } catch (e) {
        print(e.toString());
      }
    }
    return;
  }

  Future logOut() => app.auth().signOut();

  Future<List<firestore.DocumentSnapshot>> fetchCommits(
      int beforeIndex, int limit) async {
    final commits = app.firestore().collection('commits');
    var query = commits.orderBy('index', 'desc');
    if (beforeIndex != null) {
      query = query.where('index', '<', beforeIndex);
    }
    query = query.limit(limit);
    return (await query.get()).docs;
  }

  Future<List<firestore.DocumentSnapshot>> fetchChanges(
      int startIndex,
      int endIndex,
      bool failuresOnly,
      bool unapprovedOnly,
      String singleTest) async {
    firestore.Query query = app.firestore().collection('results');
    if (singleTest != null) {
      query = query.where('name', '==', singleTest);
    } else if (failuresOnly) {
      // Because the index contains 'active' and 'approved', we
      // always need to give values for both of them (or neither).
      query = query
          .where('active', '==', true)
          .where('approved', 'in', [false, if (!unapprovedOnly) true]);
    }
    final snapshot = await query
        .where('blamelist_end_index', '>=', startIndex)
        .where('blamelist_end_index', '<=', endIndex)
        .get();
    return snapshot.docs;
  }

  Future<firestore.DocumentSnapshot> fetchReviewInfo(int review) async {
    await getFirebaseClient();

    return app.firestore().doc('reviews/$review').get();
  }

  Future<List<firestore.DocumentSnapshot>> fetchPatchsetInfo(int review) async {
    await getFirebaseClient();
    final collection =
        await app.firestore().collection('reviews/$review/patchsets');
    return (await collection.orderBy('number').get()).docs;
  }

  Future<List<firestore.DocumentSnapshot>> fetchTryChanges(
      int review, int patchset) async {
    final results = app.firestore().collection('try_results');
    final snapshot = await results
        .where('review', '==', review)
        .where('patchset', '==', patchset)
        .get();
    return snapshot.docs;
  }

  Future<List<firestore.DocumentSnapshot>> fetchTryBuilds(int review) async {
    final results = app.firestore().collection('try_builds');
    final snapshot = await results.where('review', '==', review).get();
    return snapshot.docs;
  }

  Future<firestore.DocumentSnapshot> fetchComment(String id) =>
      app.firestore().collection('comments').doc(id).get();

  Future<List<firestore.DocumentSnapshot>> fetchCommentThread(
      String baseId) async {
    final results = app.firestore().collection('comments');
    final doc = await results.doc(baseId).get();
    final snapshot = await results.where('base_comment', '==', baseId).get();
    return [doc, ...snapshot.docs];
  }

  Future<List<firestore.DocumentSnapshot>> fetchCommentsForRange(
      int start, int end) async {
    final results = app.firestore().collection('comments');
    final snapshot = await results
        .where('blamelist_end_index', '>=', start)
        .where('blamelist_end_index', '<=', end)
        .get();
    return snapshot.docs;
  }

  Future<List<firestore.DocumentSnapshot>> fetchCommentsForReview(
      int review) async {
    final results = app.firestore().collection('comments');
    final snapshot = await results.where('review', '==', review).get();
    return snapshot.docs;
  }

  Future<firestore.DocumentSnapshot> fetchBuild(
      String builder, int index) async {
    final builds = app.firestore().collection('builds');
    final snapshot = await builds
        .where('index', '>=', index)
        .where('builder', '==', builder)
        .orderBy('index', 'asc')
        .limit(1)
        .get();
    return snapshot.docs.first;
  }

  Future<List<firestore.DocumentSnapshot>> fetchBuilders() async {
    final snapshot = await app.firestore().collection('configurations').get();
    return snapshot.docs;
  }

  Future pinResults(int pin, List<String> resultIds) async {
    final collection = app.firestore().collection('results');
    // If resultIds.length > 500, break into multiple batches.
    for (final results in iterables.partition(resultIds, 500)) {
      final batch = app.firestore().batch();
      for (final id in results) {
        batch
            .update(collection.doc(id), fieldsAndValues: ['pinned_index', pin]);
      }
      await batch.commit();
    }
  }

  Future<firestore.DocumentSnapshot> saveComment(
      bool approve, String comment, String baseComment,
      {List<String> resultIds,
      List<String> tryResultIds,
      int blamelistStart,
      int blamelistEnd,
      int review}) async {
    final reference = await app.firestore().collection('comments').add({
      'author': app.auth().currentUser.email,
      if (comment != null) 'comment': comment,
      'created': DateTime.now(),
      if (approve != null) 'approved': approve,
      if (resultIds != null) 'results': resultIds,
      if (tryResultIds != null) 'try_results': tryResultIds,
      if (blamelistStart != null) 'blamelist_start_index': blamelistStart,
      if (blamelistStart != null) 'blamelist_end_index': blamelistEnd,
      if (review != null) 'review': review
    });
    return reference.get();
  }

  Future<void> saveApprovals(
      {bool approve, List<String> resultIds, List<String> tryResultIds}) async {
    if (approve == null) return;
    // Update approved field in results documents.
    Future<void> approveResults(List<String> ids, String collectionName) async {
      if (ids == null) return;
      // If resultIds.length > 500, break into multiple batches.
      for (final results in iterables.partition(ids, 500)) {
        final batch = app.firestore().batch();
        final collection = app.firestore().collection(collectionName);
        for (final id in results) {
          batch.update(collection.doc(id),
              fieldsAndValues: ['approved', approve]);
        }
        await batch.commit();
      }
    }

    await approveResults(resultIds, 'results');
    await approveResults(tryResultIds, 'try_results');
  }

  Future<void> getFirebaseClient() async {
    if (app != null) return;
    // Firebase api key is public, and must be sent to client for use.
    // It is invalid over any connection except https to the app URL.
    // It is not used for security, only usage accounting.
    app = firebase.initializeApp(
        apiKey: 'AIzaSyBFKKpPdV3xPQU4jPYiMvUnUfhB5pDDMRI',
        authDomain: 'dart-ci.firebaseapp.com',
        databaseURL: 'https://dart-ci.firebaseio.com',
        projectId: 'dart-ci',
        storageBucket: 'dart-ci.appspot.com',
        messagingSenderId: '410721018617');
    await app.auth().setPersistence(firebase.Persistence.LOCAL);
  }
}

class StagingFirestoreService extends FirestoreService {
  @override
  Future<void> getFirebaseClient() async {
    if (app != null) return;
    // Firebase api key is public, and must be sent to client for use.
    // It is invalid over any connection except https to the app URL.
    // It is not used for security, only usage accounting.
    app = firebase.initializeApp(
        apiKey: 'AIzaSyBky7KGq1dbVn_J48iAI6oVyKRcMrRanns',
        authDomain: 'dart-ci-staging.firebaseapp.com',
        databaseURL: 'https://dart-ci-staging.firebaseio.com',
        messagingSenderId: '287461583823',
        projectId: 'dart-ci-staging',
        storageBucket: 'dart-ci-staging.appspot.com');
    await app.auth().setPersistence(firebase.Persistence.LOCAL);
  }
}

class TestingFirestoreService extends StagingFirestoreService {
  // TestingFirestoreService uses the Firestore database at
  // dart-ci-staging.
  // It adds additional methods used by integration tests.
  // It includes local password-based authentication for
  // tests that write to staging.
  @override
  Future<void> getFirebaseClient() async {
    await super.getFirebaseClient();
    await logIn();
  }

  @override
  Future logIn() async {
    try {
      await app.auth().signInWithEmailAndPassword(
          'dartresultsfeedtestaccount2@example.com', r'');
      // Password must be entered locally before testing.
      // Because this is running in a browser, cannot read password from
      // a file or environment variable. Investigate what testing framework
      // supports for local secrets.
    } catch (e) {
      print(e.toString());
    }
    return;
  }

  Future<void> writeDocumentsFrom(Map<String, dynamic> documents,
      {bool delete = false}) async {
    for (final keys in iterables.partition(documents.keys, 500)) {
      final batch = app.firestore().batch();
      for (final key in keys) {
        if (delete) {
          batch.delete(app.firestore().doc(key));
        } else {
          batch.set(app.firestore().doc(key), documents[key]);
        }
      }
      await batch.commit();
    }
  }

  Future<void> deleteCommentsForReview(int review) async {
    final snapshot = await app
        .firestore()
        .collection('comments')
        .where('review', '==', review)
        .get();
    for (final document in snapshot.docs) {
      await document.ref.delete();
    }
  }
}
