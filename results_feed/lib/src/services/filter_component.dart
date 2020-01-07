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
        (checkedChange)="onShowLatestFailures(\$event)"
        [checked]="filter.showLatestFailures"
        label="Show only latest failures">
    </material-toggle>
    <hr>
    <material-toggle
        (checkedChange)="onShowUnapprovedOnly(\$event)"
        [checked]="filter.showUnapprovedOnly"
        label="Show only unapproved failures">
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
    if (groupSelector.selectedValues.isEmpty) {
      // Do not allow deselecting the last selected group.
      // Selecting synchronously or with Future.microtask don't show in UI.
      final recheck = service.filter.configurationGroups.first;
      Future(() => groupSelector.select(recheck));
      return;
    }
    final values = groupSelector.selectedValues.toList();
    service.filter = filter.copy(configurationGroups: values);
    filter.updateUrl();
  }

  void onShowLatestFailures(bool event) {
    service.filter = filter.copy(showLatestFailures: event);
    filter.updateUrl();
  }

  void onShowUnapprovedOnly(bool event) {
    service.filter = filter.copy(showUnapprovedOnly: event);
    filter.updateUrl();
  }

  String identityFunction(t) => t;
}
