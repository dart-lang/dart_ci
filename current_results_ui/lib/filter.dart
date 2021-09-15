// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'query.dart';
import 'main.dart';

class Filter {
  final List<String> terms;
  Filter(String termString) : terms = _parse(termString);

  static List<String> _parse(String termString) {
    if (termString.trim() == '') return List.unmodifiable([]);
    return List.unmodifiable(termString.split(',').map((s) => s.trim()));
  }

  bool hasSameTerms(Filter other) =>
      const ListEquality().equals(terms, other.terms);
}

class FilterUI extends StatefulWidget {
  @override
  State<FilterUI> createState() => _FilterUIState();
}

class _FilterUIState extends State<FilterUI> {
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QueryResults>(
      builder: (context, results, child) {
        final filter = results.filter;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 100.0),
              child: Scrollbar(
                child: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
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
                                pushRoute(context,
                                    terms:
                                        filter.terms.where((t) => t != term));
                              },
                              onPressed: () {
                                controller.text = term;
                              }),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Divider(
              color: Colors.grey[300],
              height: 2,
              thickness: 2,
            ),
            Padding(
              padding: EdgeInsets.only(left: 12.0),
              child: SizedBox(
                width: 300.0,
                height: 36.0,
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                      hintText: 'Test, configuration or experiment prefix'),
                  onSubmitted: (value) {
                    if (value.trim().isEmpty) return;
                    final newTerms = value.split(',').map((s) => s.trim());
                    bool isNotReplacedByNewTerm(String term) =>
                        !newTerms.any((newTerm) =>
                            term.startsWith(newTerm) ||
                            newTerm.startsWith(term));
                    controller.text = '';
                    pushRoute(context,
                        terms: filter.terms
                            .where(isNotReplacedByNewTerm)
                            .followedBy(newTerms));
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
