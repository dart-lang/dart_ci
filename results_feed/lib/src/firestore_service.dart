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
        firebase.UserCredential user =
            await app.auth().signInWithPopup(provider);
        // Our application settings already disallow non-org users,
        // so we don't even get to this additional check.
        if (!user.user.email.endsWith('@google.com')) logOut();
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
    firestore.Query query = commits.orderBy('index', 'desc');
    if (beforeIndex != null) {
      query = query.where('index', '<', beforeIndex);
    }
    query = query.limit(limit);
    return (await query.get()).docs;
  }

  Future<List<firestore.DocumentSnapshot>> fetchChanges(
      int startIndex, int endIndex) async {
    final results = app.firestore().collection('results');
    final firestore.QuerySnapshot snapshot = await results
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
      int cl, int patch) async {
    final results = app.firestore().collection('try_results');
    final firestore.QuerySnapshot snapshot = await results
        .where('review_path', '==', 'refs/changes/$cl/$patch')
        .get();
    return snapshot.docs;
  }

  Future<firestore.DocumentSnapshot> fetchComment(String id) =>
      app.firestore().collection('comments').doc(id).get();

  Future<List<firestore.DocumentSnapshot>> fetchCommentThread(
      String baseId) async {
    final results = app.firestore().collection('comments');
    final firestore.DocumentSnapshot doc = await results.doc(baseId).get();
    final firestore.QuerySnapshot snapshot =
        await results.where('base_comment', '==', baseId).get();
    return [doc, ...snapshot.docs];
  }

  Future<List<firestore.DocumentSnapshot>> fetchCommentsForRange(
      int start, int end) async {
    final results = app.firestore().collection('comments');
    final firestore.QuerySnapshot snapshot = await results
        .where('index', '>=', start)
        .where('index', '<=', end)
        .get();
    return snapshot.docs;
  }

  Future<firestore.DocumentSnapshot> fetchBuild(
      String builder, int index) async {
    final builds = app.firestore().collection('builds');
    final firestore.QuerySnapshot snapshot = await builds
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
    final batch = app.firestore().batch();
    final results = app.firestore().collection('results');
    for (final id in resultIds) {
      batch.update(results.doc(id), fieldsAndValues: ['pinned_index', pin]);
    }
    return batch.commit();
  }

  Future<void> getFirebaseClient() async {
    if (app != null) return;
    // Firebase api key is public, and must be sent to client for use.
    // It is invalid over any connection except https to the app URL.
    // It is not used for security, only usage accounting.
    app = firebase.initializeApp(
        apiKey: "AIzaSyBFKKpPdV3xPQU4jPYiMvUnUfhB5pDDMRI",
        authDomain: "dart-ci.firebaseapp.com",
        databaseURL: "https://dart-ci.firebaseio.com",
        projectId: "dart-ci",
        storageBucket: "dart-ci.appspot.com",
        messagingSenderId: "410721018617");
    await app.auth().setPersistence(firebase.Persistence.LOCAL);
  }
}

class StagingFirestoreService extends FirestoreService {
  // StagingFirestoreService uses the Firestore database at
  // dart-ci-staging.
  // It adds additional methods used by integration tests.
  Future<void> getFirebaseClient() async {
    if (app != null) return;
    // Firebase api key is public, and must be sent to client for use.
    // It is invalid over any connection except https to the app URL.
    // It is not used for security, only usage accounting.
    app = firebase.initializeApp(
        apiKey: "AIzaSyBky7KGq1dbVn_J48iAI6oVyKRcMrRanns",
        authDomain: "dart-ci-staging.firebaseapp.com",
        databaseURL: "https://dart-ci-staging.firebaseio.com",
        messagingSenderId: "287461583823",
        projectId: "dart-ci-staging",
        storageBucket: "dart-ci-staging.appspot.com");
    await app.auth().setPersistence(firebase.Persistence.LOCAL);
  }

  Future<void> writeDocumentsFrom(Map<String, dynamic> documents,
      {bool delete: false}) async {
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

  Future<void> mergeDocumentsFrom(Map<String, dynamic> documents,
      {bool delete: false}) async {
    for (final keys in iterables.partition(documents.keys, 500)) {
      final batch = app.firestore().batch();
      for (final key in keys) {
        Map<String, dynamic> update = documents[key];
        if (delete) {
          update = Map.fromIterable(update.keys,
              value: (_) => firestore.FieldValue.delete());
        }
        batch.update(app.firestore().doc(key), data: update);
      }
      await batch.commit();
    }
  }

  Future logIn() async {
    //  final provider = firebase.GoogleAuthProvider();
    //  provider.addScope('openid https://www.googleapis.com/auth/datastore');
    try {
      firebase.UserCredential user = await app
          .auth()
          .signInWithEmailAndPassword('whesse+dummy@google.com',
              r''); // Password must be entered locally before testing.
      // Because this is running in a browser, cannot read password from
      // a file or environment variable. Investigate what testing framework
      // supports for local secrets.

      // Our application settings already disallow non-org users,
      // so we don't even get to this additional check.
      if (!user.user.email.endsWith('@google.com')) logOut();
      print(user.user.email);
    } catch (e) {
      print(e.toString());
    }
    return;
  }
}
