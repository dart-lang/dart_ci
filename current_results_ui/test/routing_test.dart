// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_current_results/instructions.dart';
import 'package:flutter_current_results/main.dart';
import 'package:flutter_current_results/query.dart';
import 'package:flutter_current_results/src/auth_service.dart';
import 'package:flutter_current_results/src/generated/query.pb.dart';
import 'package:flutter_current_results/src/routing.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';

import 'routing_test.mocks.dart';

class FakeQueryResults extends QueryResults {
  @override
  void fetchCurrentResults() async {
    // Do nothing to prevent network calls in tests.
    await Future.microtask(() => onResults(GetResultsResponse()));
    onDone();
  }
}

@GenerateNiceMocks([MockSpec<AuthService>()])
void main() {
  late MockAuthService mockAuthService;
  late FakeQueryResults fakeQueryResults;
  late TabController tabController;

  setUp(() {
    mockAuthService = MockAuthService();
    fakeQueryResults = FakeQueryResults();
    tabController = TabController(length: 3, vsync: const TestVSync());
  });

  testWidgets('Routing works for filter parameter', (
    WidgetTester tester,
  ) async {
    final router = createRouter();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthService>.value(value: mockAuthService),
          ChangeNotifierProvider<QueryResults>.value(value: fakeQueryResults),
          ChangeNotifierProvider<TabController>.value(value: tabController),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    router.push('/?filter=test-filter');
    await tester.pumpAndSettle();

    final resultsScreen = tester.widget<CurrentResultsScreen>(
      find.byType(CurrentResultsScreen),
    );
    expect(resultsScreen.filter.terms, equals(['test-filter']));
    expect(resultsScreen.initialTabIndex, equals(0));
    expect(find.byType(Instructions), findsNothing);
  });

  testWidgets('Routing works for flaky parameter', (WidgetTester tester) async {
    final router = createRouter();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthService>.value(value: mockAuthService),
          ChangeNotifierProvider<QueryResults>.value(value: fakeQueryResults),
          ChangeNotifierProvider<TabController>.value(value: tabController),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    router.push('/?flaky=true');
    await tester.pumpAndSettle();

    final resultsScreen = tester.widget<CurrentResultsScreen>(
      find.byType(CurrentResultsScreen),
    );
    expect(resultsScreen.filter.terms, isEmpty);
    expect(resultsScreen.initialTabIndex, equals(1));
  });

  testWidgets('Routing works for showAll parameter', (
    WidgetTester tester,
  ) async {
    final router = createRouter();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthService>.value(value: mockAuthService),
          ChangeNotifierProvider<QueryResults>.value(value: fakeQueryResults),
          ChangeNotifierProvider<TabController>.value(value: tabController),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    router.push('/?showAll=true');
    await tester.pumpAndSettle();

    final resultsScreen = tester.widget<CurrentResultsScreen>(
      find.byType(CurrentResultsScreen),
    );
    expect(resultsScreen.filter.terms, isEmpty);
    expect(resultsScreen.initialTabIndex, equals(2));
  });

  testWidgets('Routing works for combined parameters', (
    WidgetTester tester,
  ) async {
    final router = createRouter();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthService>.value(value: mockAuthService),
          ChangeNotifierProvider<QueryResults>.value(value: fakeQueryResults),
          ChangeNotifierProvider<TabController>.value(value: tabController),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    router.push('/?filter=test-filter&showAll=true');
    await tester.pumpAndSettle();

    final resultsScreen = tester.widget<CurrentResultsScreen>(
      find.byType(CurrentResultsScreen),
    );
    expect(resultsScreen.filter.terms, equals(['test-filter']));
    expect(resultsScreen.initialTabIndex, equals(2));
  });

  testWidgets('Routing works for default route', (WidgetTester tester) async {
    final router = createRouter();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthService>.value(value: mockAuthService),
          ChangeNotifierProvider<QueryResults>.value(value: fakeQueryResults),
          ChangeNotifierProvider<TabController>.value(value: tabController),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    router.push('/');
    await tester.pumpAndSettle();

    final resultsScreen = tester.widget<CurrentResultsScreen>(
      find.byType(CurrentResultsScreen),
    );
    expect(resultsScreen.filter.terms, isEmpty);
    expect(resultsScreen.initialTabIndex, equals(0));
    expect(find.byType(Instructions), findsOneWidget);
  });
}
