// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
import 'dart:convert';
import 'dart:io';

import 'package:async/async.dart' show Result;
import 'package:http/http.dart' as http;
import 'package:gcp/gcp.dart';
import 'package:sendgrid_mailer/sendgrid_mailer.dart' as sendgrid;
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import 'package:github_label_notifier/github_utils.dart';
import 'package:github_label_notifier/redirecting_http.dart';
import 'package:github_label_notifier/subscriptions_db.dart' as db;

final String symbolizerServer = Platform.environment['SYMBOLIZER_SERVER'] ??
    'crash-symbolizer.c.dart-ci.internal:4040';
late final sendgrid.Mailer mailer;
late final Future<Result<void>> Function(sendgrid.Email) sendMail;

// To enable offline testing we redirect all requests to our mock server.
final mockServer = Platform.environment['SENDGRID_MOCK_SERVER'];
final mockUrl = 'http://$mockServer';

Future<void> main() async {
  await db.ensureInitialized;
  mailer = sendgrid.Mailer(Platform.environment['SENDGRID_SECRET']!);
  final mockSendgridServer = Platform.environment['SENDGRID_MOCK_SERVER'];
  if (mockSendgridServer == null) {
    sendMail = mailer.send;
  } else {
    final host = mockSendgridServer.split(':').first;
    final port = int.parse(mockSendgridServer.split(':').last);
    sendMail =
        (sendgrid.Email email) => http.runWithClient<Future<Result<void>>>(() {
              return mailer.send(email);
            }, () => RedirectingIOClient(host, port));
  }
  final router = Router()..post('/githubWebhook', wrappedGithubWebhook);
  await serveHandler(router);
}

/// If githubWebHook throws a WebHookError, this function prints it
/// to stdout and responds with an appropriate HTTP error response.
Future<Response> wrappedGithubWebhook(Request request) async {
  try {
    return await githubWebhook(request);
  } catch (e, st) {
    print('Caught exception: $e\n$st');
    final statusCode =
        e is WebHookError ? e.statusCode : HttpStatus.internalServerError;
    final response = Response(statusCode, body: 'FAILURE');
    return response;
  }
}

/// Entry point for a [GitHub WebHook](https://developer.github.com/webhooks/).
///
/// Actual handlers are defined in [eventHandlers] dictionary.
Future<Response> githubWebhook(Request request) async {
  // First we need to validate that this is a request originating from GitHub
  // by checking if it has all required header values and is properly signed.
  if (request.method != 'POST') {
    throw WebHookError(
        HttpStatus.methodNotAllowed, 'Expected to be called via POST method');
  }
  final rawBody = await request
      .read()
      .fold<List<int>>([], (body, chunk) => body..addAll(chunk));
  final signature = getRequiredHeaderValue(request, 'x-hub-signature');
  final event = getRequiredHeaderValue(request, 'x-github-event');
  final delivery = getRequiredHeaderValue(request, 'x-github-delivery');

  if (!verifyEventSignatureRaw(rawBody, signature)) {
    throw WebHookError(
        HttpStatus.unauthorized, 'Failed to validate the signature');
  }

  final body = json.decode(utf8.decode(rawBody));
  // Event has passed the validation. Dispatch it to the handler.
  print('Received event from GitHub: $delivery $event ${body['action']}');
  await eventHandlers[event]?.call(body);

  return Response(HttpStatus.ok, body: 'OK: $event');
}

typedef GitHubEventHandler = Future<void> Function(Map<String, dynamic> event);

