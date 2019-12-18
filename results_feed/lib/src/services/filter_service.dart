// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:html';

class Filter {
  final List<String> configurationGroups;
  final bool showAllCommits;
  final bool showLatestFailures;
  final bool showUnapprovedOnly;

  const Filter._(this.configurationGroups, this.showAllCommits,
      this.showLatestFailures, this.showUnapprovedOnly);
  Filter(this.configurationGroups, showAllCommits, this.showLatestFailures,
      this.showUnapprovedOnly)
      : showAllCommits = configurationGroups.isEmpty || showAllCommits;

  static const defaultFilter = Filter._(
      allConfigurationGroups,
      defaultShowAllCommits,
      defaultShowLatestFailures,
      defaultShowUnapprovedOnly);

  Filter copy(
          {List<String> configurationGroups,
          bool showAllCommits,
          bool showLatestFailures,
          bool showUnapprovedOnly}) =>
      Filter(
          configurationGroups ?? this.configurationGroups,
          showAllCommits ?? this.showAllCommits,
          showLatestFailures ?? this.showLatestFailures,
          showUnapprovedOnly ?? this.showUnapprovedOnly);

  bool get allGroups =>
      configurationGroups.length == allConfigurationGroups.length;

  String fragment() => [
        if (showAllCommits != defaultShowAllCommits)
          'showAllCommits=$showAllCommits',
        if (showLatestFailures != defaultShowLatestFailures)
          'showLatestFailures=$showLatestFailures',
        if (!allGroups) 'configurationGroups=${configurationGroups.join(',')}'
      ].join('&');

  void updateUrl() {
    window.location.hash = fragment();
  }

  factory Filter.fromUrl() {
    final fragment = Uri.parse(window.location.href).fragment;
    Filter result = defaultFilter;
    if (fragment.isEmpty) return result;
    for (final setting in fragment.split('&')) {
      final key = setting.split('=').first;
      final value = setting.split('=').last;
      if (key == 'showAllCommits') {
        result = result.copy(showAllCommits: value == 'true');
      } else if (key == 'showLatestFailures') {
        result = result.copy(showLatestFailures: value == 'true');
      } else if (key == 'configurationGroups') {
        final configurationGroups = value.split(',');
        result = result.copy(configurationGroups: configurationGroups);
      }
    }
    return result;
  }

  static const defaultShowAllCommits = false;
  static const defaultShowLatestFailures = false;
  static const defaultShowUnapprovedOnly = false;
  static const allConfigurationGroups = <String>[
    'analyzer',
    'app_jitk',
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
}
