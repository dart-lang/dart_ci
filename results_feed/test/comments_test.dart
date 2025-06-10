// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@TestOn('browser')
@Tags(['requires_auth'])
import 'package:angular/di.dart';
import 'package:angular_test/angular_test.dart';
import 'package:dart_results_feed/src/components/app_component.dart';
import 'package:dart_results_feed/src/components/app_component.template.dart'
    as ng;
import 'package:dart_results_feed/src/model/comment.dart';
import 'package:dart_results_feed/src/services/firestore_service.dart';
import 'package:pageloader/html.dart';
import 'package:test/test.dart';

import 'comments_sample_data.dart';
import 'comments_test.template.dart' as self;
import 'page_objects/app_po.dart';
import 'page_objects/blamelist_po.dart';
import 'page_objects/commit_po.dart';

// pub run build_runner test --fail-on-severe -- -p chrome comments_test.dart

const int neededCommits = 3;

@GenerateInjector([
  ClassProvider(FirestoreService, useClass: TestingFirestoreService),
])
final InjectorFactory rootInjector = self.rootInjector$Injector;

void main() {
  final testSetup = FirestoreTestSetup();
  final testBed = NgTestBed.forComponent<AppComponent>(ng.AppComponentNgFactory,
      rootInjector: rootInjector);
  NgTestFixture<AppComponent> fixture;
  Map<String, Map<String, dynamic>> commentsSampleData;

  setUpAll(() async {
    // Because the FirestoreService can only be initialized once, set up the
    // testBed (and component, and root injectors, and injected FirestoreService
    // instance, in a setupAll function that is created once.
    await testSetup.initialize();
    final lastIndex = await testSetup.lastIndex();
    commentsSampleData = createCommentsSampleData(lastIndex);
    await testSetup.writeDocumentsFrom(commentsSampleData);
    fixture = await testBed.create();
    await fixture.assertOnlyInstance.fetching;
  });

  tearDownAll(() async {
    await disposeAnyRunningTest();
    await testSetup.writeDocumentsFrom(commentsSampleData, delete: true);
  });

  void testEqual(Comment comment, Map<String, dynamic> original, String id) {
    expect(comment.id, id);
    expect(comment.author, original['author']);
    expect(comment.created.isAtSameMomentAs(original['created']), true);
    expect(comment.comment, original['comment']);
    expect(comment.link, original['link']);
    final results = comment.results;
    if (results.isEmpty) {
      expect(original.containsKey('results'), isFalse);
    } else {
      for (var i = 0; i < results.length; ++i) {
        expect(results[i], original['results'][i]);
      }
    }
    final tryResults = comment.tryResults;
    if (tryResults.isEmpty) {
      expect(original.containsKey('try_results'), isFalse);
    } else {
      for (var i = 0; i < tryResults.length; ++i) {
        expect(tryResults[i], original['try_results'][i]);
      }
    }
    expect(comment.approved, original['approved']);
    expect(comment.link, original['link']);
    expect(comment.blamelistStartIndex, original['blamelist_start_index']);
    expect(comment.blamelistEndIndex, original['blamelist_end_index']);
    expect(comment.pinnedIndex, original['pinned_index']);
    expect(comment.review, original['review']);
    expect(comment.patchset, original['patchset']);
  }

  test('load comments', () async {
    final firestore =
        AppComponentTest(fixture.assertOnlyInstance).firestoreService;
    final commentDocument = await firestore.fetchComment(commentId1);
    final comment = Comment.fromDocument(commentDocument);
    final original = commentsSampleData['comments/$commentId1'];
    testEqual(comment, original, commentId1);
  });

  test('check comment ui', () async {
    // TODO(whesse): The app fetches when initialized, with the old filter.
    // Because our new result is an active failure, it is fetched.
    // The fetch here fetches some earlier commits, does not really help.
    await fixture.update((app) => app.filterService.filter = app
        .filterService.filter
        .copy(showLatestFailures: false, showUnapprovedOnly: false));
    await fixture.update((app) => app.fetchData());
    await fixture.assertOnlyInstance.fetching;
    final context =
        HtmlPageLoaderElement.createFromElement(fixture.rootElement);
    var app = AppPO.create(context);
    // Take our sample commit with a non-trival buildlist, press button on it.
    bool isSampleCommit(CommitPO commit) =>
        commit.isNotEmpty &&
        commit.blamelist.commentBodies.isNotEmpty &&
        commit.blamelist.numCommits == neededCommits;

    final unpinned = app.commits.firstWhere(isSampleCommit);
    await fixture.update((AppComponent app) => unpinned.pressPickerButton());

    // Create a new AppPO because AppPO fields are final and cached, and the
    // DOM has changed.
    app = AppPO.create(context);
    final commit = app.commits.firstWhere(isSampleCommit);

    final data = commentsSampleData;
    var expected = {
      'comments': [
        data['comments/$commentId1']['comment'],
        data['comments/$commentId2']['comment'],
        data['comments/$commentId3']['comment'],
      ],
      'author': data['comments/$commentId1']['author'],
      'is_blamelist_picker': true,
    };
    checkComments(commit.blamelist, expected);
  });
}

void checkComments(BlamelistPO blamelist, Map<String, dynamic> data) {
  expect(blamelist.commentBodies, equals(data['comments']));
  expect(blamelist.comments.first, matches(data['author']));
  expect(blamelist.hasRadioButtons, data['is_blamelist_picker'] ?? false);
}
