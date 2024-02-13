// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:gcloud/storage.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:grpc/grpc.dart';
import 'package:pool/pool.dart';

import 'package:current_results/src/api_impl.dart';
import 'package:current_results/src/bucket.dart';
import 'package:current_results/src/slice.dart';
import 'package:current_results/src/notifications.dart';

void main() async {
  final client = await clientViaApplicationDefaultCredentials(scopes: [
    'https://www.googleapis.com/auth/devstorage.read_only',
  ]);
  final bucket = Storage(client, 'dart-ci').bucket('dart-test-results');
  final resultsBucket = ResultsBucket(bucket);
  var port = int.parse(Platform.environment['PORT'] ?? '8080');
  await startServer(port, resultsBucket);
}

Future<void> startServer(int port, ResultsBucket bucket) async {
  final notifications = BucketNotifications();
  await notifications.initialize();
  final current = await loadData(bucket);
  final grpcServer = Server.create(
    services: [QueryService(current, notifications, bucket)],
  );
  await grpcServer.serve(port: port);
  print('Grpc serving on port ${grpcServer.port}');
}

Future<Slice> loadData(ResultsBucket bucket) async {
  final result = Slice();
  final configurationDirectories = await bucket.configurationDirectories();
  await Pool(10).forEach(configurationDirectories,
      (String configurationDirectory) async {
    try {
      final resultsDate =
          await bucket.latestResultsDate(configurationDirectory);
      if (DateTime.now().difference(resultsDate) <= maximumAge) {
        final results = await bucket.latestResults(configurationDirectory);
        result.add(results);
      }
    } catch (e, stack) {
      print('Error loading configuration $configurationDirectory: $e\n$stack');
    }
  }).drain<void>();
  return result;
}
