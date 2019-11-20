// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

import '../model/commit.dart';
import 'results_panel.dart';
import '../services/try_data_service.dart';

@Component(
    selector: 'try-results',
    directives: [coreDirectives, routerDirectives, ResultsPanel],
    providers: [
      ClassProvider(TryDataService),
    ],
    templateUrl: 'try_results_component.html',
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
  IntRange range = IntRange(1, 0);
  bool updating = false;
  bool updatePending = false;

  TryResultsComponent(this._tryDataService, this._applicationRef);

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
    if (change != changeInfo?.review)
      changeInfo = await _tryDataService.reviewInfo(change);
    if (change != cachedChange || patch != cachedPatch) {
      changes = await _tryDataService.changes(changeInfo, patch);
      cachedChange = change;
      cachedPatch = patch;
      changeGroup = ChangeGroup(null, {}, changes, []);
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
