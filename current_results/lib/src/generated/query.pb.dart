///
//  Generated code. Do not modify.
//  source: query.proto
//
// @dart = 2.3
// ignore_for_file: camel_case_types,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class GetResultsRequest extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('GetResultsRequest',
      package: const $pb.PackageName('current_results'),
      createEmptyInstance: create)
    ..aOS(1, 'filter')
    ..a<$core.int>(2, 'pageSize', $pb.PbFieldType.O3)
    ..aOS(3, 'pageToken')
    ..hasRequiredFields = false;

  GetResultsRequest._() : super();
  factory GetResultsRequest() => create();
  factory GetResultsRequest.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory GetResultsRequest.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  GetResultsRequest clone() => GetResultsRequest()..mergeFromMessage(this);
  GetResultsRequest copyWith(void Function(GetResultsRequest) updates) =>
      super.copyWith((message) => updates(message as GetResultsRequest));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static GetResultsRequest create() => GetResultsRequest._();
  GetResultsRequest createEmptyInstance() => create();
  static $pb.PbList<GetResultsRequest> createRepeated() =>
      $pb.PbList<GetResultsRequest>();
  @$core.pragma('dart2js:noInline')
  static GetResultsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetResultsRequest>(create);
  static GetResultsRequest _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get filter => $_getSZ(0);
  @$pb.TagNumber(1)
  set filter($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasFilter() => $_has(0);
  @$pb.TagNumber(1)
  void clearFilter() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get pageSize => $_getIZ(1);
  @$pb.TagNumber(2)
  set pageSize($core.int v) {
    $_setSignedInt32(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasPageSize() => $_has(1);
  @$pb.TagNumber(2)
  void clearPageSize() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get pageToken => $_getSZ(2);
  @$pb.TagNumber(3)
  set pageToken($core.String v) {
    $_setString(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasPageToken() => $_has(2);
  @$pb.TagNumber(3)
  void clearPageToken() => clearField(3);
}

class GetResultsResponse extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('GetResultsResponse',
      package: const $pb.PackageName('current_results'),
      createEmptyInstance: create)
    ..pc<Result>(1, 'results', $pb.PbFieldType.PM, subBuilder: Result.create)
    ..aOS(2, 'nextPageToken')
    ..hasRequiredFields = false;

  GetResultsResponse._() : super();
  factory GetResultsResponse() => create();
  factory GetResultsResponse.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory GetResultsResponse.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  GetResultsResponse clone() => GetResultsResponse()..mergeFromMessage(this);
  GetResultsResponse copyWith(void Function(GetResultsResponse) updates) =>
      super.copyWith((message) => updates(message as GetResultsResponse));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static GetResultsResponse create() => GetResultsResponse._();
  GetResultsResponse createEmptyInstance() => create();
  static $pb.PbList<GetResultsResponse> createRepeated() =>
      $pb.PbList<GetResultsResponse>();
  @$core.pragma('dart2js:noInline')
  static GetResultsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetResultsResponse>(create);
  static GetResultsResponse _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<Result> get results => $_getList(0);

  @$pb.TagNumber(2)
  $core.String get nextPageToken => $_getSZ(1);
  @$pb.TagNumber(2)
  set nextPageToken($core.String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasNextPageToken() => $_has(1);
  @$pb.TagNumber(2)
  void clearNextPageToken() => clearField(2);
}

class Result extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('Result',
      package: const $pb.PackageName('current_results'),
      createEmptyInstance: create)
    ..aOS(1, 'name')
    ..aOS(2, 'configuration')
    ..aOS(3, 'result')
    ..aOS(4, 'expected')
    ..aOB(5, 'flaky')
    ..a<$core.int>(6, 'timeMs', $pb.PbFieldType.O3)
    ..hasRequiredFields = false;

  Result._() : super();
  factory Result() => create();
  factory Result.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory Result.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  Result clone() => Result()..mergeFromMessage(this);
  Result copyWith(void Function(Result) updates) =>
      super.copyWith((message) => updates(message as Result));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static Result create() => Result._();
  Result createEmptyInstance() => create();
  static $pb.PbList<Result> createRepeated() => $pb.PbList<Result>();
  @$core.pragma('dart2js:noInline')
  static Result getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Result>(create);
  static Result _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get configuration => $_getSZ(1);
  @$pb.TagNumber(2)
  set configuration($core.String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasConfiguration() => $_has(1);
  @$pb.TagNumber(2)
  void clearConfiguration() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get result => $_getSZ(2);
  @$pb.TagNumber(3)
  set result($core.String v) {
    $_setString(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasResult() => $_has(2);
  @$pb.TagNumber(3)
  void clearResult() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get expected => $_getSZ(3);
  @$pb.TagNumber(4)
  set expected($core.String v) {
    $_setString(3, v);
  }

  @$pb.TagNumber(4)
  $core.bool hasExpected() => $_has(3);
  @$pb.TagNumber(4)
  void clearExpected() => clearField(4);

  @$pb.TagNumber(5)
  $core.bool get flaky => $_getBF(4);
  @$pb.TagNumber(5)
  set flaky($core.bool v) {
    $_setBool(4, v);
  }

  @$pb.TagNumber(5)
  $core.bool hasFlaky() => $_has(4);
  @$pb.TagNumber(5)
  void clearFlaky() => clearField(5);

  @$pb.TagNumber(6)
  $core.int get timeMs => $_getIZ(5);
  @$pb.TagNumber(6)
  set timeMs($core.int v) {
    $_setSignedInt32(5, v);
  }

  @$pb.TagNumber(6)
  $core.bool hasTimeMs() => $_has(5);
  @$pb.TagNumber(6)
  void clearTimeMs() => clearField(6);
}

class ListTestsRequest extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('ListTestsRequest',
      package: const $pb.PackageName('current_results'),
      createEmptyInstance: create)
    ..aOS(1, 'prefix')
    ..a<$core.int>(2, 'limit', $pb.PbFieldType.O3)
    ..hasRequiredFields = false;

  ListTestsRequest._() : super();
  factory ListTestsRequest() => create();
  factory ListTestsRequest.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory ListTestsRequest.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  ListTestsRequest clone() => ListTestsRequest()..mergeFromMessage(this);
  ListTestsRequest copyWith(void Function(ListTestsRequest) updates) =>
      super.copyWith((message) => updates(message as ListTestsRequest));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static ListTestsRequest create() => ListTestsRequest._();
  ListTestsRequest createEmptyInstance() => create();
  static $pb.PbList<ListTestsRequest> createRepeated() =>
      $pb.PbList<ListTestsRequest>();
  @$core.pragma('dart2js:noInline')
  static ListTestsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListTestsRequest>(create);
  static ListTestsRequest _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get prefix => $_getSZ(0);
  @$pb.TagNumber(1)
  set prefix($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasPrefix() => $_has(0);
  @$pb.TagNumber(1)
  void clearPrefix() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get limit => $_getIZ(1);
  @$pb.TagNumber(2)
  set limit($core.int v) {
    $_setSignedInt32(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasLimit() => $_has(1);
  @$pb.TagNumber(2)
  void clearLimit() => clearField(2);
}

class ListTestsResponse extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('ListTestsResponse',
      package: const $pb.PackageName('current_results'),
      createEmptyInstance: create)
    ..pPS(1, 'names')
    ..hasRequiredFields = false;

  ListTestsResponse._() : super();
  factory ListTestsResponse() => create();
  factory ListTestsResponse.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory ListTestsResponse.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  ListTestsResponse clone() => ListTestsResponse()..mergeFromMessage(this);
  ListTestsResponse copyWith(void Function(ListTestsResponse) updates) =>
      super.copyWith((message) => updates(message as ListTestsResponse));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static ListTestsResponse create() => ListTestsResponse._();
  ListTestsResponse createEmptyInstance() => create();
  static $pb.PbList<ListTestsResponse> createRepeated() =>
      $pb.PbList<ListTestsResponse>();
  @$core.pragma('dart2js:noInline')
  static ListTestsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListTestsResponse>(create);
  static ListTestsResponse _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.String> get names => $_getList(0);
}

class ListConfigurationsRequest extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('ListConfigurationsRequest',
      package: const $pb.PackageName('current_results'),
      createEmptyInstance: create)
    ..aOS(1, 'prefix')
    ..hasRequiredFields = false;

  ListConfigurationsRequest._() : super();
  factory ListConfigurationsRequest() => create();
  factory ListConfigurationsRequest.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory ListConfigurationsRequest.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  ListConfigurationsRequest clone() =>
      ListConfigurationsRequest()..mergeFromMessage(this);
  ListConfigurationsRequest copyWith(
          void Function(ListConfigurationsRequest) updates) =>
      super
          .copyWith((message) => updates(message as ListConfigurationsRequest));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static ListConfigurationsRequest create() => ListConfigurationsRequest._();
  ListConfigurationsRequest createEmptyInstance() => create();
  static $pb.PbList<ListConfigurationsRequest> createRepeated() =>
      $pb.PbList<ListConfigurationsRequest>();
  @$core.pragma('dart2js:noInline')
  static ListConfigurationsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListConfigurationsRequest>(create);
  static ListConfigurationsRequest _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get prefix => $_getSZ(0);
  @$pb.TagNumber(1)
  set prefix($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasPrefix() => $_has(0);
  @$pb.TagNumber(1)
  void clearPrefix() => clearField(1);
}

class ListConfigurationsResponse extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      'ListConfigurationsResponse',
      package: const $pb.PackageName('current_results'),
      createEmptyInstance: create)
    ..pPS(1, 'configurations')
    ..hasRequiredFields = false;

  ListConfigurationsResponse._() : super();
  factory ListConfigurationsResponse() => create();
  factory ListConfigurationsResponse.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory ListConfigurationsResponse.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  ListConfigurationsResponse clone() =>
      ListConfigurationsResponse()..mergeFromMessage(this);
  ListConfigurationsResponse copyWith(
          void Function(ListConfigurationsResponse) updates) =>
      super.copyWith(
          (message) => updates(message as ListConfigurationsResponse));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static ListConfigurationsResponse create() => ListConfigurationsResponse._();
  ListConfigurationsResponse createEmptyInstance() => create();
  static $pb.PbList<ListConfigurationsResponse> createRepeated() =>
      $pb.PbList<ListConfigurationsResponse>();
  @$core.pragma('dart2js:noInline')
  static ListConfigurationsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListConfigurationsResponse>(create);
  static ListConfigurationsResponse _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.String> get configurations => $_getList(0);
}

class FetchResponse extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('FetchResponse',
      package: const $pb.PackageName('current_results'),
      createEmptyInstance: create)
    ..pc<ConfigurationUpdate>(1, 'updates', $pb.PbFieldType.PM,
        subBuilder: ConfigurationUpdate.create)
    ..hasRequiredFields = false;

  FetchResponse._() : super();
  factory FetchResponse() => create();
  factory FetchResponse.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory FetchResponse.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  FetchResponse clone() => FetchResponse()..mergeFromMessage(this);
  FetchResponse copyWith(void Function(FetchResponse) updates) =>
      super.copyWith((message) => updates(message as FetchResponse));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static FetchResponse create() => FetchResponse._();
  FetchResponse createEmptyInstance() => create();
  static $pb.PbList<FetchResponse> createRepeated() =>
      $pb.PbList<FetchResponse>();
  @$core.pragma('dart2js:noInline')
  static FetchResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FetchResponse>(create);
  static FetchResponse _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<ConfigurationUpdate> get updates => $_getList(0);
}

class ConfigurationUpdate extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('ConfigurationUpdate',
      package: const $pb.PackageName('current_results'),
      createEmptyInstance: create)
    ..aOS(1, 'configuration')
    ..hasRequiredFields = false;

  ConfigurationUpdate._() : super();
  factory ConfigurationUpdate() => create();
  factory ConfigurationUpdate.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory ConfigurationUpdate.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);
  ConfigurationUpdate clone() => ConfigurationUpdate()..mergeFromMessage(this);
  ConfigurationUpdate copyWith(void Function(ConfigurationUpdate) updates) =>
      super.copyWith((message) => updates(message as ConfigurationUpdate));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static ConfigurationUpdate create() => ConfigurationUpdate._();
  ConfigurationUpdate createEmptyInstance() => create();
  static $pb.PbList<ConfigurationUpdate> createRepeated() =>
      $pb.PbList<ConfigurationUpdate>();
  @$core.pragma('dart2js:noInline')
  static ConfigurationUpdate getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ConfigurationUpdate>(create);
  static ConfigurationUpdate _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get configuration => $_getSZ(0);
  @$pb.TagNumber(1)
  set configuration($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasConfiguration() => $_has(0);
  @$pb.TagNumber(1)
  void clearConfiguration() => clearField(1);
}
