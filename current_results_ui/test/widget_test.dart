// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:flutter_current_results/main.dart';
import 'package:flutter_current_results/query.dart';
import 'package:flutter_current_results/src/auth_service.dart';

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
  late QueryResults queryResults;
  late TabController tabController;

  setUp(() {
    mockAuthService = MockAuthService();
    queryResults = QueryResults();
    tabController = TabController(length: 3, vsync: const TestVSync());
  });

  Widget createTestWidget() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>.value(value: mockAuthService),
        ChangeNotifierProvider<QueryResults>.value(value: queryResults),
        ChangeNotifierProvider<TabController>.value(value: tabController),
      ],
      child: MaterialApp(
        home: CurrentResultsScaffold(tabController: tabController),
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
}
