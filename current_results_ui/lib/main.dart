// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'src/auth_service.dart';
import 'src/platform_specific/url_strategy_stub.dart'
    if (dart.library.js_interop) 'src/platform_specific/url_strategy_web.dart';
import 'src/routing.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    configureUrlStrategy();
    runApp(const CurrentResultsApp());
  } catch (e) {
    print('Failed to initialize Firebase: $e');
    runApp(FirebaseErrorApp(error: e.toString()));
  }
}

class FirebaseErrorApp extends StatelessWidget {
  final String error;
  const FirebaseErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Initialization Error')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SelectionArea(
              child: Text(
                'Failed to initialize Firebase. Please check your configuration and ensure you have added the necessary platform-specific setup.\n\nError: $error',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

final _router = createRouter();

class CurrentResultsApp extends StatelessWidget {
  const CurrentResultsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AuthService>(
      create: (_) => AuthService(),
      child: MaterialApp.router(
        title: 'Current Results',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.compact,
        ),
        routerConfig: _router,
      ),
    );
  }
}
