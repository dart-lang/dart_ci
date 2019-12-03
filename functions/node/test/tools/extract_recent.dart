// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:math' show min;

import 'package:firebase_functions_interop/firebase_functions_interop.dart';

// Extract sample data from production Firestore, to populate the
// staging/test Firestore with.  Takes the latest 100 commits and
// latest 100 reviews, and all records referring to them, and dumps them
// as a JSON object to stdout.

Firestore firestore = createFirestore();

// Creates a Firestore object referring to dart-ci's database.
Firestore createFirestore() {
  final app = FirebaseAdmin.instance.initializeApp(AppOptions(
      databaseURL: "https://dart-ci.firebaseio.com", projectId: 'dart-ci'));
  return app.firestore()
    ..settings(FirestoreSettings(timestampsInSnapshots: true));
}

void main() async {
  final object = await fetchRecentData(100, 100);
  print(new JsonEncoder.withIndent('  ', encodeTimestamp).convert(object));
}

dynamic encodeTimestamp(dynamic timestamp) {
  if (timestamp is Timestamp) {
    return timestamp.toDateTime().toIso8601String();
  }
}

Future<Map<String, dynamic>> fetchRecentData(
    int numCommits, int numReviews) async {
  final configurations = await fetchAllConfigurations();
  final commits = await fetchCommits(numCommits);
  final firstIndex =
      [for (var commit in commits.values) commit['index'] as int].reduce(min);
  final results = await fetchResults(firstIndex);
  final builds = await fetchBuilds(firstIndex);
  final reviews = await fetchReviews(numReviews);
  final patchsets = await fetchPatchsets(reviews);
  final try_results = await fetchTryResults(reviews);
  return {
    ...builds,
    ...commits,
    ...configurations,
    ...results,
    ...reviews,
    ...patchsets,
    ...try_results
  };
}

Map<String, dynamic> documentsToMap(List<DocumentSnapshot> documents) => {
      for (final document in documents)
        document.reference.path: document.data.toMap()
    };

Future<Map<String, dynamic>> fetchCommits(int numCommits) async {
  QuerySnapshot snapshot = await firestore
      .collection('commits')
      .orderBy('index', descending: true)
      .limit(numCommits)
      .get();
  return documentsToMap(snapshot.documents);
}

Future<Map<String, dynamic>> fetchAllConfigurations() async {
  QuerySnapshot snapshot = await firestore.collection('configurations').get();
  return documentsToMap(snapshot.documents);
}

Future<Map<String, dynamic>> fetchBuilds(int firstIndex) async {
  QuerySnapshot snapshot = await firestore
      .collection('builds')
      .where('index', isGreaterThanOrEqualTo: firstIndex)
      .get();
  return documentsToMap(snapshot.documents);
}

Future<Map<String, dynamic>> fetchResults(int firstIndex) async {
  QuerySnapshot snapshot = await firestore
      .collection('results')
      .where('blamelist_start_index', isGreaterThanOrEqualTo: firstIndex)
      .get();
  return documentsToMap(snapshot.documents);
}

Future<Map<String, dynamic>> fetchReviews(int numReviews) async {
  QuerySnapshot snapshot =
      await firestore.collection('reviews').limit(numReviews).get();
  return documentsToMap(snapshot.documents);
}

Future<Map<String, dynamic>> fetchPatchsets(
    Map<String, dynamic> reviews) async {
  final result = <String, dynamic>{};
  for (final review in reviews.keys) {
    QuerySnapshot snapshot =
        await firestore.collection('$review/patchsets').get();
    result.addAll(documentsToMap(snapshot.documents));
  }
  return result;
}

Future<Map<String, dynamic>> fetchTryResults(
    Map<String, dynamic> reviews) async {
  final result = <String, dynamic>{};
  for (final review in reviews.keys) {
    QuerySnapshot snapshot = await firestore
        .collection('try_results')
        .where('review', isEqualTo: int.parse(review.split('/').last))
        .get();
    result.addAll(documentsToMap(snapshot.documents));
  }
  return result;
}
