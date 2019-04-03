// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Serves the log over HTTP for a failing test on a given runner and build

import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'package:dart_ci/src/get_log.dart';
import 'package:dart_ci/src/group_changes.dart';
import 'package:dart_ci/src/fetch_changes.dart';

String changesPage;

void main() async {
  await fetchData();
  changesPage = await createChangesPage();
  final server = await HttpServer.bind(InternetAddress.anyIPv4, 8080);
  server.listen(dispatchingServer);
  print("Server started at ip:port ${server.address}:${server.port}");
  Timer.periodic(Duration(minutes: 10), (timer) async {
    try {
      await refresh();
    } catch (e, t) {
      print(e);
      print(t);
    }
  });
}

Future<void> refresh() async {
  await fetchData();
  changesPage = await createChangesPage();
}

Future<void> dispatchingServer(HttpRequest request) async {
  try {
    if (request.uri.path == '/') {
      return await redirectTemporary(request, '/changes/');
    } else if (request.uri.path.startsWith('/log/')) {
      return await serveLog(request);
    } else if (request.uri.path.startsWith('/changes')) {
      return await serveChanges(request);
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
    return redirectTemporary(
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

Future<void> redirectTemporary(HttpRequest request, String newPath) {
  request.response.headers.add(HttpHeaders.locationHeader, newPath);
  request.response.statusCode = HttpStatus.movedTemporarily;
  return request.response.close();
}

Future<void> serveChanges(HttpRequest request) async {
  final response = request.response;
  response.headers.contentType = ContentType.html;
  response.write(changesPage);
  return response.close();
}

Future<void> notFound(HttpRequest request) {
  request.response.statusCode = HttpStatus.notFound;
  return request.response.close();
}

Future<void> noLog(
    HttpRequest request, String builder, String build, String test) async {
  request.response.headers.contentType = ContentType.text;
  request.response
      .write("No log for test $test on build $build of builder $builder");
  return request.response.close();
}

Future<void> serverError(HttpRequest request) {
  request.response.statusCode = HttpStatus.internalServerError;
  return request.response.close();
}
