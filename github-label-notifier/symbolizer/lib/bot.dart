// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Implementation of @flutter-symbolizer-bot.
///
/// The bot is triggered by command comments starting with bot mention
/// and followed by zero of more keywords.
///
/// See README-bot.md for bot command documentation.
library symbolizer.bot;

import 'dart:convert';

import 'package:github/github.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:sendgrid_mailer/sendgrid_mailer.dart';

import 'package:symbolizer/model.dart';
import 'package:symbolizer/parser.dart';
import 'package:symbolizer/symbolizer.dart';

final _log = Logger(Bot.account);

class Bot {
  final GitHub github;
  final Symbolizer symbolizer;
  final Mailer mailer;
  final String failuresEmail;
  final bool dryRun;

  Bot({
    @required this.github,
    @required this.symbolizer,
    @required this.mailer,
    @required this.failuresEmail,
    this.dryRun = false,
  });

  static final account = 'flutter-symbolizer-bot';
  static final accountMention = '@$account';

  /// Returns [true] if the given [text] is potentially a command to the bot.
  static bool isCommand(String text) {
    return text.startsWith(Bot.accountMention);
  }

  /// Parse the given [text] as a command to the bot. See the library doc
  /// comment at the beginning of the file for information about the command
  /// format.
  static BotCommand parseCommand(int issueNumber, String text) {
    final command = text.split('\n').first;
    if (!isCommand(command)) {
      return null;
    }

    final issueNumberStr = issueNumber.toString();

    var symbolizeThis = false;
    final worklist = <String>{};
    String engineHash;
    String flutterVersion;
    String os;
    String arch;
    String mode;
    String format;
    var force = false;

    // Command is just a sequence of keywords which specify which comments
    // to symbolize and which symbols to use.
    for (var keyword in command.split(' ').skip(1)) {
      switch (keyword) {
        case 'this':
          symbolizeThis = true;
          break;
        case 'x86':
        case 'arm':
        case 'arm64':
        case 'x64':
          arch = keyword;
          break;
        case 'debug':
        case 'profile':
        case 'release':
          mode = keyword;
          break;
        case 'internal':
          format = 'internal';
          break;
        case 'force':
          force = true;
          break;
        case 'ios':
          os = 'ios';
          break;
        default:
          // Check if this keyword is a link to an comment on this issue.
          var m = _commentLinkPattern.firstMatch(keyword);
          if (m != null) {
            if (m.namedGroup('issueNumber') == issueNumberStr) {
              worklist.add(m.namedGroup('ref'));
            }
            break;
          }

          // Check if this keyword is an engine hash.
          m = _engineHashPattern.firstMatch(keyword);
          if (m != null) {
            engineHash = m.namedGroup('sha');
            break;
          }

          m = _flutterHashOrVersionPattern.firstMatch(keyword);
          if (m != null) {
            flutterVersion = m.namedGroup('version');
            break;
          }
          break;
      }
    }

    return BotCommand(
      symbolizeThis: symbolizeThis,
      worklist: worklist,
      overrides: SymbolizationOverrides(
        arch: arch,
        engineHash: engineHash,
        flutterVersion: flutterVersion,
        mode: mode,
        os: os,
        force: force,
        format: format,
      ),
    );
  }

  /// Execute command contained in the given [commandComment] posted on the
  /// [issue] in the repository [repo].
  Future<void> executeCommand(
    RepositorySlug repo,
    Issue issue,
    IssueComment commandComment, {
    @required bool authorized,
  }) async {
    if (!authorized) {
      await github.issues.createComment(repo, issue.number, '''
@${commandComment.user.login} Sorry, only **public members of Flutter org** can trigger my services.

Check your privacy settings as described [here](https://docs.github.com/en/free-pro-team@latest/github/setting-up-and-managing-your-github-user-account/publicizing-or-hiding-organization-membership).
''');
      return;
    }

    final command = parseCommand(issue.number, commandComment.body);
    if (command == null) {
      return;
    }

    // Comments which potentially contain crashes by their id.
    Map<int, _Comment> worklist;
    if (command.shouldProcessAll) {
      worklist = await processAllComments(repo, issue);
    } else {
      worklist = {};
      if (command.symbolizeThis) {
        worklist[commandComment.id] = _Comment.fromComment(commandComment);
      }

      // Process worklist from the command and fetch comment bodies.
      for (var ref in command.worklist) {
        // ref has one of the following formats: issue-id or issuecomment-id
        final c = ref.split('-');
        final id = int.parse(c[1]);
        if (c[0] == 'issue') {
          worklist[issue.id] = _Comment.fromIssue(issue);
        } else {
          try {
            final comment = await github.issues.getComment(repo, id);
            worklist[comment.id] = _Comment.fromComment(comment);
          } catch (e) {
            // Ignore.
          }
        }
      }
    }

    // Process comments from the worklist.
    await symbolizeGiven(
        repo, issue, commandComment.user, worklist, command.overrides);
  }

