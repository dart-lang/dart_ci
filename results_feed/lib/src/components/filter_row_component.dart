// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_components/material_input/material_auto_suggest_input.dart';
import 'package:angular_components/material_chips/material_chip.dart';
import 'package:angular_components/material_chips/material_chips.dart';
import 'package:angular_components/material_icon/material_icon.dart';

import '../services/build_service.dart';
import '../services/filter_service.dart';

const allConfigurationGroups = Filter.allConfigurationGroups;
const testSuggestion = '[suite]/[test name]';

@Component(
    selector: 'filter-row',
    exports: [allConfigurationGroups],
    directives: [
      coreDirectives,
      MaterialAutoSuggestInputComponent,
      MaterialChipComponent,
      MaterialChipsComponent,
      MaterialIconComponent,
      NgModel,
    ],
    providers: [
      popupBindings,
    ],
    templateUrl: 'filter_row_component.html',
    styleUrls: [
      'package:angular_components/app_layout/layout.scss.css',
      'filter_row_component.css'
    ])
class FilterRowComponent implements OnInit {
  @ViewChild('addFilterTextInput')
  MaterialAutoSuggestInputComponent addFilterTextInput;

  final FilterService service;
  final BuildService buildService;
  bool addingFilter = false;
  bool addingTestFilter = false;
  String filterText = '';
  List<String> selectionOptions = [];

  Filter get filter => service.filter;

  FilterRowComponent(this.service, this.buildService);

  @override
  void ngOnInit() async {
    final configurations = await buildService.configurations;
    selectionOptions = [testSuggestion]
        .followedBy({
          for (final configuration in configurations)
            configuration.split('-').first + '-'
        })
        .followedBy(configurations)
        .toList();
  }

  String get test => filter.singleTest;

  Iterable<String> get configurations =>
      filter.configurationGroups.followedBy(filter.configurations).toList();

  void addFilter() {
    addingFilter = true;
    Future.delayed(Duration(), () => addFilterTextInput.focus());
  }

  void clear() {
    filterText = '';
    addingFilter = false;
    addingTestFilter = false;
  }

  void selectionChange(event) {
    if (event is String && event != testSuggestion) {
      service.addConfiguration(event);
      clear();
    }
  }

  void inputTextChange(event) {
    filterText = event;
    addingTestFilter = event is String && event.contains('/');
  }

  void addTestFilter() {
    if (filterText != testSuggestion) {
      service.setTestFilter(filterText);
    }
    clear();
  }
}
