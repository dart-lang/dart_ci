// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

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

String formatFetchDate(DateTime date) => DateFormat('MMM d, y').format(date);

String formattedEmail(String email) {
  if (email.endsWith('@google.com')) {
    return email.split('@').first;
  }
  return email;
}

// Checkmark followed by a space. Used for approved results.
String checkmark = '\u2714 ';

// Format comments and change Github short issue links to HTML links.
const organizations = ['dart-lang', 'google', 'flutter'];
final organization = organizations.join('|');
const repo = '[\\w-]+';
const issue = '\\d+';

final pastedIssueUrlMatcher =
    RegExp('\\bhttps://github.com/($organization)/($repo)/issues/($issue)\\b');
// We allow short links of the form "organization/repo#number",
// "repo#number", and "#number".  Organization and repo default
// to dart-lang and sdk.
final shortLinkMatcher = RegExp('(\\b(($organization)/)?($repo))?#($issue)');

String formatComment(String comment) => comment == null
    ? null
    : HtmlEscape(HtmlEscapeMode.element)
        .convert(comment)
        .replaceAll('\n', '<br>')
        .replaceAllMapped(pastedIssueUrlMatcher,
            (match) => ' ${match[1]}/${match[2]}#${match[3]} ')
        .replaceAllMapped(
            shortLinkMatcher,
            (match) => '<a target="_blank" rel="noopener" '
                'href="https://${[
                  'github.com',
                  match[3] ?? 'dart-lang',
                  match[4] ?? 'sdk',
                  'issues',
                  match[5]
                ].join('/')}">'
                '${match[0]}</a>');
