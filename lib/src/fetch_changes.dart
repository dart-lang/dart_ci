// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Fetch data about the results that changed from the previous build, from
// BigQuery.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:googleapis/bigquery/v2.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;

const String project = "dart-ci";
List<Map<String, dynamic>> changes;

Future<void> fetchData() async {
  var client;
  try {
    client = await auth.clientViaMetadataServer();
  } catch (e) {
    print(e);
    // Set GCLOUD_KEY for local testing.
    var keyPath = Platform.environment['GCLOUD_KEY'];
    var key = await File(keyPath).readAsString();
    final scopes = ['https://www.googleapis.com/auth/cloud-platform'];
    client = await auth.clientViaServiceAccount(
        auth.ServiceAccountCredentials.fromJson(key), scopes);
  }
  var bigQuery = BigqueryApi(client);
  try {
    var queryRequestJson = {
      "kind": "bigquery#queryRequest",
      "query": """
SELECT TO_JSON_STRING(t)
FROM `dart-ci.results.results` as t
WHERE _PARTITIONTIME > TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 7 DAY) 
  AND NOT ENDS_WITH(builder_name, '-dev') 
  AND NOT ENDS_WITH(builder_name, '-stable') 
  AND changed 
  AND builder_name != 'dart2js-strong-linux-x64-firefox'
  AND NOT flaky 
  AND (previous_flaky IS NULL OR NOT previous_flaky)
LIMIT 100000
""",
      "maxResults": 10000,
      "timeoutMs": 60000,
      "useQueryCache": true,
      "useLegacySql": false,
      "location": "US"
    };

    final queryRequest = QueryRequest.fromJson(queryRequestJson);
    print("Starting query $queryRequestJson");
    QueryResponse response = await bigQuery.jobs.query(queryRequest, project);
    int numRows;
    String pageToken;
    final newChanges = <Map<String, dynamic>>[];
    if (response.errors != null && response.errors.isNotEmpty) {
      response.errors.forEach((e) => print(e.toJson().toString()));
      return;
    } else {
      numRows = int.parse(response.totalRows);
      pageToken = response.pageToken;
      if (response.rows != null && response.rows.isNotEmpty) {
        for (var row in response.rows) {
          newChanges.add(json.decode(row.f[0].v));
        }
      }
    }
    while (numRows > newChanges.length) {
      var job = response.jobReference;
      GetQueryResultsResponse pageResponse = await bigQuery.jobs
          .getQueryResults(job.projectId, job.jobId,
              location: job.location,
              maxResults: 10000,
              pageToken: pageToken,
              timeoutMs: 30000);
      pageToken = pageResponse.pageToken;

      if (pageResponse.rows != null && pageResponse.rows.isNotEmpty) {
        for (var row in pageResponse.rows) {
          newChanges.add(json.decode(row.f[0].v));
        }
      }
    }
    if (newChanges.isNotEmpty) {
      changes = newChanges;
    }
  } catch (e, t) {
    print(e);
    print(t);
  } finally {
    client.close();
  }
}
