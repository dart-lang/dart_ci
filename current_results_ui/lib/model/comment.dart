// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String author;
  final DateTime created;
  final String comment;
  final bool? approved;
  final List<String> tryResults;

  Comment({
    required this.id,
    required this.author,
    required this.created,
    required this.comment,
    this.approved,
    required this.tryResults,
  });

  factory Comment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Comment(
      id: doc.id,
      author: data['author'] ?? '',
      created: (data['created'] as Timestamp).toDate(),
      comment: data['comment'] ?? '',
      approved: data['approved'],
      tryResults: List<String>.from(data['try_results'] ?? []),
    );
  }
}
