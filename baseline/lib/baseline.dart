// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:baseline/options.dart';
import 'dart:convert';
import 'dart:io';

import 'package:pool/pool.dart';
import 'package:google_cloud_storage/google_cloud_storage.dart';

const _resultBase = 'gs://dart-test-results';

/// Baselines a builder with the [options] and copies the results to the
/// [resultBase]. [resultBase] can be a GCS URL (gs://...) or a local path.
Future<void> baseline(
  BaselineOptions options, [
  String resultBase = _resultBase,
]) async {
  final FileStore store = resultBase.startsWith('gs://')
      ? GcsFileStore(Storage())
      : LocalFileStore();
  await Future.wait([
    for (final channel in options.channels)
      if (channel == 'main')
        // baseline a new builder on main
        // builder,builder2 -> new-builder
        baselineBuilder(
          store,
          options.builders,
          channel,
          options.suites,
          options.target,
          options.configs,
          options.dryRun,
          options.mapping,
          resultBase,
        )
      else if (options.builders.contains(options.target))
        // baseline a builder on a channel with main builder data
        // builder,builder2 -> builder-dev
        baselineBuilder(
          store,
          options.builders,
          channel,
          options.suites,
          '${options.target}-$channel',
          options.configs,
          options.dryRun,
          options.mapping,
          resultBase,
        )
      else
        // baseline a builder on a channel with channel builder data
        // builder-dev,builder2-dev -> new-builder-dev
        baselineBuilder(
          store,
          options.builders.map((b) => '$b-$channel').toList(),
          channel,
          options.suites,
          '${options.target}-$channel',
          options.configs,
          options.dryRun,
          options.mapping,
          resultBase,
        ),
  ]);
}

Future<void> baselineBuilder(
  FileStore store,
  List<String> builders,
  String channel,
  Set<String> suites,
  String target,
  Map<String, List<String>> configs,
  bool dryRun,
  ConfigurationMapping mapping,
  String resultBase,
) async {
  var resultsStream = Pool(4).forEach(builders, (builder) async {
    var latest = await store.read('$resultBase/builders/$builder/latest');
    return await store.read(
      '$resultBase/builders/$builder/$latest/results.json',
    );
  });
  var modifiedResults = StringBuffer();
  var modifiedResultsPerConfig = <String, StringBuffer>{};
  await for (var results in resultsStream) {
    for (var json in LineSplitter.split(
      results,
    ).map(jsonDecode).cast<Map<String, dynamic>>()) {
      var configurations = mapping(json['configuration'], configs);
      if (configurations == null) {
        continue;
      }
      for (var configuration in configurations) {
        if (suites.isNotEmpty && !suites.contains(json['suite'])) continue;
        json['configuration'] = configuration;
        json['build_number'] = '0';
        json['previous_build_number'] = '0';
        json['builder_name'] = target;
        json['flaky'] = false;
        json['previous_flaky'] = false;

        var encoded = jsonEncode(json);
        modifiedResults.writeln(encoded);
        modifiedResultsPerConfig
            .putIfAbsent(configuration, () => StringBuffer())
            .writeln(encoded);
      }
      if (dryRun) break;
    }
  }
  await store.write(
    '$resultBase/builders/$target/0/results.json',
    modifiedResults.toString(),
    dryRun,
  );
  for (var entry in modifiedResultsPerConfig.entries) {
    await store.write(
      '$resultBase/configuration/$channel/${entry.key}/0/results.json',
      entry.value.toString(),
      dryRun,
    );
  }
  await store.write('$resultBase/builders/$target/latest', '0', dryRun);
}

abstract class FileStore {
  Future<String> read(String path);
  Future<void> write(String path, String content, bool dryRun);
}

class GcsFileStore implements FileStore {
  final Storage _storage;
  GcsFileStore(this._storage);

  (String, String) _parseGsUrl(String url) {
    final uri = Uri.parse(url);
    if (uri.scheme != 'gs') {
      throw ArgumentError('Invalid scheme: ${uri.scheme}, expected gs://');
    }
    final object = uri.path.startsWith('/') ? uri.path.substring(1) : uri.path;
    return (uri.host, object);
  }

  @override
  Future<String> read(String path) async {
    final (bucket, object) = _parseGsUrl(path);
    final bytes = await _storage.bucket(bucket).object(object).download();
    return utf8.decode(bytes);
  }

  @override
  Future<void> write(String path, String content, bool dryRun) async {
    print('Writing to $path...');
    if (dryRun) {
      print('stdin:\n$content');
      return;
    }
    final (bucket, object) = _parseGsUrl(path);
    await _storage.bucket(bucket).object(object).uploadAsString(content);
  }
}

class LocalFileStore implements FileStore {
  @override
  Future<String> read(String path) {
    return File(path).readAsString();
  }

  @override
  Future<void> write(String path, String content, bool dryRun) async {
    print('Writing to $path...');
    if (dryRun) {
      print('stdin:\n$content');
      return;
    }
    final file = File(path);
    await file.parent.create(recursive: true);
    await file.writeAsString(content);
  }
}

Future<String> run(
  String command,
  List<String> arguments, {
  String? stdin,
  bool dryRun = false,
}) async {
  print('Running $command $arguments...');
  if (dryRun) {
    if (stdin != null) {
      print('stdin:\n$stdin');
    }
    return '';
  }
  var process = await Process.start(command, arguments);
  process.stderr.transform(utf8.decoder).forEach(print);
  if (stdin != null) {
    process.stdin.write(stdin);
    await process.stdin.flush();
    process.stdin.close();
  }
  var stdout = process.stdout.transform(utf8.decoder).join();
  var result = await process.exitCode;
  if (result != 0) {
    throw Exception('Failed to run $command $arguments: $result');
  }
  return await stdout;
}
