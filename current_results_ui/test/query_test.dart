// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:flutter_current_results/filter.dart';
import 'package:flutter_current_results/results.dart';
import 'package:flutter_current_results/src/generated/query.pb.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_current_results/query.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'query_test.mocks.dart';

@GenerateNiceMocks([MockSpec<http.Client>()])
void main() {
  group('ChangeInResult', () {
    test('flaky result', () {
      final result = Result(
        result: 'RuntimeError',
        expected: 'Pass',
        flaky: true,
      );
      final change = ChangeInResult(result);
      expect(change.kind, ResultKind.flaky);
      expect(change.text, 'flaky (latest result RuntimeError expected Pass)');
    });

    test('matching result', () {
      final result = Result(result: 'Pass', expected: 'Pass', flaky: false);
      final change = ChangeInResult(result);
      expect(change.kind, ResultKind.pass);
      expect(change.text, 'Pass');
    });

    test('failing result', () {
      final result = Result(
        result: 'RuntimeError',
        expected: 'Pass',
        flaky: false,
      );
      final change = ChangeInResult(result);
      expect(change.kind, ResultKind.fail);
      expect(change.text, 'RuntimeError (expected Pass)');
    });

    test('comparison', () {
      final pass = ChangeInResult(Result(result: 'Pass', expected: 'Pass'));
      final fail = ChangeInResult(
        Result(result: 'RuntimeError', expected: 'Pass'),
      );
      final flaky = ChangeInResult(
        Result(result: 'RuntimeError', expected: 'Pass', flaky: true),
      );

      expect(pass.compareTo(fail), 1);
      expect(fail.compareTo(pass), -1);
      expect(flaky.compareTo(fail), -1);
      expect(fail.compareTo(flaky), 1);
      expect(pass.compareTo(flaky), 1);
      expect(flaky.compareTo(pass), -1);
    });

    test('caching', () {
      final result1 = Result(result: 'Pass', expected: 'Pass');
      final result2 = Result(result: 'Pass', expected: 'Pass');
      final change1 = ChangeInResult(result1);
      final change2 = ChangeInResult(result2);
      expect(identical(change1, change2), isTrue);
    });
  });

  group('QueryResults', () {
    late MockClient mockClient;
    late QueryResults queryResults;

    setUp(() {
      mockClient = MockClient();
      queryResults = QueryResults(Filter(''), client: mockClient);
    });

    test('fetches and processes results', () async {
      final response = GetResultsResponse(
        results: [
          Result(name: 'test1', result: 'Pass', expected: 'Pass'),
          Result(name: 'test2', result: 'Fail', expected: 'Pass'),
        ],
        nextPageToken: '',
      );
      when(mockClient.get(any)).thenAnswer(
        (_) async => http.Response(jsonEncode(response.toProto3Json()), 200),
      );

      queryResults.filter = Filter('test');

      await untilCalled(mockClient.get(any));
      while (!queryResults.isDone) {
        await Future.delayed(Duration.zero);
      }

      expect(queryResults.names, ['test1', 'test2']);
      expect(queryResults.counts['test1']!.count, 1);
      expect(queryResults.counts['test1']!.countPassing, 1);
      expect(queryResults.counts['test2']!.count, 1);
      expect(queryResults.counts['test2']!.countFailing, 1);
    });
  });
}
