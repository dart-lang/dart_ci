// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:collection';

extension IterableIterator<T> on Iterator<T> {
  Iterable<T> get iterable => SingleUseIterable(this);
}

class SingleUseIterable<T> extends IterableBase<T> {
  final Iterator<T> _iterator;
  bool _used = false;
  SingleUseIterable(this._iterator);

  Iterator<T> get iterator {
    if (_used) throw StateError('SingleUseIterable.iterator called twice');
    _used = true;
    return _iterator;
  }
}

Iterable<T> merge<T, S extends Comparable>(
    Iterable<T> a, Iterable<T> b, S Function(T) orderedBy) sync* {
  final ita = a.iterator;
  final itb = b.iterator;
  if (!ita.moveNext()) {
    yield* itb.iterable;
    return;
  }
  if (!itb.moveNext()) {
    yield ita.current;
    yield* ita.iterable;
    return;
  }
  for (;;) {
    if (orderedBy(ita.current).compareTo(orderedBy(itb.current)) <= 0) {
      yield ita.current;
      if (!ita.moveNext()) {
        yield itb.current;
        yield* itb.iterable;
        return;
      }
    } else {
      yield itb.current;
      if (!itb.moveNext()) {
        yield ita.current;
        yield* ita.iterable;
        return;
      }
    }
  }
}
