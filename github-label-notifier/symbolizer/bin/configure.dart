#!/usr/bin/env dart
// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:symbolizer/model.dart';

final parser = ArgParser()
  ..addOption('github-token',
      help: 'GitHub OAuth token',
      defaultsTo: Platform.environment['GITHUB_TOKEN'])
  ..addOption('output', help: 'Config to write', defaultsTo: '.config.json');

void main(List<String> args) {
  final opts = parser.parse(args);
  for (var opt in ['github-token']) {
    if (opts[opt].isEmpty) {
      throw 'Pass non-empty value via --$opt or through'
          ' ${opt.toUpperCase().replaceAll('-', '_')} environment variable';
    }
  }

  final config = ServerConfig(
    githubToken: opts['github-token'],
  );
  File(opts['output']).writeAsStringSync(jsonEncode(config));
}
