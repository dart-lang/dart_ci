// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:baseline/options.dart';
import 'package:test/test.dart';

const _builders = '-ba:b';

main() {
  for (var channels in [
    ['main'],
    ['dev', 'beta'],
    ['stable'],
  ]) {
    var arguments = ['-c${channels.join(',')}', _builders];
    test('channels: "$arguments"', () {
      var options = BaselineOptions(arguments);
      expect(options.channels, channels);
    });
  }

  test('builder-mapping', () {
    var options = BaselineOptions([_builders]);
    expect(options.builders, ['a', 'b']);
  });

  test('config-mapping', () {
    var options = BaselineOptions(['-mc:d,e:f', _builders]);
    expect(options.configs, {'c': 'd', 'e': 'f'});
  });

  test('dry-run defaults to false', () {
    var options = BaselineOptions([_builders]);
    expect(options.dryRun, false);
  });

  test('dry-run: true', () {
    var options = BaselineOptions(['-n', _builders]);
    expect(options.dryRun, true);
  });
}