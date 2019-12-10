// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:test/test.dart';

import '../firestore.dart';
import '../firestore_impl.dart' as fs;

// These tests read and write data from the Firestore database, and
// should only be run locally against the dart-ci-staging project.
// Requires the environment variable GOOGLE_APPLICATION_CREDENTIALS
// to point to a json key to a service account
// with write access to dart_ci_staging datastore.
// Set the database with 'firebase use --add dart-ci-staging'
// The test must be compiled with nodejs, and run using the 'node' command.

void main() {
  final firestore = fs.FirestoreServiceImpl();

  test('Test chunk storing', () async {
    final builder = 'test_builder';
    final index = 123;
    final document = fs.firestore.document('builds/$builder:$index');

    await document.delete();
    await firestore.updateBuildInfo(builder, 3456, index);
    await firestore.storeChunkStatus(builder, index, true);
    await firestore.storeBuildChunkCount(builder, index, 4);
    await firestore.storeChunkStatus(builder, index, true);

    DocumentSnapshot snapshot = await document.get();
    var data = snapshot.data.toMap();
    expect(data['success'], isTrue);
    expect(data['num_chunks'], 4);
    expect(data['processed_chunks'], 2);
    expect(data['completed'], isNull);

    await firestore.storeChunkStatus(builder, index, false);
    await firestore.storeChunkStatus(builder, index, true);

    snapshot = await document.get();
    data = snapshot.data.toMap();
    expect(data['success'], isFalse);
    expect(data['num_chunks'], 4);
    expect(data['processed_chunks'], 4);
    expect(data['completed'], isTrue);
  });
}
