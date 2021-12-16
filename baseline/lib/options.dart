// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:args/args.dart';

class BaselineOptions {
  late final bool dryRun;
  late final List<String> builders;
  late final Map<String, String> configs;
  late final List<String> channels;
  late final String target;

  BaselineOptions(List<String> arguments) {
    var parser = ArgParser();
    parser.addMultiOption('channel',
        abbr: 'c',
        allowed: ['main', 'dev', 'beta', 'stable'],
        defaultsTo: ['main'],
        help: 'a comma separated list of channels');
    parser.addMultiOption('config-mapping',
        abbr: 'm',
        help: 'a comma separated list of configuration mappings in the form:'
            '<old1>:<new1>,<old2>:<new2>');
    parser.addMultiOption('builders',
        abbr: 'b',
        help: 'a comma separated list of builders to read result data from');
    parser.addOption('target',
        abbr: 't', help: 'a the name of the builder to baseline');
    parser.addFlag('dry-run',
        abbr: 'n',
        defaultsTo: false,
        help: 'prevents writes and only processes a single result',
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
    builders = (parsed['builders'] as List<String>);
    configs = {
      for (var v in ((parsed['config-mapping'] as Iterable<String>)
          .map((c) => c.split(':'))))
        v[0]: v[1]
    };
    dryRun = parsed['dry-run'];
    channels = parsed['channel'];
    target = parsed['target'];
  }
}
