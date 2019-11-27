// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:pageloader/html.dart';

import 'commit_po.dart';

part 'app_po.g.dart';

@PageObject()
abstract class AppPO {
  AppPO();
  factory AppPO.create(PageLoaderElement context) = $AppPO.create;

  @ByTagName('dart-commit')
  List<PageLoaderElement> get _commits;

  Iterable<CommitPO> get commits => _commits.map((el) => CommitPO.create(el));
}
