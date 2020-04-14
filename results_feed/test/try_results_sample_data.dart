// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Sample database records used by try_results_test.dart

final createComponentReview = 123;
final createComponentPatchset = 2;
final commentId1 = 'sampleId00001';
final commentText = 'test comment approving a test';

final tryResultsCreateComponentSampleData = <String, dynamic>{
  'reviews/$createComponentReview': {
    'subject': 'Test review for try_results_test \'create component\''
  },
  'reviews/$createComponentReview/patchsets/1': {
    'description': 'initial upload',
    'kind': 'REWORK',
    'number': 1,
    'patchset_group': 1,
  },
  'reviews/$createComponentReview/patchsets/2': {
    'description': 'initial upload',
    'kind': 'REWORK',
    'number': 2,
    'patchset_group': 1,
  },
  'comments/$commentId1': {
    'author': 'user@example.com',
    'created': DateTime.parse('2019-11-20 20:18:00Z'),
    'comment': 'Sample comment approving a test',
    'approved': true,
    'results': [],
    'review': 123
  },
  'try_results/try_result_1': {
    'approved': false,
    'review': 123,
    'configurations': ['unittest-asserts-release-linux'],
    'name': 'pkg/front_end/test/fasta/analyze_test',
    'patchset': 2,
    'result': 'Fail',
    'expected': 'Pass',
    'previous_result': 'Pass'
  },
  'try_results/try_result_2': {
    'approved': false,
    'review': 123,
    'configurations': ['analyzer-asserts-win', 'analyzer-asserts-linux'],
    'name': 'pkg/front_end/test/fasta/analyze_test',
    'patchset': 2,
    'result': 'CompileTimeError',
    'expected': 'Pass',
    'previous_result': 'Pass'
  },
  'try_results/try_result_3': {
    'approved': false,
    'review': 123,
    'configurations': ['analyzer-asserts-win', 'analyzer-asserts-linux'],
    'name': 'sample_suite/sample_test',
    'patchset': 2,
    'result': 'RuntimeError',
    'expected': 'Pass',
    'previous_result': 'Pass'
  },
  'try_results/try_result_4': {
    'approved': true,
    'review': 123,
    'configurations': ['unittest-asserts-release-linux'],
    'name': 'sample_suite/second_test',
    'patchset': 2,
    'result': 'Fail',
    'expected': 'Pass',
    'previous_result': 'Pass'
  },
};
