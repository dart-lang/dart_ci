// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter_current_results/src/data/models/filter.dart';
import 'package:flutter_current_results/src/data/services/results_service.dart';
import 'package:flutter_current_results/src/features/results_overview/data/results_repository.dart';
import 'package:flutter_current_results/src/features/try_results/data/try_results_repository.dart';
import 'package:flutter_current_results/src/shared/generated/query.pb.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'try_query_results_test.mocks.dart';

@GenerateMocks([ResultsService])
void main() {
  late MockResultsService mockResultsService;

  setUp(() {
    mockResultsService = MockResultsService();
  });

  test('constructor fetches and setter refetches on change', () async {
    when(mockResultsService.fetchChanges(123, 1)).thenAnswer((_) async => []);

    // Instantiation triggers the first fetch via the constructor.
    final queryResults = TryQueryResults(
      cl: 123,
      patchset: 1,
      resultsService: mockResultsService,
      filter: Filter('foo'),
    );

    await untilCalled(mockResultsService.fetchChanges(123, 1));
    verify(mockResultsService.fetchChanges(123, 1)).called(1);

    // Setting the same filter should not trigger a refetch.
    queryResults.filter = Filter('foo');
    await Future.delayed(Duration.zero); // Allow event loop to run.
    verifyNever(mockResultsService.fetchChanges(123, 1));

    // Setting a new filter should trigger a refetch.
    queryResults.filter = Filter('bar');
    await Future.delayed(Duration.zero); // Allow event loop to run.
    await untilCalled(mockResultsService.fetchChanges(123, 1));
    verify(mockResultsService.fetchChanges(123, 1)).called(1);
  });

  test('properties are populated correctly after fetch', () async {
    final result1 = Result()
      ..name = 'test1'
      ..configuration = 'config1'
      ..result = 'Pass'
      ..expected = 'Pass'
      ..flaky = false;
    final change1 = ChangeInResult(result1);

    final result2 = Result()
      ..name = 'test2'
      ..configuration = 'config2'
      ..result = 'Fail'
      ..expected = 'Pass'
      ..flaky = false;
    final change2 = ChangeInResult(result2);

    when(
      mockResultsService.fetchChanges(123, 1),
    ).thenAnswer((_) async => [(change1, result1), (change2, result2)]);

    // Instantiation triggers the fetch.
    final queryResults = TryQueryResults(
      cl: 123,
      patchset: 1,
      resultsService: mockResultsService,
      filter: Filter('foo'),
    );

    await untilCalled(mockResultsService.fetchChanges(123, 1));
    await Future.delayed(Duration.zero); // Allow event loop to run.

    expect(queryResults.names, ['test1', 'test2']);
    expect(queryResults.counts.length, 2);
    expect(queryResults.counts['test1']!.count, 1);
    expect(queryResults.counts['test1']!.countPassing, 1);
    expect(queryResults.counts['test2']!.count, 1);
    expect(queryResults.counts['test2']!.countFailing, 1);
    expect(queryResults.resultCounts.count, 2);
    expect(queryResults.resultCounts.countPassing, 1);
    expect(queryResults.resultCounts.countFailing, 1);
    expect(queryResults.testCounts.count, 2);
    expect(queryResults.testCounts.countPassing, 1);
    expect(queryResults.testCounts.countFailing, 1);
  });
}
