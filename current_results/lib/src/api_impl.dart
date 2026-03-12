// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:current_results/src/bucket.dart';
import 'package:current_results/src/generated/query.pb.dart';
import 'package:current_results/src/notifications.dart';
import 'package:current_results/src/slice.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

part 'api_impl.g.dart';

const _corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, PUT, PATCH, DELETE, OPTIONS',
  'Access-Control-Allow-Headers':
      'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,'
      'Content-Type,Range,Authorization',
  'Access-Control-Expose-Headers': 'Content-Length,Content-Range',
};

class RestApi {
  final Slice current;
  final BucketNotifications notifications;
  final ResultsBucket bucket;

  RestApi(this.current, this.notifications, this.bucket);

  Router get router => _$RestApiRouter(this);

  Future<Response> handleRequest(Request request) async {
    return (await router(request)).change(headers: _corsHeaders);
  }

  @Route.options('/<ignored|.*>')
  Future<Response> _options(Request request) async => Response.ok('');

  @Route.get('/v1/testPaths')
  Future<Response> _testPaths(Request request) async =>
      Response(501, body: 'Unimplemented');

  @Route.get('/v1/configurations')
  Future<Response> _configurations(Request request) async =>
      Response(501, body: 'Unimplemented');

  @Route.get('/v1/results')
  Future<Response> _getResults(Request request) async {
    final params = request.url.queryParameters;
    final protoRequest = GetResultsRequest();
    if (params['filter'] case final filter?) {
      protoRequest.filter = filter;
    }
    if (params['pageSize'] case final pageSize?) {
      protoRequest.pageSize = int.tryParse(pageSize) ?? 0;
    }
    if (params['pageToken'] case final pageToken?) {
      protoRequest.pageToken = pageToken;
    }
    final response = current.results(protoRequest);
    return Response.ok(
      jsonEncode(response.toProto3Json()),
      headers: {'Content-Type': 'application/json'},
    );
  }

  @Route.get('/v1/tests')
  Future<Response> _listTests(Request request) async {
    final params = request.url.queryParameters;
    final protoRequest = ListTestsRequest();
    if (params['prefix'] case final prefix?) {
      protoRequest.prefix = prefix;
    }
    if (params['limit'] case final limit?) {
      protoRequest.limit = int.tryParse(limit) ?? 0;
    }
    final response = current.listTests(protoRequest);
    return Response.ok(
      jsonEncode(response.toProto3Json()),
      headers: {'Content-Type': 'application/json'},
    );
  }

  @Route.post('/v1/fetch')
  Future<Response> _fetch(Request request) async {
    final response = await fetchUpdates(notifications, bucket, current);
    return Response.ok(
      jsonEncode(response.toProto3Json()),
      headers: {'Content-Type': 'application/json'},
    );
  }
}

Future<FetchResponse> fetchUpdates(
  BucketNotifications notifications,
  ResultsBucket bucket,
  Slice current,
) async {
  final response = FetchResponse();
  final messages = await notifications.getMessages();
  final latestObjectPattern = RegExp('^(configuration/main/[^/]+/)latest\$');
  final configurations = <String>{};
  for (final message in messages) {
    if (message.attributes['eventType'] == 'OBJECT_FINALIZE') {
      final match = latestObjectPattern.firstMatch(
        message.attributes['objectId']!,
      );
      if (match != null) {
        configurations.add(match[1]!);
      }
    }
  }
  for (final configuration in configurations) {
    final lines = await bucket.latestResults(configuration);
    current.add(lines);
    response.updates.add(ConfigurationUpdate()..configuration = configuration);
  }
  current.dropResultsOlderThan(maximumAge);
  current.collectTestNames();
  return response;
}
