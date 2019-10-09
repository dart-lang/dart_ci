// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:collection';
import 'dart:html';

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_components/app_layout/material_temporary_drawer.dart';
import 'package:angular_components/laminate/components/modal/modal.dart';
import 'package:angular_components/laminate/overlay/module.dart';
import 'package:angular_components/material_button/material_button.dart';
import 'package:angular_components/material_dialog/material_dialog.dart';
import 'package:angular_components/material_icon/material_icon.dart';
import 'package:angular_components/material_toggle/material_toggle.dart';
import 'package:angular_router/angular_router.dart';
import 'package:dart_results_feed/src/filter_component.dart';

import 'commit_component.dart';
import 'commit.dart';
import 'filter_service.dart';
import 'firestore_service.dart';
import 'build_service.dart';

@Component(
    selector: 'my-app',
    pipes: [commonPipes],
    directives: [
      coreDirectives,
      AutoDismissDirective,
      CommitComponent,
      FilterComponent,
      MaterialIconComponent,
      MaterialButtonComponent,
      MaterialDialogComponent,
      MaterialTemporaryDrawerComponent,
      MaterialToggleComponent,
      ModalComponent
    ],
    providers: [
      ClassProvider(FilterService),
      ClassProvider(BuildService),
      overlayBindings
    ],
    templateUrl: 'app.html',
    styleUrls: [
      'package:angular_components/app_layout/layout.scss.css',
      'app_component.css'
    ])
class AppComponent implements OnInit, CanReuse {
  String title = 'Results Feed (Angular Dart)';

  Map<IntRange, ChangeGroup> changeGroups = SplayTreeMap(reverse);
  Map<int, Commit> commits = SplayTreeMap(reverse);
  Map<String, Map<IntRange, List<Change>>> changesByName = {};
  Map<String, Map<IntRange, List<Change>>> liveChangesByName = {};
  Map<IntRange, List<Change>> changes = SplayTreeMap(reverse);
  Map<IntRange, List<Change>> liveChanges = SplayTreeMap(reverse);
  Set<String> modifiedNames = Set();
  Set<IntRange> modifiedRanges = Set();

  int firstIndex;
  int lastIndex;
  bool fetching = false;
  num infiniteScrollVisibleRatio = 0;
  bool showFilter = false;

  ApplicationRef _applicationRef;
  FirestoreService _firestoreService;
  FilterService filterService;

  AppComponent(
      this._firestoreService, this.filterService, this._applicationRef);

  @ViewChild("infiniteScroll")
  Element infiniteScroll;

  @override
  void ngOnInit() async {
    await _firestoreService.getFirebaseClient();
    await fetchData();
    IntersectionObserver(infiniteScrollCallback).observe(infiniteScroll);
  }

  /// We do not want to create a new AppComponent object each time the
  /// route changes, which includes changes to the fragment.
  /// It is always acceptable to use the same AppComponent.
  @override
  Future<bool> canReuse(_, __) async => true;

  void infiniteScrollCallback(
      List entries, IntersectionObserver observer) async {
    infiniteScrollVisibleRatio = entries[0].intersectionRatio;
    // The event stream will write to infiniteScrollVisible, stopping the loop.
    while (infiniteScrollVisibleRatio > 0) {
      await fetchData();
      await Future.delayed(Duration(seconds: 2));
    }
  }

  List<Change> getInMap(Map map, String name, IntRange range) => map
      .putIfAbsent(name, () => SplayTreeMap<IntRange, List<Change>>(reverse))
      .putIfAbsent(range, () => <Change>[]);

  Future fetchData() async {
    if (fetching) return;
    fetching = true;
    try {
      final before = commits.isEmpty ? null : commits.keys.last;
      final range = await fetchEarlierCommits(before);
      await fetchResults(range);
      updateLiveChanges();
      updateRanges();
    } finally {
      fetching = false;
      // Force a reevaluation of changed views
      filterService.filter = filterService.filter.copy();
      _applicationRef.tick();
    }
  }

