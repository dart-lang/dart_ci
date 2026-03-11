// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:current_results/src/slice.dart';
import 'package:current_results/src/notifications.dart';
import 'package:current_results/src/bucket.dart';
import 'package:current_results/src/generated/query.pb.dart' as api;
import 'package:protobuf/protobuf.dart';
import 'package:current_results/src/api_impl.dart' show fetchUpdates;

class RestApi {
  final Slice current;
  final BucketNotifications notifications;
  final ResultsBucket bucket;

  RestApi(this.current, this.notifications, this.bucket);

  Future<Response> handleRequest(Request request) async {
    final path = request.url.path;
    if (path == 'v1/results' && request.method == 'GET') {
      return _getResults(request);
    } else if (path == 'v1/tests' && request.method == 'GET') {
      return _listTests(request);
    } else if (path == 'v1/fetch' && request.method == 'POST') {
      return _fetch(request);
    } else if ((path == 'v1/testPaths' || path == 'v1/configurations') &&
        request.method == 'GET') {
      return Response(501, body: 'Unimplemented');
    }
    return Response.notFound('Not Found');
  }

  Future<Response> _getResults(Request request) async {
    final params = request.url.queryParameters;
    final protoRequest = api.GetResultsRequest();
    if (params.containsKey('filter')) protoRequest.filter = params['filter']!;
    if (params.containsKey('page_size')) {
      protoRequest.pageSize = int.tryParse(params['page_size']!) ?? 0;
    }
    if (params.containsKey('page_token')) {
      protoRequest.pageToken = params['page_token']!;
    }
    final response = current.results(protoRequest);
    return Response.ok(
      _toJson(response),
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<Response> _listTests(Request request) async {
    final params = request.url.queryParameters;
    final protoRequest = api.ListTestsRequest();
    if (params.containsKey('prefix')) protoRequest.prefix = params['prefix']!;
    if (params.containsKey('limit')) {
      protoRequest.limit = int.tryParse(params['limit']!) ?? 0;
    }
    final response = current.listTests(protoRequest);
    return Response.ok(
      _toJson(response),
      headers: {'Content-Type': 'application/json'},
    );
  }

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
