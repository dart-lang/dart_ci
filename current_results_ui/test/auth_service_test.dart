// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_current_results/src/auth_service.dart';
import 'dart:async';

import 'auth_service_test.mocks.dart';

@GenerateMocks([
  FirebaseAuth,
  User,
  UserCredential,
  GoogleAuthProvider,
])
void main() {
  late MockFirebaseAuth mockAuth;
  late MockUser mockUser;
  late MockUserCredential mockUserCredential;
  late AuthService authService;
  late StreamController<User?> authStateController;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockUser = MockUser();
    mockUserCredential = MockUserCredential();
    authStateController = StreamController<User?>.broadcast();

    when(mockAuth.authStateChanges())
        .thenAnswer((_) => authStateController.stream);
    when(mockUser.email).thenReturn('test@example.com');
    when(mockUser.displayName).thenReturn('Test User');
    when(mockUser.uid).thenReturn('test_uid');
    when(mockUser.photoURL).thenReturn('http://example.com/avatar.png');
    when(mockUserCredential.user).thenReturn(mockUser);

    authService = AuthService(auth: mockAuth);
  });

  tearDown(() {
    authStateController.close();
  });

  group('AuthService', () {
    test('initial state is logged out', () {
      expect(authService.user, isNull);
      expect(authService.isAuthenticated, isFalse);
    });

    test('signInWithGoogle success', () async {
      when(mockAuth.signInWithPopup(any))
          .thenAnswer((_) async => mockUserCredential);

      final completer = Completer<void>();
      authService.addListener(() {
        if (authService.user != null && !completer.isCompleted) {
          completer.complete();
        }
      });

      authService.signInWithGoogle();
      authStateController.add(mockUser);

      await completer.future;

      expect(authService.user, mockUser);
      expect(authService.isAuthenticated, isTrue);
    });

    test('signInWithGoogle failure', () async {
      when(mockAuth.signInWithPopup(any))
          .thenThrow(FirebaseAuthException(code: 'error'));

      await authService.signInWithGoogle();

      expect(authService.user, isNull);
      expect(authService.isAuthenticated, isFalse);
      expect(authService.errorMessage, isNotNull);
    });

    test('signOut', () async {
      when(mockAuth.currentUser).thenReturn(mockUser);
      authService = AuthService(auth: mockAuth);
      authStateController.add(mockUser);
      await Future.delayed(Duration.zero);

      expect(authService.isAuthenticated, isTrue);

      when(mockAuth.signOut()).thenAnswer((_) async {});

      final completer = Completer<void>();
      authService.addListener(() {
        if (!authService.isAuthenticated && !completer.isCompleted) {
          completer.complete();
        }
      });

      await authService.signOut();
      authStateController.add(null);

      await completer.future;

      expect(authService.user, isNull);
      expect(authService.isAuthenticated, isFalse);
    });

    test('isLoading is true during signInWithGoogle and false after', () async {
      final signInCompleter = Completer<UserCredential>();
      when(mockAuth.signInWithPopup(any))
          .thenAnswer((_) => signInCompleter.future);

      final signInFuture = authService.signInWithGoogle();

      expect(authService.isLoading, isTrue);

      signInCompleter.complete(mockUserCredential);
      authStateController.add(mockUser);

      await signInFuture;
      authStateController.add(null);
      await Future.delayed(Duration.zero);
      
      expect(authService.isLoading, isFalse);
    });

    test('isLoading is true during signOut and false after', () async {
      when(mockAuth.currentUser).thenReturn(mockUser);
      authService = AuthService(auth: mockAuth);
      authStateController.add(mockUser);
      await Future.delayed(Duration.zero);

      final signOutCompleter = Completer<void>();
      when(mockAuth.signOut()).thenAnswer((_) => signOutCompleter.future);

      final signOutFuture = authService.signOut();

      expect(authService.isLoading, isTrue);

      signOutCompleter.complete();
      await signOutFuture;

      expect(authService.isLoading, isTrue);

      authStateController.add(null);
      await Future.delayed(Duration.zero);

      expect(authService.isLoading, isFalse);
    });
  });
}
