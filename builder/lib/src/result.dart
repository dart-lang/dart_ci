// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Field names and helper functions for result documents and
// commit documents from Firestore.


import 'firestore_helpers.dart';

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


/// The information about a builder, taken from a Result object,
/// that is needed to process the results
class BuildInfo {
  static final commitRefRegExp = RegExp(r'refs/changes/(\d*)/(\d*)');

  final String builderName;
  final int buildNumber;
  final String commitRef;
  final String? previousCommitHash;
  final Set<String> configurations;

  BuildInfo(ChangeRecord result, this.configurations)
    : builderName = result.builderName,
      buildNumber = result.buildNumber,
      commitRef = result.commitHash,
      previousCommitHash = result.previousCommitHash;

  factory BuildInfo.fromResult(
    ChangeRecord result,
    Set<String> configurations,
  ) {
    final commitRef = result.commitHash;
    final match = commitRefRegExp.matchAsPrefix(commitRef);
    if (match == null) {
      return BuildInfo(result, configurations);
    } else {
      return TryBuildInfo(
        result,
        configurations,
        int.parse(match[1]!),
        int.parse(match[2]!),
      );
    }
  }
}

class TryBuildInfo extends BuildInfo {
  final int review;
  final int patchset;

  TryBuildInfo(super.result, super.configurations, this.review, this.patchset);
}

