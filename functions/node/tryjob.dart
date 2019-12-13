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
  final http.BaseClient httpClient;
  final FirestoreService firestore;
  String builderName;
  int buildNumber;
  int review;
  int patchset;
  bool success = true;
  final int countChunks;

  Tryjob(String changeRef, this.countChunks, this.firestore, this.httpClient) {
    final match = changeRefRegExp.matchAsPrefix(changeRef);
    review = int.parse(match[1]);
    patchset = int.parse(match[2]);
  }

  Future<void> update() {
    return GerritInfo(review, patchset, firestore, httpClient).update();
  }

  Future<void> process(List<Map<String, dynamic>> results) async {
    await update();
    builderName = results.first['builder_name'];
    buildNumber = int.parse(results.first['build_number']);
    await Future.forEach(results.where(isChangedResult), storeTryChange);

    if (countChunks != null) {
      await firestore.storeTryBuildChunkCount(
          builderName, buildNumber, review, patchset, countChunks);
    }
    await firestore.storeTryChunkStatus(
        builderName, buildNumber, review, patchset, success);
  }

  Future<void> storeTryChange(change) async {
    final approved = await firestore.storeTryChange(change, review, patchset);
    if (!approved && !change['matches']) success = false;
  }
}
