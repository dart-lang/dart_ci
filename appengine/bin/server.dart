// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Serves the log over HTTP for a failing test on a given runner and build

import 'dart:async';
import 'dart:io';

import 'package:dart_ci/src/get_log.dart';

void main() async {
  final server = await HttpServer.bind(InternetAddress.anyIPv4, 8080);
  server.listen(dispatchingServer);
  print("Server started at ip:port ${server.address}:${server.port}");
}

Future<void> dispatchingServer(HttpRequest request) async {
  try {
    if (request.uri.path.startsWith('/log/')) {
      return await serveLog(request);
    }
    return await serveFrontPage(request);
  } on UserVisibleFailure catch (e) {
    print(e);
    showError(request, e);
  } catch (e, t) {
    print(e);
    print(t);
    serverError(request);
  }
}

void serveFrontPage(HttpRequest request) async {
  request.response.headers.contentType = ContentType.html;
  request.response.write("""<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <title>Dart Test Logs</title>
  </head>
  <body>
    <h1>Dart Test Logs</h1>
   URL formats:
   <ul>
   <li>/logs/any/[configuration name]/latest/[test name]
   <li>/logs/any/[configuration name]/[build number]/[test name]
   <li>/logs/any/[configuration name]/latest/[test name prefix]*
   <li>/logs/[builder]/[configuration name]/latest/[test name]
   <li>/logs/[builder]/*/latest/[test name]
   </ul>
   and all combinations of these except /logs/any/*/... .
  </body>
</html>
""");
  request.response.close();
}

Future<void> serveLog(HttpRequest request) async {
  final parts = request.uri.pathSegments;
  final builder = parts[1];
  final configuration = parts[2];
  final build = parts[3];
  final test = parts.skip(4).join('/');

  if (build == 'latest') {
    final actualBuild = builder == 'any'
        ? await getLatestConfigurationBuildNumber(configuration)
        : await getLatestBuildNumber(builder);
    return redirectTemporary(
        request, '/log/$builder/$configuration/$actualBuild/$test');
  }
  final log = await getLog(builder, build, configuration, test);
  if (log == null) {
    throw UserVisibleFailure('No logs found for test $test on build $build of '
        'builder $builder, configuration $configuration');
  }
  final response = request.response;
  response.headers.contentType = ContentType.text;
  response.headers.expires = DateTime.now().add(const Duration(days: 30));
  response.write(log);
  return response.close();
}

Future<void> redirectTemporary(HttpRequest request, String newPath) {
  request.response.headers.add(HttpHeaders.locationHeader, newPath);
  request.response.statusCode = HttpStatus.movedTemporarily;
  return request.response.close();
}

Future<void> notFound(HttpRequest request) {
  request.response.statusCode = HttpStatus.notFound;
  return request.response.close();
}

Future<void> showError(HttpRequest request, UserVisibleFailure failure) {
  request.response.headers.contentType = ContentType.text;
  request.response.write(failure.toString());
  return request.response.close();
}

Future<void> serverError(HttpRequest request) {
  try {
    request.response.statusCode = HttpStatus.internalServerError;
  } catch (e) {
    print(e);
  }
  return request.response.close();
}