  /// Find all comments on the [issue] which potentially contain crashes
  /// and were not previously symbolized by the bot.
  Future<Map<int, _Comment>> processAllComments(
      RepositorySlug repo, Issue issue) async {
    _log.info(
        'Requested to symbolize all comments on ${repo.fullName}#${issue.number}');

    // Dictionary of comments to symbolize by their id.
    final worklist = <int, _Comment>{};
    final alreadySymbolized = <int>{};

    // Collect all comments which might contain crashes in the worklist
    // and ids of already symbolized comments in the [alreadySymbolized] set.
    if (containsCrash(issue.body)) {
      worklist[issue.id] = _Comment.fromIssue(issue);
    }
    await for (var comment
        in github.issues.listCommentsByIssue(repo, issue.number)) {
      if (comment.user.login == Bot.account) {
        // From comments by the bot extract ids of already symbolized comments.
        // Bot adds it to its comments as a JSON encoded object within
        // HTML comment: <!-- {"symbolized": [id0, id1, ...]} -->
        final m = _botInfoPattern.firstMatch(comment.body);
        if (m != null) {
          final state = jsonDecode(m.namedGroup('json').trim());
          if (state is Map<String, dynamic> &&
              state.containsKey('symbolized')) {
            alreadySymbolized
                .addAll((state['symbolized'] as List<dynamic>).cast<int>());
          }
        }
      } else if (containsCrash(comment.body)) {
        worklist[comment.id] = _Comment.fromComment(comment);
      }
    }

    _log.info(
        'Found comments with crashes ${worklist.keys}, and already symbolized ${alreadySymbolized}');
    alreadySymbolized.forEach(worklist.remove);
    return worklist;
  }

  /// Symbolize crashes from all comments in the [worklist] using the given
  /// [overrides] and post response on the issue.
  Future<void> symbolizeGiven(
      RepositorySlug repo,
      Issue issue,
      User commandUser,
      Map<int, _Comment> worklist,
      SymbolizationOverrides overrides) async {
    _log.info('Symbolizing ${worklist.keys} with overrides {$overrides}');

    // Symbolize all collected comments.
    final symbolized = <int, SymbolizationResult>{};
    for (var comment in worklist.values) {
      final result =
          await symbolizer.symbolize(comment.body, overrides: overrides);
      if (result is SymbolizationResultError ||
          (result is SymbolizationResultOk && result.results.isNotEmpty)) {
        symbolized[comment.id] = result;
      }
    }

    if (symbolized.isEmpty) {
      await github.issues.createComment(repo, issue.number, '''
@${commandUser.login} No crash reports found. I used the following overrides
when looking for reports

```
$overrides
```

Note that I can only find native Android and iOS crash reports automatically,
you need to explicitly point me to crash reports in other supported formats.

If the crash report is embedded into a log and prefixed with additional
information I might not be able to automatically strip those prefixes.
Currently I only support `flutter run -v`, `adb logcat` and device lab logs.

See [my documentation](https://github.com/flutter-symbolizer-bot/flutter-symbolizer-bot/blob/main/README.md#commands) for more details on how to do that.
''');
      return;
    }

    // Post a comment containing all successfully symbolized crashes.
    await postResultComment(repo, issue, worklist, symbolized);
    await mailFailures(repo, issue, worklist, symbolized);
  }

  /// Post a comment on the issue commenting successfully symbolized crashes.
  void postResultComment(
      RepositorySlug repo,
      Issue issue,
      Map<int, _Comment> comments,
      Map<int, SymbolizationResult> symbolized) async {
    if (symbolized.isEmpty) {
      return;
    }

    final successes = symbolized.onlySuccesses;
    final failures = symbolized.onlyFailures;

    final buf = StringBuffer();
    for (var entry in successes.entries) {
      for (var result in entry.value.results) {
        buf.write('''
crash from ${comments[entry.key].url} symbolized using symbols for `${result.engineBuild.engineHash}` `${result.engineBuild.variant.os}-${result.engineBuild.variant.arch}-${result.engineBuild.variant.mode}`
```
${result.symbolized}
```
''');
        for (var note in result.notes) {
          buf.write('_(${noteMessage[note.kind]}');
          if ((note.message ?? '').isNotEmpty) {
            buf.write(': ');
            buf.write(note.message);
          }
          buf.write(')_');
        }
        buf.writeln();
      }
    }

    if (failures.isNotEmpty) {
      buf.writeln();
      // GitHub allows <details> HTML elements
      // https://developer.mozilla.org/en-US/docs/Web/HTML/Element/details
      buf.writeln('''
<details>
<summary>There were failures processing the request</summary>
''');

      void appendNote(SymbolizationNote note) {
        buf.write('* ${noteMessage[note.kind]}');
        if (note.message != null && note.message.isNotEmpty) {
          if (note.message.contains('\n')) {
            buf.writeln(':');
            buf.write('''
```
${note.message}
```'''
                .indentBy('    '));
          } else {
            buf.writeln(': `${note.message}`');
          }
        }
        buf.writeln('');
      }

      for (var entry in failures.entries) {
        entry.value.when(ok: (results) {
          for (var result in results) {
            buf.writeln('''
When processing ${comments[entry.key].url} I found crash

```
${result.crash}
```

but failed to symbolize it with the following notes:
''');
            result.notes.forEach(appendNote);
          }
        }, error: (note) {
          buf.writeln('''
When processing ${comments[entry.key].url} I encountered the following error:
''');
          appendNote(note);
        });
      }

      buf.writeln('''

See [my documentation](https://github.com/flutter-symbolizer-bot/flutter-symbolizer-bot/blob/main/README.md#commands) for more details.
</details>
''');
    }

    // Append information about symbolized comments to the bot's comment so that
    // we could skip them later.
    buf.writeln(
        '<!-- ${jsonEncode({'symbolized': successes.keys.toList()})} -->');

    if (dryRun) {
      print(buf);
    } else {
      await github.issues.createComment(repo, issue.number, buf.toString());
    }
  }

