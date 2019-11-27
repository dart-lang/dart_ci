// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test/test.dart';

import 'package:dart_results_feed/src/formatting.dart';

main() {
  test('Test current year format', () {
    final currentYear = DateTime.now().year;
    expect(formattedDate(DateTime.parse('$currentYear-01-07T00:07:55')),
        matches(RegExp(r'^0:07 ... Jan 7$')));
    final weekdayDate = DateTime.parse('$currentYear-05-15T07:17:00');
    final daysToWednesday = DateTime.wednesday - weekdayDate.weekday;
    final wednesdayDate = weekdayDate.add(Duration(days: daysToWednesday));
    expect(
        formattedDate(wednesdayDate), matches(RegExp(r'^7:17 Wed May \d\d$')));
  });
  test('Test past year format', () {
    expect(formattedDate(DateTime.parse('2018-11-13T15:07:55.123')),
        '15:07 Tue Nov 13, 2018');
  });
}
