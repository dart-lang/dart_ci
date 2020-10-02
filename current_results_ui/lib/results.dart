// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

import 'src/generated/query.pb.dart';
import 'instructions.dart';
import 'query.dart';

const Color lightCoral = Color.fromARGB(255, 240, 128, 128);
const Color gold = Color.fromARGB(255, 255, 215, 0);
const resultColors = {
  'pass': Colors.lightGreen,
  'flaky': gold,
  'fail': lightCoral,
};

class ResultsPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer2<QueryResults, TabController>(
      builder: (context, queryResults, tabController, child) {
        if (queryResults.noQuery) {
          return Align(child: Instructions());
        }
        bool isFailed(String name) =>
            queryResults.counts[name].countFailing > 0;
        bool isFlaky(String name) => queryResults.counts[name].countFlaky > 0;
        final filter = [(name) => true, isFailed, isFlaky][tabController.index];
        final filteredNames = queryResults.names.where(filter).toList();
        return ListView.builder(
          itemCount: filteredNames.length,
          itemBuilder: (BuildContext context, int index) {
            final name = filteredNames[index];
            final changeGroups = queryResults.grouped[name];
            final counts = queryResults.counts[name];
            return ExpandableResult(
                name, changeGroups, counts, tabController.index);
          },
        );
      },
    );
  }
}

class ExpandableResult extends StatefulWidget {
  final String name;
  final Map<ChangeInResult, List<Result>> changeGroups;
  final Counts counts;
  final int tab;

  ExpandableResult(this.name, this.changeGroups, this.counts, this.tab)
      : super(key: Key(name));

  @override
  _ExpandableResultState createState() => _ExpandableResultState();
}

class CountItem {
  String text;
  Color color;

  CountItem(int count, this.color) {
    if (count > 0) {
      text = count.toString();
    } else {
      color = Colors.transparent;
      text = '';
    }
  }
}

List<CountItem> countItems(Counts counts) => [
      CountItem(counts.countPassing, resultColors['pass']),
      CountItem(counts.countFailing, resultColors['fail']),
      CountItem(counts.countFlaky, resultColors['flaky'])
    ];

class _ExpandableResultState extends State<ExpandableResult> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final name = widget.name;
    final changeGroups = widget.changeGroups;
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
              for (final item in countItems(widget.counts))
                Container(
                  width: 24,
                  alignment: Alignment.center,
                  margin: EdgeInsets.symmetric(horizontal: 1.0),
                  decoration: BoxDecoration(
                    color: item.color,
                    shape: BoxShape.circle,
                  ),
                  child: Text(item.text, style: TextStyle(fontSize: 14.0)),
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
                      name,
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
                              fragment: widget.tab == 0
                                  ? 'showLatestFailures=false&test=$name'
                                  : 'test=$name')
                          .toString(),
                      '_blank')),
            ],
          ),
        ),
        if (expanded)
          for (final change in changeGroups.keys.where((key) =>
              widget.tab == 0 ||
              widget.tab == 1 && !key.matches ||
              widget.tab == 2 && key.flaky))
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
                    InkWell(
                        onTap: () {
                          html.window.open(
                            'https://dart-ci.appspot.com/log/any/'
                                '${result.configuration}/latest/$name',
                            '_blank',
                          );
                        },
                        child: Text(result.configuration)),
                ],
              ),
            ),
        if (expanded) SizedBox(height: 12.0),
      ],
    );
  }
}

class ResultsSummary extends StatelessWidget {
  const ResultsSummary() : super();

  @override
  Widget build(BuildContext context) {
    return Consumer<QueryResults>(
      builder: (context, results, child) =>
          Summary("results", results.resultCounts),
    );
  }
}

class TestSummary extends StatelessWidget {
  const TestSummary() : super();

  @override
  Widget build(BuildContext context) {
    return Consumer<QueryResults>(
      builder: (context, results, child) =>
          Summary("tests", results.testCounts),
    );
  }
}

class Summary extends StatelessWidget {
  final String typeText;
  final Counts counts;

  Summary(this.typeText, this.counts);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: AlignmentDirectional.centerStart,
      width: 200.0,
      height: 36.0,
      child: Row(
        children: [
          Text(
            typeText,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Pill(Colors.black26, counts.count, 'total'),
          Pill(resultColors['fail'], counts.countFailing, 'failing'),
          Pill(resultColors['flaky'], counts.countFlaky, 'flaky'),
        ],
      ),
    );
  }
}

class Pill extends StatelessWidget {
  final Color color;
  final int count;
  final String tooltip;

  Pill(this.color, this.count, this.tooltip);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Container(
        //width: 24,
        height: 24,
        alignment: Alignment.center,
        margin: EdgeInsets.symmetric(horizontal: 4.0),
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14.0),
        ),
        child: Text(count.toString(), style: TextStyle(fontSize: 14.0)),
      ),
    );
  }
}
