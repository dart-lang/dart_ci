#!/usr/bin/env dart
// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:github/github.dart';
import 'package:logging/logging.dart';
import 'package:sendgrid_mailer/sendgrid_mailer.dart';
import 'package:symbolizer/bot.dart';
import 'package:symbolizer/config.dart';
import 'package:symbolizer/ndk.dart';
import 'package:symbolizer/symbolizer.dart';
import 'package:symbolizer/symbols.dart';
import 'package:symbolizer/server.dart';

const isDev = bool.fromEnvironment('DEV');

final bindHostname = isDev
    ? InternetAddress.loopbackIPv4
    : 'crash-symbolizer.c.dart-ci.internal';

final log = Logger('server');

final config = loadConfigFromFile();

Future<void> main() async {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  final mailer = Mailer(config.sendgridToken);
  final ndk = Ndk();
  final symbols = SymbolsCache(path: 'symbols-cache', ndk: ndk);
  final github = GitHub(auth: Authentication.withToken(config.githubToken));

  final symbolizer = Symbolizer(symbols: symbols, ndk: ndk, github: github);
  final bot = Bot(
      github: github,
      symbolizer: symbolizer,
      mailer: mailer,
      failuresEmail: config.failureEmail);

  await serve(
    bindHostname,
    4040,
    symbolizer: symbolizer,
    bot: bot,
  );
}
