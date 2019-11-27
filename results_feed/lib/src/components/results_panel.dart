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

import 'log_component.dart';

import '../model/commit.dart';

@Component(
    selector: 'results-panel',
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
    templateUrl: 'results_panel.html',
    styleUrls: ([
      'commit_component.css',
      'package:angular_components/css/mdc_web/card/mdc-card.scss.css'
    ]))
class ResultsPanel {
  ResultsPanel();

  @Input()
  Changes changes;

  @Input()
  IntRange range;

  Map<String, List<String>> summaries(List<List<Change>> group) =>
      group.first.first.configurations.summaries;

  int resultLimit = 10;

  final preferredTooltipPositions = [
    RelativePosition.OffsetBottomLeft,
    RelativePosition.OffsetTopLeft
  ];

  String approvalContent(Change change) {
    if (change.approved) return "\u2714 ";
    if (change.disapproved) return "\u274C ";
    return "";
  }
}
