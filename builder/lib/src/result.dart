// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Field names and helper functions for result documents and
// commit documents from Firestore.

import 'dart:convert' show jsonEncode;

import 'package:googleapis/firestore/v1.dart' show Value;

class ResultRecord {
  final Map<String, Value> fields;

  ResultRecord(this.fields);

  bool get approved => fields['approved'].booleanValue;

  @override
  String toString() => jsonEncode(fields);

  int get blamelistEndIndex {
    return int.parse(fields['blamelist_end_index'].integerValue);
  }

  bool containsActiveConfiguration(String configuration) {
    for (final value in fields['active_configurations'].arrayValue.values) {
      if (value.stringValue != null && value.stringValue == configuration) {
        return true;
      }
    }
    return false;
  }
}

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

String fromStringOrValue(dynamic value) {
  return value is Value ? value.stringValue : value;
}

String testResult(Map<String, dynamic> change) => [
      fromStringOrValue(change[fName]),
      fromStringOrValue(change[fResult]),
      fromStringOrValue(change[fPreviousResult]),
      fromStringOrValue(change[fExpected])
    ].join(' ');

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
  final String previousCommitHash;

  BuildInfo(Map<String, dynamic> result)
      : builderName = result['builder_name'],
        buildNumber = int.parse(result['build_number']),
        commitRef = result['commit_hash'],
        previousCommitHash = result['previous_commit_hash'];

  factory BuildInfo.fromResult(Map<String, dynamic> result) {
    final commitRef = result['commit_hash'];
    final match = commitRefRegExp.matchAsPrefix(commitRef);
    if (match == null) {
      return BuildInfo(result);
    } else {
      return TryBuildInfo(result, int.parse(match[1]), int.parse(match[2]));
    }
  }
}

class TryBuildInfo extends BuildInfo {
  final int review;
  final int patchset;

  TryBuildInfo(result, this.review, this.patchset) : super(result);
}
