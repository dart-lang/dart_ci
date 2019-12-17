// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:http/http.dart';

import '../builder.dart';
import '../firestore.dart';
import 'test_data.dart';

class FirestoreServiceMock extends Mock implements FirestoreService {}

class HttpClientMock extends Mock implements BaseClient {}

class ResponseFake extends Fake implements Response {
  String body;
  ResponseFake(this.body);
}

void main() async {
  test("Store already existing commit", () async {
    final client = HttpClientMock();
    final firestore = FirestoreServiceMock();
    when(firestore.getCommit(existingCommitHash))
        .thenAnswer((_) => Future.value(existingCommit));
    when(firestore.getCommit(previousCommitHash))
        .thenAnswer((_) => Future.value(previousCommit));
    when(firestore.getCommitByIndex(any))
        .thenAnswer((_) => Future.value(commit53));
    when(firestore.tryApprovals(77779)).thenAnswer((_) => Future(() =>
        tryjobResults
            .where((result) => result['review'] == 77779)
            .where((result) => result['approved'] == true)
            .toList()));

    final builder = Build(
        existingCommitHash, existingCommitChange, null, firestore, client);
    await builder.storeBuildCommitsInfo();
    expect(builder.endIndex, existingCommit['index']);
    expect(builder.startIndex, previousCommit['index'] + 1);
    verifyInOrder([
      firestore.getCommit(existingCommitHash),
      firestore.getCommit(previousCommitHash),
      firestore.getCommitByIndex(50),
      firestore.tryApprovals(77779),
      firestore.getCommitByIndex(51),
      firestore.tryApprovals(77779),
    ]);
    verifyNoMoreInteractions(firestore);
    verifyZeroInteractions(client);
  });

  test("Link landed commit to review", () async {
    final client = HttpClientMock();
    final firestore = FirestoreServiceMock();
    when(firestore.getCommit(existingCommitHash))
        .thenAnswer((_) => Future.value(existingCommit));
    final landedResponses = [null, landedCommit];
    when(firestore.getCommit(landedCommitHash))
        .thenAnswer((_) => Future(() => landedResponses.removeAt(0)));
    when(firestore.getCommitByIndex(53))
        .thenAnswer((_) => Future.value(commit53));
    when(firestore.getLastCommit()).thenAnswer(
        (_) => Future(() => {...existingCommit, 'id': existingCommitHash}));
    when(firestore.tryApprovals(44445)).thenAnswer((_) => Future(() =>
        tryjobResults
            .where((result) => result['review'] == 44445)
            .where((result) => result['approved'])
            .toList()));
    when(firestore.tryApprovals(77779)).thenAnswer((_) => Future(() =>
        tryjobResults
            .where((result) => result['review'] == 77779)
            .where((result) => result['approved'])
            .toList()));
    when(firestore.reviewIsLanded(any)).thenAnswer((_) => Future.value(true));

    when(client.get(any))
        .thenAnswer((_) => Future(() => ResponseFake(gitilesLog)));

    final builder =
        Build(landedCommitHash, landedCommitChange, null, firestore, client);
    await builder.storeBuildCommitsInfo();
    expect(builder.endIndex, landedCommit['index']);
    expect(builder.startIndex, existingCommit['index'] + 1);
    expect(builder.tryApprovals,
        {testResult(tryjobResults[0]), testResult(tryjobResults[1])});
    verifyInOrder([
      verify(firestore.getCommit(landedCommitHash)).called(2),
      verify(firestore.getLastCommit()),
      verify(firestore.addCommit(commit53Hash, {
        'author': 'user@example.com',
        'created': DateTime.parse('2019-11-28 12:07:55 +0000'),
        'index': 53,
        'title': 'A commit on the git log',
        'review': 77779
      })),
      verify(firestore.reviewIsLanded(77779)),
      verify(firestore.addCommit(landedCommitHash, {
        'author': 'gerrit_user@example.com',
        'created': DateTime.parse('2019-11-29 15:15:00 +0000'),
        'index': 54,
        'title': 'A commit used for testing tryjob approvals, with index 54',
        'review': 44445
      })),
      verify(firestore.reviewIsLanded(44445)),
      // We want to verify firestore.getCommit(landedCommitHash) here,
      // but it is already matched by the earlier check for the same call.
      verify(firestore.getCommit(existingCommitHash)),
      verify(firestore.tryApprovals(44445)),
      verify(firestore.getCommitByIndex(53)),
      verify(firestore.tryApprovals(77779))
    ]);
    verifyNoMoreInteractions(firestore);
  });

  test("copy approvals from try results", () async {
    final firestore = FirestoreServiceMock();
    final client = HttpClientMock();
    when(firestore.getCommit(existingCommitHash))
        .thenAnswer((_) => Future.value(existingCommit));
    when(firestore.getCommit(landedCommitHash))
        .thenAnswer((_) => Future.value(landedCommit));
    when(firestore.getCommitByIndex(53))
        .thenAnswer((_) => Future.value(commit53));
    when(firestore.tryApprovals(44445)).thenAnswer((_) => Future(() =>
        tryjobResults
            .where((result) => result['review'] == 44445)
            .where((result) => result['approved'] == true)
            .toList()));
    when(firestore.tryApprovals(77779)).thenAnswer((_) => Future(() =>
        tryjobResults
            .where((result) => result['review'] == 77779)
            .where((result) => result['approved'] == true)
            .toList()));

    final builder =
        Build(landedCommitHash, landedCommitChange, null, firestore, client);
    await builder.process([landedCommitChange]);

    verifyZeroInteractions(client);
    verifyInOrder([
      firestore.updateConfiguration(
          "dart2js-new-rti-linux-x64-d8", "dart2js-rti-linux-x64-d8"),
      firestore.findResult(any, 53, 54),
      firestore.storeResult(any, 53, 54,
          approved: argThat(isTrue, named: 'approved'),
          failure: argThat(isTrue, named: 'failure'))
    ]);
  });

  test("update previous active result", () async {
    final activeResult = {
      'blamelist_end_index': 52,
      'configurations': [
        landedCommitChange['configuration'],
        'another configuration'
      ],
      'active_configurations': [
        landedCommitChange['configuration'],
        'another configuration'
      ],
      'active': true
    };

    final firestore = FirestoreServiceMock();
    final client = HttpClientMock();

    when(firestore.findActiveResult(any))
        .thenAnswer((_) => Future.value(activeResult));

    final builder =
        Build(landedCommitHash, landedCommitChange, null, firestore, client);
    builder.startIndex = 53;
    builder.endIndex = 54;

    await builder.storeChange(landedCommitChange);

    expect(builder.countApprovalsCopied, 0);
    expect(builder.countChanges, 1);
    expect(builder.success, false);
    verifyZeroInteractions(client);
    verifyInOrder([
      firestore.findResult(any, 53, 54),
      firestore.findActiveResult(landedCommitChange),
      firestore.storeResult(any, 53, 54,
          approved: argThat(isFalse, named: 'approved'),
          failure: argThat(isTrue, named: 'failure')),
      firestore.updateActiveResult(
          activeResult, landedCommitChange['configuration'])
    ]);
  });
}
