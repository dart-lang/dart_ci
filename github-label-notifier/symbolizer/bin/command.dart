#!/usr/bin/env dart
// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:args/args.dart';
import 'package:github/github.dart';
import 'package:logging/logging.dart';
import 'package:sendgrid_mailer/sendgrid_mailer.dart';
import 'package:symbolizer/bot.dart';
import 'package:symbolizer/config.dart';
import 'package:symbolizer/ndk.dart';
import 'package:symbolizer/symbolizer.dart';
import 'package:symbolizer/symbols.dart';

const isDev = bool.fromEnvironment('DEV');

final bindHostname = isDev
    ? InternetAddress.loopbackIPv4
    : 'crash-symbolizer.c.dart-ci.internal';

final log = Logger('server');

final config = loadConfigFromFile();

final argParser = ArgParser(allowTrailingOptions: false)
  ..addFlag(
    'act',
    help: 'Post comment on GitHub (by default '
        'results are printed into stdout instead)',
    negatable: false,
    defaultsTo: false,
  );

Future<void> main(List<String> args) async {
  final opts = argParser.parse(args);
  if (opts.rest.length != 2) {
    print('''Usage: command.dart [--act] <issue-number> <command>
${argParser.usage}''');
    exit(1);
  }
  final issueNumber = int.parse(opts.rest[0]);
  final command = opts.rest[1];

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
    failuresEmail: config.failureEmail,
    dryRun: !opts['act'],
  );

  final repo = RepositorySlug('flutter', 'flutter');
  await bot.executeCommand(
    repo,
    await github.issues.get(repo, issueNumber),
    IssueComment(
        body: '${Bot.accountMention} $command',
        user: User(
          login: Platform.environment['USER'],
        )),
    authorized: true,
  );
  github.dispose();
}
