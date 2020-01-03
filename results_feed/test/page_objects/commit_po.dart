// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:pageloader/html.dart';

import 'blamelist_po.dart';

part 'commit_po.g.dart';

@PageObject()
abstract class CommitPO {
  CommitPO();
  factory CommitPO.create(PageLoaderElement context) = $CommitPO.create;

  @First(ByCss('div.commit'))
  PageLoaderElement get _commit;

  bool get isNotEmpty => _commit.exists;
  bool get isEmpty => !isNotEmpty;

  @First(ByTagName('blamelist-panel'))
  PageLoaderElement get _blamelistPanel;

  @First(ByTagName('blamelist-picker'))
  PageLoaderElement get _blamelistPicker;

  BlamelistPO get blamelist => BlamelistPO.create(
      _blamelistPanel.exists ? _blamelistPanel : _blamelistPicker);

  @First(ByTagName('material-button'))
  PageLoaderElement get _pickerButton;

  void pressPickerButton() {
    _pickerButton.click();
  }
}
