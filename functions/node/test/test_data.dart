// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:core';

const Map<String, dynamic> alreadyExistingCommitChange = {
  "name": "dart2js_extra/local_function_signatures_strong_test/none",
  "configuration": "dart2js-new-rti-linux-x64-d8",
  "suite": "dart2js_extra",
  "test_name": "local_function_signatures_strong_test/none",
  "time_ms": 2384,
  "result": "Pass",
  "expected": "Pass",
  "matches": true,
  "bot_name": "luci-dart-try-xenial-70-8fkh",
  "commit_hash": existingCommitHash,
  "commit_time": 1563576771,
  "build_number": "307",
  "builder_name": "dart2js-rti-linux-x64-d8",
  "flaky": false,
  "previous_flaky": false,
  "previous_result": "RuntimeError",
  "previous_commit_hash": previousCommitHash,
  "previous_commit_time": 1563576211,
  "previous_build_number": "306",
  "changed": true
};

const String existingCommitHash = 'an already existing commit hash';

Map<String, dynamic> existingCommit = {
  'author': 'test_user@example.com',
  'created': DateTime.parse('2019-11-22 22:19:00Z'),
  'index': 52,
  'title': 'A commit used for testing, with index 52'
};

const String previousCommitHash = 'a previous existing commit hash';
Map<String, dynamic> previousCommit = {
  'author': 'previous_user@example.com',
  'created': DateTime.parse('2019-11-24 11:18:00Z'),
  'index': 49,
  'title': 'A commit used for testing, with index 49'
};
