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

const Color lightCoral = Color.fromARGB(255, 240, 128, 128);
const Color gold = Color.fromARGB(255, 255, 215, 0);
const resultColors = {
  'pass': Colors.lightGreen,
  'flaky': gold,
  'fail': lightCoral,
};
const kinds = ['pass', 'fail', 'flaky'];

class ResultsPanel extends StatelessWidget {
  final QueryResults queryResults;
  final bool showAll;

  ResultsPanel(this.queryResults, {this.showAll = true});

  @override
  Widget build(BuildContext context) {
    if (queryResults.noQuery) {
      return Align(child: QuerySuggestionsPage());
    }
    return ListView.builder(
      itemCount: queryResults.names.length,
      itemBuilder: (BuildContext context, int index) {
        final name = queryResults.names[index];
        final changeGroups = queryResults.grouped[name];
        final counts = queryResults.counts[name];
        final partialResults = queryResults.partialResults;
        return ExpandableResult(
            name, changeGroups, counts, showAll, partialResults);
      },
    );
  }
}

class ExpandableResult extends StatefulWidget {
  final String name;
  final changeGroups;
  final counts;
  final bool showAll;
  final bool partialResults;

  ExpandableResult(this.name, this.changeGroups, this.counts, this.showAll,
      this.partialResults)
      : super(key: Key(name));

  @override
  _ExpandableResultState createState() => _ExpandableResultState();
}

class _ExpandableResultState extends State<ExpandableResult> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final name = widget.name;
    final changeGroups = widget.changeGroups;

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
                icon: Icon(expanded ? Icons.expand_less : Icons.expand_more),
                onPressed: () => setState(() => expanded = !expanded),
              ),
              for (final kind in kinds)
                Container(
                  width: 24,
                  alignment: Alignment.center,
                  margin: EdgeInsets.symmetric(horizontal: 1.0),
                  decoration: BoxDecoration(
                    color: widget.counts.containsKey(kind)
                        ? resultColors[kind]
                        : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Text('${widget.counts[kind] ?? ''}',
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
                      widget.partialResults ? '$name (partial results)' : name,
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
        if (expanded)
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
        if (expanded) SizedBox(height: 12.0),
      ],
    );
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
