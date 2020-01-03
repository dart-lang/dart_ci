// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_components/material_button/material_button.dart';
import 'package:angular_components/material_input/material_input.dart';
import 'package:angular_components/material_input/material_input_multiline.dart';
import 'package:angular_forms/angular_forms.dart' show formDirectives;
import 'package:angular_router/angular_router.dart';

import '../formatting.dart';
import '../model/comment.dart';
import '../model/commit.dart';
import '../services/try_data_service.dart';
import 'results_panel.dart';
import 'results_selector_panel.dart';

@Component(
    selector: 'try-results',
    directives: [
      coreDirectives,
      formDirectives,
      materialInputDirectives,
      MaterialButtonComponent,
      MaterialMultilineInputComponent,
      ResultsPanel,
      ResultsSelectorPanel
    ],
    providers: [
      ClassProvider(TryDataService),
      overlayBindings,
    ],
    templateUrl: 'try_results_component.html',
    exports: [formattedDate, formattedEmail],
    styles: ['div {padding: 8px;}'])
class TryResultsComponent implements OnActivate {
  TryDataService _tryDataService;
  ApplicationRef _applicationRef;

  int change;
  int patch;
  ReviewInfo changeInfo;
  ChangeGroup changeGroup = ChangeGroup(null, {}, [], []);
  int cachedPatch;
  int cachedChange;
  List<Change> changes;
  List<Comment> comments;
  IntRange range = IntRange(1, 0);
  bool updating = false;
  bool updatePending = false;
  bool _approving = false;
  final selected = Set<Change>();
  String commentText;

  TryResultsComponent(this._tryDataService, this._applicationRef);

  bool get approveEnabled => changeGroup.changes.flat
      .any((change) => change.result != change.expected);

  bool get approving => _approving;
  set approving(bool approve) {
    if (approve) {
      _tryDataService.logIn().then((_) {
        _approving = _tryDataService.isLoggedIn;
      });
    } else {
      _approving = false;
    }
  }

  Future<void> approve(bool approval) async {
    for (Change result in selected) {
      result.approved = approval ?? result.approved;
    }
    final comment = await _tryDataService.saveApproval(
        approval,
        commentText,
        changeGroup.comments.isEmpty
            ? null
            : changeGroup.comments.last.baseComment ??
                changeGroup.comments.last.id,
        [for (Change result in selected) result.id],
        changeInfo.review);
    comments
      ..add(comment)
      ..sort();
    _approving = false;
  }

  void tryUpdate() async {
    if (updating) {
      updatePending = true;
    } else {
      updating = true;
      try {
        await update();
      } finally {
        updating = false;
        if (updatePending) {
          updatePending = false;
          tryUpdate(); // Not awaited, tail call.
        }
        // TODO: better change management.
        _applicationRef.tick();
      }
    }
  }

  Future<void> update() async {
    if (change == null) return;
    if (changeInfo == null || change != changeInfo.review) {
      changeInfo = await _tryDataService.reviewInfo(change);
    }
    if (change != cachedChange || patch != cachedPatch) {
      changes = await _tryDataService.changes(changeInfo, patch);
      comments = await _tryDataService.comments(changeInfo.review);
      comments..sort();
      cachedChange = change;
      cachedPatch = patch;
      changeGroup = ChangeGroup(null, {}, comments, changes);
    }
  }

  @override
  void onActivate(_, RouterState current) {
    final changeParam = current.parameters['cl'];
    change = changeParam == null ? null : int.parse(changeParam);
    final patchParam = current.parameters['patch'];
    patch = patchParam == null ? null : int.parse(patchParam);
    tryUpdate();
  }
}
