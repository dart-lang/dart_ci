// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Field names and helper functions for result documents and
// commit documents from Firestore.

import 'package:googleapis/firestore/v1.dart' show Value;

// Field names of Result document fields
const fName = 'name';
const fResult = 'result';
const fPreviousResult = 'previous_result';
const fExpected = 'expected';
const fChanged = 'changed';
const fMatches = 'matches';
const fFlaky = 'flaky';
const fPreviousFlaky = 'previous_flaky';
const fPinnedIndex = 'pinned_index';
const fBlamelistStartIndex = 'blamelist_start_index';
const fBlamelistEndIndex = 'blamelist_end_index';
const fApproved = 'approved';
const fActive = 'active';
const fConfigurations = 'configurations';
const fActiveConfigurations = 'active_configurations';
// Fields added to a Result document by addBlamelistHashes()
const fBlamelistStartCommit = 'blamelist_start_commit';
const fBlamelistEndCommit = 'blamelist_end_commit';

// Fields of a results.json change
const fBuilderName = 'builder_name';
const fBuildNumber = 'build_number';
const fConfiguration = 'configuration';
const fCommitHash = 'commit_hash';
const fPreviousCommitHash = 'previous_commit_hash';

// Field names of commit document fields
const fHash = 'hash';
const fIndex = 'index';
const fAuthor = 'author';
const fCreated = 'created';
const fTitle = 'title';
const fReview = 'review';
const fRevertOf = 'revert_of';
const fRelandOf = 'reland_of';

bool isChangedResult(Map<String, dynamic> change) =>
    change[fChanged] && (!change[fFlaky] || !change[fPreviousFlaky]);

/// Whether the change will be marked as an active failure.
/// New flaky tests will not be marked active, so they will appear in the
/// results feed "all", but not turn the builder red
bool isFailure(Map<String, dynamic> change) =>
    !change[fMatches] && change[fResult] != 'flaky';

void transformChange(Map<String, dynamic> change) {
  change[fPreviousResult] ??= 'new test';
  if (change[fPreviousFlaky]) {
    change[fPreviousResult] = 'flaky';
  }
  if (change[fFlaky]) {
    change[fResult] = 'flaky';
    change[fMatches] = false;
  }
}

String? fromStringOrValue(dynamic value) {
  return value is Value ? value.stringValue : value;
}

String testResult(Map<String, dynamic> change) => [
      fromStringOrValue(change[fName]),
      fromStringOrValue(change[fResult]),
      fromStringOrValue(change[fPreviousResult]),
      fromStringOrValue(change[fExpected])
    ].join(' ');

/// The information about a builder, taken from a Result object,
/// that is needed to process the results
class BuildInfo {
  static final commitRefRegExp = RegExp(r'refs/changes/(\d*)/(\d*)');

  final String builderName;
  final int buildNumber;
  final String commitRef;
  final String? previousCommitHash;
  final Set<String> configurations;

  BuildInfo(Map<String, dynamic> result, this.configurations)
      : builderName = result[fBuilderName],
        buildNumber = int.parse(result[fBuildNumber]),
        commitRef = result[fCommitHash],
        previousCommitHash = result[fPreviousCommitHash];

  factory BuildInfo.fromResult(
      Map<String, dynamic> result, Set<String> configurations) {
    final commitRef = result[fCommitHash];
    final match = commitRefRegExp.matchAsPrefix(commitRef);
    if (match == null) {
      return BuildInfo(result, configurations);
    } else {
      return TryBuildInfo(
          result, configurations, int.parse(match[1]!), int.parse(match[2]!));
    }
  }
}

class TryBuildInfo extends BuildInfo {
  final int review;
  final int patchset;

  TryBuildInfo(Map<String, dynamic> result, Set<String> configurations,
      this.review, this.patchset)
      : super(result, configurations);
}

class TestNameLock {
  final locks = <String, Future<void>>{};

  Future<void> guardedCall(Future<void> Function(Map<String, dynamic> change) f,
      Map<String, dynamic> change) async {
    final name = change[fName]!;
    while (locks.containsKey(name)) {
      await locks[name];
    }
    return locks[name] = () async {
      try {
        await f(change);
      } finally {
        // ignore: unawaited_futures
        locks.remove(name);
      }
    }();
  }
}
