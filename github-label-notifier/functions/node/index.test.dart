// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:js_util';

import 'package:firebase_admin_interop/firebase_admin_interop.dart';
import 'package:js/js.dart';
import 'package:node_http/node_http.dart' as http_client;
import 'package:node_interop/http.dart' show http, HttpServer;
import 'package:node_interop/node_interop.dart';
import 'package:node_interop/util.dart' show dartify, jsify;
import 'package:node_io/node_io.dart' hide HttpServer;
import 'package:symbolizer/model.dart';
import 'package:test/test.dart';

import 'package:github_label_notifier/github_utils.dart';

// Note: must match project-id used in test.sh
final String projectId = 'github-label-notifier';

void main() async {
  if (!Platform.environment.containsKey('FIRESTORE_EMULATOR_HOST')) {
    throw 'This test must run in an emulated environment via test.sh script';
  }

  // Mock SendGrid server which simply records all requests it recieves.
  HttpServer sendgridMockServer;
  final sendgridRequests = <SendgridRequest>[];

  HttpServer symbolizerServer;
  final symbolizerCommands = <String>[];

  setUpAll(() async {
    // Populate firestore with mock data.
    final firestore = FirebaseAdmin.instance
        .initializeApp(AppOptions(projectId: projectId))
        .firestore();
    final subscriptions = firestore.collection('github-label-subscriptions');

    for (var doc in (await subscriptions.get()).documents) {
      await doc.reference.delete();
    }

    await subscriptions.add(DocumentData.fromMap({
      'email': 'first@example.com',
      'subscriptions': [
        'dart-lang/webhook-test:some-label',
        'dart-lang/webhook-test:feature',
      ],
    }));
    await subscriptions.add(DocumentData.fromMap({
      'email': 'second@example.com',
      'subscriptions': [
        'dart-lang/webhook-test:bug',
        'dart-lang/webhook-test:feature',
        'dart-lang/webhook-test:special-label',
      ],
    }));

    await firestore
        .document('github-keyword-subscriptions/dart-lang\$webhook-test')
        .setData(DocumentData.fromMap({
          'keywords': [
            'jit',
            'aot',
            'third_party/dart',
            'crash',
          ],
          'label': 'special-label',
        }));

    {
      // Start mock SendGrid server at the address/port specified in
      // SENDGRID_MOCK_SERVER environment variable.
      // This server will simply record headers and bodies of all requests
      // it receives in the [sendgridRequests] variable.
      sendgridMockServer = http.createServer(allowInterop((rq, rs) {
        final body = [];
        rq.on('data', allowInterop((chunk) {
          body.add(chunk);
        }));
        rq.on('end', allowInterop(() {
          sendgridRequests.add(SendgridRequest(
              headers: dartify(rq.headers),
              body: jsonDecode(_bufferToString(Buffer.concat(body)))));

          // Reply with 200 OK.
          rs.writeHead(200, 'OK', jsify({'Content-Type': 'text/plain'}));
          rs.write('OK');
          rs.end();
        }));
      }));

      final serverAddress = Platform.environment['SENDGRID_MOCK_SERVER'];
      if (serverAddress == null) {
        throw 'SENDGRID_MOCK_SERVER environment variable is not set';
      }
      final serverUri = Uri.parse('http://$serverAddress');
      sendgridMockServer.listen(serverUri.port, serverUri.host);
    }

    {
      // Start mock Symbolizer server at the address/port specified in
      // SYMBOLIZER_SERVER environment variable.
      symbolizerServer = http.createServer(allowInterop((rq, rs) {
        final body = [];
        rq.on('data', allowInterop((chunk) {
          body.add(chunk);
        }));
        rq.on('end', allowInterop(() {
          switch (Uri.parse(rq.url).path) {
            case '/symbolize':
              // Reply with symbolized crash.
              rs.writeHead(
                  200, 'OK', jsify({'Content-Type': 'application/json'}));
              SymbolizationResult result;
              final requestBody = _bufferToString(Buffer.concat(body));
              console.log(requestBody);
              if (requestBody.contains('TRIGGER_SYMBOLIZATION_ERROR')) {
                result = SymbolizationResult.error(
                  error: SymbolizationNote(
                      kind: SymbolizationNoteKind.exceptionWhileParsing,
                      message: 'some detailed error'),
                );
              } else {
                result = SymbolizationResult.ok(results: [
                  CrashSymbolizationResult(
                      crash: Crash(
                          engineVariant: EngineVariant(
                              arch: 'arm', os: 'ios', mode: 'debug'),
                          format: 'native',
                          frames: [
                            CrashFrame.ios(
                              no: '00',
                              binary: 'BINARY',
                              pc: 0x10042,
                              symbol: '0x',
                              offset: 42,
                              location: '',
                            )
                          ]),
                      engineBuild: EngineBuild(
                        engineHash: 'aaabbb',
                        variant: EngineVariant(
                            arch: 'arm', os: 'ios', mode: 'debug'),
                      ),
                      symbolized: 'SYMBOLIZED_STACK_HERE')
                ]);
              }
              rs.write(jsonEncode(result));
              rs.end();
              break;
            case '/command':
              symbolizerCommands.add(
                  jsonDecode(_bufferToString(Buffer.concat(body)))['comment']
                      ['body']);

              // Reply with 200 OK.
              rs.writeHead(200, 'OK', jsify({'Content-Type': 'text/plain'}));
              rs.write('OK');
              rs.end();
              break;
            default:
              // Reply with 404.
              rs.writeHead(
                  404, 'Not Found', jsify({'Content-Type': 'text/plain'}));
              rs.write('Not Found');
              rs.end();
              break;
          }
        }));
      }));

      final serverAddress = Platform.environment['SYMBOLIZER_SERVER'];
      if (serverAddress == null) {
        throw 'SENDGRID_MOCK_SERVER environment variable is not set';
      }
      final serverUri = Uri.parse('http://$serverAddress');
      symbolizerServer.listen(serverUri.port, serverUri.host);
    }
  });

  setUp(() {
    sendgridRequests.clear();
    symbolizerCommands.clear();
  });

  tearDownAll(() async {
    // Shutdown the mock SendGrid server.
    await sendgridMockServer.close();

    // Shutdown the mock symbolizer.
    await symbolizerServer.close();
  });

  // Helper to send a mock GitHub event to the locally running instance of the
  // webhook.
  Future<http_client.Response> sendEvent({
    String delivery = '7e754400-fa9b-11e9-9421-bb996f50ac6b',
    String event = 'issues',
    String signature,
    Map<String, dynamic> body,
  }) async {
    final headers = {
      'content-type': 'application/json',
    };

    if (delivery != null) {
      headers['X-GitHub-Delivery'] = delivery;
    }

    if (event != null) {
      headers['X-GitHub-Event'] = event;
    }

    final encodedBody = jsonEncode(body);
    if (signature != '') {
      headers['X-Hub-Signature'] = signature ?? signEvent(encodedBody);
    }

    // Note: there does not seem to be a good way to get a trigger uri for
    // a function when running the test suite.
    return await http_client.post(
        'http://localhost:5001/$projectId/us-central1/githubWebhook',
        headers: headers,
        body: encodedBody);
  }

  // Create mock event body.
  Map<String, dynamic> makeLabeledEvent(
          {String labelName = 'bug', int number = 1}) =>
      {
        'action': 'labeled',
        'issue': {
          'html_url':
              'https://github.com/dart-lang/webhook-test/issues/${number}',
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
              'https://github.com/dart-lang/webhook-test/issues/${number}',
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

  Map<String, dynamic> makeIssueCommentEvent(
          {int number = 1,
          String repositoryName = 'dart-lang/webhook-test',
          String issueBody =
              'This is an amazing ../third_party/dart/runtime/vm solution',
          String commentBody = 'comment body goes here',
          String authorAssociation = 'NONE'}) =>
      {
        'action': 'created',
        'issue': {
          'html_url':
              'https://github.com/dart-lang/webhook-test/issues/${number}',
          'number': number,
          'title': 'TEST ISSUE TITLE',
          'body': issueBody,
          'user': {
            'login': 'hest',
            'html_url': 'https://github.com/hest',
          },
        },
        'comment': {
          'body': commentBody,
          'author_association': authorAssociation,
        },
        'repository': {
          'full_name': 'dart-lang/webhook-test',
        },
      };

  test('signing', () {
    expect(signEvent(jsonEncode(makeLabeledEvent(labelName: 'bug'))),
        equals('sha1=76af51cdb9c7a43b146d4df721ac8f83e53182e5'));
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

    final rq = sendgridRequests.first;
    expect(rq.headers['authorization'],
        equals('Bearer ' + Platform.environment['SENDGRID_SECRET']));
    expect(rq.body['subject'], contains('bug'));
    expect(rq.body['subject'], contains('#1'));
    expect(rq.body['subject'], contains('TEST ISSUE TITLE'));
    expect(
        rq.body['personalizations'],
        unorderedEquals([
          {
            'to': [
              {'email': 'second@example.com'}
            ]
          }
        ]));
  });

  test('ok - multiple subscribers', () async {
    final rs = await sendEvent(
        body: makeLabeledEvent(labelName: 'feature', number: 2));
    expect(rs.statusCode, equals(HttpStatus.ok));
    expect(sendgridRequests.length, equals(1));

    final rq = sendgridRequests.first;
    expect(rq.headers['authorization'],
        equals('Bearer ' + Platform.environment['SENDGRID_SECRET']));
    expect(rq.body['subject'], contains('feature'));
    expect(rq.body['subject'], contains('#2'));
    expect(rq.body['subject'], contains('TEST ISSUE TITLE'));
    expect(
        rq.body['personalizations'],
        unorderedEquals([
          {
            'to': [
              {'email': 'second@example.com'}
            ]
          },
          {
            'to': [
              {'email': 'first@example.com'}
            ]
          }
        ]));
  });

  test('ok - issue opened', () async {
    final rs = await sendEvent(body: makeIssueOpenedEvent());
    expect(rs.statusCode, equals(HttpStatus.ok));
    expect(sendgridRequests.length, equals(1));

    final rq = sendgridRequests.first;
    expect(rq.headers['authorization'],
        equals('Bearer ' + Platform.environment['SENDGRID_SECRET']));
    expect(rq.body['subject'], contains('#1'));
    expect(rq.body['subject'], contains('TEST ISSUE TITLE'));
    expect(
        rq.body['personalizations'],
        unorderedEquals([
          {
            'to': [
              {'email': 'second@example.com'}
            ]
          }
        ]));
    expect(
        rq.body['content']
            .firstWhere((c) => c['type'] == 'text/plain')['value'],
        contains('Matches keyword: third_party/dart'));
  });

  test('ok - issue opened - test underscore as word boundary', () async {
    final rs = await sendEvent(
        body: makeIssueOpenedEvent(
            body: 'xyz, something_jit_something_else, foobar'));
    expect(rs.statusCode, equals(HttpStatus.ok));
    expect(sendgridRequests.length, equals(1));

    final rq = sendgridRequests.first;
    expect(rq.headers['authorization'],
        equals('Bearer ' + Platform.environment['SENDGRID_SECRET']));
    expect(rq.body['subject'], contains('#1'));
    expect(rq.body['subject'], contains('TEST ISSUE TITLE'));
    expect(
        rq.body['personalizations'],
        unorderedEquals([
          {
            'to': [
              {'email': 'second@example.com'}
            ]
          }
        ]));
    expect(
        rq.body['content']
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
    final rq = sendgridRequests.first;
    final plainTextBody = rq.body['content']
        .firstWhere((c) => c['type'] == 'text/plain')['value'];
    expect(plainTextBody, contains('engine aaabbb ios-arm-debug crash'));
    expect(plainTextBody, contains('SYMBOLIZED_STACK_HERE'));
  });

  test('ok - issue opened - crash - error during symbolization', () async {
    final rs = await sendEvent(body: makeIssueOpenedEvent(body: '''
I had Flutter engine c_r_a_s_h on me with the following message

*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***
Such c_r_a_s_h
Much information
TRIGGER_SYMBOLIZATION_ERROR
'''));
    expect(rs.statusCode, equals(HttpStatus.ok));
    expect(sendgridRequests.length, equals(0));
  });

  test('ok - issue comment - forward bot command', () async {
    final command = '''@flutter-symbolizer-bot aaa bbb''';
    final rs = await sendEvent(
        event: 'issue_comment',
        body: makeIssueCommentEvent(
          commentBody: command,
          authorAssociation: 'MEMBER',
        ));
    expect(rs.statusCode, equals(HttpStatus.ok));
    expect(symbolizerCommands, equals([command]));
  });
}

/// Helper method to convert a [Buffer] to a [String].
///
/// Just calling [Buffer.toString] invokes the wrong method
/// (see https://dartbug.com/30096).
String _bufferToString(Buffer buf) {
  return callMethod(buf, 'toString', []);
}

/// Request that arrived to the mock SendGrid server.
class SendgridRequest {
  final Map<String, dynamic> headers;
  final Map<String, dynamic> body;

  SendgridRequest({this.headers, this.body});

  Map<String, dynamic> toJson() => {'headers': headers, 'body': body};
}
