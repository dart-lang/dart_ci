// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';

import 'package:gcloud/storage.dart';

/// Fetches la(st )test results from the dart-test-results GCS bucket.
class ResultsBucket {
  final Bucket _bucket;

  ResultsBucket(this._bucket);

  Future<List<String>> configurationDirectories() async {
    final mainDirectories = await _bucket
        .list(prefix: 'configuration/main/')
        .where((entry) => entry.isDirectory)
        .map((entry) => entry.name)
        .toSet();
    // Once all builders have run once on the main branch, this search
    // for results from the master branch can be removed.
    final masterDirectories = await _bucket
        .list(prefix: 'configuration/master/')
        .where((entry) => entry.isDirectory)
        .map((entry) => entry.name)
        .where(
          (name) => !mainDirectories.contains(
            name.replaceFirst('configuration/master/', 'configuration/main/'),
          ),
        )
        .toList();
    return [...mainDirectories, ...masterDirectories];
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
    } catch (e) {
      print('Error reading results from $configurationDirectory:');
      print(e);
      return [];
    }
  }
}
