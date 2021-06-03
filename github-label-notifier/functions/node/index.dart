// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:js/js_util.dart';
import 'package:node_interop/node_interop.dart';
import 'package:node_io/node_io.dart';
import 'package:node_http/node_http.dart' as http;

import 'package:github_label_notifier/github_utils.dart';
import 'package:github_label_notifier/sendgrid.dart' as sendgrid;
import 'package:github_label_notifier/subscriptions_db.dart' as db;
import 'package:symbolizer/model.dart';
import 'package:symbolizer/parser.dart';
import 'package:symbolizer/bot.dart';

final String symbolizerServer = Platform.environment['SYMBOLIZER_SERVER'] ??
    'crash-symbolizer.c.dart-ci.internal:4040';

extension on ExpressHttpRequest {
  Uint8List get rawBody {
    if (!hasProperty(nativeInstance, 'rawBody')) return null;
    return getProperty(nativeInstance, 'rawBody');
  }
}

void main() {
  db.ensureInitialized();
  functions['githubWebhook'] = functions.https.onRequest((request) async {
    try {
      await githubWebhook(request);
    } catch (e, stack) {
      try {
        request.response.statusCode =
            e is WebHookError ? e.statusCode : HttpStatus.internalServerError;
      } catch (e) {
        console.error('Failed to set statusCode: ${e}');
      }
      console.error('Caught exception: ${e}\n${stack}');
      request.response.write('FAILURE');
    } finally {
      await request.response.close();
    }
  });
}

/// Entry point for a [GitHub WebHook](https://developer.github.com/webhooks/).
///
/// Actual handlers are defined in [eventHandlers] dictionary.
Future<void> githubWebhook(ExpressHttpRequest request) async {
  // First we need to validate that this is a request originating from GitHub
  // by checking if it has all required header values and is properly signed.
  if (request.method != 'POST') {
    throw WebHookError(
        HttpStatus.methodNotAllowed, 'Expected to be called via POST method');
  }

  if (request.body == null) {
    throw WebHookError(HttpStatus.badRequest, 'Request is missing a body');
  }

  final signature = getRequiredHeaderValue(request, 'x-hub-signature');
  final event = getRequiredHeaderValue(request, 'x-github-event');
  final delivery = getRequiredHeaderValue(request, 'x-github-delivery');

  final body = request.body;
  if (!verifyEventSignatureRaw(request.rawBody, signature)) {
    throw WebHookError(
        HttpStatus.unauthorized, 'Failed to validate the signature');
  }

  // Event has passed the validation. Dispatch it to the handler.
  print('Received event from GitHub: $delivery $event ${body['action']}');
  await eventHandlers[event]?.call(body);

  request.response.statusCode = HttpStatus.ok;
  request.response.writeln('OK: ${event}');
}

typedef GitHubEventHandler = Future<void> Function(Map<String, dynamic> event);

final eventHandlers = <String, GitHubEventHandler>{
  'issues': (event) => issueActionHandlers[event['action']]?.call(event),
  'issue_comment': (event) =>
      commentActionHandlers[event['action']]?.call(event)
};

final issueActionHandlers = <String, GitHubEventHandler>{
  'labeled': onIssueLabeled,
  'opened': onIssueOpened,
};

final commentActionHandlers = <String, GitHubEventHandler>{
  'created': onIssueCommentCreated,
};

/// Handler for the 'labeled' issue event which triggers whenever an
/// issue is labeled with a new label.
///
/// The handler will send mails to all users that subscribed to a
/// particular label.
Future<void> onIssueLabeled(Map<String, dynamic> event) async {
  final labelName = event['label']['name'];
  final repositoryName = event['repository']['full_name'];

  final emails =
      await db.lookupLabelSubscriberEmails(repositoryName, labelName);
  if (emails.isEmpty) {
    return;
  }

  final issueData = event['issue'];

  final issueTitle = issueData['title'];
  final issueNumber = issueData['number'];
  final issueUrl = issueData['html_url'];
  final issueReporterUsername = issueData['user']['login'];
  final issueReporterUrl = issueData['user']['html_url'];
  final senderUser = event['sender']['login'];
  final senderUrl = event['sender']['html_url'];

  final escape = htmlEscape.convert;

  await sendgrid.sendMultiple(
      from: 'noreply@dart.dev',
      to: emails,
      subject: '[+${labelName}] ${issueTitle} (#${issueNumber})',
      text: '''
${issueUrl}

Reported by ${issueReporterUsername}

Labeled ${labelName} by ${senderUser}

--
Sent by dart-github-label-notifier.web.app
''',
      html: '''
<p>${escape(issueTitle)}&nbsp;(<a href="${issueUrl}">${escape(repositoryName)}#${escape(issueNumber.toString())}</a>)</p>
<p>Reported by <a href="${issueReporterUrl}">${escape(issueReporterUsername)}</a></p>
<p>Labeled <strong>${escape(labelName)}</strong> by <a href="${senderUrl}">${escape(senderUser)}</a></p>
<hr>
<p>Sent by <a href="https://dart-github-label-notifier.web.app/">GitHub Label Notifier</a></p>
''');
}

