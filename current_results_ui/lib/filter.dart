// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'query.dart';

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

class FilterUI extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<QueryResults>(
      builder: (context, results, child) {
        final filter = results.filter;
        return Padding(
          padding: EdgeInsets.all(8.0),
          child: Wrap(
            spacing: 12.0,
            alignment: WrapAlignment.start,
            children: [
              for (final term in filter.terms)
                InputChip(
                  label: Text(term),
                  onDeleted: () {
                    final terms = filter.terms.where((t) => t != term);
                    Navigator.pushNamed(
                      context,
                      '/filter=${terms.join(',')}',
                    );
                  },
                ),
              AddWidget(filter),
            ],
          ),
        );
      },
    );
  }
}

class AddWidget extends StatefulWidget {
  final Filter filter;
  AddWidget(this.filter);

  @override
  _AddWidgetState createState() => _AddWidgetState();
}

class _AddWidgetState extends State<AddWidget> {
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200.0,
      height: 40.0,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(hintText: 'Test or configuration prefix'),
        onSubmitted: (value) {
          if (value.trim().isEmpty) return;
          final newTerms = value.split(',').map((s) => s.trim());
          bool isNotReplacedByNewTerm(String term) => !newTerms.any((newTerm) =>
              term.startsWith(newTerm) || newTerm.startsWith(term));
          final filterText = widget.filter.terms
              .where(isNotReplacedByNewTerm)
              .followedBy(newTerms)
              .join(',');
          controller.text = '';
          Navigator.pushNamed(
            context,
            '/filter=$filterText',
          );
        },
      ),
    );
  }
}
