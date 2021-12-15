// @dart = 2.9

import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:builder/src/builder.dart';
import 'package:builder/src/commits_cache.dart';
import 'package:builder/src/firestore.dart';
import 'package:builder/src/result.dart';
import 'package:builder/src/tryjob.dart';
import 'package:googleapis/firestore/v1.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;

BuildInfo buildInfo;

Future<List<Map<String, dynamic>>> readChangedResults(File resultsFile) async {
  final lines = (await resultsFile.readAsLines())
      .map((line) => jsonDecode(line) /*!*/ as Map<String, dynamic>);
  if (lines.isEmpty) {
    print('Empty input results.json file');
    exit(1);
  }
  buildInfo = BuildInfo.fromResult(lines.first);
  return lines.where(isChangedResult).toList();
}

File fileOption(options, String name) {
  final path = options[name];
  if (path == null) {
    print("Required option '$name'!");
    exit(1);
  }
  final file = File(path);
  if (!file.existsSync()) {
    print('File not found: "$path"');
    exit(1);
  }
  return file;
}

Future<void> processResults(options, client, firestore) async {
  final inputFile = fileOption(options, 'results');
  final results = await readChangedResults(inputFile);
  final String buildbucketID = options['buildbucket_id'];
  final String baseRevision = options['base_revision'];
  final commitCache = CommitsCache(firestore, client);
  if (buildInfo is TryBuildInfo) {
    await Tryjob(buildInfo, buildbucketID, baseRevision, commitCache, firestore,
            client)
        .process(results);
  } else {
    await Build(buildInfo, commitCache, firestore).process(results);
  }
}

void main(List<String> arguments) async {
  final options = (ArgParser()
        ..addOption('project',
            abbr: 'p',
            defaultsTo: 'dart-ci-staging',
            allowed: ['dart-ci-staging', 'dart-ci'])
        ..addOption('results', abbr: 'r')
        ..addOption('buildbucket_id', abbr: 'i')
        ..addOption('base_revision', abbr: 'b'))
      .parse(arguments);

  final baseClient = http.Client();
  final client = await clientViaApplicationDefaultCredentials(
      scopes: ['https://www.googleapis.com/auth/cloud-platform'],
      baseClient: baseClient);
  final api = FirestoreApi(client);
  final firestore = FirestoreService(api, client, project: options['project']);

  await processResults(options, client, firestore);

  baseClient.close();
}
