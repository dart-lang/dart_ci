// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:mockito/mockito.dart';

import '../firestore.dart';
import 'test_data.dart';

class FirestoreServiceMock extends Mock implements FirestoreService {
  FirestoreServiceMock() {
    when(this.getCommit(existingCommitHash))
        .thenAnswer((_) => Future.value(existingCommit));
    when(this.getCommit(previousCommitHash))
        .thenAnswer((_) => Future.value(previousCommit));
  }
}
