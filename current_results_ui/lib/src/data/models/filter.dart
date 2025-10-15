// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of a source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:collection/collection.dart';

class Filter {
  final List<String> terms;
  Filter(String termString) : terms = _parse(termString);

  static List<String> _parse(String termString) {
    if (termString.trim() == '') return List.unmodifiable([]);
    return List.unmodifiable(termString.split(',').map((s) => s.trim()));
  }

  @override
  bool operator ==(Object other) =>
      other is Filter && const ListEquality().equals(terms, other.terms);

  @override
  int get hashCode => const ListEquality().hash(terms);
}
