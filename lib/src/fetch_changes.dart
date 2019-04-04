// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Fetch data about the results that changed from the previous build, from
// BigQuery.

import 'dart:async';
import 'dart:convert';

import 'package:googleapis/bigquery/v2.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:resource/resource.dart' show Resource;

const String project = "dart-ci";
const bool useStaticData = true; // Used during local testing only.
List<Map<String, dynamic>> changes;

Future<void> fetchData() async {
  if (useStaticData) {
    final changesPath = Resource("package:dart_ci/src/resources/changes.json");
    changes = await loadJsonLines(changesPath);
    return;
  }
  final client = await auth.clientViaMetadataServer();
  var bigQuery = BigqueryApi(client);
  try {
  var queryRequestJson = {
    "kind": "bigquery#queryRequest",
    "query": """
SELECT TO_JSON_STRING(t)
FROM `dart-ci.results.results` as t
WHERE _PARTITIONTIME > TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 1 DAY) 
  AND NOT ENDS_WITH(builder_name, '-dev') 
  AND NOT ENDS_WITH(builder_name, '-stable') 
  AND changed 
  AND NOT flaky 
  AND (previous_flaky IS NULL OR NOT previous_flaky)
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
    for (var row in response.rows) {
      newChanges.add(json.decode(row.f[0].v));
    }
  }
  print("numRows: $numRows newchanges.length: ${newChanges.length}");
  while (numRows > newChanges.length  && newChanges.length < 50000) {
    print("Getting another page of query responses");
    var job = response.jobReference;
    GetQueryResultsResponse pageResponse = await bigQuery.jobs.getQueryResults(
        job.projectId, job.jobId,
        location: job.location,
        maxResults: 10000,
        pageToken: pageToken,
        timeoutMs: 10000);
    pageToken = pageResponse.pageToken;
    print("numrows: $numRows rows.length ${pageResponse.rows.length} newChagnes.length ${newChanges.length} new numrows: ${pageResponse.totalRows}");  
    for (var row in pageResponse.rows) {
      newChanges.add(json.decode(row.f[0].v));
    }
  }
  if (newChanges.isNotEmpty) {
    changes = newChanges;
  }
} catch (e) {
  print(e);
} finally {
  print("closing client");
  client.close();
}
}

Future<List<Map<String, dynamic>>> loadJsonLines(Resource resource) async {
  final lines = await resource
      .openRead()
      .transform(utf8.decoder)
      .transform(LineSplitter())
      .toList();
  return List<Map<String, dynamic>>.from(lines.map(jsonDecode));
}
