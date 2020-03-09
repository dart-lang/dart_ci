// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Tests that check automatic approval of failures on a revert on the CI

import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../result.dart';
import 'fakes.dart';
import 'test_data.dart';

void main() async {
  test('fetch commit that is a revert', () async {
    final builderTest = BuilderTest(revertCommitHash, revertUnchangedChange);
    builderTest.firestore.commits[revertedCommitHash] = revertedCommit;
    when(builderTest.client.get(any))
        .thenAnswer((_) => Future(() => ResponseFake(revertGitilesLog)));
    await builderTest.storeBuildCommitsInfo();
    expect(builderTest.builder.endIndex, revertCommit['index']);
    expect(builderTest.builder.startIndex, landedCommit['index'] + 1);
    expect(await builderTest.builder.firestore.getCommit(revertCommitHash),
        revertCommit);
  });

  test('fetch commit that is a reland (as a reland)', () async {
    final builderTest = BuilderTest(relandCommitHash, relandUnchangedChange);
    builderTest.firestore.commits[revertedCommitHash] = revertedCommit;
    when(builderTest.client.get(any)).thenAnswer(
        (_) => Future(() => ResponseFake(revertAndRelandGitilesLog)));
    await builderTest.storeBuildCommitsInfo();
    expect(builderTest.builder.endIndex, relandCommit['index']);
    expect(builderTest.builder.startIndex, revertCommit['index'] + 1);
    expect(await builderTest.builder.firestore.getCommit(revertCommitHash),
        revertCommit);
    expect(
        await builderTest.builder.firestore.getCommit(commit56Hash), commit56);
    expect(await builderTest.builder.firestore.getCommit(relandCommitHash),
        relandCommit);
  });

  test('fetch commit that is a reland (as a revert)', () async {
    final builderTest =
        RevertBuilderTest(relandCommitHash, relandUnchangedChange);
    when(builderTest.client.get(any))
        .thenAnswer((_) => Future(() => ResponseFake(relandGitilesLog)));
    await builderTest.storeBuildCommitsInfo();
    expect(builderTest.builder.endIndex, relandCommit['index']);
    expect(builderTest.builder.startIndex, revertCommit['index'] + 1);
    expect(await builderTest.builder.firestore.getCommit(relandCommitHash),
        relandCommit);
  });

  test('Automatically approve expected failure on revert', () async {
    final builderTest = RevertBuilderTest(revertCommitHash, revertChange);
    await builderTest.update();
    await builderTest.storeChange(revertChange);
    expect(
        builderTest.firestore.results.values
            .where((result) => result[fBlamelistEndIndex] == 55)
            .single,
        revertResult);
  });

  test('Revert in blamelist, doesn\'t match new failure', () async {
    final builderTest =
        RevertBuilderTest(commit56Hash, commit56UnmatchingChange);
    await builderTest.update();
    await builderTest.storeChange(commit56UnmatchingChange);
    await builderTest.storeChange(commit56DifferentNameChange);
    await builderTest.storeChange(commit56Change);
    expect(
        (await builderTest.firestore
                .findActiveResults(commit56UnmatchingChange))
            .single['approved'],
        false);
    expect(
        (await builderTest.firestore
                .findActiveResults(commit56DifferentNameChange))
            .single['approved'],
        false);
    expect(
        (await builderTest.firestore.findActiveResults(commit56Change))
            .single['approved'],
        true);
  });
}

class RevertBuilderTest extends BuilderTest {
  RevertBuilderTest(String commitHash, Map<String, dynamic> firstChange)
      : super(commitHash, firstChange) {
    expect(revertedCommit[fIndex] + 1, fakeFirestoreCommitsFirstIndex);
    expect(revertCommit[fIndex] - 1, fakeFirestoreCommitsLastIndex);
    firestore.commits
      ..[revertedCommitHash] = revertedCommit
      ..[revertCommitHash] = revertCommit
      ..[commit56Hash] = commit56;
    firestore.results['revertedResult id'] = revertedResult;
  }
}

