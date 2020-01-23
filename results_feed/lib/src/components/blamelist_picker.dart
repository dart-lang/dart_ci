// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_components/material_radio/material_radio.dart';
import 'package:angular_components/material_radio/material_radio_group.dart';
import 'package:angular_components/simple_html/simple_html.dart';
import 'package:angular_forms/angular_forms.dart' show formDirectives;

import '../formatting.dart';
import '../model/comment.dart';
import '../model/commit.dart';

@Component(
    selector: 'blamelist-picker',
    directives: [
      coreDirectives,
      formDirectives,
      MaterialRadioComponent,
      MaterialRadioGroupComponent,
      SimpleHtmlComponent,
    ],
    templateUrl: 'blamelist_picker.html',
    styleUrls: ([
      'blamelist.css',
      'package:angular_components/css/mdc_web/card/mdc-card.scss.css'
    ]),
    exports: [formattedDate, formattedEmail])
class BlamelistPicker {
  @Input()
  List<Commit> commits;

  @Input()
  IntRange range;

  @Input()
  List<Comment> comments;

  @Output()
  Stream<Commit> get selected => _selectedCommit.stream;
  final _selectedCommit = StreamController<Commit>();
  void chosen(Commit commit) => _selectedCommit.add(commit);
}
