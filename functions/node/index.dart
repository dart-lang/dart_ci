// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:node_http/node_http.dart' as http;
import 'package:node_interop/node.dart';

import 'builder.dart';
import 'commits_cache.dart';
import 'firestore_impl.dart';
import 'tryjob.dart';

final commits = CommitsCache(FirestoreServiceImpl(), http.NodeClient());

void main() {
  functions['receiveChanges'] =
      functions.pubsub.topic('results').onPublish(receiveChanges);
}

Future<void> receiveChanges(Message message, EventContext context) async {
  final results = (message.json as List).cast<Map<String, dynamic>>();
  final first = results.first;
  final String commit = first['commit_hash'];
  final int countChunks = message.attributes.containsKey('num_chunks')
      ? int.parse(message.attributes['num_chunks'])
      : null;
  final String buildbucketID = message.attributes['buildbucket_id'];
  final String baseRevision = message.attributes['base_revision'];
  try {
    var firestore = FirestoreServiceImpl();
    if (commit.startsWith('refs/changes')) {
      return await Tryjob(commit, countChunks, buildbucketID, baseRevision,
              commits, firestore, http.NodeClient())
          .process(results);
    } else {
      return await Build(commit, first, countChunks, commits, firestore)
          .process(results);
    }
  } catch (e, trace) {
    console.error('Uncaught exception in cloud function', e.toString(),
        trace.toString(), 'first record: $first');
  }
}
