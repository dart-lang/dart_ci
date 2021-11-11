// GENERATED CODE - DO NOT MODIFY BY HAND

part of symbolizer.model;

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_EngineVariant _$_$_EngineVariantFromJson(Map<String, dynamic> json) {
  return _$_EngineVariant(
    os: json['os'] as String,
    arch: json['arch'] as String,
    mode: json['mode'] as String,
  );
}

Map<String, dynamic> _$_$_EngineVariantToJson(_$_EngineVariant instance) =>
    <String, dynamic>{
      'os': instance.os,
      'arch': instance.arch,
      'mode': instance.mode,
    };

_$_EngineBuild _$_$_EngineBuildFromJson(Map<String, dynamic> json) {
  return _$_EngineBuild(
    engineHash: json['engineHash'] as String,
    variant: json['variant'] == null
        ? null
        : EngineVariant.fromJson(json['variant'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$_$_EngineBuildToJson(_$_EngineBuild instance) =>
    <String, dynamic>{
      'engineHash': instance.engineHash,
      'variant': instance.variant,
    };

_$IosCrashFrame _$_$IosCrashFrameFromJson(Map<String, dynamic> json) {
  return _$IosCrashFrame(
    no: json['no'] as String,
    binary: json['binary'] as String,
    pc: json['pc'] as int,
    symbol: json['symbol'] as String,
    offset: json['offset'] as int,
    location: json['location'] as String,
  );
}

Map<String, dynamic> _$_$IosCrashFrameToJson(_$IosCrashFrame instance) =>
    <String, dynamic>{
      'no': instance.no,
      'binary': instance.binary,
      'pc': instance.pc,
      'symbol': instance.symbol,
      'offset': instance.offset,
      'location': instance.location,
    };

_$AndroidCrashFrame _$_$AndroidCrashFrameFromJson(Map<String, dynamic> json) {
  return _$AndroidCrashFrame(
    no: json['no'] as String,
    pc: json['pc'] as int,
    binary: json['binary'] as String,
    rest: json['rest'] as String,
    buildId: json['buildId'] as String,
  );
}

Map<String, dynamic> _$_$AndroidCrashFrameToJson(
        _$AndroidCrashFrame instance) =>
    <String, dynamic>{
      'no': instance.no,
      'pc': instance.pc,
      'binary': instance.binary,
      'rest': instance.rest,
      'buildId': instance.buildId,
    };

_$CustomCrashFrame _$_$CustomCrashFrameFromJson(Map<String, dynamic> json) {
  return _$CustomCrashFrame(
    no: json['no'] as String,
    pc: json['pc'] as int,
    binary: json['binary'] as String,
    offset: json['offset'] as int,
    location: json['location'] as String,
    symbol: json['symbol'] as String,
  );
}

Map<String, dynamic> _$_$CustomCrashFrameToJson(_$CustomCrashFrame instance) =>
    <String, dynamic>{
      'no': instance.no,
      'pc': instance.pc,
      'binary': instance.binary,
      'offset': instance.offset,
      'location': instance.location,
      'symbol': instance.symbol,
    };

_$DartvmCrashFrame _$_$DartvmCrashFrameFromJson(Map<String, dynamic> json) {
  return _$DartvmCrashFrame(
    pc: json['pc'] as int,
    binary: json['binary'] as String,
    offset: json['offset'] as int,
  );
}

Map<String, dynamic> _$_$DartvmCrashFrameToJson(_$DartvmCrashFrame instance) =>
    <String, dynamic>{
      'pc': instance.pc,
      'binary': instance.binary,
      'offset': instance.offset,
    };

_$_Crash _$_$_CrashFromJson(Map<String, dynamic> json) {
  return _$_Crash(
    engineVariant: json['engineVariant'] == null
        ? null
        : EngineVariant.fromJson(json['engineVariant'] as Map<String, dynamic>),
    frames: (json['frames'] as List)
        ?.map((e) =>
            e == null ? null : CrashFrame.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    format: json['format'] as String,
    androidMajorVersion: json['androidMajorVersion'] as int,
  );
}

Map<String, dynamic> _$_$_CrashToJson(_$_Crash instance) => <String, dynamic>{
      'engineVariant': instance.engineVariant,
      'frames': instance.frames,
      'format': instance.format,
      'androidMajorVersion': instance.androidMajorVersion,
    };

_$SymbolizationResultOk _$_$SymbolizationResultOkFromJson(
    Map<String, dynamic> json) {
  return _$SymbolizationResultOk(
    results: (json['results'] as List)
        ?.map((e) => e == null
            ? null
            : CrashSymbolizationResult.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$_$SymbolizationResultOkToJson(
        _$SymbolizationResultOk instance) =>
    <String, dynamic>{
      'results': instance.results?.map((e) => e?.toJson())?.toList(),
    };

_$SymbolizationResultError _$_$SymbolizationResultErrorFromJson(
    Map<String, dynamic> json) {
  return _$SymbolizationResultError(
    error: json['error'] == null
        ? null
        : SymbolizationNote.fromJson(json['error'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$_$SymbolizationResultErrorToJson(
        _$SymbolizationResultError instance) =>
    <String, dynamic>{
      'error': instance.error?.toJson(),
    };

_$_CrashSymbolizationResult _$_$_CrashSymbolizationResultFromJson(
    Map<String, dynamic> json) {
  return _$_CrashSymbolizationResult(
    crash: json['crash'] == null
        ? null
        : Crash.fromJson(json['crash'] as Map<String, dynamic>),
    engineBuild: json['engineBuild'] == null
        ? null
        : EngineBuild.fromJson(json['engineBuild'] as Map<String, dynamic>),
    symbolized: json['symbolized'] as String,
    notes: (json['notes'] as List)
            ?.map((e) => e == null
                ? null
                : SymbolizationNote.fromJson(e as Map<String, dynamic>))
            ?.toList() ??
        [],
  );
}

Map<String, dynamic> _$_$_CrashSymbolizationResultToJson(
        _$_CrashSymbolizationResult instance) =>
    <String, dynamic>{
      'crash': instance.crash?.toJson(),
      'engineBuild': instance.engineBuild?.toJson(),
      'symbolized': instance.symbolized,
      'notes': instance.notes?.map((e) => e?.toJson())?.toList(),
    };

_$_SymbolizationNote _$_$_SymbolizationNoteFromJson(Map<String, dynamic> json) {
  return _$_SymbolizationNote(
    kind: _$enumDecodeNullable(_$SymbolizationNoteKindEnumMap, json['kind']),
    message: json['message'] as String,
  );
}

Map<String, dynamic> _$_$_SymbolizationNoteToJson(
        _$_SymbolizationNote instance) =>
    <String, dynamic>{
      'kind': _$SymbolizationNoteKindEnumMap[instance.kind],
      'message': instance.message,
    };

T _$enumDecode<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    throw ArgumentError('A value must be provided. Supported values: '
        '${enumValues.values.join(', ')}');
  }

  final value = enumValues.entries
      .singleWhere((e) => e.value == source, orElse: () => null)
      ?.key;

  if (value == null && unknownValue == null) {
    throw ArgumentError('`$source` is not one of the supported values: '
        '${enumValues.values.join(', ')}');
  }
  return value ?? unknownValue;
}

T _$enumDecodeNullable<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<T>(enumValues, source, unknownValue: unknownValue);
}

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

_$_ServerConfig _$_$_ServerConfigFromJson(Map<String, dynamic> json) {
  return _$_ServerConfig(
    githubToken: json['githubToken'] as String,
    sendgridToken: json['sendgridToken'] as String,
    failureEmail: json['failureEmail'] as String,
  );
}

Map<String, dynamic> _$_$_ServerConfigToJson(_$_ServerConfig instance) =>
    <String, dynamic>{
      'githubToken': instance.githubToken,
      'sendgridToken': instance.sendgridToken,
      'failureEmail': instance.failureEmail,
    };
