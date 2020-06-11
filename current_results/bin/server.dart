// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:gcloud/storage.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:grpc/grpc.dart';
import 'package:http/http.dart' as http;
import 'package:pool/pool.dart';

import 'package:current_results/src/api_impl.dart';
import 'package:current_results/src/slice.dart';

// For Google Cloud Run, set _hostname to '0.0.0.0'.
var _hostname = '0.0.0.0';

Future initialized;

final current = Slice();

void main(List<String> args) async {
  initialized = loadData();
  var port = int.tryParse(Platform.environment['PORT'] ?? '8081');
  final grpcServer = Server([QueryService(current)]);
  await grpcServer.serve(port: port);
  print('Grpc serving on port ${grpcServer.port}');
}

Future<void> loadData() async {
  // Load files from cloud storage:
  final client = await getAuthenticatedClient();
  final storage = Storage(client, 'dart-ci-staging');
  final bucket = storage.bucket('dart-test-results');

  final configurationDirectories = await bucket
      .list(prefix: 'configuration/master/')
      .where((entry) => entry.isDirectory)
      .toList();
  await Pool(10).forEach(configurationDirectories, (configuration) async {
    print(configuration.name);
    try {
      final revision = await bucket
          .read('${configuration.name}latest')
          .transform(ascii.decoder)
          .transform(LineSplitter())
          .single;
      final results = await bucket
          .read('${configuration.name}$revision/results.json')
          .transform(utf8.decoder)
          .transform(LineSplitter())
          .toList();
      current.add(results);
    } catch (e) {
      print('Error reading results from ${configuration.name}:');
      print(e);
    }
  }).drain();
  print('Records ingested: ${current.size}');
}

Future<AuthClient> getAuthenticatedClient() async {
  final localCredentials =
      Platform.environment['GOOGLE_APPLICATION_CREDENTIALS'];
  if (localCredentials == null) {
    return clientViaMetadataServer();
  } else {
    // When running locally, use "localhost" so service is not exposed.
    _hostname = 'localhost';
    print('Running locally for testing, using local credentials');
    // Set user credentials using gcloud auth login --update-adc
    // or use service account credentials stored locally.
    final credentials =
        json.decode(await File(localCredentials).readAsString());
    final scopes = [
      'https://www.googleapis.com/auth/cloud-platform',
    ];

    if (credentials is Map && credentials['type'] == 'authorized_user') {
      // User credentials - already in the form of authorization tokens.
      return autoRefreshingClient(
        ClientId(credentials['client_id'], credentials['client_secret']),
        AccessCredentials(AccessToken('Bearer', '', DateTime(0).toUtc()),
            credentials['refresh_token'] as String, scopes),
        http.Client(),
      );
    } else {
      // Service credentials.
      return clientViaServiceAccount(
          ServiceAccountCredentials.fromJson(credentials), scopes);
    }
  }
}
