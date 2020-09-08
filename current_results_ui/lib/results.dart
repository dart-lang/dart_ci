// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:html' as html;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

import 'filter.dart';
import 'query.dart';

class ResultsPanel extends StatefulWidget {
  final QueryResults queryResults;
  final bool showAll;

  ResultsPanel(this.queryResults, {this.showAll = true});

  @override
  ResultsPanelState createState() => ResultsPanelState();
}

class ResultsPanelState extends State<ResultsPanel> {
  static const Color lightCoral = Color.fromARGB(255, 240, 128, 128);
  static const Color gold = Color.fromARGB(255, 255, 215, 0);
  static const resultColors = {
    'pass': Colors.lightGreen,
    'flaky': gold,
    'fail': lightCoral,
  };

  static const kinds = ['pass', 'fail', 'flaky'];
  List<bool> expanded = [];

  @override
  Widget build(BuildContext context) {
    if (widget.queryResults.noQuery) {
      return Align(child: QuerySuggestionsPage());
    }
    if (expanded.length != widget.queryResults.names.length) {
      expanded = List<bool>.filled(widget.queryResults.names.length, false);
    }
    return ListView.builder(
      itemCount: widget.queryResults.names.length,
      itemBuilder: itemBuilder(widget.queryResults),
    );
  }

  IndexedWidgetBuilder itemBuilder(QueryResults results) {
    return (BuildContext context, int index) {
      final name = results.names[index];
      final changeGroups = results.grouped[name];
      final counts = results.counts[name];
      if (!widget.showAll &&
          changeGroups.keys.every((change) => change.matches)) {
        return Container(height: 0.0, width: 0.0);
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 28.0,
            padding: EdgeInsets.only(top: 0.0, left: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                      expanded[index] ? Icons.expand_less : Icons.expand_more),
                  onPressed: () =>
                      setState(() => expanded[index] = !expanded[index]),
                ),
                for (final kind in kinds)
                  Container(
                    width: 24,
                    alignment: Alignment.center,
                    margin: EdgeInsets.symmetric(horizontal: 1.0),
                    decoration: BoxDecoration(
                      color: counts.containsKey(kind)
                          ? resultColors[kind]
                          : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Text('${counts[kind] ?? ''}',
                        style: TextStyle(fontSize: 14.0)),
                  ),
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: EdgeInsets.only(left: 4.0),
                    alignment: Alignment.centerLeft,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      child: SelectableText(
                        results.partialResults
                            ? '$name (partial results)'
                            : name,
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ),
                  ),
                ),
                IconButton(
                    icon: Icon(Icons.history),
                    onPressed: () => html.window.open(
                        Uri(
                                path: '/',
                                fragment: widget.showAll
                                    ? 'showLatestFailures=false&test=$name'
                                    : 'test=$name')
                            .toString(),
                        '_blank')),
              ],
            ),
          ),
          if (expanded[index])
            for (final change in changeGroups.keys
                .where((key) => widget.showAll || !key.matches))
              Container(
                alignment: Alignment.topLeft,
                padding: EdgeInsets.only(left: 48.0),
                constraints: BoxConstraints.loose(Size.fromWidth(500.0)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.only(top: 12.0),
                      child: Text(
                          '$change (${changeGroups[change].length} configurations)',
                          style: TextStyle(
                              backgroundColor: resultColors[change.kind],
                              fontSize: 16.0)),
                    ),
                    for (final result in changeGroups[change])
                      SelectableText(result.configuration),
                  ],
                ),
              ),
          if (expanded[index]) SizedBox(height: 12.0),
        ],
      );
    };
  }
}

class QuerySuggestionsPage extends StatelessWidget {
  Widget build(context) {
    Function setFilter(String terms) =>
        () => Provider.of<Filter>(context, listen: false).addAll(terms);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        'Enter a query to see current test results',
        style: TextStyle(fontSize: 24.0),
      ),
      SizedBox(height: 24.0),
      Text(
          'Enter query terms that are prefixes of configuration or test names.'),
      Text('Multiple terms can be entered at once, separated by commas.'),
      SizedBox(height: 12.0),
      Text('Some example queries are:'),
      for (final example in [
        {
          'description': 'language_2/ tests on analyzer configurations',
          'terms': 'language_2/,analyzer'
        },
        {
          'description': 'service/de* tests on dartk- configurations',
          'terms': 'dartk-, service/de'
        },
        {'description': 'analyzer unit tests', 'terms': 'pkg/analyzer/'},
        {
          'description': 'all tests on dart2js strong null-safe configuration',
          'terms': 'dart2js-hostasserts-strong'
        },
        {'description': 'null-safe language tests', 'terms': 'language/'},
      ]) ...[
        SizedBox(height: 12),
        Text.rich(
          TextSpan(
            text: '${example['description']}: ',
            children: [
              TextSpan(
                text: example['terms'],
                style: TextStyle(
                  color: Colors.blue[900],
                  decoration: TextDecoration.underline,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = setFilter(example['terms']),
              )
            ],
          ),
        ),
      ],
    ]);
  }
}
