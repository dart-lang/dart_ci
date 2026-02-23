// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:baseline/options.dart';
import 'package:test/test.dart';

const _builders = ['-ba1,a2', '-tb'];

void main() {
  for (var channels in [
    ['main'],
    ['dev', 'beta'],
    ['stable'],
  ]) {
    var arguments = ['-c${channels.join(',')}', ..._builders];
    test('channels: "$arguments"', () {
      var options = BaselineOptions.parse(arguments);
      expect(options.channels, channels);
    });
  }

  test('builder-mapping', () {
    var options = BaselineOptions.parse(_builders);
    expect(options.builders, ['a1', 'a2']);
    expect(options.target, 'b');
  });

  test('builder-mapping: default to target', () {
    var options = BaselineOptions.parse(['-tb']);
    expect(options.builders, ['b']);
  });

  test('config-mapping', () {
    var options = BaselineOptions.parse(['-mc:d,e:f', ..._builders]);
    expect(options.configs, {
      'c': ['d'],
      'e': ['f']
    });
    expect(options.mapping, ConfigurationMapping.strict);
  });

  test('config-mapping-multiple', () {
    var options = BaselineOptions.parse(['-ma:b,a:c', ..._builders]);
    expect(options.configs, {
      'a': ['b', 'c']
    });
    expect(options.mapping, ConfigurationMapping.strict);
  });

  test('config-mapping: star', () {
    var options = BaselineOptions.parse(['-m*', ..._builders]);
    expect(options.configs, const {});
    expect(options.mapping, ConfigurationMapping.none);
  });

  test('config-mapping: ignore-unmapped', () {
    var options = BaselineOptions.parse(['-u', '-mc:d,e:f', ..._builders]);
    expect(options.mapping, ConfigurationMapping.relaxed);
  });

  test('suites', () {
    var options = BaselineOptions.parse(['-ss1,s2', ..._builders]);
    expect(options.suites, {'s1', 's2'});
  });

  test('dry-run defaults to false', () {
    var options = BaselineOptions.parse(_builders);
    expect(options.dryRun, false);
  });

  test('dry-run: true', () {
    var options = BaselineOptions.parse(['-n', ..._builders]);
    expect(options.dryRun, true);
  });

  test('mapping: strict', () {
    expect(
        ConfigurationMapping.strict('foo', {
          'foo': ['bar']
        }),
        ['bar']);
    expect(
        () => ConfigurationMapping.strict('oof', {
              'foo': ['bar']
            }),
        throwsException);
  });

  test('mapping: relaxed', () {
    expect(
        ConfigurationMapping.relaxed('foo', {
          'foo': ['bar']
        }),
        ['bar']);
    expect(
        ConfigurationMapping.relaxed('oof', {
          'foo': ['bar']
        }),
        null);
  });

  test('mapping: none', () {
    expect(
        ConfigurationMapping.none('foo', {
          'foo': ['bar']
        }),
        ['foo']);
    expect(
        ConfigurationMapping.none('oof', {
          'foo': ['bar']
        }),
        ['oof']);
  });
}