// Commits
const String revertedCommitHash = '50abcd55abcd';
const int revertedReview = 3926;
const int revertedIndex = 50;
Map<String, dynamic> revertedCommit = Map.unmodifiable({
  'author': 'gerrit_reverted_user@example.com',
  'created': DateTime.parse('2019-11-22 02:01:00Z'),
  'index': revertedIndex,
  'title': 'A commit reverted by commit 55, with index 50',
  'review': revertedReview,
  'hash': revertedCommitHash,
});

const String revertCommitHash = '55ffffdddd';
const int revertReview = 3426;
const int revertIndex = 55;
Map<String, dynamic> revertCommit = Map.unmodifiable({
  'author': 'gerrit_revert_user@example.com',
  'created': DateTime.parse('2019-11-29 16:15:00Z'),
  'index': revertIndex,
  'title': 'Revert "${revertedCommit[fTitle]}"',
  'hash': revertCommitHash,
  'review': revertReview,
  'revert_of': revertedCommitHash,
});

const String commit56Hash = '56ffeeddccbbaa00';
Map<String, dynamic> commit56 = Map.unmodifiable({
  'author': 'gerrit_revert_user@example.com',
  'created': DateTime.parse('2019-11-29 17:15:00Z'),
  'index': revertIndex + 1,
  'title': 'A commit with index 56',
  'hash': commit56Hash,
});

const String relandCommitHash = '57eeddccff7733';
const int relandReview = 98999;
Map<String, dynamic> relandCommit = Map.unmodifiable({
  'author': 'gerrit_reland_user@example.com',
  'created': DateTime.parse('2020-01-13 06:16:00Z'),
  'index': revertIndex + 2,
  'title': 'Reland "${revertedCommit[fTitle]}"',
  'hash': relandCommitHash,
  'review': relandReview,
  'reland_of': revertedCommitHash,
});

// Changes
// This change is an unchanged passing result, used as the first result in
// a chunk with no changed results.
const Map<String, dynamic> revertUnchangedChange = {
  "name": "dart2js_extra/local_function_signatures_strong_test/none",
  "configuration": "dart2js-new-rti-linux-x64-d8",
  "suite": "dart2js_extra",
  "test_name": "local_function_signatures_strong_test/none",
  "time_ms": 2384,
  "result": "Pass",
  "expected": "Pass",
  "matches": false,
  "bot_name": "luci-dart-try-xenial-70-8fkh",
  "commit_hash": revertCommitHash,
  "previous_commit_hash": landedCommitHash,
  "commit_time": 1563576771,
  "build_number": "401",
  "previous_build_number": "400",
  "changed": false,
};

Map<String, dynamic> relandUnchangedChange = Map.from(revertUnchangedChange)
  ..["commit_hash"] = relandCommitHash
  ..["previous_commit_hash"] = revertCommitHash;

const Map<String, dynamic> revertChange = {
  "name": "test_suite/fixed_broken_test",
  "configuration": "a_different_configuration",
  "suite": "test_suite",
  "test_name": "fixed_broken_test",
  "time_ms": 2384,
  "result": "RuntimeError",
  "expected": "Pass",
  "matches": false,
  "bot_name": "a_ci_bot",
  "commit_hash": revertCommitHash,
  "commit_time": 1563576771,
  "build_number": "314",
  "builder_name": "dart2js-rti-linux-x64-d8",
  "flaky": false,
  "previous_flaky": false,
  "previous_result": "Pass",
  "previous_commit_hash": existingCommitHash,
  "previous_commit_time": 1563576211,
  "previous_build_number": "313",
  "changed": true,
};

const Map<String, dynamic> revertedChange = {
  "name": "test_suite/fixed_broken_test",
  "configuration": "a_configuration",
  "suite": "test_suite",
  "test_name": "fixed_broken_test",
  "time_ms": 2384,
  "result": "Pass",
  "expected": "Pass",
  "matches": true,
  "bot_name": "a_ci_bot",
  "commit_hash": revertedCommitHash,
  "commit_time": 1563576771,
  "build_number": "308",
  "builder_name": "dart2js-rti-linux-x64-d8",
  "flaky": false,
  "previous_flaky": false,
  "previous_result": "RuntimeError",
  "previous_commit_hash": "a nonexistent hash",
  "previous_commit_time": 1563576211,
  "previous_build_number": "306",
  "changed": true
};

