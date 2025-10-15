// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'src/app/app.dart';
import 'src/shared/platform/url_strategy_stub.dart'
    if (dart.library.js_interop) 'src/shared/platform/url_strategy_web.dart';

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
