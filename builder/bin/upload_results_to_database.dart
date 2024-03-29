import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:builder/src/builder.dart';
import 'package:builder/src/commits_cache.dart';
import 'package:builder/src/firestore.dart';
import 'package:builder/src/result.dart';
import 'package:builder/src/status.dart';
import 'package:builder/src/tryjob.dart';
import 'package:googleapis/firestore/v1.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;

late BuildInfo buildInfo;

Future<List<Map<String, dynamic>>> readChangedResults(File resultsFile) async {
  final lines = (await resultsFile.readAsLines())
      .map((line) => jsonDecode(line)! as Map<String, dynamic>);
  if (lines.isEmpty) {
    print('Empty input results.json file');
    exit(1);
  }
  buildInfo = BuildInfo.fromResult(
      lines.first, {for (final line in lines) line[fConfiguration]});
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

Future<BuildStatus> processResults(options, client, firestore) async {
  final inputFile = fileOption(options, 'results');
  final results = await readChangedResults(inputFile);
  final String? buildbucketID = options['buildbucket_id'];
  final String? baseRevision = options['base_revision'];
  final commitCache = CommitsCache(firestore, client);
  if (buildInfo is TryBuildInfo) {
    return Tryjob(buildInfo as TryBuildInfo, buildbucketID!, baseRevision!,
            commitCache, firestore, client)
        .process(results);
  } else {
    return Build(buildInfo, commitCache, firestore).process(results);
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
        ..addOption('base_revision', abbr: 'b')
        ..addOption('status_file'))
      .parse(arguments);

  final baseClient = http.Client();
  final client = await clientViaApplicationDefaultCredentials(
      scopes: ['https://www.googleapis.com/auth/cloud-platform'],
      baseClient: baseClient);
  final api = FirestoreApi(client);
  final firestore = FirestoreService(api, client, project: options['project']);

  final status = await processResults(options, client, firestore);
  if (options['status_file'] != null) {
    await File(options['status_file']).writeAsString(status.toJson());
  }
  baseClient.close();
}
