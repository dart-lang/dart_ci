// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Resolves the source of a test for a given revision of the SDK.

import 'dart:async' show Future;
import 'dart:convert' show base64Decode, jsonDecode;
import 'package:http/http.dart' as http;
import 'dart:io' show HttpStatus;

final testDirectories = {
  "observatory_ui": "runtime/observatory/tests/observatory_ui",
  "observatory_ui_2": "runtime/observatory_2/tests/observatory_ui_2",
  "pkg_tested": "third_party/pkg_tested",
  "samples": "samples",
  "samples_2": "samples_2",
  "service": "runtime/observatory/tests/service",
  "service_2": "runtime/observatory_2/tests/service_2"
};

const customTestRunnerSuites = {
  'flutter_frontend':
      'pkg/frontend_server/test/frontend_server_flutter_suite.dart',
};

// These names must be kept in sync with
// https://github.com/dart-lang/sdk/blob/master/pkg/front_end/test/unit_test_suites_impl.dart
const frontendUnitTestSuites = [
  "fasta/expression",
  "fasta/outline",
  "fasta/incremental_dartino",
  "fasta/messages",
  "fasta/text_serialization",
  "fasta/strong",
  "incremental_bulk_compiler_smoke",
  "incremental",
  "lint",
  "parser",
  "parser_equivalence",
  "parser_all",
  "spelling_test_not_src",
  "spelling_test_src",
  "fasta/weak",
  "fasta/textual_outline",
];

String? findBaseName(String suite, Iterable<String> nameParts) {
  var parts = nameParts.toList();
  final regExp = (suite == 'co19' || suite == 'co19_2')
      ? RegExp(r"t[0-9]{2,3}$")
      : RegExp(r"_test$");
  for (var i = 0; i <= 2 && parts.isNotEmpty; i++) {
    if (regExp.hasMatch(parts.last)) {
      return parts.join('/');
    } else {
      parts.removeLast();
    }
  }
  return null;
}

Future<Uri?> guessFileName(
    String suite, Uri testDirectory, Iterable<String> parts) async {
  final baseName = findBaseName(suite, parts);
  if (baseName != null) {
    return testDirectory.resolve('$baseName.dart');
  } else {
    return null;
  }
}

bool isFrontEndUnitTestSuiteTest(String testName) {
  for (final suite in frontendUnitTestSuites) {
    if (testName.startsWith('pkg/front_end/test/$suite')) {
      return true;
    }
  }
  return false;
}

Future<Uri?> findTestFile(
    String testName, Uri root, String suite, Iterable<String> testParts) async {
  if (isCo19(suite)) {
    return await guessFileName(suite, root, testParts);
  } else if (isExternalPackage(suite)) {
    return root.resolve('${testParts.join('/')}.dart');
  } else if (testDirectories.containsKey(suite)) {
    var testDir = root.resolveUri(Uri.directory(testDirectories[suite]!));
    return await guessFileName(suite, testDir, testParts);
  } else if (customTestRunnerSuites.containsKey(suite)) {
    return root.resolve(customTestRunnerSuites[suite]!);
  } else if (suite == 'pkg') {
    if (testParts.first == 'front_end' &&
        isFrontEndUnitTestSuiteTest(testName)) {
      // Some of the pkg/front_end tests are in unit test suites defined in a
      // custom test runner.
      return root.resolve('pkg/front_end/test/unit_test_suites.dart');
    } else {
      final fileName =
          await guessFileName(suite, root.resolve('pkg/'), testParts);
      return fileName;
    }
  } else if (testName.startsWith('tests/modular')) {
    return root.resolve(testName);
  } else if (suite == 'ffi_unit') {
    // TODO(karlklose): find a way to lookup the location of the definition
    return root.resolve('runtime/vm/compiler/ffi');
  } else if (testName.startsWith('vm/cc')) {
    // TODO(karlklose): find a way to lookup the location of the definition
    return root.resolve('runtime/vm/');
  } else if (testName.startsWith('vm/dart')) {
    return await guessFileName(
        suite, root.resolve('runtime/tests/vm/'), testParts);
  } else {
    // By default, map the path to the tests directory.
    return await guessFileName(suite, root.resolve('tests/$suite/'), testParts);
  }
}

bool isCo19(String suite) {
  return suite == 'co19' || suite == 'co19_2';
}

bool isExternalPackage(String suite) {
  return suite == 'pkg_tested';
}

Future<String> findDepsRevision(String revision, String package) async {
  final url = Uri.parse(
      'https://dart.googlesource.com/sdk/+/$revision/DEPS?format=TEXT');
  final response = await http.get(url);
  if (response.statusCode != HttpStatus.ok) {
    throw Exception("Unable to download DEPS for revision '$revision'"
        "at $url");
  }
  final body = String.fromCharCodes(base64Decode(response.body));
  final match = RegExp('"${package}_rev": "(.*)",').firstMatch(body);
  if (match == null) {
    throw Exception("Unable to find $package revision '$revision' at $url");
  }
  return match.group(1)!;
}

const gerritDataHeader = ")]}'";

Future<String> getPatchsetRevision(int review, int patchset) async {
  final url = Uri.parse('https://dart-review.googlesource.com/'
      'changes/$review/revisions/$patchset/commit');
  final response = await http.get(url);
  if (response.statusCode != HttpStatus.ok) {
    throw Exception("Can't find revision for cl/$review/$patchset");
  }
  final body = response.body;
  if (!body.startsWith(gerritDataHeader)) {
    throw Exception('Got invalid response for cl/$review/$patchset');
  }
  final data = jsonDecode(body.substring(gerritDataHeader.length));
  return data['commit'];
}

Future<Uri?> computeTestSource(
    String revision, String testName, bool useGob) async {
  final splitName = testName.split('/');
  var parts = splitName.skip(1);
  final suite = splitName.first;
  String root;
  if (isCo19(suite)) {
    revision = await findDepsRevision(revision, suite);
    root = "https://github.com/dart-lang/co19/blob/$revision/";
  } else if (isExternalPackage(suite)) {
    final package = parts.first;
    revision = await findDepsRevision(revision, package);
    root = "https://dart.googlesource.com/$package/+/$revision/";
    parts = parts.skip(1);
  } else {
    root = useGob
        ? "https://dart.googlesource.com/sdk/+/$revision/"
        : "https://github.com/dart-lang/sdk/blob/$revision/";
  }
  return findTestFile(testName, Uri.parse(root), suite, parts);
}
