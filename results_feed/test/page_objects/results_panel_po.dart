// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:pageloader/html.dart';

part 'results_panel_po.g.dart';

/// The ResultsSelectorPanel and ResultsPanel components are very similar,
/// but the ResultsSelectorPanel has checkboxes to select tests.
/// I am using a common PageObject interface ResultsPanelPO to interact
/// with page objects for both components.  Because of code generation,
/// I can't share common code easily between the two classes by extending
/// ResultsPanelPO. Using a mixin to share implementations has many
/// complications in this case, so is not worth it for these two classes.
@PageObject()
abstract class ResultsPanelPO {
  ResultsPanelPO();
  factory ResultsPanelPO.create(PageLoaderElement context) =
      $ResultsPanelPO.create;

  @ByCss('results-panel > div')
  List<PageLoaderElement> get _configurationGroups;

  PageLoaderElement configurationGroup(String searchText) {
    return _configurationGroups.firstWhere(
        (group) => group.innerText.contains(searchText),
        orElse: () => null);
  }

  PageLoaderElement resultsGroup(
          PageLoaderElement configurationGroup, String resultsText) =>
      _resultGroups(configurationGroup).firstWhere(
          (resultGroup) => resultGroup.innerText.contains(resultsText),
          orElse: () => null);

  List<PageLoaderElement> _resultGroups(PageLoaderElement configurationGroup) {
    return configurationGroup.getElementsByCss('results-panel > div > div');
  }

  List<PageLoaderElement> _results(PageLoaderElement resultGroup) {
    return resultGroup
        .getElementsByCss('results-panel > div > div > span.indent');
  }

  List<List<List<PageLoaderElement>>> _getResults() => [
        for (final configurationGroup in _configurationGroups)
          [
            for (final resultGroup in _resultGroups(configurationGroup))
              _results(resultGroup)
          ]
      ];

  List<List<List<PageLoaderElement>>> _cachedResults;

  List<List<List<PageLoaderElement>>> get results =>
      _cachedResults ??= _getResults();

  List<List<List<String>>> testNames() => [
        for (final configurationGroup in results)
          [
            for (final resultGroup in configurationGroup)
              [for (final result in resultGroup) result.innerText]
          ]
      ];
}

String checked(PageLoaderElement checkbox) =>
    checkbox.attributes['aria-checked'];

PageLoaderElement checkbox(PageLoaderElement parent) =>
    parent.getElementsByCss('material-checkbox').first;

@PageObject()
abstract class ResultsSelectorPanelPO implements ResultsPanelPO {
  // ignore_for_file:annotate_overrides
  // Because we cannot use extends here, all the methods of
  // the superclass are repeated here.  Some are modified
  // because the page DOM is different
  ResultsSelectorPanelPO();

  factory ResultsSelectorPanelPO.create(PageLoaderElement context) =
      $ResultsSelectorPanelPO.create;

  @ByCss('results-selector-panel > div')
  List<PageLoaderElement> get _configurationGroups;

  List<PageLoaderElement> _resultGroups(PageLoaderElement configurationGroup) {
    return configurationGroup
        .getElementsByCss('results-selector-panel > div > div.indent');
  }

  PageLoaderElement configurationGroup(String searchText) {
    return _configurationGroups.firstWhere(
        (group) => group.innerText.contains(searchText),
        orElse: () => null);
  }

  PageLoaderElement resultsGroup(
          PageLoaderElement configurationGroup, String resultsText) =>
      _resultGroups(configurationGroup).firstWhere(
          (resultGroup) => resultGroup.innerText.contains(resultsText),
          orElse: () => null);

  List<PageLoaderElement> _results(PageLoaderElement resultGroup) {
    return resultGroup.getElementsByCss(
        'results-selector-panel > div > div.indent > span.indent');
  }

  List<List<List<PageLoaderElement>>> _getResults() => [
        for (final configurationGroup in _configurationGroups)
          [
            for (final resultGroup in _resultGroups(configurationGroup))
              _results(resultGroup)
          ]
      ];

  List<List<List<PageLoaderElement>>> _cachedResults;

  List<List<List<PageLoaderElement>>> get results =>
      _cachedResults ??= _getResults();

  List<List<List<String>>> testNames() => [
        for (final configurationGroup in results)
          [
            for (final resultGroup in configurationGroup)
              [for (final result in resultGroup) result.innerText]
          ]
      ];
}
