// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:collection/collection.dart';
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

    grouped = groupBy<Result, String>(results, (Result result) => result.name)
        .map((String name, List<Result> list) => MapEntry(name,
            groupBy<Result, ChangeInResult>(list, ChangeInResult.fromResult)));
    names = grouped.keys.toList()..sort();
    partialResults = results.length == fetchLimit;
    notifyListeners();
  }
}

class ChangeInResult {
  static const Color lightCoral = Color.fromARGB(255, 240, 128, 128);
  static const Color gold = Color.fromARGB(255, 255, 215, 0);

  String result;
  String expected;
  bool flaky;
  bool get matches => result == expected;
  Color get backgroundColor =>
      flaky ? gold : matches ? Colors.lightGreen : lightCoral;

  ChangeInResult._(this.result, this.expected, this.flaky);
  static ChangeInResult fromResult(Result result) =>
      ChangeInResult._(result.result, result.expected, result.flaky);

  String toString() => flaky
      ? "flaky (latest result $result expected $expected"
      : "$result (expected $expected)";
  bool operator ==(Object other) => toString() == other.toString();
  int get hashCode => toString().hashCode;
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
