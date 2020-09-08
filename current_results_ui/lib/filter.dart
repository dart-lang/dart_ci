// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Filter extends ChangeNotifier {
  List<String> terms = [];

  void addAll(String value) {
    for (final term in value.split(',')) {
      final trimmed = term.trim();
      if (trimmed.isEmpty) continue;
      if (terms.contains(trimmed)) continue;
      terms.add(trimmed);
    }
    notifyListeners();
  }

  void remove(String term) {
    terms.remove(term);
    notifyListeners();
  }
}

class FilterUI extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<Filter>(
      builder: (context, filter, child) {
        return Padding(
          padding: EdgeInsets.all(8.0),
          child: Wrap(
            spacing: 12.0,
            alignment: WrapAlignment.start,
            children: [
              for (final term in filter.terms)
                InputChip(
                    label: Text(term), onDeleted: () => filter.remove(term)),
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
          widget.filter.addAll(value);
          controller.text = '';
        },
      ),
    );
  }
}
