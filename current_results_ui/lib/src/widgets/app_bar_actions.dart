// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

import '../auth_service.dart';

List<Widget> buildAppBarActions(BuildContext context) {
  return [
    IconButton(
      icon: const Icon(Icons.bug_report),
      tooltip: 'Send feeback!',
      splashRadius: 20,
      onPressed: () {
        url_launcher.launchUrl(
          Uri.https('github.com', '/dart-lang/dart_ci/issues'),
        );
      },
    ),
    Consumer<AuthService>(
      builder: (context, authService, child) {
        if (authService.errorMessage != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Authentication Error: ${authService.errorMessage}',
                ),
                backgroundColor: Colors.red,
              ),
            );
            authService.clearError();
          });
        }

        if (authService.isLoading) {
          return const IconButton(
            icon: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2.0),
            ),
            onPressed: null, // Disabled
          );
        }

        if (authService.isAuthenticated) {
          return IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
            onPressed: () {
              authService.signOut();
            },
          );
        } else {
          return IconButton(
            icon: const Icon(Icons.login),
            tooltip: 'Sign in with Google',
            onPressed: () {
              authService.signInWithGoogle();
            },
          );
        }
      },
    ),
  ];
}
