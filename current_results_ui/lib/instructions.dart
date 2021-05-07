// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class Instructions extends StatelessWidget {
  Widget build(context) {
    return SingleChildScrollView(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          'Enter a query to see current test results',
          style: TextStyle(fontSize: 24.0),
        ),
        paragraph('Enter query terms that are prefixes of configuration '
            'or test names, or filter for experiments with "experiment:<name>".'
            ' Multiple terms can be entered at once, separated by commas.'),
        paragraph('Some example queries are:'),
        for (final example in [
          {
            'description': 'language_2/ tests on analyzer configurations',
            'terms': 'language_2/,analyzer'
          },
          {
            'description': 'service/de* tests on dartk- configurations',
            'terms': 'dartk-,service/de'
          },
          {'description': 'analyzer unit tests', 'terms': 'pkg/analyzer/'},
          {
            'description':
                'all tests on dart2js strong null-safe configuration',
            'terms': 'dart2js-hostasserts-strong'
          },
          {
            'description':
                'all tests that were run with experiment "triple-shift"',
            'terms': 'experiment:triple-shift'
          },
          {'description': 'null-safe language tests', 'terms': 'language/'},
        ]) ...[
          SizedBox(height: 12),
          InkWell(
            onTap: () {
              Navigator.pushNamed(
                context,
                '/filter=${example['terms']}',
              );
            },
            child: Text.rich(
              TextSpan(
                text: '${example['description']}: ',
                children: [
                  TextSpan(
                    text: example['terms'],
                    style: TextStyle(
                      color: Colors.blue[900],
                      decoration: TextDecoration.underline,
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
        SizedBox(height: 24.0),
        Text(
          'About Current Results',
          style: TextStyle(fontSize: 24.0),
        ),
        paragraph('For each test, the results show how many '
            'of the selected configurations are passing, failing, and flaky. '
            'The item can be expanded to show which configurations are failing,'
            ' and the configuration names are links to the failure logs.'),
        paragraph('The clock icon after each test name is a link to the '
            'results feed, filtered to show just the history of that test.'),
        paragraph('Results can be downloaded from the server using the '
            'JSON link at the bottom of the page, or as comma-separated '
            'text using the text link.'),
      ]),
    );
  }

  Widget paragraph(String text) {
    return Container(
        constraints: BoxConstraints(maxWidth: 500.0),
        padding: EdgeInsets.only(top: 12.0),
        child: Text(text, style: TextStyle(height: 1.5)));
  }
}
