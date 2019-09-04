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
    <material-toggle  (checkedChange)="filterService.showAllCommitsEvent(\$event)"  label="Show all commits">
    </material-toggle>
    <hr>
    <material-toggle  (checkedChange)="filterService.showLatestFailuresEvent(\$event)"  label="Show only latest failures">
    </material-toggle>
    <hr>
   <b>Show changes on builders:</b>
    <material-select class="bordered-list"  focusList [selection]="filterService.groupSelector"  [itemRenderer]="identityFunction">
      <material-select-item  *ngFor="let group of filterService.defaultBuilderGroups"   focusItem   [value]="group">
      </material-select-item>
    </material-select>
  ''')
class FilterComponent {
  FilterComponent(this.filterService);

  String identityFunction(t) => t;
  @Input()
  FilterService filterService;
}
