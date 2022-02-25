// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert' show jsonEncode;

import 'firestore.dart';
import 'result.dart';

class BuildStatus {
  static const unapprovedFailuresLimit = 10;
  bool success = true;
  bool truncatedResults = false;
  Map<String, List<SafeDocument>> unapprovedFailures = {};

  String toJson() {
    return jsonEncode({
      'success': success && unapprovedFailures.isEmpty,
      'truncatedResults': truncatedResults,
      'unapprovedFailures': unapprovedFailuresReport(),
    });
  }

  String unapprovedFailuresReport() {
    if (unapprovedFailures.isEmpty) return '';
    if (unapprovedFailures.containsKey('failed')) {
      return 'There are unapproved failures. Error fetching details';
    }
    return [
      'There are unapproved failures',
      for (final entry in unapprovedFailures.entries) ...[
        '  ${entry.key}:',
        for (final result in entry.value.take(unapprovedFailuresLimit))
          resultLine(result),
        if (entry.value.length > unapprovedFailuresLimit) '    ...'
      ],
      ''
    ].join('\n');
  }
}

String resultLine(SafeDocument result) {
  final name = result.getString(fName);
  final previous = result.getString(fPreviousResult);
  final current = result.getString(fResult);
  final expected = result.getString(fExpected);
  final start = result.getString(fBlamelistStartCommit);
  final end = result.getString(fBlamelistEndCommit);
  final range = start == end
      ? start.substring(0, 6)
      : '${start.substring(0, 6)}..${end.substring(0, 6)}';
  return '    $name   ($previous -> $current , expected $expected ) at $range';
}
