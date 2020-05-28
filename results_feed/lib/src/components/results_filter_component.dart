// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_components/material_chips/material_chip.dart';
import 'package:angular_components/material_chips/material_chips.dart';

import '../services/filter_service.dart';

const allConfigurationGroups = Filter.allConfigurationGroups;

@Component(selector: 'results-filter', exports: [
  allConfigurationGroups
], directives: [
  coreDirectives,
  MaterialChipComponent,
  MaterialChipsComponent,
], template: '''
<span></span>
<span
    *ngFor="let type of resultTypes"
    [class.selected]="type == selectedType"
    (click)="select(type)">
  {{type}}
</span>
<span></span>
''', styles: [
  '''
  :host {
    display: flex;
    box-sizing: border-box;
    border-bottom-style:solid;
    border-width: thin;
    border-color: rgb(63, 81, 181);
  }
  span {
    color: gray;
    display: inline-flex;
    font-variant: small-caps;
    font-size: 20px;
    font-weight: bold;
    padding-left: 4px;
    padding-top: 8px;
    text-align: center;
    justify-content: center;
    height: auto;
    border-bottom-style: solid;
    border-width: medium;
    border-color: transparent;
    flex: 1 1 auto;
  }
  span.selected {
    color: rgb(63, 81, 181);
    border-color: rgb(63, 81, 181);
  }'''
])
class ResultsFilterComponent {
  static const allResults = 'all';
  static const activeFailures = 'failures';
  static const unapprovedFailures = 'unapproved';
  static const resultTypes = [allResults, activeFailures, unapprovedFailures];

  final FilterService service;
  Filter get filter => service.filter;

  ResultsFilterComponent(this.service);

  String get selectedType => filter.showLatestFailures
      ? filter.showUnapprovedOnly ? unapprovedFailures : activeFailures
      : allResults;

  void select(String type) {
    if (type == selectedType) return;
    service.filter = filter.copy(
        showLatestFailures: type != allResults,
        showUnapprovedOnly: type == unapprovedFailures)
      ..updateUrl();
  }
}
