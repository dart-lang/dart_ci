// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:node_io/node_io.dart';

// Imports sample data into the staging/testing Firestore.
// This sample data is exported from the production database by running
// the extract_recent.dart program.
// Requires the environment variable GOOGLE_APPLICATION_CREDENTIALS
// to point to a json key to a service account
// with write access to dart_ci_staging datastore.

Firestore firestore = createFirestore();

// Creates a Firestore object referring to the dart-ci-staging's database.
Firestore createFirestore() {
  final app = FirebaseAdmin.instance.initializeApp(AppOptions(
      databaseURL: "https://dart-ci-staging.firebaseio.com",
      projectId: 'dart-ci-staging'));
  return app.firestore()
    ..settings(FirestoreSettings(timestampsInSnapshots: true));
}

dynamic reviver(dynamic key, dynamic object) {
  if (key != 'created') return object;
  return Timestamp.fromDateTime(DateTime.parse(object));
}

void main(args) async {
  // Filename is hardcoded because argv is not available on Dart nodejs.
  final file = new File('staging_sample_data');
  final object = jsonDecode(await file.readAsStringSync(), reviver: reviver);
  await storeData(object);
}

Future<void> storeData(Map<String, dynamic> object) async {
  for (final documentPath in object.keys) {
    await firestore
        .document(documentPath)
        .setData(DocumentData.fromMap(object[documentPath]));
  }
}
