// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:googleapis/firestore/v1.dart';
import 'package:sendgrid_mailer/sendgrid_mailer.dart';
import 'package:test/test.dart';

import 'package:github_label_notifier/firestore_helpers.dart';
import 'package:github_label_notifier/github_utils.dart';
import 'package:github_label_notifier/subscriptions_db.dart';

import '../bin/server.dart' as server_lib;

// Note: must match project-id used in test.sh
final projectId = 'github-label-notifier';

void createGithubLabelNotifier() {
  server_lib.main();
}

Future<HttpServer> createSendgridMockServer(
    List<SendgridRequest> requestLog) async {
  // Start mock SendGrid server at the address/port specified in
  // SENDGRID_MOCK_SERVER environment variable.
  // This server will simply record headers and bodies of all requests
  // it receives in the [sendgridRequests] variable.
  final serverAddress = Platform.environment['SENDGRID_MOCK_SERVER'];
  if (serverAddress == null) {
    throw 'SENDGRID_MOCK_SERVER environment variable is not set';
  }
  final serverUri = Uri.parse('http://$serverAddress');
  final server = await HttpServer.bind(serverUri.host, serverUri.port);
  server.listen((request) async {
    final body = await utf8.decoder.fuse(json.decoder).bind(request).single;
    requestLog.add(SendgridRequest(
        headers: request.headers, body: body as Map<String, dynamic>));
    print(
        'Sendgrid request received by mock server ${requestLog.last.toJson()}');

    // Reply with 200 OK.
    await (request.response
          ..statusCode = HttpStatus.ok
          ..reasonPhrase = 'OK'
          ..headers.contentType = ContentType.text
          ..write('OK'))
        .close();
  });
  return server;
}

