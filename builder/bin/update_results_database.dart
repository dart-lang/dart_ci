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

// TODO(karlklose): Convert to streaming
// Stream<Map> readChangedResults(File resultsFile) {
//   return resultsFile.openRead()
//     .transform(utf8.decoder)       // Decode bytes to UTF-8.
//     .transform(LineSplitter())
//     .map((line) => jsonDecode as Map)
//     .where((result) => result['changed']);
// }
Future<List<Map<String, dynamic>>> readChangedResults(File resultsFile) async {
  return (await resultsFile.readAsLines())
      .map((line) => jsonDecode(line) as Map<String, dynamic>)
      .where(isChangedResult)
      .toList();
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
  final project = options['project'] as String;
  // TODO(karlklose): remove this when switching to production.
  if (project != 'dart-ci-staging') throw 'Unuspported mode';
  final inputFile = fileOption(options, 'results');
  final results = await readChangedResults(inputFile);
  if (results.isNotEmpty) {
    final first = results.first;
    final String commit = first['commit_hash'];
    final String buildbucketID = options['buildbucket_id'];
    final String baseRevision = options['base_revision'];
    final commitCache = CommitsCache(firestore, client);
    final process = commit.startsWith('refs/changes')
        ? Tryjob(commit, buildbucketID, baseRevision, commitCache, firestore,
                client)
            .process
        : Build(commit, first, commitCache, firestore).process;
    await process(results);
  }
}

void main(List<String> arguments) async {
  final options = (ArgParser()
        ..addOption('project',
            abbr: 'p',
            defaultsTo: 'dart-ci-staging',
            allowed: ['dart-ci-staging'])
        ..addOption('results', abbr: 'r')
        ..addOption('buildbucket_id', abbr: 'i')
        ..addOption('base_revision', abbr: 'b'))
      .parse(arguments);

  final baseClient = http.Client();
  final client = await clientViaApplicationDefaultCredentials(
      scopes: ['https://www.googleapis.com/auth/cloud-platform'],
      baseClient: baseClient);
  final api = FirestoreApi(client);
  final firestore = FirestoreService(api, client);

  await processResults(options, client, firestore);

  baseClient.close();
}
