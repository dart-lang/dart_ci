// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

import 'firestore_service.dart';
import 'route_paths.dart';

@Component(
    selector: 'try-results',
    directives: [coreDirectives, routerDirectives],
    template: '''
    <h1>Placeholder for try results page</h1>
    change(CL) number: {{change}}<br>
    patchset number: {{patch}}<br>
    Link to results feed page:
    <a [routerLink]="feedLink">Results feed</a>
   ''')
class TryResultsComponent implements OnActivate {
  FirestoreService firestoreService;

  TryResultsComponent(this.firestoreService);

  get feedLink => feedPath.toUrl();

  int patch;
  int change;

  @override
  void onActivate(_, RouterState current) {
    final changeParam = current.parameters['cl'];
    change = changeParam == null ? null : int.parse(changeParam);
    final patchParam = current.parameters['patch'];
    patch = patchParam == null ? null : int.parse(patchParam);
  }
}
