// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Serves the log over HTTP for a failing test on a given runner and build

import 'dart:async';
import 'dart:io';

import 'package:log/src/get_log.dart';
import 'package:http/http.dart' as http;

void main() async {
  final server = await HttpServer.bind(InternetAddress.anyIPv4, 8080);
  server.listen(dispatchingServer);
  print("Server started at ip:port ${server.address}:${server.port}");
}

Future<void> dispatchingServer(HttpRequest request) async {
  try {
    if (request.uri.path.startsWith('/log/')) {
      await serveLog(request);
      return;
    } else if (request.uri.path == '/') {
      return await redirectPermanent(request, '/changes/');
    } else {
      return await notFound(request);
    }
  } catch (e, t) {
    print(e);
    print(t);
    serverError(request);
  }
}

Future<void> serveLog(HttpRequest request) async {
  final parts = request.uri.pathSegments;
  final builder = parts[1];
  final configuration = parts[2];
  final build = parts[3];
  final test = parts.skip(4).join('/');

  if (build == 'latest') {
    final actualBuild = await getLatestBuildNumber(builder);
    return redirectPermanent(
        request, '/log/$builder/$configuration/$actualBuild/$test');
  }
  final log = await getLog(builder, build, configuration, test);
  if (log == null) {
    return noLog(request, builder, build, test);
  }
  final response = request.response;
  response.headers.contentType = ContentType.text;
  response.headers.expires = DateTime.now().add(const Duration(days: 30));
  response.write(log);
  return response.close();
}

Future<void> redirectPermanent(HttpRequest request, String newPath) {
  request.response.headers.add(HttpHeaders.locationHeader, newPath);
  request.response.statusCode = HttpStatus.movedPermanently;
  return request.response.close();
}

Future<void> notFound(HttpRequest request) {
  request.response.statusCode = HttpStatus.notFound;
  return request.response.close();
}

Future<void> noLog(
    HttpRequest request, String builder, String build, String test) {
  request.response.headers.contentType = ContentType.text;
  request.response
      .write("No log for test $test on build $build of builder $builder");
  return request.response.close();
}

Future<void> serverError(HttpRequest request) {
  request.response.statusCode = HttpStatus.internalServerError;
  return request.response.close();
}
