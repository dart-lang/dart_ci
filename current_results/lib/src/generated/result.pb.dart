///
//  Generated code. Do not modify.
//  source: result.proto
///
// ignore_for_file: camel_case_types,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name

import 'dart:core' as $core
    show bool, Deprecated, double, int, List, Map, override, pragma, String;

import 'package:protobuf/protobuf.dart' as $pb;

class Result extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i =
      $pb.BuilderInfo('Result', package: const $pb.PackageName('dart_ci'))
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
  static Result getDefault() => _defaultInstance ??= create()..freeze();
  static Result _defaultInstance;

  $core.String get name => $_getS(0, '');
  set name($core.String v) {
    $_setString(0, v);
  }

  $core.bool hasName() => $_has(0);
  void clearName() => clearField(1);

  $core.String get configuration => $_getS(1, '');
  set configuration($core.String v) {
    $_setString(1, v);
  }

  $core.bool hasConfiguration() => $_has(1);
  void clearConfiguration() => clearField(2);

  $core.int get timeMs => $_get(2, 0);
  set timeMs($core.int v) {
    $_setSignedInt32(2, v);
  }

  $core.bool hasTimeMs() => $_has(2);
  void clearTimeMs() => clearField(3);

  $core.String get result => $_getS(3, '');
  set result($core.String v) {
    $_setString(3, v);
  }

  $core.bool hasResult() => $_has(3);
  void clearResult() => clearField(4);

  $core.String get expected => $_getS(4, '');
  set expected($core.String v) {
    $_setString(4, v);
  }

  $core.bool hasExpected() => $_has(4);
  void clearExpected() => clearField(5);

  $core.bool get matches => $_get(5, false);
  set matches($core.bool v) {
    $_setBool(5, v);
  }

  $core.bool hasMatches() => $_has(5);
  void clearMatches() => clearField(6);

  $core.String get botName => $_getS(6, '');
  set botName($core.String v) {
    $_setString(6, v);
  }

  $core.bool hasBotName() => $_has(6);
  void clearBotName() => clearField(7);

  $core.String get commitHash => $_getS(7, '');
  set commitHash($core.String v) {
    $_setString(7, v);
  }

  $core.bool hasCommitHash() => $_has(7);
  void clearCommitHash() => clearField(8);

  $core.String get buildNumber => $_getS(8, '');
  set buildNumber($core.String v) {
    $_setString(8, v);
  }

  $core.bool hasBuildNumber() => $_has(8);
  void clearBuildNumber() => clearField(9);

  $core.String get builderName => $_getS(9, '');
  set builderName($core.String v) {
    $_setString(9, v);
  }

  $core.bool hasBuilderName() => $_has(9);
  void clearBuilderName() => clearField(10);

  $core.bool get flaky => $_get(10, false);
  set flaky($core.bool v) {
    $_setBool(10, v);
  }

  $core.bool hasFlaky() => $_has(10);
  void clearFlaky() => clearField(11);

  $core.bool get previousFlaky => $_get(11, false);
  set previousFlaky($core.bool v) {
    $_setBool(11, v);
  }

  $core.bool hasPreviousFlaky() => $_has(11);
  void clearPreviousFlaky() => clearField(12);

  $core.String get previousCommitHash => $_getS(12, '');
  set previousCommitHash($core.String v) {
    $_setString(12, v);
  }

  $core.bool hasPreviousCommitHash() => $_has(12);
  void clearPreviousCommitHash() => clearField(13);

  $core.int get previousCommitTime => $_get(13, 0);
  set previousCommitTime($core.int v) {
    $_setSignedInt32(13, v);
  }

  $core.bool hasPreviousCommitTime() => $_has(13);
  void clearPreviousCommitTime() => clearField(14);

  $core.String get previousBuildNumber => $_getS(14, '');
  set previousBuildNumber($core.String v) {
    $_setString(14, v);
  }

  $core.bool hasPreviousBuildNumber() => $_has(14);
  void clearPreviousBuildNumber() => clearField(15);

  $core.String get previousResult => $_getS(15, '');
  set previousResult($core.String v) {
    $_setString(15, v);
  }

  $core.bool hasPreviousResult() => $_has(15);
  void clearPreviousResult() => clearField(16);

  $core.bool get changed => $_get(16, false);
  set changed($core.bool v) {
    $_setBool(16, v);
  }

  $core.bool hasChanged() => $_has(16);
  void clearChanged() => clearField(17);

  $core.String get suite => $_getS(17, '');
  set suite($core.String v) {
    $_setString(17, v);
  }

  $core.bool hasSuite() => $_has(17);
  void clearSuite() => clearField(100);

  $core.String get testName => $_getS(18, '');
  set testName($core.String v) {
    $_setString(18, v);
  }

  $core.bool hasTestName() => $_has(18);
  void clearTestName() => clearField(101);

  $core.int get commitTime => $_get(19, 0);
  set commitTime($core.int v) {
    $_setSignedInt32(19, v);
  }

  $core.bool hasCommitTime() => $_has(19);
  void clearCommitTime() => clearField(102);
}
