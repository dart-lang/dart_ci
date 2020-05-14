// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;
import 'package:gcloud/storage.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart';

import '../gen/result.pbserver.dart';

// For Google Cloud Run, set _hostname to '0.0.0.0'.
var _hostname = '0.0.0.0';

Future initialized;

void main(List<String> args) async {
  initialized = loadData();
  var port = int.tryParse(Platform.environment['PORT'] ?? '8080');
  var handler = const shelf.Pipeline()
      .addMiddleware(shelf.logRequests())
      .addHandler(_echoRequest);

  var server = await io.serve(handler, _hostname, port);
  print('Serving at http://${server.address.host}:${server.port}');
}

Future<void> loadData() async {
  // Load files from cloud storage:
  final AuthClient client = await getAuthenticatedClient();
  final storage = Storage(client, 'dart-ci-staging');
  final bucket = storage.bucket('dart-test-results');

  await for (final configuration
      in bucket.list(prefix: 'configuration/master/')) {
    if (configuration.isDirectory) {
      try {
        final revision = await bucket
            .read('${configuration.name}latest')
            .transform(ascii.decoder)
            .transform(LineSplitter())
            .single;
        final lines = await bucket
            .read('${configuration.name}$revision/results.json')
            .transform(utf8.decoder)
            .transform(LineSplitter());
        await for (final line in lines) {
          final result = Result()
            ..mergeFromProto3Json(json.decode(line),
                supportNamesWithUnderscores: true);
          data.add(CurrentResult.fromResult(result));
        }
      } catch (e) {
        print('Error reading results from ${configuration.name}:');
        print(e);
      }
    }
  }
  print("Records ingested: ${data.length}");
}

class CurrentResult {
  final String name;
  final String configuration;
  final String commitHash;
  final String result;
  final bool flaky;
  final String expected;
  final Duration time;

  CurrentResult(this.name, this.configuration, this.commitHash, this.result,
      this.flaky, this.expected, this.time);

  CurrentResult.fromResult(Result other)
      : this(
            unique(other.name),
            unique(other.configuration),
            unique(other.commitHash),
            unique(other.result),
            other.flaky,
            unique(other.expected),
            Duration(milliseconds: other.timeMs));
}

final set = Set<String>();
final data = <CurrentResult>[];

String unique(String string) =>
    set.lookup(string) ?? (set.add(string) ? string : string);

Map<String, dynamic> canonicalize(Map<String, dynamic> map) => {
      for (final entry in map.entries)
        unique(entry.key):
            (entry.value is String) ? unique(entry.value) : entry.value
    };

Future<shelf.Response> _echoRequest(shelf.Request request) async {
  print("Request ${request.url} received");
  await initialized;
  return shelf.Response.ok('Number of results: ${data.length}\n'
      'Number of unique strings ${set.length}');
}

Future<AuthClient> getAuthenticatedClient() async {
  AuthClient result;
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
        Client(),
      );
    } else {
      // Service credentials.
      return clientViaServiceAccount(
          ServiceAccountCredentials.fromJson(credentials), scopes);
    }
  }
}
