// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Displays the log for a failing test on a given runner and build
library;

import 'dart:async';
import 'dart:convert';

import 'package:_discoveryapis_commons/_discoveryapis_commons.dart';
import 'package:googleapis/storage/v1.dart' as storage;
import 'package:http/http.dart' as http;

final resultsBucket = 'dart-test-results';

class UserVisibleFailure {
  final String message;

  UserVisibleFailure(this.message);

  @override
  String toString() => "error: $message";
}

Future<String> getCloudFile(String bucket, String path) async {
  final client = http.Client();
  try {
    final api = storage.StorageApi(client);
    final media =
        await api.objects.get(
              bucket,
              path,
              downloadOptions: DownloadOptions.fullMedia,
            )
            as Media;
    return await utf8.decodeStream(media.stream);
  } catch (e) {
    throw UserVisibleFailure(
      'Failure when fetching $path from $bucket in cloud storage',
    );
  } finally {
    client.close();
  }
}

Future<String> getLatestBuildNumber(String builder) =>
    getCloudFile(resultsBucket, "builders/$builder/latest");

Future<String> getLatestConfigurationBuildNumber(String configuration) =>
    getCloudFile(resultsBucket, 'configuration/main/$configuration/latest');

/// Fetches a log or logs and formats them for output.
Future<String?> getLog(
  String builder,
  String build,
  String configuration,
  String test,
) async {
  final safeRegExp = RegExp('^[-\\w]*\$');
  final digitsRegExp = RegExp('^\\d*\$');
  if (!safeRegExp.hasMatch(builder)) {
    throw UserVisibleFailure(
      "Builder name $builder contains illegal characters",
    );
  }
  if (builder == 'any') {
    if (configuration.endsWith('*')) {
      throw UserVisibleFailure(
        'Wildcard not allowed in configuration with builder "any"',
      );
    }
    if (!safeRegExp.hasMatch(configuration)) {
      throw UserVisibleFailure(
        'Configuration name $configuration contains illegal characters',
      );
    }
  }
  if (!digitsRegExp.hasMatch(build)) {
    throw UserVisibleFailure('Build number $build is not a number');
  }

  final cloudFile = builder == 'any'
      ? 'configuration/main/$configuration/$build/logs.json'
      : 'builders/$builder/$build/logs.json';
  final jsonLogs = await getCloudFile(resultsBucket, cloudFile);

  final logs = LineSplitter.split(jsonLogs)
      .where((line) => line.isNotEmpty)
      .map(jsonDecode)
      .cast<Map<String, dynamic>>();
  bool Function(Map<String, dynamic>) testFilter = (Map<String, dynamic> log) =>
      log['name'] == test;
  if (test.endsWith('*')) {
    final prefix = test.substring(0, test.length - 1);
    testFilter = (Map<String, dynamic> log) => log['name'].startsWith(prefix);
  }
  bool Function(Map<String, dynamic>) configurationFilter =
      (Map<String, dynamic> log) => log['configuration'] == configuration;
  if (configuration.endsWith('*')) {
    final prefix = configuration.substring(0, configuration.length - 1);
    configurationFilter = (Map<String, dynamic> log) =>
        log['configuration'].startsWith(prefix);
  }
  var result = logs
      .where((log) => testFilter(log) && configurationFilter(log))
      .map((log) => log['log'])
      .join('\n\n======================================================\n\n');
  if (result.isEmpty) return null;
  return result;
}
