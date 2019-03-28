// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Fetch data about the results that changed from the previous build, from
// BigQuery.

import 'dart:async';
import 'dart:convert';

import 'package:resource/resource.dart' show Resource;
import 'package:googleapis/bigquery/v2.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;

final String PROJECT = "dart-ci";
final bool useStaticData = false; // Used during local testing only.
List<Map<String, dynamic>> changes;

Future<void> fetchData() async {
  if (useStaticData) {
    final changesPath = Resource("package:log/src/resources/changes.json");
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
  QueryResponse response = await bigQuery.jobs.query(queryRequest, "dart-ci");
  int numRows;
  String pageToken;
  if (response.errors != null && response.errors.isNotEmpty) {
    response.errors.forEach((e) => print(e.toJson().toString()));
    return;
  } else {
    numRows = int.parse(response.totalRows);
    pageToken = response.pageToken;
    changes = <Map<String, dynamic>>[];
    for (var row in response.rows) {
      changes.add(json.decode(row.f[0].v));
    }
  }

  while (numRows > changes.length) {
    var job = response.jobReference;
    GetQueryResultsResponse pageResponse = await bigQuery.jobs.getQueryResults(
        job.projectId, job.jobId,
        location: job.location,
        maxResults: 5000,
        pageToken: pageToken,
        timeoutMs: 10000);
    pageToken = pageResponse.pageToken;
    for (var row in response.rows) {
      changes.add(json.decode(row.f[0].v));
    }
  }
}

Future<Object> loadJsonLines(Resource resource) async {
  final json = await resource
      .openRead()
      .transform(utf8.decoder)
      .transform(LineSplitter())
      .toList();
  return List<Map<String, dynamic>>.from(json.map(jsonDecode));
}
