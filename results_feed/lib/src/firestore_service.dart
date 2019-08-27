// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase/firebase.dart' as firebase;
import 'package:firebase/firestore.dart' as firestore;

class FirestoreService {
  firebase.App app;

  bool get isLoggedIn => app?.auth()?.currentUser != null;

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

  void getFirebaseClient() async {
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
    return;
  }
}
