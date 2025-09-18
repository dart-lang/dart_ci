// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_current_results/filter.dart';
import 'package:flutter_current_results/model/review.dart';
import 'package:flutter_current_results/query.dart';
import 'package:flutter_current_results/src/auth_service.dart';
import 'package:flutter_current_results/src/data/try_query_results.dart';
import 'package:flutter_current_results/src/generated/query.pb.dart';
import 'package:flutter_current_results/src/widgets/results_view.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'try_query_results_test.mocks.dart';

class MockAuthService extends Mock implements AuthService {
  @override
  bool get isAuthenticated => _isAuthenticated;
  bool _isAuthenticated = false;

  @override
  bool get isLoading => _isLoading;
  bool _isLoading = false;

  @override
  String? get errorMessage => _errorMessage;
  String? _errorMessage;

  void setAuthenticated(bool value) {
    _isAuthenticated = value;
    notifyListeners();
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }
}

void main() {
  late MockAuthService mockAuthService;
  late QueryResultsBase queryResults;

  setUp(() {
    mockAuthService = MockAuthService();
    queryResults = QueryResults(Filter(''));
  });

  Widget createTestWidget() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>.value(value: mockAuthService),
        ChangeNotifierProvider<QueryResultsBase>.value(value: queryResults),
      ],
      child: MaterialApp(
        home: ResultsView(title: 'Test Results', filter: Filter('')),
      ),
    );
  }

  testWidgets('shows sign-in button when logged out', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createTestWidget());

    expect(find.widgetWithIcon(IconButton, Icons.login), findsOneWidget);
    expect(find.widgetWithIcon(IconButton, Icons.logout), findsNothing);
  });

  testWidgets('shows sign-out button when logged in', (
    WidgetTester tester,
  ) async {
    mockAuthService.setAuthenticated(true);
    await tester.pumpWidget(createTestWidget());

    expect(find.widgetWithIcon(IconButton, Icons.logout), findsOneWidget);
    expect(find.widgetWithIcon(IconButton, Icons.login), findsNothing);
  });

  testWidgets('shows loading indicator when signing in', (
    WidgetTester tester,
  ) async {
    mockAuthService.setLoading(true);
    await tester.pumpWidget(createTestWidget());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows sign-out button when user is already logged in on start', (
    WidgetTester tester,
  ) async {
    // This test simulates the scenario where the user was already logged in
    // from a previous session.
    mockAuthService.setAuthenticated(true);
    await tester.pumpWidget(createTestWidget());

    // The sign-out button should be immediately visible, without needing
    // to wait for any async operations.
    expect(find.widgetWithIcon(IconButton, Icons.logout), findsOneWidget);
    expect(find.widgetWithIcon(IconButton, Icons.login), findsNothing);
  });

  testWidgets('ResultsView updates with TryQueryResults data', (
    WidgetTester tester,
  ) async {
    final mockResultsService = MockResultsService();
    final result = Result()
      ..name = 'test1'
      ..configuration = 'config1'
      ..result = 'Fail'
      ..expected = 'Pass'
      ..flaky = false;
    final change = ChangeInResult(result);
    when(
      mockResultsService.fetchChanges(123, 1),
    ).thenAnswer((_) async => [(change, result)]);
    when(mockResultsService.fetchReviewInfo(123)).thenAnswer(
      (_) async => Review(
        id: '1',
        subject: 'Subject',
        patchsets: [
          Patchset(
            id: '1',
            description: 'description',
            number: 1,
            patchsetGroup: 1,
          ),
        ],
      ),
    );
    final tryQueryResults = TryQueryResults(
      cl: 123,
      patchset: 1,
      resultsService: mockResultsService,
      filter: Filter(''),
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthService>.value(value: mockAuthService),
          ChangeNotifierProvider<TryQueryResults>.value(value: tryQueryResults),
          ChangeNotifierProvider<QueryResultsBase>.value(
            value: tryQueryResults,
          ),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Consumer<TryQueryResults>(
              builder: (context, value, child) => ResultsView(
                title: 'Try Results',
                filter: value.filter,
                showInstructionsOnEmptyQuery: false,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Try Results'), findsOneWidget);
    expect(find.text('test1'), findsOneWidget);
  });
}
