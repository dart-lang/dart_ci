// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:baseline/options.dart';
import 'dart:convert';
import 'dart:io';

import 'package:pool/pool.dart';

const _resultBase = 'gs://dart-test-results/builders';

/// Baselines a builder with the [options] and copies the results to the
/// [resultBase]. [resultBase] can be a URL or a path supported by `gsutil cp`.
Future<void> baseline(BaselineOptions options,
    [String resultBase = _resultBase]) async {
  await Future.wait([
    for (final channel in options.channels)
      if (channel == 'main')
        baselineBuilder(options.builders, options.target, options.configs,
            options.dryRun, options.ignoreUnmapped, resultBase)
      else
        baselineBuilder(
            options.builders.map((b) => '$b-$channel').toList(),
            '${options.target}-$channel',
            options.configs,
            options.dryRun,
            options.ignoreUnmapped,
            resultBase)
  ]);
}

Future<void> baselineBuilder(
    List<String> builders,
    String target,
    Map<String, String> configs,
    bool dryRun,
    bool ignoreUnmapped,
    String resultBase) async {
  var resultsStream = Pool(4).forEach(builders, (builder) async {
    var latest = await read('$resultBase/$builder/latest');
    return await read('$resultBase/$builder/$latest/results.json');
  });
  var modifiedResults = StringBuffer();
  await for (var results in resultsStream) {
    for (var json in LineSplitter.split(results).map(jsonDecode)) {
      var configuration = configs[json['configuration']];
      if (configuration == null) {
        if (ignoreUnmapped) {
          continue;
        }
        throw Exception(
            "Missing configuration mapping for ${json['configuration']}");
      }
      json['configuration'] = configuration;
      json['build_number'] = 0;
      json['previous_build_number'] = 0;
      json['builder_name'] = target;
      json['flaky'] = false;
      json['previous_flaky'] = false;

      modifiedResults.writeln(jsonEncode(json));
      if (dryRun) break;
    }
  }
  await write(
      '$resultBase/$target/0/results.json', modifiedResults.toString(), dryRun);
  await write('$resultBase/$target/latest', '0', dryRun);
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
