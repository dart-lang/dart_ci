// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../features/results_overview/data/results_repository.dart';
import '../../shared/generated/query.pb.dart';
import '../models/comment.dart';
import '../models/review.dart';
import '../models/try_build.dart';
import 'firestore_service.dart';

class ResultsService {
  final FirestoreService _firestoreService = FirestoreService();

  Future<Review> fetchReviewInfo(int review) async {
    final patchsetDocs = await _firestoreService.fetchPatchsetInfo(review);
    final patchsets = patchsetDocs
        .map((d) => Patchset.fromFirestore(d))
        .toList();
    final reviewDoc = await _firestoreService.fetchReviewInfo(review);
    if (reviewDoc.exists) {
      return Review.fromFirestore(reviewDoc, patchsets);
    }
    return Review(
      id: review.toString(),
      subject: 'No results received yet for CL $review',
      patchsets: [],
    );
  }

  Future<Map<String, TryBuild>> fetchBuilds(int review, int patchset) async {
    final buildDocs = await _firestoreService.fetchTryBuilds(review);
    final builds = buildDocs.map((d) => TryBuild.fromFirestore(d));
    return {for (var build in builds) build.builder: build};
  }

  Future<Iterable<(ChangeInResult, Result)>> fetchChanges(
    int review,
    int patchset,
  ) async {
    final changeDocs = await _firestoreService.fetchTryChanges(
      review,
      patchset,
    );
    return changeDocs.expand((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final result = data['result'] ?? '';
      final change = ChangeInResult.create(
        result: result,
        expected: data['expected'] ?? '',
        isFlaky: result.toLowerCase().contains('flaky'),
        previousResult: data['previous_result'] ?? '',
      );
      final configurations = List<String>.from(data['configurations'] ?? []);
      return configurations.map((configuration) {
        final result = Result()
          ..name = data['name'] ?? ''
          ..configuration = configuration
          ..result = data['result'] ?? ''
          ..expected = data['expected'] ?? ''
          ..flaky = change.flaky;
        return (change, result);
      });
    });
  }

  Future<List<Comment>> fetchComments(int review) async {
    final commentDocs = await _firestoreService.fetchCommentsForReview(review);
    return commentDocs.map((d) => Comment.fromFirestore(d)).toList();
  }

  Future<Map<String, String>> fetchBuilders() async {
    final builderDocs = await _firestoreService.fetchBuilders();
    return {for (var doc in builderDocs) doc.id: doc.get('builder') as String};
  }
}
