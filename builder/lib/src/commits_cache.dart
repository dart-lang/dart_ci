// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'firestore.dart';
import 'result.dart';

/// Contains data about the commits on the tracked branch of the SDK repo.
///
/// The class fetches commits from Firestore if they are present,
/// and fetches them from gitiles if not, and saves them to Firestore.
/// If a fetch of the latest 1000 commits from gitiles does not find the
/// commit that is missing from Firestore, the request fails.
class CommitsCache {
  FirestoreService firestore;
  final http.Client httpClient;
  Map<String, FutureOr<Commit>> byHash = {};
  Map<int, FutureOr<Commit>> byIndex = {};
  late final Future<void> _fetchCommits = _getNewCommits();

  CommitsCache(this.firestore, this.httpClient);

  FutureOr<Commit> getCommit(String hash) => byHash[hash] ??= _getCommit(hash);
  Future<Commit> _getCommit(String hash) async {
    var commit = await _fetchByHash(hash);
    if (commit == null) {
      await _fetchCommits;
      commit = await _fetchByHash(hash);
    }
    if (commit == null) {
      throw _makeError('getCommit($hash)');
    }
    return commit;
  }

  FutureOr<Commit> getCommitByIndex(int index) =>
      byIndex[index] ??= _fetchByIndex(index);

  String _makeError(String message) {
    final error = 'Failed to fetch commit: $message\n';
    print(error);
    return error;
  }

  Future<Commit?> _fetchByHash(String hash) async {
    final commit = await firestore.getCommit(hash);
    if (commit == null) return null;
    byHash[commit.hash] = commit;
    byIndex[commit.index] = commit;
    return commit;
  }

  Future<Commit> _fetchByIndex(int index) async {
    final commit = await firestore.getCommitByIndex(index);
    byHash[commit.hash] = commit;
    byIndex[commit.index] = commit;
    return commit;
  }

  /// This function is idempotent, so every call of it should write the
  /// same info to new Firestore documents.
  Future<void> _getNewCommits() async {
    const prefix = ")]}'\n";
    final lastCommit = await firestore.getLastCommit();
    final lastHash = lastCommit.hash;
    final lastIndex = lastCommit.index;

    final branch = 'main';
    final logUrl = 'https://dart.googlesource.com/sdk/+log/';
    final range = '$lastHash..$branch';
    final parameters = ['format=JSON', 'topo-order', 'first-parent', 'n=1000'];
    final url = Uri.parse('$logUrl$range?${parameters.join('&')}');
    final response = await httpClient.get(url);
    final protectedJson = response.body;
    if (!protectedJson.startsWith(prefix)) {
      throw Exception('Gerrit response missing prefix $prefix: $protectedJson.'
          'Requested URL: $url');
    }
    final commits = List.castFrom<dynamic, Map<String, dynamic>>(
        jsonDecode(protectedJson.substring(prefix.length))['log']);
    if (commits.isEmpty) {
      print('Found no new commits between $lastHash and $branch');
    }
    print('Fetched new commits from Gerrit (gitiles): $commits');
    final first = commits.last;
    if (first['parents'].first != lastHash) {
      throw 'First new commit ${first['commit']} is not'
          ' a child of last known commit $lastHash when fetching new commits';
    }
    var index = lastIndex + 1;
    for (final commit in commits.reversed) {
      final review = _review(commit);
      var reverted = _revert(commit);
      var relanded = _reland(commit);
      if (relanded != null) {
        reverted = null;
      }
      if (reverted != null) {
        final revertedCommit = await firestore.getCommit(reverted);
        if (revertedCommit != null && revertedCommit.isRevert) {
          reverted = null;
          relanded = revertedCommit.revertOf;
        }
      }
      await firestore.addCommit(commit['commit'], {
        fAuthor: commit['author']['email'],
        fCreated: parseGitilesDateTime(commit['committer']['time']),
        fIndex: index,
        fTitle: commit['message'].split('\n').first,
        if (review != null) fReview: review,
        if (reverted != null) fRevertOf: reverted,
        if (relanded != null) fRelandOf: relanded,
      });
      if (review != null) {
        await landReview(commit, index);
      }
      ++index;
    }
  }

  /// This function is idempotent and may be called multiple times
  /// concurrently.
  Future<void> landReview(Map<String, dynamic> commit, int index) async {
    final review = _review(commit)!;
    // Optimization to avoid duplicate work: if another instance has linked
    // the review to its landed commit, do nothing.
    if (await firestore.reviewIsLanded(review)) return;
    await firestore.linkReviewToCommit(review, index);
    await firestore.linkCommentsToCommit(review, index);
  }
}

class TestingCommitsCache extends CommitsCache {
  TestingCommitsCache(firestore, httpClient) : super(firestore, httpClient);

  @override
  Future<void> _getNewCommits() {
    if (firestore.isStaging) {
      return super._getNewCommits();
    } else {
      return Future.value(null);
    }
  }
}

const months = {
  'Jan': '01',
  'Feb': '02',
  'Mar': '03',
  'Apr': '04',
  'May': '05',
  'Jun': '06',
  'Jul': '07',
  'Aug': '08',
  'Sep': '09',
  'Oct': '10',
  'Nov': '11',
  'Dec': '12'
};

DateTime parseGitilesDateTime(String gitiles) {
  final parts = gitiles.split(' ');
  final year = parts[4];
  final month = months[parts[1]];
  final day = parts[2].padLeft(2, '0');
  return DateTime.parse('$year-$month-$day ${parts[3]} ${parts[5]}');
}

final reviewRegExp = RegExp(
    '^Reviewed-on: https://dart-review.googlesource.com/c/sdk/\\+/(\\d+)\$',
    multiLine: true);

int? _review(Map<String, dynamic> commit) {
  final match = reviewRegExp.firstMatch(commit['message']);
  if (match != null) return int.parse(match.group(1)!);
  return null;
}

final revertRegExp =
    RegExp('^This reverts commit ([\\da-f]+)\\.\$', multiLine: true);

String? _revert(Map<String, dynamic> commit) =>
    revertRegExp.firstMatch(commit['message'])?.group(1);

final relandRegExp =
    RegExp('^This is a reland of ([\\da-f]+)\\.?\$', multiLine: true);

String? _reland(Map<String, dynamic> commit) =>
    relandRegExp.firstMatch(commit['message'])?.group(1);
