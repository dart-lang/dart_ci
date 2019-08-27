// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:angular/angular.dart';
import 'package:angular_components/material_toggle/material_toggle.dart';
import 'package:angular_components/material_select/material_select.dart';
import 'package:angular_components/material_select/material_select_item.dart';

import 'filter_service.dart';

@Component(selector: 'app-filter', directives: [
  coreDirectives,
  MaterialToggleComponent,
  MaterialSelectComponent,
  MaterialSelectItemComponent
], template: '''
    <material-toggle [(checked)]="filterService.showAllCommits" label="Show all commits">
    </material-toggle>
    <hr>
    <b>Show changes on builders:</b>
    <material-select focusList [selection]="filterService.groupSelector" (selection)="onSelection(\$event)" class="bordered-list" [itemRenderer]="identityFunction">
      <material-select-item *ngFor="let group of filterService.builderGroups" focusItem [value]="group"></material-select-item>
    </material-select>
  ''')
class FilterComponent {
  FilterComponent(this.filterService);

  String identityFunction(t) => t;
  @Input()
  FilterService filterService;
  onSelection(event) {
    filterService.enabledBuilderGroups = event.toList();
    print("bar $event");
  }
}
