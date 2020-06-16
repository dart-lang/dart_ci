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
    ..addCommand(FetchCommand())
    ..argParser.addOption('host', help: 'Current results server to query')
    ..argParser
        .addOption('port', abbr: 'p', help: 'Port of current results server');
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
    argParser.addMultiOption('name',
        abbr: 'n', help: 'Test name or prefix to fetch results for');
    argParser.addMultiOption('configuration',
        abbr: 'c', help: 'Configuration to fetch results for');
  }
  String get name => 'getResults';
  String get description => 'Send a GetResults gRPC request to the server';

  Future<void> runWithChannel(ClientChannel channel) async {
    final request = GetResultsRequest();
    request.names.addAll(argResults['name']);
    request.configurations.addAll(argResults['configuration']);
    final result = await QueryClient(channel).getResults(request);
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
