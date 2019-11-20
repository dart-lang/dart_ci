// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@TestOn('browser')
import 'package:angular/di.dart';
import 'package:angular_test/angular_test.dart';
import 'package:dart_results_feed/src/app_component.dart';
import 'package:dart_results_feed/src/app_component.template.dart' as ng;
import 'package:dart_results_feed/src/comment.dart';
import 'package:dart_results_feed/src/firestore_service.dart';
import 'package:test/test.dart';

import 'comments_sample_data.dart';
import 'comments_test.template.dart' as self;

// pub run build_runner test --fail-on-severe -- -p chrome comments_test.dart

@GenerateInjector([
  ClassProvider(FirestoreService, useClass: StagingFirestoreService),
])
final InjectorFactory rootInjector = self.rootInjector$Injector;

void main() {
  print("entering main");
  final testBed = NgTestBed.forComponent<AppComponent>(ng.AppComponentNgFactory,
      rootInjector: rootInjector);
  NgTestFixture<AppComponent> fixture;

  setUpAll(() async {
    // Because the FirestoreService can only be initialized once, set up the
    // testBed (and component, and root injectors, and injected FirestoreService
    // instance, in a setupAll function that is created once.
    print('setting up');
    fixture = await testBed.create();
    final firestore =
        AppComponentTest(fixture.assertOnlyInstance).firestoreService;
    await firestore.logIn();
    await firestore.writeDocumentsFrom(commentsSampleData);
    await firestore.mergeDocumentsFrom(commentsSampleDataMerges);
  });

  tearDownAll(() async {
    await disposeAnyRunningTest();
    final firestore =
        AppComponentTest(fixture.assertOnlyInstance).firestoreService;
    await firestore.writeDocumentsFrom(commentsSampleData, delete: true);
    await firestore.mergeDocumentsFrom(commentsSampleDataMerges, delete: true);
  });

  testEqual(Comment comment, Map<String, dynamic> original, String id) {
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
    expect(comment.gerritChange, original['gerrit_change']);
    expect(comment.patchset, original['patchset']);
  }

  test('load comments', () async {
    final firestore =
        AppComponentTest(fixture.assertOnlyInstance).firestoreService;
    final commentDocument = await firestore.fetchComment(commentId1);
    final comment = Comment.fromDocument(commentDocument);
    final original = commentsSampleData['comments/$commentId1'];
    print('running test');
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
    // verify that UI for a commit shows the approvals and comments for that
    // commit.
  });
}
