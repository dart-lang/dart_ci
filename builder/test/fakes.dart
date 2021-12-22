// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:math';

import 'package:googleapis/firestore/v1.dart';
import 'package:http/http.dart';

import 'package:builder/src/builder.dart';
import 'package:builder/src/commits_cache.dart';
import 'package:builder/src/firestore.dart';
import 'package:builder/src/result.dart';
import 'test_data.dart';

class BuilderTest {
  final client = HttpClientMock();
  final firestore = FirestoreServiceFake();
  late CommitsCache commitsCache;
  late Build builder;
  Map<String, dynamic> firstChange;

  BuilderTest(this.firstChange) {
    commitsCache = CommitsCache(firestore, client);
    builder = Build(BuildInfo.fromResult(firstChange), commitsCache, firestore);
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

class FirestoreServiceFake implements FirestoreService {
  Map<String, Map<String, dynamic>> commits = Map.from(fakeFirestoreCommits);
  Map<String, Map<String, dynamic>> results = Map.from(fakeFirestoreResults);
  List<Map<String, dynamic>> fakeTryResults =
      List.from(fakeFirestoreTryResults);
  int addedResultIdCounter = 1;

  @override
  Future<bool> isStaging() async => false;

  @override
  void noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(invocation.memberName.toString());

  @override
  Future<Commit?> getCommit(String hash) async {
    final commit = commits[hash];
    if (commit == null) {
      return null;
    }
    return Commit.fromJson(hash, commits[hash]!);
  }

  @override
  Future<Commit> getCommitByIndex(int? index) {
    for (final entry in commits.entries) {
      if (entry.value[fIndex] == index) {
        return Future.value(Commit.fromJson(entry.key, entry.value));
      }
    }
    throw 'No commit found with index $index';
  }

  @override
  Future<Commit> getLastCommit() => getCommitByIndex(
      commits.values.map<int>((commit) => commit[fIndex]).reduce(max));

  @override
  Future<void> addCommit(String id, Map<String, dynamic> data) async {
    commits[id] = data..[fHash] = id;
  }

  @override
  Future<String?> findResult(
      Map<String, dynamic> change, int startIndex, int endIndex) {
    String? resultId;
    int? resultEndIndex;
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

  @override
  Future<List<SafeDocument>> findActiveResults(
      String? name, String? configuration) async {
    return [
      for (final id in results.keys)
        if (results[id]![fName] == name &&
            results[id]![fActiveConfigurations] != null &&
            results[id]![fActiveConfigurations].contains(configuration))
          SafeDocument(Document()
            ..fields = taggedMap(Map.from(results[id]!))
            ..name = id)
    ];
  }

  @override
  Future<Document> storeResult(Map<String, dynamic> result) async {
    final id = 'resultDocumentID$addedResultIdCounter';
    addedResultIdCounter++;
    results[id] = result;
    return Document()
      ..fields = taggedMap(result)
      ..name = id;
  }

  @override
  Future<bool> updateResult(
      String resultId, String? configuration, int startIndex, int endIndex,
      {required bool failure}) {
    final result = Map<String, dynamic>.from(results[resultId]!);

    result[fBlamelistStartIndex] =
        max<int>(startIndex, result[fBlamelistStartIndex]);

    result[fBlamelistEndIndex] = min<int>(endIndex, result[fBlamelistEndIndex]);
    if (!result[fConfigurations].contains(configuration)) {
      result[fConfigurations] = List<String?>.from(result[fConfigurations])
        ..add(configuration)
        ..sort();
    }
    if (failure) {
      result[fActive] = true;
      if (!result[fActiveConfigurations].contains(configuration)) {
        result[fActiveConfigurations] =
            List<String?>.from(result[fActiveConfigurations])
              ..add(configuration)
              ..sort();
      }
    }
    results[resultId] = result;
    return Future.value(result[fApproved] ?? false);
  }

  @override
  Future<void> removeActiveConfiguration(
      SafeDocument activeResult, String? configuration) async {
    final result = Map<String, dynamic>.from(results[activeResult.name]!);
    result[fActiveConfigurations] = List.from(result[fActiveConfigurations])
      ..remove(configuration);
    if (result[fActiveConfigurations].isEmpty) {
      result.remove(fActiveConfigurations);
      result.remove(fActive);
    }
    results[activeResult.name] = result;
  }

  @override
  Future<List<Map<String, Value>>> findRevertedChanges(int index) async {
    return results.values
        .where((change) =>
            change[fPinnedIndex] == index ||
            (change[fBlamelistStartIndex] == index &&
                change[fBlamelistEndIndex] == index))
        .map(taggedMap)
        .toList();
  }

  @override
  Future<List<SafeDocument>> tryApprovals(int review) async {
    return fakeTryResults
        .where(
            (result) => result[fReview] == review && result[fApproved] == true)
        .map(taggedMap)
        .map((fields) => SafeDocument(Document()
          ..fields = fields
          ..name = ''))
        .toList();
  }

  @override
  Future<List<SafeDocument>> tryResults(
      int review, String configuration) async {
    return fakeTryResults
        .where((result) =>
            result[fReview] == review &&
            result[fConfigurations].contains(configuration))
        .map(taggedMap)
        .map((fields) => SafeDocument(Document()
          ..fields = fields
          ..name = ''))
        .toList();
  }

  @override
  Future<bool> reviewIsLanded(int review) =>
      Future.value(commits.values.any((commit) => commit[fReview] == review));

  @override
  Future<bool> hasPatchset(String review, String patchset) async => false;

  @override
  Future<bool> hasReview(String review) async => false;

  @override
  Future<void> storeReview(String review, Map<String, Value> data) async {}

  @override
  Future<void> storePatchset(String review, int patchset, String kind,
      String? description, int patchsetGroup, int number) async {}
}

class HttpClientMock extends BaseClient {
  String body = '';

  void addDefaultResponse(String response) {
    body = response;
  }

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    return StreamedResponse(Stream.fromIterable([]), 200);
  }

  @override
  Future<Response> get(Uri uri, {Map<String, String>? headers}) async {
    return Response(body, 200);
  }
}