  /// Mail failures to the [failuresEmail] mail address.
  void mailFailures(
      RepositorySlug repo,
      Issue issue,
      Map<int, _Comment> comments,
      Map<int, SymbolizationResult> symbolized) async {
    if (failuresEmail == null) {
      return;
    }

    final failures = symbolized.onlyFailures;
    if (failures.isEmpty) {
      return;
    }

    final escape = const HtmlEscape().convert;

    final buf = StringBuffer();
    buf.write('''<p>Hello &#x1f44b;</p>
<p>I was asked to symbolize crashes from <a href="${issue.htmlUrl}">issue ${issue.number}</a>, but failed.</p>
''');
    for (var entry in failures.entries) {
      entry.value.when(ok: (results) {
        for (var result in results) {
          buf.writeln('''
<p>When processing <a href="${comments[entry.key].url}">comment</a>, I found crash</p>
<pre>${escape(result.crash.toString())}</pre>
<p>but failed with the following notes:</p>
''');
          for (var note in result.notes) {
            buf.writeln(
                '${noteMessage[note.kind]} <pre>${escape(note.message ?? '')}');
          }
        }
      }, error: (note) {
        buf.writeln('''
<p>When processing <a href="${comments[entry.key].url}">comment</a>, I failed with the following error:</p>
''');
        buf.writeln(
            '${noteMessage[note.kind]} <pre>${escape(note.message ?? '')}');
      });
    }

    if (dryRun) {
      print(buf);
    } else {
      await mailer.send(
        Email(
          [
            Personalization([Address(failuresEmail)])
          ],
          Address('noreply@dart.dev'),
          'symbolization errors for issue #${issue.number}',
          content: [Content('text/html', buf.toString())],
        ),
      );
    }
  }

  static final _botInfoPattern = RegExp(r'<!-- (?<json>.*) -->');
  static final _commentLinkPattern = RegExp(
      r'^https://github\.com/(?<fullName>[\-\w]+/[\-\w]+)/issues/(?<issueNumber>\d+)#(?<ref>issue(comment)?-\d+)$');
  static final _engineHashPattern = RegExp(r'^engine#(?<sha>[a-f0-9]+)$');
  static final _flutterHashOrVersionPattern =
      RegExp(r'^flutter#v?(?<version>[a-f0-9\.]+)$');
}

extension on BotCommand {
  /// [true] if the user requested to process all comments on the issue.
  bool get shouldProcessAll => !symbolizeThis && worklist.isEmpty;
}

/// Class that represents a comment on the issue.
///
/// GitHub API does not treat issue body itself as a comment hence
/// the need for separate wrapper.
class _Comment {
  final int id;
  final String url;
  final String body;

  _Comment(this.id, this.url, this.body);

  _Comment.fromComment(IssueComment comment)
      : this(comment.id, comment.htmlUrl, comment.body);

  _Comment.fromIssue(Issue issue)
      : this(issue.id, issue.commentLikeHtmlUrl, issue.body);
}

extension on Issue {
  String get commentLikeHtmlUrl => '$htmlUrl#issue-$id';
}

extension on Map<int, SymbolizationResult> {
  /// Filter multimap of symbolization results to get all successes.
  Map<int, SymbolizationResultOk> get onlySuccesses {
    return Map.fromEntries(entries
        .where((e) => e.value is SymbolizationResultOk)
        .map((e) => MapEntry(
            e.key,
            applyFilter(
                e.value as SymbolizationResultOk, (r) => r.symbolized != null)))
        .where((e) => e.value.results.isNotEmpty));
  }

  /// Filter multimap of symbolization results to get all failures.
  Map<int, SymbolizationResult> get onlyFailures {
    return Map.fromEntries(entries.map((e) {
      final result = e.value;
      return MapEntry(
          e.key,
          result is SymbolizationResultOk
              ? applyFilter(result, (r) => r.symbolized == null)
              : result);
    }).where((e) =>
        e.value is SymbolizationResultError ||
        (e.value as SymbolizationResultOk).results.isNotEmpty));
  }

  static SymbolizationResultOk applyFilter(SymbolizationResultOk result,
      bool Function(CrashSymbolizationResult) predicate) {
    return SymbolizationResultOk(
        results: result.results.where(predicate).toList());
  }
}

extension on String {
  String indentBy(String indent) => indent + split('\n').join('\n$indent');
}
