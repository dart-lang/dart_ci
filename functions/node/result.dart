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

bool isChangedResult(Map<String, dynamic> change) =>
    change[fChanged] && !change[fFlaky] && !change[fPreviousFlaky];

bool isFailure(Map<String, dynamic> change) => !change[fMatches];

String testResult(Map<String, dynamic> change) => [
      change[fName],
      change[fResult],
      change[fPreviousResult] ?? 'new test',
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
