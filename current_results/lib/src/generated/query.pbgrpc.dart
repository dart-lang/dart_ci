///
//  Generated code. Do not modify.
//  source: query.proto
//
// @dart = 2.3
// ignore_for_file: camel_case_types,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type

import 'dart:async' as $async;

import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'query.pb.dart' as $0;
import 'google/protobuf/empty.pb.dart' as $1;
export 'query.pb.dart';

class QueryClient extends $grpc.Client {
  static final _$getResults =
      $grpc.ClientMethod<$0.GetResultsRequest, $0.GetResultsResponse>(
          '/current_results.Query/GetResults',
          ($0.GetResultsRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $0.GetResultsResponse.fromBuffer(value));
  static final _$listTests =
      $grpc.ClientMethod<$0.ListTestsRequest, $0.ListTestsResponse>(
          '/current_results.Query/ListTests',
          ($0.ListTestsRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $0.ListTestsResponse.fromBuffer(value));
  static final _$listTestPathCompletions =
      $grpc.ClientMethod<$0.ListTestsRequest, $0.ListTestsResponse>(
          '/current_results.Query/ListTestPathCompletions',
          ($0.ListTestsRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $0.ListTestsResponse.fromBuffer(value));
  static final _$listConfigurations = $grpc.ClientMethod<
          $0.ListConfigurationsRequest, $0.ListConfigurationsResponse>(
      '/current_results.Query/ListConfigurations',
      ($0.ListConfigurationsRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) =>
          $0.ListConfigurationsResponse.fromBuffer(value));
  static final _$fetch = $grpc.ClientMethod<$1.Empty, $0.FetchResponse>(
      '/current_results.Query/Fetch',
      ($1.Empty value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.FetchResponse.fromBuffer(value));

  QueryClient($grpc.ClientChannel channel, {$grpc.CallOptions options})
      : super(channel, options: options);

  $grpc.ResponseFuture<$0.GetResultsResponse> getResults(
      $0.GetResultsRequest request,
      {$grpc.CallOptions options}) {
    final call = $createCall(
        _$getResults, $async.Stream.fromIterable([request]),
        options: options);
    return $grpc.ResponseFuture(call);
  }

  $grpc.ResponseFuture<$0.ListTestsResponse> listTests(
      $0.ListTestsRequest request,
      {$grpc.CallOptions options}) {
    final call = $createCall(_$listTests, $async.Stream.fromIterable([request]),
        options: options);
    return $grpc.ResponseFuture(call);
  }

  $grpc.ResponseFuture<$0.ListTestsResponse> listTestPathCompletions(
      $0.ListTestsRequest request,
      {$grpc.CallOptions options}) {
    final call = $createCall(
        _$listTestPathCompletions, $async.Stream.fromIterable([request]),
        options: options);
    return $grpc.ResponseFuture(call);
  }

  $grpc.ResponseFuture<$0.ListConfigurationsResponse> listConfigurations(
      $0.ListConfigurationsRequest request,
      {$grpc.CallOptions options}) {
    final call = $createCall(
        _$listConfigurations, $async.Stream.fromIterable([request]),
        options: options);
    return $grpc.ResponseFuture(call);
  }

  $grpc.ResponseFuture<$0.FetchResponse> fetch($1.Empty request,
      {$grpc.CallOptions options}) {
    final call = $createCall(_$fetch, $async.Stream.fromIterable([request]),
        options: options);
    return $grpc.ResponseFuture(call);
  }
}

abstract class QueryServiceBase extends $grpc.Service {
  $core.String get $name => 'current_results.Query';

  QueryServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.GetResultsRequest, $0.GetResultsResponse>(
        'GetResults',
        getResults_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GetResultsRequest.fromBuffer(value),
        ($0.GetResultsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ListTestsRequest, $0.ListTestsResponse>(
        'ListTests',
        listTests_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ListTestsRequest.fromBuffer(value),
        ($0.ListTestsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ListTestsRequest, $0.ListTestsResponse>(
        'ListTestPathCompletions',
        listTestPathCompletions_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ListTestsRequest.fromBuffer(value),
        ($0.ListTestsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ListConfigurationsRequest,
            $0.ListConfigurationsResponse>(
        'ListConfigurations',
        listConfigurations_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ListConfigurationsRequest.fromBuffer(value),
        ($0.ListConfigurationsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $0.FetchResponse>(
        'Fetch',
        fetch_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($0.FetchResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.GetResultsResponse> getResults_Pre($grpc.ServiceCall call,
      $async.Future<$0.GetResultsRequest> request) async {
    return getResults(call, await request);
  }

  $async.Future<$0.ListTestsResponse> listTests_Pre($grpc.ServiceCall call,
      $async.Future<$0.ListTestsRequest> request) async {
    return listTests(call, await request);
  }

  $async.Future<$0.ListTestsResponse> listTestPathCompletions_Pre(
      $grpc.ServiceCall call,
      $async.Future<$0.ListTestsRequest> request) async {
    return listTestPathCompletions(call, await request);
  }

  $async.Future<$0.ListConfigurationsResponse> listConfigurations_Pre(
      $grpc.ServiceCall call,
      $async.Future<$0.ListConfigurationsRequest> request) async {
    return listConfigurations(call, await request);
  }

  $async.Future<$0.FetchResponse> fetch_Pre(
      $grpc.ServiceCall call, $async.Future<$1.Empty> request) async {
    return fetch(call, await request);
  }

  $async.Future<$0.GetResultsResponse> getResults(
      $grpc.ServiceCall call, $0.GetResultsRequest request);
  $async.Future<$0.ListTestsResponse> listTests(
      $grpc.ServiceCall call, $0.ListTestsRequest request);
  $async.Future<$0.ListTestsResponse> listTestPathCompletions(
      $grpc.ServiceCall call, $0.ListTestsRequest request);
  $async.Future<$0.ListConfigurationsResponse> listConfigurations(
      $grpc.ServiceCall call, $0.ListConfigurationsRequest request);
  $async.Future<$0.FetchResponse> fetch(
      $grpc.ServiceCall call, $1.Empty request);
}
