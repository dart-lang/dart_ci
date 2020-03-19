// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

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

  test("Get info for already saved commit", () async {
    final builderTest = BuilderTest(existingCommitHash, existingCommitChange);
    await builderTest.storeBuildCommitsInfo();
    expect(builderTest.builder.endIndex, existingCommitIndex);
    expect(builderTest.builder.startIndex, previousCommitIndex + 1);
  });

  test("Link landed commit to review", () async {
    final builderTest = BuilderTest(landedCommitHash, landedCommitChange);
    builderTest.firestore.commits
        .removeWhere((key, value) => value[fIndex] > existingCommitIndex);
    when(builderTest.client.get(any))
        .thenAnswer((_) => Future(() => ResponseFake(gitilesLog)));
    await builderTest.storeBuildCommitsInfo();
    await builderTest.builder.fetchReviewsAndReverts();
    expect(builderTest.builder.endIndex, landedCommitIndex);
    expect(builderTest.builder.startIndex, existingCommitIndex + 1);
    expect(builderTest.builder.tryApprovals,
        {testResult(review44445Result): 54, testResult(review77779Result): 53});
    expect(await builderTest.firestore.getCommit(commit53Hash), commit53);
    expect(
        await builderTest.firestore.getCommit(landedCommitHash), landedCommit);
  });

  test("update previous active result", () async {
    final builderTest = BuilderTest(landedCommitHash, landedCommitChange);
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
    expect(builderTest.firestore.results['activeResultID'],
        Map.from(activeResult)..remove(fActiveConfigurations)..remove(fActive));
    expect(builderTest.builder.countApprovalsCopied, 1);
    expect(builderTest.builder.countChanges, 2);
    expect(
        builderTest.firestore.results[await builderTest.firestore.findResult(
            landedCommitChange, landedCommitIndex, landedCommitIndex)],
        landedResult);
    expect(
        (await builderTest.firestore.findActiveResults(landedCommitChange))
          ..single.remove('id'),
        [landedResult]);
  });
}
