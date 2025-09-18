// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:go_router/go_router.dart';

import '../filter.dart';
import '../main.dart';

GoRouter createRouter() => GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) {
        final filter = Filter(state.uri.queryParameters['filter'] ?? '');
        final tab = state.uri.queryParameters.containsKey('showAll')
            ? 2
            : state.uri.queryParameters.containsKey('flaky')
            ? 1
            : 0;
        return CurrentResultsScreen(filter: filter, initialTabIndex: tab);
      },
    ),
  ],
);
