// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:args/command_runner.dart';
import 'package:grpc/grpc.dart';

import 'package:current_results/src/generated/query.pbgrpc.dart';

void main(List<String> args) async {
  final runner =
      CommandRunner<void>(
          'client.dart',
          'Send gRPC requests to current results server',
        )
        ..addCommand(QueryCommand())
        ..addCommand(ListTestsCommand())
        ..addCommand(FetchCommand())
        ..argParser.addOption('host', help: 'current results server to query')
        ..argParser.addOption(
          'port',
          abbr: 'p',
          help: 'port of current results server',
        )
        ..argParser.addFlag('insecure', help: 'connect over insecure http');
  await runner.run(args);
}

abstract class GrpcCommand extends Command<void> {
  Future<void> runWithClient(QueryClient client);
  @override
  Future<void> run() async {
    final channel = ClientChannel(
      globalResults!['host'],
      port: int.parse(globalResults!['port']),
      options:
          globalResults!['insecure'] == true
              ? const ChannelOptions(credentials: ChannelCredentials.insecure())
              : const ChannelOptions(credentials: ChannelCredentials.secure()),
    );

    final client = QueryClient(channel);
    try {
      await runWithClient(client);
    } finally {
      await channel.shutdown();
    }
  }
}

class QueryCommand extends GrpcCommand {
  QueryCommand() {
    argParser.addOption(
      'filter',
      abbr: 'f',
      help:
          'test names, test name prefixes, and configurations, '
          'comma-separated, to fetch results for',
    );
    argParser.addOption(
      'limit',
      abbr: 'l',
      help: 'number of results to return',
    );
    argParser.addOption('page', help: 'page token returned from previous call');
  }
  @override
  String get name => 'getResults';
  @override
  String get description => 'Send a GetResults gRPC request to the server';

  @override
  Future<void> runWithClient(QueryClient client) async {
    final request = GetResultsRequest();
    request.filter = argResults!['filter'] ?? '';
    if (argResults!['limit'] != null) {
      request.pageSize = int.parse(argResults!['limit']);
    }
    if (argResults!['page'] != null) {
      request.pageToken = argResults!['page'];
    }

    final result = await client.getResults(request);
    print(jsonEncode(result.toProto3Json()));
  }
}

class ListTestsCommand extends GrpcCommand {
  ListTestsCommand() {
    argParser.addOption(
      'prefix',
      defaultsTo: '',
      help: 'test name prefix to fetch test names for',
    );
    argParser.addOption(
      'limit',
      defaultsTo: '0',
      help: 'number of test names starting with prefix to return',
    );
  }

  @override
  String get name => 'listTests';
  @override
  String get description => 'Send a ListTests gRPC request to the server';

  @override
  Future<void> runWithClient(QueryClient client) async {
    final query =
        ListTestsRequest()
          ..prefix = argResults!['prefix']
          ..limit = int.parse(argResults!['limit']);
    final result = await client.listTests(query);
    print(jsonEncode(result.toProto3Json()));
  }
}

class FetchCommand extends GrpcCommand {
  @override
  String get name => 'fetch';
  @override
  String get description => 'Send a Fetch gRPC request to the server';

  @override
  Future<void> runWithClient(QueryClient client) async {
    final result = await client.fetch(Empty());
    print(jsonEncode(result.toProto3Json()));
  }
}
