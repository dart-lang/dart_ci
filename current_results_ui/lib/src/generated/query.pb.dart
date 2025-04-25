//
//  Generated code. Do not modify.
//  source: query.proto
//
// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class Empty extends $pb.GeneratedMessage {
  factory Empty() => create();
  Empty._() : super();
  factory Empty.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory Empty.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Empty',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'current_results'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  Empty clone() => Empty()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  Empty copyWith(void Function(Empty) updates) =>
      super.copyWith((message) => updates(message as Empty)) as Empty;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Empty create() => Empty._();
  Empty createEmptyInstance() => create();
  static $pb.PbList<Empty> createRepeated() => $pb.PbList<Empty>();
  @$core.pragma('dart2js:noInline')
  static Empty getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Empty>(create);
  static Empty? _defaultInstance;
}

class GetResultsRequest extends $pb.GeneratedMessage {
  factory GetResultsRequest({
    $core.String? filter,
    $core.int? pageSize,
    $core.String? pageToken,
  }) {
    final $result = create();
    if (filter != null) {
      $result.filter = filter;
    }
    if (pageSize != null) {
      $result.pageSize = pageSize;
    }
    if (pageToken != null) {
      $result.pageToken = pageToken;
    }
    return $result;
  }
  GetResultsRequest._() : super();
  factory GetResultsRequest.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory GetResultsRequest.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetResultsRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'current_results'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'filter')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'pageSize', $pb.PbFieldType.O3)
    ..aOS(3, _omitFieldNames ? '' : 'pageToken')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  GetResultsRequest clone() => GetResultsRequest()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  GetResultsRequest copyWith(void Function(GetResultsRequest) updates) =>
      super.copyWith((message) => updates(message as GetResultsRequest))
          as GetResultsRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetResultsRequest create() => GetResultsRequest._();
  GetResultsRequest createEmptyInstance() => create();
  static $pb.PbList<GetResultsRequest> createRepeated() =>
      $pb.PbList<GetResultsRequest>();
  @$core.pragma('dart2js:noInline')
  static GetResultsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetResultsRequest>(create);
  static GetResultsRequest? _defaultInstance;

  /// The filter contains test names and test name prefixes, and configuration
  /// names, separated by commas. If there are test names and/or test name
  /// prefixes, only results for tests matching them are returned.
  /// If there are configuration names, only results on those configurations
  /// are returned. If absent, return all results.
  @$pb.TagNumber(1)
  $core.String get filter => $_getSZ(0);
  @$pb.TagNumber(1)
  set filter($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasFilter() => $_has(0);
  @$pb.TagNumber(1)
  void clearFilter() => $_clearField(1);

  /// The maximum number of results to return.
  /// The service may return fewer than this value.
  /// If unspecified, will be 100,000.
  /// The maximum value is 100,000.
  @$pb.TagNumber(2)
  $core.int get pageSize => $_getIZ(1);
  @$pb.TagNumber(2)
  set pageSize($core.int v) {
    $_setSignedInt32(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasPageSize() => $_has(1);
  @$pb.TagNumber(2)
  void clearPageSize() => $_clearField(2);

  /// The page token received from a previous call to GetResults.
  /// All arguments except page_size must be identical to the previous call.
  @$pb.TagNumber(3)
  $core.String get pageToken => $_getSZ(2);
  @$pb.TagNumber(3)
  set pageToken($core.String v) {
    $_setString(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasPageToken() => $_has(2);
  @$pb.TagNumber(3)
  void clearPageToken() => $_clearField(3);
}

class GetResultsResponse extends $pb.GeneratedMessage {
  factory GetResultsResponse({
    $core.Iterable<Result>? results,
    $core.String? nextPageToken,
  }) {
    final $result = create();
    if (results != null) {
      $result.results.addAll(results);
    }
    if (nextPageToken != null) {
      $result.nextPageToken = nextPageToken;
    }
    return $result;
  }
  GetResultsResponse._() : super();
  factory GetResultsResponse.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory GetResultsResponse.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetResultsResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'current_results'),
      createEmptyInstance: create)
    ..pc<Result>(1, _omitFieldNames ? '' : 'results', $pb.PbFieldType.PM,
        subBuilder: Result.create)
    ..aOS(2, _omitFieldNames ? '' : 'nextPageToken')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  GetResultsResponse clone() => GetResultsResponse()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  GetResultsResponse copyWith(void Function(GetResultsResponse) updates) =>
      super.copyWith((message) => updates(message as GetResultsResponse))
          as GetResultsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetResultsResponse create() => GetResultsResponse._();
  GetResultsResponse createEmptyInstance() => create();
  static $pb.PbList<GetResultsResponse> createRepeated() =>
      $pb.PbList<GetResultsResponse>();
  @$core.pragma('dart2js:noInline')
  static GetResultsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetResultsResponse>(create);
  static GetResultsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Result> get results => $_getList(0);

  /// A token, which can be sent as `page_token` to retrieve the next page.
  /// If this field is omitted, there are no subsequent pages.
  @$pb.TagNumber(2)
  $core.String get nextPageToken => $_getSZ(1);
  @$pb.TagNumber(2)
  set nextPageToken($core.String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasNextPageToken() => $_has(1);
  @$pb.TagNumber(2)
  void clearNextPageToken() => $_clearField(2);
}

class Result extends $pb.GeneratedMessage {
  factory Result({
    $core.String? name,
    $core.String? configuration,
    $core.String? result,
    $core.String? expected,
    $core.bool? flaky,
    $core.int? timeMs,
    $core.Iterable<$core.String>? experiments,
    $core.String? revision,
  }) {
    final $result = create();
    if (name != null) {
      $result.name = name;
    }
    if (configuration != null) {
      $result.configuration = configuration;
    }
    if (result != null) {
      $result.result = result;
    }
    if (expected != null) {
      $result.expected = expected;
    }
    if (flaky != null) {
      $result.flaky = flaky;
    }
    if (timeMs != null) {
      $result.timeMs = timeMs;
    }
    if (experiments != null) {
      $result.experiments.addAll(experiments);
    }
    if (revision != null) {
      $result.revision = revision;
    }
    return $result;
  }
  Result._() : super();
  factory Result.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory Result.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Result',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'current_results'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOS(2, _omitFieldNames ? '' : 'configuration')
    ..aOS(3, _omitFieldNames ? '' : 'result')
    ..aOS(4, _omitFieldNames ? '' : 'expected')
    ..aOB(5, _omitFieldNames ? '' : 'flaky')
    ..a<$core.int>(6, _omitFieldNames ? '' : 'timeMs', $pb.PbFieldType.O3)
    ..pPS(7, _omitFieldNames ? '' : 'experiments')
    ..aOS(8, _omitFieldNames ? '' : 'revision')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  Result clone() => Result()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  Result copyWith(void Function(Result) updates) =>
      super.copyWith((message) => updates(message as Result)) as Result;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Result create() => Result._();
  Result createEmptyInstance() => create();
  static $pb.PbList<Result> createRepeated() => $pb.PbList<Result>();
  @$core.pragma('dart2js:noInline')
  static Result getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Result>(create);
  static Result? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get configuration => $_getSZ(1);
  @$pb.TagNumber(2)
  set configuration($core.String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasConfiguration() => $_has(1);
  @$pb.TagNumber(2)
  void clearConfiguration() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get result => $_getSZ(2);
  @$pb.TagNumber(3)
  set result($core.String v) {
    $_setString(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasResult() => $_has(2);
  @$pb.TagNumber(3)
  void clearResult() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get expected => $_getSZ(3);
  @$pb.TagNumber(4)
  set expected($core.String v) {
    $_setString(3, v);
  }

  @$pb.TagNumber(4)
  $core.bool hasExpected() => $_has(3);
  @$pb.TagNumber(4)
  void clearExpected() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get flaky => $_getBF(4);
  @$pb.TagNumber(5)
  set flaky($core.bool v) {
    $_setBool(4, v);
  }

  @$pb.TagNumber(5)
  $core.bool hasFlaky() => $_has(4);
  @$pb.TagNumber(5)
  void clearFlaky() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get timeMs => $_getIZ(5);
  @$pb.TagNumber(6)
  set timeMs($core.int v) {
    $_setSignedInt32(5, v);
  }

  @$pb.TagNumber(6)
  $core.bool hasTimeMs() => $_has(5);
  @$pb.TagNumber(6)
  void clearTimeMs() => $_clearField(6);

  @$pb.TagNumber(7)
  $pb.PbList<$core.String> get experiments => $_getList(6);

  @$pb.TagNumber(8)
  $core.String get revision => $_getSZ(7);
  @$pb.TagNumber(8)
  set revision($core.String v) {
    $_setString(7, v);
  }

  @$pb.TagNumber(8)
  $core.bool hasRevision() => $_has(7);
  @$pb.TagNumber(8)
  void clearRevision() => $_clearField(8);
}

class ListTestsRequest extends $pb.GeneratedMessage {
  factory ListTestsRequest({
    $core.String? prefix,
    $core.int? limit,
  }) {
    final $result = create();
    if (prefix != null) {
      $result.prefix = prefix;
    }
    if (limit != null) {
      $result.limit = limit;
    }
    return $result;
  }
  ListTestsRequest._() : super();
  factory ListTestsRequest.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory ListTestsRequest.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListTestsRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'current_results'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'prefix')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'limit', $pb.PbFieldType.O3)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  ListTestsRequest clone() => ListTestsRequest()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  ListTestsRequest copyWith(void Function(ListTestsRequest) updates) =>
      super.copyWith((message) => updates(message as ListTestsRequest))
          as ListTestsRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListTestsRequest create() => ListTestsRequest._();
  ListTestsRequest createEmptyInstance() => create();
  static $pb.PbList<ListTestsRequest> createRepeated() =>
      $pb.PbList<ListTestsRequest>();
  @$core.pragma('dart2js:noInline')
  static ListTestsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListTestsRequest>(create);
  static ListTestsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get prefix => $_getSZ(0);
  @$pb.TagNumber(1)
  set prefix($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasPrefix() => $_has(0);
  @$pb.TagNumber(1)
  void clearPrefix() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get limit => $_getIZ(1);
  @$pb.TagNumber(2)
  set limit($core.int v) {
    $_setSignedInt32(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasLimit() => $_has(1);
  @$pb.TagNumber(2)
  void clearLimit() => $_clearField(2);
}

class ListTestsResponse extends $pb.GeneratedMessage {
  factory ListTestsResponse({
    $core.Iterable<$core.String>? names,
  }) {
    final $result = create();
    if (names != null) {
      $result.names.addAll(names);
    }
    return $result;
  }
  ListTestsResponse._() : super();
  factory ListTestsResponse.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory ListTestsResponse.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListTestsResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'current_results'),
      createEmptyInstance: create)
    ..pPS(1, _omitFieldNames ? '' : 'names')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  ListTestsResponse clone() => ListTestsResponse()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  ListTestsResponse copyWith(void Function(ListTestsResponse) updates) =>
      super.copyWith((message) => updates(message as ListTestsResponse))
          as ListTestsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListTestsResponse create() => ListTestsResponse._();
  ListTestsResponse createEmptyInstance() => create();
  static $pb.PbList<ListTestsResponse> createRepeated() =>
      $pb.PbList<ListTestsResponse>();
  @$core.pragma('dart2js:noInline')
  static ListTestsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListTestsResponse>(create);
  static ListTestsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$core.String> get names => $_getList(0);
}

class ListConfigurationsRequest extends $pb.GeneratedMessage {
  factory ListConfigurationsRequest({
    $core.String? prefix,
  }) {
    final $result = create();
    if (prefix != null) {
      $result.prefix = prefix;
    }
    return $result;
  }
  ListConfigurationsRequest._() : super();
  factory ListConfigurationsRequest.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory ListConfigurationsRequest.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListConfigurationsRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'current_results'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'prefix')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  ListConfigurationsRequest clone() =>
      ListConfigurationsRequest()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  ListConfigurationsRequest copyWith(
          void Function(ListConfigurationsRequest) updates) =>
      super.copyWith((message) => updates(message as ListConfigurationsRequest))
          as ListConfigurationsRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListConfigurationsRequest create() => ListConfigurationsRequest._();
  ListConfigurationsRequest createEmptyInstance() => create();
  static $pb.PbList<ListConfigurationsRequest> createRepeated() =>
      $pb.PbList<ListConfigurationsRequest>();
  @$core.pragma('dart2js:noInline')
  static ListConfigurationsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListConfigurationsRequest>(create);
  static ListConfigurationsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get prefix => $_getSZ(0);
  @$pb.TagNumber(1)
  set prefix($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasPrefix() => $_has(0);
  @$pb.TagNumber(1)
  void clearPrefix() => $_clearField(1);
}

class ListConfigurationsResponse extends $pb.GeneratedMessage {
  factory ListConfigurationsResponse({
    $core.Iterable<$core.String>? configurations,
  }) {
    final $result = create();
    if (configurations != null) {
      $result.configurations.addAll(configurations);
    }
    return $result;
  }
  ListConfigurationsResponse._() : super();
  factory ListConfigurationsResponse.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory ListConfigurationsResponse.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListConfigurationsResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'current_results'),
      createEmptyInstance: create)
    ..pPS(1, _omitFieldNames ? '' : 'configurations')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  ListConfigurationsResponse clone() =>
      ListConfigurationsResponse()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  ListConfigurationsResponse copyWith(
          void Function(ListConfigurationsResponse) updates) =>
      super.copyWith(
              (message) => updates(message as ListConfigurationsResponse))
          as ListConfigurationsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListConfigurationsResponse create() => ListConfigurationsResponse._();
  ListConfigurationsResponse createEmptyInstance() => create();
  static $pb.PbList<ListConfigurationsResponse> createRepeated() =>
      $pb.PbList<ListConfigurationsResponse>();
  @$core.pragma('dart2js:noInline')
  static ListConfigurationsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListConfigurationsResponse>(create);
  static ListConfigurationsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$core.String> get configurations => $_getList(0);
}

class FetchResponse extends $pb.GeneratedMessage {
  factory FetchResponse({
    $core.Iterable<ConfigurationUpdate>? updates,
  }) {
    final $result = create();
    if (updates != null) {
      $result.updates.addAll(updates);
    }
    return $result;
  }
  FetchResponse._() : super();
  factory FetchResponse.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory FetchResponse.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FetchResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'current_results'),
      createEmptyInstance: create)
    ..pc<ConfigurationUpdate>(
        1, _omitFieldNames ? '' : 'updates', $pb.PbFieldType.PM,
        subBuilder: ConfigurationUpdate.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  FetchResponse clone() => FetchResponse()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  FetchResponse copyWith(void Function(FetchResponse) updates) =>
      super.copyWith((message) => updates(message as FetchResponse))
          as FetchResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FetchResponse create() => FetchResponse._();
  FetchResponse createEmptyInstance() => create();
  static $pb.PbList<FetchResponse> createRepeated() =>
      $pb.PbList<FetchResponse>();
  @$core.pragma('dart2js:noInline')
  static FetchResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FetchResponse>(create);
  static FetchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<ConfigurationUpdate> get updates => $_getList(0);
}

class ConfigurationUpdate extends $pb.GeneratedMessage {
  factory ConfigurationUpdate({
    $core.String? configuration,
  }) {
    final $result = create();
    if (configuration != null) {
      $result.configuration = configuration;
    }
    return $result;
  }
  ConfigurationUpdate._() : super();
  factory ConfigurationUpdate.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory ConfigurationUpdate.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ConfigurationUpdate',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'current_results'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'configuration')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  ConfigurationUpdate clone() => ConfigurationUpdate()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  ConfigurationUpdate copyWith(void Function(ConfigurationUpdate) updates) =>
      super.copyWith((message) => updates(message as ConfigurationUpdate))
          as ConfigurationUpdate;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ConfigurationUpdate create() => ConfigurationUpdate._();
  ConfigurationUpdate createEmptyInstance() => create();
  static $pb.PbList<ConfigurationUpdate> createRepeated() =>
      $pb.PbList<ConfigurationUpdate>();
  @$core.pragma('dart2js:noInline')
  static ConfigurationUpdate getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ConfigurationUpdate>(create);
  static ConfigurationUpdate? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get configuration => $_getSZ(0);
  @$pb.TagNumber(1)
  set configuration($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasConfiguration() => $_has(0);
  @$pb.TagNumber(1)
  void clearConfiguration() => $_clearField(1);
}

class QueryApi {
  $pb.RpcClient _client;
  QueryApi(this._client);

  /// Returns all results matching the optional test and configuration filters.
  $async.Future<GetResultsResponse> getResults(
          $pb.ClientContext? ctx, GetResultsRequest request) =>
      _client.invoke<GetResultsResponse>(
          ctx, 'Query', 'GetResults', request, GetResultsResponse());

  /// Returns the test names starting with an optional prefix.
  $async.Future<ListTestsResponse> listTests(
          $pb.ClientContext? ctx, ListTestsRequest request) =>
      _client.invoke<ListTestsResponse>(
          ctx, 'Query', 'ListTests', request, ListTestsResponse());

  /// Returns the completions of a partial test name. Returns a list of
  /// the test paths starting with the prefix, completed to the next path
  /// component, perhaps followed by complete test paths.
  $async.Future<ListTestsResponse> listTestPathCompletions(
          $pb.ClientContext? ctx, ListTestsRequest request) =>
      _client.invoke<ListTestsResponse>(ctx, 'Query', 'ListTestPathCompletions',
          request, ListTestsResponse());

  /// Returns a list of all configurations starting with an optional prefix.
  $async.Future<ListConfigurationsResponse> listConfigurations(
          $pb.ClientContext? ctx, ListConfigurationsRequest request) =>
      _client.invoke<ListConfigurationsResponse>(ctx, 'Query',
          'ListConfigurations', request, ListConfigurationsResponse());

  /// Fetches new results into the service
  $async.Future<FetchResponse> fetch($pb.ClientContext? ctx, Empty request) =>
      _client.invoke<FetchResponse>(
          ctx, 'Query', 'Fetch', request, FetchResponse());
}

const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