Map<String, dynamic> commit56Change = Map.from(revertChange)
  ..['commit_hash'] = commit56Hash;
Map<String, dynamic> commit56UnmatchingChange = Map.from(commit56Change)
  ..['configuration'] = 'a_configuration'
  ..['commit_hash'] = commit56Hash
  ..['result'] = 'CompileTimeError';
Map<String, dynamic> commit56DifferentNameChange = Map.from(commit56Change)
  ..['commit_hash'] = commit56Hash
  ..['name'] = 'test_suite/broken_test'
  ..['test_name'] = 'broken_test';

// Results
const Map<String, dynamic> revertResult = {
  "configurations": ["a_different_configuration"],
  "active": true,
  "active_configurations": ["a_different_configuration"],
  "name": "test_suite/fixed_broken_test",
  "result": "RuntimeError",
  "expected": "Pass",
  "previous_result": "Pass",
  "blamelist_start_index": commit53Index,
  "blamelist_end_index": revertIndex,
  "pinned_index": revertIndex,
  "approved": true,
};

const Map<String, dynamic> revertedResult = {
  "configurations": ["a_configuration"],
  "name": "test_suite/fixed_broken_test",
  "result": "Pass",
  "expected": "Pass",
  "previous_result": "RuntimeError",
  "blamelist_start_index": revertedIndex,
  "blamelist_end_index": revertedIndex,
};

// Git logs
String escape(s) => s.replaceAll('"', '\\"');
String revertGitilesLog = gitilesLog([revertCommitJson]);
String relandGitilesLog = gitilesLog([relandCommitJson(relandAsRevert)]);
String revertAndRelandGitilesLog = gitilesLog(
    [relandCommitJson(relandAsReland), commit56Json, revertCommitJson]);

String gitilesLog(List<String> commitLogs) => '''
)]}'
{
  "log": [
  ${commitLogs.join(",\n")}
  ]
}
''';

String revertCommitJson = '''
    {
      "commit": "$revertCommitHash",
      "parents": ["$landedCommitHash"],
      "author": {
        "email": "${revertCommit[fAuthor]}"
      },
      "committer": {
        "time": "Fri Nov 29 16:15:00 2019 +0000"
      },
      "message": "${escape(revertCommit[fTitle])}\\n\\nThis reverts commit $revertedCommitHash.\\nChange-Id: I89b88c3d9f7c743fc340ee73a45c3f57059bcf30\\nReviewed-on: https://dart-review.googlesource.com/c/sdk/+/$revertReview\\n\\n"
    }
''';

String commit56Json = '''
    {
      "commit": "$commit56Hash",
      "parents": ["$revertCommitHash"],
      "author": {
        "email": "${commit56[fAuthor]}"
      },
      "committer": {
        "time": "Fri Nov 29 17:15:00 2019 +0000"
      },
      "message": "${escape(commit56[fTitle])}\\n\\nNo line like: This reverts commit $revertedCommitHash.\\nChange-Id: I89b88c3d9f7c743fc340ee73a45c3f57059bcf30\\nNo review line either\\n\\n"
    }
''';

String relandCommitJson(String relandLine) => '''
    {
      "commit": "$relandCommitHash",
      "parents": ["$commit56Hash"],
      "author": {
        "email": "${relandCommit[fAuthor]}"
      },
      "committer": {
        "time": "Mon Jan 13 06:16:00 2020 +0000"
      },
      "message": "${escape(relandCommit[fTitle])}\\n\\n$relandLine\\nChange-Id: I89b88c3d9f7c743fc340ee73a45c3f57059bcf30\\nReviewed-on: https://dart-review.googlesource.com/c/sdk/+/$relandReview\\n\\n"
    }
''';

String relandAsRevert = "This reverts commit $revertCommitHash.";

String relandAsReland = "This is a reland of $revertedCommitHash";
