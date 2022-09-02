// GENERATED CODE - DO NOT MODIFY BY HAND

part of symbolizer.model;

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_EngineVariant _$$_EngineVariantFromJson(Map<String, dynamic> json) =>
    _$_EngineVariant(
      os: json['os'] as String,
      arch: json['arch'] as String?,
      mode: json['mode'] as String?,
    );

Map<String, dynamic> _$$_EngineVariantToJson(_$_EngineVariant instance) =>
    <String, dynamic>{
      'os': instance.os,
      'arch': instance.arch,
      'mode': instance.mode,
    };

_$_EngineBuild _$$_EngineBuildFromJson(Map<String, dynamic> json) =>
    _$_EngineBuild(
      engineHash: json['engineHash'] as String,
      variant: EngineVariant.fromJson(json['variant'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$_EngineBuildToJson(_$_EngineBuild instance) =>
    <String, dynamic>{
      'engineHash': instance.engineHash,
      'variant': instance.variant,
    };

_$IosCrashFrame _$$IosCrashFrameFromJson(Map<String, dynamic> json) =>
    _$IosCrashFrame(
      no: json['no'] as String,
      binary: json['binary'] as String,
      pc: json['pc'] as int,
      symbol: json['symbol'] as String,
      offset: json['offset'] as int?,
      location: json['location'] as String,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$IosCrashFrameToJson(_$IosCrashFrame instance) =>
    <String, dynamic>{
      'no': instance.no,
      'binary': instance.binary,
      'pc': instance.pc,
      'symbol': instance.symbol,
      'offset': instance.offset,
      'location': instance.location,
      'runtimeType': instance.$type,
    };

_$AndroidCrashFrame _$$AndroidCrashFrameFromJson(Map<String, dynamic> json) =>
    _$AndroidCrashFrame(
      no: json['no'] as String,
      pc: json['pc'] as int,
      binary: json['binary'] as String,
      rest: json['rest'] as String,
      buildId: json['buildId'] as String?,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$AndroidCrashFrameToJson(_$AndroidCrashFrame instance) =>
    <String, dynamic>{
      'no': instance.no,
      'pc': instance.pc,
      'binary': instance.binary,
      'rest': instance.rest,
      'buildId': instance.buildId,
      'runtimeType': instance.$type,
    };

_$CustomCrashFrame _$$CustomCrashFrameFromJson(Map<String, dynamic> json) =>
    _$CustomCrashFrame(
      no: json['no'] as String,
      pc: json['pc'] as int,
      binary: json['binary'] as String,
      offset: json['offset'] as int?,
      location: json['location'] as String?,
      symbol: json['symbol'] as String?,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$CustomCrashFrameToJson(_$CustomCrashFrame instance) =>
    <String, dynamic>{
      'no': instance.no,
      'pc': instance.pc,
      'binary': instance.binary,
      'offset': instance.offset,
      'location': instance.location,
      'symbol': instance.symbol,
      'runtimeType': instance.$type,
    };

_$DartvmCrashFrame _$$DartvmCrashFrameFromJson(Map<String, dynamic> json) =>
    _$DartvmCrashFrame(
      pc: json['pc'] as int,
      binary: json['binary'] as String,
      offset: json['offset'] as int,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$DartvmCrashFrameToJson(_$DartvmCrashFrame instance) =>
    <String, dynamic>{
      'pc': instance.pc,
      'binary': instance.binary,
      'offset': instance.offset,
      'runtimeType': instance.$type,
    };

_$_Crash _$$_CrashFromJson(Map<String, dynamic> json) => _$_Crash(
      engineVariant:
          EngineVariant.fromJson(json['engineVariant'] as Map<String, dynamic>),
      frames: (json['frames'] as List<dynamic>)
          .map((e) => CrashFrame.fromJson(e as Map<String, dynamic>))
          .toList(),
      format: json['format'] as String,
      androidMajorVersion: json['androidMajorVersion'] as int?,
    );

Map<String, dynamic> _$$_CrashToJson(_$_Crash instance) => <String, dynamic>{
      'engineVariant': instance.engineVariant,
      'frames': instance.frames,
      'format': instance.format,
      'androidMajorVersion': instance.androidMajorVersion,
    };

_$SymbolizationResultOk _$$SymbolizationResultOkFromJson(
        Map<String, dynamic> json) =>
    _$SymbolizationResultOk(
      results: (json['results'] as List<dynamic>)
          .map((e) =>
              CrashSymbolizationResult.fromJson(e as Map<String, dynamic>))
          .toList(),
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$SymbolizationResultOkToJson(
        _$SymbolizationResultOk instance) =>
    <String, dynamic>{
      'results': instance.results.map((e) => e.toJson()).toList(),
      'runtimeType': instance.$type,
    };

_$SymbolizationResultError _$$SymbolizationResultErrorFromJson(
        Map<String, dynamic> json) =>
    _$SymbolizationResultError(
      error: SymbolizationNote.fromJson(json['error'] as Map<String, dynamic>),
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$SymbolizationResultErrorToJson(
        _$SymbolizationResultError instance) =>
    <String, dynamic>{
      'error': instance.error.toJson(),
      'runtimeType': instance.$type,
    };

_$_CrashSymbolizationResult _$$_CrashSymbolizationResultFromJson(
        Map<String, dynamic> json) =>
    _$_CrashSymbolizationResult(
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

Map<String, dynamic> _$$_CrashSymbolizationResultToJson(
        _$_CrashSymbolizationResult instance) =>
    <String, dynamic>{
      'crash': instance.crash.toJson(),
      'engineBuild': instance.engineBuild?.toJson(),
      'symbolized': instance.symbolized,
      'notes': instance.notes.map((e) => e.toJson()).toList(),
    };

_$_SymbolizationNote _$$_SymbolizationNoteFromJson(Map<String, dynamic> json) =>
    _$_SymbolizationNote(
      kind: $enumDecode(_$SymbolizationNoteKindEnumMap, json['kind']),
      message: json['message'] as String?,
    );

Map<String, dynamic> _$$_SymbolizationNoteToJson(
        _$_SymbolizationNote instance) =>
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

_$_ServerConfig _$$_ServerConfigFromJson(Map<String, dynamic> json) =>
    _$_ServerConfig(
      githubToken: json['githubToken'] as String,
      sendgridToken: json['sendgridToken'] as String,
      failureEmail: json['failureEmail'] as String,
    );

Map<String, dynamic> _$$_ServerConfigToJson(_$_ServerConfig instance) =>
    <String, dynamic>{
      'githubToken': instance.githubToken,
      'sendgridToken': instance.sendgridToken,
      'failureEmail': instance.failureEmail,
    };
