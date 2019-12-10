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

    final builder =
        Build(existingCommitHash, existingCommitChange, firestore, client);
    await builder.storeBuildCommitsInfo();
    expect(builder.endIndex, existingCommit['index']);
    expect(builder.startIndex, previousCommit['index'] + 1);
    verifyInOrder([
      firestore.getCommit(existingCommitHash),
      firestore.getCommit(previousCommitHash)
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
    when(firestore.getLastCommit()).thenAnswer(
        (_) => Future(() => {...existingCommit, 'id': existingCommitHash}));
    when(firestore.tryApprovals(44445)).thenAnswer((_) => Future(() =>
        tryjobResults
            .where((result) => result['review'] == 44445)
            .where((result) => result['approved'] == true)
            .toList()));
    when(firestore.reviewIsLanded(any)).thenAnswer((_) => Future.value(true));

    when(client.get(any))
        .thenAnswer((_) => Future(() => ResponseFake(gitilesLog)));

    final builder =
        Build(landedCommitHash, landedCommitChange, firestore, client);
    await builder.storeBuildCommitsInfo();
    expect(builder.endIndex, landedCommit['index']);
    expect(builder.startIndex, existingCommit['index'] + 1);
    expect(builder.tryApprovals, {testResult(tryjobResults[0])});
    verifyInOrder([
      verify(firestore.getCommit(landedCommitHash)).called(2),
      verify(firestore.getLastCommit()),
      verify(firestore.addCommit(gitLogCommitHash, {
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
      verify(firestore.getCommit(existingCommitHash))
    ]);
  });

  test("copy approvals from try results", () async {
    final firestore = FirestoreServiceMock();
    final client = HttpClientMock();
    when(firestore.getCommit(existingCommitHash))
        .thenAnswer((_) => Future.value(existingCommit));
    when(firestore.getCommit(landedCommitHash))
        .thenAnswer((_) => Future.value(landedCommit));
    when(firestore.tryApprovals(44445)).thenAnswer((_) => Future(() =>
        tryjobResults
            .where((result) => result['review'] == 44445)
            .where((result) => result['approved'] == true)
            .toList()));

    final builder =
        Build(landedCommitHash, landedCommitChange, firestore, client);
    await builder.process([landedCommitChange]);

    verifyZeroInteractions(client);
    verifyInOrder([
      verify(firestore.updateConfiguration(
          "dart2js-new-rti-linux-x64-d8", "dart2js-rti-linux-x64-d8")),
      verify(firestore.storeChange(any, 53, 54, approved: true))
    ]);
  });
}
