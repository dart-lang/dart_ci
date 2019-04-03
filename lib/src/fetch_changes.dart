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
const bool useStaticData = false; // Used during local testing only.
List<Map<String, dynamic>> changes;

Future<void> fetchData() async {
  if (useStaticData) {
    final changesPath = Resource("package:dart_ci/src/resources/changes.json");
    changes = await loadJsonLines(changesPath);
    return;
  }
  final client = await auth.clientViaMetadataServer();
  var bigQuery = BigqueryApi(client);
  var queryRequestJson = {
    "kind": "bigquery#queryRequest",
    "query": """
SELECT TO_JSON_STRING(t)
FROM `dart-ci.results.results` as t
WHERE _PARTITIONTIME > TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 5 DAY) 
  AND NOT ENDS_WITH(builder_name, '-dev') 
  AND NOT ENDS_WITH(builder_name, '-stable') 
  AND previous_result IS NOT NULL 
  AND changed 
  AND NOT flaky 
  AND NOT previous_flaky
""",
    "maxResults": 5000,
    "timeoutMs": 30000,
    "useQueryCache": true,
    "useLegacySql": false,
    "location": "US"
  };

  final queryRequest = QueryRequest.fromJson(queryRequestJson);
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

  while (numRows > newChanges.length) {
    var job = response.jobReference;
    GetQueryResultsResponse pageResponse = await bigQuery.jobs.getQueryResults(
        job.projectId, job.jobId,
        location: job.location,
        maxResults: 5000,
        pageToken: pageToken,
        timeoutMs: 10000);
    pageToken = pageResponse.pageToken;
    for (var row in response.rows) {
      newChanges.add(json.decode(row.f[0].v));
    }
  }
  if (newChanges.isNotEmpty) {
    changes = newChanges;
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
