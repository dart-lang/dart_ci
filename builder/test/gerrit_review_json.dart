// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// This is the JSON log for an actual review that is a revert,
// with emails and names removed.
String revertReviewGerritLog = r'''
{
  "id": "sdk~master~Ie212fae88bc1977e34e4d791c644b77783a8deb1",
  "project": "sdk",
  "branch": "master",
  "hashtags": [],
  "change_id": "Ie212fae88bc1977e34e4d791c644b77783a8deb1",
  "subject": "Revert \"[SDK] Adds IndirectGoto implementation of sync-yield.\"",
  "status": "MERGED",
  "created": "2020-02-17 12:17:05.000000000",
  "updated": "2020-02-17 12:17:25.000000000",
  "submitted": "2020-02-17 12:17:25.000000000",
  "submitter": {
    "_account_id": 5260,
    "name": "commit-bot@chromium.org",
    "email": "commit-bot@chromium.org"
  },
  "insertions": 61,
  "deletions": 155,
  "total_comment_count": 0,
  "unresolved_comment_count": 0,
  "has_review_started": true,
  "revert_of": 133586,
  "submission_id": "136125",
  "_number": 136125,
  "owner": {
  },
  "current_revision": "82f3f81fc82d06c575b0137ddbe71408826d8b46",
  "revisions": {
    "82f3f81fc82d06c575b0137ddbe71408826d8b46": {
      "kind": "REWORK",
      "_number": 2,
      "created": "2020-02-17 12:17:25.000000000",
      "uploader": {
        "_account_id": 5260,
        "name": "commit-bot@chromium.org",
        "email": "commit-bot@chromium.org"
      },
      "ref": "refs/changes/25/136125/2",
      "fetch": {
        "rpc": {
          "url": "rpc://dart/sdk",
          "ref": "refs/changes/25/136125/2"
        },
        "http": {
          "url": "https://dart.googlesource.com/sdk",
          "ref": "refs/changes/25/136125/2"
        },
        "sso": {
          "url": "sso://dart/sdk",
          "ref": "refs/changes/25/136125/2"
        }
      },
      "commit": {
        "parents": [
          {
            "commit": "d2d00ff357bd64a002697b3c96c92a0fec83328c",
            "subject": "[cfe] Allow unassigned late local variables"
          }
        ],
        "author": {
          "name": "gerrit_user",
          "email": "gerrit_user@example.com",
          "date": "2020-02-17 12:17:25.000000000",
          "tz": 0
        },
        "committer": {
          "name": "commit-bot@chromium.org",
          "email": "commit-bot@chromium.org",
          "date": "2020-02-17 12:17:25.000000000",
          "tz": 0
        },
        "subject": "Revert \"[SDK] Adds IndirectGoto implementation of sync-yield.\"",
        "message": "Revert \"[SDK] Adds IndirectGoto implementation of sync-yield.\"\n\nThis reverts commit 7ed1690b4ed6b56bc818173dff41a7a2530991a2.\n\nReason for revert: Crashes precomp.\n\nOriginal change\u0027s description:\n\u003e [SDK] Adds IndirectGoto implementation of sync-yield.\n\u003e \n\u003e Sets a threshold of five continuations determining if the old\n\u003e if-else or the new igoto-based implementation will be used.\n\u003e Informal benchmarking on x64 and arm_x64 point towards the overhead\n\u003e of the igoto-based impl. dropping off around this point.\n\u003e \n\u003e Benchmarks of this CL (threshold\u003d5) show drastic improvement in\n\u003e Calls.IterableManualIterablePolymorphicManyYields of about ~35-65%\n\u003e across {dart,dart-aot}-{ia32,x64,armv7hf,armv8}.\n\u003e \n\u003e Bug: https://github.com/dart-lang/sdk/issues/37754\n\u003e Change-Id: I6e113f1f98e9ab0f994cf93004227d616e9e4d07\n\u003e Reviewed-on: https://dart-review.googlesource.com/c/sdk/+/133586\n\u003e Commit-Queue: XXXXX \u003cxxxx@example.com\u003e\n\u003e Reviewed-by: xxxx \u003cxxxxxx@example.com\u003e\n\nChange-Id: Ie212fae88bc1977e34e4d791c644b77783a8deb1\nNo-Presubmit: true\nNo-Tree-Checks: true\nNo-Try: true\nBug: https://github.com/dart-lang/sdk/issues/37754\nReviewed-on: https://dart-review.googlesource.com/c/sdk/+/136125\nReviewed-by: XXX\nCommit-Queue: XXXXXX\n"
      },
      "description": "Rebase"
    },
    "8bae95c4001a0815e89ebc4c89dc5ad42337a01b": {
      "kind": "REWORK",
      "_number": 1,
      "created": "2020-02-17 12:17:05.000000000",
      "uploader": {
      },
      "ref": "refs/changes/25/136125/1",
      "fetch": {
        "rpc": {
          "url": "rpc://dart/sdk",
          "ref": "refs/changes/25/136125/1"
        },
        "http": {
          "url": "https://dart.googlesource.com/sdk",
          "ref": "refs/changes/25/136125/1"
        },
        "sso": {
          "url": "sso://dart/sdk",
          "ref": "refs/changes/25/136125/1"
        }
      }
    }
  },
  "requirements": []
}
''';
