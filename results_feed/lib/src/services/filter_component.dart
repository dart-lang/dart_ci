// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_components/material_radio/material_radio.dart';
import 'package:angular_components/material_radio/material_radio_group.dart';
import 'package:angular_components/material_select/material_select.dart';
import 'package:angular_components/material_select/material_select_item.dart';

import 'filter_service.dart';

const allConfigurationGroups = Filter.allConfigurationGroups;

@Component(selector: 'app-filter', exports: [
  allConfigurationGroups
], directives: [
  coreDirectives,
  MaterialRadioComponent,
  MaterialRadioGroupComponent,
  MaterialSelectComponent,
  MaterialSelectItemComponent,
  NgModel,
], template: '''
  <material-radio-group
      [ngModel]="changeType"
      (ngModelChange)="setChangeType(\$event)">
    <material-radio
        *ngFor="let option of changeTypes"
        style="display: flex"
        [value]="option">{{option['label']}}
    </material-radio>
  </material-radio-group>
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
    changeType = changeTypes.firstWhere(
        (type) =>
            type['latestFailures'] == filter.showLatestFailures &&
            type['unapprovedOnly'] == filter.showUnapprovedOnly,
        orElse: () => changeTypes.first);
  }

  void onSelectionChange(_) {
    final values = groupSelector.selectedValues.toList();
    service.filter = filter.copy(configurationGroups: values);
    filter.updateUrl();
  }

  List<Map> changeTypes = [
    {
      'label': 'Show all changes',
      'latestFailures': false,
      'unapprovedOnly': false
    },
    {
      'label': 'Show latest failures',
      'latestFailures': true,
      'unapprovedOnly': false
    },
    {
      'label': 'Show latest unapproved failures',
      'latestFailures': true,
      'unapprovedOnly': true
    },
  ];

  Map changeType;

  void setChangeType(Map event) {
    changeType = event;
    service.filter = filter.copy(
        showLatestFailures: event['latestFailures'],
        showUnapprovedOnly: event['unapprovedOnly']);
    filter.updateUrl();
  }

  String identityFunction(t) => t;
}
