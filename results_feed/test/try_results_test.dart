// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@TestOn('browser')
import 'package:angular/di.dart';
import 'package:angular_test/angular_test.dart';
import 'package:dart_results_feed/src/components/try_results_component.dart';
import 'package:dart_results_feed/src/components/try_results_component.template.dart'
    as ng;
import 'package:dart_results_feed/src/services/firestore_service.dart';
import 'package:pageloader/html.dart';
import 'package:pageloader/testing.dart';

import 'package:test/test.dart';

import 'try_results_test.template.dart' as self;
import 'try_results_sample_data.dart';
import 'page_objects/results_panel_po.dart';
import 'page_objects/try_results_po.dart';

// pub run build_runner test --fail-on-severe -- -p chrome comments_test.dart

@GenerateInjector([
  ClassProvider(FirestoreService, useClass: TestingFirestoreService),
])
final InjectorFactory rootInjector = self.rootInjector$Injector;

void main() {
  final testBed = NgTestBed.forComponent<TryResultsComponent>(
      ng.TryResultsComponentNgFactory,
      rootInjector: rootInjector);

  tearDown(() async {
    await disposeAnyRunningTest();
  });

  test('create component', () async {
    TestingFirestoreService firestore;
    final fixture =
        await testBed.create(beforeComponentCreated: (Injector injector) async {
      firestore =
          injector.provideType<TestingFirestoreService>(FirestoreService);
      await firestore.getFirebaseClient();
      await firestore.writeDocumentsFrom(tryResultsCreateComponentSampleData);
    });
    await fixture.update((TryResultsComponent tryResultsComponent) {
      tryResultsComponent.review = createComponentReview;
      tryResultsComponent.patchset = createComponentPatchset;
    });
    await fixture.assertOnlyInstance.update();
    await fixture.update();

    var context = HtmlPageLoaderElement.createFromElement(fixture.rootElement);
    var tryResultsPO = TryResultsPO.create(context);
    var results = tryResultsPO.resultsPanel;
    expect(results, isA<ResultsPanelPO>());
    expect(results, isNot(isA<ResultsSelectorPanelPO>()));

    expect(results.testNames(), [
      [
        ['pkg/front_end/test/fasta/analyze_test'],
        ['sample_suite/sample_test']
      ],
      [
        ['pkg/front_end/test/fasta/analyze_test', '✔ sample_suite/second_test']
      ]
    ]);
    expect(tryResultsPO.approveCommentButton, exists);
    expect(tryResultsPO.cancelButton, isNull);
    expect(tryResultsPO.revokeButton, isNull);
    expect(tryResultsPO.commentOnlyButton, isNull);
    expect(tryResultsPO.approveButton, isNull);

    await fixture.update((_) => tryResultsPO.approveCommentButton.click());
    // The waiting in fixture.update is not enough when we replace
    // the ResultsPanel with a ResultsSelectorPanel.
    await Future.delayed(Duration(seconds: 1), () => null);

    results = tryResultsPO.resultsPanel;
    expect(results, isA<ResultsSelectorPanelPO>());
    expect(results.testNames(), [
      [
        ['check_box pkg/front_end/test/fasta/analyze_test'],
        ['check_box sample_suite/sample_test']
      ],
      [
        [
          'check_box pkg/front_end/test/fasta/analyze_test',
          'check_box ✔ sample_suite/second_test'
        ]
      ]
    ]);
    expect(tryResultsPO.approveCommentButton, isNull);
    expect(tryResultsPO.cancelButton, exists);
    expect(tryResultsPO.revokeButton, exists);
    expect(tryResultsPO.commentOnlyButton, exists);
    expect(tryResultsPO.approveButton, exists);

    final analyzerGroup = results.configurationGroup('analyzer...');
    final analyzerGroupCheckbox = checkbox(analyzerGroup);
    final secondResultGroup = results.resultsGroup(
        analyzerGroup, 'Pass -> CompileTimeError (expected Pass)');
    final secondResultGroupCheckbox = checkbox(secondResultGroup);
    expect(analyzerGroupCheckbox, exists);
    expect(secondResultGroupCheckbox, exists);
    expect(checked(analyzerGroupCheckbox), 'true');
    expect(checked(secondResultGroupCheckbox), 'true');
    await fixture.update((_) => analyzerGroupCheckbox.click());
    expect(checked(analyzerGroupCheckbox), 'false');
    expect(checked(secondResultGroupCheckbox), 'false');
    await fixture.update((_) => secondResultGroupCheckbox.click());
    expect(checked(analyzerGroupCheckbox), 'mixed');
    expect(checked(secondResultGroupCheckbox), 'true');

    await fixture.update((_) => tryResultsPO.commentField.type(commentText));

    await fixture.update((_) => tryResultsPO.approveButton.click());
    await Future.delayed(Duration(seconds: 1), () => null);
    // The waiting in fixture.update is not enough when we replace
    // the ResultsSelectorPanel with a ResultsPanel.
    results = tryResultsPO.resultsPanel;
    expect(results, isA<ResultsPanelPO>());
    expect(results, isNot(isA<ResultsSelectorPanelPO>()));

    expect(results.testNames(), [
      [
        ['✔ pkg/front_end/test/fasta/analyze_test'],
        ['sample_suite/sample_test']
      ],
      [
        [
          '✔ pkg/front_end/test/fasta/analyze_test',
          '✔ sample_suite/second_test'
        ]
      ]
    ]);
    expect(tryResultsPO.comments.last.innerText,
        stringContainsInOrder(['approved', commentText]));

    await firestore.writeDocumentsFrom(tryResultsCreateComponentSampleData,
        delete: true);
    await firestore.deleteCommentsForReview(createComponentReview);
  });
}
