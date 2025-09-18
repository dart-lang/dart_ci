// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_current_results/firebase_options.dart';
import 'package:flutter_current_results/src/routing.dart';
import 'package:flutter_current_results/src/widgets/app_bar_actions.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

import 'filter.dart';
import 'query.dart';
import 'results.dart';
import 'src/auth_service.dart';
import 'src/platform_specific/url_strategy_stub.dart'
    if (dart.library.js_interop) 'src/platform_specific/url_strategy_web.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    configureUrlStrategy();
    runApp(const CurrentResultsApp());
  } catch (e) {
    print('Failed to initialize Firebase: $e');
    runApp(FirebaseErrorApp(error: e.toString()));
  }
}

class FirebaseErrorApp extends StatelessWidget {
  final String error;
  const FirebaseErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Initialization Error')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SelectionArea(
              child: Text(
                'Failed to initialize Firebase. Please check your configuration and ensure you have added the necessary platform-specific setup.\n\nError: $error',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

final _router = createRouter();

class CurrentResultsApp extends StatelessWidget {
  const CurrentResultsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppProviders(
      child: MaterialApp.router(
        title: 'Current Results',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.compact,
        ),
        routerConfig: _router,
      ),
    );
  }
}

class AppProviders extends StatelessWidget {
  final Widget child;
  const AppProviders({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>(create: (_) => AuthService()),
        ChangeNotifierProvider<QueryResults>(create: (_) => QueryResults()),
      ],
      child: child,
    );
  }
}

class CurrentResultsScreen extends StatefulWidget {
  final Filter filter;
  final int initialTabIndex;
  const CurrentResultsScreen({
    super.key,
    required this.filter,
    this.initialTabIndex = 0,
  });

  @override
  State<CurrentResultsScreen> createState() => _CurrentResultsScreenState();
}

class _CurrentResultsScreenState extends State<CurrentResultsScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    Provider.of<QueryResults>(context, listen: false).fetch(widget.filter);
    _tabController = TabController(
      initialIndex: widget.initialTabIndex,
      length: 3,
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(CurrentResultsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.filter != oldWidget.filter) {
      Provider.of<QueryResults>(context, listen: false).fetch(widget.filter);
    }
    _tabController.index = widget.initialTabIndex;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TabController>.value(
      value: _tabController,
      child: CurrentResultsScaffold(tabController: _tabController),
    );
  }
}

class CurrentResultsScaffold extends StatelessWidget {
  final TabController tabController;
  const CurrentResultsScaffold({super.key, required this.tabController});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          leading: const Center(child: FetchingProgress()),
          title: const Text(
            'Current Results',
            style: TextStyle(fontSize: 24.0),
          ),
          actions: buildAppBarActions(context),
          bottom: TabBar(
            controller: tabController,
            tabs: const [
              Tab(text: 'FAILURES'),
              Tab(text: 'FLAKES'),
              Tab(text: 'ALL'),
            ],
            onTap: (int tab) {
              final uri = GoRouter.of(
                context,
              ).routeInformationProvider.value.uri;
              final newUri = uri.replace(
                queryParameters: {
                  for (final entry in uri.queryParameters.entries)
                    if (entry.key != 'showAll' && entry.key != 'flaky')
                      entry.key: entry.value,
                  if (tab == 2) 'showAll': 'true',
                  if (tab == 1) 'flaky': 'true',
                },
              );
              GoRouter.of(context).go(newUri.toString());
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
        body: const SelectionArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: FilterUI(),
              ),
              Divider(color: Colors.black12, height: 20),
              Expanded(child: ResultsPanel()),
            ],
          ),
        ),
      ),
    );
  }
}

class ApiPortalLink extends StatelessWidget {
  const ApiPortalLink({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: const Text('API portal'),
      onPressed: () => url_launcher.launchUrl(
        Uri.https(
          'endpointsportal.dart-ci.cloud.goog',
          '/docs/current-results-qvyo5rktwa-uc.a.run.app/g'
              '/routes/v1/results/get',
        ),
      ),
    );
  }
}

class JsonLink extends StatelessWidget {
  const JsonLink({super.key});

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
  const TextPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<QueryResults>(
      builder: (context, QueryResults results, child) {
        return Tooltip(
          message: 'Results query as text',
          waitDuration: const Duration(milliseconds: 500),
          child: TextButton(
            child: const Text('Copy to clipboard as text'),
            onPressed: () {
              final text = [resultTextHeader]
                  .followedBy(
                    results.names
                        .expand((name) => results.grouped[name]!.values)
                        .expand((list) => list)
                        .map(resultAsCommaSeparated),
                  )
                  .join('\n');
              Clipboard.setData(ClipboardData(text: text));
            },
          ),
        );
      },
    );
  }
}
