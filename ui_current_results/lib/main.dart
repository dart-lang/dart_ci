// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:clippy/browser.dart' as clippy;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:html' as html;

import 'filter.dart';
import 'query.dart';
import 'results.dart';

void main() {
  runApp(CurrentResultsAppProviders());
}

class CurrentResultsAppProviders extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Current Results',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.compact,
        ),
        home: MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (context) => Filter()),
              ChangeNotifierProxyProvider<Filter, QueryResults>(
                  create: (context) => QueryResults(),
                  update: (context, filter, queryResults) {
                    return queryResults
                      ..filter = filter
                      ..fetchCurrentResults();
                  })
            ],
            child: DefaultTabController(
              length: 2,
              child: CurrentResultsApp(),
            )));
  }
}

class CurrentResultsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: 808.0),
        decoration: BoxDecoration(
            border: Border(right: BorderSide(color: Colors.black))),
        child: Scaffold(
          appBar: AppBar(
            leading: Image.asset('dart_64.png', width: 16.0, height: 32.0),
            title: Text(
              'Current Results',
              style: TextStyle(
                fontSize: 24.0,
                color: Color.fromARGB(255, 63, 81, 181),
              ),
            ),
            backgroundColor: Colors.white,
            bottom: TabBar(
              tabs: [
                Tab(text: 'ALL'),
                Tab(text: 'FAILURES'),
              ],
              indicatorColor: Color.fromARGB(255, 63, 81, 181),
              labelColor: Color.fromARGB(255, 63, 81, 181),
            ),
          ),
          persistentFooterButtons: [
            ApiPortalLink(),
            JsonLink(),
            textPopup(),
          ],
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FilterUI(),
              Expanded(
                child: Consumer<QueryResults>(
                  builder: (context, results, child) => TabBarView(
                    children: [
                      ResultsPanel(results, showAll: true),
                      ResultsPanel(results, showAll: false)
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ApiPortalLink extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<Filter>(
      builder: (context, Filter filter, child) {
        return FlatButton(
          child: Text('API portal'),
          onPressed: () => html.window.open(
              'https://endpointsportal.dart-ci-staging.cloud.goog'
                  '/docs/current-results-rest-zlujsyuhha-uc.a.run.app/g'
                  '/routes/v1/results/get',
              '_blank'),
        );
      },
    );
  }
}

class JsonLink extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<Filter>(
      builder: (context, filter, child) {
        return FlatButton(
          child: Text('json'),
          onPressed: () => html.window.open(
              Uri.https(apiHost, 'v1/results', {
                'filter': filter.terms.join(','),
                'pageSize': '4000'
              }).toString(),
              '_blank'),
        );
      },
    );
  }
}

Widget textPopup() {
  return Consumer<QueryResults>(
    builder: (context, QueryResults results, child) {
      return FlatButton(
        child: Text('text'),
        onPressed: () => showDialog(
          context: context,
          builder: (BuildContext context) {
            final text = [resultTextHeader]
                .followedBy(
                    results.resultsObject.results.map(resultAsCommaSeparated))
                .join('\n');
            return AlertDialog(
              title: Text('Results query as text'),
              content: SelectableText(text),
              actions: <Widget>[
                FlatButton(
                  child: Text('Copy and dismiss'),
                  onPressed: () {
                    clippy.write(text);
                    Navigator.of(context).pop();
                  },
                ),
                FlatButton(
                  child: Text('Dismiss'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            );
          },
        ),
      );
    },
  );
}
