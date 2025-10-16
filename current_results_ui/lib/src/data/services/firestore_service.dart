// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  FirebaseFirestore get firestore => FirebaseFirestore.instance;

  Future<DocumentSnapshot> fetchReviewInfo(int review) async {
    return firestore.doc('reviews/$review').get();
  }

  Future<List<DocumentSnapshot>> fetchPatchsetInfo(int review) async {
    final snapshot = await firestore
        .collection('reviews/$review/patchsets')
        .orderBy('number')
        .get();
    return snapshot.docs;
  }

  Future<List<DocumentSnapshot>> fetchTryChanges(
    int review,
    int patchset,
  ) async {
    final snapshot = await firestore
        .collection('try_results')
        .where('review', isEqualTo: review)
        .where('patchset', isEqualTo: patchset)
        .orderBy('name')
        .get();
    return snapshot.docs;
  }

  Future<List<DocumentSnapshot>> fetchTryBuilds(int review) async {
    final snapshot = await firestore
        .collection('try_builds')
        .where('review', isEqualTo: review)
        .get();
    return snapshot.docs;
  }

  Future<List<DocumentSnapshot>> fetchCommentsForReview(int review) async {
    final snapshot = await firestore
        .collection('comments')
        .where('review', isEqualTo: review)
        .get();
    return snapshot.docs;
  }

  Future<List<DocumentSnapshot>> fetchBuilders() async {
    final snapshot = await firestore.collection('configurations').get();
    return snapshot.docs;
  }
}
