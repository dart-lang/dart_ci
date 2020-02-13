// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:http/http.dart' as http show BaseClient;
import 'package:pool/pool.dart';

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
  final String buildbucketID;
  int countChanges = 0;
  int countUnapproved = 0;

  Tryjob(String changeRef, this.countChunks, this.buildbucketID, this.firestore,
      this.httpClient) {
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
    await Pool(30).forEach(results.where(isChangedResult), storeChange).drain();

    if (countChunks != null) {
      await firestore.storeTryBuildChunkCount(builderName, buildNumber,
          buildbucketID, review, patchset, countChunks);
    }
    await firestore.storeTryChunkStatus(
        builderName, buildNumber, buildbucketID, review, patchset, success);

    final report = [
      "Processed ${results.length} results from $builderName build $buildNumber",
      "Tryjob on CL $review patchset $patchset",
      if (countChanges > 0) "Stored $countChanges changes",
      if (!success) "Found unapproved new failures",
      if (countUnapproved > 0) "$countUnapproved tests found",
    ];
    print(report.join('\n'));
  }

  Future<void> storeChange(change) async {
    countChanges++;
    final approved = await firestore.storeTryChange(change, review, patchset);
    if (!approved && !change['matches']) {
      countUnapproved++;
      success = false;
    }
  }
}
