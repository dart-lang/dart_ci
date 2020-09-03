///
//  Generated code. Do not modify.
//  source: query.proto
//
// @dart = 2.3
// ignore_for_file: camel_case_types,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type

import 'dart:async' as $async;

import 'package:protobuf/protobuf.dart' as $pb;

import 'dart:core' as $core;
import 'query.pb.dart' as $1;
import 'google/protobuf/empty.pb.dart' as $0;
import 'query.pbjson.dart';

export 'query.pb.dart';

abstract class QueryServiceBase extends $pb.GeneratedService {
  $async.Future<$1.GetResultsResponse> getResults(
      $pb.ServerContext ctx, $1.GetResultsRequest request);
  $async.Future<$1.ListTestsResponse> listTests(
      $pb.ServerContext ctx, $1.ListTestsRequest request);
  $async.Future<$1.ListTestsResponse> listTestPathCompletions(
      $pb.ServerContext ctx, $1.ListTestsRequest request);
  $async.Future<$1.ListConfigurationsResponse> listConfigurations(
      $pb.ServerContext ctx, $1.ListConfigurationsRequest request);
  $async.Future<$1.FetchResponse> fetch(
      $pb.ServerContext ctx, $0.Empty request);

  $pb.GeneratedMessage createRequest($core.String method) {
    switch (method) {
      case 'GetResults':
        return $1.GetResultsRequest();
      case 'ListTests':
        return $1.ListTestsRequest();
      case 'ListTestPathCompletions':
        return $1.ListTestsRequest();
      case 'ListConfigurations':
        return $1.ListConfigurationsRequest();
      case 'Fetch':
        return $0.Empty();
      default:
        throw $core.ArgumentError('Unknown method: $method');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx,
      $core.String method, $pb.GeneratedMessage request) {
    switch (method) {
      case 'GetResults':
        return this.getResults(ctx, request);
      case 'ListTests':
        return this.listTests(ctx, request);
      case 'ListTestPathCompletions':
        return this.listTestPathCompletions(ctx, request);
      case 'ListConfigurations':
        return this.listConfigurations(ctx, request);
      case 'Fetch':
        return this.fetch(ctx, request);
      default:
        throw $core.ArgumentError('Unknown method: $method');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => QueryServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
      get $messageJson => QueryServiceBase$messageJson;
}
