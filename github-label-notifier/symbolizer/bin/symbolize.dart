#!/usr/bin/env dart
// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Primitive CLI for the symbolizer. Usage:
///
///    symbolize <input-file>|<github-uri> [overrides]
///
library;

import 'dart:io';

import 'package:ansicolor/ansicolor.dart';
import 'package:github/github.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;

import 'package:symbolizer/model.dart';
import 'package:symbolizer/ndk.dart';
import 'package:symbolizer/symbolizer.dart';
import 'package:symbolizer/symbols.dart';

final githubIssueUriRe = RegExp(
    r'https://github.com/(?<org>[-\w]+)/(?<repo>[-\w]+)/issues/(?<issue>\d+)(?<anchor>#issue(comment)?-\d+)?');

Future<String> loadContent(GitHub github, String resource) async {
  final match = githubIssueUriRe.firstMatch(resource);
  if (match != null) {
    final orgName = match.namedGroup('org')!;
    final repoName = match.namedGroup('repo')!;
    final issueNumber = int.parse(match.namedGroup('issue')!);
    final anchor = match.namedGroup('anchor');

    final int? commentId;
    if (anchor != null && anchor.startsWith('#issuecomment-')) {
      commentId = int.parse(anchor.split('-').last);
    } else {
      commentId = null;
    }

    final slug = RepositorySlug(orgName, repoName);
    if (commentId != null) {
      final comment = await github.issues.getComment(slug, commentId);
      return comment.body ?? '';
    } else {
      final issue = await github.issues.get(slug, issueNumber);
      return issue.body;
    }
  } else {
    return File(resource).readAsString();
  }
}

void main(List<String> args) async {
  if (args.isEmpty ||
      args.length > 2 ||
      args.contains('-h') ||
      args.contains('--help')) {
    print('''
Usage: symbolize <file-or-uri> ["<overrides>"]

file-or-uri can be either a path to the local text file or a URI
pointing to an issue or an issue comment on GitHub.

Supported URI formats:
* https://github.com/<org>/<repo>/issues/<issuenum>
* https://github.com/<org>/<repo>/issues/<issuenum>#issue-<id>
* https://github.com/<org>/<repo>/issues/<issuenum>#issuecomment-<id>

Overrides argument can contain the following components:

* engine#<sha> - use specific engine commit
* flutter#<commit> - use specific flutter commit
* profile|release|debug - use specific build mode
* x86|arm|arm64|x64 - use specific engine architecture

Additionally you can specify:

* force ios - force symbolization of partial Mac OS / iOS / Crashlytics
              reports which don't contain all necessary markers. This
              forces symbolizer to look for frames like this:

              4  Flutter                        0x106013134 (Missing)

* internal - force symbolization of stacks which look like:

             0x0000000105340708(Flutter + 0x002b4708)
''');
    exit(1);
  }

  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  final llvmTools = LlvmTools.findTools();
  if (llvmTools == null) {
    print('''
Failed to locate LLVM tools (llvm-{symbolizer,readobj,objdump}).

Either install them globally so that they are available in the \$PATH or
install Android NDK.
''');
    exit(1);
  }

  final ndk = Ndk(llvmTools: llvmTools);
  final symbols = SymbolsCache(
      path: p.join(Directory.systemTemp.path, 'symbols-cache'), ndk: ndk);
  final github = GitHub();

  final symbolizer = Symbolizer(symbols: symbols, ndk: ndk, github: github);

  try {
    final input = await loadContent(github, args.first);

    final overrides = args.length >= 2
        ? SymbolizationOverrides.tryParse(args.skip(1).join(' '))
        : null;

    _printResult(await symbolizer.symbolize(input, overrides: overrides));
  } finally {
    github.dispose();
  }
}

final errorPen = AnsiPen()..red();
final notePen = AnsiPen()..gray();
final successPen = AnsiPen()..green();
final stackPen = AnsiPen()..black(bold: true);

String _reindent(String str, {String padding = '  '}) {
  return '  ${str.split('\n').join('\n$padding')}';
}

/// Pretty print the given [SymbolizationResult] to stdout.
void _printResult(SymbolizationResult symbolized) async {
  final buf = StringBuffer();

  switch (symbolized) {
    case SymbolizationResultOk(:final results):
      for (var result in results) {
        buf.write('''

--------------------------------------------------------------------------------
''');
        bool success;
        switch (result) {
          case CrashSymbolizationResult(
              :final symbolized?,
              engineBuild: EngineBuild(
                engineHash: final engineHash,
                variant: EngineVariant(:final os, :final arch, :final mode)
              )
            ):
            success = true;
            buf.writeln(successPen(
                'symbolized using symbols for $engineHash $os-$arch-$mode\n'));
            buf.writeln(stackPen(_reindent(symbolized)));

          default:
            success = false;
            buf.writeln(errorPen('Found crash but failed to symbolize it.\n'));
            final addrSize = result.crash.frames
                    .map((frame) => frame.pc == (frame.pc & 0xFFFFFFFF))
                    .every((v) => v)
                ? 8
                : 16;

            for (var frame in result.crash.frames) {
              switch (frame) {
                case AndroidCrashFrame(
                    :final no,
                    :final pc,
                    :final binary,
                    :final rest,
                  ):
                  buf.writeln(stackPen(
                      '  #$no ${pc.toRadixString(16).padLeft(addrSize, '0')} $binary $rest'));

                default:
                  buf.writeln(stackPen('  ${frame.pc} ${frame.binary}'));
              }
            }
            buf.writeln();
        }

        final pen = success ? notePen : errorPen;
        for (var note in result.notes) {
          buf.write(pen('${noteMessage[note.kind]}'));
          final message = note.message;
          if (message != null && message.isNotEmpty) {
            buf.write(pen(':\n${_reindent(message)}'));
          }
          buf.write('');
        }

        buf.writeln('''

--------------------------------------------------------------------------------
''');
      }
    case SymbolizationResultError(error: final note):
      buf.write('''

--------------------------------------------------------------------------------
''');
      buf.write(errorPen('${noteMessage[note.kind]}'));
      final message = note.message;
      if (message != null && message.isNotEmpty) {
        buf.write(errorPen(':\n${_reindent(message)}'));
      }
      buf.write('');
      buf.writeln('''

--------------------------------------------------------------------------------
''');
  }

  print(buf);
}
