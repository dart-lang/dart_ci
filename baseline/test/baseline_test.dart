// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:baseline/baseline.dart';
import 'package:baseline/options.dart';
import 'package:io/io.dart';
import 'package:test/test.dart';

final String builderResults =
    File('test/data/builder/42/results.json').readAsStringSync();
final String builderStableResults =
    File('test/data/builder-stable/12/results.json').readAsStringSync();

main() {
  test('run', () async {
    var out = await run('echo', ['hellø!']);
    expect(out, 'hellø!\n');
  });

  test('dry run', () async {
    var out = await run('does not exist', ['hellø!'], dryRun: true);
    expect(out, '');
  });

  test('run with stdin', () async {
    var out = await run('cat', [], stdin: 'hellø!');
    expect(out, 'hellø!');
  });

  test('run fails', () {
    expect(run('cat', ['--fail']), throwsException);
  });

  test('baseline missing config mapping throws', () {
    expect(
        baseline(
            BaselineOptions([
              '--builder-mapping=builder:new-builder',
              '--channel=main,stable',
              '--config-mapping=config2:new-config2',
              '--dry-run',
            ]),
            'test/data'),
        throwsException);
  });

  test('baseline dry-run', () async {
    await baselineTest([
      '--builder-mapping=builder:new-builder',
      '--channel=main,stable',
      '--config-mapping=config1:new-config1,config2:new-config2',
      '--dry-run',
    ], {
      'builder-stable/latest': '12',
      'builder-stable/12/results.json': builderStableResults,
      'builder/42/results.json': builderResults,
      'builder/latest': '42',
    });
  });

  test('baseline', () async {
    const newBuilderStableResults = '''
{"build_number":0,"previous_build_number":0,"builder_name":"new-builder-stable","configuration":"new-config1","test_name":"test1","result":"PASS","flaky":false,"previous_flaky":false}
{"build_number":0,"previous_build_number":0,"builder_name":"new-builder-stable","configuration":"new-config2","test_name":"test2","result":"FAIL","flaky":false,"previous_flaky":false}
''';
    const newBuilderResults = '''
{"build_number":0,"previous_build_number":0,"builder_name":"new-builder","configuration":"new-config1","test_name":"test1","result":"FAIL","flaky":false,"previous_flaky":false}
{"build_number":0,"previous_build_number":0,"builder_name":"new-builder","configuration":"new-config2","test_name":"test2","result":"PASS","flaky":false,"previous_flaky":false}
''';

    await baselineTest([
      '--builder-mapping=builder:new-builder',
      '--channel=main,stable',
      '--config-mapping=config1:new-config1,config2:new-config2',
    ], {
      'builder-stable/latest': '12',
      'builder-stable/12/results.json': builderStableResults,
      'new-builder-stable/0/results.json': newBuilderStableResults,
      'new-builder-stable/latest': '0',
      'new-builder/0/results.json': newBuilderResults,
      'new-builder/latest': '0',
      'builder/42/results.json': builderResults,
      'builder/latest': '42',
    });
  });
}

Future<void> baselineTest(
    List<String> arguments, Map<String, String> expectedFiles) async {
  var temp = await Directory.systemTemp.createTemp();
  try {
    await copyPath('test/data', temp.path);
    await baseline(BaselineOptions(arguments), temp.path);
    var files = temp
        .listSync(recursive: true)
        .whereType<File>()
        .map((e) => e.path.substring(temp.path.length + 1));
    expect(files, containsAll(expectedFiles.keys));
    for (var expectedFile in expectedFiles.entries) {
      var content =
          await File('${temp.path}/${expectedFile.key}').readAsString();
      expect(content, expectedFile.value,
          reason: 'File "${expectedFile.key}" mismatch');
    }
  } finally {
    await temp.delete(recursive: true);
  }
}
