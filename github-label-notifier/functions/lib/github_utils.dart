// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Various utility methods for processing on GitHub events.
library github_label_notifier.github_utils;

import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

/// Computes the GitHub event signature for the given [body] using
/// `GITHUB_SECRET` environment variable as a key.
String signEvent(List<int> body) {
  final secret = Platform.environment['GITHUB_SECRET'];
  if (secret == null) {
    throw 'GITHUB_SECRET is missing';
  }
  final digest = Hmac(sha1, utf8.encode(secret)).convert(body);
  return 'sha1=$digest';
}

/// Validate that the given [body] and [signature] against `GITHUB_SECRET`
/// environment variable.
bool verifyEventSignature(dynamic body, String signature) {
  final expectedSignature = signEvent(utf8.encode(json.encode(body)));
  // Timing-safe compare
  final aUnits = signature.codeUnits;
  final bUnits = expectedSignature.codeUnits;
  var result = true;
  for (var i = 0; i < aUnits.length; i++) {
    if (aUnits[i] != bUnits[i]) result = false;
  }
  return result;
}

/// Validate that the given [body] and [signature] against `GITHUB_SECRET`
/// environment variable.
bool verifyEventSignatureRaw(List<int> body, String signature) {
  final expectedSignature = signEvent(body);
  // Timing-safe compare
  final aUnits = signature.codeUnits;
  final bUnits = expectedSignature.codeUnits;
  var result = true;
  for (var i = 0; i < aUnits.length; i++) {
    if (aUnits[i] != bUnits[i]) result = false;
  }
  return result;
}
