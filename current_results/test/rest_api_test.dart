// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'package:test/test.dart';
import 'package:shelf/shelf.dart';
import 'package:current_results/src/rest_api.dart';
import 'package:current_results/src/slice.dart';
import 'package:current_results/src/notifications.dart';
import 'package:current_results/src/bucket.dart';
import 'package:current_results/src/generated/google/pubsub/v1/pubsub.pbgrpc.dart'
    show PubsubMessage;

import 'package:mockito/annotations.dart';
import 'rest_api_test.mocks.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([BucketNotifications, ResultsBucket])
void main() {
  group('RestApi tests', () {
    late Slice slice;
    late RestApi restApi;

    setUp(() {
      slice = Slice();
      // Add fake results
      slice.add([
        jsonEncode({
          'name': 'test1',
          'configuration': 'config_a',
          'result': 'passed',
        }),
        jsonEncode({
          'name': 'test2',
          'configuration': 'config_a',
          'result': 'failed',
        }),
      ]);
      slice.add([
        jsonEncode({
          'name': 'test1',
          'configuration': 'config_b',
          'result': 'passed',
        }),
      ]);
      slice.collectTestNames();

      final notifications = MockBucketNotifications();
      when(notifications.initialize()).thenAnswer((_) async {});
      when(notifications.getMessages()).thenAnswer((_) async => []);

      final bucket = MockResultsBucket();
      when(bucket.configurationDirectories()).thenAnswer((_) async => []);
      when(bucket.latestResults(any)).thenAnswer((_) async => []);

      restApi = RestApi(slice, notifications, bucket);
    });

    test('GET /v1/results - Returns all', () async {
      final request = Request('GET', Uri.parse('http://localhost/v1/results'));
      final response = await restApi.handleRequest(request);

      expect(response.statusCode, 200);
      expect(response.headers['Content-Type'], 'application/json');

      final body = jsonDecode(await response.readAsString());
      expect(body['results'], isList);
      expect(body['results'], hasLength(3));
    });

    test('GET /v1/results - With Filter', () async {
      final request = Request(
        'GET',
        Uri.parse('http://localhost/v1/results?filter=config_b'),
      );
      final response = await restApi.handleRequest(request);

      expect(response.statusCode, 200);
      final body = jsonDecode(await response.readAsString());
      expect(body['results'], hasLength(1));
      expect(body['results'][0]['configuration'], 'config_b');
    });

    test('GET /v1/results - With PageSize', () async {
      final request = Request(
        'GET',
        Uri.parse('http://localhost/v1/results?page_size=1'),
      );
      final response = await restApi.handleRequest(request);

      expect(response.statusCode, 200);
      final body = jsonDecode(await response.readAsString());
      expect(body['results'], hasLength(1));
      expect(body['nextPageToken'], isNotNull);
    });

    test('GET /v1/tests', () async {
      final request = Request('GET', Uri.parse('http://localhost/v1/tests'));
      final response = await restApi.handleRequest(request);

      expect(response.statusCode, 200);
      final body = jsonDecode(await response.readAsString());
      expect(body['names'], isList);
      expect(body['names'], contains('test1'));
      expect(body['names'], contains('test2'));
    });

    test('POST /v1/fetch', () async {
      final notifications = MockBucketNotifications();
      when(notifications.getMessages()).thenAnswer(
        (_) async => [
          PubsubMessage()
            ..attributes.addAll({
              'eventType': 'OBJECT_FINALIZE',
              'objectId': 'configuration/main/config_c/latest',
            }),
        ],
      );

      final bucket = MockResultsBucket();
      when(bucket.latestResults('configuration/main/config_c/')).thenAnswer(
        (_) async => [
          jsonEncode({
            'name': 'test3',
            'configuration': 'config_c',
            'result': 'passed',
          }),
        ],
      );

      final apiWithFetch = RestApi(slice, notifications, bucket);

      final request = Request('POST', Uri.parse('http://localhost/v1/fetch'));
      final response = await apiWithFetch.handleRequest(request);

      expect(response.statusCode, 200);
      final body = jsonDecode(await response.readAsString());
      expect(body['updates'], isList);
      expect(
        body['updates'][0]['configuration'],
        'configuration/main/config_c/',
      );

      // Verify slice updated
      expect(slice.size, 4);
    });

    test('GET /v1/testPaths - Returns 501', () async {
      final request = Request(
        'GET',
        Uri.parse('http://localhost/v1/testPaths'),
      );
      final response = await restApi.handleRequest(request);

      expect(response.statusCode, 501);
    });

    test('GET /invalid_path - Returns 404', () async {
      final request = Request(
        'GET',
        Uri.parse('http://localhost/invalid_path'),
      );
      final response = await restApi.handleRequest(request);

      expect(response.statusCode, 404);
    });
  });
}
