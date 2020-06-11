///
//  Generated code. Do not modify.
//  source: result.proto
//
// @dart = 2.3
// ignore_for_file: camel_case_types,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class Result extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('Result',
      package: const $pb.PackageName('dart_ci'), createEmptyInstance: create)
    ..aOS(1, 'name')
    ..aOS(2, 'configuration')
    ..a<$core.int>(3, 'timeMs', $pb.PbFieldType.O3)
    ..aOS(4, 'result')
    ..aOS(5, 'expected')
    ..aOB(6, 'matches')
    ..aOS(7, 'botName')
    ..aOS(8, 'commitHash')
    ..aOS(9, 'buildNumber')
    ..aOS(10, 'builderName')
    ..aOB(11, 'flaky')
    ..aOB(12, 'previousFlaky')
    ..aOS(13, 'previousCommitHash')
    ..a<$core.int>(14, 'previousCommitTime', $pb.PbFieldType.O3)
    ..aOS(15, 'previousBuildNumber')
    ..aOS(16, 'previousResult')
    ..aOB(17, 'changed')
    ..aOS(100, 'suite')
    ..aOS(101, 'testName')
    ..a<$core.int>(102, 'commitTime', $pb.PbFieldType.O3)
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
  $core.int get timeMs => $_getIZ(2);
  @$pb.TagNumber(3)
  set timeMs($core.int v) {
    $_setSignedInt32(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasTimeMs() => $_has(2);
  @$pb.TagNumber(3)
  void clearTimeMs() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get result => $_getSZ(3);
  @$pb.TagNumber(4)
  set result($core.String v) {
    $_setString(3, v);
  }

  @$pb.TagNumber(4)
  $core.bool hasResult() => $_has(3);
  @$pb.TagNumber(4)
  void clearResult() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get expected => $_getSZ(4);
  @$pb.TagNumber(5)
  set expected($core.String v) {
    $_setString(4, v);
  }

  @$pb.TagNumber(5)
  $core.bool hasExpected() => $_has(4);
  @$pb.TagNumber(5)
  void clearExpected() => clearField(5);

  @$pb.TagNumber(6)
  $core.bool get matches => $_getBF(5);
  @$pb.TagNumber(6)
  set matches($core.bool v) {
    $_setBool(5, v);
  }

  @$pb.TagNumber(6)
  $core.bool hasMatches() => $_has(5);
  @$pb.TagNumber(6)
  void clearMatches() => clearField(6);

  @$pb.TagNumber(7)
  $core.String get botName => $_getSZ(6);
  @$pb.TagNumber(7)
  set botName($core.String v) {
    $_setString(6, v);
  }

  @$pb.TagNumber(7)
  $core.bool hasBotName() => $_has(6);
  @$pb.TagNumber(7)
  void clearBotName() => clearField(7);

  @$pb.TagNumber(8)
  $core.String get commitHash => $_getSZ(7);
  @$pb.TagNumber(8)
  set commitHash($core.String v) {
    $_setString(7, v);
  }

  @$pb.TagNumber(8)
  $core.bool hasCommitHash() => $_has(7);
  @$pb.TagNumber(8)
  void clearCommitHash() => clearField(8);

  @$pb.TagNumber(9)
  $core.String get buildNumber => $_getSZ(8);
  @$pb.TagNumber(9)
  set buildNumber($core.String v) {
    $_setString(8, v);
  }

  @$pb.TagNumber(9)
  $core.bool hasBuildNumber() => $_has(8);
  @$pb.TagNumber(9)
  void clearBuildNumber() => clearField(9);

  @$pb.TagNumber(10)
  $core.String get builderName => $_getSZ(9);
  @$pb.TagNumber(10)
  set builderName($core.String v) {
    $_setString(9, v);
  }

  @$pb.TagNumber(10)
  $core.bool hasBuilderName() => $_has(9);
  @$pb.TagNumber(10)
  void clearBuilderName() => clearField(10);

  @$pb.TagNumber(11)
  $core.bool get flaky => $_getBF(10);
  @$pb.TagNumber(11)
  set flaky($core.bool v) {
    $_setBool(10, v);
  }

  @$pb.TagNumber(11)
  $core.bool hasFlaky() => $_has(10);
  @$pb.TagNumber(11)
  void clearFlaky() => clearField(11);

  @$pb.TagNumber(12)
  $core.bool get previousFlaky => $_getBF(11);
  @$pb.TagNumber(12)
  set previousFlaky($core.bool v) {
    $_setBool(11, v);
  }

  @$pb.TagNumber(12)
  $core.bool hasPreviousFlaky() => $_has(11);
  @$pb.TagNumber(12)
  void clearPreviousFlaky() => clearField(12);

  @$pb.TagNumber(13)
  $core.String get previousCommitHash => $_getSZ(12);
  @$pb.TagNumber(13)
  set previousCommitHash($core.String v) {
    $_setString(12, v);
  }

  @$pb.TagNumber(13)
  $core.bool hasPreviousCommitHash() => $_has(12);
  @$pb.TagNumber(13)
  void clearPreviousCommitHash() => clearField(13);

  @$pb.TagNumber(14)
  $core.int get previousCommitTime => $_getIZ(13);
  @$pb.TagNumber(14)
  set previousCommitTime($core.int v) {
    $_setSignedInt32(13, v);
  }

  @$pb.TagNumber(14)
  $core.bool hasPreviousCommitTime() => $_has(13);
  @$pb.TagNumber(14)
  void clearPreviousCommitTime() => clearField(14);

  @$pb.TagNumber(15)
  $core.String get previousBuildNumber => $_getSZ(14);
  @$pb.TagNumber(15)
  set previousBuildNumber($core.String v) {
    $_setString(14, v);
  }

  @$pb.TagNumber(15)
  $core.bool hasPreviousBuildNumber() => $_has(14);
  @$pb.TagNumber(15)
  void clearPreviousBuildNumber() => clearField(15);

  @$pb.TagNumber(16)
  $core.String get previousResult => $_getSZ(15);
  @$pb.TagNumber(16)
  set previousResult($core.String v) {
    $_setString(15, v);
  }

  @$pb.TagNumber(16)
  $core.bool hasPreviousResult() => $_has(15);
  @$pb.TagNumber(16)
  void clearPreviousResult() => clearField(16);

  @$pb.TagNumber(17)
  $core.bool get changed => $_getBF(16);
  @$pb.TagNumber(17)
  set changed($core.bool v) {
    $_setBool(16, v);
  }

  @$pb.TagNumber(17)
  $core.bool hasChanged() => $_has(16);
  @$pb.TagNumber(17)
  void clearChanged() => clearField(17);

  @$pb.TagNumber(100)
  $core.String get suite => $_getSZ(17);
  @$pb.TagNumber(100)
  set suite($core.String v) {
    $_setString(17, v);
  }

  @$pb.TagNumber(100)
  $core.bool hasSuite() => $_has(17);
  @$pb.TagNumber(100)
  void clearSuite() => clearField(100);

  @$pb.TagNumber(101)
  $core.String get testName => $_getSZ(18);
  @$pb.TagNumber(101)
  set testName($core.String v) {
    $_setString(18, v);
  }

  @$pb.TagNumber(101)
  $core.bool hasTestName() => $_has(18);
  @$pb.TagNumber(101)
  void clearTestName() => clearField(101);

  @$pb.TagNumber(102)
  $core.int get commitTime => $_getIZ(19);
  @$pb.TagNumber(102)
  set commitTime($core.int v) {
    $_setSignedInt32(19, v);
  }

  @$pb.TagNumber(102)
  $core.bool hasCommitTime() => $_has(19);
  @$pb.TagNumber(102)
  void clearCommitTime() => clearField(102);
}
