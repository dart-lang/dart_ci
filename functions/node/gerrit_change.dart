// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:http/http.dart' as http;

import 'firestore.dart';

class GerritInfo {
  static const gerritUrl = 'https://dart-review.googlesource.com/changes';
  static const gerritQuery =
      'o=ALL_REVISIONS&o=DETAILED_ACCOUNTS&o=CURRENT_COMMIT';
  static const trivialKinds = const {
    'TRIVIAL_REBASE',
    'NO_CHANGE',
    'NO_CODE_CHANGE',
  };
  static const prefix = ")]}'\n";

  http.BaseClient httpClient;
  FirestoreService firestore;
  String review;
  String patchset;

  GerritInfo(int review, int patchset, this.firestore, this.httpClient) {
    this.review = review.toString();
    this.patchset = patchset.toString();
  }

// Fetch the owner, changeId, message, and date of a Gerrit change.
  Future<void> update() async {
    if (await firestore.hasPatchset(review, patchset)) return;
    // Get the Gerrit change's commit from the Gerrit API.
    final url = '$gerritUrl/$review?$gerritQuery';
    final response = await httpClient.get(url);
    final protectedJson = response.body;
    if (!protectedJson.startsWith(prefix))
      throw Exception('Gerrit response missing prefix $prefix: $protectedJson');
    final reviewInfo = jsonDecode(protectedJson.substring(prefix.length))
        as Map<String, dynamic>;
    final reverted = revert(reviewInfo);
    await firestore.storeReview(review, {
      'subject': reviewInfo['subject'],
      if (reverted != null) 'revert_of': reverted
    });

    // Add the patchset information to the patchsets subcollection.
    final revisions = reviewInfo['revisions'].values.toList()
      ..sort((a, b) => (a['_number'] as int).compareTo(b['_number']));
    int patchsetGroupFirst;
    for (Map<String, dynamic> revision in revisions) {
      int number = revision['_number'];
      if (!trivialKinds.contains(revision['kind'])) {
        patchsetGroupFirst = number;
      }
      await firestore.storePatchset(review, number, {
        'number': number,
        'patchset_group': patchsetGroupFirst,
        'description': revision['description'],
        'kind': revision['kind']
      });
    }
  }

  static String revert(Map<String, dynamic> reviewInfo) {
    final current = reviewInfo['current_revision'];
    final commit = reviewInfo['revisions'][current]['commit'];
    final regExp =
        RegExp('^This reverts commit ([\\da-f]+)\\.\$', multiLine: true);
    return regExp.firstMatch(commit['message'])?.group(1);
  }
}