  Future<IntRange> fetchEarlierCommits(int before) async {
    final newCommits = (await _firestoreService.fetchCommits(before, 30))
        .map((x) => Commit.fromDocument(x));
    if (newCommits.isEmpty) {
      throw Exception("Failed to fetch more commits");
    }
    for (Commit commit in newCommits) {
      commits[commit.index] = commit;
      final range = IntRange(commit.index, commit.index);
      changeGroups.putIfAbsent(
          range, () => ChangeGroup(range, commits, [], []));
    }
    final range = IntRange(
        commits.keys.last, before == null ? commits.keys.first : before - 1);
    // Add new commits to previously loaded blamelists that included them.
    for (ChangeGroup changeGroup in changeGroups.values) {
      if (changeGroup.range.contains(range.end) &&
          changeGroup.range.length > changeGroup.commits.length) {
        changeGroup.commits = commits.values
            .where((commit) => changeGroup.range.contains(commit.index))
            .toList();
      }
    }
    return range;
  }

  Future fetchResults(IntRange commitRange) async {
    final resultsData = await _firestoreService.fetchChanges(
        commitRange.start, commitRange.end);
    for (var resultData in resultsData) {
      final change = Change.fromDocument(resultData);
      final range = IntRange(change.pinnedIndex ?? change.blamelistStartIndex,
          change.pinnedIndex ?? change.blamelistEndIndex);

      changes.putIfAbsent(range, () => <Change>[]).add(change);
      getInMap(changesByName, change.name, range).add(change);
      modifiedRanges.add(range);
      modifiedNames.add(change.name);
    }
  }

  /// Updates Change objects representing only the changed test results that
  /// have not been replaced by a later changed result on the same test and
  /// configuration.
  /// For each test name with incoming new results, scan backwards in time,
  /// keeping a set of the configurations that we have seen a test change on.
  /// Only the changes to configurations not in the 'seen' set are still 'live',
  /// and still impact the current state of the test on that configuration.
  /// Update the existing Change object for the live changes for this
  /// test, configuration, and results. Remove it if there are no live results.
  /// If the existing Change object is still correct, leave it unchanged, so
  /// Angular change detection does not need to recompute the view.
  void updateLiveChanges() {
    for (final name in modifiedNames) {
      final byRange = changesByName[name];
      final seenConfigurations = Set<String>();
      for (final range in byRange.keys) {
        // The current live Change objects for that test and range,
        // which need to be updated.
        final existingLive = getInMap(liveChangesByName, name, range);
        for (final change in byRange[range]) {
          final liveConfigurations = change.configurations.configurations
              .where((c) => !seenConfigurations.contains(c))
              .toList();
          final previous = getInMap(liveChangesByName, name, range).firstWhere(
              (c) => c.changesText == change.changesText,
              orElse: () => null);
          if (liveConfigurations.isEmpty) {
            if (previous != null) {
              existingLive.remove(previous);
              modifiedRanges.add(range);
            }
          } else if (Configurations(liveConfigurations) !=
              previous?.configurations) {
            // Configurations are canonicalized.
            if (previous != null) {
              existingLive.remove(previous);
            }
            existingLive
                .add(change.copy(newConfigurations: liveConfigurations));
            modifiedRanges.add(range);
          }
          seenConfigurations.addAll(liveConfigurations);
        }
      }
    }
    modifiedNames.clear();
  }

  void updateRanges() {
    for (final range in modifiedRanges) {
      liveChanges[range] = [
        for (final byRange in liveChangesByName.values) ...?byRange[range]
      ];
      if (changes[range].isEmpty && liveChanges[range].isEmpty) {
        changeGroups.remove(range);
      } else {
        changeGroups[range] =
            ChangeGroup(range, commits, changes[range], liveChanges[range]);
      }
    }
    modifiedRanges.clear();
  }

  bool get loginEnabled =>
      Uri.parse(window.location.href).fragment.contains('&login');

  String get loginIcon =>
      _firestoreService.isLoggedIn ? 'highlight_off' : 'account_circle';

  void toggleLogin() {
    if (_firestoreService.isLoggedIn) {
      _firestoreService.logOut();
    } else {
      _firestoreService.logIn();
    }
  }
}

// We often want changeGroups and commits ordered from latest to earliest.
int reverse(key1, key2) => key2.compareTo(key1);
