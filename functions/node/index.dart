// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:node_http/node_http.dart' as http;

import 'builder.dart';
import 'firestore_impl.dart';
import 'tryjob.dart';

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
  try {
    var firestore = FirestoreServiceImpl();
    if (commit.startsWith('refs/changes')) {
      return await Tryjob(
              commit, countChunks, buildbucketID, firestore, http.NodeClient())
          .process(results);
    } else {
      return await Build(
              commit, first, countChunks, firestore, http.NodeClient())
          .process(results);
    }
  } catch (e) {
    print('Exception when processing message. First record is:\n$first');
    rethrow;
  }
}
