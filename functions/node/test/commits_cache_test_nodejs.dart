// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:node_http/node_http.dart' as http;
import 'package:test/test.dart';

import '../firestore_impl.dart' as fs;
import '../commits_cache.dart';

// These tests read and write data from the Firestore database.
// If they are run against the production database, they will not
// write data to the database.
// Requires the environment variable GOOGLE_APPLICATION_CREDENTIALS
// to point to a json key to a service account.
// To run against the staging database, use a service account.
// with write access to dart_ci_staging datastore.
// Set the database with 'firebase use --add dart-ci-staging'
// The test must be compiled with nodejs, and run using the 'node' command.

void main() async {
  final firestore = fs.FirestoreServiceImpl();
  // create commits cache
  final commits = TestingCommitsCache(firestore, http.NodeClient());
  test('Test fetch first commit', () async {
    Future<void> fetchAndTestCommit(Map<String, dynamic> commit) async {
      final fetched = await commits.getCommit(commit['hash']);
      final copied = Map.from(fetched)..remove('author');
      expect(copied, commit);
    }

    Future<void> fetchAndTestCommitByIndex(Map<String, dynamic> commit) async {
      final fetched = await commits.getCommitByIndex(commit['index']);
      final copied = Map.from(fetched)..remove('author');
      expect(copied, commit);
    }

    expect(commits.startIndex, isNull);
    await fetchAndTestCommit(commit68900);
    expect(commits.startIndex, 68900);
    expect(commits.endIndex, 68900);
    await fetchAndTestCommit(commit68900);
    expect(commits.startIndex, 68900);
    expect(commits.endIndex, 68900);
    await fetchAndTestCommitByIndex(commit68910);
    expect(commits.startIndex, 68900);
    expect(commits.endIndex, 68910);
    await fetchAndTestCommitByIndex(commit68905);
    expect(commits.startIndex, 68900);
    expect(commits.endIndex, 68910);
    await fetchAndTestCommit(commit68905);
    expect(commits.startIndex, 68900);
    expect(commits.endIndex, 68910);
    await fetchAndTestCommitByIndex(commit68890);
    expect(commits.startIndex, 68890);
    expect(commits.endIndex, 68910);
    await fetchAndTestCommitByIndex(commit68889);
    expect(commits.startIndex, 68889);
    expect(commits.endIndex, 68910);
  });
}

final commit68889 = <String, dynamic>{
  'review': 136974,
  'title': '[Cleanup] Removes deprecated --gc_at_instance_allocation.',
  'index': 68889,
  'created': Timestamp.fromDateTime(DateTime.parse("2020-02-26 16:00:26.000")),
  'hash': '9c05fde96b62556944befd18ec834c56d6854fda'
};

final commit68890 = <String, dynamic>{
  'review': 136854,
  'title':
      'Add analyzer run support to steamroller and minor QOL improvements.',
  'index': 68890,
  'created': Timestamp.fromDateTime(DateTime.parse("2020-02-26 17:57:46.000")),
  'hash': '31053a8c0180b663858aadce1ff6c0eefcf78623'
};

final commit68900 = <String, dynamic>{
  'review': 137322,
  'title': 'Remove unused SdkPatcher.',
  'index': 68900,
  'created': Timestamp.fromDateTime(DateTime.parse("2020-02-26 21:20:31.000")),
  'hash': '118d220bfa7dc0f065b441e4edd584c2b9c0edc8',
};

final commit68905 = <String, dynamic>{
  'review': 137286,
  'title': '[dart2js] switch bot to use hostaserts once again',
  'index': 68905,
  'created': Timestamp.fromDateTime(DateTime.parse("2020-02-26 22:41:47.000")),
  'hash': '5055c98beeacb3996c256e37148b4dc3561735ee'
};

final commit68910 = <String, dynamic>{
  'review': 137424,
  'title': 'corpus index updates',
  'index': 68910,
  'created': Timestamp.fromDateTime(DateTime.parse("2020-02-27 00:19:11.000")),
  'hash': '8fb0e62babb213c98f4051f544fc80527bcecc18',
};
