// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../filter.dart';
import '../query.dart';
import '../src/widgets/results_view.dart';
import '../try_results_screen.dart';
import 'data/try_query_results.dart';

typedef QueryResultsFactory = QueryResultsBase Function(Filter filter);
typedef TryQueryResultsFactory =
    TryQueryResults Function({
      required int cl,
      required int patchset,
      required Filter filter,
    });

GoRouter createRouter({
  QueryResultsFactory queryResultsProvider = QueryResults.new,
  TryQueryResultsFactory tryQueryResultsProvider = TryQueryResults.new,
}) => GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) {
        final filter = Filter(state.uri.queryParameters['filter'] ?? '');
        return ChangeNotifierProvider<QueryResultsBase>(
          create: (_) => queryResultsProvider(filter),
          child: ResultsView(title: 'Current Results', filter: filter),
        );
      },
    ),
    GoRoute(
      path: '/cl/:cl/:patchset',
      builder: (context, state) {
        final cl = int.tryParse(state.pathParameters['cl']!);
        final patchset = int.tryParse(state.pathParameters['patchset']!);
        final filter = Filter(state.uri.queryParameters['filter'] ?? '');

        if (cl != null && patchset != null) {
          return MultiProvider(
            providers: [
              ChangeNotifierProvider<TryQueryResults>(
                create: (_) => tryQueryResultsProvider(
                  filter: filter,
                  cl: cl,
                  patchset: patchset,
                ),
              ),
              ListenableProxyProvider<TryQueryResults, QueryResultsBase>(
                update: (_, tryResults, _) => tryResults,
              ),
            ],
            child: TryResultsScreen(),
          );
        }
        // TODO: Should create a proper error screen here.
        return const Text('Invalid CL or patchset');
      },
    ),
  ],
);
