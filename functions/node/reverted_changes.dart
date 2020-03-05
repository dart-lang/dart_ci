// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:collection/collection.dart';

import 'firestore.dart';
import 'result.dart';

Future<RevertedChanges> getRevertedChanges(
    String reverted, int revertIndex, FirestoreService firestore) async {
  final revertedCommit = await firestore.getCommit(reverted);
  if (revertedCommit == null) {
    throw 'Cannot find commit for reverted commit hash $reverted';
  }
  final index = revertedCommit['index'];
  final changes = await firestore.findRevertedChanges(index);
  return RevertedChanges(
      index, revertIndex, changes, groupBy(changes, (change) => change[fName]));
}

class RevertedChanges {
  final int index;
  final int revertIndex;
  final List<Map<String, dynamic>> changes;
  final Map<String, List<Map<String, dynamic>>> changesForTest;

  RevertedChanges(
      this.index, this.revertIndex, this.changes, this.changesForTest);

  bool approveRevert(Map<String, dynamic> revert) {
    final reverted = changesForTest[revert[fName]];
    return isFailure(revert) &&
        reverted != null &&
        reverted.any((change) => revert[fResult] == change[fPreviousResult]);
  }
}
