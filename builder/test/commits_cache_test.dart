// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:googleapis/firestore/v1.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

import '../lib/src/firestore.dart' as fs;
import '../lib/src/commits_cache.dart';

// These tests read and write data from the Firestore database.
// If they are run against the production database, they will not
// write data to the database.

void main() async {
  final baseClient = http.Client();
  final client = await clientViaApplicationDefaultCredentials(
      scopes: ['https://www.googleapis.com/auth/cloud-platform'],
      baseClient: baseClient);
  final firestore = fs.FirestoreService(FirestoreApi(client), client);
  // create commits cache
  final commits = TestingCommitsCache(firestore, baseClient);
  test('Test fetch first commit', () async {
    Future<void> fetchAndTestCommit(Map<String, dynamic> commit) async {
      final fetched = await commits.getCommit(commit['hash']);
      final copied = Map.from(fetched.toJson())
        ..remove('author')
        ..['hash'] = commit['hash'];
      expect(copied, commit);
    }

    Future<void> fetchAndTestCommitByIndex(Map<String, dynamic> commit) async {
      final fetched = await commits.getCommitByIndex(commit['index']);
      final copied = Map.from(fetched.toJson())
        ..remove('author')
        ..['hash'] = commit['hash'];
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
  tearDownAll(() => baseClient.close());
}

final commit68889 = <String, dynamic>{
  'review': 136974,
  'title': '[Cleanup] Removes deprecated --gc_at_instance_allocation.',
  'index': 68889,
  'created': DateTime.parse('2020-02-26 15:00:26.000Z'),
  'hash': '9c05fde96b62556944befd18ec834c56d6854fda'
};

final commit68890 = <String, dynamic>{
  'review': 136854,
  'title':
      'Add analyzer run support to steamroller and minor QOL improvements.',
  'index': 68890,
  'created': DateTime.parse('2020-02-26 16:57:46.000Z'),
  'hash': '31053a8c0180b663858aadce1ff6c0eefcf78623'
};

final commit68900 = <String, dynamic>{
  'review': 137322,
  'title': 'Remove unused SdkPatcher.',
  'index': 68900,
  'created': DateTime.parse('2020-02-26 20:20:31.000Z'),
  'hash': '118d220bfa7dc0f065b441e4edd584c2b9c0edc8',
};

final commit68905 = <String, dynamic>{
  'review': 137286,
  'title': '[dart2js] switch bot to use hostaserts once again',
  'index': 68905,
  'created': DateTime.parse('2020-02-26 21:41:47.000Z'),
  'hash': '5055c98beeacb3996c256e37148b4dc3561735ee'
};

final commit68910 = <String, dynamic>{
  'review': 137424,
  'title': 'corpus index updates',
  'index': 68910,
  'created': DateTime.parse('2020-02-26 23:19:11.000Z'),
  'hash': '8fb0e62babb213c98f4051f544fc80527bcecc18',
};