void main() async {
  if (!Platform.environment.containsKey('FIRESTORE_EMULATOR_HOST')) {
    throw 'This test must run in an emulated environment via test.sh script';
  }

  // Mock SendGrid server which simply records all requests it receives.
  late HttpServer sendgridMockServer;
  final sendgridRequests = <SendgridRequest>[];

  late int notifierPort;

  final client = HttpClient();

  setUpAll(() async {
    notifierPort = int.parse(Platform.environment['PORT'] ?? '8080');
    // Populate firestore with mock data.
    await ensureInitialized;
    final firestore = firestoreApi;
    final documentsApi = firestore.projects.databases.documents;

    final documentList = await documentsApi
        .list(documents, 'github-label-subscriptions', mask_fieldPaths: []);
    final deletes = [
      for (final document in documentList.documents ?? [])
        Write(delete: document.name)
    ];
    if (deletes.isNotEmpty) {
      await documentsApi.batchWrite(
          BatchWriteRequest(writes: deletes), documents);
    }

    await documentsApi.createDocument(
        Document(
            fields: taggedMap({
          'email': 'first@example.com',
          'subscriptions': [
            'dart-lang/webhook-test:some-label',
            'dart-lang/webhook-test:feature',
          ],
        })),
        documents,
        labelCollection);

    await documentsApi.createDocument(
        Document(
            fields: taggedMap({
          'email': 'second@example.com',
          'subscriptions': [
            'dart-lang/webhook-test:bug',
            'dart-lang/webhook-test:feature',
            'dart-lang/webhook-test:special-label',
          ],
        })),
        documents,
        labelCollection);

    await documentsApi.patch(
        Document(
            fields: taggedMap({
          'keywords': [
            'jit',
            'aot',
            'third_party/dart',
            'crash',
          ],
          'label': 'special-label',
        })),
        '$keywordDatabase/dart-lang\$webhook-test');

    sendgridMockServer = await createSendgridMockServer(sendgridRequests);
    createGithubLabelNotifier();
  });

  setUp(() {
    sendgridRequests.clear();
  });

  tearDownAll(() async {
    // Shutdown the mock SendGrid server.
    await sendgridMockServer.close();
  });

  // Helper to send a mock GitHub event to the locally running instance of the
  // webhook.
  Future<HttpClientResponse> sendEvent({
    String? delivery = '7e754400-fa9b-11e9-9421-bb996f50ac6b',
    String? event = 'issues',
    String? signature,
    required Map<String, dynamic> body,
  }) async {
    final request =
        await client.post('localhost', notifierPort, 'githubWebhook');
    request.headers.add('content-type', 'application/json');
    if (delivery != null) {
      request.headers.add('X-GitHub-Delivery', delivery);
    }

    if (event != null) {
      request.headers.add('X-GitHub-Event', event);
    }

    final encodedBody = jsonEncode(body);
    if (signature != '') {
      request.headers.add(
          'X-Hub-Signature', signature ?? signEvent(utf8.encode(encodedBody)));
    }
    request.write(encodedBody);
    return request.close();
  }

  // Create mock event body.
  Map<String, dynamic> makeLabeledEvent(
          {String labelName = 'bug', int number = 1}) =>
      {
        'action': 'labeled',
        'issue': {
          'html_url':
              'https://github.com/dart-lang/webhook-test/issues/$number',
          'number': number,
          'title': 'TEST ISSUE TITLE',
          'user': {
            'login': 'hest',
            'html_url': 'https://github.com/hest',
          },
        },
        'label': {
          'name': labelName,
        },
        'repository': {
          'full_name': 'dart-lang/webhook-test',
        },
        'sender': {
          'login': 'fisk',
          'html_url': 'https://github.com/fisk',
        }
      };

  Map<String, dynamic> makeIssueOpenedEvent(
          {int number = 1,
          String repositoryName = 'dart-lang/webhook-test',
          String body =
              'This is an amazing ../third_party/dart/runtime/vm solution'}) =>
      {
        'action': 'opened',
        'issue': {
          'html_url':
              'https://github.com/dart-lang/webhook-test/issues/$number',
          'number': number,
          'title': 'TEST ISSUE TITLE',
          'body': body,
          'user': {
            'login': 'hest',
            'html_url': 'https://github.com/hest',
          },
        },
        'repository': {
          'full_name': 'dart-lang/webhook-test',
        },
      };

  test('signing', () {
    expect(
        signEvent(utf8.encode(jsonEncode(makeLabeledEvent(labelName: 'bug')))),
        equals('sha1=2a997eeaf8fda3069018e00b03ca105c875f365b'));
  });

  test('reject malformed request - no delivery', () async {
    final rs = await sendEvent(body: {}, delivery: null);
    expect(rs.statusCode, equals(HttpStatus.badRequest));
    expect(sendgridRequests, isEmpty);
  });

  test('reject malformed request - no event', () async {
    final rs = await sendEvent(body: {}, event: null);
    expect(rs.statusCode, equals(HttpStatus.badRequest));
    expect(sendgridRequests, isEmpty);
  });

  test('reject malformed request - no signature', () async {
    final rs = await sendEvent(
        body: makeLabeledEvent(labelName: 'bug'), signature: '');
    expect(rs.statusCode, equals(HttpStatus.badRequest));
    expect(sendgridRequests, isEmpty);
  });

  test('reject incorrectly signed request', () async {
    final rs = await sendEvent(
        body: makeLabeledEvent(labelName: 'bug'),
        signature: 'sha1=76af51cdb9c7a43b246d4df721ac8f83e53182e5');
    expect(rs.statusCode, equals(HttpStatus.unauthorized));
    expect(sendgridRequests, isEmpty);
  });

  test('ok - ignore wrong event', () async {
    final rs = await sendEvent(
        body: makeLabeledEvent(labelName: 'bug'), event: 'wrong-type');
    expect(rs.statusCode, equals(HttpStatus.ok));
    expect(sendgridRequests, isEmpty);
  });

  test('ok - ignore wrong action', () async {
    final rs = await sendEvent(body: {'action': 'deleted'});
    expect(rs.statusCode, equals(HttpStatus.ok));
    expect(sendgridRequests, isEmpty);
  });

  test('ok - no subscribers', () async {
    final rs =
        await sendEvent(body: makeLabeledEvent(labelName: 'performance'));
    expect(rs.statusCode, equals(HttpStatus.ok));
    expect(sendgridRequests, isEmpty);
  });

  test('ok - single subscriber', () async {
    final rs = await sendEvent(body: makeLabeledEvent(labelName: 'bug'));
    expect(rs.statusCode, equals(HttpStatus.ok));
    expect(sendgridRequests.length, equals(1));

    final request = sendgridRequests.first;
    expect(request.headers['authorization']!.single,
        equals('Bearer ${Platform.environment['SENDGRID_SECRET']!}'));
    expect(request.body['subject'], contains('bug'));
    expect(request.body['subject'], contains('#1'));
    expect(request.body['subject'], contains('TEST ISSUE TITLE'));
    expect(request.body['personalizations'].single,
        emailAsPersonalization('second@example.com'));
  });

  test('ok - multiple subscribers', () async {
    final rs = await sendEvent(
        body: makeLabeledEvent(labelName: 'feature', number: 2));
    expect(rs.statusCode, equals(HttpStatus.ok));
    expect(sendgridRequests.length, equals(1));

    final request = sendgridRequests.first;
    expect(request.headers['authorization'],
        contains('Bearer ${Platform.environment['SENDGRID_SECRET']!}'));
    expect(request.body['subject'], contains('feature'));
    expect(request.body['subject'], contains('#2'));
    expect(request.body['subject'], contains('TEST ISSUE TITLE'));
    expect(
        request.body['personalizations'],
        unorderedEquals([
          emailAsPersonalization('second@example.com'),
          emailAsPersonalization('first@example.com')
        ]));
  });

  test('ok - issue opened', () async {
    final rs = await sendEvent(body: makeIssueOpenedEvent());
    expect(rs.statusCode, equals(HttpStatus.ok));
    expect(sendgridRequests.length, equals(1));

    final request = sendgridRequests.first;
    expect(request.headers['authorization'],
        contains('Bearer ${Platform.environment['SENDGRID_SECRET']!}'));
    expect(request.body['subject'], contains('#1'));
    expect(request.body['subject'], contains('TEST ISSUE TITLE'));
    expect(request.body['personalizations'].single,
        emailAsPersonalization('second@example.com'));
    expect(
        request.body['content']
            .firstWhere((c) => c['type'] == 'text/plain')['value'],
        contains('Matches keyword: third_party/dart'));
  });

  test('ok - issue opened - test underscore as word boundary', () async {
    final rs = await sendEvent(
        body: makeIssueOpenedEvent(
            body: 'xyz, something_jit_something_else, foobar'));
    expect(rs.statusCode, equals(HttpStatus.ok));
    expect(sendgridRequests.length, equals(1));

    final request = sendgridRequests.first;
    expect(request.headers['authorization']!.single,
        equals('Bearer ${Platform.environment['SENDGRID_SECRET']!}'));
    expect(request.body['subject'], contains('#1'));
    expect(request.body['subject'], contains('TEST ISSUE TITLE'));
    expect(request.body['personalizations'].single,
        emailAsPersonalization('second@example.com'));
    expect(
        request.body['content']
            .firstWhere((c) => c['type'] == 'text/plain')['value'],
        contains('Matches keyword: jit'));
  });

  test('ok - issue opened - no matching keyword', () async {
    final rs = await sendEvent(
        body: makeIssueOpenedEvent(
            body: 'xyz, somethingjitsomething_else, foobar'));
    expect(rs.statusCode, equals(HttpStatus.ok));
    expect(sendgridRequests.length, equals(0));
  });

  test('ok - issue opened - crash', () async {
    final rs = await sendEvent(body: makeIssueOpenedEvent(body: '''
I had Flutter engine c_r_a_s_h on me with the following message

*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***
Such c_r_a_s_h
Much information
'''));
    expect(rs.statusCode, equals(HttpStatus.ok));
    expect(sendgridRequests.length, equals(1));
    final request = sendgridRequests.first;
    expect(
        request.body['content']
            .firstWhere((c) => c['type'] == 'text/plain')['value'],
        contains('Matches keyword: crash'));
  });
}

/// Request that arrived to the mock SendGrid server.
class SendgridRequest {
  final HttpHeaders headers;
  final Map<String, dynamic> body;

  SendgridRequest({required this.headers, required this.body});

  Map<String, dynamic> toJson() => {'headers': headers, 'body': body};
}

Map<String, dynamic> emailAsPersonalization(String email) =>
    Personalization([Address(email)]).toJson();
