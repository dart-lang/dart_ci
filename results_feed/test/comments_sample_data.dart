// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Sample comment records used by comments_test.dart
// This data needs to be modified when new sample data is created
// for the staging database, since it include ids for the result records
// the comments apply to.

final commentId1 = 'sampleId00001';
final commentThreadId = 'sampleId00002';
final commentId2 = 'sampleId00003';
final commentId3 = 'sampleId00004';

final result1 = '1d91eLOxn3mWjJY9qsEO';
final result2 = 'RyMWa5iGfYCjUms0FBU7';
final result3 = 'FkCKOa7uZQdtEpidTYbe';
final result4 = 'JCXiPwG5O7td1X5wjSzA';
final result5 = 'rjDBqGpGiIDOJgimyIid';
final result6 = '';

// These documents are added to the sample database for testing, then removed.
Map<String, dynamic> commentsSampleData = {
  'comments/$commentId1': {
    'author': 'user@example.com',
    'created': DateTime.parse('2019-11-20 20:18:00Z'),
    'comment': 'Sample comment approving a test',
    'approved': true,
    'results': [result1],
    'blamelist_start_index': 66142,
    'blamelist_end_index': 66142
  },
  'comments/$commentThreadId': {
    'author': 'user@example.com',
    'created': DateTime.parse('2019-11-21 20:19:00Z'),
    'comment': 'Sample comment approving 2 tests',
    'approved': true,
    'results': [result2, result3],
    'blamelist_start_index': 66235,
    'blamelist_end_index': 66235
  },
  'comments/$commentId2': {
    'author': 'user@example.com',
    'created': DateTime.parse('2019-11-22 22:19:00Z'),
    'comment': 'Sample comment disapproving 1 of 2 approved tests',
    'approved': false,
    'results': [result3],
    'base_comment': commentThreadId,
    'blamelist_start_index': 66235,
    'blamelist_end_index': 66235
  },
  'comments/$commentId3': {
    'author': 'user2@example.com',
    'created': DateTime.parse('2019-10-31 23:19:00Z'),
    'comment': 'Sample comment on a non-trivial blamelist',
    'approved': true,
    'results': [result4, result5],
    'blamelist_start_index': 66148,
    'blamelist_end_index': 66151
  },
};
