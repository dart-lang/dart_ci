import 'dart:convert';
import 'dart:io';

import 'package:logging/logging.dart';

void setupLogging() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((LogRecord record) {
    final entry = <String, dynamic>{
      'severity': _logLevelToGcpSeverity(record.level),
      'message': record.message,
    };

    if (record.loggerName.isNotEmpty) {
      entry['logger'] = record.loggerName;
    }

    if (record.error != null) {
      entry['@type'] =
          'type.googleapis.com/google.devtools.clouderrorreporting.v1beta1.ReportedErrorEvent';
      final errorMessage = record.error.toString();
      final stackTrace = record.stackTrace?.toString() ?? '';

      var fullMessage = record.message;
      if (errorMessage.isNotEmpty) {
        fullMessage += '\n$errorMessage';
      }
      if (stackTrace.isNotEmpty) {
        fullMessage += '\n$stackTrace';
      }
      entry['message'] = fullMessage.trim();
    }

    stdout.writeln(jsonEncode(entry));
  });
}

String _logLevelToGcpSeverity(Level level) {
  if (level >= Level.SHOUT) return 'EMERGENCY';
  if (level >= Level.SEVERE) return 'ERROR';
  if (level >= Level.WARNING) return 'WARNING';
  if (level >= Level.INFO) return 'INFO';
  if (level >= Level.CONFIG) return 'DEBUG';
  return 'DEFAULT';
}
