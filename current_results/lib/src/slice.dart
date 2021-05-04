// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:math';

import 'package:collection/collection.dart';

import 'package:current_results/src/result.dart';
import 'package:current_results/src/generated/query.pb.dart' as query_api;
import 'package:current_results/src/generated/result.pb.dart' as api;
import 'package:current_results/src/iterable.dart';

const maximumAge = Duration(days: 7);

int compareNames(Result a, Result b) => a.name.compareTo(b.name);

/// All result names before or starting with [prefix] are "before" prefix.
int isAfterPrefix(Result a, Result prefix) {
  if (a.name.startsWith(prefix.name)) return -1;
  return compareNames(a, prefix);
}

/// Returns the range from [sorted] of Result entries that are at or after
/// [startResult] and begin with [prefixResult].
Iterable<Result> getResultRange(
    List<Result> sorted, Result startResult, Result prefixResult) {
  var start = lowerBound<Result>(sorted, startResult, compare: compareNames);
  if (start >= sorted.length) return [];
  if (!sorted[start].name.startsWith(prefixResult.name)) return [];
  var end = start + 1;
  if (end < sorted.length && sorted[end].name.startsWith(prefixResult.name)) {
    end = lowerBound<Result>(sorted, prefixResult, compare: isAfterPrefix);
  }
  return sorted.getRange(start, end);
}

/// Holds the test results for all configurations.
/// Answers queries about the test results.
/// Used for holding the current test results in memory.
/// Can also be used to hold a snapshot of results data at a past time.
class Slice {
  /// The current results, stored separately for each configuration in a
  /// list sorted by test name.
  final _stored = <String, List<Result>>{};

  /// The date on which the current results of a configuration were fetched
  final _lastFetched = <String, DateTime>{};

  /// A sorted list of all test names seen. Names are not removed from this list.
  List<String> testNames = [];
  int _size = 0;

  int get size => _size;

  void add(List<String> lines) {
    if (lines.isEmpty) return;
    final results = lines.map((line) => Result.fromApi(api.Result()
      ..mergeFromProto3Json(json.decode(line),
          supportNamesWithUnderscores: true)));
    final configuration = results.first.configuration;
    if (results.any((result) => result.configuration != configuration)) {
      print('Loaded results list with multiple configurations: '
          'first result: ${results.first}');
      return;
    }
    final sorted = results.toList()..sort(compareNames);
    _size -= _stored[configuration]?.length ?? 0;
    _stored[configuration] = sorted;
    _lastFetched[configuration] = DateTime.now();
    _size += sorted.length;
    print('latest results of $configuration: ${sorted.length} results '
        '(total: $_size)');
  }

  void collectTestNames() {
    testNames.clear();
    for (final results in _stored.values) {
      testNames = _mergeIfNeeded(testNames, results);
    }
  }

  static List<String> _mergeIfNeeded(List<String> names, List<Result> sorted) {
    var i = 0;
    var j = 0;
    while (i < names.length && j < sorted.length) {
      final compare = names[i].compareTo(sorted[j].name);
      if (compare < 0) {
        i++;
      } else if (compare == 0) {
        i++;
        j++;
      } else {
        break;
      }
    }
    if (j == sorted.length) return names;

    // J points to the first unfound element in sorted.
    // I points to the first element in names greater than the unfound name.
    final result = names.sublist(0, i);
    while (i < names.length && j < sorted.length) {
      final compare = names[i].compareTo(sorted[j].name);
      if (compare <= 0) {
        result.add(names[i++]);
        if (compare == 0) j++;
      } else {
        result.add(sorted[j++].name);
      }
    }
    if (i < names.length) {
      result.addAll(names.getRange(i, names.length));
    }
    while (j < sorted.length) {
      result.add(sorted[j++].name);
    }
    return result;
  }

