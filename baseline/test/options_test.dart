// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:baseline/options.dart';
import 'package:test/test.dart';

const _builders = ['-ba1,a2', '-tb'];

main() {
  for (var channels in [
    ['main'],
    ['dev', 'beta'],
    ['stable'],
  ]) {
    var arguments = ['-c${channels.join(',')}', ..._builders];
    test('channels: "$arguments"', () {
      var options = BaselineOptions(arguments);
      expect(options.channels, channels);
    });
  }

  test('builder-mapping', () {
    var options = BaselineOptions(_builders);
    expect(options.builders, ['a1', 'a2']);
    expect(options.target, 'b');
  });

  test('config-mapping', () {
    var options = BaselineOptions(['-mc:d,e:f', ..._builders]);
    expect(options.configs, {'c': 'd', 'e': 'f'});
  });

  test('suites', () {
    var options = BaselineOptions(['-ss1,s2', ..._builders]);
    expect(options.suites, {'s1', 's2'});
  });

  test('ignore-unmapped', () {
    var options = BaselineOptions(['-u', '-mc:d,e:f', ..._builders]);
    expect(options.ignoreUnmapped, true);
  });

  test('dry-run defaults to false', () {
    var options = BaselineOptions(_builders);
    expect(options.dryRun, false);
  });

  test('dry-run: true', () {
    var options = BaselineOptions(['-n', ..._builders]);
    expect(options.dryRun, true);
  });
}
