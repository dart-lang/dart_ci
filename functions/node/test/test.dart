// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../builder.dart';
import 'firestore_mock.dart';
import 'http_mock.dart';
import 'test_data.dart';

void main() async {
  test("Store already existing commit", () async {
    final client = HttpClientMock();
    final firestore = FirestoreServiceMock();
    final change = alreadyExistingCommitChange;

    final builder = Build(existingCommitHash, change, firestore, client);
    await builder.storeBuildCommitsInfo();
    expect(builder.endIndex, existingCommit['index']);
    expect(builder.startIndex, previousCommit['index'] + 1);
    verifyInOrder([
      firestore.getCommit(existingCommitHash),
      firestore.getCommit(previousCommitHash)
    ]);
  });
}
