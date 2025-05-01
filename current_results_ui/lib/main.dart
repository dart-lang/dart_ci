// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

import 'filter.dart';
import 'query.dart';
import 'results.dart';
import 'src/auth_service.dart'; // Import AuthService

Future<void> main() async { // Make main async
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter binding is initialized
  try {
    // Initialize Firebase using default options
    // IMPORTANT: You'll need to configure Firebase for your web app
    // (e.g., add the firebase config script to index.html or use FlutterFire CLI)
    await Firebase.initializeApp();
    print('Firebase initialized successfully.'); // Optional: Add a success log
    runApp(const Providers()); // Run the main app if initialization succeeds
  } catch (e) {
    // Handle Firebase initialization error
    print('Failed to initialize Firebase: $e');
    // Run an error app if initialization fails
    runApp(FirebaseErrorApp(error: e.toString()));
  }
}

// Simple widget to display an error if Firebase fails to initialize
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
            child: Text(
              'Failed to initialize Firebase. Please check your configuration and ensure you have added the necessary platform-specific setup.\n\nError: $error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}

class CurrentResultsApp extends StatelessWidget {
  const CurrentResultsApp({super.key});

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
  const Providers({super.key});

  @override
  Widget build(BuildContext context) {
    // Wrap the existing providers with the AuthService provider at the top level
    return ChangeNotifierProvider<AuthService>(
      create: (_) => AuthService(), // Create AuthService instance
      child: ChangeNotifierProvider<QueryResults>( // Existing QueryResults provider
        create: (_) => QueryResults(),
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
    ); // Closes ChangeNotifierProvider<QueryResults>
  } // Closes ChangeNotifierProvider<AuthService>
}

class CurrentResultsScaffold extends StatelessWidget {
  const CurrentResultsScaffold({super.key});

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
            // Add the Consumer<AuthService> for the login/logout button
            Consumer<AuthService>(
              builder: (context, authService, child) {
                // Handle error messages post-frame
                if (authService.errorMessage != null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Authentication Error: ${authService.errorMessage}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    // Clear the error message after showing it
                    // Use a method on AuthService if available, or manage here if needed
                    // Assuming AuthService has a method like clearError()
                    authService.clearError(); // Need to add this method to AuthService
                  });
                }

                // Show loading indicator
                if (authService.isLoading) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.0),
                    child: SizedBox(
                      width: 20, // Consistent size for the indicator area
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2.0, color: Colors.white),
                    ),
                  );
                }

                // Show Login/Logout button based on auth state
                if (authService.isAuthenticated) {
                  // Logged in state
                  return TextButton(
                    style: TextButton.styleFrom(foregroundColor: Colors.white),
                    onPressed: () async {
                       await authService.signOut();
                       // Optional: Show confirmation SnackBar
                       // ScaffoldMessenger.of(context).showSnackBar(
                       //   SnackBar(content: Text('Signed out successfully.')),
                       // );
                    },
                    child: Tooltip(
                      message: 'Sign out',
                      child: Text('Logout (${authService.user?.email ?? '...'})'),
                    ),
                  );
                } else {
                  // Logged out state
                  return TextButton(
                     style: TextButton.styleFrom(foregroundColor: Colors.white),
                    onPressed: () async {
                      await authService.signInWithGoogle();
                      // Error handling is done via the errorMessage check above
                    },
                    child: const Tooltip(
                      message: 'Sign in with Google',
                      child: Text('Login'),
                    )
                  );
                }
              },
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
        body: const SelectionArea(
            child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: FilterUI(),
            ),
            Divider(
              color: Colors.black12,
              height: 20,
            ),
            Expanded(
              child: ResultsPanel(),
            ),
          ],
        )),
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
            child: const Text('Copy to clipboard as text'),
            onPressed: () {
              final text = [resultTextHeader]
                  .followedBy(results.names
                      .expand((name) => results.grouped[name]!.values)
                      .expand((list) => list)
                      .map(resultAsCommaSeparated))
                  .join('\n');
              Clipboard.setData(ClipboardData(text: text));
            },
          ),
        );
      },
    );
  }
}

class NoTransitionPageRoute extends MaterialPageRoute {
  NoTransitionPageRoute({
    required super.builder,
    super.settings,
    super.maintainState = true,
  });

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
