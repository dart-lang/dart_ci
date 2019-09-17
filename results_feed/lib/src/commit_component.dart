// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:angular/angular.dart';
import 'package:angular_forms/angular_forms.dart' show formDirectives;

import 'blamelist_component.dart';
import 'firestore_service.dart';
import 'filter_service.dart';
import 'results_panel.dart';

import 'commit.dart';

@Component(
    selector: 'dart-commit',
    directives: [
      coreDirectives,
      formDirectives,
      BlamelistComponent,
      ResultsPanel
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
  ChangeGroup commit;

  String toString() => commit.toString();
}
