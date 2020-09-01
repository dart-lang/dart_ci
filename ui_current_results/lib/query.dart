// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'src/generated/query.pb.dart';
import 'filter.dart';

const String apiHost = 'current-results-rest-zlujsyuhha-uc.a.run.app';
// Current endpoints proxy is limited to 1 MB response size,
// so we limit results fetched to 4000.
// Implement paging on the service in the future to remove this limit.
const int fetchLimit = 4000;
const int maxFetchedResults = 100 * fetchLimit;

class QueryResults extends ChangeNotifier {
  Filter filter;
  bool showAll = true;
  List<String> names = [];
  Map<String, Map<String, int>> counts = {};
  Map<String, Map<ChangeInResult, List<Result>>> grouped = {};
  bool partialResults = true;

  GetResultsResponse resultsObject = GetResultsResponse.create();

  void fetchCurrentResults() async {
    final client = http.Client();
    final resultsQuery = Uri.https(apiHost, 'v1/results',
        {'filter': filter.terms.join(','), 'pageSize': '$fetchLimit'});
    final resultsResponse = await client.get(resultsQuery);
    resultsObject = GetResultsResponse.create()
      ..mergeFromProto3Json(json.decode(resultsResponse.body));
    final results = resultsObject.results;

    for (final result in results) {
      grouped
          .putIfAbsent(result.name, () => <ChangeInResult, List<Result>>{})
          .putIfAbsent(ChangeInResult(result), () => <Result>[])
          .add(result);
    }
    for (final name in grouped.keys) {
      final count = counts[name] = <String, int>{};
      for (final change in grouped[name].keys) {
        count.putIfAbsent(change.kind, () => 0);
        count[change.kind] += grouped[name][change].length;
      }
    }
    names = grouped.keys.toList()..sort();
    partialResults = results.length == fetchLimit;
    notifyListeners();
  }
}

class ChangeInResult {
  final String result;
  final String expected;
  final bool flaky;
  final String text;
  bool get matches => result == expected;
  String get kind => flaky ? 'flaky' : matches ? 'pass' : 'fail';

  ChangeInResult(Result result)
      : this._(result.result, result.expected, result.flaky);

  ChangeInResult._(this.result, this.expected, this.flaky)
      : text = flaky
            ? "flaky (latest result $result expected $expected"
            : "$result (expected $expected)";

  @override
  String toString() => text;
  @override
  bool operator ==(Object other) => text == (other as ChangeInResult)?.text;
  @override
  int get hashCode => text.hashCode;
}

String resultAsCommaSeparated(Result result) => [
      result.name,
      result.configuration,
      result.result,
      result.expected,
      result.flaky,
      result.timeMs
    ].join(',');

String resultTextHeader = "name,configuration,result,expected,flaky,timeMs";
