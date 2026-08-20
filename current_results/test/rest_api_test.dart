// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:current_results/src/api_impl.dart';
import 'package:current_results/src/bucket.dart';
import 'package:current_results/src/generated/google/pubsub/v1/pubsub.pbgrpc.dart'
    show PubsubMessage;
import 'package:current_results/src/generated/query.pb.dart';
import 'package:current_results/src/notifications.dart';
import 'package:current_results/src/slice.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

import 'rest_api_test.mocks.dart';

@GenerateMocks([BucketNotifications, ResultsBucket])
void main() {
  group('RestApi tests', () {
    late Slice slice;
    late RestApi restApi;
    late MockResultsBucket bucket;

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

      bucket = MockResultsBucket();
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

    test('GET /v1/results - Returns Binary Protobuf', () async {
      final request = Request(
        'GET',
        Uri.parse('http://localhost/v1/results'),
        headers: {'Accept': 'application/x-protobuf'},
      );
      final response = await restApi.handleRequest(request);

      expect(response.statusCode, 200);
      expect(response.headers['Content-Type'], 'application/x-protobuf');

      final bytes = await response.read().expand((b) => b).toList();
      final body = GetResultsResponse.fromBuffer(bytes);
      expect(body.results, hasLength(3));
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
        Uri.parse('http://localhost/v1/results?pageSize=1'),
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

    test('GET /v1/tests - Returns Binary Protobuf', () async {
      final request = Request(
        'GET',
        Uri.parse('http://localhost/v1/tests'),
        headers: {'Accept': 'application/x-protobuf'},
      );
      final response = await restApi.handleRequest(request);

      expect(response.statusCode, 200);
      expect(response.headers['Content-Type'], 'application/x-protobuf');

      final bytes = await response.read().expand((b) => b).toList();
      final body = ListTestsResponse.fromBuffer(bytes);
      expect(body.names, contains('test1'));
      expect(body.names, contains('test2'));
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

    test('OPTIONS /v1/results - Returns CORS headers', () async {
      final request = Request(
        'OPTIONS',
        Uri.parse('http://localhost/v1/results'),
      );
      final response = await restApi.handleRequest(request);

      expect(response.statusCode, 200);
      expect(response.headers['Access-Control-Allow-Origin'], '*');
      expect(response.headers['Access-Control-Allow-Methods'], contains('GET'));
      expect(
        response.headers['Access-Control-Allow-Headers'],
        contains('Content-Type'),
      );
    });

    test('GET /v1/results - Response has CORS headers', () async {
      final request = Request('GET', Uri.parse('http://localhost/v1/results'));
      final response = await restApi.handleRequest(request);

      expect(response.statusCode, 200);
      expect(response.headers['Access-Control-Allow-Origin'], '*');
    });

    test('GET / - Returns front page HTML', () async {
      final request = Request('GET', Uri.parse('http://localhost/'));
      final response = await restApi.handleRequest(request);

      expect(response.statusCode, 200);
      expect(response.headers['Content-Type'], contains('text/html'));
      final body = await response.readAsString();
      expect(body, contains('Current Results REST API'));
      expect(body, contains('Dart Test Logs'));
      expect(body, contains('Dart Test Sources'));
    });

    test('GET /log - latest redirect for builder', () async {
      when(
        bucket.getLatestBuildNumber('my-builder'),
      ).thenAnswer((_) async => '123');

      final request = Request(
        'GET',
        Uri.parse('http://localhost/log/my-builder/my-config/latest/test_name'),
      );
      final response = await restApi.handleRequest(request);

      expect(response.statusCode, 302);
      expect(
        response.headers['location'],
        '/log/my-builder/my-config/123/test_name',
      );
    });

    test('GET /log - latest redirect for any builder', () async {
      when(
        bucket.getLatestConfigurationBuildNumber('my-config'),
      ).thenAnswer((_) async => '456');

      final request = Request(
        'GET',
        Uri.parse('http://localhost/log/any/my-config/latest/test_name'),
      );
      final response = await restApi.handleRequest(request);

      expect(response.statusCode, 302);
      expect(response.headers['location'], '/log/any/my-config/456/test_name');
    });

    test('GET /log - serves log content', () async {
      when(
        bucket.getLog('my-builder', '123', 'my-config', 'test_name'),
      ).thenAnswer((_) async => 'Test log output here');

      final request = Request(
        'GET',
        Uri.parse('http://localhost/log/my-builder/my-config/123/test_name'),
      );
      final response = await restApi.handleRequest(request);

      expect(response.statusCode, 200);
      expect(response.headers['Content-Type'], 'text/plain; charset=utf-8');
      expect(response.headers['Expires'], isNotNull);
      final body = await response.readAsString();
      expect(body, 'Test log output here');
    });

    test('GET /log - no log found', () async {
      when(
        bucket.getLog('my-builder', '123', 'my-config', 'test_name'),
      ).thenAnswer((_) async => null);

      final request = Request(
        'GET',
        Uri.parse('http://localhost/log/my-builder/my-config/123/test_name'),
      );
      final response = await restApi.handleRequest(request);

      expect(response.statusCode, 200);
      final body = await response.readAsString();
      expect(body, contains('error: No logs found'));
    });

    test('GET /log - invalid log url', () async {
      final request = Request(
        'GET',
        Uri.parse('http://localhost/log/only-two-parts'),
      );
      final response = await restApi.handleRequest(request);

      expect(response.statusCode, 400);
      final body = await response.readAsString();
      expect(body, contains('error: Invalid log URL format'));
    });

    test('GET /test - redirect to source', () async {
      final request = Request(
        'GET',
        Uri.parse('http://localhost/test/main/corelib/apply2_test'),
      );
      final response = await restApi.handleRequest(request);

      expect(response.statusCode, 302);
      expect(
        response.headers['location'],
        'https://github.com/dart-lang/sdk/blob/main/tests/corelib/apply2_test.dart',
      );
    });

    test('GET /test - not found', () async {
      final request = Request(
        'GET',
        Uri.parse('http://localhost/test/main/suite/not_a_basename'),
      );
      final response = await restApi.handleRequest(request);

      expect(response.statusCode, 404);
      final body = await response.readAsString();
      expect(body, contains('No rules found'));
    });

    test('GET /test - invalid format', () async {
      final request = Request(
        'GET',
        Uri.parse('http://localhost/test/only-one-part'),
      );
      final response = await restApi.handleRequest(request);

      expect(response.statusCode, 400);
      final body = await response.readAsString();
      expect(body, contains('error: Invalid test URL format'));
    });

    test('GET /test - invalid CL format', () async {
      final request = Request(
        'GET',
        Uri.parse('http://localhost/test/cl/not-a-number/abc/test_name'),
      );
      final response = await restApi.handleRequest(request);

      expect(response.statusCode, 400);
      final body = await response.readAsString();
      expect(body, contains('error: Invalid review or patchset ID'));
    });
  });
}
