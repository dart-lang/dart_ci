// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:html';

class Filter {
  final List<String> configurations;
  final List<String> configurationGroups;
  final bool showLatestFailures;
  final bool showUnapprovedOnly;
  final String singleTest; // null by default.

  Filter(this.configurations, this.configurationGroups, this.showLatestFailures,
      this.showUnapprovedOnly, this.singleTest);

  static final defaultFilter = Filter(
      [], [], defaultShowLatestFailures, defaultShowUnapprovedOnly, null);

  bool get hasFilter =>
      singleTest != null ||
      configurations.isNotEmpty ||
      configurationGroups.isNotEmpty;

  Filter copy(
          {List<String> configurations,
          List<String> configurationGroups,
          bool showLatestFailures,
          bool showUnapprovedOnly,
          String singleTest}) =>
      Filter(
          configurations ?? this.configurations,
          configurationGroups ?? this.configurationGroups,
          showLatestFailures ?? this.showLatestFailures,
          showUnapprovedOnly ?? this.showUnapprovedOnly,
          singleTest ?? this.singleTest); // Cannot reset singleTest to null.

  Filter clearTest() => Filter(configurations, configurationGroups,
      showLatestFailures, showUnapprovedOnly, null);

  String fragment() => [
        if (showLatestFailures != defaultShowLatestFailures)
          'showLatestFailures=$showLatestFailures',
        if (showUnapprovedOnly != defaultShowUnapprovedOnly)
          'showUnapprovedOnly=$showUnapprovedOnly',
        if (configurations.isNotEmpty)
          'configurations=${configurations.join(',')}',
        if (configurationGroups.isNotEmpty)
          'configurationGroups=${configurationGroups.join(',')}',
        if (singleTest != null) 'test=$singleTest'
      ].join('&');

  void updateUrl() {
    window.location.hash = fragment();
  }

  factory Filter.fromUrl() {
    final fragment = Uri.parse(window.location.href).fragment;
    var result = defaultFilter;
    if (fragment.isEmpty) return result;
    for (final setting in fragment.split('&')) {
      final key = setting.split('=').first;
      final value = setting.split('=').last;
      if (key == 'showLatestFailures') {
        result = result.copy(showLatestFailures: value == 'true');
      } else if (key == 'showUnapprovedOnly') {
        result = result.copy(showUnapprovedOnly: value == 'true');
      } else if (key == 'configurations') {
        final configurations = value.split(',');
        result = result.copy(configurations: configurations);
      } else if (key == 'configurationGroups') {
        final configurationGroups = value.split(',');
        result = result.copy(configurationGroups: configurationGroups);
      } else if (key == 'test') {
        result = result.copy(singleTest: value);
      }
    }
    return result;
  }

  static const defaultShowLatestFailures = true;
  static const defaultShowUnapprovedOnly = false;
  static const allConfigurationGroups = <String>[
    'analyzer',
    'app_jitk',
    'cfe',
    'dart2js',
    'dartdevc',
    'dartdevk',
    'dartk',
    'dartkb',
    'dartkp',
    'fasta',
    'unittest',
    'vm'
  ];
}

class FilterService {
  FilterService();

  Filter filter = Filter.fromUrl();

  void changeFilter(Filter newFilter) {
    newFilter.updateUrl();
    if (newFilter.singleTest != filter.singleTest) {
      window.location.reload();
    }
    filter = newFilter;
  }

  void addConfiguration(String configuration) {
    if (configuration.endsWith('-')) {
      changeFilter(filter.copy(
          configurationGroups: [configuration, ...filter.configurationGroups]));
    } else {
      changeFilter(filter
          .copy(configurations: [configuration, ...filter.configurations]));
    }
  }

  void removeConfiguration(String configuration) {
    changeFilter(filter.copy(
        configurationGroups: List.from(filter.configurationGroups)
          ..remove(configuration),
        configurations: List.from(filter.configurations)
          ..remove(configuration)));
  }

  void setTestFilter(String test) {
    changeFilter(filter.copy(singleTest: test));
  }

  void clearTestFilter() {
    changeFilter(filter.clearTest());
  }
}
