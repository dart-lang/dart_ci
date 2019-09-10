// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:collection';
import 'dart:core';

// import 'package:angular/angular.dart';
import 'package:dart_results_feed/src/filter_service.dart';
import 'package:firebase/firestore.dart' as firestore;

class IntRange implements Comparable {
  IntRange(this.start, this.end);

  final int start;
  final int end;

  bool operator ==(other) =>
      other is IntRange && other.start == start && other.end == end;

  int get hashCode => start + end * 40927 % 63703;

  bool contains(int i) => i >= start && i <= end;
  int get length => end - start + 1;

  int compareTo(dynamic other) {
    IntRange o = other; // Throw TypeError if not an IntRange
    return end == o.end ? start.compareTo(o.start) : end.compareTo(o.end);
  }

  String toString() => "IntRange($start, $end)";
}

class Commit implements Comparable {
  final String hash;
  final String author;
  final String title;
  final DateTime created;
  final int index;

  Commit(this.hash, this.author, this.title, this.created, this.index);

  Commit.fromDocument(firestore.DocumentSnapshot document)
      : hash = document.id,
        author = document.get('author'),
        title = document.get('title'),
        created = document.get('created'),
        index = document.get('index');

  /// Sort in reverse index order.
  int compareTo(other) => (other as Commit).index.compareTo(index);

  String toString() => "$index $hash $author $created $title";
}

class ChangeGroup implements Comparable {
  IntRange range;
  List<Commit> commits;
  Changes changes = Changes();
  Changes latestChanges = Changes();

  ChangeGroup.fromRange(IntRange this.range, Iterable<Commit> allCommits) {
    commits = allCommits
        .where((commit) => range.contains(commit.index))
        .toList()
          ..sort();
  }

  /// Sort in reverse chronological order.
  int compareTo(other) => (other as ChangeGroup).range.compareTo(range);

  void addChanges(Iterable<Change> newChanges) {
    newChanges.forEach(changes.add);
  }

  void addLatestChanges(Iterable<Change> newChanges) {
    newChanges.forEach(latestChanges.add);
  }

  bool show(FilterService filter) =>
      filter.showAllCommits || shownChanges(filter).show(filter);

  Changes shownChanges(FilterService filterService) =>
      filterService.showLatestFailures ? latestChanges : changes;
}

/// A list of configurations affected by a result change.
/// The list is canonicalized, and configurations are grouped into
/// summaries of similar configurations.
class Configurations {
  static final _instances = <String, Configurations>{};
  List<String> configurations;
  String text;
  Map<String, List<String>> summaries;

  Configurations._(List<dynamic> configurations)
      : configurations = List<String>.from(configurations),
        text = configurations.join(),
        summaries = _summarize(configurations);

  factory Configurations(List configs) {
    configs.sort();
    return _instances.putIfAbsent(
        configs.join(' '), () => Configurations._(configs.toList()));
  }

  static Map<String, List<String>> _summarize(List<dynamic> configurations) {
    final groups = <String, List<String>>{};
    for (final String configuration in configurations) {
      groups
          .putIfAbsent(configuration.split('-').first, () => <String>[])
          .add(configuration);
    }
    // Sorts the values as a side effect, while changing their keys.
    return SplayTreeMap.fromIterable(groups.values,
        key: (list) => (list..sort).length == 1
            ? list.first
            : list.first.split('-').first + '...');
  }

  bool show(FilterService filter) => configurations.any((configuration) =>
      filter.enabledBuilderGroups.any(configuration.startsWith));
}

class Change {
  Change._(
      this.name,
      this.configurations,
      this.result,
      this.previousResult,
      this.expected,
      this.blamelistStartIndex,
      this.blamelistEndIndex,
      this.trivialBlamelist)
      : changesText = '$previousResult -> $result (expected $expected)',
        configurationsText = configurations.text;
  Change.fromDocument(firestore.DocumentSnapshot document)
      : this._(
            document.get('name'),
            Configurations(document.get('configurations')),
            document.get('result'),
            document.get('previous_result'),
            document.get('expected'),
            document.get('blamelist_start_index'),
            document.get('blamelist_end_index'),
            document.get('trivial_blamelist'));

  final String name;
  final Configurations configurations;
  final String result;
  final String previousResult;
  final String expected;
  int blamelistStartIndex;
  int blamelistEndIndex;
  bool trivialBlamelist;
  final String configurationsText;
  final String changesText;

  Change copy({List<String> newConfigurations}) => Change._(
      name,
      newConfigurations == null
          ? configurations
          : Configurations(newConfigurations),
      result,
      previousResult,
      expected,
      blamelistStartIndex,
      blamelistEndIndex,
      trivialBlamelist);

  String get resultStyle => result == expected ? 'success' : 'failure';
}

class ResultGroup with IterableMixin<Change> {
  final String changesText;
  final Map<String, Change> _map = SplayTreeMap();
  ResultGroup(this.changesText);

  get iterator => _map.values.iterator;
  void operator []=(Object resultText, Object change) {
    _map[resultText] = change;
  }

  bool show(FilterService filterService) =>
      !filterService.showLatestFailures || first.resultStyle == 'failure';
}

class ConfigGroup with IterableMixin<ResultGroup> {
  final Configurations configurations;
  final Map<String, ResultGroup> _map = SplayTreeMap();
  ConfigGroup(this.configurations);

  ResultGroup operator [](String resultText) =>
      _map.putIfAbsent(resultText, () => ResultGroup(resultText));

  get iterator => _map.values.iterator;
  Iterable<ResultGroup> shown(FilterService filter) =>
      where((group) => group.show(filter));
  bool show(FilterService filter) =>
      configurations.show(filter) && shown(filter).isNotEmpty;
}

class Changes with IterableMixin<ConfigGroup> {
  final Map<String, ConfigGroup> _map = SplayTreeMap();
  Changes();
  get iterator => _map.values.iterator;

  ConfigGroup operator [](Configurations configuration) =>
      _map.putIfAbsent(configuration.text, () => ConfigGroup(configuration));

  void add(Change change) {
    this[change.configurations][change.changesText][change.name] = change;
  }

  Iterable<ConfigGroup> shown(FilterService filterService) =>
      where((group) => group.show(filterService));
  bool show(FilterService filterService) => shown(filterService).isNotEmpty;
}