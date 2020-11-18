// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';

import 'package:gcloud/storage.dart';
import 'package:googleapis_auth/auth_io.dart';

/// Fetches la(st )test results from the dart-test-results GCS bucket.
class ResultsBucket {
  AuthClient client;
  Bucket bucket;

  Future<void> initialize() async {
    client = await clientViaApplicationDefaultCredentials(scopes: [
      'https://www.googleapis.com/auth/devstorage.read_only',
    ]);
    final storage = Storage(client, 'dart-ci');
    bucket = storage.bucket('dart-test-results');
  }

  Future<List<String>> configurationDirectories() => bucket
      .list(prefix: 'configuration/master/')
      .where((entry) => entry.isDirectory)
      .map((entry) => entry.name)
      .toList();

  Future<DateTime> latestResultsDate(String configurationDirectory) async {
    final info = await bucket.info('${configurationDirectory}latest');
    return info.updated;
  }

  Future<List<String>> latestResults(String configurationDirectory) async {
    try {
      final revision = await bucket
          .read('${configurationDirectory}latest')
          .transform(ascii.decoder)
          .transform(LineSplitter())
          .single;
      final results = await bucket
          .read('$configurationDirectory$revision/results.json')
          .transform(utf8.decoder)
          .transform(LineSplitter())
          .toList();
      return results;
    } catch (e) {
      print('Error reading results from $configurationDirectory:');
      print(e);
      return [];
    }
  }
}
