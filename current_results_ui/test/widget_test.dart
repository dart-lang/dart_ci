// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_current_results/src/app/app_router.dart';
import 'package:flutter_current_results/src/app/auth_service.dart';
import 'package:flutter_current_results/src/data/models/review.dart';
import 'package:flutter_current_results/src/features/results_overview/data/results_repository.dart';
import 'package:flutter_current_results/src/features/try_results/data/try_results_repository.dart';
import 'package:flutter_current_results/src/features/try_results/widgets/try_results_screen.dart';
import 'package:flutter_current_results/src/shared/generated/query.pb.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
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
  late GoRouter router;
  late MockAuthService mockAuthService;
  late MockResultsService mockResultsService;

  setUp(() {
    mockAuthService = MockAuthService();
    mockResultsService = MockResultsService();
  });

  Widget createTestWidget() {
    router = createRouter(
      tryQueryResultsProvider:
          ({required cl, required filter, required patchset}) =>
              TryQueryResults(
                cl: cl,
                patchset: patchset,
                filter: filter,
                resultsService: mockResultsService,
              ),
    );
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>.value(value: mockAuthService),
      ],
      child: MaterialApp.router(routerConfig: router),
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

    await tester.pumpWidget(createTestWidget());
    router.go('/cl/123/1');
    await tester.pumpAndSettle();

    expect(find.byType(TryResultsScreen), findsOneWidget);
    expect(find.text('test1'), findsOneWidget);
  });
}
