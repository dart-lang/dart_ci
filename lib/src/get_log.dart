// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Displays the log for a failing test on a given runner and build

import 'dart:async';
import 'dart:convert';

import 'package:_discoveryapis_commons/_discoveryapis_commons.dart';
import 'package:googleapis/storage/v1.dart' as storage;
import 'package:http/http.dart' as http;

final resultsBucket = 'dart-test-results';

Future<String> getCloudFile(String bucket, String path) async {
  final client = http.Client();
  try {
    final api = storage.StorageApi(client);
    final media = await api.objects
        .get(bucket, path, downloadOptions: DownloadOptions.FullMedia) as Media;
    return await utf8.decodeStream(media.stream);
  } finally {
    client.close();
  }
}

Future<String> getLatestBuildNumber(String builder) =>
    getCloudFile(resultsBucket, "builders/$builder/latest");

/// Fetches a log or logs and formats them for output.
/// If a failure occurs, signal error on the returned future.
Future<String> getLog(
    String builder, String build, String configuration, String test) async {
  if (build == "latest") {
    build = await getLatestBuildNumber(builder);
  }
  final safeRegExp = RegExp('^[-\\w]*\$');
  final digitsRegExp = RegExp('^\\d*\$');
  if (!safeRegExp.hasMatch(builder)) {
    throw "Builder name $builder contains illegal characters";
  }
  if (!digitsRegExp.hasMatch(build)) {
    throw "Build number $build is not a number";
  }

  final logs_json =
      await getCloudFile(resultsBucket, "builders/$builder/$build/logs.json");
  final logs = LineSplitter.split(logs_json)
      .where((line) => line.isNotEmpty)
      .map(jsonDecode);
  var testFilter = (log) => log["name"] == test;
  if (test.endsWith("*")) {
    final prefix = test.substring(0, test.length - 1);
    testFilter = (log) => log["name"].startsWith(prefix);
  }
  var configurationFilter = (log) => log["configuration"] == configuration;
  if (configuration.endsWith("*")) {
    final prefix = configuration.substring(0, configuration.length - 1);
    configurationFilter = (log) => log["configuration"].startsWith(prefix);
  }
  var result = logs
      .where((log) => testFilter(log) && configurationFilter(log))
      .map((log) => log["log"])
      .join("\n\n======================================================\n\n");
  if (result.isEmpty) return null;
  return result;
}
