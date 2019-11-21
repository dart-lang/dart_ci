// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
import 'dart:convert';

import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:node_interop/node_interop.dart';
import 'package:node_io/node_io.dart';

import 'package:github_label_notifier/github_utils.dart';
import 'package:github_label_notifier/sendgrid.dart' as sendgrid;
import 'package:github_label_notifier/subscriptions_db.dart' as db;

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
  if (!verifyEventSignature(body, signature)) {
    throw WebHookError(
        HttpStatus.unauthorized, 'Failed to validate the signature');
  }

  // Event has passed the validation. Dispatch it to the handler.
  print('Received event from GitHub: $delivery $event');
  await eventHandlers[event]?.call(body);

  request.response.statusCode = HttpStatus.ok;
  request.response.writeln('OK: ${event}');
}

typedef Future<void> GitHubEventHandler(Map<String, dynamic> event);

final eventHandlers = <String, GitHubEventHandler>{
  'issues': (event) => issueActionHandlers[event['action']]?.call(event),
};

final issueActionHandlers = <String, GitHubEventHandler>{
  'labeled': onLabeled,
};

/// Handler for the 'labeled' issue event which triggers whenever an
/// issue is labeled with a new label.
///
/// The handler will send mails to all users that subscribed to a
/// particular label.
Future<void> onLabeled(Map<String, dynamic> event) async {
  final labelName = event['label']['name'];
  final repositoryName = event['repository']['full_name'];

  final emails = await db.lookupSubscriberEmails(repositoryName, labelName);
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
''',
      html: '''
<p><strong><a href="${issueUrl}">${escape(issueTitle)}</a>&nbsp;(${escape(repositoryName)}#${escape(issueNumber)})</strong></p>
<p>Reported by <a href="${issueReporterUrl}">${escape(issueReporterUsername)}</a></p>
<p>Labeled <strong>${escape(labelName)}</strong> by <a href="${senderUrl}">${escape(senderUser)}</a></p>
''');
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
