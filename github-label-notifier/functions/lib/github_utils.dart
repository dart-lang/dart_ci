// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Various utility methods for processing on GitHub events.
library github_label_notifier.github_utils;

import 'dart:convert';

import 'package:node_interop/buffer.dart';
import 'package:node_io/node_io.dart';

import 'package:github_label_notifier/node_crypto.dart';

/// Computes the GitHub event signature for the given [body] using
/// `GITHUB_SECRET` environment variable as a key.
String signEvent(dynamic body) {
  final secret = Platform.environment['GITHUB_SECRET'];
  if (secret == null) {
    throw 'GITHUB_SECRET is missing';
  }
  final bodyHmac =
      crypto.createHmac('sha1', secret).update(jsonEncode(body)).digest('hex');
  return 'sha1=${bodyHmac}';
}

/// Validate that the given [body] and [signature] against `GITHUB_SECRET`
/// environment variable.
bool verifyEventSignature(dynamic body, String signature) {
  final expectedSignature = signEvent(body);
  return signature.length == expectedSignature.length &&
      crypto.timingSafeEqual(
          Buffer.from(signature), Buffer.from(expectedSignature));
}
