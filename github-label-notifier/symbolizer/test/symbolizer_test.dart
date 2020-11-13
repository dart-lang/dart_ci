// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
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

class MockSymbolsCache extends Mock implements SymbolsCache {}

class MockGitHub extends Mock implements GitHub {}

class MockNdk extends Mock implements Ndk {}

class MockRepositoriesService extends Mock implements RepositoriesService {}

class MockRepositoryCommit extends Mock implements RepositoryCommit {}

final regenerateExpectations =
    bool.fromEnvironment('REGENERATE_EXPECTATIONS') ||
        Platform.environment['REGENERATE_EXPECTATIONS'] == 'true';

final config = loadConfigFromFile();

void main() {
  group('end-to-end', () {
    Symbolizer symbolizer;
    final files = Directory('test/data').listSync();

    setUpAll(() {
      final ndk = Ndk();
      final symbols = SymbolsCache(path: 'symbols-cache', ndk: ndk);
      final github = GitHub(auth: Authentication.withToken(config.githubToken));
      symbolizer = Symbolizer(symbols: symbols, ndk: ndk, github: github);
    });

    for (var inputFile in files
        .where((f) => p.basename(f.path).endsWith('.input.txt'))
        .cast<File>()) {
      final testName = p.basename(inputFile.path).split('.').first;
      final expectationFile = File('test/data/$testName.expected.txt');
      test(testName, () async {
        final input = await inputFile.readAsString();
        final overrides = Bot.parseCommand(0, input)?.overrides;
        final result = await symbolizer.symbolize(input, overrides: overrides);
        final roundTrip = (jsonDecode(jsonEncode(result)) as List)
            .cast<Map<String, dynamic>>()
            .map($SymbolizationResult.fromJson);
        expect(result, equals(roundTrip));
        if (regenerateExpectations) {
          await expectationFile.writeAsString(
              const JsonEncoder.withIndent('  ').convert(result));
        } else {
          final expected =
              (jsonDecode(await expectationFile.readAsString()) as List)
                  .map((e) => SymbolizationResult.fromJson(e))
                  .toList();

          expect(result, equals(expected));
        }
      });
    }

    tearDownAll(() {
      symbolizer.github.dispose();
    });
  });

  test('nothing to symbolize', () async {
    final symbols = MockSymbolsCache();
    final ndk = MockNdk();
    final github = MockGitHub();
    final symbolizer = Symbolizer(github: github, ndk: ndk, symbols: symbols);

    expect(
        await symbolizer
            .symbolize('''This is test which does not contain anything'''),
        isEmpty);
  });

  group('android crash', () {
    test('no engine hash', () async {
      final symbols = MockSymbolsCache();
      final ndk = MockNdk();
      final github = MockGitHub();
      final symbolizer = Symbolizer(github: github, ndk: ndk, symbols: symbols);

      final results = await symbolizer.symbolize('''
*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***
backtrace:
      #00 pc 0000000000111111  libflutter.so (BuildId: aaaabbbbccccddddaaaabbbbccccdddd)
      #01 pc 0000000000222222  else-else
''');
      expect(results.length, equals(1));
      expect(results.first.crash.engineVariant,
          equals(EngineVariant(os: 'android', arch: null, mode: null)));
      expect(results.first.notes.map((note) => note.kind),
          equals([SymbolizationNoteKind.unknownEngineHash]));
    });

    test('no abi', () async {
      final symbols = MockSymbolsCache();
      final ndk = MockNdk();
      final github = MockGitHub();
      final symbolizer = Symbolizer(github: github, ndk: ndk, symbols: symbols);

      final repositories = MockRepositoriesService();
      final commit = MockRepositoryCommit();

      when(commit.sha).thenReturn('abcdef123456');
      when(repositories.getCommit(
              RepositorySlug('flutter', 'engine'), 'abcdef'))
          .thenAnswer((_) async => commit);
      when(github.repositories).thenReturn(repositories);

      final results = await symbolizer.symbolize('''
• Engine revision abcdef

*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***
backtrace:
      #00 pc 0000000000111111  libflutter.so (BuildId: aaaabbbbccccddddaaaabbbbccccdddd)
      #01 pc 0000000000222222  else-else
''');
      expect(results.length, equals(1));
      expect(results.first.crash.engineVariant,
          equals(EngineVariant(os: 'android', arch: null, mode: null)));
      expect(results.first.notes.map((note) => note.kind),
          equals([SymbolizationNoteKind.unknownAbi]));
    });

    test('illegal abi', () async {
      final symbols = MockSymbolsCache();
      final ndk = MockNdk();
      final github = MockGitHub();
      final symbolizer = Symbolizer(github: github, ndk: ndk, symbols: symbols);

      final repositories = MockRepositoriesService();
      final commit = MockRepositoryCommit();

      when(commit.sha).thenReturn('abcdef123456');
      when(repositories.getCommit(
              RepositorySlug('flutter', 'engine'), 'abcdef'))
          .thenAnswer((_) async => commit);
      when(github.repositories).thenReturn(repositories);

      final results = await symbolizer.symbolize('''
• Engine revision abcdef

*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***
ABI: 'something'
backtrace:
      #00 pc 0000000000111111  libflutter.so (BuildId: aaaabbbbccccddddaaaabbbbccccdddd)
      #01 pc 0000000000222222  else-else
''');
      expect(results.length, equals(1));
      expect(results.first.crash.engineVariant,
          equals(EngineVariant(os: 'android', arch: null, mode: null)));
      expect(results.first.notes.map((note) => note.kind),
          equals([SymbolizationNoteKind.unknownAbi]));
    });

    test('symbolize', () async {
      final symbols = MockSymbolsCache();
      final ndk = MockNdk();
      final github = MockGitHub();
      final symbolizer = Symbolizer(github: github, ndk: ndk, symbols: symbols);

      final repositories = MockRepositoriesService();
      final commit = MockRepositoryCommit();

      when(commit.sha).thenReturn('abcdef123456');
      when(repositories.getCommit(
              RepositorySlug('flutter', 'engine'), 'abcdef'))
          .thenAnswer((_) async => commit);
      when(github.repositories).thenReturn(repositories);

      final releaseBuild = EngineBuild(
          engineHash: 'abcdef123456',
          variant:
              EngineVariant(os: 'android', arch: 'arm64', mode: 'release'));

      when(symbols.findVariantByBuildId(
              engineHash: 'abcdef123456',
              variant: EngineVariant(os: 'android', arch: 'arm64', mode: null),
              buildId: 'aaaabbbbccccddddaaaabbbbccccdddd'))
          .thenAnswer((x) async {
        return releaseBuild;
      });

      when(symbols.get(releaseBuild)).thenAnswer(
          (_) async => '/engines/abcdef123456/android-arm64-release');

      when(ndk.getBuildId(
              '/engines/abcdef123456/android-arm64-release/libflutter.so'))
          .thenAnswer((_) async => 'aaaabbbbccccddddaaaabbbbccccdddd');

      when(ndk.getTextSectionInfo(
              '/engines/abcdef123456/android-arm64-release/libflutter.so'))
          .thenAnswer((_) async => SectionInfo(
              fileOffset: 0x12340, fileSize: 0x2000, virtualAddress: 0x13340));

      final backtrace = '''
*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***
ABI: 'arm64'
backtrace:
      #00 pc 0000000000111111  libflutter.so (BuildId: aaaabbbbccccddddaaaabbbbccccdddd)
      #01 pc 0000000000222222  else-else''';

      when(ndk.symbolize(
          object: '/engines/abcdef123456/android-arm64-release/libflutter.so',
          arch: 'arm64',
          addresses: [
            '0x124111' // Adjusted by load bias.
          ])).thenAnswer(
          (_) async => ['some-function\nthird_party/something/else.cc']);

      final results = await symbolizer.symbolize('''
• Engine revision abcdef

$backtrace
''');

      expect(results.length, equals(1));
      expect(results.first.crash.engineVariant,
          equals(EngineVariant(os: 'android', arch: 'arm64', mode: null)));
      expect(
          results.first.crash.frames.first,
          equals(AndroidCrashFrame(
              no: '00',
              pc: 0x111111,
              binary: 'libflutter.so',
              rest: ' (BuildId: aaaabbbbccccddddaaaabbbbccccdddd)',
              buildId: 'aaaabbbbccccddddaaaabbbbccccdddd')));
      expect(results.first.engineBuild, equals(releaseBuild));
      expect(results.first.notes, isEmpty);
      expect(results.first.symbolized.trim(), equals('''
#00 0000000000111111 libflutter.so (BuildId: aaaabbbbccccddddaaaabbbbccccdddd)
                                   some-function
                                   third_party/something/else.cc
#01 0000000000222222 else-else'''));
    });
  });
}
