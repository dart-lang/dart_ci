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

import 'commit.dart';

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
    selectableChanges = [
      for (ConfigGroup c in changes) SelectableConfigurationGroup(c, this)
    ];
    initializeSelected();
  }

  @Input()
  ChangeGroup commit;

  @Input()
  set selected(Set<Change> selected) {
    _selected = selected;
    initializeSelected();
  }

  Changes _changes;
  Set<Change> _selected;
  List<SelectableConfigurationGroup> selectableChanges;
  int resultLimit = 10;

  Changes get changes => _changes;

  final preferredTooltipPositions = [
    RelativePosition.OffsetBottomLeft,
    RelativePosition.OffsetTopLeft
  ];

  void initializeSelected() {
    if (_selected != null && _changes != null) {
      _selected.addAll([
        for (final c in selectableChanges)
          for (SelectableResultGroup r in c.resultGroups)
            for (SelectableChange h in r.changes) h.change
      ]);
    }
  }
}

class SelectableChange {
  final Change change;
  bool selected = true;
  final SelectableResultGroup resultGroup;
  final SelectableConfigurationGroup configurationGroup;
  final ResultsSelectorPanel panel;

  SelectableChange(this.change, this.resultGroup, this.configurationGroup, this.panel);

  void onChange(bool event) {
    if (selected == event) return;
    selected = event;
    if (event) {
      panel._selected.add(this.change);
    } else {
      panel._selected.remove(this.change);
    }
    resultGroup.checkbox.setMixed();
    configurationGroup.checkbox.setMixed();
  }
}

class SelectableResultGroup {
  List<SelectableChange> changes;
  SelectableConfigurationGroup configurationGroup;
  FixedMixedCheckbox checkbox = FixedMixedCheckbox();

  SelectableResultGroup(ResultGroup group, this.configurationGroup, ResultsSelectorPanel panel) {
    changes = [
      for (final change in group)
        SelectableChange(change, this, configurationGroup, panel)
    ];
  }

  void onChange(String event) {
    print("ResultGroup onChange $event");
    if (checkbox.eventMatchesState(event)) return;
    assert(event != 'mixed');
    bool newChecked = event == 'true';
    checkbox.setState(newChecked, false);
    for (final change in changes) {
      change.selected = newChecked;
    }
    configurationGroup.checkbox.setMixed();
  }
}

class SelectableConfigurationGroup {
  List<SelectableResultGroup> resultGroups;
  FixedMixedCheckbox checkbox = FixedMixedCheckbox();

  SelectableConfigurationGroup(ConfigGroup configGroup, ResultsSelectorPanel panel) {
    resultGroups = [
      for (final resultGroup in configGroup)
        SelectableResultGroup(resultGroup, this, panel)
    ];
  }

  get summaries =>
      resultGroups.first.changes.first.change.configurations.summaries;

  void onChange(String event) {
    if (checkbox.eventMatchesState(event)) return;
    assert(event != 'mixed');
    bool newChecked = event == 'true';
    checkbox.setState(newChecked, false);
    for (final group in resultGroups) {
      group.checkbox.setState(newChecked, false);
      for (final change in group.changes) {
        change.selected = newChecked;
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
