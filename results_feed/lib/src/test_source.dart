// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'model/commit.dart';

String getTestSourceUrl(List<Commit> commits, Change change, bool isTryResult) {
  const serviceUrl = 'https://dart-ci.appspot.com/test';
  if (isTryResult) {
    return '$serviceUrl/cl/${change.review}/${change.patchset}/${change.name}';
  } else {
    final revision =
        commits.singleWhere((c) => c.index == change.blamelistEndIndex).hash;
    return '$serviceUrl/$revision/${change.name}';
  }
}
