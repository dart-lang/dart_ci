// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:intl/intl.dart';

int _year = DateTime.now().year;
final _noYearFormat = DateFormat('H:mm EEE MMM d');
final _yearFormat = DateFormat('H:mm EEE MMM d, y');

String formattedDate(DateTime date) {
  if (date.year == _year) return _noYearFormat.format(date);
  if (date.year < _year) return _yearFormat.format(date);
  _year = DateTime.now().year;
  return _yearFormat.format(date);
}

String formattedEmail(String email) {
  if (email.endsWith('@google.com')) {
    return email.split('@').first;
  }
  return email;
}

// Checkmark followed by a space. Used for approved results.
String checkmark = "\u2714 ";
