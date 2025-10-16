// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../data/models/filter.dart';
import '../../../shared/generated/query.pb.dart';
import '../../../shared/widgets/results_widgets.dart';

const String apiHost = 'current-results-qvyo5rktwa-uc.a.run.app';
// Current endpoints proxy is limited to 1 MB response size,
// so we limit results fetched to 4000 per page.  Paging is implemented.
const int fetchLimit = 3000;
const int maxFetchedResults = 100 * fetchLimit;

abstract class QueryResultsBase extends ChangeNotifier {
  Filter _filter;
  StreamSubscription<Iterable<(ChangeInResult, Result)>>? _streamFetcher;
  bool get isDone => _streamFetcher == null;
  final bool supportsEmptyQuery;

  SplayTreeMap<String, Counts> counts = SplayTreeMap();
  SplayTreeMap<String, SplayTreeMap<ChangeInResult, List<Result>>> grouped =
      SplayTreeMap();
  TestCounts testCounts = TestCounts();
  Counts resultCounts = Counts();
  int fetchedResultsCount = 0;

  QueryResultsBase(
    this._filter, {
    bool fetchInitialResults = false,
    this.supportsEmptyQuery = false,
  }) {
    if (fetchInitialResults) {
      _fetchResults();
    }
  }

  bool get hasQuery => _filter.terms.isNotEmpty;

  List<String> get names => grouped.keys.toList();

  Filter get filter => _filter;

  set filter(Filter newFilter) {
    if (_filter != newFilter) {
      _filter = newFilter;
      Future.microtask(fetch);
    }
  }

  void fetch() {
    _streamFetcher?.cancel();
    _streamFetcher = null;
    counts.clear();
    grouped.clear();
    testCounts = TestCounts();
    resultCounts = Counts();
    fetchedResultsCount = 0;
    notifyListeners();
    if (hasQuery || supportsEmptyQuery) {
      _fetchResults();
    }
  }

  void _fetchResults() {
    _streamFetcher = createResultsStream().listen(
      _processResults,
      onDone: () {
        _streamFetcher = null;
        notifyListeners();
      },
    );
  }

  @visibleForOverriding
  Stream<Iterable<(ChangeInResult, Result)>> createResultsStream();

  void _processResults(Iterable<(ChangeInResult, Result)> results) {
    for (final (change, result) in results) {
      grouped
          .putIfAbsent(result.name, SplayTreeMap.new)
          .putIfAbsent(change, () => [])
          .add(result);
      counts.putIfAbsent(result.name, () => Counts()).addResult(change, result);
      testCounts.addResult(change, result);
      resultCounts.addResult(change, result);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _streamFetcher?.cancel();
    super.dispose();
  }
}

class QueryResults extends QueryResultsBase {
  final http.Client _client;

  QueryResults(super.filter, {http.Client? client})
    : _client = client ?? http.Client();

  @override
  Stream<Iterable<(ChangeInResult, Result)>> createResultsStream() {
    return _streamPagedResults().transform(
      StreamTransformer.fromHandlers(
        handleData: (response, sink) {
          fetchedResultsCount += response.results.length;
          sink.add(
            response.results.map((result) => (ChangeInResult(result), result)),
          );
          if (fetchedResultsCount >= maxFetchedResults) {
            sink.close();
          }
        },
      ),
    );
  }

  Stream<GetResultsResponse> _streamPagedResults() async* {
    var pageToken = '';
    do {
      final resultsQuery = Uri.https(apiHost, 'v1/results', {
        'filter': filter.terms.join(','),
        'pageSize': '$fetchLimit',
        'pageToken': pageToken,
      });
      final response = await _client.get(resultsQuery);
      final results = GetResultsResponse.create()
        ..mergeFromProto3Json(json.decode(response.body));
      yield results;
      pageToken = results.nextPageToken;
    } while (pageToken.isNotEmpty);
  }
}

class ChangeInResult implements Comparable<ChangeInResult> {
  static final _cache = <String, ChangeInResult>{};

  final bool matches;
  final bool flaky;
  final String text;

  ResultKind get kind => flaky
      ? ResultKind.flaky
      : matches
      ? ResultKind.pass
      : ResultKind.fail;

  factory ChangeInResult(Result result) {
    return ChangeInResult.create(
      result: result.result,
      expected: result.expected,
      isFlaky: result.flaky,
    );
  }

  factory ChangeInResult.create({
    required String result,
    required String expected,
    required bool isFlaky,
    String? previousResult,
  }) {
    final bool matches = result == expected;
    final String text;

    if (isFlaky) {
      text = 'flaky (latest result $result expected $expected)';
    } else {
      final String resultText = matches
          ? result
          : '$result (expected $expected)';

      if (previousResult != null) {
        if (previousResult.isNotEmpty) {
          text = previousResult == result
              ? resultText
              : '$previousResult -> $resultText';
        } else {
          text = 'new test => $resultText';
        }
      } else {
        text = resultText;
      }
    }

    return _cache.putIfAbsent(
      text,
      () => ChangeInResult._(text, matches, isFlaky),
    );
  }

  ChangeInResult._(this.text, this.matches, this.flaky);

  @override
  String toString() => text;

  @override
  bool operator ==(Object other) =>
      other is ChangeInResult && text == other.text;

  @override
  int get hashCode => text.hashCode;

  @override
  int compareTo(ChangeInResult other) {
    if (matches != other.matches) {
      return matches ? 1 : -1;
    }

    if (flaky != other.flaky) {
      return flaky ? -1 : 1;
    }
    return text.compareTo(other.text);
  }
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
