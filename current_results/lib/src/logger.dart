// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:logging/logging.dart';
import 'package:stack_trace/stack_trace.dart';

void setupLogging() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    final level = switch (record.level) {
      Level.SHOUT => 'EMERGENCY',
      Level.SEVERE => 'ERROR',
      Level.WARNING => 'WARNING',
      Level.INFO => 'INFO',
      Level.CONFIG => 'DEBUG',
      _ => 'DEFAULT',
    };

    var message = record.message;

    if (record.loggerName.isNotEmpty) {
      message = '${record.loggerName}: $message';
    }

    void addBlock(String header, String body) {
      body = body.replaceAll('\n', '\n    ');
      message = '$message\n\n$header:\n    $body';
    }

    final error = record.error;
    if (error != null) addBlock('Error', '$error');
    var stackTrace = record.stackTrace;
    if (stackTrace is Chain) {
      stackTrace = stackTrace.terse;
    }
    if (stackTrace != null) {
      addBlock('Stack', '$stackTrace');
    }

    // Truncated messages over 64kb
    if (message.length > 64 * 1024) {
      message =
          '${message.substring(0, 32 * 1024)}...\n[truncated due to size]\n...'
          '${message.substring(message.length - 16 * 1024)}';
    }

    print(
      jsonEncode({
        'severity': level,
        'message': message,
        'time': record.time.toUtc().toIso8601String(),
      }),
    );
  });
}
