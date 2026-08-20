// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:current_results/src/bucket.dart';
import 'package:current_results/src/generated/query.pb.dart';
import 'package:current_results/src/notifications.dart';
import 'package:current_results/src/slice.dart';
import 'package:current_results/src/test_source.dart';
import 'package:logging/logging.dart';
import 'package:protobuf/protobuf.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

part 'api_impl.g.dart';

final _log = Logger('api');

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
  Future<Response> _options(Request request) async =>
      Response.ok('', headers: _corsHeaders);

  @Route.get('/')
  Future<Response> _frontPage(Request request) async => Response.ok(
    _frontPageHtml,
    headers: {'Content-Type': 'text/html; charset=utf-8', ..._corsHeaders},
  );

  @Route.get('/log/<path|.*>')
  Future<Response> _serveLog(Request request, String path) async {
    final parts = path.split('/');
    if (parts.length < 4) {
      return Response.badRequest(
        body:
            'error: Invalid log URL format. Expected /log/[builder]/[configuration]/[build]/[test]',
        headers: {'Content-Type': 'text/plain; charset=utf-8', ..._corsHeaders},
      );
    }
    final builder = parts[0];
    final configuration = parts[1];
    final build = parts[2];
    final test = parts.skip(3).join('/');

    if (build == 'latest') {
      try {
        final actualBuild = builder == 'any'
            ? await bucket.getLatestConfigurationBuildNumber(configuration)
            : await bucket.getLatestBuildNumber(builder);
        return Response.found(
          '/log/$builder/$configuration/$actualBuild/$test',
          headers: _corsHeaders,
        );
      } on UserVisibleFailure catch (e) {
        return Response.ok(
          e.toString(),
          headers: {
            'Content-Type': 'text/plain; charset=utf-8',
            ..._corsHeaders,
          },
        );
      } catch (e, st) {
        _log.severe('Error getting latest build for log request: $path', e, st);
        return Response.internalServerError(
          body: 'Internal server error',
          headers: _corsHeaders,
        );
      }
    }

    try {
      final log = await bucket.getLog(builder, build, configuration, test);
      if (log == null) {
        return Response.ok(
          'error: No logs found for test $test on build $build of '
          'builder $builder, configuration $configuration',
          headers: {
            'Content-Type': 'text/plain; charset=utf-8',
            ..._corsHeaders,
          },
        );
      }
      return Response.ok(
        log,
        headers: {
          'Content-Type': 'text/plain; charset=utf-8',
          'Expires': HttpDate.format(
            DateTime.now().add(const Duration(days: 30)),
          ),
          ..._corsHeaders,
        },
      );
    } on UserVisibleFailure catch (e) {
      return Response.ok(
        e.toString(),
        headers: {'Content-Type': 'text/plain; charset=utf-8', ..._corsHeaders},
      );
    } catch (e, st) {
      _log.severe('Error serving log for $path', e, st);
      return Response.internalServerError(
        body: 'Internal server error',
        headers: _corsHeaders,
      );
    }
  }

  @Route.get('/test/<path|.*>')
  Future<Response> _redirectToTest(Request request, String path) async {
    final parts = path.split('/');
    if (parts.isEmpty || (parts.length == 1 && parts.first.isEmpty)) {
      return Response.badRequest(
        body:
            'error: Invalid test URL format. Expected /test/[revision]/[test-name] or /test/cl/[review]/[patchset]/[test-name]',
        headers: {'Content-Type': 'text/plain; charset=utf-8', ..._corsHeaders},
      );
    }
    final isCl = parts.first == 'cl';
    if (isCl && parts.length < 4) {
      return Response.badRequest(
        body:
            'error: Invalid CL test URL format. Expected /test/cl/[review-id]/[patchset-id]/[test-name]',
        headers: {'Content-Type': 'text/plain; charset=utf-8', ..._corsHeaders},
      );
    } else if (!isCl && parts.length < 2) {
      return Response.badRequest(
        body:
            'error: Invalid test URL format. Expected /test/[revision]/[test-name]',
        headers: {'Content-Type': 'text/plain; charset=utf-8', ..._corsHeaders},
      );
    }

    late String revision;
    if (isCl) {
      final review = int.tryParse(parts[1]);
      final patchset = int.tryParse(parts[2]);
      if (review == null || patchset == null) {
        return Response.badRequest(
          body: 'error: Invalid review or patchset ID',
          headers: {
            'Content-Type': 'text/plain; charset=utf-8',
            ..._corsHeaders,
          },
        );
      }
      try {
        revision = await getPatchsetRevision(review, patchset);
      } catch (e) {
        return Response.ok(
          'error: $e',
          headers: {
            'Content-Type': 'text/plain; charset=utf-8',
            ..._corsHeaders,
          },
        );
      }
    } else {
      revision = parts.first;
    }
    final testName = parts.skip(isCl ? 3 : 1).join('/');
    try {
      final source = await computeTestSource(revision, testName, isCl);
      if (source != null) {
        return Response.found(source.toString(), headers: _corsHeaders);
      } else {
        return Response.notFound(
          "No rules found that match test name '$testName'."
          " If you think that this test name should work, please send a"
          " message to dart-engprod@.",
          headers: {
            'Content-Type': 'text/plain; charset=utf-8',
            ..._corsHeaders,
          },
        );
      }
    } catch (e) {
      return Response.ok(
        'error: $e',
        headers: {'Content-Type': 'text/plain; charset=utf-8', ..._corsHeaders},
      );
    }
  }

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
    return _respond(request, response);
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
    return _respond(request, response);
  }

  @Route.post('/v1/fetch')
  Future<Response> _fetch(Request request) async {
    final response = await fetchUpdates(notifications, bucket, current);
    return _respond(request, response);
  }

  Response _respond(Request request, GeneratedMessage response) {
    final accept = request.headers['Accept'] ?? '';
    final Object body;
    final String contentType;
    if (accept.contains('application/x-protobuf')) {
      body = response.writeToBuffer();
      contentType = 'application/x-protobuf';
    } else {
      body = jsonEncode(response.toProto3Json());
      contentType = 'application/json';
    }
    return Response.ok(
      body,
      headers: {'Content-Type': contentType, ..._corsHeaders},
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

const _frontPageHtml = """<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <title>Dart CI Current Results, Logs, and Sources</title>
  </head>
  <body>
    <h1>Dart CI Services</h1>

    <h2>Current Results REST API</h2>
    <ul>
      <li><code>GET /v1/results[?filter=...&amp;pageSize=...&amp;pageToken=...]</code> - Query test results. Supports <code>Accept: application/json</code> or <code>Accept: application/x-protobuf</code>.</li>
      <li><code>GET /v1/tests[?prefix=...&amp;limit=...]</code> - List test names matching an optional prefix.</li>
      <li><code>POST /v1/fetch</code> - Fetches new test result updates from bucket notifications.</li>
    </ul>

    <h2>Dart Test Logs</h2>
    <p>URL formats:</p>
    <ul>
      <li><code>/log/any/[configuration name]/latest/[test name]</code></li>
      <li><code>/log/any/[configuration name]/[build number]/[test name]</code></li>
      <li><code>/log/any/[configuration name]/latest/[test name prefix]*</code></li>
      <li><code>/log/[builder]/[configuration name]/latest/[test name]</code></li>
      <li><code>/log/[builder]/*/latest/[test name]</code></li>
    </ul>
    <p>and all combinations of these except <code>/log/any/*/...</code>.</p>

    <h2>Dart Test Sources</h2>
    <p>Redirects to the source of the test given by name and either SDK revision or CL/patchset reference.</p>
    <p>URL formats:</p>
    <ul>
      <li><code>/test/[revision]/[test-name]</code></li>
      <li><code>/test/cl/[review-id]/[patchset-id]/[test-name]</code></li>
    </ul>
    <p>Examples:</p>
    <ul>
      <li><a href="test/main/corelib/apply2_test">test/main/corelib/apply2_test</a></li>
      <li><a href="test/9094f7/co19/Language/Classes/Class_Member_Conflicts/static_member_and_instance_member_t04/none">test/9094f7/co19/Language/Classes/Class_Member_Conflicts/static_member_and_instance_member_t04/none</a></li>
      <li><a href="test/cl/199421/3/pkg/test_runner/test/experiment_test">test/cl/199421/3/pkg/test_runner/test/experiment_test</a></li>
    </ul>
  </body>
</html>
""";
