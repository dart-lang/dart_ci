// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_components/content/deferred_content.dart';
import 'package:angular_forms/angular_forms.dart' show formDirectives;
import 'package:angular_components/laminate/enums/alignment.dart';
import 'package:angular_components/material_checkbox/material_checkbox.dart';
import 'package:angular_components/material_chips/material_chips.dart';
import 'package:angular_components/material_chips/material_chip.dart';
import 'package:angular_components/material_radio/material_radio.dart';
import 'package:angular_components/material_tooltip/material_tooltip.dart';
import 'package:angular_components/material_tooltip/module.dart' as tooltip;

import 'log_component.dart';

import '../model/commit.dart';

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
      'commit_component.css',
      'package:angular_components/css/mdc_web/card/mdc-card.scss.css'
    ]))
class ResultsSelectorPanel {
  ResultsSelectorPanel();

  @Input()
  set changes(Changes changes) {
    _changes = changes;
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

  @Input()
  IntRange range;

  @Input()
  set selected(Set<Change> selected) {
    _selected = selected;
    initializeSelected();
  }

  @Input()
  bool failuresOnly;

  Changes _changes;
  Set<Change> _selected;

  final checked = Map<Change, bool>();
  final resultCheckboxes = Map<List<Change>, FixedMixedCheckbox>();
  final _showResultGroupCheckbox = Map<List<Change>, bool>();
  final configurationCheckboxes = Map<List<List<Change>>, FixedMixedCheckbox>();
  final _showConfigurationCheckbox = Map<List<List<Change>>, bool>();

  // When pinning results to a blamelist, we select all results.
  // When approving results, we only show checkboxes for the failures.
  bool showCheckbox(Change change) =>
      !failuresOnly || change.result != change.expected;
  bool showResultGroupCheckbox(List<Change> group) =>
      !failuresOnly ||
      _showResultGroupCheckbox.putIfAbsent(
          group, () => group.any(showCheckbox));
  bool showConfigurationCheckbox(List<List<Change>> group) =>
      !failuresOnly ||
      _showConfigurationCheckbox.putIfAbsent(
          group, () => group.any(showResultGroupCheckbox));

  int resultLimit = 10;

  Changes get changes => _changes;

  final preferredTooltipPositions = [
    RelativePosition.OffsetBottomLeft,
    RelativePosition.OffsetTopLeft
  ];

  Map<String, List<String>> summaries(List<List<Change>> group) =>
      group.first.first.configurations.summaries;

  String approvalContent(Change change) {
    if (change.approved) return "\u2714 ";
    if (change.disapproved) return "\u274C ";
    return "";
  }

  void initializeSelected() {
    if (_selected != null && _changes != null) {
      _selected.addAll(checked.keys.where(showCheckbox));
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
    bool newChecked = event == 'true';
    checkbox.setState(newChecked, false);
    for (final change in resultGroup.where(showCheckbox)) {
      setCheckbox(change, newChecked);
    }
    configurationCheckboxes[configurationGroup].setMixed();
  }

  void onConfigurationChange(
      String event, List<List<Change>> configurationGroup) {
    final checkbox = configurationCheckboxes[configurationGroup];
    if (checkbox.eventMatchesState(event)) return;
    assert(event != 'mixed');
    bool newChecked = event == 'true';
    checkbox.setState(newChecked, false);
    for (final subgroup in configurationGroup.where(showResultGroupCheckbox)) {
      resultCheckboxes[subgroup].setState(newChecked, false);
      for (final change in subgroup.where(showCheckbox)) {
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
