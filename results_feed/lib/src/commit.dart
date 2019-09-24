// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:collection';
import 'dart:core';

// import 'package:angular/angular.dart';
import 'filter_service.dart';
import 'package:firebase/firestore.dart' as firestore;

int reverse(key1, key2) => key2.compareTo(key1);

class IntRangeIterator implements Iterator<int> {
  int current;
  int end;

  IntRangeIterator(int start, this.end) {
    current = start - 1;
  }

  bool moveNext() {
    current++;
    if (current > end) current = null;
    return current != null;
  }
}

class IntRange with IterableMixin<int> implements Comparable {
  IntRange(this.start, this.end);

  final int start;
  final int end;

  bool operator ==(other) =>
      other is IntRange && other.start == start && other.end == end;

  int get hashCode => start + end * 40927 % 63703;

  Iterator<int> get iterator => IntRangeIterator(start, end);

  bool contains(Object i) => i as int >= start && i as int <= end;

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
  final IntRange range;
  List<Commit> commits;
  final Changes changes;
  final Changes latestChanges;
  Changes _filteredChanges;
  Filter _filter = Filter.defaultFilter;

  ChangeGroup(IntRange this.range, Map<int, Commit> allCommits,
      Iterable<Change> changeList, Iterable<Change> liveChangeList)
      : changes = Changes(changeList),
        latestChanges = Changes(liveChangeList) {
    commits = [for (int i in range) if (allCommits[i] != null) allCommits[i]]
      ..sort(reverse);
  }

  /// Sort in reverse chronological order.
  int compareTo(other) => (other as ChangeGroup).range.compareTo(range);

  void addChanges(Iterable<Change> newChanges) {
    newChanges.forEach(changes.add);
    computeFilteredChanges(_filter);
  }

  void addLatestChanges(Iterable<Change> newChanges) {
    newChanges.forEach(latestChanges.add);
    computeFilteredChanges(_filter);
  }

  bool show(Filter filter) =>
      filter.showAllCommits || filteredChanges(filter).isNotEmpty;

  Changes shownChanges(Filter filter) =>
      filter.showLatestFailures ? latestChanges : changes;

  Changes filteredChanges(Filter filter) =>
      (filter == _filter) ? _filteredChanges : computeFilteredChanges(filter);

  Changes computeFilteredChanges(filter) {
    _filteredChanges = shownChanges(filter).filtered(filter);
    _filter = filter;
    return _filteredChanges;
  }
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

  bool show(Filter filter) =>
      filter.allGroups ||
      configurations.any((configuration) =>
          filter.configurationGroups.any(configuration.startsWith));
}

class Change {
  Change._(
      this.id,
      this.name,
      this.configurations,
      this.result,
      this.previousResult,
      this.expected,
      this.blamelistStartIndex,
      this.blamelistEndIndex,
      this.pinnedIndex,
      this.trivialBlamelist)
      : changesText = '$previousResult -> $result (expected $expected)',
        configurationsText = configurations.text;

  Change.fromDocument(firestore.DocumentSnapshot document)
      : this._(
            document.id,
            document.get('name'),
            Configurations(document.get('configurations')),
            document.get('result'),
            document.get('previous_result'),
            document.get('expected'),
            document.get('blamelist_start_index'),
            document.get('blamelist_end_index'),
            document.get('pinned_index'),
            document.get('trivial_blamelist'));

  final String id;
  final String name;
  final Configurations configurations;
  final String result;
  final String previousResult;
  final String expected;
  final int blamelistStartIndex;
  final int blamelistEndIndex;
  int pinnedIndex;
  bool trivialBlamelist;
  final String configurationsText;
  final String changesText;

  Change copy({List<String> newConfigurations}) => Change._(
      id,
      name,
      newConfigurations == null
          ? configurations
          : Configurations(newConfigurations),
      result,
      previousResult,
      expected,
      blamelistStartIndex,
      blamelistEndIndex,
      pinnedIndex,
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

  bool show(Filter filter) =>
      !filter.showLatestFailures || first.resultStyle == 'failure';
}

class ConfigGroup with IterableMixin<ResultGroup> {
  final Configurations configurations;
  final Map<String, ResultGroup> _map;

  ConfigGroup(this.configurations, {Map<String, ResultGroup> map})
      : _map = map ?? SplayTreeMap();

  ResultGroup operator [](String resultText) =>
      _map.putIfAbsent(resultText, () => ResultGroup(resultText));

  get iterator => _map.values.iterator;

  ConfigGroup filtered(Filter filter) {
    if (!configurations.show(filter)) {
      return ConfigGroup(configurations, map: {});
    }
    final newMap =
        Map.fromEntries(_map.entries.where((e) => e.value.show(filter)));
    return newMap.length == _map.length
        ? this
        : ConfigGroup(configurations, map: newMap);
  }
}

class Changes with IterableMixin<ConfigGroup> {
  final Map<String, ConfigGroup> _map;

  Changes(Iterable<Change> changes, {Map map}) : _map = map ?? SplayTreeMap() {
    changes.forEach(add);
  }

  get iterator => _map.values.iterator;

  ConfigGroup operator [](Configurations configuration) =>
      _map.putIfAbsent(configuration.text, () => ConfigGroup(configuration));

  void add(Change change) {
    this[change.configurations][change.changesText][change.name] = change;
  }

  Changes filtered(Filter filter) {
    final newMap = <String, ConfigGroup>{};
    bool changed = false;
    for (final key in _map.keys) {
      final newValue = _map[key].filtered(filter);
      changed = changed || newValue != _map[key];
      if (!newValue.isEmpty) {
        newMap[key] = newValue;
      }
    }
    return changed ? Changes([], map: newMap) : this;
  }
}
