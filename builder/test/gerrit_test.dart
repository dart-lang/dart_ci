// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:test/test.dart';

import 'package:builder/src/gerrit_change.dart';
import 'fakes.dart';
import 'gerrit_review_json.dart';

void main() async {
  test('get revert information from Gerrit log api output', () {
    expect(GerritInfo.revert(json.decode(revertReviewGerritLog)),
        '7ed1690b4ed6b56bc818173dff41a7a2530991a2');
  });

  test('update', () async {
    final httpClientMock = HttpClientMock()
      ..addDefaultResponse('${GerritInfo.prefix}$revertReviewGerritLog');
    final gerrit = GerritInfo(123, 4, FirestoreServiceFake(), httpClientMock);
    await gerrit.update();
  });
}
