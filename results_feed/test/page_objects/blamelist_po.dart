// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:pageloader/html.dart';

part 'blamelist_po.g.dart';

@PageObject()
abstract class BlamelistPO {
  BlamelistPO();
  factory BlamelistPO.create(PageLoaderElement context) = $BlamelistPO.create;

  @ByClass('comment-body')
  List<PageLoaderElement> get _commentBodies;

  Iterable<String> get commentBodies =>
      _commentBodies.map(((el) => el.visibleText));

  @ByClass('comment')
  List<PageLoaderElement> get _comments;

  Iterable<String> get comments => _comments.map((el) => el.innerText);

  @ByClass('commit')
  List<PageLoaderElement> get _commits;

  @First(ByClass('commit'))
  PageLoaderElement get _firstCommit;

  String get firstCommit => _firstCommit.getElementsByCss('a').first.innerText;

  String get lastCommit => _commits.last.getElementsByCss('a').first.innerText;
  @ByTagName('material-radio')
  List<PageLoaderElement> get _buttons;

  bool get hasRadioButtons => _buttons.isNotEmpty;
}
