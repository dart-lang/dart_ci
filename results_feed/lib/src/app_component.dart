// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:collection';
import 'dart:html';

import 'package:angular/angular.dart';
import 'package:angular_components/app_layout/material_temporary_drawer.dart';
import 'package:angular_components/material_button/material_button.dart';
import 'package:angular_components/material_icon/material_icon.dart';
import 'package:angular_components/material_toggle/material_toggle.dart';
import 'package:dart_results_feed/src/filter_component.dart';

import 'commit_component.dart';
import 'commit.dart';
import 'filter_service.dart';
import 'firestore_service.dart';
import 'build_service.dart';

@Component(
    selector: 'my-app',
    directives: [
      coreDirectives,
      CommitComponent,
      FilterComponent,
      MaterialIconComponent,
      MaterialButtonComponent,
      MaterialTemporaryDrawerComponent,
      MaterialToggleComponent
    ],
    providers: [
      ClassProvider(FirestoreService),
      ClassProvider(FilterService),
      ClassProvider(BuildService)
    ],
    templateUrl: 'app.html',
    styleUrls: [
      'package:angular_components/app_layout/layout.scss.css',
      'app_component.css'
    ])
class AppComponent implements OnInit {
  String title = 'Results Feed (Angular Dart)';
  // We often want changeGroups and commits ordered from latest to earliest.
  Map<IntRange, ChangeGroup> changeGroups =
      SplayTreeMap((key1, key2) => key2.compareTo(key1));
  Map<int, Commit> commits = SplayTreeMap((key1, key2) => key2.compareTo(key1));
  Map<String, List<Change>> changes = {};

  int firstIndex;
  int lastIndex;
  bool _fetching = false;
  num infiniteScrollVisibleRatio = 0;

  ApplicationRef _applicationRef;
  FirestoreService _firestoreService;

  AppComponent(this._firestoreService, this._applicationRef);

  @ViewChild("infiniteScroll")
  Element infiniteScroll;

  @override
  void ngOnInit() async {
    await _firestoreService.getFirebaseClient();
    await fetchCommits();
    IntersectionObserver(infiniteScrollCallback).observe(infiniteScroll);
  }

  void infiniteScrollCallback(
      List entries, IntersectionObserver observer) async {
    infiniteScrollVisibleRatio = entries[0].intersectionRatio;
    // The event stream will write to infiniteScrollVisible, stopping the loop.
    while (infiniteScrollVisibleRatio > 0) {
      await fetchCommits();
      await Future.delayed(Duration(seconds: 2));
    }
  }

  Future fetchCommits() async {
    if (_fetching) return;
    _fetching = true;
    try {
      final newCommits = (await _firestoreService.fetchCommits(firstIndex, 50))
          .map((x) => Commit.fromDocument(x));
      for (Commit commit in newCommits) {
        commits[commit.index] = commit;
        final range = IntRange(commit.index, commit.index);
        changeGroups.putIfAbsent(
            range, () => ChangeGroup.fromRange(range, [commit]));
      }
      lastIndex = commits.keys.first;
      final previousFirstIndex = firstIndex ?? lastIndex;
      firstIndex = commits.keys.last;
      // Add new commits to previously loaded blamelists that included them.
      for (ChangeGroup changeGroup in changeGroups.values) {
        if (changeGroup.range.contains(previousFirstIndex - 1) &&
            changeGroup.range.length > changeGroup.commits.length) {
          changeGroup.commits.addAll(newCommits
              .where((commit) => changeGroup.range.contains(commit.index)));
        }
      }
      final resultsData =
          await _firestoreService.fetchChanges(firstIndex, previousFirstIndex);
      final results = <IntRange, List<Change>>{};
      for (var resultData in resultsData) {
        final result = Change.fromDocument(resultData);
        final range =
            IntRange(result.blamelistStartIndex, result.blamelistEndIndex);
        changes.putIfAbsent(result.name, () => <Change>[]).add(result);
        results.putIfAbsent(range, () => <Change>[]).add(result);
      }
      for (IntRange range in results.keys) {
        changeGroups.putIfAbsent(
            range, () => ChangeGroup.fromRange(range, commits.values))
          ..addChanges(results[range])
          ..addLatestChanges(results[range].expand(_selectCurrent));
      }
    } finally {
      _fetching = false;
      _applicationRef.tick();
    }
  }

  List<Change> _selectCurrent(Change change) {
    final name = change.name;
    final laterChanges = changes[name].where((laterChange) =>
        laterChange.blamelistEndIndex > change.blamelistEndIndex);
    Set<String> configurations = change.configurations.configurations.toSet();
    for (final laterChange in laterChanges) {
      configurations.removeAll(laterChange.configurations.configurations);
    }
    if (configurations.isEmpty) return [];
    if (configurations.length == change.configurations.configurations.length)
      return [change];
    return [change.copy(newConfigurations: configurations.toList())];
  }
}
