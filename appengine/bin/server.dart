// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Serves the log over HTTP for a failing test on a given runner and build,
/// and redirects to the source code of a test for a given revision.

import 'dart:async';
import 'dart:io';

import 'package:dart_ci/src/get_log.dart';
import 'package:dart_ci/src/test_source.dart'
    show computeTestSource, getPatchsetRevision;

void main() async {
  final server = await HttpServer.bind(InternetAddress.anyIPv4, 8080);
  server.listen(dispatchingServer);
  print("Server started at ip:port ${server.address}:${server.port}");
}

Future<void> dispatchingServer(HttpRequest request) async {
  try {
    if (request.headers['X-Forwarded-Proto']?.first == 'http') {
      return redirectPermanent(
          request, request.requestedUri.replace(scheme: 'https').toString());
    }
    request.response.headers
        .add('Strict-Transport-Security', 'max-age=31536000; preload');
    final path = request.uri.path;
    if (path.startsWith('/log/')) {
      await serveLog(request);
    } else if (path.startsWith('/test/')) {
      await redirectToTest(request);
    } else {
      await serveFrontPage(request);
    }
  } on UserVisibleFailure catch (e) {
    print(e);
    showError(request, e);
  } catch (e, t) {
    print(e);
    print(t);
    serverError(request);
  }
}

Future<void> serveFrontPage(HttpRequest request) async {
  request.response.headers.contentType = ContentType.html;
  request.response.write("""<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <title>Dart Test Logs and Sources</title>
  </head>
  <body>
    <h1>Dart Test Logs</h1>
   URL formats:
   <ul>
   <li>/log/any/[configuration name]/latest/[test name]
   <li>/log/any/[configuration name]/[build number]/[test name]
   <li>/log/any/[configuration name]/latest/[test name prefix]*
   <li>/log/[builder]/[configuration name]/latest/[test name]
   <li>/log/[builder]/*/latest/[test name]
   </ul>
   and all combinations of these except /log/any/*/... .
    <h1>Dart Test Sources</h1>
    Redirects to the source of the test given by name and either SDK revision or CL/patchset
    reference.
    <p>URL formats:
    <ul>
    <li>/test/[revision]/[test-name]
    <li>/test/cl/[review-id]/[patchset-id]/[test-name]
    </ul>
    </p>
    <p>Examples:
    <ul>
    <li><a href="test/main/corelib/apply2_test">
      test/main/corelib/apply2_test</a>
    <li><a href="test/9094f7/co19/Language/Classes/Class_Member_Conflicts/static_member_and_instance_member_t04/none">
      test/9094f7/co19/Language/Classes/Class_Member_Conflicts/static_member_and_instance_member_t04/none
    <li><a href="test/cl/199421/3/pkg/test_runner/test/experiment_test">
      test/cl/199421/3/pkg/test_runner/test/experiment_test</a>
    </ul>
    </p>
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

Future<void> redirectToTest(HttpRequest request) async {
  final parts = request.uri.pathSegments.skip(1).toList();
  final isCl = parts.first == 'cl';
  late String revision;
  if (isCl) {
    final review = int.parse(parts[1]);
    final patchset = int.parse(parts[2]);
    revision = await getPatchsetRevision(review, patchset);
  } else {
    revision = parts.first;
  }
  final testName = parts.skip(isCl ? 3 : 1).join('/');
  try {
    final source = await computeTestSource(revision, testName, isCl);
    if (source != null) {
      return redirectTemporary(request, source.toString());
    } else {
      return notFound(request,
          message: "No rules found that match test name '$testName'."
              " If you think that this test name should work, please send a"
              " message to dart-engprod@.");
    }
  } catch (e) {
    throw UserVisibleFailure(e.toString());
  }
}

Future<void> redirectTemporary(HttpRequest request, String newPath) {
  request.response.headers.add(HttpHeaders.locationHeader, newPath);
  request.response.statusCode = HttpStatus.movedTemporarily;
  return request.response.close();
}

Future<void> redirectPermanent(HttpRequest request, String newPath) {
  request.response.headers.add(HttpHeaders.locationHeader, newPath);
  request.response.statusCode = HttpStatus.movedPermanently;
  return request.response.close();
}

Future<void> notFound(HttpRequest request, {String? message}) {
  request.response.statusCode = HttpStatus.notFound;
  if (message != null) {
    request.response.write(message);
  }
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
