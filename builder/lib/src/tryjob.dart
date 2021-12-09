// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:collection/collection.dart';
import 'package:googleapis/firestore/v1.dart';
import 'package:http/http.dart' as http show BaseClient;
import 'package:pool/pool.dart';

import 'commits_cache.dart';
import 'firestore.dart';
import 'gerrit_change.dart';
import 'result.dart';

class ChangeCounter {
  static const maxReportedSuccesses = 1000;
  static const maxReportedFailures = 1000;

  int changes = 0;
  int passes = 0;
  int failures = 0;
  int unapprovedFailures = 0;
  int newFlakes = 0;
  bool hasTruncatedChanges = false;

  bool get hasTooManyFlakes => newFlakes >= 10;
  bool get hasTooManyPassingChanges => passes > maxReportedSuccesses;
  bool get hasTooManyFailingChanges => failures > maxReportedFailures;

  void count(Map<String, dynamic> change) {
    ++changes;
    change[fMatches] ? ++passes : ++failures;
    if (change[fFlaky] && !change[fPreviousFlaky]) ++newFlakes;
  }

  bool isNotReported(Map<String, dynamic> change) {
    if (change[fMatches] && hasTooManyPassingChanges ||
        !change[fMatches] && hasTooManyFailingChanges) {
      hasTruncatedChanges = true;
      return true;
    }
    return false;
  }

  List<String> report() => [
        if (changes > 0) 'Stored $changes changes',
        if (hasTruncatedChanges) 'Did not store all results. Truncating.',
        if (hasTooManyPassingChanges)
          'Only $maxReportedSuccesses new passes stored',
        if (hasTooManyFailingChanges)
          'Only $maxReportedFailures new failures stored',
        if (unapprovedFailures > 0)
          '$unapprovedFailures unapproved failing tests found',
        if (failures > 0) '$failures failing tests found',
        if (passes > 0) '$passes passing tests found',
        if (newFlakes > 0) '$newFlakes new flaky tests found',
      ];
}

class Tryjob {
  final http.BaseClient httpClient;
  final FirestoreService firestore;
  final CommitsCache commits;
  final counter = ChangeCounter();
  TryBuildInfo info;
  final TestNameLock testNameLock = TestNameLock();
  String baseRevision;
  bool success = true;
  List<Map<String, Value>> landedResults;
  Map<String, Map<String, Value>> lastLandedResultByName = {};
  final String buildbucketID;

  Tryjob(this.info, this.buildbucketID, this.baseRevision, this.commits,
      this.firestore, this.httpClient);

  void log(String string) => firestore.log(string);

  Future<void> update() async {
    await GerritInfo(info.review, info.patchset, firestore, httpClient)
        .update();
  }

  bool isNotLandedResult(Map<String, dynamic> change) {
    return !lastLandedResultByName.containsKey(change[fName]) ||
        change[fResult] !=
            lastLandedResultByName[change[fName]][fResult].stringValue;
  }

  Future<void> process(List<Map<String, dynamic>> results) async {
    await update();
    log('storing ${results.length} change(s)');
    final resultsByConfiguration = groupBy<Map<String, dynamic>, String>(
        results, (result) => result['configuration']);

    for (final configuration in resultsByConfiguration.keys) {
      if (baseRevision != null && info.previousCommitHash != null) {
        landedResults = await fetchLandedResults(configuration);
        // Map will contain the last result with each name.
        lastLandedResultByName = {
          for (final result in landedResults)
            getValue(result[fName]) as String: result
        };
      }
      final changes =
          resultsByConfiguration[configuration].where(isNotLandedResult);
      await Pool(30).forEach(changes, guardedStoreChange).drain();
    }

    if (counter.hasTooManyFlakes) {
      success = false;
    }
    await firestore.recordTryBuild(
        info, buildbucketID, success, counter.hasTruncatedChanges);
    final report = [
      'Processed ${results.length} results from ${info.builderName} build ${info.buildNumber}',
      'Tryjob on CL ${info.review} patchset ${info.patchset}',
      if (!success) 'Found unapproved new failures',
      ...counter.report(),
      '${firestore.documentsFetched} documents fetched',
      '${firestore.documentsWritten} documents written',
    ];
    log(report.join('\n'));
  }

  Future<void> guardedStoreChange(Map<String, dynamic> change) =>
      testNameLock.guardedCall(storeChange, change);

  Future<void> storeChange(Map<String, dynamic> change) async {
    transformChange(change);
    counter.count(change);
    if (counter.isNotReported(change)) return;
    final approved =
        await firestore.storeTryChange(change, info.review, info.patchset);
    if (!approved && isFailure(change)) {
      counter.unapprovedFailures++;
      success = false;
    }
  }

  Future<List<Map<String, Value>>> fetchLandedResults(
      String configuration) async {
    final resultsBase = await commits.getCommit(info.previousCommitHash);
    final rebaseBase = await commits.getCommit(baseRevision);
    final results = <Map<String, Value>>[];
    if (resultsBase.index > rebaseBase.index) {
      print('Try build is rebased on $baseRevision, which is before '
          'the commit ${info.previousCommitHash} with CI comparison results');
      return results;
    }
    final reviews = <int>[];
    for (var index = resultsBase.index + 1;
        index <= rebaseBase.index;
        ++index) {
      final commit = await commits.getCommitByIndex(index);
      if (commit.review != null) {
        reviews.add(commit.review);
      }
    }
    for (final landedReview in reviews) {
      results.addAll(await firestore.tryResults(landedReview, configuration));
    }
    return results;
  }
}
