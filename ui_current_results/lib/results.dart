// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:html' as html;

import 'package:flutter/material.dart';

import 'query.dart';

class ResultsPanel extends StatelessWidget {
  final QueryResults queryResults;
  final bool showAll;

  ResultsPanel(this.queryResults, {this.showAll = true});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: SizedBox(
        width: 800.0,
        child: Container(
          decoration: BoxDecoration(border: Border.all(color: Colors.black)),
          child: ListView.builder(
            itemCount: queryResults.names.length,
            itemBuilder: itemBuilder(queryResults),
          ),
        ),
      ),
    );
  }

  IndexedWidgetBuilder itemBuilder(QueryResults results) {
    return (BuildContext context, int index) {
      final name = results.names[index];
      final changeGroups = results.grouped[name];
      if (!showAll && changeGroups.keys.every((change) => change.matches)) {
        // Inserting this seems to break history icons on remaining tests.
        return Container(height: 0.0, width: 0.0);
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedOverflowBox(
            size: Size(600.0, 18.0),
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.only(top: 0.0, left: 8.0),
              child: Row(
                children: [
                  Flexible(
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
                  IconButton(
                    icon: Icon(Icons.history),
                    onPressed: () => html.window.open(
                        Uri(
                                path: '/',
                                fragment: showAll
                                    ? 'showLatestFailures=false&test=$name'
                                    : 'test=$name')
                            .toString(),
                        '_blank'),
                  ),
                ],
              ),
            ),
          ),
          for (final change
              in changeGroups.keys.where((key) => showAll || !key.matches))
            Container(
              alignment: Alignment.topLeft,
              constraints: BoxConstraints.loose(Size.fromWidth(500.0)),
              child: ExpansionTile(
                key: Key(name + change.toString()),
                title: Text(
                  '$change (${changeGroups[change].length} configurations)',
                  style: TextStyle(
                    backgroundColor: change.backgroundColor,
                    fontSize: 14.0,
                  ),
                ),
                expandedAlignment: Alignment.topLeft,
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                childrenPadding: EdgeInsets.only(left: 48.0, bottom: 4.0),
                children: [
                  for (final result in changeGroups[change])
                    SelectableText(result.configuration),
                ],
              ),
            ),
        ],
      );
    };
  }
}
