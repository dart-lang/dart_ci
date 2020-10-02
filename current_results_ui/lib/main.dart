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
  runApp(Providers());
}

class CurrentResultsApp extends StatelessWidget {
  const CurrentResultsApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Current Results',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.compact,
      ),
      initialRoute: '/',
      onGenerateRoute: (RouteSettings settings) {
        final match = RegExp('/filter=(.*)').matchAsPrefix(settings.name);
        final filter = (match == null) ? Filter('') : Filter(match[1]);
        return NoTransitionPageRoute(
            builder: (context) {
              Provider.of<QueryResults>(context, listen: false).fetch(filter);
              return const CurrentResultsScaffold();
            },
            settings: settings,
            maintainState: false);
      },
    );
  }
}

class Providers extends StatelessWidget {
  const Providers({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => QueryResults(),
      child: const DefaultTabController(
        length: 3,
        initialIndex: 1,
        child: const CurrentResultsApp(),
      ),
    );
  }
}

class CurrentResultsScaffold extends StatelessWidget {
  const CurrentResultsScaffold({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Scaffold(
        appBar: AppBar(
          leading: Align(
            alignment: Alignment.center,
            child: Image.asset('assets/dart_64.png', width: 40.0, height: 40.0),
          ),
          title: const Text('Current Results',
              style: TextStyle(
                  fontSize: 24.0, color: Color.fromARGB(255, 63, 81, 181))),
          backgroundColor: Colors.transparent,
          bottom: TabBar(
            tabs: [
              Tab(text: 'ALL'),
              Tab(text: 'FAILURES'),
              Tab(text: 'FLAKY'),
            ],
            indicatorColor: Color.fromARGB(255, 63, 81, 181),
            labelColor: Color.fromARGB(255, 63, 81, 181),
          ),
        ),
        persistentFooterButtons: [
          const TestSummary(),
          const ResultsSummary(),
          const ApiPortalLink(),
          const JsonLink(),
          const TextPopup(),
        ],
        body: Align(
          alignment: Alignment.topCenter,
          child: Container(
            constraints: BoxConstraints(maxWidth: 1000.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FilterUI(),
                Divider(
                  color: Colors.grey[300],
                  height: 20,
                  thickness: 2,
                ),
                Expanded(
                  child: Consumer<QueryResults>(
                    builder: (context, results, child) => TabBarView(
                      children: [
                        ResultsPanel(results, showAll: true),
                        ResultsPanel(results, showAll: false),
                        ResultsPanel(results, flaky: true),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ApiPortalLink extends StatelessWidget {
  const ApiPortalLink();

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: Text('API portal'),
      onPressed: () => html.window.open(
          'https://endpointsportal.dart-ci-staging.cloud.goog'
              '/docs/current-results-rest-zlujsyuhha-uc.a.run.app/g'
              '/routes/v1/results/get',
          '_blank'),
    );
  }
}

class JsonLink extends StatelessWidget {
  const JsonLink();

  @override
  Widget build(BuildContext context) {
    return Consumer<QueryResults>(
      builder: (context, results, child) {
        return FlatButton(
          child: Text('json'),
          onPressed: () => html.window.open(
              Uri.https(apiHost, 'v1/results', {
                'filter': results.filter.terms.join(','),
                'pageSize': '4000'
              }).toString(),
              '_blank'),
        );
      },
    );
  }
}

class TextPopup extends StatelessWidget {
  const TextPopup();

  @override
  Widget build(BuildContext context) {
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
}

class NoTransitionPageRoute extends MaterialPageRoute {
  NoTransitionPageRoute({
    @required WidgetBuilder builder,
    RouteSettings settings,
    bool maintainState = true,
  }) : super(
          builder: builder,
          settings: settings,
          maintainState: maintainState,
        );

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return child;
  }
}
