// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:html' show window;

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_components/material_button/material_button.dart';
import 'package:angular_components/material_input/material_input.dart';
import 'package:angular_components/material_input/material_input_multiline.dart';
import 'package:angular_components/simple_html/simple_html.dart';
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
      ResultsSelectorPanel,
      SimpleHtmlComponent,
    ],
    providers: [
      ClassProvider(TryDataService),
      overlayBindings,
    ],
    templateUrl: 'try_results_component.html',
    exports: [formattedDate, formattedEmail],
    styles: ['div {padding: 8px;}'])
class TryResultsComponent implements OnActivate {
  final TryDataService _tryDataService;
  final ApplicationRef _applicationRef;

  int review;
  int patchset;
  ReviewInfo reviewInfo;
  ChangeGroup changeGroup = waitingForDataChangeGroup;
  int cachedReview;
  int cachedPatchset;
  List<Change> changes;
  List<Comment> comments;
  Map<int, Map<String, TryBuild>> builds;
  Map<String, String> builders;
  final IntRange emptyRange = IntRange(1, 0);
  bool updating = false;
  bool updatePending = false;
  bool _approving = false;
  final Set<Change> selected = {};
  String commentText;

  TryResultsComponent(this._tryDataService, this._applicationRef);

  bool get waitingForData => !changeGroup.loadedResultsStatus.loaded;

  bool get noChanges => !waitingForData && changeGroup.changes.isEmpty;

  bool get approveEnabled =>
      changeGroup.changes.flat.any((change) => change.failed);

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
    if (approval != null) {
      for (final result in selected) {
        result.approved = approval;
      }
    }
    final comment = await _tryDataService.saveApproval(
        approval,
        commentText,
        changeGroup.comments.isEmpty
            ? null
            : changeGroup.comments.last.baseComment ??
                changeGroup.comments.last.id,
        [for (Change result in selected) result.id],
        reviewInfo.review);
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
    if (review == null) return;
    if (reviewInfo == null || review != reviewInfo.review) {
      reviewInfo = await _tryDataService.fetchReviewInfo(review);
    }
    if (review != cachedReview || patchset != cachedPatchset) {
      changeGroup = waitingForDataChangeGroup;
      comments = [];
      changes = await _tryDataService.changes(reviewInfo, patchset);
      comments = await _tryDataService.comments(reviewInfo.review);
      builds = {
        for (final patchset in reviewInfo.patchsets) patchset.number: {}
      };
      for (final build in reviewInfo.builds) {
        builds[build.patchset][build.builder] = build;
      }
      builders = await _tryDataService.builders();
      comments..sort();
      cachedReview = review;
      cachedPatchset = patchset;
      changeGroup =
          ChangeGroup(null, {}, comments, changes, LoadedResultsStatus());
    }
  }

  @override
  void onActivate(_, RouterState current) {
    final changeParam = current.parameters['cl'];
    review = changeParam == null ? null : int.parse(changeParam);
    final patchParam = current.parameters['patch'];
    patchset = patchParam == null ? null : int.parse(patchParam);
    tryUpdate();
  }

  void openNewGithubIssue() {
    window.open(newIssueURL(), '_blank');
  }

  String newIssueURL() => githubNewIssueURL(changeGroup.changes,
      reviewInfo.title, 'https://dart-review.googlesource.com/c/sdk/+/$review');
}

final waitingForDataChangeGroup =
    ChangeGroup(null, {}, [], [], LoadedResultsStatus()..loaded = false);
