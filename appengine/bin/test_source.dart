// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:dart_ci/src/test_source.dart';

main(List<String> arguments) async {
  if (arguments.isEmpty || arguments.length > 2) {
    print('Finds the source of the given test. If a revision is provided,'
        'returns a link to the source at that revision, otherwise the latest'
        'revision at main.\n\n'
        'Usage: test_source <full test name> [<revision>]');
    exit(1);
  }
  final testName = arguments.first;
  final revision = arguments.length == 2 ? arguments[1] : 'main';
  print(await computeTestSource(revision, testName, true));
}
