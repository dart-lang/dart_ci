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
  test('Base builder test', () async {
    final builderTest = BuilderTest(landedCommitHash, landedCommitChange);
    await builderTest.update();
  });

  test('fetch commit that is a revert', () async {
    final builderTest = BuilderTest(revertCommitHash, revertUnchangedChange);
    builderTest.firestore.commits.remove(revertCommitHash);
    when(builderTest.client.get(any))
        .thenAnswer((_) => Future(() => ResponseFake(revertGitilesLog)));
    await builderTest.storeBuildCommitsInfo();
    expect(builderTest.builder.endIndex, revertCommit['index']);
    expect(builderTest.builder.startIndex, landedCommit['index'] + 1);
    expect(await builderTest.builder.firestore.getCommit(revertCommitHash),
        revertCommit);
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

  const String commit56Hash = 'commit 56 hash';
  Map<String, dynamic> commit56 = Map.unmodifiable({
    'author': 'gerrit_revert_user@example.com',
    'created': DateTime.parse('2019-11-29 16:15:00Z'),
    'index': revertIndex + 1,
    'title': 'A commit with index 56',
    'hash': commit56Hash,
    'review': 99999,
  });
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

  test('Revert in blamelist, doesn\'t match new failure', () async {
    final builderTest =
        RevertBuilderTest(commit56Hash, commit56UnmatchingChange);
    builderTest.firestore.commits[commit56Hash] = commit56;
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
    firestore.results.remove('revertResultID');
  }
}
