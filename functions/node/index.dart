// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_functions_interop/firebase_functions_interop.dart';

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

  if (commit.startsWith('refs/changes')) {
    return Tryjob(commit, FirestoreServiceImpl()).process(results);
  } else {
    return Build(commit, first, FirestoreServiceImpl()).process(results);
  }
}
