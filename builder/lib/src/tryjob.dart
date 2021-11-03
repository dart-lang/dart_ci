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

class Tryjob {
  static final changeRefRegExp = RegExp(r'refs/changes/(\d*)/(\d*)');
  final http.BaseClient httpClient;
  final FirestoreService firestore;
  final CommitsCache commits;
  String builderName;
  String baseRevision;
  String baseResultsHash;
  int buildNumber;
  int review;
  int patchset;
  bool success = true;
  List<Map<String, Value>> landedResults;
  Map<String, Map<String, Value>> lastLandedResultByName = {};
  final String buildbucketID;
  int countChanges = 0;
  int countUnapproved = 0;
  int countNewFlakes = 0;

  Tryjob(String changeRef, this.buildbucketID, this.baseRevision, this.commits,
      this.firestore, this.httpClient) {
    final match = changeRefRegExp.matchAsPrefix(changeRef);
    review = int.parse(match[1]);
    patchset = int.parse(match[2]);
  }

  void log(String string) => firestore.log(string);

  Future<void> update() async {
    await GerritInfo(review, patchset, firestore, httpClient).update();
  }

  bool isNotLandedResult(Map<String, dynamic> change) =>
      !lastLandedResultByName.containsKey(change[fName]) ||
      change[fResult] != lastLandedResultByName[change[fName]][fResult];

  Future<void> process(List<Map<String, dynamic>> results) async {
    await update();
    builderName = results.first['builder_name'];
    buildNumber = int.parse(results.first['build_number']);

    if (!await firestore.updateTryBuildInfo(
        builderName, buildNumber, buildbucketID, review, patchset, success)) {
      // This build's results have already been recorded.
      log('build up-to-date, exiting');
      return;
    }

    baseResultsHash = results.first['previous_commit_hash'];
    final resultsByConfiguration = groupBy<Map<String, dynamic>, String>(
        results.where(isChangedResult), (result) => result['configuration']);

    for (final configuration in resultsByConfiguration.keys) {
      log('Fetching landed results for configuration $configuration');
      if (baseRevision != null && baseResultsHash != null) {
        landedResults = await fetchLandedResults(configuration);
        // Map will contain the last result with each name.
        lastLandedResultByName = {
          for (final result in landedResults)
            getValue(result[fName]) as String: result
        };
      }
      log('Processing results');
      await Pool(30)
          .forEach(
              resultsByConfiguration[configuration].where(isNotLandedResult),
              storeChange)
          .drain();
    }

    log('complete builder record');
    await firestore.completeTryBuilderRecord(
        builderName, review, patchset, success);

    final report = [
      'Processed ${results.length} results from $builderName build $buildNumber',
      'Tryjob on CL $review patchset $patchset',
      if (countChanges > 0) 'Stored $countChanges changes',
      if (!success) 'Found unapproved new failures',
      if (countUnapproved > 0) '$countUnapproved unapproved tests found',
      if (countNewFlakes > 0) '$countNewFlakes new flaky tests found',
      '${firestore.documentsFetched} documents fetched',
      '${firestore.documentsWritten} documents written',
    ];
    log(report.join('\n'));
  }

  Future<void> storeChange(Map<String, dynamic> change) async {
    countChanges++;
    transformChange(change);
    final approved = await firestore.storeTryChange(change, review, patchset);
    if (!approved && isFailure(change)) {
      countUnapproved++;
      success = false;
    }
    if (change[fFlaky] && !change[fPreviousFlaky]) {
      if (++countNewFlakes >= 10) {
        success = false;
      }
    }
  }

  Future<List<Map<String, Value>>> fetchLandedResults(
      String configuration) async {
    final resultsBase = await commits.getCommit(baseResultsHash);
    final rebaseBase = await commits.getCommit(baseRevision);
    final results = <Map<String, Value>>[];
    if (resultsBase.index > rebaseBase.index) {
      print('Try build is rebased on $baseRevision, which is before '
          'the commit $baseResultsHash with CI comparison results');
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
