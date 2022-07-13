// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:baseline/baseline.dart';
import 'package:baseline/options.dart';
import 'package:io/io.dart';
import 'package:test/test.dart';

final builder1Results =
    _readTestData('test/data/builders/builder/42/results.json');
final builder2Results =
    _readTestData('test/data/builders/builder2/36/results.json');
final builderStableResults =
    _readTestData('test/data/builders/builder-stable/12/results.json');
final builder2StableResults =
    _readTestData('test/data/builders/builder2-stable/15/results.json');
final testData = {
  'builders/builder-stable/latest': ['12'],
  'builders/builder-stable/12/results.json': builderStableResults,
  'builders/builder/42/results.json': builder1Results,
  'builders/builder/latest': ['42'],
  'builders/builder2-stable/15/results.json': builder2StableResults,
  'builders/builder2-stable/latest': ['15'],
  'builders/builder2/36/results.json': builder2Results,
  'builders/builder2/latest': ['36'],
};

List<String> _readTestData(String path) {
  return LineSplitter.split(File(path).readAsStringSync()).toList();
}

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
              '--builders=builder,builder2',
              '--target=new-builder',
              '--channel=main,stable',
              '--config-mapping=config2:new-config2',
              '--dry-run',
            ]),
            'test/data'),
        throwsException);
  });

  test('baseline ignored config mapping dry-run', () async {
    await baselineTest([
      '--builders=builder,builder2',
      '--target=new-builder',
      '--channel=main,stable',
      '--config-mapping=config2:new-config2',
      '--dry-run',
      '--ignore-unmapped',
    ], testData);
  });

  test('baseline ignored config mapping', () async {
    final newBuilderStableResults = [
      '{"build_number":"0","previous_build_number":"0","builder_name":"new-builder-stable","configuration":"new-config2","test_name":"test2","result":"FAIL","flaky":false,"previous_flaky":false}'
    ];
    final newBuilderResults = [
      '{"build_number":"0","previous_build_number":"0","builder_name":"new-builder","configuration":"new-config2","test_name":"test2","result":"PASS","flaky":false,"previous_flaky":false}'
    ];
    await baselineTest([
      '--builders=builder,builder2',
      '--target=new-builder',
      '--channel=main,stable',
      '--config-mapping=config2:new-config2',
      '--ignore-unmapped',
    ], {
      'builders/new-builder-stable/0/results.json': newBuilderStableResults,
      'builders/new-builder-stable/latest': ['0'],
      'builders/new-builder/0/results.json': newBuilderResults,
      'builders/new-builder/latest': ['0'],
      'configuration/main/new-config2/0/results.json': newBuilderResults,
      'configuration/stable/new-config2/0/results.json':
          newBuilderStableResults,
      ...testData,
    });
  });

  test('baseline dry-run', () async {
    await baselineTest([
      '--builders=builder,builder2',
      '--target=new-builder',
      '--channel=main,stable',
      '--config-mapping=config1:new-config1,config2:new-config2,'
          'config3:new-config3,config4:new-config4',
      '--dry-run',
    ], testData);
  });

  test('baseline', () async {
    final newBuilderStableResults = [
      '{"build_number":"0","previous_build_number":"0","builder_name":"new-builder-stable","configuration":"new-config1","test_name":"test1","result":"PASS","flaky":false,"previous_flaky":false}',
      '{"build_number":"0","previous_build_number":"0","builder_name":"new-builder-stable","configuration":"new-config2","test_name":"test2","result":"FAIL","flaky":false,"previous_flaky":false}',
      '{"build_number":"0","previous_build_number":"0","builder_name":"new-builder-stable","configuration":"new-config3","test_name":"test1","result":"PASS","flaky":false,"previous_flaky":false}',
      '{"build_number":"0","previous_build_number":"0","builder_name":"new-builder-stable","configuration":"new-config4","test_name":"test2","result":"FAIL","flaky":false,"previous_flaky":false}',
    ];
    final newBuilderResults = [
      '{"build_number":"0","previous_build_number":"0","builder_name":"new-builder","configuration":"new-config1","test_name":"test1","result":"FAIL","flaky":false,"previous_flaky":false}',
      '{"build_number":"0","previous_build_number":"0","builder_name":"new-builder","configuration":"new-config2","test_name":"test2","result":"PASS","flaky":false,"previous_flaky":false}',
      '{"build_number":"0","previous_build_number":"0","builder_name":"new-builder","configuration":"new-config3","test_name":"test1","result":"FAIL","flaky":false,"previous_flaky":false}',
      '{"build_number":"0","previous_build_number":"0","builder_name":"new-builder","configuration":"new-config4","test_name":"test2","result":"PASS","flaky":false,"previous_flaky":false}',
    ];

    await baselineTest([
      '--builders=builder,builder2',
      '--target=new-builder',
      '--channel=main,stable',
      '--config-mapping=config1:new-config1,config2:new-config2,'
          'config3:new-config3,config4:new-config4',
    ], {
      'builders/new-builder-stable/0/results.json':
          unorderedEquals(newBuilderStableResults),
      'builders/new-builder-stable/latest': ['0'],
      'builders/new-builder/0/results.json': unorderedEquals(newBuilderResults),
      'builders/new-builder/latest': ['0'],
      'configuration/main/new-config1/0/results.json': [newBuilderResults[0]],
      'configuration/main/new-config2/0/results.json': [newBuilderResults[1]],
      'configuration/main/new-config3/0/results.json': [newBuilderResults[2]],
      'configuration/main/new-config4/0/results.json': [newBuilderResults[3]],
      'configuration/stable/new-config1/0/results.json': [
        newBuilderStableResults[0]
      ],
      'configuration/stable/new-config2/0/results.json': [
        newBuilderStableResults[1]
      ],
      'configuration/stable/new-config3/0/results.json': [
        newBuilderStableResults[2]
      ],
      'configuration/stable/new-config4/0/results.json': [
        newBuilderStableResults[3]
      ],
      ...testData,
    });
  });
}

Future<void> baselineTest(
    List<String> arguments, Map<String, dynamic> expectedFiles) async {
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
      var content = LineSplitter.split(
          await File('${temp.path}/${expectedFile.key}').readAsString());
      expect(content, expectedFile.value,
          reason: 'File "${expectedFile.key}" mismatch');
    }
  } finally {
    await temp.delete(recursive: true);
  }
}
