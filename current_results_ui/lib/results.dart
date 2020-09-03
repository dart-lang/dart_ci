// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

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
                          : Colors.white,
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
