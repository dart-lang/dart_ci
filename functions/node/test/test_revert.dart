// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Tests that check automatic approval of failures on a revert on the CI

import 'package:collection/collection.dart';
import 'package:http/http.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../builder.dart';
import '../firestore.dart';
import '../result.dart';
import 'test_data.dart';

Future<void> main() async {
  test("Base builder test", () async {
    final builderTest = BuilderTest(newCommitHash, newCommitChange);
    await builderTest.update();
  });

  test("Automatically approve expected failure on revert", () async {
    final builderTest = RevertBuilderTest(revertCommitHash, revertChange);
    await builderTest.update();
    await builderTest.storeChange(revertChange);
    expect(
        builderTest.firestore.results.values
            .where((result) => result[fBlamelistEndIndex] == 55)
            .single,
        revertResult);
  });
}

class BuilderTest {
  final client = HttpClientMock();
  final firestore = FirestoreServiceFake();
  Build builder;
  final String commitHash;
  final Map<String, dynamic> firstChange;

  BuilderTest(this.commitHash, this.firstChange) {
    builder = Build(commitHash, firstChange, null, firestore, client);
  }

  Future<void> storeBuildCommitsInfo() async {
    await builder.storeBuildCommitsInfo();
    // Test expectations
  }

  Future<void> storeChange(Map<String, dynamic> change) async {
    return builder.storeChange(change);
  }

  Future<void> update() async {
    await storeBuildCommitsInfo();
  }
}

class FirestoreServiceFake extends Fake implements FirestoreService {
  final Map<String, Map<String, dynamic>> commits =
      Map.from(fakeFirestoreCommits);
  final Map<String, Map<String, dynamic>> results =
      Map.from(fakeFirestoreResults);
  int _addedResultID = 0;

  Future<void> addCommit(String id, Map<String, dynamic> data) async {
    commits[id] = data;
  }

  Future<List<Map<String, dynamic>>> findActiveResults(
          Map<String, dynamic> change) =>
      Future.value([]);

  Future<String> findResult(
          Map<String, dynamic> change, int startIndex, int endIndex) =>
      Future.value(null);

  Future<List<Map<String, dynamic>>> findRevertedChanges(int index) =>
      Future.value(results.values
          .where((change) =>
              change[fPinnedIndex] == index ||
              (change[fBlamelistStartIndex] == index &&
                  change[fBlamelistEndIndex] == index))
          .toList());

  Future<Map<String, dynamic>> getCommit(String hash) =>
      Future.value(commits[hash]);

  Future<Map<String, dynamic>> getCommitByIndex(int index) =>
      Future.value(commits.values
          .firstWhere((commit) => commit[fIndex] == index, orElse: () => null));

  Future<Map<String, dynamic>> getLastCommit() =>
      Future.value(maxBy<Map<String, dynamic>, int>(
          commits.values, (commit) => commit[fIndex]));

  Future<void> storeResult(Map<String, dynamic> result) async {
    final id = 'resultDocumentID$_addedResultID';
    _addedResultID++;
    results[id] = result;
  }

  Future<List<Map<String, dynamic>>> tryApprovals(int review) =>
      Future.value([]);
}

class HttpClientMock extends Mock implements BaseClient {}

class ResponseFake extends Fake implements Response {
  String body;
  ResponseFake(this.body);
}

class RevertBuilderTest extends BuilderTest {
  RevertBuilderTest(String commitHash, Map<String, dynamic> firstChange)
      : super(commitHash, firstChange) {
    firestore.commits[revertCommitHash] = revertCommit;
    firestore.commits[revertedCommitHash] = revertedCommit;
    firestore.results['revertedResultID'] = revertedResult;
  }
}
