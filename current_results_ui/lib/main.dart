// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

import 'filter.dart';
import 'query.dart';
import 'results.dart';

void main() {
  runApp(const Providers());
}

class CurrentResultsApp extends StatelessWidget {
  const CurrentResultsApp({Key? key}) : super(key: key);

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
        final parameters = settings.name!.substring(1).split('&');

        final terms = parameters
            .firstWhere((parameter) => parameter.startsWith('filter='),
                orElse: () => 'filter=')
            .split('=')[1];
        final filter = Filter(terms);
        final showAll = parameters.contains('showAll');
        final flakes = parameters.contains('flaky');
        final tab = showAll
            ? 2
            : flakes
                ? 1
                : 0;
        return NoTransitionPageRoute(
          builder: (context) {
            Provider.of<QueryResults>(context, listen: false).fetch(filter);
            // Not allowed to set state of tab controller in this builder.
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Provider.of<TabController>(context, listen: false).index = tab;
            });
            return const CurrentResultsScaffold();
          },
          settings: settings,
          maintainState: false,
        );
      },
    );
  }
}

/// Provides access to an QueryResults object which notifies when new
/// results are fetched, a DefaultTabController widget used by the
/// TabBar, and to the TabController object created by that
/// DefaultTabController widget.
class Providers extends StatelessWidget {
  const Providers({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => QueryResults(),
      child: DefaultTabController(
        length: 3,
        initialIndex: 0,
        child: Builder(
          // ChangeNotifierProvider.value in a Builder is needed to make
          // the TabController available for widgets to observe.
          builder: (context) => ChangeNotifierProvider<TabController>.value(
            value: DefaultTabController.of(context),
            child: const CurrentResultsApp(),
          ),
        ),
      ),
    );
  }
}

class CurrentResultsScaffold extends StatelessWidget {
  const CurrentResultsScaffold({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Scaffold(
        appBar: AppBar(
          leading: const Center(
            child: FetchingProgress(),
          ),
          title: const Text(
            'Current Results',
            style: TextStyle(fontSize: 24.0),
          ),
          actions: [
            Tooltip(
              message: 'Send feeback!',
              child: IconButton(
                icon: const Icon(Icons.bug_report),
                splashRadius: 20,
                onPressed: () {
                  url_launcher.launchUrl(
                      Uri.https('github.com', '/dart-lang/dart_ci/issues'));
                },
              ),
            ),
          ],
          bottom: TabBar(
            tabs: const [
              Tab(text: 'FAILURES'),
              Tab(text: 'FLAKES'),
              Tab(text: 'ALL'),
            ],
            onTap: (int tab) {
              // We cannot compare to the previous value, it is gone.
              pushRoute(context, tab: tab);
            },
          ),
        ),
        persistentFooterButtons: const [
          ResultsSummary(),
          TestSummary(),
          ApiPortalLink(),
          JsonLink(),
          TextPopup(),
        ],
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: FilterUI(),
            ),
            Divider(
              color: Colors.grey[300],
              height: 20,
            ),
            Expanded(
              child: ResultsPanel(),
            ),
          ],
        ),
      ),
    );
  }
}

class ApiPortalLink extends StatelessWidget {
  const ApiPortalLink();

  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: const Text('API portal'),
      onPressed: () => url_launcher.launchUrl(Uri.https(
        'endpointsportal.dart-ci.cloud.goog',
        '/docs/current-results-qvyo5rktwa-uc.a.run.app/g'
            '/routes/v1/results/get',
      )),
    );
  }
}

class JsonLink extends StatelessWidget {
  const JsonLink();

  @override
  Widget build(BuildContext context) {
    return Consumer<QueryResults>(
      builder: (context, results, child) {
        return TextButton(
          child: const Text('JSON'),
          onPressed: () => url_launcher.launchUrl(
            Uri.https(apiHost, 'v1/results', {
              'filter': results.filter.terms.join(','),
              'pageSize': '4000',
            }),
          ),
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
        return Tooltip(
          message: 'Results query as text',
          waitDuration: const Duration(milliseconds: 500),
          child: TextButton(
            child: const Text('Text'),
            onPressed: () => showDialog(
              context: context,
              builder: (BuildContext context) {
                final text = [resultTextHeader]
                    .followedBy(results.names
                        .expand((name) => results.grouped[name]!.values)
                        .expand((list) => list)
                        .map(resultAsCommaSeparated))
                    .join('\n');
                return AlertDialog(
                  title: const Text('Results query as text'),
                  content: SelectableText(text),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('Copy and dismiss'),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: text));
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: const Text('Dismiss'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class NoTransitionPageRoute extends MaterialPageRoute {
  NoTransitionPageRoute({
    required WidgetBuilder builder,
    RouteSettings? settings,
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

void pushRoute(context, {Iterable<String>? terms, int? tab}) {
  if (terms == null && tab == null) {
    throw ArgumentError('pushRoute calls must have a named argument');
  }
  tab ??= Provider.of<TabController>(context, listen: false).index;
  terms ??= Provider.of<QueryResults>(context, listen: false).filter.terms;
  final tabItems = [
    if (tab == 2) 'showAll',
    if (tab == 1) 'flaky',
  ];
  Navigator.pushNamed(
    context,
    [
      '/filter=${terms.join(',')}',
      ...tabItems,
    ].join('&'),
  );
}
