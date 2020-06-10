// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:args/args.dart';
import 'package:grpc/grpc.dart';

import 'package:current_results/src/generated/query.pbgrpc.dart';

void main(List<String> args) async {
  final results = parseArgs(args);

  final query = GetResultsRequest();
  query.names.addAll(results['name']);
  query.configurations.addAll(results['configuration']);

  final channel = ClientChannel(results['host'],
      port: int.parse(results['port']),
      options:
          const ChannelOptions(credentials: ChannelCredentials.insecure()));
  try {
    final result = await QueryClient(channel).getResults(query);
    print(result.toProto3Json());
  } finally {
    await channel.shutdown();
  }
}

ArgResults parseArgs(List<String> args) {
  final parser = ArgParser();
  parser.addMultiOption('name', abbr: 'n', help: 'Test to fetch results for');
  parser.addMultiOption('configuration',
      abbr: 'c', help: 'Configuration to fetch results for');
  parser.addOption('host', abbr: 'h', help: 'Current results server to query');
  parser.addOption('port', abbr: 'p', help: 'Port of current results server');
  return parser.parse(args);
}
