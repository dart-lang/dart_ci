// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:current_results/src/generated/query.pb.dart' as query_api;
import 'package:current_results/src/generated/result.pb.dart' as api;

class Result {
  final String name;
  final String configuration;
  final String commitHash;
  final String result;
  final bool flaky;
  final String expected;
  final Duration time;
  final List<String> experiments;

  Result(this.name, this.configuration, this.commitHash, this.result,
      this.flaky, this.expected, this.time, this.experiments);

  Result.fromApi(api.Result other)
      : this(
            unique(other.name),
            unique(other.configuration),
            unique(other.commitHash),
            unique(other.result),
            other.flaky,
            unique(other.expected),
            Duration(milliseconds: other.timeMs),
            other.experiments.isEmpty
                ? const []
                : other.experiments.map(unique).toList(growable: false));

  Result.nameOnly(String name)
      : this(name, null, null, null, null, null, null, null);

  static final uniqueStrings = <String>{};

  static String unique(String string) =>
      uniqueStrings.lookup(string) ??
      (uniqueStrings.add(string) ? string : string);

  query_api.Result toQueryResult() => query_api.Result()
    ..name = name
    ..configuration = configuration
    ..result = result
    ..timeMs = time.inMilliseconds
    ..expected = expected
    ..flaky = flaky
    ..experiments.addAll(experiments)
    ..revision = commitHash;

  static query_api.Result toApi(Result result) => result.toQueryResult();

  Map<String, dynamic> toMap() => {
        'name': name,
        'configuration': configuration,
        'commitHash': commitHash,
        'result': result,
        'flaky': flaky,
        'expected': expected,
        'time': time,
        'experiments': experiments,
      };

  @override
  String toString() => toMap().toString();
}
