// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../data/results_repository.dart';

class FilterUI extends StatefulWidget {
  const FilterUI({super.key});

  @override
  State<FilterUI> createState() => _FilterUIState();
}

class _FilterUIState extends State<FilterUI> {
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final results = context.watch<QueryResultsBase>();
    final filter = results.filter;

    void updateFilter(Iterable<String> newTerms) {
      final uri = GoRouter.of(context).routeInformationProvider.value.uri;
      final newUri = uri.replace(
        queryParameters: {...uri.queryParameters, 'filter': newTerms.join(',')},
      );
      GoRouter.of(context).go(newUri.toString());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 100.0),
          child: Scrollbar(
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.only(top: 16.0),
                alignment: Alignment.topLeft,
                child: Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  alignment: WrapAlignment.start,
                  children: [
                    for (final term in filter.terms)
                      InputChip(
                        label: Text(term),
                        onDeleted: () {
                          updateFilter(filter.terms.where((t) => t != term));
                        },
                        onPressed: () {
                          controller.text = term;
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          width: 300.0,
          child: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Test, configuration or experiment prefix',
            ),
            onSubmitted: (value) {
              if (value.trim().isEmpty) return;
              final newTerms = value.split(',').map((s) => s.trim());
              bool isNotReplacedByNewTerm(String term) => !newTerms.any(
                (newTerm) =>
                    term.startsWith(newTerm) || newTerm.startsWith(term),
              );
              controller.text = '';
              updateFilter(
                filter.terms.where(isNotReplacedByNewTerm).followedBy(newTerms),
              );
            },
          ),
        ),
      ],
    );
  }
}
