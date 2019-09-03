// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:html';
import 'dart:convert';

import 'package:angular_components/angular_components.dart';

class FilterService {
  FilterService() {
    updateFromUrl();
    groupSelector = SelectionModel.multi(selectedValues: enabledBuilderGroups);
    groupSelector.selectionChanges.listen((_) {
      enabledBuilderGroups = groupSelector.selectedValues.toList();
      if (enabledBuilderGroups.isEmpty) {
        showAllCommits = true;
      }
      updateUrl();
    });
  }
  static const allBuilderGroups = <String>[
    'analyzer',
    'app_jitk',
    'dart2js',
    'dartdevc',
    'dartdevk',
    'dartk',
    'dartkb',
    'dartkp',
    'fasta',
    'unittest',
    'vm'
  ];

  /// We need this field because Angular cannot access the static member.
  final List<String> defaultBuilderGroups = allBuilderGroups;
  List<String> enabledBuilderGroups;
  static const defaultShowAllCommits = false;
  bool showAllCommits;
  SelectionModel<String> groupSelector;

  void checkedChange(event) {
    showAllCommits = event;
    updateUrl();
  }

  void updateUrl() {
    final settings = {
      if (showAllCommits != defaultShowAllCommits) 'showAll': showAllCommits,
      if (enabledBuilderGroups.length != defaultBuilderGroups.length)
        'enabled': enabledBuilderGroups
    };
    final fragment =
        settings.isEmpty ? '' : Uri.encodeComponent(jsonEncode(settings));
    Uri old = Uri.parse(window.location.href);
    if (old.fragment != fragment) {
      window.location.replace(old.replace(fragment: fragment).toString());
    }
  }

  void updateFromUrl() {
    final fragment = Uri.parse(window.location.href).fragment;
    final settings =
        fragment.isEmpty ? {} : jsonDecode(Uri.decodeComponent(fragment));
    showAllCommits = settings['showAll'] ?? defaultShowAllCommits;
    enabledBuilderGroups =
        List<String>.from(settings['enabled'] ?? defaultBuilderGroups);
  }
}
