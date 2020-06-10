// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:current_results/src/generated/result.pb.dart' as api;

class Result {
  final String name;
  final String configuration;
  final String commitHash;
  final String result;
  final bool flaky;
  final String expected;
  final Duration time;

  Result(this.name, this.configuration, this.commitHash, this.result,
      this.flaky, this.expected, this.time);

  Result.fromApi(api.Result other)
      : this(
            unique(other.name),
            unique(other.configuration),
            unique(other.commitHash),
            unique(other.result),
            other.flaky,
            unique(other.expected),
            Duration(milliseconds: other.timeMs));

  static final uniqueStrings = Set<String>();

  static String unique(String string) =>
      uniqueStrings.lookup(string) ??
      (uniqueStrings.add(string) ? string : string);

  Map<String, dynamic> toMap() => {
        'name': name,
        'configuration': configuration,
        'commitHash': commitHash,
        'result': result,
        'flaky': flaky,
        'expected': expected,
        'time': time,
      };

  String toString() => toMap().toString();
}
