// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:angular/angular.dart';
import 'package:angular_components/material_button/material_button.dart';
import 'package:angular_forms/angular_forms.dart' show formDirectives;

import 'blamelist_component.dart';
import 'blamelist_picker.dart';
import '../model/commit.dart';
import '../services/firestore_service.dart';
import '../services/filter_service.dart';
import 'results_panel.dart';
import 'results_selector_panel.dart';

@Component(
    selector: 'dart-commit',
    directives: [
      coreDirectives,
      formDirectives,
      MaterialButtonComponent,
      BlamelistComponent,
      BlamelistPicker,
      ResultsPanel,
      ResultsSelectorPanel,
    ],
    templateUrl: 'commit_component.html',
    styleUrls: ([
      'commit_component.css',
      'package:angular_components/css/mdc_web/card/mdc-card.scss.css'
    ]))
class CommitComponent {
  CommitComponent(this.firestoreService);

  @Input()
  FirestoreService firestoreService;

  @Input()
  Filter filter;

  @Input()
  ChangeGroup changeGroup;

  bool collapsedBlamelist = true;
  int resultLimit = 10;

  bool chooseCommit = false;

  final selected = Set<Change>();
  Commit selectedCommit;

  Future pinCommit(int pin, List<Change> results) {
    return firestoreService.pinResults(
        selectedCommit.index, [for (Change result in results) result.id]);
  }
}
