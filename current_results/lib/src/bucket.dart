// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';

import 'package:gcloud/storage.dart';
import 'package:logging/logging.dart';

/// Fetches la(st )test results from the dart-test-results GCS bucket.
final _log = Logger('bucket');

class UserVisibleFailure implements Exception {
  final String message;

  UserVisibleFailure(this.message);

  @override
  String toString() => 'error: $message';
}

void validateLogRequest({
  required String builder,
  required String build,
  required String configuration,
}) {
  final safeRegExp = RegExp(r'^[-\w]*$');
  final digitsRegExp = RegExp(r'^\d*$');
  if (!safeRegExp.hasMatch(builder)) {
    throw UserVisibleFailure(
      'Builder name $builder contains illegal characters',
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
}

String? filterLogs(
  String jsonLogs, {
  required String configuration,
  required String test,
}) {
  final logs = LineSplitter.split(jsonLogs)
      .where((line) => line.isNotEmpty)
      .map(jsonDecode)
      .cast<Map<String, dynamic>>();
  bool Function(Map<String, dynamic>) testFilter = (Map<String, dynamic> log) =>
      log['name'] == test;
  if (test.endsWith('*')) {
    final prefix = test.substring(0, test.length - 1);
    testFilter = (Map<String, dynamic> log) =>
        (log['name'] as String).startsWith(prefix);
  }
  bool Function(Map<String, dynamic>) configurationFilter =
      (Map<String, dynamic> log) => log['configuration'] == configuration;
  if (configuration.endsWith('*')) {
    final prefix = configuration.substring(0, configuration.length - 1);
    configurationFilter = (Map<String, dynamic> log) =>
        (log['configuration'] as String).startsWith(prefix);
  }
  final result = logs
      .where((log) => testFilter(log) && configurationFilter(log))
      .map((log) => log['log'] as String)
      .join('\n\n======================================================\n\n');
  if (result.isEmpty) return null;
  return result;
}

class ResultsBucket {
  final Bucket _bucket;

  ResultsBucket(this._bucket);

  Future<List<String>> configurationDirectories() async {
    final mainDirectories = await _bucket
        .list(prefix: 'configuration/main/')
        .where((entry) => entry.isDirectory)
        .map((entry) => entry.name)
        .toSet();
    return [...mainDirectories];
  }

  Future<DateTime> latestResultsDate(String configurationDirectory) async {
    final info = await _bucket.info('${configurationDirectory}latest');
    return info.updated;
  }

  Future<List<String>> latestResults(String configurationDirectory) async {
    try {
      final revision = await _bucket
          .read('${configurationDirectory}latest')
          .transform(ascii.decoder)
          .transform(LineSplitter())
          .single;
      final results = await _bucket
          .read('$configurationDirectory$revision/results.json')
          .transform(utf8.decoder)
          .transform(LineSplitter())
          .toList();
      return results;
    } catch (e, st) {
      _log.severe('Error reading results from $configurationDirectory', e, st);
      return [];
    }
  }

  Future<String> _read(String path) async {
    try {
      return await _bucket.read(path).transform(utf8.decoder).join();
    } catch (e) {
      throw UserVisibleFailure(
        'Failure when fetching $path from ${_bucket.bucketName} in cloud storage',
      );
    }
  }

  Future<String> latestBuild(String builder) async {
    final content = await _read('builders/$builder/latest');
    return content.trim();
  }

  Future<String> latestConfigurationBuild(String configuration) async {
    final content = await _read('configuration/main/$configuration/latest');
    return content.trim();
  }

  /// Fetches logs for a test and formats them for output.
  Future<String?> logs(
    String builder,
    String build,
    String configuration,
    String test,
  ) async {
    validateLogRequest(
      builder: builder,
      build: build,
      configuration: configuration,
    );

    final cloudFile = builder == 'any'
        ? 'configuration/main/$configuration/$build/logs.json'
        : 'builders/$builder/$build/logs.json';
    final jsonLogs = await _read(cloudFile);
    return filterLogs(jsonLogs, configuration: configuration, test: test);
  }
}
