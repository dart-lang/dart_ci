// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:angular/angular.dart';
import 'package:angular_components/simple_html/simple_html.dart'
    show simpleHtmlUriWhitelist;
import 'package:angular_router/angular_router.dart';
import 'package:dart_results_feed/src/services/firestore_service.dart';
import 'package:dart_results_feed/src/components/routing_wrapper_component.template.dart'
    as ng;
import 'package:dart_results_feed/src/formatting.dart' as formatting;
import 'main.template.dart' as self;

// Allow links from comments to GitHub issues in allowed organizations.
List<Uri> getUriWhitelist() => List.unmodifiable(<Uri>[
      for (final organization in formatting.organizations)
        Uri.https('github.com', '$organization/')
    ]);

// Use for local testing
const localTestingProviders = [
  ClassProvider(FirestoreService, useClass: TestingFirestoreService),
  FactoryProvider.forToken(simpleHtmlUriWhitelist, getUriWhitelist),
  routerProvidersHash,
];

// Use for deploying on staging website
const stagingProviders = [
  ClassProvider(FirestoreService, useClass: StagingFirestoreService),
  FactoryProvider.forToken(simpleHtmlUriWhitelist, getUriWhitelist),
  routerProviders,
];

const productionProviders = [
  ClassProvider(FirestoreService),
  FactoryProvider.forToken(simpleHtmlUriWhitelist, getUriWhitelist),
  routerProviders,
];

@GenerateInjector(productionProviders)
final InjectorFactory injector = self.injector$Injector;

void main() {
  runApp(ng.RoutingWrapperComponentNgFactory, createInjector: injector);
}
