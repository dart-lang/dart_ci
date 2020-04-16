// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test/test.dart';

import 'package:dart_results_feed/src/formatting.dart';

void main() {
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

  test('Format comment', () {
    const unformatted = 'This comment has\n'
        'newlines and\n'
        'escaped newlines and '
        'a < sign and an '
        '& ampersand';
    const formatted = 'This comment has<br>'
        'newlines and<br>'
        'escaped newlines and '
        'a &lt; sign and an '
        '&amp; ampersand';
    expect(formatComment(unformatted), formatted);
  });

  test('Format comment with GitHub short issue links', () {
    const unformatted = '#012 This comment has\n'
        'a short issue link #1234 and \n'
        'one after a newline \n'
        '#987 and a link with a repo dart_style#567 '
        'and one with the dart-lang org dart-lang/dart_ci#890 '
        'and one with the google org google/a-repo#000 '
        'and one with the flutter org flutter/engine#92text afterward '
        'but the following are invalid and should\n'
        'not be changed to html:\n'
        'one with no number # '
        'one across a newline sdk#\n34 '
        'one with an org and repo but no number google/sdk#deadbeef '
        'The following get converted, but with the default org:\n'
        'one from a different org private/dart_clone#358 '
        'one with an org but no repo dart-lang/#1234 '
        'one with a slash but no org /dart-pad#567';
    const formatted = '<a target="_blank" rel="noopener" '
        'href="https://github.com/dart-lang/sdk/issues/012">#012</a> '
        'This comment has<br>'
        'a short issue link '
        '<a target="_blank" rel="noopener" '
        'href="https://github.com/dart-lang/sdk/issues/1234">#1234</a> '
        'and <br>one after a newline <br>'
        '<a target="_blank" rel="noopener" '
        'href="https://github.com/dart-lang/sdk/issues/987">#987</a> and '
        'a link with a repo '
        '<a target="_blank" rel="noopener" '
        'href="https://github.com/dart-lang/dart_style/issues/567">'
        'dart_style#567</a> '
        'and one with the dart-lang org '
        '<a target="_blank" rel="noopener" '
        'href="https://github.com/dart-lang/dart_ci/issues/890">'
        'dart-lang/dart_ci#890</a> '
        'and one with the google org '
        '<a target="_blank" rel="noopener" '
        'href="https://github.com/google/a-repo/issues/000">'
        'google/a-repo#000</a> '
        'and one with the flutter org '
        '<a target="_blank" rel="noopener" '
        'href="https://github.com/flutter/engine/issues/92">'
        'flutter/engine#92</a>text afterward '
        'but the following are invalid and should<br>'
        'not be changed to html:<br>'
        'one with no number # '
        'one across a newline sdk#<br>34 '
        'one with an org and repo but no number google/sdk#deadbeef '
        'The following get converted, but with the default org:<br>'
        'one from a different org private/'
        '<a target="_blank" rel="noopener" '
        'href="https://github.com/dart-lang/dart_clone/issues/358">'
        'dart_clone#358</a> '
        'one with an org but no repo dart-lang/'
        '<a target="_blank" rel="noopener" '
        'href="https://github.com/dart-lang/sdk/issues/1234">'
        '#1234</a> '
        'one with a slash but no org /'
        '<a target="_blank" rel="noopener" '
        'href="https://github.com/dart-lang/dart-pad/issues/567">'
        'dart-pad#567</a>';
    expect(formatComment(unformatted), formatted);
  });

  test('Format comment with pasted GitHub issue URL', () {
    const unformatted = 'This comment has a pasted issue URL\n'
        'https://github.com/dart-lang/sdk/issues/4132\n'
        'and one from a different repo '
        '\nhttps://github.com/dart-lang/dart_ci/issues/4321\n'
        'and one from flutter '
        '\nhttps://github.com/flutter/engine/issues/3241 '
        'here are links with text around them '
        'link https://github.com/dart-lang/sdk/issues/4132 here'
        'link:https://github.com/dart-lang/sdk/issues/4132<here>'
        'These links should not be converted:\n'
        'myhttps://github.com/dart-lang/sdk/issues/4132 '
        'link https://github.com/dart-lang/sdk/issues/4132foo here'
        'link https://github.com/dart-clone/sdk/issues/4132 here'
        'link https://github.com/google//issues/4132 here'
        'link https://github.com/dart-lang/sdk/issues/ here'
        'link https://github.com/dart-lang/sdk/issues/new here'
        'link https://gitfoohub.com/dart-lang/sdk/issues/4132 here'
        'link https://github.com/dart-lang/s.dk/issues/1234 here';
    const formatted = 'This comment has a pasted issue URL<br>'
        ' <a target="_blank" rel="noopener" '
        'href="https://github.com/dart-lang/sdk/issues/4132">'
        'dart-lang/sdk#4132</a> <br>'
        'and one from a different repo '
        '<br> <a target="_blank" rel="noopener" '
        'href="https://github.com/dart-lang/dart_ci/issues/4321">'
        'dart-lang/dart_ci#4321</a> <br>'
        'and one from flutter '
        '<br> <a target="_blank" rel="noopener" '
        'href="https://github.com/flutter/engine/issues/3241">'
        'flutter/engine#3241</a>  '
        'here are links with text around them '
        'link  <a target="_blank" rel="noopener" '
        'href="https://github.com/dart-lang/sdk/issues/4132">'
        'dart-lang/sdk#4132</a>  here'
        'link: <a target="_blank" rel="noopener" '
        'href="https://github.com/dart-lang/sdk/issues/4132">'
        'dart-lang/sdk#4132</a> &lt;here&gt;'
        'These links should not be converted:<br>'
        'myhttps://github.com/dart-lang/sdk/issues/4132 '
        'link https://github.com/dart-lang/sdk/issues/4132foo here'
        'link https://github.com/dart-clone/sdk/issues/4132 here'
        'link https://github.com/google//issues/4132 here'
        'link https://github.com/dart-lang/sdk/issues/ here'
        'link https://github.com/dart-lang/sdk/issues/new here'
        'link https://gitfoohub.com/dart-lang/sdk/issues/4132 here'
        'link https://github.com/dart-lang/s.dk/issues/1234 here';
    expect(formatComment(unformatted), formatted);
  });
}
