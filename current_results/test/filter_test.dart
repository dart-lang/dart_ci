// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:test/test.dart';

import 'package:current_results/src/generated/query.pb.dart' as query_api;
import 'package:current_results/src/result.dart' show Result;
import 'package:current_results/src/slice.dart' show Slice;

Slice makeTestSlice(Map<String, List<Map<String, dynamic>>> tests) {
  var slice = Slice();
  for (final configuration in tests.keys) {
    final lines = <String>[];
    for (final data in tests[configuration]) {
      if (!{'name', 'experiments'}.containsAll(data.keys)) {
        throw 'Invalid test data:\n$data';
      }
      final result = Result(data['name'], configuration, '12345678abc', 'Pass',
          false, 'Pass', Duration(milliseconds: 17), data['experiments'] ?? []);
      lines.add(jsonEncode(result.toMap()));
    }
    slice.add(lines);
  }
  return slice;
}

void filterTest(
    String name,

    /// See [makeTestSlice] for the format of the test data
    Map<String, List<Map<String, dynamic>>> testData,

    /// The query terms to use on the data
    Iterable<String> queryTerms,

    /// Maps configuration names to the list of test name that we expect to be
    /// returned from querying [testData] with [queryTerms].
    Map<String, Set<String>> expectedResults) {
  test(name, () {
    final slice = makeTestSlice(testData);
    final response = slice.results(query_api.GetResultsRequest()
      ..filter = queryTerms.join(',')
      ..pageToken = ''
      ..pageSize = 0);
    final actualResults = groupBy<query_api.Result, String>(
            response.results, (result) => result.configuration)
        .map((configuration, results) =>
            MapEntry(configuration, results.map((r) => r.name).toSet()));

    expect(actualResults, equals(expectedResults));
  });
}

/// Helper to create test data entries from strings of the form 'name' or
/// 'name-experiment1[, experiment2, ...]'.
List<Map<String, dynamic>> makeResults(List<String> descriptions) {
  return descriptions.map((description) {
    final parts = description.split('-');
    final name = parts[0];
    final experiments = parts.length == 2 ? parts[1].split(',') : [];
    return {
      'name': name,
      if (experiments.isNotEmpty) 'experiments': experiments,
    };
  }).toList();
}

void main() {
  filterTest('test name', {
    'c1': makeResults(['ta1', 'tb', 'ta2'])
  }, [
    'tb'
  ], {
    'c1': {'tb'}
  });
  filterTest('test name as prefix', {
    'ca1': makeResults(['ta1', 'tb', 'ta2']),
    'ca2': makeResults(['ta3']),
    'cb': makeResults(['tb2'])
  }, [
    'tb'
  ], {
    'ca1': {'tb'},
    'cb': {'tb2'}
  });
  filterTest('configuration name', {
    'c1': makeResults(['ta1']),
    'c2': makeResults(['ta2'])
  }, [
    'c2'
  ], {
    'c2': {'ta2'}
  });
  filterTest('configuration name as prefix', {
    'ca1': makeResults(['ta1', 'tb', 'ta2']),
    'ca2': makeResults(['ta3']),
    'cb': makeResults(['tb2'])
  }, [
    'ca'
  ], {
    'ca1': {'ta1', 'tb', 'ta2'},
    'ca2': {'ta3'}
  });
  filterTest('experiment', {
    'ca1': makeResults(['ta1', 'tb-e1', 'ta2']),
    'ca2': makeResults(['ta3']),
    'cb': makeResults(['tb2', 'tb3-e1'])
  }, [
    'experiment:e1'
  ], {
    'ca1': {'tb'},
    'cb': {'tb3'}
  });
  filterTest('experiment does not work as prefix', {
    'ca1': makeResults(['ta1', 'tb-e1', 'ta2']),
    'ca2': makeResults(['ta3']),
    'cb': makeResults(['tb2', 'tb3-e2'])
  }, [
    'experiment:e'
  ], {});
  filterTest('experiment narrows configuration', {
    'ca1': makeResults(['ta1', 'tb-e1', 'ta2']),
    'ca2': makeResults(['ta3']),
    'cb': makeResults(['tb2', 'tb3-e1'])
  }, [
    'ca',
    'experiment:e1'
  ], {
    'ca1': {'tb'}
  });
  filterTest('experiment narrows test', {
    'ca1': makeResults(['ta1', 'tb', 'ta2']),
    'ca2': makeResults(['ta3']),
    'cb': makeResults(['tb2-e2'])
  }, [
    'tb',
    'experiment:e2'
  ], {
    'cb': {'tb2'}
  });
  filterTest('experiment does not match configuration', {
    'c': makeResults(['ta'])
  }, [
    'experiment:c'
  ], {});
  filterTest('experiment does not match test', {
    'c': makeResults(['ta'])
  }, [
    'experiment:ta'
  ], {});
}
