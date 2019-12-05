// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:http/http.dart' as http show BaseClient;

import 'firestore.dart';
import 'gerrit_change.dart';

bool isChangedResult(Map<String, dynamic> result) =>
    result['changed'] && !result['flaky'] && !result['previous_flaky'];

class Tryjob {
  static final changeRefRegExp = RegExp(r'refs/changes/(\d*)/(\d*)');
  http.BaseClient httpClient;
  FirestoreService firestore;
  int review;
  int patchset;

  Tryjob(String changeRef, this.firestore, this.httpClient) {
    final match = changeRefRegExp.matchAsPrefix(changeRef);
    review = int.parse(match[1]);
    patchset = int.parse(match[2]);
  }

  Future<void> update() {
    return GerritInfo(review, patchset, firestore, httpClient).update();
  }

  Future<void> process(List<Map<String, dynamic>> results) async {
    await update();
    await Future.forEach(results.where(isChangedResult),
        (change) => firestore.storeTryChange(change, review, patchset));
  }
}
