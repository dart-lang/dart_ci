// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Sample comment records used by comments_test.dart
// This data needs to be modified when new sample data is created
// for the staging database, since it include ids for the result records
// the comments apply to.

final commentId1 = 'sampleId00001';
final commentId2 = 'sampleId00002';
final commentId3 = 'sampleId00003';

final result1 = 'sample_result_1';

// These documents are added to the sample database for testing, then removed.
Map<String, Map<String, dynamic>> createCommentsSampleData(int lastIndex) {
  final startIndex = lastIndex - 2;
  final endIndex = lastIndex;
  final commentTime = DateTime.now().subtract(Duration(days: 2));
  return {
    'results/$result1': {
      'approved': false,
      'configurations': ['analyzer-asserts-win', 'analyzer-asserts-linux'],
      'name': 'sample_suite/sample_test',
      'result': 'RuntimeError',
      'expected': 'Pass',
      'previous_result': 'Pass',
      'blamelist_start_index': startIndex,
      'blamelist_end_index': endIndex,
    },
    'comments/$commentId1': {
      'author': 'user@example.com',
      'created': commentTime,
      'comment': 'Sample comment approving a test',
      'approved': true,
      'results': [result1],
      'blamelist_start_index': startIndex,
      'blamelist_end_index': endIndex,
    },
    'comments/$commentId2': {
      'author': 'user@example.com',
      'created': commentTime,
      'comment': 'Sample comment approving 2 tests',
      'approved': true,
      'results': [result1],
      'blamelist_start_index': startIndex,
      'blamelist_end_index': endIndex,
    },
    'comments/$commentId3': {
      'author': 'user@example.com',
      'created': commentTime,
      'comment': 'Sample comment disapproving 1 of 2 approved tests',
      'approved': false,
      'results': [result1],
      'blamelist_start_index': startIndex,
      'blamelist_end_index': endIndex,
    },
  };
}
