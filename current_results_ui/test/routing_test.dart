// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_current_results/instructions.dart';
import 'package:flutter_current_results/model/review.dart';
import 'package:flutter_current_results/query.dart';
import 'package:flutter_current_results/src/auth_service.dart';
import 'package:flutter_current_results/src/data/try_query_results.dart';
import 'package:flutter_current_results/src/generated/query.pb.dart';
import 'package:flutter_current_results/src/routing.dart';
import 'package:flutter_current_results/src/services/results_service.dart';
import 'package:flutter_current_results/src/widgets/results_view.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'routing_test.mocks.dart';

class FakeQueryResults extends TryQueryResults {
  FakeQueryResults({
    super.cl = 0,
    super.patchset = 0,
    required super.filter,
    super.resultsService,
  });

  @override
  Stream<Iterable<(ChangeInResult, Result)>> createResultsStream() async* {
    yield [];
  }
}

@GenerateNiceMocks([
  MockSpec<AuthService>(),
  MockSpec<http.Client>(),
  MockSpec<ResultsService>(),
])
void main() {
  late MockAuthService mockAuthService;
  late GoRouter router;
  late TryQueryResults queryResults;
  late MockResultsService mockResultsService;

  setUp(() {
    mockAuthService = MockAuthService();
    mockResultsService = MockResultsService();
    when(mockResultsService.fetchReviewInfo(any)).thenAnswer(
      (_) async => Review(id: '123', subject: 'Test Subject', patchsets: []),
    );
    router = createRouter(
      queryResultsProvider: (filter) => queryResults = FakeQueryResults(
        filter: filter,
        resultsService: mockResultsService,
      ),
      tryQueryResultsProvider:
          ({required cl, required patchset, required filter}) =>
              queryResults = FakeQueryResults(
                cl: cl,
                patchset: patchset,
                filter: filter,
                resultsService: mockResultsService,
              ),
    );
  });

  Future<void> pumpTestWidget(WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<AuthService>.value(
        value: mockAuthService,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
  }

  testWidgets('Routing works for filter parameter', (
    WidgetTester tester,
  ) async {
    await pumpTestWidget(tester);

    router.push('/?filter=test-filter');
    await tester.pumpAndSettle();

    final resultsScreen = tester.widget<ResultsView>(find.byType(ResultsView));
    expect(resultsScreen.filter.terms, equals(['test-filter']));
    final tabBar = tester.widget<TabBar>(find.byType(TabBar));
    expect(tabBar.controller?.index, equals(0));
    expect(find.byType(Instructions), findsNothing);
  });

  testWidgets('Routing works for flaky parameter', (WidgetTester tester) async {
    await pumpTestWidget(tester);

    router.push('/?flaky=true');
    await tester.pumpAndSettle();

    final resultsScreen = tester.widget<ResultsView>(find.byType(ResultsView));
    expect(resultsScreen.filter.terms, isEmpty);
    final tabBar = tester.widget<TabBar>(find.byType(TabBar));
    expect(tabBar.controller?.index, equals(1));
  });

  testWidgets('Routing works for showAll parameter', (
    WidgetTester tester,
  ) async {
    await pumpTestWidget(tester);

    router.push('/?showAll=true');
    await tester.pumpAndSettle();

    final resultsScreen = tester.widget<ResultsView>(find.byType(ResultsView));
    expect(resultsScreen.filter.terms, isEmpty);
    final tabBar = tester.widget<TabBar>(find.byType(TabBar));
    expect(tabBar.controller?.index, equals(2));
  });

  testWidgets('Routing works for combined parameters', (
    WidgetTester tester,
  ) async {
    await pumpTestWidget(tester);

    router.push('/?filter=test-filter&showAll=true');
    await tester.pumpAndSettle();

    final resultsScreen = tester.widget<ResultsView>(find.byType(ResultsView));
    expect(resultsScreen.filter.terms, equals(['test-filter']));
    final tabBar = tester.widget<TabBar>(find.byType(TabBar));
    expect(tabBar.controller?.index, equals(2));
  });

  testWidgets('Routing works for default route', (WidgetTester tester) async {
    await pumpTestWidget(tester);

    router.push('/');
    await tester.pumpAndSettle();

    final resultsScreen = tester.widget<ResultsView>(find.byType(ResultsView));
    expect(resultsScreen.filter.terms, isEmpty);
    final tabBar = tester.widget<TabBar>(find.byType(TabBar));
    expect(tabBar.controller?.index, equals(0));
    expect(find.byType(Instructions), findsOneWidget);
  });

  testWidgets('Routing works for cl route', (WidgetTester tester) async {
    await pumpTestWidget(tester);

    router.push('/cl/1234/5');
    await tester.pumpAndSettle();

    final tabBar = tester.widget<TabBar>(find.byType(TabBar));
    expect(tabBar.controller?.index, equals(0));
    expect(queryResults.cl, equals(1234));
    expect(queryResults.patchset, equals(5));
    expect(queryResults.filter.terms, isEmpty);
  });

  testWidgets('Routing works for cl route with filter', (
    WidgetTester tester,
  ) async {
    await pumpTestWidget(tester);

    router.push('/cl/1234/5?filter=my-filter');
    await tester.pumpAndSettle();

    final tabBar = tester.widget<TabBar>(find.byType(TabBar));
    expect(tabBar.controller?.index, equals(0));
    expect(queryResults.cl, equals(1234));
    expect(queryResults.patchset, equals(5));
    expect(queryResults.filter.terms, equals(['my-filter']));
  });

  testWidgets('Routing works for cl route with flaky', (
    WidgetTester tester,
  ) async {
    await pumpTestWidget(tester);

    router.push('/cl/1234/5?flaky=true');
    await tester.pumpAndSettle();

    final tabBar = tester.widget<TabBar>(find.byType(TabBar));
    expect(tabBar.controller?.index, equals(1));
    expect(queryResults.cl, equals(1234));
    expect(queryResults.patchset, equals(5));
    expect(queryResults.filter.terms, isEmpty);
  });

  testWidgets('Routing works for cl route with showAll', (
    WidgetTester tester,
  ) async {
    await pumpTestWidget(tester);

    router.push('/cl/1234/5?showAll=true');
    await tester.pumpAndSettle();

    final tabBar = tester.widget<TabBar>(find.byType(TabBar));
    expect(tabBar.controller?.index, equals(2));
    expect(queryResults.cl, equals(1234));
    expect(queryResults.patchset, equals(5));
    expect(queryResults.filter.terms, isEmpty);
  });
}
