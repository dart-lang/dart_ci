// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id;
  final String subject;
  final List<Patchset> patchsets;

  Review({required this.id, required this.subject, required this.patchsets});

  factory Review.fromFirestore(DocumentSnapshot doc, List<Patchset> patchsets) {
    final data = doc.data() as Map<String, dynamic>;
    return Review(
      id: doc.id,
      subject: data['subject'] ?? '',
      patchsets: patchsets,
    );
  }
}

class Patchset {
  final String id;
  final String description;
  final int number;
  final int patchsetGroup;

  Patchset({
    required this.id,
    required this.description,
    required this.number,
    required this.patchsetGroup,
  });

  factory Patchset.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Patchset(
      id: doc.id,
      description: data['description'] ?? '',
      number: data['number'] ?? 0,
      patchsetGroup: data['patchset_group'] ?? 0,
    );
  }
}
