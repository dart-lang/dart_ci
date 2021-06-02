// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Generates sample test data from a file with a list of test names.

import 'dart:convert';
import 'dart:io';

import 'package:dart_ci/src/test_source.dart';

const revision = '245705e23c9ec290b10cbb981c1941d7e600b00c';

main(List<String> arguments) async {
  // We want a test case for each suite and other variations, so we compute
  // an identifier for each class of tests that we are interested in.
  String makeKey(String testName) {
    final parts = testName.split('/');
    final suite = parts.first;
    final baseName = findBaseName(suite, parts) ?? testName;
    // Make distinct keys for tests that have one or multiple postfix '/???'
    // parts because of multi-tests or VMOption variations.
    final postFix =
        testName.substring(baseName.length).split('/').length.toString();
    if (['vm', 'pkg_tested'].contains(parts.first)) {
      // Include the sub component of the path in the key.
      return parts.take(2).join('/') + postFix;
    } else if (testName.startsWith('pkg/front_end')) {
      if (isFrontEndUnitTestSuiteTest(testName)) {
        return "pkg/front_end/test/unit_test_suites.dart";
      } else {
        return parts.take(2).join('/') + postFix;
      }
    } else {
      return parts.first + postFix;
    }
  }

  final tests = await File(arguments.single).readAsLines();
  final testNames = <String, String>{};
  for (final testName in tests) {
    var key = makeKey(testName);
    // Pick one example for each class of tests.
    testNames.putIfAbsent(key, () => testName);
  }

  Map<String, Map<String, String>> results = {
    'suite/not_a_basename': {"true": null, "false": null},
  };
  for (var name in testNames.values) {
    results[name] = {};
    for (var gob in [true, false]) {
      results[name][gob.toString()] =
          (await computeTestSource(revision, name, gob)).toString();
    }
  }
  print(jsonEncode(results));
}
