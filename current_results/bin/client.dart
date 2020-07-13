// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:args/command_runner.dart';
import 'package:grpc/grpc.dart';

import 'package:current_results/src/generated/google/protobuf/empty.pb.dart';
import 'package:current_results/src/generated/query.pbgrpc.dart';

void main(List<String> args) async {
  final runner = CommandRunner<void>(
      'client.dart', 'Send gRPC requests to current results server')
    ..addCommand(QueryCommand())
    ..addCommand(ListTestsCommand())
    ..addCommand(FetchCommand())
    ..argParser.addOption('host', help: 'current results server to query')
    ..argParser
        .addOption('port', abbr: 'p', help: 'port of current results server');
  await runner.run(args);
}

abstract class gRpcCommand extends Command {
  Future<void> runWithChannel(ClientChannel channel);
  Future<void> run() async {
    final channel = ClientChannel(globalResults['host'],
        port: int.parse(globalResults['port']),
        options:
            const ChannelOptions(credentials: ChannelCredentials.insecure()));
    try {
      await runWithChannel(channel);
    } finally {
      await channel.shutdown();
    }
  }
}

class QueryCommand extends gRpcCommand {
  QueryCommand() {
    argParser.addOption('filter',
        abbr: 'f',
        help: 'test names, test name prefixes, and configurations, '
            'comma-separated, to fetch results for');
    argParser.addOption('limit',
        abbr: 'l', help: 'number of results to return');
  }
  String get name => 'getResults';
  String get description => 'Send a GetResults gRPC request to the server';

  Future<void> runWithChannel(ClientChannel channel) async {
    final request = GetResultsRequest();
    request.filter = argResults['filter'] ?? '';
    if (argResults['limit'] != null) {
      request.pageSize = int.parse(argResults['limit']);
    }

    final result = await QueryClient(channel).getResults(request);
    print(result.toProto3Json());
  }
}

class ListTestsCommand extends gRpcCommand {
  ListTestsCommand() {
    argParser.addOption('prefix',
        defaultsTo: '', help: 'test name prefix to fetch test names for');
    argParser.addOption('limit',
        defaultsTo: '0',
        help: 'number of test names starting with prefix to return');
  }

  String get name => 'listTests';
  String get description => 'Send a ListTests gRPC request to the server';

  Future<void> runWithChannel(ClientChannel channel) async {
    final query = ListTestsRequest()
      ..prefix = argResults['prefix']
      ..limit = int.parse(argResults['limit']);
    final result = await QueryClient(channel).listTests(query);
    print(result.toProto3Json());
  }
}

class FetchCommand extends gRpcCommand {
  String get name => 'fetch';
  String get description => 'Send a Fetch gRPC request to the server';

  Future<void> runWithChannel(ClientChannel channel) async {
    final result = await QueryClient(channel).fetch(Empty());
    print(result.toProto3Json());
  }
}
