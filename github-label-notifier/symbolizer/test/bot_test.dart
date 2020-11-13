// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:github/github.dart';
import 'package:mockito/mockito.dart';
import 'package:path/path.dart' as p;
import 'package:symbolizer/bot.dart';
import 'package:symbolizer/config.dart';
import 'package:symbolizer/model.dart';
import 'package:symbolizer/ndk.dart';
import 'package:symbolizer/symbols.dart';
import 'package:test/test.dart';

import 'package:symbolizer/symbolizer.dart';

class MockGitHub extends Mock implements GitHub {}

class MockIssuesService extends Mock implements IssuesService {}

class SymbolsCacheProxy implements SymbolsCache {
  final SymbolsCache impl;
  final bool shouldThrow;
  SymbolsCacheProxy(this.impl, {this.shouldThrow = false});

  @override
  Future<EngineBuild> findVariantByBuildId(
      {String engineHash, EngineVariant variant, String buildId}) {
    return impl.findVariantByBuildId(
        engineHash: engineHash, variant: variant, buildId: buildId);
  }

  @override
  Future<String> get(EngineBuild build) {
    if (shouldThrow) {
      throw 'Failed to download ${build}';
    }
    return impl.get(build);
  }

  @override
  Future<String> getEngineBinary(EngineBuild build) =>
      impl.getEngineBinary(build);
}

final regenerateExpectations =
    bool.fromEnvironment('REGENERATE_EXPECTATIONS') ||
        Platform.environment['REGENERATE_EXPECTATIONS'] == 'true';

final config = loadConfigFromFile();

void main() {
  group('command parsing', () {
    test('nothing to do', () {
      expect(Bot.parseCommand(0, 'x64'), isNull);
      expect(Bot.parseCommand(0, 'x64 debug'), isNull);
      expect(Bot.parseCommand(0, 'x64\n@flutter-symbolizer-bot'), isNull);
    });
    test('simple', () {
      expect(
          Bot.parseCommand(0, '@flutter-symbolizer-bot'),
          equals(BotCommand(
            overrides: SymbolizationOverrides(),
            symbolizeThis: false,
            worklist: <String>{},
          )));
    });
    test('with arch', () {
      for (var arch in ['arm', 'arm64', 'x86', 'x64']) {
        expect(
            Bot.parseCommand(0, '@flutter-symbolizer-bot $arch'),
            equals(BotCommand(
              overrides: SymbolizationOverrides(arch: arch),
              symbolizeThis: false,
              worklist: <String>{},
            )));
      }
    });
    test('with mode', () {
      for (var mode in ['profile', 'release', 'debug']) {
        expect(
            Bot.parseCommand(0, '@flutter-symbolizer-bot $mode'),
            equals(BotCommand(
              overrides: SymbolizationOverrides(mode: mode),
              symbolizeThis: false,
              worklist: <String>{},
            )));
      }
    });
    test('with engine hash', () {
      expect(
          Bot.parseCommand(
              0, '@flutter-symbolizer-bot arm64 engine#aaabbb debug'),
          equals(BotCommand(
            overrides: SymbolizationOverrides(
                arch: 'arm64', engineHash: 'aaabbb', mode: 'debug'),
            symbolizeThis: false,
            worklist: <String>{},
          )));
    });
    test('with links', () {
      expect(
          Bot.parseCommand(
              0,
              '@flutter-symbolizer-bot '
              'https://github.com/flutter/flutter/issues/0#issue-1 '
              'engine#aaabbb '
              'https://github.com/flutter/flutter/issues/0#issuecomment-2'),
          equals(BotCommand(
            overrides: SymbolizationOverrides(engineHash: 'aaabbb'),
            symbolizeThis: false,
            worklist: <String>{'issue-1', 'issuecomment-2'},
          )));
    });
  });

  group('end-to-end', () {
    SymbolsCache symbols;
    Ndk ndk;
    GitHub github;
    final files = Directory('test/data').listSync();

    setUpAll(() {
      ndk = Ndk();
      symbols = SymbolsCache(path: 'symbols-cache', ndk: ndk);
      github = GitHub(auth: Authentication.withToken(config.githubToken));
    });

    for (var inputFile in files
        .where((f) => p.basename(f.path).endsWith('.input.txt'))
        .cast<File>()) {
      final testName = p.basename(inputFile.path).split('.').first;
      final expectationFile = File('test/data/$testName.expected.github.txt');
      test(testName, () async {
        final input = await inputFile.readAsString();

        final authorized = !input.contains('/unauthorized');
        final shouldThrow = input.contains('/throw');

        final symbolsProxy =
            SymbolsCacheProxy(symbols, shouldThrow: shouldThrow);

        final symbolizer =
            Symbolizer(symbols: symbolsProxy, ndk: ndk, github: github);

        final mockGitHub = MockGitHub();
        final mockIssues = MockIssuesService();
        final repo = RepositorySlug('flutter', 'flutter');
        final bot = Bot(
          github: mockGitHub,
          symbolizer: symbolizer,
          failuresEmail: null,
          mailer: null,
        );

        final command = Bot.isCommand(input)
            ? Bot.parseCommand(0, input).symbolizeThis
                ? input
                : input.split('\n').first
            : Bot.accountMention;

        final somebody = User(login: 'somebody');
        final commandComment =
            IssueComment(id: 1001, body: command, user: somebody);

        when(mockGitHub.issues).thenAnswer((realInvocation) => mockIssues);
        when(mockIssues.listCommentsByIssue(repo, 42))
            .thenAnswer((realInvocation) async* {
          yield IssueComment(id: 1002, body: 'something', user: somebody);
          yield IssueComment(id: 1042, body: input, user: somebody);
          yield commandComment;
        });

        when(mockIssues.createComment(repo, 42, any))
            .thenAnswer((realInvocation) async {
          return null;
        });

        throwOnMissingStub(mockGitHub);
        throwOnMissingStub(mockIssues);
        await bot.executeCommand(
          repo,
          Issue(id: 1000, body: 'something', number: 42),
          commandComment,
          authorized: authorized,
        );

        final result = verify(mockIssues.createComment(repo, 42, captureAny))
            .captured
            .single;

        if (regenerateExpectations) {
          await expectationFile.writeAsString(result);
        } else {
          final expected = await expectationFile.readAsString();

          expect(result, equals(expected));
        }
      });
    }

    tearDownAll(() {
      github.dispose();
    });
  });
}
