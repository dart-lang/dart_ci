// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'index.dart';

String resultJson = '''
{
"name":"dart2js_extra/local_function_signatures_strong_test/none",
"configuration":"dart2js-new-rti-linux-x64-d8",
"suite":"dart2js_extra",
"test_name":"local_function_signatures_strong_test/none",
"time_ms":2384,
"result":"Pass",
"expected":"Pass",
"matches":true,
"bot_name":"luci-dart-try-xenial-70-8fkh",
"commit_hash":"9cd47ac2e6ac024e5a0fd1d5667d94a8c2fd2d5e",
"commit_time":1563576771,
"build_number":"307",
"builder_name":"dart2js-rti-linux-x64-d8",
"flaky":false,
"previous_flaky":false,
"previous_result":"RuntimeError",
"previous_commit_hash":"ebc180be95efd89b8745ddffcedf970af6e36dc1",
"previous_commit_time":1563576211,
"previous_build_number":"306",
"changed":true
}
''';

String tryResultJson = '''
{
"name":"dart2js_extra/local_function_signatures_strong_test/none",
"configuration":"dart2js-new-rti-linux-x64-d8",
"suite":"dart2js_extra",
"test_name":"local_function_signatures_strong_test/none",
"time_ms":2384,
"result":"Pass",
"expected":"Pass",
"matches":true,
"bot_name":"luci-dart-try-xenial-70-8fkh",
"commit_hash":"refs/changes/12345/2",
"commit_time":1563576771,
"build_number":"307",
"builder_name":"dart2js-rti-linux-x64-d8",
"flaky":false,
"previous_flaky":false,
"previous_result":"RuntimeError",
"previous_commit_hash":"ebc180be95efd89b8745ddffcedf970af6e36dc1",
"previous_commit_time":1563576211,
"previous_build_number":"306",
"changed":true
}
''';

void main() async {
  print("starting test");
  Map<String, dynamic> result = jsonDecode(resultJson);
  final stats = Statistics();
  final info = await storeBuildInfo([result], stats);
  print("info: $info");
  stats.report();
  await storeChange(result, info, stats);
  stats.report();
  await storeTryChange(jsonDecode(tryResultJson) as Map<String, dynamic>);
}
