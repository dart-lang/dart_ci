// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:pageloader/html.dart';

import 'results_panel_po.dart';

part 'try_results_po.g.dart';

@PageObject()
abstract class TryResultsPO {
  TryResultsPO();
  factory TryResultsPO.create(PageLoaderElement context) = $TryResultsPO.create;

  @First(ByTagName('results-panel'))
  PageLoaderElement get _resultsPanel;

  @First(ByTagName('results-selector-panel'))
  PageLoaderElement get _resultsSelectorPanel;

  ResultsPanelPO get resultsPanel => _resultsPanel.exists
      ? ResultsPanelPO.create(_resultsPanel)
      : ResultsSelectorPanelPO.create(_resultsSelectorPanel);

  @ByTagName('material-button')
  List<PageLoaderElement> get _buttons;

  @First(ByCss('material-input textarea'))
  PageLoaderElement get _commentField;

  PageLoaderElement get commentField => _commentField;

  @ByCss('try-results  div  div.comment')
  List<PageLoaderElement> get _comments;

  List<PageLoaderElement> get comments => _comments;

  PageLoaderElement _buttonCalled(String text) =>
      _buttons.firstWhere((final button) => button.innerText == text,
          orElse: () => null);

  PageLoaderElement get approveCommentButton =>
      _buttonCalled('Approve/Comment ...');
  PageLoaderElement get cancelButton => _buttonCalled('Cancel');
  PageLoaderElement get revokeButton =>
      _buttonCalled('Revoke Selected Approvals');
  PageLoaderElement get commentOnlyButton =>
      _buttonCalled('Comment without Approving');
  PageLoaderElement get approveButton => _buttonCalled('Approve');

  void clickApproveComment() {
    approveCommentButton.click();
    for (final button in _buttons) {
      print(button.innerText);
    }
  }
}
