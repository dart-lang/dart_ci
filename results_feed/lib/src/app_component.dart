// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

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
  List<Commit> commits = [];
  int firstIndex;
  int lastIndex;

  FirestoreService _firestoreService;

  AppComponent(this._firestoreService);

  @override
  void ngOnInit() async {
    await _firestoreService.getFirebaseClient();
    await fetchCommits();
  }

  Future fetchCommits() async {
    commits.addAll((await _firestoreService.fetchCommits(firstIndex, 50))
        .map((x) => Commit.fromDocument(x)));
    final previousFirstIndex = firstIndex;
    firstIndex = commits.last.index;
    lastIndex = commits.first.index;
    var resultsData = await _firestoreService.fetchChanges(
        firstIndex, previousFirstIndex ?? lastIndex);
    var results = <int, List<Change>>{};
    for (var resultData in resultsData) {
      var result = Change.fromDocument(resultData);
      results
          .putIfAbsent(result.blamelistStartIndex, () => <Change>[])
          .add(result);
    }
    for (var commit in commits) {
      commit.addChanges(results[commit.index]);
    }
  }
}
