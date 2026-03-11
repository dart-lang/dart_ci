// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:current_results/src/api_impl.dart' show fetchUpdates;
import 'package:current_results/src/bucket.dart';
import 'package:current_results/src/generated/query.pb.dart' as api;
import 'package:current_results/src/notifications.dart';
import 'package:current_results/src/slice.dart';
import 'package:protobuf/protobuf.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

part 'rest_api.g.dart';

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
    final protoRequest = api.GetResultsRequest();
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
      _toJson(response),
      headers: {'Content-Type': 'application/json'},
    );
  }

  @Route.get('/v1/tests')
  Future<Response> _listTests(Request request) async {
    final params = request.url.queryParameters;
    final protoRequest = api.ListTestsRequest();
    if (params['prefix'] case final prefix?) {
      protoRequest.prefix = prefix;
    }
    if (params['limit'] case final limit?) {
      protoRequest.limit = int.tryParse(limit) ?? 0;
    }
    final response = current.listTests(protoRequest);
    return Response.ok(
      _toJson(response),
      headers: {'Content-Type': 'application/json'},
    );
  }

  @Route.post('/v1/fetch')
  Future<Response> _fetch(Request request) async {
    final response = await fetchUpdates(notifications, bucket, current);
    return Response.ok(
      _toJson(response),
      headers: {'Content-Type': 'application/json'},
    );
  }

  String _toJson(GeneratedMessage message) =>
      jsonEncode(message.toProto3Json());
}
