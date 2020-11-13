// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// HTTP API for [symbolizer.bot] and [symbolizer.symbolizer] functionality.
library symbolizer.server;

import 'dart:convert';
import 'dart:io';

import 'package:github/github.dart';
import 'package:github/hooks.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:pedantic/pedantic.dart';

import 'package:symbolizer/bot.dart';
import 'package:symbolizer/symbolizer.dart';

final _log = Logger('server');

typedef _RequestHandler = Future<Object> Function(Map<String, dynamic> request);

Future<void> serve(Object address, int port,
    {@required Symbolizer symbolizer, @required Bot bot}) async {
  final handlers = <String, _RequestHandler>{
    '/symbolize': (issue) => symbolizer.symbolize(issue['body']),
    '/command': (event) async {
      final repoOrgMember = const {'MEMBER', 'OWNER'}
          .contains(event['comment']['author_association']);
      final commentEvent = IssueCommentEvent.fromJson(event);
      final repo = RepositorySlug.full(event['repository']['full_name']);
      await bot.executeCommand(repo, commentEvent.issue, commentEvent.comment,
          authorized: repoOrgMember);
      return {'status': 'ok'};
    },
  };

  // Start the server.
  final server = await HttpServer.bind(address, port);
  _log.info('Listening on ${server.address}:${server.port}');

  // Intentionally not processing requests in parallel to avoid racing
  // in symbol cache.
  await for (HttpRequest request in server) {
    _log.info('Incoming request: ${request.method} ${request.requestedUri}');
    final handler = handlers[request.requestedUri.path];
    if (request.method != 'POST' || handler == null) {
      request.response
        ..statusCode = 404
        ..write('Not found');
      unawaited(request.response.close());
      continue;
    }
    try {
      final requestObj =
          await utf8.decoder.bind(request).transform(json.decoder).first;
      final responseJson = jsonEncode(await handler(requestObj));
      request.response
        ..statusCode = HttpStatus.ok
        ..headers.add(HttpHeaders.contentTypeHeader, 'application/json')
        ..write(responseJson);
    } catch (e, st) {
      request.response
        ..statusCode = HttpStatus.internalServerError
        ..headers.add(HttpHeaders.contentTypeHeader, 'application/json')
        ..write(jsonEncode({
          'status': 'error',
          'message': e.toString(),
          'stacktrace': st.toString(),
        }));
    }
    unawaited(request.response.close());
  }
}
