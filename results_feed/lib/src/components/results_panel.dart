// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_components/content/deferred_content.dart';
import 'package:angular_components/laminate/enums/alignment.dart';
import 'package:angular_components/material_chips/material_chip.dart';
import 'package:angular_components/material_chips/material_chips.dart';
import 'package:angular_components/material_tooltip/material_tooltip.dart';
import 'package:angular_components/material_tooltip/module.dart' as tooltip;
import 'package:angular_forms/angular_forms.dart' show formDirectives;

import '../formatting.dart' as formatting;
import '../model/commit.dart';
import '../services/filter_service.dart';
import 'log_component.dart';

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
      'results.css',
      'package:angular_components/css/mdc_web/card/mdc-card.scss.css'
    ]))
class ResultsPanel {
  ResultsPanel();

  @Input()
  Changes changes;

  @Input()
  IntRange range;

  @Input()
  Filter filter = Filter.defaultFilter;

  Map<String, List<String>> summaries(List<List<Change>> group) {
    final first = group.first.first;
    final configurations = filter.showLatestFailures
        ? first.activeConfigurations
        : first.configurations;
    return configurations.summaries;
  }

  int resultLimit = 10;

  final preferredTooltipPositions = [
    RelativePosition.OffsetBottomLeft,
    RelativePosition.OffsetTopLeft
  ];

  String approvalContent(Change change) =>
      change.approved ? formatting.checkmark : '';
}
