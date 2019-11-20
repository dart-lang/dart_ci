// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@TestOn('browser')

import 'package:dart_results_feed/src/components/app_component.dart';
import 'package:dart_results_feed/src/components/app_component.template.dart'
    as ng;
import 'package:angular_test/angular_test.dart';
import 'package:test/test.dart';

// Because FirestoreService can only be initialized once, and each
// AppComponent instance creates a FirestoreService, only one test can
// be run at a time.  Use the -n "test name" option to
// pub run build_runner test:
// pub run build_runner test --fail-on-severe -- -p chrome -n "Check html"
// pub run build_runner test --fail-on-severe -- -p chrome -n "Loads commits"

void main() {
  final testBed =
      NgTestBed.forComponent<AppComponent>(ng.AppComponentNgFactory);
  NgTestFixture<AppComponent> fixture;

  setUp(() async {
    fixture = await testBed.create();
  });

  tearDown(disposeAnyRunningTest);

  test('Loads commits', () async {
    await fixture.update();
    await Future.delayed(Duration(seconds: 20));
    expect(fixture.assertOnlyInstance.commits.isNotEmpty, true);
  });

  test('Check html', () async {
    await fixture.update();
    expect(
        fixture.rootElement.innerHtml.contains("Results Feed (Angular Dart)"),
        true);
  });
}
