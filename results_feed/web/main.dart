// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';
import 'package:dart_results_feed/src/services/firestore_service.dart';
import 'package:dart_results_feed/src/components/routing_wrapper_component.template.dart'
    as ng;
import 'main.template.dart' as self;

// Local testing use @GenerateInjector(routerProvidersHash)
// Use for deploying on staging website:
// @GenerateInjector([ClassProvider(FirestoreService, useClass: StagingFirestoreService), ...routerProviders])

@GenerateInjector([ClassProvider(FirestoreService), ...routerProviders])
final InjectorFactory injector = self.injector$Injector;

void main() {
  runApp(ng.RoutingWrapperComponentNgFactory, createInjector: injector);
}
