// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:args/args.dart';

class BaselineOptions {
  final List<String> builders;
  final Map<String, List<String>> configs;
  final bool dryRun;
  final List<String> channels;
  final ConfigurationMapping mapping;
  final Set<String> suites;
  final String target;

  BaselineOptions(this.builders, this.configs, this.dryRun, this.channels,
      this.mapping, this.suites, this.target);

  factory BaselineOptions.parse(List<String> arguments) {
    var parser = ArgParser();
    parser.addMultiOption('channel',
        abbr: 'c',
        allowed: ['main', 'dev', 'beta', 'stable'],
        defaultsTo: ['main'],
        help: 'a comma separated list of channels');
    parser.addMultiOption('config-mapping',
        abbr: 'm',
        defaultsTo: ['*'],
        help: 'a comma separated list of configuration mappings in the form:'
            '<old1>:<new1>,<old2>:<new2>');
    parser.addMultiOption('builders',
        abbr: 'b',
        help: 'a comma separated list of builders to read result data from');
    parser.addMultiOption('suites',
        abbr: 's', help: 'a comma separated list of test suites to include');
    parser.addOption('target',
        abbr: 't', help: 'a the name of the builder to baseline');
    parser.addFlag('dry-run',
        abbr: 'n',
        defaultsTo: false,
        help: 'prevents writes and only processes a single result',
        negatable: false);
    parser.addFlag('ignore-unmapped',
        abbr: 'u',
        defaultsTo: false,
        help: 'ignore tests in unmapped configurations',
        negatable: false);
    parser.addFlag('help',
        abbr: 'h', negatable: false, help: 'prints this message');
    var parsed = parser.parse(arguments);
    if (parsed['help'] ||
        parsed['builders'] is! List<String> ||
        parsed['target'] is! String) {
      print(parser.usage);
      exit(64);
    }
    var builders = (parsed['builders'] as List<String>);
    final target = parsed['target'];
    if (builders.isEmpty) {
      builders = [target];
    }
    var mapping = parsed['ignore-unmapped']
        ? ConfigurationMapping.relaxed
        : ConfigurationMapping.strict;
    var configs = const <String, List<String>>{};
    final configMapping = parsed['config-mapping'] as List<String>;
    if (configMapping.length == 1 && configMapping.first == '*') {
      mapping = ConfigurationMapping.none;
    } else {
      configs = {};
      for (var mapping in configMapping.map((c) => c.split(':'))) {
        configs.putIfAbsent(mapping.first, () => []).add(mapping.last);
      }
    }
    final dryRun = parsed['dry-run'];
    final channels = parsed['channel'];
    final suites = Set.unmodifiable(parsed['suites'] as List<String>);

    return BaselineOptions(
        builders, configs, dryRun, channels, mapping, suites, target);
  }
}

List<String>? _strict(
        String configuration, Map<String, List<String>> configs) =>
    configs[configuration] ??
    (throw Exception("Missing configuration mapping for $configuration"));
List<String>? _relaxed(
        String configuration, Map<String, List<String>> configs) =>
    configs[configuration];
List<String>? _none(String configuration, Map<String, List<String>> configs) =>
    [configuration];

enum ConfigurationMapping {
  none(_none),
  strict(_strict),
  relaxed(_relaxed);

  const ConfigurationMapping(this.mapping);
  final List<String>? Function(
      String configuration, Map<String, List<String>> configs) mapping;

  List<String>? call(String configuration, Map<String, List<String>> configs) =>
      mapping(configuration, configs);
}
