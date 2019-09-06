// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_components/content/deferred_content.dart';
import 'package:angular_forms/angular_forms.dart' show formDirectives;
import 'package:angular_components/laminate/enums/alignment.dart';
import 'package:angular_components/material_chips/material_chips.dart';
import 'package:angular_components/material_chips/material_chip.dart';
import 'package:angular_components/material_tooltip/material_tooltip.dart';
import 'package:angular_components/material_tooltip/module.dart' as tooltip;

import 'firestore_service.dart';
import 'filter_service.dart';
import 'log_component.dart';

import 'commit.dart';

@Component(
    selector: 'dart-commit',
    directives: [
      coreDirectives,
      formDirectives,
      DeferredContentDirective,
      LogComponent,
      MaterialChipComponent,
      MaterialChipsComponent,
      MaterialPaperTooltipComponent,
      MaterialTooltipDirective,
      MaterialTooltipTargetDirective,
      RelativePosition
    ],
    providers: [popupBindings, tooltip.materialTooltipBindings],
    templateUrl: 'commit_component.html',
    styleUrls: ([
      'commit_component.css',
      'package:angular_components/css/mdc_web/card/mdc-card.scss.css'
    ]))
class CommitComponent {
  CommitComponent(this.firestoreService, this.filterService);

  @Input()
  FirestoreService firestoreService;

  @Input()
  FilterService filterService;

  @Input()
  ChangeGroup commit;

  final preferredTooltipPositions = [
    RelativePosition.OffsetBottomLeft,
    RelativePosition.OffsetTopLeft
  ];
  String toString() => commit.toString();
}