  query_api.GetResultsResponse results(query_api.GetResultsRequest query) {
    final response = query_api.GetResultsResponse();
    final limit = min(100000, query.pageSize == 0 ? 100000 : query.pageSize);
    final pageStart =
        query.pageToken.isEmpty ? null : PageStart.parse(query.pageToken);
    final filterTerms =
        query.filter.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty);
    final configurationSet = <String>{};
    final testPrefixes = <String>[];
    for (final prefix in filterTerms) {
      final matchingConfigurations = _stored.keys
          .where((configuration) => configuration.startsWith(prefix));
      if (matchingConfigurations.isEmpty) {
        testPrefixes.add(prefix);
      } else {
        configurationSet.addAll(matchingConfigurations);
      }
    }
    testPrefixes.sort();
    for (var i = 0; i < testPrefixes.length; ++i) {
      while (i + 1 < testPrefixes.length &&
          testPrefixes[i + 1].startsWith(testPrefixes[i])) {
        testPrefixes.removeAt(i + 1);
      }
    }
    if (testPrefixes.isEmpty) {
      testPrefixes.add('');
    }
    final configurations =
        (configurationSet.isEmpty ? _stored.keys : configurationSet).toList()
          ..sort();

    for (final prefix in testPrefixes) {
      response.results.addAll(getSortedResults(
              prefix, configurations, pageStart,
              needed: limit - response.results.length)
          .map(Result.toApi));
      if (response.results.length == limit) {
        response.nextPageToken = PageStart(
                response.results.last.name, response.results.last.configuration)
            .encode();
        break;
      }
    }
    return response;
  }

  /// Returns up to [needed] results from the configurations in [configurations],
  /// with test names that start with [prefix], sorted by test name.
  /// If [pageStart] is not null, test names before pageStart.name are
  /// filtered out.
  List<Result> getSortedResults(
      String prefix, List<String> configurations, PageStart pageStart,
      {int needed}) {
    final prefixResult = Result.nameOnly(prefix);
    var startResult;
    if (pageStart == null || pageStart.test.compareTo(prefixResult.name) <= 0) {
      startResult = prefixResult;
    } else if (pageStart.test.startsWith(prefixResult.name)) {
      startResult = Result.nameOnly(pageStart.test);
    } else {
      return [];
    }

    var results = <Result>[];

    for (final configuration in configurations) {
      var configurationRange =
          getResultRange(_stored[configuration], startResult, prefixResult);

      if (configurationRange.isEmpty) continue;
      if (pageStart != null &&
          configurationRange.first.name == pageStart.test &&
          configuration.compareTo(pageStart.configuration) <= 0) {
        configurationRange = configurationRange.skip(1);
        if (configurationRange.isEmpty) continue;
      }
      if (results.isEmpty ||
          results.last.name.compareTo(configurationRange.first.name) <= 0) {
        // Optimization
        results.addAll(configurationRange.take(needed - results.length));
      } else {
        results =
            merge(results, configurationRange, (Result result) => result.name)
                .take(needed)
                .toList();
      }
    }
    return results;
  }

  query_api.ListTestsResponse listTests(query_api.ListTestsRequest query) {
    var limit = min(query.limit, 100000);
    if (limit == 0) limit = 20;
    final prefix = query.prefix;
    final response = query_api.ListTestsResponse();
    final start = lowerBound(testNames, prefix);
    final end = min(start + limit, testNames.length);
    for (final name in testNames.getRange(start, end)) {
      if (name.startsWith(prefix)) {
        response.names.add(name);
      } else {
        break;
      }
    }
    return response;
  }

  void dropResultsOlderThan(Duration maximumAge) {
    final now = DateTime.now();
    for (final configuration in _lastFetched.keys.toList()) {
      if (now.difference(_lastFetched[configuration]) > maximumAge) {
        _size -= _stored[configuration].length;
        _stored.remove(configuration);
        _lastFetched.remove(configuration);
      }
    }
  }
}

class PageStart {
  final String test;
  final String configuration;

  PageStart(this.test, this.configuration);

  factory PageStart.parse(String token) {
    final decoded = jsonDecode(ascii.decode(base64Decode(token)));
    return PageStart(decoded['test'], decoded['configuration']);
  }

  String encode() {
    return base64UrlEncode(ascii.encode(jsonEncode({
      'test': test,
      'configuration': configuration,
    })));
  }
}
