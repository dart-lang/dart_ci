// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:angular/angular.dart';
// import 'package:angular_components/angular_components.dart';

import '../services/build_service.dart';

@Component(
  selector: 'dart-log',
  providers: [],
  directives: [coreDirectives],
  template: '''
            {{configuration}}
            <a
            href="https://dart-ci.firebaseapp.com/#showLatestFailures=false&test={{test}}&configurations={{configuration}}"
            target="_blank">history</a>
            <a *ngIf="build != null"
            href="https://dart-ci.appspot.com/log/{{build.builder}}/{{configuration}}/{{build.buildNumber}}/{{test}}"
            target="_blank">log</a>
            <a href="{{source}}" target="_blank">source</a>
            <br>
  ''',
)
class LogComponent implements OnInit {
  LogComponent(this.buildService);

  @Input()
  BuildService buildService;

  @Input()
  String configuration;

  @Input()
  int index;

  @Input()
  String test;

  @Input()
  String source;

  Build build;

  @override
  void ngOnInit() async {
    build = await buildService.buildForResult(configuration, index);
  }
}
