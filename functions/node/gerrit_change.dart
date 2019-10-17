// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:node_http/node_http.dart' as http;

class GerritInfo {
  static const gerritUrl = 'https://dart-review.googlesource.com/changes';
  static final reviewRefRegExp = RegExp(r'refs/changes/(\d*)/(\d*)');
  static const trivialKinds = const {
    'TRIVIAL_REBASE',
    'NO_CHANGE',
    'NO_CODE_CHANGE',
  };
  static const prefix = ")]}'\n";

  Firestore firestore;
  String review;
  String patchset;

  GerritInfo(String changeRef, this.firestore) {
    final match = reviewRefRegExp.matchAsPrefix(changeRef);
    review = match[1];
    patchset = match[2];
  }

// Fetch the owner, changeId, message, and date of a Gerrit change.
  Future<void> update() async {
    final client = http.NodeClient();
    var patchsetRef = firestore.document('reviews/$review/patchsets/$patchset');
    DocumentSnapshot patchsetDoc = await patchsetRef.get();
    if (patchsetDoc.exists) return;

    // Get the Gerrit change's commit from the Gerrit API.
    final url = '$gerritUrl/$review?o=ALL_REVISIONS&o=DETAILED_ACCOUNTS';
    final response = await client.get(url);
    final protectedJson = response.body;
    if (!protectedJson.startsWith(prefix))
      throw Exception('Gerrit response missing prefix $prefix: $protectedJson');
    final reviewInfo = jsonDecode(protectedJson.substring(prefix.length))
        as Map<String, dynamic>;
    final reviewRef = firestore.document('reviews/$review');
    await reviewRef
        .setData(DocumentData.fromMap({'subject': reviewInfo['subject']}));

    // Add the patchset information to the patchsets subcollection.
    final revisions = reviewInfo['revisions'].values.toList()
      ..sort((a, b) => (a['_number'] as int).compareTo(b['_number']));
    var patchsetGroupFirst;
    for (Map<String, dynamic> revision in revisions) {
      final number = revision['_number'];
      if (!trivialKinds.contains(revision['kind'])) {
        patchsetGroupFirst = number;
      }
      patchsetRef = firestore.document('reviews/$review/patchsets/$number');

      await patchsetRef.setData(DocumentData.fromMap({
        'number': number,
        'patchset_group': patchsetGroupFirst,
        'description': revision['description'],
        'kind': revision['kind']
      }));
    }
  }
}
