// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:collection';

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
  Map<IntRange, Commit> blamelists = SplayTreeMap();
  Map<int, Commit> commits = SplayTreeMap();
  int firstIndex;
  int lastIndex;

  List<Commit> get allResults =>
      List.from(commits.values.followedBy(blamelists.values))..sort();

  FirestoreService _firestoreService;

  AppComponent(this._firestoreService);

  @override
  void ngOnInit() async {
    await _firestoreService.getFirebaseClient();
    await fetchCommits();
  }

  Future fetchCommits() async {
    final newCommits = (await _firestoreService.fetchCommits(firstIndex, 50))
        .map((x) => Commit.fromDocument(x));
    for (Commit commit in newCommits) commits[commit.index] = commit;
    final previousFirstIndex = firstIndex;
    firstIndex = commits.keys.first;
    lastIndex = commits.keys.last;
    final resultsData = await _firestoreService.fetchChanges(
        firstIndex, previousFirstIndex ?? lastIndex);
    final results = <IntRange, List<Change>>{};
    for (var resultData in resultsData) {
      final result = Change.fromDocument(resultData);
      final range =
          IntRange(result.blamelistStartIndex, result.blamelistEndIndex);
      results.putIfAbsent(range, () => <Change>[]).add(result);
    }
    for (IntRange range in results.keys) {
      if (range.length == 1) {
        commits[range.end].addChanges(results[range]);
      } else {
        blamelists
            .putIfAbsent(range, () => Commit.fromRange(range, commits.values))
            .addChanges(results[range]);
      }
    }
  }
}
