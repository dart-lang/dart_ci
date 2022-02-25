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
  final Map<String, List<ResultRecord>> unapprovedFailures = {};

  String toJson() {
    return jsonEncode({
      'success': success && unapprovedFailures.isEmpty,
      'truncatedResults': truncatedResults,
      'unapprovedFailures': unapprovedFailuresReport(),
    });
  }

  String unapprovedFailuresReport() {
    if (unapprovedFailures.isEmpty) return '';
    String resultLine(ResultRecord result) => '';
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
