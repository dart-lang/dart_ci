// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Tests that check automatic approval of failures on a revert on the CI

import 'dart:math';

import 'package:mockito/mockito.dart';
import 'package:http/http.dart';

import '../builder.dart';
import '../commits_cache.dart';
import '../firestore.dart';
import '../result.dart';
import 'test_data.dart';

class BuilderTest {
  final client = HttpClientMock();
  final firestore = FirestoreServiceFake();
  CommitsCache commitsCache;
  Build builder;
  String commitHash;
  Map<String, dynamic> firstChange;

  BuilderTest(this.commitHash, this.firstChange) {
    commitsCache = CommitsCache(firestore, client);
    builder = Build(commitHash, firstChange, null, commitsCache, firestore);
  }

  Future<void> update() async {
    await storeBuildCommitsInfo();
  }

  Future<void> storeBuildCommitsInfo() async {
    await builder.storeBuildCommitsInfo();
    // Test expectations
  }

  Future<void> storeChange(Map<String, dynamic> change) async {
    return builder.storeChange(change);
  }
}

class FirestoreServiceFake extends Fake implements FirestoreService {
  Map<String, Map<String, dynamic>> commits = Map.from(fakeFirestoreCommits);
  Map<String, Map<String, dynamic>> results = Map.from(fakeFirestoreResults);
  List<Map<String, dynamic>> fakeTryResults =
      List.from(fakeFirestoreTryResults);
  int addedResultIdCounter = 1;

  Future<Map<String, dynamic>> getCommit(String hash) =>
      Future.value(commits[hash]);

  Future<Map<String, dynamic>> getCommitByIndex(int index) {
    for (final entry in commits.entries) {
      if (entry.value[fIndex] == index) {
        return Future.value(entry.value);
      }
    }
    throw "No commit found with index $index";
  }

  Future<Map<String, dynamic>> getLastCommit() => getCommitByIndex(
      commits.values.map<int>((commit) => commit[fIndex]).reduce(max));

  Future<void> addCommit(String id, Map<String, dynamic> data) async {
    commits[id] = data..[fHash] = id;
  }

  Future<String> findResult(
      Map<String, dynamic> change, int startIndex, int endIndex) {
    var resultId;
    var resultEndIndex;
    for (final entry in results.entries) {
      final result = entry.value;
      if (result[fName] == change[fName] &&
          result[fResult] == change[fResult] &&
          result[fExpected] == change[fExpected] &&
          result[fPreviousResult] == change[fPreviousResult] &&
          result[fBlamelistEndIndex] >= startIndex &&
          result[fBlamelistStartIndex] <= endIndex) {
        if (resultEndIndex == null ||
            resultEndIndex < result[fBlamelistEndIndex]) {
          resultId = entry.key;
          resultEndIndex = result[fBlamelistEndIndex];
        }
      }
    }
    return Future.value(resultId);
  }

  Future<List<Map<String, dynamic>>> findActiveResults(
      Map<String, dynamic> change) async {
    return [
      for (final id in results.keys)
        if (results[id][fName] == change[fName] &&
            results[id][fActiveConfigurations] != null &&
            results[id][fActiveConfigurations]
                .contains(change['configuration']))
          Map.from(results[id])..['id'] = id
    ];
  }

  Future<void> storeResult(Map<String, dynamic> result) async {
    final id = 'resultDocumentID$addedResultIdCounter';
    addedResultIdCounter++;
    results[id] = result;
  }

  Future<bool> updateResult(
      String resultId, String configuration, int startIndex, int endIndex,
      {bool failure}) {
    final result = Map<String, dynamic>.from(results[resultId]);

    result[fBlamelistStartIndex] =
        max<int>(startIndex, result[fBlamelistStartIndex]);

    result[fBlamelistEndIndex] = min<int>(endIndex, result[fBlamelistEndIndex]);
    if (!result[fConfigurations].contains(configuration)) {
      result[fConfigurations] = List<String>.from(result[fConfigurations])
        ..add(configuration)
        ..sort();
    }
    if (failure) {
      result[fActive] = true;
      if (!result[fActiveConfigurations].contains(configuration)) {
        result[fActiveConfigurations] =
            List<String>.from(result[fActiveConfigurations])
              ..add(configuration)
              ..sort();
      }
    }
    results[resultId] = result;
    return Future.value(result[fApproved] ?? false);
  }

  Future<void> updateActiveResult(
      Map<String, dynamic> activeResult, String configuration) async {
    final result = Map<String, dynamic>.from(results[activeResult['id']]);
    result[fActiveConfigurations] = List.from(result[fActiveConfigurations])
      ..remove(configuration);
    if (result[fActiveConfigurations].isEmpty) {
      result.remove(fActiveConfigurations);
      result.remove(fActive);
    }
    results[activeResult['id']] = result;
  }

  Future<List<Map<String, dynamic>>> findRevertedChanges(int index) =>
      Future.value(results.values
          .where((change) =>
              change[fPinnedIndex] == index ||
              (change[fBlamelistStartIndex] == index &&
                  change[fBlamelistEndIndex] == index))
          .toList());

  Future<List<Map<String, dynamic>>> tryApprovals(int review) =>
      Future.value(fakeTryResults
          .where((result) =>
              result[fReview] == review && result[fApproved] == true)
          .toList());

  Future<List<Map<String, dynamic>>> tryResults(
          int review, String configuration) =>
      Future.value(fakeTryResults
          .where((result) =>
              result[fReview] == review &&
              result[fConfigurations].contains(configuration))
          .toList());

  Future<bool> reviewIsLanded(int review) =>
      Future.value(commits.values.any((commit) => commit[fReview] == review));
}

class HttpClientMock extends Mock implements BaseClient {}

class ResponseFake extends Fake implements Response {
  String body;
  ResponseFake(this.body);
}
