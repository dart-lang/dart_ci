// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Bindings for the @sendgrid/mail module.
@JS()
library github_label_notifier.sendgrid;

import 'package:js/js.dart';
import 'package:js/js_util.dart';
import 'package:node_interop/node.dart';
import 'package:node_interop/util.dart';
import 'package:node_io/node_io.dart';

final _SendgridModule _sendgrid = (() {
  // Load and configure the module.
  final _SendgridModule module = require('@sendgrid/mail');
  module.setApiKey(Platform.environment['SENDGRID_SECRET']);

  // To enable offline testing we redirect all requests to our mock server.
  final mockServer = Platform.environment['SENDGRID_MOCK_SERVER'];
  if (mockServer != null) {
    module.client.setDefaultRequest('baseUrl', 'http://$mockServer');
  }

  return module;
})();

/// Send the mail with the given [from], [subject], [text] and [html] content
/// to all recepients listed in [to].
///
/// Note: individual recepients would be unaware about other recepients.
Future<void> sendMultiple(
    {List<String> to, String from, String subject, String text, String html}) {
  return promiseToFuture(_sendgrid.sendMultiple(jsify({
    'to': to,
    'from': from,
    'subject': subject,
    'text': text,
    'html': html,
  })));
}

@JS()
@anonymous
abstract class _SendgridModule {
  external void setApiKey(String key);
  external _Client get client;
  external Promise sendMultiple(Object data);
}

@JS()
@anonymous
abstract class _Client {
  external void setDefaultRequest(String key, String value);
}
