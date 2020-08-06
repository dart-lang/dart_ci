// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Field names and helper functions for result documents and
// commit documents from Firestore.

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

bool isChangedResult(Map<String, dynamic> change) => change[fChanged];

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

String testResult(Map<String, dynamic> change) => [
      change[fName],
      change[fResult],
      change[fPreviousResult],
      change[fExpected]
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
