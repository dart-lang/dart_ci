// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'src/generated/query.pb.dart';
import 'filter.dart';

const String apiHost = 'current-results-qvyo5rktwa-uc.a.run.app';
// Current endpoints proxy is limited to 1 MB response size,
// so we limit results fetched to 4000 per page.  Paging is implemented.
const int fetchLimit = 3000;
const int maxFetchedResults = 100 * fetchLimit;

class QueryResults extends ChangeNotifier {
  Filter filter = Filter('');
  StreamSubscription<GetResultsResponse>? fetcher;
  List<String> names = [];
  Map<String, Counts> counts = {};
  Map<String, Map<ChangeInResult, List<Result>>> grouped = {};
  TestCounts testCounts = TestCounts();
  Counts resultCounts = Counts();
  int fetchedResultsCount = 0;
  bool get noQuery => filter.terms.isEmpty;

  QueryResults();

  void fetch(Filter newFilter) {
    if (!filter.hasSameTerms(newFilter)) {
      filter = newFilter;
      fetchCurrentResults();
    }
  }

  @override
  void dispose() {
    fetcher?.cancel();
    super.dispose();
  }

  GetResultsResponse resultsObject = GetResultsResponse.create();

  void fetchCurrentResults() async {
    fetcher?.cancel();
    fetcher = null;
    names = [];
    counts = {};
    grouped = {};
    testCounts = TestCounts();
    resultCounts = Counts();
    fetchedResultsCount = 0;
    if (noQuery) return;
    fetcher = fetchResults(filter).listen(onResults, onDone: onDone);
  }

  void onResults(GetResultsResponse response) {
    final results = response.results;
    fetchedResultsCount += results.length;
    if (fetchedResultsCount >= maxFetchedResults) {
      fetcher?.cancel();
      fetcher = null;
    }
    for (final result in results) {
      final change = ChangeInResult(result);
      grouped
          .putIfAbsent(result.name, () => <ChangeInResult, List<Result>>{})
          .putIfAbsent(change, () => <Result>[])
          .add(result);
      counts.putIfAbsent(result.name, () => Counts()).addResult(change, result);
      testCounts.addResult(change, result);
      resultCounts.addResult(change, result);
    }
    names = grouped.keys.toList()..sort();
    notifyListeners();
  }

  void onDone() {
    fetcher = null;
  }
}

Stream<GetResultsResponse> fetchResults(Filter filter) async* {
  final client = http.Client();
  var pageToken = '';
  do {
    final resultsQuery = Uri.https(apiHost, 'v1/results', {
      'filter': filter.terms.join(','),
      'pageSize': '$fetchLimit',
      'pageToken': pageToken,
    });
    final response = await client.get(resultsQuery);
    final results = GetResultsResponse.create()
      ..mergeFromProto3Json(json.decode(response.body));
    yield results;
    pageToken = results.nextPageToken;
  } while (pageToken.isNotEmpty);
}

class ChangeInResult {
  final String result;
  final String expected;
  final bool flaky;
  final String text;

  bool get matches => result == expected;

  String get kind => flaky
      ? 'flaky'
      : matches
      ? 'pass'
      : 'fail';

  ChangeInResult(Result result)
    : this._(result.result, result.expected, result.flaky);

  ChangeInResult._(this.result, this.expected, this.flaky)
    : text = flaky
          ? "flaky (latest result $result expected $expected)"
          : "$result (expected $expected)";

  @override
  String toString() => text;

  @override
  bool operator ==(Object other) =>
      other is ChangeInResult && text == other.text;

  @override
  int get hashCode => text.hashCode;
}

String resultAsCommaSeparated(Result result) => [
  result.name,
  result.configuration,
  result.result,
  result.expected,
  result.flaky,
  result.timeMs,
  result.revision,
].join(',');

String resultTextHeader =
    "name,configuration,result,expected,flaky,timeMs,revision";

class Counts {
  int count = 0;
  int countFailing = 0;
  int countFlaky = 0;

  int get countPassing => count - countFailing - countFlaky;

  void addResult(ChangeInResult change, Result result) {
    count++;
    if (change.flaky) {
      countFlaky++;
    } else if (!change.matches) {
      countFailing++;
    }
  }
}

class TestCounts extends Counts {
  String currentTest = '';
  bool currentFailing = false;
  bool currentFlaky = false;

  @override
  void addResult(ChangeInResult change, Result result) {
    if (currentTest != result.name) {
      if (currentTest.compareTo(result.name) > 0) {
        print(
          'Results are not sorted by test name: '
          '$currentTest, ${result.name}',
        );
        return;
      }
      currentFlaky = false;
      currentFailing = false;
      currentTest = result.name;
      count++;
    }
    if (change.flaky) {
      if (!currentFlaky) {
        currentFlaky = true;
        countFlaky++;
      }
    } else if (!change.matches && !currentFailing) {
      currentFailing = true;
      countFailing++;
    }
  }
}
