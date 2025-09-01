// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth;
  late final StreamSubscription<User?> _authStateSubscription;
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;
  Completer<void>? _signInCompleter;
  Completer<void>? _signOutCompleter;

  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance {
    _user = _auth.currentUser;
    _authStateSubscription =
        _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  @override
  void dispose() {
    _authStateSubscription.cancel();
    super.dispose();
  }

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  void _onAuthStateChanged(User? user) {
    if (user == _user) return;
    _user = user;
    _isLoading = false;
    if (_signInCompleter != null && !_signInCompleter!.isCompleted) {
      _signInCompleter!.complete();
    }
    if (_signOutCompleter != null && !_signOutCompleter!.isCompleted) {
      _signOutCompleter!.complete();
    }
    clearError();
    notifyListeners();
    print('Auth state changed: User is ${user == null ? 'null' : user.uid}');
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
    if (message != null) {
      print('Auth Error: $message');
    }
  }

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  Future<void> signInWithGoogle() async {
    if (_isLoading) return _signInCompleter?.future;
    _signInCompleter = Completer<void>();
    _setLoading(true);
    clearError();

    try {
      GoogleAuthProvider googleProvider = GoogleAuthProvider();
      await _auth.signInWithPopup(
        googleProvider,
      );
      // The user state will be updated by the authStateChanges listener,
      // which will also complete the completer.
    } on FirebaseAuthException catch (e) {
      _setError('Firebase Auth Error: ${e.message} (Code: ${e.code})');
      _setLoading(false);
      _signInCompleter?.complete();
    } catch (e) {
      _setError('An unexpected error occurred during Google Sign-In: $e');
      _setLoading(false);
      _signInCompleter?.complete();
    }
    return _signInCompleter?.future;
  }

  Future<void> signOut() async {
    if (_isLoading) return _signOutCompleter?.future;
    _signOutCompleter = Completer<void>();
    _setLoading(true);
    clearError();
    try {
      await _auth.signOut();
      print('User signed out.');
      // The user state will be updated by the authStateChanges listener,
      // which will also complete the completer.
    } catch (e) {
      _setError('Error signing out: $e');
      _setLoading(false);
      _signOutCompleter?.complete();
    }
    return _signOutCompleter?.future;
  }
}
