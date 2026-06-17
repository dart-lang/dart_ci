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
    builder = Build(
      BuildInfo.fromResult(ChangeRecord.fromMap(firstChange), <String>{firstChange[fConfiguration]}),
      commitsCache,
      firestore,
    );
  }

  Future<void> update() async {
    await storeBuildCommitsInfo();
  }

  Future<void> storeBuildCommitsInfo() async {
    await builder.storeBuildCommitsInfo();
    // Test expectations
  }

  Future<void> storeChange(Map<String, dynamic> change) async {
    final record = ChangeRecord.fromMap(change);
    await builder.storeChange(record);
    record.toJson().forEach((key, value) {
      if (change[key] != value) {
        change[key] = value;
      }
    });
  }
}

class FirestoreServiceFake implements FirestoreService {
  Map<String, Map<String, dynamic>> commits = Map.from(fakeFirestoreCommits);
  Map<String, Map<String, dynamic>> results = Map.from(fakeFirestoreResults);
  List<Map<String, dynamic>> fakeTryResults = List.from(
    fakeFirestoreTryResults,
  );
  int addedResultIdCounter = 1;

  @override
  bool get isStaging => false;

  @override
  void noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(invocation.memberName.toString());

  @override
  Future<CommitRecord?> getCommit(String hash) async {
    final commit = commits[hash];
    if (commit == null) {
      return null;
    }
    return CommitRecord.fromJson(hash, commits[hash]!);
  }

  @override
  Future<CommitRecord> getCommitByIndex(int? index) {
    for (final entry in commits.entries) {
      if (entry.value[fIndex] == index) {
        return Future.value(CommitRecord.fromJson(entry.key, entry.value));
      }
    }
    throw 'No commit found with index $index';
  }

  @override
  Future<CommitRecord> getLastCommit() => getCommitByIndex(
    commits.values.map<int>((commit) => commit[fIndex]).reduce(max),
  );

  @override
  Future<void> addCommit(String id, Map<String, dynamic> data) async {
    commits[id] = data..[fHash] = id;
  }

  @override
  Future<String?> findResult(
    ResultRecord change,
    int startIndex,
    int endIndex,
  ) {
    String? resultId;
    int? resultEndIndex;
    for (final entry in results.entries) {
      final result = entry.value;
      if (result[fName] == change.testName &&
          result[fResult] == change.result &&
          result[fExpected] == change.expected &&
          result[fPreviousResult] == change.previousResult &&
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
  Future<List<ResultRecord>> findActiveResults(
    String? name,
    String? configuration,
  ) async {
    return [
      for (final id in results.keys)
        if (results[id]![fName] == name &&
            results[id]![fActiveConfigurations] != null &&
            results[id]![fActiveConfigurations].contains(configuration))
          ResultRecord(Document()
            ..fields = taggedMap(Map.from(results[id]!))
            ..name = id),
    ];
  }

  @override
  Future<Document> storeResult(ResultRecord result) async {
    final id = 'resultDocumentID$addedResultIdCounter';
    addedResultIdCounter++;
    results[id] = result.toJson();
    return Document()
      ..fields = result.doc.fields
      ..name = id;
  }

  @override
  Future<bool> updateResult(
    String resultId,
    String? configuration,
    int startIndex,
    int endIndex, {
    required bool failure,
  }) {
    final result = Map<String, dynamic>.from(results[resultId]!);

    result[fBlamelistStartIndex] = max<int>(
      startIndex,
      result[fBlamelistStartIndex],
    );

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
    ResultRecord activeResult,
    String? configuration,
  ) async {
    final result = Map<String, dynamic>.from(results[activeResult.doc.name]!);
    result[fActiveConfigurations] = List.from(result[fActiveConfigurations])
      ..remove(configuration);
    if (result[fActiveConfigurations].isEmpty) {
      result.remove(fActiveConfigurations);
      result.remove(fActive);
    }
    results[activeResult.doc.name!] = result;
  }

  @override
  Future<List<ResultRecord>> findRevertedChanges(int index) async {
    return results.entries
        .where(
          (entry) {
            final change = entry.value;
            return change[fPinnedIndex] == index ||
                (change[fBlamelistStartIndex] == index &&
                    change[fBlamelistEndIndex] == index);
          },
        )
        .map((entry) => ResultRecord(Document()
          ..fields = taggedMap(entry.value)
          ..name = entry.key))
        .toList();
  }

  @override
  Future<List<TryResultRecord>> tryApprovals(int review) async {
    return fakeTryResults
        .where(
          (result) => result[fReview] == review && result[fApproved] == true,
        )
        .map(taggedMap)
        .map(
          (fields) => TryResultRecord(Document()
            ..fields = fields
            ..name = 'projects/dummy/databases/(default)/documents/try_results/dummy'),
        )
        .toList();
  }

  @override
  Future<List<TryResultRecord>> tryResults(
    int review,
    String configuration,
  ) async {
    return fakeTryResults
        .where(
          (result) =>
              result[fReview] == review &&
              result[fConfigurations].contains(configuration),
        )
        .map(taggedMap)
        .map(
          (fields) => TryResultRecord(Document()
            ..fields = fields
            ..name = 'projects/dummy/databases/(default)/documents/try_results/dummy'),
        )
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
  Future<void> storePatchset(
    String review,
    int patchset,
    String kind,
    String? description,
    int patchsetGroup,
    int number,
  ) async {}
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
