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
    final builderTest = BuilderTest(ChangeRecord.fromMap(landedCommitChange));
    await builderTest.update();
  });

  test('Get info for already saved commit', () async {
    final builderTest = BuilderTest(ChangeRecord.fromMap(existingCommitChange));
    await builderTest.storeBuildCommitsInfo();
    expect(builderTest.builder.endIndex, existingCommitIndex);
    expect(builderTest.builder.startIndex, previousCommitIndex + 1);
  });

  test('Link landed commit to review', () async {
    final builderTest = BuilderTest(ChangeRecord.fromMap(landedCommitChange));
    builderTest.firestore.commits.removeWhere(
      (key, value) => value[fIndex] > existingCommitIndex,
    );
    builderTest.client.addDefaultResponse(gitilesLog);
    await builderTest.storeBuildCommitsInfo();
    await builderTest.builder.reviewsFetched;
    expect(builderTest.builder.endIndex, landedCommitIndex);
    expect(builderTest.builder.startIndex, existingCommitIndex + 1);
    expect(builderTest.builder.tryApprovals, {
      ResultRecord.fromMap(review44445Result).testResult: 54,
      ResultRecord.fromMap(review77779Result).testResult: 53,
    });
    expect(
      (await builderTest.firestore.getCommit(commit53Hash))!.toJson(),
      commit53,
    );
    expect(
      (await builderTest.firestore.getCommit(landedCommitHash))!.toJson(),
      landedCommit,
    );
  });

  test('update previous active result', () async {
    final landedRecord = ChangeRecord.fromMap(landedCommitChange);
    final builderTest = BuilderTest(landedRecord);
    await builderTest.storeBuildCommitsInfo();
    await builderTest.storeChange(landedRecord);
    expect(builderTest.builder.success, true);
    expect(
      builderTest.firestore.results['activeResultID'],
      Map.from(activeResult)
        ..[fActiveConfigurations] = ['another configuration'],
    );

    final changeAnotherConfiguration = ChangeRecord.fromMap(
      Map<String, dynamic>.from(landedCommitChange)
        ..['configuration'] = 'another configuration',
    );
    await builderTest.storeChange(changeAnotherConfiguration);
    expect(builderTest.builder.success, true);
    expect(
      builderTest.firestore.results['activeResultID'],
      Map.from(activeResult)
        ..remove(fActiveConfigurations)
        ..remove(fActive),
    );
    expect(builderTest.builder.countApprovalsCopied, 1);
    expect(builderTest.builder.countChanges, 2);
    expect(
      builderTest.firestore.results[await builderTest.firestore.findResult(
        landedRecord,
        landedCommitIndex,
        landedCommitIndex,
      )],
      landedResult,
    );
    final result = (await builderTest.firestore.findActiveResults(
      landedRecord.name,
      landedRecord.configuration,
    )).single;
    expect(untagMap(result.doc.fields!), landedResult);
  });

  test('mark active result flaky', () async {
    final landedRecord = ChangeRecord.fromMap(landedCommitChange);
    final builderTest = BuilderTest(landedRecord);
    await builderTest.storeBuildCommitsInfo();
    final flakyChange = ChangeRecord.fromMap(
      Map<String, dynamic>.from(landedCommitChange)
        ..[fPreviousResult] = 'RuntimeError'
        ..[fFlaky] = true,
    );
    expect(flakyChange.result, 'RuntimeError');
    await builderTest.storeChange(flakyChange);
    expect(flakyChange.result, 'flaky');
    expect(builderTest.builder.success, true);
    expect(
      builderTest.firestore.results['activeResultID'],
      Map.from(activeResult)
        ..[fActiveConfigurations] = ['another configuration'],
    );

    expect(builderTest.builder.countChanges, 1);
    expect(
      builderTest.firestore.results[await builderTest.firestore.findResult(
        flakyChange,
        landedCommitIndex,
        landedCommitIndex,
      )],
      flakyResult,
    );
  });
}
