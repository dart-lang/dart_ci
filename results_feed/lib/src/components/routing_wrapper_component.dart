// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

import '../route_paths.dart';
import 'app_component.template.dart';
import 'try_results_component.template.dart';

@Component(
    selector: 'routing-wrapper', directives: [routerDirectives], template: '''
      <router-outlet [routes]="routes"></router-outlet>
    ''')
class RoutingWrapperComponent {
  final List<RouteDefinition> routes = [
    RouteDefinition(routePath: feedPath, component: AppComponentNgFactory),
    RouteDefinition(routePath: clPath, component: TryResultsComponentNgFactory),
    RouteDefinition(
        routePath: rootPath,
        component: AppComponentNgFactory,
        useAsDefault: true),
  ];
}
