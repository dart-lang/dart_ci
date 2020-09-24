// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:grpc/grpc.dart';
import 'package:pool/pool.dart';

import 'package:current_results/src/api_impl.dart';
import 'package:current_results/src/bucket.dart';
import 'package:current_results/src/slice.dart';
import 'package:current_results/src/notifications.dart';

final current = Slice();
final bucket = ResultsBucket();
final notifications = BucketNotifications();
final grpcServer = Server([QueryService(current, notifications, bucket)]);

void main(List<String> args) async {
  await bucket.initialize();
  await notifications.initialize();
  await loadData();
  var port = int.tryParse(Platform.environment['PORT'] ?? '8080');
  await grpcServer.serve(port: port);
  print('Grpc serving on port ${grpcServer.port}');
}

Future<void> loadData() async {
  final configurationDirectories = await bucket.configurationDirectories();
  await Pool(10).forEach(configurationDirectories,
      (configurationDirectory) async {
    final results = await bucket.latestResults(configurationDirectory);
    current.add(results);
  }).drain();
}
