// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test/test.dart';
import 'package:current_results/src/iterable.dart';

int intIdentity(int i) => i;

void main() {
  test('merge int lists', () {
    final a = [1, 2, 4];
    final b = [3];
    final c = [2, 5];
    final empty = <int>[];
    expect(merge(a, b, intIdentity), [1, 2, 3, 4]);
    expect(merge(a, c, intIdentity), [1, 2, 2, 4, 5]);
    expect(merge(b, b, intIdentity), [3, 3]);
    expect(merge(c, c, intIdentity), [2, 2, 5, 5]);
    expect(merge(empty, empty, intIdentity), []);
    expect(merge<int, int>([], [], intIdentity), []);
    expect(merge(a, empty, intIdentity), a);
    expect(merge(b, empty, intIdentity), b);
    expect(merge(empty, a, intIdentity), a);
    expect(merge(empty, b, intIdentity), b);
  });

  test('merge map lists', () {
    final a = [
      {'x': 1, 'y': 9},
      {'x': 2},
      {'x': 4},
    ];
    final b = [
      {'x': 3, 'y': 8},
    ];
    final c = [
      {'x': 2, 'y': 7},
      {'x': 5},
    ];
    final empty = <Map<String, int>>[];

    int xField(Map<String, int> map) => map['x']!;
    expect(merge(a, b, xField), [
      {'x': 1, 'y': 9},
      {'x': 2},
      {'x': 3, 'y': 8},
      {'x': 4},
    ]);
    expect(merge(a, c, xField), [
      {'x': 1, 'y': 9},
      {'x': 2},
      {'x': 2, 'y': 7},
      {'x': 4},
      {'x': 5},
    ]);
    expect(merge(b, b, xField), [
      {'x': 3, 'y': 8},
      {'x': 3, 'y': 8},
    ]);
    expect(merge(c, c, xField), [
      {'x': 2, 'y': 7},
      {'x': 2, 'y': 7},
      {'x': 5},
      {'x': 5},
    ]);
    expect(merge(empty, empty, xField), []);
    expect(merge<Map<String, int>, int>([], [], xField), []);
    expect(merge(a, empty, xField), a);
    expect(merge(b, empty, xField), b);
    expect(merge(empty, a, xField), a);
    expect(merge(empty, b, xField), b);
  });

  test('Iterable from Iterator', () {
    final a = [1, 2, 4];
    expect(a.iterator.iterable, a);
    expect((a.iterator..moveNext()).iterable, a.skip(1));
    expect([].iterator.iterable, []);
    expect(
      () =>
          a.iterator.iterable
            ..toList()
            ..toList(),
      throwsStateError,
    );
    expect(a.getRange(1, 2).iterator.iterable.single, 2);
    expect(a.iterator.iterable.iterator.iterable, a);
    final m = {'x': 1, 'y': 2};
    expect(m.keys.iterator.iterable, ['x', 'y']);
    Iterable<Map<String, int>> unbounded() sync* {
      for (;;) {
        yield m;
      }
    }

    expect(unbounded().iterator.iterable.take(2), [m, m]);
    expect(a.iterator.iterable.length, 3); // hasLength matcher can't be used.
    expect(
      (() sync* {
        yield* a.iterator.iterable;
      })(),
      a,
    );
  });
}
