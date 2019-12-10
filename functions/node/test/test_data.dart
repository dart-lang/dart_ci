// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:core';

const Map<String, dynamic> existingCommitChange = {
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

const String landedCommitHash = 'a commit landing a CL hash';
Map<String, dynamic> landedCommit = {
  'author': 'gerrit_user@example.com',
  'created': DateTime.parse('2019-11-29 15:15:00Z'),
  'index': 54,
  'title': 'A commit used for testing tryjob approvals, with index 54',
  'review': 44445
};

const Map<String, dynamic> landedCommitChange = {
  "name": "dart2js_extra/local_function_signatures_strong_test/none",
  "configuration": "dart2js-new-rti-linux-x64-d8",
  "suite": "dart2js_extra",
  "test_name": "local_function_signatures_strong_test/none",
  "time_ms": 2384,
  "result": "RuntimeError",
  "expected": "Pass",
  "matches": false,
  "bot_name": "luci-dart-try-xenial-70-8fkh",
  "commit_hash": landedCommitHash,
  "commit_time": 1563576771,
  "build_number": "308",
  "builder_name": "dart2js-rti-linux-x64-d8",
  "flaky": false,
  "previous_flaky": false,
  "previous_result": "Pass",
  "previous_commit_hash": existingCommitHash,
  "previous_commit_time": 1563576211,
  "previous_build_number": "306",
  "changed": true
};

const List<Map<String, dynamic>> tryjobResults = [
  {
    "review": 44445,
    "configurations": [
      "dart2js-new-rti-linux-x64-d8",
      "dartk-reload-rollback-linux-debug-x64",
      "dartk-reload-linux-debug-x64"
    ],
    "name": "dart2js_extra/local_function_signatures_strong_test/none",
    "patchset": 1,
    "result": "RuntimeError",
    "expected": "Pass",
    "previous_result": "Pass",
    "approved": true
  },
];

String gitLogCommitHash = "a commit fetched from the git log";

String gitilesLog = '''
)]}'
{
  "log": [
    {
      "commit": "$landedCommitHash",
      "parents": ["$gitLogCommitHash"],
      "author": {
        "email": "gerrit_user@example.com"
      },
      "committer": {
        "time": "Fri Nov 29 15:15:00 2019 +0000"
      },
      "message": "A commit used for testing tryjob approvals, with index 54\\n\\nDescription of the landed commit\\nin multiple lines.\\n\\u003e Change-Id: I8dcc08b7571137e869a16ceea8cc73539eb02a5a\\n\\u003e Reviewed-on: https://dart-review.googlesource.com/c/sdk/+/33337\\n\\nChange-Id: I89b88c3d9f7c743fc340ee73a45c3f57059bcf30\\nReviewed-on: https://dart-review.googlesource.com/c/sdk/+/44445\\n\\n"
    },
    {
      "commit": "$gitLogCommitHash",
      "parents": ["$existingCommitHash"],
      "author": {
        "email": "user@example.com"
      },
      "committer": {
        "time": "Thu Nov 28 12:07:55 2019 +0000"
      },
      "message": "A commit on the git log\\n\\nThis commit does not have results from the CQ\\n\\nChange-Id: I481b2cb8b666885b5c2b9c53fff1177accd01830\\nReviewed-on: https://dart-review.googlesource.com/c/sdk/+/77779\\nCommit-Queue: A user \\u003cuser9@example.com\\u003e\\nReviewed-by: Another user \\u003cuser10@example.com\\u003e\\n"
    }
  ]
}
''';