/// Handler for the 'opened' issue event which triggers whenever a new issue
/// is opened at the repository.
///
/// The handler will search the body of the open issue for specific keywords
/// and send emails to all subscribers to a specific label.
Future<void> onIssueOpened(Map<String, dynamic> event) async {
  final symbolizedCrashes = <SymbolizationResult>[];

  final repositoryName = event['repository']['full_name'];
  final subscription = await db.lookupKeywordSubscription(repositoryName);

  if (subscription != null &&
      subscription.keywords.contains('crash') &&
      containsCrash(event['issue']['body'])) {
    symbolizedCrashes.addAll(await _trySymbolize(event['issue']));
  }

  final match = symbolizedCrashes.isNotEmpty
      ? 'crash'
      : subscription?.match(event['issue']['body']);
  if (match == null) {
    return;
  }

  final subscribers =
      await db.lookupLabelSubscriberEmails(repositoryName, subscription.label);

  final issueData = event['issue'];

  final issueTitle = issueData['title'];
  final issueNumber = issueData['number'];
  final issueUrl = issueData['html_url'];
  final issueReporterUsername = issueData['user']['login'];
  final issueReporterUrl = issueData['user']['html_url'];

  final escape = htmlEscape.convert;

  var symbolizedCrashesText = '', symbolizedCrashesHtml = '';
  if (symbolizedCrashes.isNotEmpty) {
    symbolizedCrashesText = [
      '',
      ...symbolizedCrashes.expand((r) => [
            if (r.symbolized != null)
              '# engine ${r.engineBuild.engineHash} ${r.engineBuild.variant.pretty} crash'
            else
              '# engine crash',
            for (var note in r.notes)
              if (note.message != null)
                '# ${noteMessage[note.kind]}: ${note.message}'
              else
                '# ${noteMessage[note.kind]}',
            r.symbolized ?? r.crash.frames.toString(),
          ]),
      ''
    ].join('\n');
    symbolizedCrashesHtml = symbolizedCrashes
        .expand((r) => [
              if (r.symbolized != null)
                '<p>engine ${r.engineBuild.engineHash} ${r.engineBuild.variant.pretty} crash</p>'
              else
                '<p>engine crash</p>',
              for (var note in r.notes)
                if (note.message != null)
                  '<em>${noteMessage[note.kind]}: <pre>${escape(note.message)}</pre></em>'
                else
                  '<em>${noteMessage[note.kind]}</em>',
              '<pre>${escape(r.symbolized ?? r.crash.frames.toString())}</pre>',
            ])
        .join('');
  }

  await sendgrid.sendMultiple(
      from: 'noreply@dart.dev',
      to: subscribers,
      subject: '[$repositoryName] ${issueTitle} (#${issueNumber})',
      text: '''
${issueUrl}

Reported by ${issueReporterUsername}

Matches keyword: ${match}
${symbolizedCrashesText}
You are getting this mail because you are subscribed to label ${subscription.label}.
--
Sent by dart-github-label-notifier.web.app
''',
      html: '''
<p><strong><a href="${issueUrl}">${escape(issueTitle)}</a>&nbsp;(${escape(repositoryName)}#${escape(issueNumber.toString())})</strong></p>
<p>Reported by <a href="${issueReporterUrl}">${escape(issueReporterUsername)}</a></p>
<p>Matches keyword: <b>${match}</b></p>
${symbolizedCrashesHtml}
<p>You are getting this mail because you are subscribed to label ${subscription.label}</p>
<hr>
<p>Sent by <a href="https://dart-github-label-notifier.web.app/">GitHub Label Notifier</a></p>
''');
}

Future<void> onIssueCommentCreated(Map<String, dynamic> event) async {
  final body = event['comment']['body'];

  if (Bot.isCommand(body)) {
    final response = await http.post(
      'http://$symbolizerServer/command',
      body: jsonEncode(event),
    );
    if (response.statusCode != HttpStatus.ok) {
      throw WebHookError(HttpStatus.internalServerError,
          'Failed to process ${event['comment']['html_url']}: ${response.body}');
    }
  }
}

class WebHookError {
  final int statusCode;
  final String message;

  WebHookError(this.statusCode, this.message);

  @override
  String toString() => 'Error: $message';
}

/// Helper which gets a value of the header with the given name from a
/// request or throws an error if request does not contain such a header.
String getRequiredHeaderValue(ExpressHttpRequest request, String header) {
  return request.headers.value(header) ??
      (throw WebHookError(
          HttpStatus.badRequest, 'Missing ${header} header value.'));
}

Future<List<SymbolizationResult>> _trySymbolize(
    Map<String, dynamic> body) async {
  try {
    final response = await http
        .post(
          'http://$symbolizerServer/symbolize',
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 20));
    return [
      for (var crash in (jsonDecode(response.body) as List))
        SymbolizationResult.fromJson(crash)
    ];
  } catch (e, st) {
    console.error('Symbolizer failed with $e: $st');
    return [];
  }
}
