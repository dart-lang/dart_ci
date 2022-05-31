#!/usr/bin/env dart
// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Displays the log for a failing test on a given runner and build

import 'package:args/args.dart';

import 'package:dart_ci/src/get_log.dart';

void main(List<String> args) async {
  final parser = ArgParser();
  parser.addOption("builder",
      abbr: "b", defaultsTo: "any", help: "Fetch log from this builder");
  parser.addOption("build-number",
      abbr: "n",
      defaultsTo: "latest",
      help: "Fetch log from this build on the chosen builder");
  parser.addOption("test",
      abbr: "t",
      defaultsTo: "*",
      help: "Fetch log for this test on the chosen builder");
  parser.addOption("configuration",
      abbr: "c",
      defaultsTo: "*",
      help: "Limit logs to this configuration on the chosen builder");
  parser.addFlag("help", help: "Show the program usage.", negatable: false);

  final options = parser.parse(args);
  final builder = options["builder"] as String;
  var build = options["build-number"] as String;
  final configuration = options["configuration"] as String;
  final test = options["test"] as String;

  if (build == "latest") {
    if (builder != "any") {
      build = await getLatestBuildNumber(builder);
    } else if (configuration != "*") {
      build = await getLatestConfigurationBuildNumber(configuration);
    }
  }
  print(await getLog(builder, build, configuration, test));
}
