// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_components/content/deferred_content.dart';
import 'package:angular_components/laminate/enums/alignment.dart';
import 'package:angular_components/material_checkbox/material_checkbox.dart';
import 'package:angular_components/material_chips/material_chip.dart';
import 'package:angular_components/material_chips/material_chips.dart';
import 'package:angular_components/material_radio/material_radio.dart';
import 'package:angular_components/material_tooltip/material_tooltip.dart';
import 'package:angular_components/material_tooltip/module.dart' as tooltip;
import 'package:angular_forms/angular_forms.dart' show formDirectives;

import '../formatting.dart' as formatting;
import '../model/commit.dart';
import '../services/filter_service.dart';
import '../services/try_data_service.dart';
import 'log_component.dart';

@Component(
    selector: 'results-selector-panel',
    directives: [
      coreDirectives,
      formDirectives,
      DeferredContentDirective,
      LogComponent,
      MaterialButtonComponent,
      MaterialCheckboxComponent,
      MaterialChipComponent,
      MaterialChipsComponent,
      MaterialPaperTooltipComponent,
      MaterialRadioComponent,
      MaterialRadioGroupComponent,
      MaterialTooltipDirective,
      MaterialTooltipTargetDirective,
      RelativePosition
    ],
    providers: [popupBindings, tooltip.materialTooltipBindings],
    templateUrl: 'results_selector_panel.html',
    styleUrls: ([
      'results.css',
      'package:angular_components/css/mdc_web/card/mdc-card.scss.css'
    ]))
class ResultsSelectorPanel {
  ResultsSelectorPanel();

  @Input()
  set changes(Changes changes) {
    _changes = changes;
    recomputeChanges();
  }

  Changes get changes => _changes;
  Changes _changes;

  // Removes passing changes if failuresOnly is set. Does not handle changing
  // failuresOnly from true to false.
  void recomputeChanges() {
    if (_changes == null) return;
    if (failuresOnly) {
      _changes = Changes(changes.flat.where((change) => change.failed));
    }
    for (final configurationGroup in changes) {
      configurationCheckboxes[configurationGroup] = FixedMixedCheckbox();
      for (final resultGroup in configurationGroup) {
        resultCheckboxes[resultGroup] = FixedMixedCheckbox();
        for (final change in resultGroup) {
          checked[change] = true;
        }
      }
    }
    initializeSelected();
  }

  @Input()
  ChangeGroup commit;

  /// [range] will be null if these are try results
  @Input()
  IntRange range;

  /// [builds] will be null if these are CI results
  @Input()
  Map<int, Map<String, TryBuild>> builds;

  /// A map from configurations to try builders. Null for CI results.
  // TODO(whesse): Make lazy, fetch directly from try data service, not an input.
  @Input()
  Map<String, String> builders;

  @Input()
  Filter filter = Filter.defaultFilter;

  @Input()
  set selected(Set<Change> selected) {
    _selected = selected;
    initializeSelected();
  }

  @Input()
  set failuresOnly(bool value) {
    _failuresOnly = value;
    recomputeChanges();
  }

  bool get failuresOnly => _failuresOnly;

  bool _failuresOnly = false;

  Set<Change> _selected;

  final Map<Change, bool> checked = {};
  final Map<List<Change>, FixedMixedCheckbox> resultCheckboxes = {};
  final Map<List<List<Change>>, FixedMixedCheckbox> configurationCheckboxes =
      {};

  int resultLimit = 10;

  final preferredTooltipPositions = [
    RelativePosition.OffsetBottomLeft,
    RelativePosition.OffsetTopLeft
  ];

  Map<String, List<String>> summaries(List<List<Change>> group) {
    final first = group.first.first;
    final configurations = filter.showLatestFailures
        ? first.activeConfigurations
        : first.configurations;
    return configurations.summaries;
  }

  String buildbucketID(int patchset, String configuration) =>
      builds[patchset][builders[configuration]].buildbucketID;

  String approvalContent(Change change) =>
      change.approved ? formatting.checkmark : '';

  void initializeSelected() {
    if (_selected != null && _changes != null) {
      _selected.addAll(checked.keys);
    }
  }

  bool setCheckbox(Change change, bool event) {
    if (checked[change] == event) return false;
    checked[change] = event;
    if (event) {
      _selected.add(change);
    } else {
      _selected.remove(change);
    }
    return true;
  }

  void onChange(bool event, Change change, List<Change> resultGroup,
      List<List<Change>> configurationGroup) {
    if (setCheckbox(change, event)) {
      configurationCheckboxes[configurationGroup].setMixed();
      resultCheckboxes[resultGroup].setMixed();
    }
  }

  void onResultChange(String event, List<Change> resultGroup,
      List<List<Change>> configurationGroup) {
    final checkbox = resultCheckboxes[resultGroup];
    if (checkbox.eventMatchesState(event)) return;
    assert(event != 'mixed');
    final newChecked = event == 'true';
    checkbox.setState(newChecked, false);
    for (final change in resultGroup) {
      setCheckbox(change, newChecked);
    }
    configurationCheckboxes[configurationGroup].setMixed();
  }

  void onConfigurationChange(
      String event, List<List<Change>> configurationGroup) {
    final checkbox = configurationCheckboxes[configurationGroup];
    if (checkbox.eventMatchesState(event)) return;
    assert(event != 'mixed');
    final newChecked = event == 'true';
    checkbox.setState(newChecked, false);
    for (final subgroup in configurationGroup) {
      resultCheckboxes[subgroup].setState(newChecked, false);
      for (final change in subgroup) {
        setCheckbox(change, newChecked);
      }
    }
  }
}

class FixedMixedCheckbox {
  bool checked = true;
  bool indeterminate = false;

  // Model change indeterminate <-> checked generates a bad 'unchecked' event.
  // Workaround for issue https://github.com/dart-lang/angular_components/issues/434
  bool expectBadEvent = false;

  bool eventMatchesState(String event) {
    if (event == 'mixed' && indeterminate ||
        event == 'true' && checked ||
        event == 'false' && !indeterminate && !checked ||
        event == 'false' && expectBadEvent) {
      expectBadEvent = false;
      return true;
    }
    return false;
  }

  void setState(bool newChecked, bool newIndeterminate) {
    assert(!newChecked || !newIndeterminate);
    if (newChecked && indeterminate || checked && newIndeterminate) {
      expectBadEvent = true;
    }
    checked = newChecked;
    indeterminate = newIndeterminate;
  }

  void setMixed() => setState(false, true);
}