final eventHandlers = <String, GitHubEventHandler>{
  'issues': (event) async => issueActionHandlers[event['action']]?.call(event),
  'issue_comment': (event) async =>
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
  print("label repository: $labelName $repositoryName");
  final emails =
      await db.lookupLabelSubscriberEmails(repositoryName, labelName);
  print("emails $emails");
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

  final personalizations = [
    for (final to in emails) sendgrid.Personalization([sendgrid.Address(to)])
  ];
  final subject = '[+$labelName] $issueTitle (#$issueNumber)';
  final text = '''
$issueUrl

Reported by $issueReporterUsername

Labeled $labelName by $senderUser

--
Sent by dart-github-label-notifier.web.app
''';
  final html = '''
<p>${escape(issueTitle)}&nbsp;(<a href="$issueUrl">${escape(repositoryName)}#${escape(issueNumber.toString())}</a>)</p>
<p>Reported by <a href="$issueReporterUrl">${escape(issueReporterUsername)}</a></p>
<p>Labeled <strong>${escape(labelName)}</strong> by <a href="$senderUrl">${escape(senderUser)}</a></p>
<hr>
<p>Sent by <a href="https://dart-github-label-notifier.web.app/">GitHub Label Notifier</a></p>
''';
  final email = sendgrid.Email(
    personalizations,
    sendgrid.Address('noreply@dart.dev'),
    subject,
    content: [
      sendgrid.Content('text/plain', text),
      sendgrid.Content('text/html', html)
    ],
  );

  final result = await sendMail(email);
  if (result.isError) {
    print(result.asError!.error);
    print(result.asError!.stackTrace);
  }
}

/// Handler for the 'opened' issue event which triggers whenever a new issue
/// is opened at the repository.
///
/// The handler will search the body of the open issue for specific keywords
/// and send emails to all subscribers to a specific label.
Future<void> onIssueOpened(Map<String, dynamic> event) async {
  final repositoryName = event['repository']['full_name'];
  print("opened issue $repositoryName");
  final subscription = await db.lookupKeywordSubscription(repositoryName);
  if (subscription == null) return;

  final match = (subscription.keywords.contains('crash') &&
          _containsCrash(event['issue']['body']))
      ? 'crash'
      : subscription.match(event['issue']['body']);
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

  final personalizations = [
    for (final to in subscribers)
      sendgrid.Personalization([sendgrid.Address(to)])
  ];
  final result = await sendMail(sendgrid.Email(
      personalizations,
      sendgrid.Address('noreply@dart.dev'),
      '[$repositoryName] $issueTitle (#$issueNumber)',
      content: [
        sendgrid.Content('text/plain', '''
$issueUrl

Reported by $issueReporterUsername

Matches keyword: $match

You are getting this mail because you are subscribed to label ${subscription.label}.
--
Sent by dart-github-label-notifier.web.app
'''),
        sendgrid.Content('text/html', '''
<p><strong><a href="$issueUrl">${escape(issueTitle)}</a>&nbsp;(${escape(repositoryName)}#${escape(issueNumber.toString())})</strong></p>
<p>Reported by <a href="$issueReporterUrl">${escape(issueReporterUsername)}</a></p>
<p>Matches keyword: <b>$match</b></p>
<p>You are getting this mail because you are subscribed to label ${subscription.label}</p>
<hr>
<p>Sent by <a href="https://dart-github-label-notifier.web.app/">GitHub Label Notifier</a></p>
''')
      ]));
  if (result.isError) {
    print(result.asError!.error);
    print(result.asError!.stackTrace);
  }
}

Future<void> onIssueCommentCreated(Map<String, dynamic> event) async {
  // Do nothing.
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
String getRequiredHeaderValue(Request request, String header) {
  return request.headers[header] ??
      (throw WebHookError(
          HttpStatus.badRequest, 'Missing $header header value.'));
}

Future<http.Response> Function(Uri url,
    {Object? body,
    Encoding? encoding,
    Map<String, String>? headers}) redirectingHttpPost(String replacementHost) {
  return (Uri url,
      {Object? body, Encoding? encoding, Map<String, String>? headers}) {
    final newUrl = url.replace(scheme: 'http', host: replacementHost);
    return http.post(newUrl, body: body, encoding: encoding, headers: headers);
  };
}

final _androidCrashMarker =
    '*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***';

final _iosCrashMarker = RegExp(
    r'(Incident Identifier:\s+([A-F0-9]+-?)+)|(Exception Type:\s+EXC_CRASH)');

/// Returns [true] if the given text is likely to contain a crash.
bool _containsCrash(String text) {
  return text.contains(_androidCrashMarker) || text.contains(_iosCrashMarker);
}
