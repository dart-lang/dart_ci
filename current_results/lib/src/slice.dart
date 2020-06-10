// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'package:collection/collection.dart';

import 'package:current_results/src/result.dart';
import 'package:current_results/src/generated/result.pb.dart' as api;

class Slice {
  /// The current results, stored separately for each configuration in a
  /// list sorted by test name.
  final _stored = <String, List<Result>>{};

  /// A sorted list of all test names seen. Names are not removed from this list.
  List<String> testNames = [];
  int _size = 0;

  int get size => _size;

  void add(List<String> lines) {
    if (lines.isEmpty) return;
    final results = lines.map((line) => Result.fromApi(api.Result()
      ..mergeFromProto3Json(json.decode(line),
          supportNamesWithUnderscores: true)));
    final configuration = results.first.configuration;
    if (results.any((result) => result.configuration != configuration)) {
      print('Loaded results list with multiple configurations: '
          'first result: ${results.first}');
      return;
    }
    int compareNames(Result a, Result b) => a.name.compareTo(b.name);
    final sorted = results.toList()..sort(compareNames);
    _size -= _stored[configuration]?.length ?? 0;
    _stored[configuration] = sorted;
    _size += sorted.length;
    if (!sorted.every(Scanner(testNames).found)) {
      testNames = merge(testNames, sorted);
    }
  }

  List<String> merge(List<String> names, List<Result> sorted) {
    final result = <String>[];
    var i = 0;
    var j = 0;
    while (i < names.length && j < sorted.length) {
      final compare = names[i].compareTo(sorted[j].name);
      if (compare <= 0) {
        result.add(names[i++]);
        if (compare == 0) j++;
      } else {
        result.add(sorted[j++].name);
      }
    }
    while (i < names.length) {
      result.add(names[i++]);
    }
    while (j < sorted.length) {
      result.add(sorted[j++].name);
    }
    return result;
  }
}

class Scanner {
  List<String> names;
  int position = 0;

  Scanner(this.names);

  bool found(Result a) {
    while (position < names.length) {
      if (names[position].compareTo(a.name) < 0) {
        position++;
      } else {
        return names[position] == a.name;
      }
    }
    return false;
  }
}
