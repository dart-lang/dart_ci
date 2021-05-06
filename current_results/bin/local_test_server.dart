// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:current_results/src/bucket.dart' show ResultsBucket;

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
}

void main(List<String> args) async {
  var resultsBucket = DirectoryBasedBucket(args.single);
  var port = int.tryParse(Platform.environment['PORT'] ?? '8080');
  await startServer(port, resultsBucket);
}
