// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:grpc/grpc.dart';

import 'package:current_results/src/bucket.dart';
import 'package:current_results/src/generated/query.pbgrpc.dart';
import 'package:current_results/src/slice.dart';
import 'package:current_results/src/notifications.dart';

class QueryService extends QueryServiceBase {
  Slice current;
  BucketNotifications notifications;
  ResultsBucket bucket;

  QueryService(this.current, this.notifications, this.bucket);

  @override
  Future<GetResultsResponse> getResults(
          ServiceCall call, GetResultsRequest request) =>
      Future.value(current.results(request));

  @override
  Future<ListTestsResponse> listTests(
          ServiceCall call, ListTestsRequest request) =>
      Future.value(current.listTests(request));

  @override
  Future<ListTestsResponse> listTestPathCompletions(
      ServiceCall call, ListTestsRequest request) async {
    throw UnimplementedError();
  }

  @override
  Future<ListConfigurationsResponse> listConfigurations(
      ServiceCall call, ListConfigurationsRequest request) async {
    throw UnimplementedError;
  }

  @override
  Future<FetchResponse> fetch(ServiceCall call, Empty request) async {
    final response = FetchResponse();
    final messages = await notifications.getMessages();
    final latestObjectPattern = RegExp('^(configuration/main/[^/]+/)latest\$');
    final configurations = <String>{};
    for (final message in messages) {
      if (message.attributes['eventType'] == 'OBJECT_FINALIZE') {
        final match =
            latestObjectPattern.firstMatch(message.attributes['objectId']!);
        if (match != null) {
          configurations.add(match[1]!);
        }
      }
    }
    for (final configuration in configurations) {
      final lines = await bucket.latestResults(configuration);
      current.add(lines);
      response.updates
          .add(ConfigurationUpdate()..configuration = configuration);
    }
    current.dropResultsOlderThan(maximumAge);
    current.collectTestNames();
    return response;
  }
}
