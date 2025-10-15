// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';

class TryBuild {
  final String id;
  final int buildNumber;
  final String builder;
  final bool success;
  final bool completed;
  final int review;
  final int patchset;

  TryBuild({
    required this.id,
    required this.buildNumber,
    required this.builder,
    required this.success,
    required this.completed,
    required this.review,
    required this.patchset,
  });

  factory TryBuild.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TryBuild(
      id: doc.id,
      buildNumber: data['build_number'] ?? 0,
      builder: data['builder'] ?? '',
      success: data['success'] ?? false,
      completed: data['completed'] ?? false,
      review: data['review'] ?? 0,
      patchset: data['patchset'] ?? 0,
    );
  }
}
