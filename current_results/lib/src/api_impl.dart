// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:grpc/grpc.dart';

import 'package:current_results/src/generated/query.pbgrpc.dart';
import 'package:current_results/src/slice.dart';

class QueryService extends QueryServiceBase {
  Slice current;

  QueryService(this.current);

  @override
  Future<GetResultsResponse> getResults(
          ServiceCall call, GetResultsRequest query) =>
      Future.value(current.query(query));

  @override
  Future<ListTestsResponse> listTests(
      ServiceCall call, ListTestsRequest query) async {
    throw UnimplementedError();
  }

  @override
  Future<ListTestsResponse> listTestPathCompletions(
      ServiceCall call, ListTestsRequest query) async {
    throw UnimplementedError();
  }

  @override
  Future<ListConfigurationsResponse> listConfigurations(
      ServiceCall call, ListConfigurationsRequest query) async {
    throw UnimplementedError;
  }
}
