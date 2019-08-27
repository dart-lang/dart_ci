// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:angular_components/angular_components.dart';

class FilterService {
  FilterService() {
    enabledBuilderGroups = builderGroups.toList();
    groupSelector = SelectionModel.multi(selectedValues: enabledBuilderGroups);
    groupSelector.selectionChanges.listen((_) {
      enabledBuilderGroups = groupSelector.selectedValues.toList();
    });
  }
  final builderGroups = const <String>[
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
  List<String> enabledBuilderGroups;
  bool showAllCommits = false;
  SelectionModel<String> groupSelector;
  void onSelection(event) {
    print(event);
    enabledBuilderGroups = event.toList();
  }
}
