// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'firestore.dart';
import 'result.dart';

/// Contains data about the commits on the master branch of the sdk repo.
/// An instance of this class is stored in a top-level variable, and is
/// shared between cloud function invocations.
///
/// The class fetches commits from Firestore if they are present,
/// and fetches them from gitiles if not, and saves them to Firestore.
class CommitsCache {
  FirestoreService firestore;
  final http.Client httpClient;
  Map<String, Map<String, dynamic>> byHash = {};
  Map<int, Map<String, dynamic>> byIndex = {};
  int startIndex;
  int endIndex;

  CommitsCache(this.firestore, this.httpClient);

  Future<Map<String, dynamic>> getCommit(String hash) async {
    return byHash[hash] ??
        await _fetchByHash(hash) ??
        await _getNewCommits() ??
        await _fetchByHash(hash) ??
        _reportError('getCommit($hash)');
  }

  Future<Map<String, dynamic>> getCommitByIndex(int index) async {
    return byIndex[index] ??
        await _fetchByIndex(index) ??
        await _getNewCommits() ??
        await _fetchByIndex(index) ??
        _reportError('getCommitByIndex($index)');
  }

  Map<String, dynamic> _reportError(String message) {
    final error = "Failed to fetch commit: $message\n"
        "Commit cache holds:\n"
        "  $startIndex: ${byIndex[startIndex]}\n"
        "  ...\n"
        "  $endIndex: ${byIndex[endIndex]}";
    print(error);
    throw error;
  }

  /// Add a commit to the cache. The cache must be empty, or the commit
  /// must be immediately before or after the current cached commits.
  /// Otherwise, do nothing.
  void _cacheCommit(Map<String, dynamic> commit) {
    final index = commit['index'];
    if (startIndex == null || startIndex == index + 1) {
      startIndex = index;
      if (endIndex == null) {
        endIndex = index;
      }
    } else if (endIndex + 1 == index) {
      endIndex = index;
    } else
      return;
    byHash[commit['hash']] = commit;
    byIndex[index] = commit;
  }

  Future<Map<String, dynamic>> _fetchByHash(String hash) async {
    final commit = await firestore.getCommit(hash);
    if (commit == null) return null;
    final index = commit['index'];
    if (startIndex == null) {
      _cacheCommit(commit);
    } else if (index < startIndex) {
      for (int fetchIndex = startIndex - 1; fetchIndex > index; --fetchIndex) {
        // Other invocations may be fetching simultaneously.
        if (fetchIndex < startIndex) {
          final infillCommit = await firestore.getCommitByIndex(fetchIndex);
          _cacheCommit(infillCommit);
        }
      }
      _cacheCommit(commit);
    } else if (index > endIndex) {
      for (int fetchIndex = endIndex + 1; fetchIndex < index; ++fetchIndex) {
        // Other invocations may be fetching simultaneously.
        if (fetchIndex > endIndex) {
          final infillCommit = await firestore.getCommitByIndex(fetchIndex);
          _cacheCommit(infillCommit);
        }
      }
      _cacheCommit(commit);
    }
    return commit;
  }

  Future<Map<String, dynamic>> _fetchByIndex(int index) => firestore
      .getCommitByIndex(index)
      .then((commit) => _fetchByHash(commit['hash']));

  /// This function is idempotent, so every call of it should write the
  /// same info to new Firestore documents.  It is safe to call multiple
  /// times simultaneously.
  Future<Null> _getNewCommits() async {
    const prefix = ")]}'\n";
    final lastCommit = await firestore.getLastCommit();
    final lastHash = lastCommit['hash'];
    final lastIndex = lastCommit['index'];

    final logUrl = 'https://dart.googlesource.com/sdk/+log/';
    final range = '$lastHash..master';
    final parameters = ['format=JSON', 'topo-order', 'n=1000'];
    final url = '$logUrl$range?${parameters.join('&')}';
    final response = await httpClient.get(url);
    final protectedJson = response.body;
    if (!protectedJson.startsWith(prefix))
      throw Exception('Gerrit response missing prefix $prefix: $protectedJson');
    final commits = jsonDecode(protectedJson.substring(prefix.length))['log']
        as List<dynamic>;
    if (commits.isEmpty) {
      print('Found no new commits between $lastHash and master');
      return;
    }
    print('Fetched new commits from Gerrit (gitiles): $commits');
    final first = commits.last as Map<String, dynamic>;
    if (first['parents'].first != lastHash) {
      throw 'First new commit ${first['parents'].first} is not'
          ' a child of last known commit $lastHash when fetching new commits';
    }
    var index = lastIndex + 1;
    for (Map<String, dynamic> commit in commits.reversed) {
      final review = _review(commit);
      var reverted = _revert(commit);
      var relanded = _reland(commit);
      if (relanded != null) {
        reverted = null;
      }
      if (reverted != null) {
        final revertedCommit = await firestore.getCommit(reverted);
        if (revertedCommit != null && revertedCommit[fRevertOf] != null) {
          reverted = null;
          relanded = revertedCommit[fRevertOf];
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
    int review = _review(commit);
    // Optimization to avoid duplicate work: if another instance has linked
    // the review to its landed commit, do nothing.
    if (await firestore.reviewIsLanded(review)) return;
    await firestore.linkReviewToCommit(review, index);
    await firestore.linkCommentsToCommit(review, index);
  }
}

class TestingCommitsCache extends CommitsCache {
  TestingCommitsCache(firestore, httpClient) : super(firestore, httpClient);

  Future<Null> _getNewCommits() async {
    if ((await firestore.isStaging())) {
      return super._getNewCommits();
    }
  }
}

const months = const {
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

int _review(Map<String, dynamic> commit) {
  final match = reviewRegExp.firstMatch(commit['message']);
  if (match != null) return int.parse(match.group(1));
  return null;
}

final revertRegExp =
    RegExp('^This reverts commit ([\\da-f]+)\\.\$', multiLine: true);

String _revert(Map<String, dynamic> commit) =>
    revertRegExp.firstMatch(commit['message'])?.group(1);

final relandRegExp =
    RegExp('^This is a reland of ([\\da-f]+)\\.?\$', multiLine: true);

String _reland(Map<String, dynamic> commit) =>
    relandRegExp.firstMatch(commit['message'])?.group(1);
