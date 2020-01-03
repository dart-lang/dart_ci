// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_components/material_toggle/material_toggle.dart';
import 'package:angular_components/material_select/material_select.dart';
import 'package:angular_components/material_select/material_select_item.dart';

import 'filter_service.dart';

const allConfigurationGroups = Filter.allConfigurationGroups;

@Component(selector: 'app-filter', exports: [
  allConfigurationGroups
], directives: [
  coreDirectives,
  MaterialToggleComponent,
  MaterialSelectComponent,
  MaterialSelectItemComponent
], template: '''
    <material-toggle
        (checkedChange)="onShowAllCommits(\$event)"
        [checked]="filter.showAllCommits"
        label="Show all commits">
    </material-toggle>
    <hr>
    <material-toggle
        (checkedChange)="onShowLatestFailures(\$event)"
        [checked]="filter.showLatestFailures"
        label="Show only latest failures">
    </material-toggle>
    <hr>
   <b>Show changes on builders:</b>
    <material-select
        class="bordered-list"
        focusList
        [selection]="groupSelector"
        [itemRenderer]="identityFunction">
      <material-select-item
          *ngFor="let group of allConfigurationGroups"
          focusItem
          [value]="group">
      </material-select-item>
    </material-select>
  ''')
class FilterComponent {
  static const allConfigurationGroups = Filter.allConfigurationGroups;

  @Input()
  FilterService service;
  SelectionModel<String> groupSelector;

  Filter get filter => service.filter;

  FilterComponent(this.service) {
    groupSelector = SelectionModel.multi(
        selectedValues: service.filter.configurationGroups);
    groupSelector.selectionChanges.listen(onSelectionChange);
  }

  void onSelectionChange(_) {
    final values = groupSelector.selectedValues.toList();
    service.filter = filter.copy(configurationGroups: values);
    filter.updateUrl();
  }

  void onShowAllCommits(bool event) {
    service.filter = filter.copy(showAllCommits: event);
    filter.updateUrl();
  }

  void onShowLatestFailures(bool event) {
    service.filter = filter.copy(showLatestFailures: event);
    filter.updateUrl();
  }

  String identityFunction(t) => t;
}
