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
import 'package:dart_results_feed/src/services/filter_component.dart';

import 'commit_component.dart';
import '../formatting.dart';
import '../model/commit.dart';
import '../model/comment.dart';
import '../services/filter_service.dart';
import '../services/firestore_service.dart';
import '../services/build_service.dart';

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
  String title = 'Dart Results Feed';

  Map<IntRange, ChangeGroup> changeGroups = SplayTreeMap(reverse);
  Map<int, Commit> commits = SplayTreeMap(reverse);
  Map<IntRange, List<Comment>> comments = SplayTreeMap(reverse);
  Map<IntRange, List<Change>> changes = SplayTreeMap(reverse);
  Set<IntRange> modifiedRanges = {};

  int firstIndex;
  int lastIndex;
  Future fetching;
  num infiniteScrollVisibleRatio = 0;
  bool showFilter = false;

  final ApplicationRef _applicationRef;
  final FirestoreService _firestoreService;
  final FilterService filterService;

  AppComponent(
      this._firestoreService, this.filterService, this._applicationRef);

  @ViewChild('infiniteScroll')
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

  bool infiniteScrollEnabled = true;

  void infiniteScrollCallback(
      List entries, IntersectionObserver observer) async {
    infiniteScrollVisibleRatio = entries[0].intersectionRatio;
    // The event stream will write to infiniteScrollVisible, stopping the loop.
    while (infiniteScrollVisibleRatio > 0) {
      await fetchData();
      await Future.delayed(Duration(seconds: 2));
    }
  }

  DateTime fetchDate;
  String get formattedFetchDate => formatFetchDate(fetchDate);

  void updateFetchDate() {
    if (commits.isNotEmpty) {
      fetchDate = commits.values.last.created;
      final initialRange = filterService.filter.singleTest == null
          ? Duration(days: 21)
          : Duration(days: 60);
      infiniteScrollEnabled =
          fetchDate.isAfter(DateTime.now().subtract(initialRange));
    }
  }

  Future fetchData() => fetching ??= () async {
        try {
          final loadedResultsStatus = LoadedResultsStatus()
            ..failuresOnly = filterService.filter.showLatestFailures
            ..unapprovedOnly = filterService.filter.showUnapprovedOnly
            ..singleTest = filterService.filter.singleTest;
          final before = commits.isEmpty ? null : commits.keys.last;
          final range = await fetchEarlierCommits(before);
          await fetchResults(range, loadedResultsStatus);
          await fetchComments(range);
          updateRanges(loadedResultsStatus);
          updateFetchDate();
        } finally {
          // Force a reevaluation of changed views
          filterService.filter = filterService.filter.copy();
          fetching = null;
          _applicationRef.tick();
        }
      }();

  Future<IntRange> fetchEarlierCommits(int before) async {
    final fetchAmount = filterService.filter.singleTest == null ? 100 : 500;
    final newCommits =
        (await _firestoreService.fetchCommits(before, fetchAmount))
            .map((x) => Commit.fromDocument(x));
    if (newCommits.isEmpty) {
      throw Exception('Failed to fetch more commits');
    }
    for (final commit in newCommits) {
      commits[commit.index] = commit;
      final range = IntRange(commit.index, commit.index);
      changeGroups.putIfAbsent(range,
          () => ChangeGroup(range, commits, [], [], LoadedResultsStatus()));
    }
    final range = IntRange(
        commits.keys.last, before == null ? commits.keys.first : before - 1);
    // Add new commits to previously loaded blamelists that included them.
    for (final changeGroup in changeGroups.values) {
      if (changeGroup.range.contains(range.end) &&
          changeGroup.range.length > changeGroup.commits.length) {
        changeGroup.commits = commits.values
            .where((commit) => changeGroup.range.contains(commit.index))
            .toList();
      }
    }
    return range;
  }

  Future fetchResults(
      IntRange commitRange, LoadedResultsStatus loadedResultsStatus) async {
    final resultsData = await _firestoreService.fetchChanges(
        commitRange.start,
        commitRange.end,
        loadedResultsStatus.failuresOnly,
        loadedResultsStatus.unapprovedOnly,
        loadedResultsStatus.singleTest);
    for (var resultData in resultsData) {
      final change = Change.fromDocument(resultData);
      final range = IntRange(change.pinnedIndex ?? change.blamelistStartIndex,
          change.pinnedIndex ?? change.blamelistEndIndex);

      changes.putIfAbsent(range, () => <Change>[]).add(change);
      modifiedRanges.add(range);
    }
  }

  Future fetchComments(IntRange commitRange) async {
    final commentsData = await _firestoreService.fetchCommentsForRange(
        commitRange.start, commitRange.end);
    final newComments = [
      for (final doc in commentsData) Comment.fromDocument(doc)
    ];
    for (final comment in newComments) {
      IntRange range;
      if (comment.pinnedIndex != null) {
        range = IntRange(comment.pinnedIndex, comment.pinnedIndex);
      } else if (comment.blamelistStartIndex != null) {
        range =
            IntRange(comment.blamelistStartIndex, comment.blamelistEndIndex);
      }
      if (range != null) {
        comments.putIfAbsent(range, () => []).add(comment);
        modifiedRanges.add(range);
      }
    }
  }

  void updateRanges(LoadedResultsStatus loadedResultsStatus) {
    for (final range in modifiedRanges) {
      if (changes[range] == null || changes[range].isEmpty) {
        changeGroups.remove(range);
      } else {
        changeGroups[range] = ChangeGroup(range, commits, comments[range] ?? [],
            changes[range], loadedResultsStatus);
      }
    }
    modifiedRanges.clear();
  }

  String get loginMessage => _firestoreService.isLoggedIn ? 'logout' : 'login';

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

/// Exposes private members of AppComponent for testing purposes.
/// Only usable on the staging Firestore instance.
class AppComponentTest {
  AppComponent appComponent;

  AppComponentTest(this.appComponent);

  TestingFirestoreService get firestoreService =>
      appComponent._firestoreService;
  ApplicationRef get applicationRef => appComponent._applicationRef;
}
