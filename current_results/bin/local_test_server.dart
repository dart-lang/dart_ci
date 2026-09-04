// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:current_results/src/bucket.dart'
    show ResultsBucket, UserVisibleFailure, filterLogs, validateLogRequest;

import 'server.dart' show startServer;

/// A [ResultsBucket] that reads a local directory instead of fetching the
/// data from cloud storage.
///
/// This class does not read `latest` files; the expected layout is a
/// directory with multiple subdirectories, each containing a file called
/// 'results.json'.
class DirectoryBasedBucket implements ResultsBucket {
  final Directory base;

  DirectoryBasedBucket(String path) : base = Directory(path);

  @override
  Future<List<String>> configurationDirectories() {
    return base
        .list()
        .where((entity) => entity is Directory)
        .map((entity) => entity.path)
        .toList();
  }

  @override
  Future<List<String>> latestResults(String configurationDirectory) {
    return File('$configurationDirectory/results.json').readAsLines();
  }

  @override
  Future<DateTime> latestResultsDate(String configurationDirectory) {
    return Future.value(DateTime.now());
  }

  Future<String> _read(String path) async {
    final file = File('${base.path}/$path');
    if (await file.exists()) {
      return await file.readAsString();
    }
    final stripped = path
        .replaceFirst('configuration/main/', '')
        .replaceFirst('builders/', '');
    final altFile = File('${base.path}/$stripped');
    if (await altFile.exists()) {
      return await altFile.readAsString();
    }
    throw UserVisibleFailure('File $path not found in ${base.path}');
  }

  @override
  Future<String> latestBuild(String builder) async {
    final content = await _read('builders/$builder/latest');
    return content.trim();
  }

  @override
  Future<String> latestConfigurationBuild(String configuration) async {
    final content = await _read('configuration/main/$configuration/latest');
    return content.trim();
  }

  @override
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

    final localPath = builder == 'any'
        ? 'configuration/main/$configuration/$build/logs.json'
        : 'builders/$builder/$build/logs.json';
    final jsonLogs = await _read(localPath);
    return filterLogs(jsonLogs, configuration: configuration, test: test);
  }
}

void main(List<String> args) async {
  if (args.isEmpty) {
    stderr.writeln('Usage: local_test_server <directory>');
    exit(1);
  }
  var resultsBucket = DirectoryBasedBucket(args.single);
  var port = int.parse(Platform.environment['PORT'] ?? '8080');
  await startServer(port, resultsBucket);
}
