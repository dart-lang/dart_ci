// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:builder/src/firestore.dart';
import 'package:test/test.dart';

import 'package:builder/src/result.dart';
import 'fakes.dart';
import 'test_data.dart';

void main() async {
  test('Base builder test', () async {
    final builderTest = BuilderTest(landedCommitChange);
    await builderTest.update();
  });

  test('Get info for already saved commit', () async {
    final builderTest = BuilderTest(existingCommitChange);
    await builderTest.storeBuildCommitsInfo();
    expect(builderTest.builder.endIndex, existingCommitIndex);
    expect(builderTest.builder.startIndex, previousCommitIndex + 1);
  });

  test('Link landed commit to review', () async {
    final builderTest = BuilderTest(landedCommitChange);
    builderTest.firestore.commits
        .removeWhere((key, value) => value[fIndex] > existingCommitIndex);
    builderTest.client.addDefaultResponse(gitilesLog);
    await builderTest.storeBuildCommitsInfo();
    await builderTest.builder.reviewsFetched;
    expect(builderTest.builder.endIndex, landedCommitIndex);
    expect(builderTest.builder.startIndex, existingCommitIndex + 1);
    expect(builderTest.builder.tryApprovals,
        {testResult(review44445Result): 54, testResult(review77779Result): 53});
    expect((await builderTest.firestore.getCommit(commit53Hash))!.toJson(),
        commit53);
    expect((await builderTest.firestore.getCommit(landedCommitHash))!.toJson(),
        landedCommit);
  });

  test('update previous active result', () async {
    final builderTest = BuilderTest(landedCommitChange);
    await builderTest.storeBuildCommitsInfo();
    await builderTest.storeChange(landedCommitChange);
    expect(builderTest.builder.success, true);
    expect(
        builderTest.firestore.results['activeResultID'],
        Map.from(activeResult)
          ..[fActiveConfigurations] = ['another configuration']);

    final changeAnotherConfiguration =
        Map<String, dynamic>.from(landedCommitChange)
          ..['configuration'] = 'another configuration';
    await builderTest.storeChange(changeAnotherConfiguration);
    expect(builderTest.builder.success, true);
    expect(
        builderTest.firestore.results['activeResultID'],
        Map.from(activeResult)
          ..remove(fActiveConfigurations)
          ..remove(fActive));
    expect(builderTest.builder.countApprovalsCopied, 1);
    expect(builderTest.builder.countChanges, 2);
    expect(
        builderTest.firestore.results[await builderTest.firestore.findResult(
            landedCommitChange, landedCommitIndex, landedCommitIndex)],
        landedResult);
    final result = (await builderTest.firestore.findActiveResults(
            landedCommitChange['name'], landedCommitChange['configuration']))
        .single;
    expect(untagMap(result.fields), landedResult);
  });

  test('mark active result flaky', () async {
    final builderTest = BuilderTest(landedCommitChange);
    await builderTest.storeBuildCommitsInfo();
    final flakyChange = Map<String, dynamic>.from(landedCommitChange)
      ..[fPreviousResult] = 'RuntimeError'
      ..[fFlaky] = true;
    expect(flakyChange[fResult], 'RuntimeError');
    await builderTest.storeChange(flakyChange);
    expect(flakyChange[fResult], 'flaky');
    expect(builderTest.builder.success, true);
    expect(
        builderTest.firestore.results['activeResultID'],
        Map.from(activeResult)
          ..[fActiveConfigurations] = ['another configuration']);

    expect(builderTest.builder.countChanges, 1);
    expect(
        builderTest.firestore.results[await builderTest.firestore
            .findResult(flakyChange, landedCommitIndex, landedCommitIndex)],
        flakyResult);
  });
}
