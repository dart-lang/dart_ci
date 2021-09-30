// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:baseline/options.dart';
import 'dart:convert';
import 'dart:io';

const _resultBase = 'gs://dart-test-results/builders';

/// Baselines a builder with the [options] and copies the results to the
/// [resultBase]. [resultBase] can be a URL or a path supported by `gsutil cp`.
Future<void> baseline(BaselineOptions options,
    [String resultBase = _resultBase]) async {
  List<Future> futures = [];
  for (var channel in options.channels) {
    if (channel != 'main') {
      futures.add(baselineBuilder(
          options.builders.map((b) => '$b-$channel').toList(),
          options.configs,
          options.dryRun,
          resultBase));
    } else {
      futures.add(baselineBuilder(
          options.builders, options.configs, options.dryRun, resultBase));
    }
  }
  await Future.wait(futures);
}

Future<void> baselineBuilder(List<String> builders, Map<String, String> configs,
    bool dryRun, String resultBase) async {
  var from = builders[0];
  var to = builders[1];
  var latest = await read('$resultBase/$from/latest');
  var results = await read('$resultBase/$from/$latest/results.json');
  var modifiedResults = StringBuffer();
  for (var json in LineSplitter.split(results).map(jsonDecode)) {
    json['build_number'] = 0;
    json['previous_build_number'] = 0;
    json['builder_name'] = to;
    var configuration = configs[json['configuration']];
    if (configuration == null) {
      throw Exception(
          "Missing configuration mapping for ${json['configuration']}");
    }
    json['configuration'] = configuration;
    json['flaky'] = false;
    json['previous_flaky'] = false;

    modifiedResults.writeln(jsonEncode(json));
    if (dryRun) break;
  }
  await write(
      '$resultBase/$to/0/results.json', modifiedResults.toString(), dryRun);
  await write('$resultBase/$to/latest', '0', dryRun);
}

Future<String> read(String url) {
  return run('gsutil.py', ['cp', url, '-']);
}

Future<String> write(String url, String stdin, bool dryRun) {
  return run('gsutil.py', ['cp', '-', url], stdin: stdin, dryRun: dryRun);
}

Future<String> run(String command, List<String> arguments,
    {String? stdin, bool dryRun = false}) async {
  print('Running $command $arguments...');
  if (dryRun) {
    if (stdin != null) {
      print('stdin:\n$stdin');
    }
    return '';
  }
  var process = await Process.start(command, arguments);
  if (stdin != null) {
    process.stdin.write(stdin);
    process.stdin.close();
  }
  var stdout = process.stdout.transform(utf8.decoder).join();
  var result = await process.exitCode;
  if (result != 0) {
    throw Exception('Failed to run $command $arguments: $result');
  }
  return await stdout;
}
