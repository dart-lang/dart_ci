// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EngineVariantImpl _$$EngineVariantImplFromJson(Map<String, dynamic> json) =>
    _$EngineVariantImpl(
      os: json['os'] as String,
      arch: json['arch'] as String?,
      mode: json['mode'] as String?,
    );

Map<String, dynamic> _$$EngineVariantImplToJson(_$EngineVariantImpl instance) =>
    <String, dynamic>{
      'os': instance.os,
      'arch': instance.arch,
      'mode': instance.mode,
    };

_$EngineBuildImpl _$$EngineBuildImplFromJson(Map<String, dynamic> json) =>
    _$EngineBuildImpl(
      engineHash: json['engineHash'] as String,
      variant: EngineVariant.fromJson(json['variant'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$EngineBuildImplToJson(_$EngineBuildImpl instance) =>
    <String, dynamic>{
      'engineHash': instance.engineHash,
      'variant': instance.variant,
    };

_$IosCrashFrameImpl _$$IosCrashFrameImplFromJson(Map<String, dynamic> json) =>
    _$IosCrashFrameImpl(
      no: json['no'] as String,
      binary: json['binary'] as String,
      pc: json['pc'] as int,
      symbol: json['symbol'] as String,
      offset: json['offset'] as int?,
      location: json['location'] as String,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$IosCrashFrameImplToJson(_$IosCrashFrameImpl instance) =>
    <String, dynamic>{
      'no': instance.no,
      'binary': instance.binary,
      'pc': instance.pc,
      'symbol': instance.symbol,
      'offset': instance.offset,
      'location': instance.location,
      'runtimeType': instance.$type,
    };

_$AndroidCrashFrameImpl _$$AndroidCrashFrameImplFromJson(
        Map<String, dynamic> json) =>
    _$AndroidCrashFrameImpl(
      no: json['no'] as String,
      pc: json['pc'] as int,
      binary: json['binary'] as String,
      rest: json['rest'] as String,
      buildId: json['buildId'] as String?,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$AndroidCrashFrameImplToJson(
        _$AndroidCrashFrameImpl instance) =>
    <String, dynamic>{
      'no': instance.no,
      'pc': instance.pc,
      'binary': instance.binary,
      'rest': instance.rest,
      'buildId': instance.buildId,
      'runtimeType': instance.$type,
    };

_$CustomCrashFrameImpl _$$CustomCrashFrameImplFromJson(
        Map<String, dynamic> json) =>
    _$CustomCrashFrameImpl(
      no: json['no'] as String,
      pc: json['pc'] as int,
      binary: json['binary'] as String,
      offset: json['offset'] as int?,
      location: json['location'] as String?,
      symbol: json['symbol'] as String?,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$CustomCrashFrameImplToJson(
        _$CustomCrashFrameImpl instance) =>
    <String, dynamic>{
      'no': instance.no,
      'pc': instance.pc,
      'binary': instance.binary,
      'offset': instance.offset,
      'location': instance.location,
      'symbol': instance.symbol,
      'runtimeType': instance.$type,
    };

_$DartvmCrashFrameImpl _$$DartvmCrashFrameImplFromJson(
        Map<String, dynamic> json) =>
    _$DartvmCrashFrameImpl(
      pc: json['pc'] as int,
      binary: json['binary'] as String,
      offset: json['offset'] as int,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$DartvmCrashFrameImplToJson(
        _$DartvmCrashFrameImpl instance) =>
    <String, dynamic>{
      'pc': instance.pc,
      'binary': instance.binary,
      'offset': instance.offset,
      'runtimeType': instance.$type,
    };

_$CrashImpl _$$CrashImplFromJson(Map<String, dynamic> json) => _$CrashImpl(
      engineVariant:
          EngineVariant.fromJson(json['engineVariant'] as Map<String, dynamic>),
      frames: (json['frames'] as List<dynamic>)
          .map((e) => CrashFrame.fromJson(e as Map<String, dynamic>))
          .toList(),
      format: json['format'] as String,
      androidMajorVersion: json['androidMajorVersion'] as int?,
    );

Map<String, dynamic> _$$CrashImplToJson(_$CrashImpl instance) =>
    <String, dynamic>{
      'engineVariant': instance.engineVariant,
      'frames': instance.frames,
      'format': instance.format,
      'androidMajorVersion': instance.androidMajorVersion,
    };

_$SymbolizationResultOkImpl _$$SymbolizationResultOkImplFromJson(
        Map<String, dynamic> json) =>
    _$SymbolizationResultOkImpl(
      results: (json['results'] as List<dynamic>)
          .map((e) =>
              CrashSymbolizationResult.fromJson(e as Map<String, dynamic>))
          .toList(),
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$SymbolizationResultOkImplToJson(
        _$SymbolizationResultOkImpl instance) =>
    <String, dynamic>{
      'results': instance.results.map((e) => e.toJson()).toList(),
      'runtimeType': instance.$type,
    };

_$SymbolizationResultErrorImpl _$$SymbolizationResultErrorImplFromJson(
        Map<String, dynamic> json) =>
    _$SymbolizationResultErrorImpl(
      error: SymbolizationNote.fromJson(json['error'] as Map<String, dynamic>),
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$SymbolizationResultErrorImplToJson(
        _$SymbolizationResultErrorImpl instance) =>
    <String, dynamic>{
      'error': instance.error.toJson(),
      'runtimeType': instance.$type,
    };

_$CrashSymbolizationResultImpl _$$CrashSymbolizationResultImplFromJson(
        Map<String, dynamic> json) =>
    _$CrashSymbolizationResultImpl(
      crash: Crash.fromJson(json['crash'] as Map<String, dynamic>),
      engineBuild: json['engineBuild'] == null
          ? null
          : EngineBuild.fromJson(json['engineBuild'] as Map<String, dynamic>),
      symbolized: json['symbolized'] as String?,
      notes: (json['notes'] as List<dynamic>?)
              ?.map(
                  (e) => SymbolizationNote.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$CrashSymbolizationResultImplToJson(
        _$CrashSymbolizationResultImpl instance) =>
    <String, dynamic>{
      'crash': instance.crash.toJson(),
      'engineBuild': instance.engineBuild?.toJson(),
      'symbolized': instance.symbolized,
      'notes': instance.notes.map((e) => e.toJson()).toList(),
    };

_$SymbolizationNoteImpl _$$SymbolizationNoteImplFromJson(
        Map<String, dynamic> json) =>
    _$SymbolizationNoteImpl(
      kind: $enumDecode(_$SymbolizationNoteKindEnumMap, json['kind']),
      message: json['message'] as String?,
    );

Map<String, dynamic> _$$SymbolizationNoteImplToJson(
        _$SymbolizationNoteImpl instance) =>
    <String, dynamic>{
      'kind': _$SymbolizationNoteKindEnumMap[instance.kind]!,
      'message': instance.message,
    };

const _$SymbolizationNoteKindEnumMap = {
  SymbolizationNoteKind.unknownEngineHash: 'unknownEngineHash',
  SymbolizationNoteKind.unknownAbi: 'unknownAbi',
  SymbolizationNoteKind.exceptionWhileGettingEngineHash:
      'exceptionWhileGettingEngineHash',
  SymbolizationNoteKind.exceptionWhileSymbolizing: 'exceptionWhileSymbolizing',
  SymbolizationNoteKind.exceptionWhileLookingByBuildId:
      'exceptionWhileLookingByBuildId',
  SymbolizationNoteKind.defaultedToReleaseBuildIdUnavailable:
      'defaultedToReleaseBuildIdUnavailable',
  SymbolizationNoteKind.noSymbolsAvailableOnIos: 'noSymbolsAvailableOnIos',
  SymbolizationNoteKind.buildIdMismatch: 'buildIdMismatch',
  SymbolizationNoteKind.loadBaseDetected: 'loadBaseDetected',
  SymbolizationNoteKind.exceptionWhileParsing: 'exceptionWhileParsing',
};

_$ServerConfigImpl _$$ServerConfigImplFromJson(Map<String, dynamic> json) =>
    _$ServerConfigImpl(
      githubToken: json['githubToken'] as String,
    );

Map<String, dynamic> _$$ServerConfigImplToJson(_$ServerConfigImpl instance) =>
    <String, dynamic>{
      'githubToken': instance.githubToken,
    };
