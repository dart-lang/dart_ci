// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@TestOn('browser')
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

// pub run build_runner test --fail-on-severe -- -p chrome comments_test.dart

@GenerateInjector([
  ClassProvider(FirestoreService, useClass: TestingFirestoreService),
])
final InjectorFactory rootInjector = self.rootInjector$Injector;

void main() {
  final testBed = NgTestBed.forComponent<AppComponent>(ng.AppComponentNgFactory,
      rootInjector: rootInjector);
  NgTestFixture<AppComponent> fixture;

  setUpAll(() async {
    // Because the FirestoreService can only be initialized once, set up the
    // testBed (and component, and root injectors, and injected FirestoreService
    // instance, in a setupAll function that is created once.
    fixture = await testBed.create();
    final firestore =
        AppComponentTest(fixture.assertOnlyInstance).firestoreService;
    await firestore.logIn();
    await firestore.writeDocumentsFrom(commentsSampleData);
  });

  tearDownAll(() async {
    await disposeAnyRunningTest();
    final firestore =
        AppComponentTest(fixture.assertOnlyInstance).firestoreService;
    await firestore.writeDocumentsFrom(commentsSampleData, delete: true);
  });

  void testEqual(Comment comment, Map<String, dynamic> original, String id) {
    expect(comment.id, id);
    expect(comment.author, original['author']);
    expect(comment.created.isAtSameMomentAs(original['created']), true);
    expect(comment.comment, original['comment']);
    expect(comment.link, original['link']);
    expect(comment.baseComment, original['base_comment']);
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
    expect(comment.baseComment, original['base_comment']);
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

  test('load comment threads', () async {
    final firestore =
        AppComponentTest(fixture.assertOnlyInstance).firestoreService;
    final documents = await firestore.fetchCommentThread(commentThreadId);
    expect(documents, hasLength(2));
    final baseComment = Comment.fromDocument(documents[0]);
    final baseOriginal = commentsSampleData['comments/$commentThreadId'];
    testEqual(baseComment, baseOriginal, commentThreadId);
    final threadComment = Comment.fromDocument(documents[1]);
    final threadOriginal = commentsSampleData['comments/$commentId2'];
    testEqual(threadComment, threadOriginal, commentId2);
  });

  test('check comment ui', () async {
    Future fetcher;
    final context =
        HtmlPageLoaderElement.createFromElement(fixture.rootElement);
    void fetchMoreCommits(AppComponent app) {
      fetcher = app.fetchData();
    }

    while (fixture.assertOnlyInstance.commits.length < 100) {
      await fixture.update(fetchMoreCommits);
      await fetcher;
    }

    var app = AppPO.create(context);

    // Take commit with a non-trival buildlist, press button on it.
    final unpinned = app.commits
        .where((commit) =>
            commit.isNotEmpty &&
            commit.blamelist.commentBodies.isNotEmpty &&
            commit.blamelist.firstCommit != commit.blamelist.lastCommit)
        .single;
    await fixture.update((AppComponent app) => unpinned.pressPickerButton());

    // Create a new AppPO because AppPO fields are final and cached, and the
    // DOM has changed.
    app = AppPO.create(context);
    final commits = app.commits
        .where((commit) =>
            commit.isNotEmpty && commit.blamelist.commentBodies.isNotEmpty)
        .toList();

    final data = commentsSampleData;
    var expected = {
      'comments': [
        data['comments/$commentThreadId']['comment'],
        data['comments/$commentId2']['comment']
      ],
      'author': data['comments/$commentThreadId']['author'],
      'date': '21:19 Thu Nov 21',
      'first_commit': '80fc4d',
      'last_commit': '80fc4d'
    };

    checkComments(commits[0].blamelist, expected);
    expected = {
      'comments': [
        data['comments/$commentId3']['comment'],
      ],
      'author': data['comments/$commentId3']['author'],
      'date': '0:19 Fri Nov 1',
      'first_commit': '8a09d7',
      'last_commit': '924ec3',
      'is_blamelist_picker': true
    };
    checkComments(commits[1].blamelist, expected);
  });
}

void checkComments(BlamelistPO blamelist, Map<String, dynamic> data) {
  expect(blamelist.commentBodies, equals(data['comments']));
  expect(blamelist.comments.first, matches(data['author']));
  expect(blamelist.comments.first, matches(data['date']));
  expect(blamelist.firstCommit, data['first_commit']);
  expect(blamelist.lastCommit, data['last_commit']);
  expect(blamelist.hasRadioButtons, data['is_blamelist_picker'] ?? false);
}
