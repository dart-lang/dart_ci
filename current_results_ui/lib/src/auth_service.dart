// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth;
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  Future<void> _onAuthStateChanged(User? user) async {
    _user = user;
    _isLoading = false;
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
    }
  }

  Future<void> signInWithGoogle() async {
    if (_isLoading) return;
    _setLoading(true);
    clearError();

    try {
      GoogleAuthProvider googleProvider = GoogleAuthProvider();
      final UserCredential userCredential = await _auth.signInWithPopup(
        googleProvider,
      );
      _user = userCredential.user;
      print('Signed in user: ${_user?.displayName}');
    } on FirebaseAuthException catch (e) {
      _setError('Firebase Auth Error: ${e.message} (Code: ${e.code})');
      _setLoading(false);
    } catch (e) {
      _setError('An unexpected error occurred during Google Sign-In: $e');
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    if (_isLoading) return;
    _setLoading(true);
    clearError();
    try {
      await _auth.signOut();
      print('User signed out.');
    } catch (e) {
      _setError('Error signing out: $e');
      _setLoading(false);
    }
  }
}
