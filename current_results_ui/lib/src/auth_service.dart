// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'; // For ChangeNotifier

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  AuthService() {
    // Listen to auth state changes from Firebase and update internal state
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  Future<void> _onAuthStateChanged(User? user) async {
    _user = user;
    _isLoading = false; // No longer loading once auth state is confirmed
    clearError(); // Clear any previous errors on auth state change
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
      // Don't notify listeners here if called within another method that will notify
    }
  }

  Future<void> signInWithGoogle() async {
    if (_isLoading) return;
    _setLoading(true);
    clearError();

    try {
      // For web, signInWithPopup is often preferred.
      // For mobile, you might use google_sign_in package + signInWithCredential.
      // We assume a web context here based on the project structure.
      GoogleAuthProvider googleProvider = GoogleAuthProvider();
      // You can add custom parameters or scopes if needed
      // googleProvider.addScope('https://www.googleapis.com/auth/contacts.readonly');
      // googleProvider.setCustomParameters({'login_hint': 'user@example.com'});

      final UserCredential userCredential = await _auth.signInWithPopup(googleProvider);
      _user = userCredential.user;
      // _onAuthStateChanged will be called automatically by the listener,
      // so we don't strictly need to set _user here, but it doesn't hurt.
      print('Signed in user: ${_user?.displayName}');

    } on FirebaseAuthException catch (e) {
      _setError('Firebase Auth Error: ${e.message} (Code: ${e.code})');
    } catch (e) {
      _setError('An unexpected error occurred during Google Sign-In: $e');
    } finally {
      _setLoading(false); // Ensure loading is set to false even if _onAuthStateChanged hasn't fired yet
    }
  }

  Future<void> signOut() async {
    if (_isLoading) return; // Prevent sign out if another operation is in progress
    _setLoading(true); // Indicate loading state during sign out
    clearError();
    try {
      await _auth.signOut();
      // _onAuthStateChanged will handle setting _user to null and notifying listeners.
      print('User signed out.');
    } catch (e) {
      _setError('Error signing out: $e');
      _setLoading(false); // Ensure loading is false if sign out fails
    }
    // Loading state will be reset to false by _onAuthStateChanged upon successful sign out.
  }
}
