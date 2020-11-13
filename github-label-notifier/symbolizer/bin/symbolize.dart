#!/usr/bin/env dart
// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Primitive CLI for the symbolizer. Usage:
///
///    symbolize <input-file> [overrides]
///

import 'dart:io';

import 'package:github/github.dart';
import 'package:logging/logging.dart';
import 'package:symbolizer/config.dart';
import 'package:symbolizer/ndk.dart';
import 'package:symbolizer/symbolizer.dart';
import 'package:symbolizer/symbols.dart';
import 'package:symbolizer/bot.dart';

final config = loadConfigFromFile();

void main(List<String> args) async {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  final ndk = Ndk();
  final symbols = SymbolsCache(path: 'symbols-cache', ndk: ndk);
  final github = GitHub();

  final symbolizer = Symbolizer(symbols: symbols, ndk: ndk, github: github);
  final input = File(args.first).readAsStringSync();

  final command = args.length >= 2
      ? Bot.parseCommand(0, '${Bot.accountMention} ${args.skip(1).join(' ')}')
      : Bot.parseCommand(0, input);

  try {
    print(await symbolizer.symbolize(input, overrides: command?.overrides));
  } finally {
    github.dispose();
  }
}
