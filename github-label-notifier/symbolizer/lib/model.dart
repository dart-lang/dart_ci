// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Data model shared between client and server.
library symbolizer.model;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'model.freezed.dart';
part 'model.g.dart';

/// Specifies an engine variant (a combination of target os, CPU architecture
/// and build mode).
@freezed
class EngineVariant with _$EngineVariant {
  factory EngineVariant({
    required String os,
    required String? arch,
    required String? mode,
  }) = _EngineVariant;
  factory EngineVariant.fromJson(Map<String, dynamic> json) =>
      _$EngineVariantFromJson(json);

  /// Generate all posibile variants from the given [variant] by varying
  /// [EngineVariant.mode].
  static Iterable<EngineVariant> allModesFor(EngineVariant variant) sync* {
    for (var mode in [
      'debug',
      if (!_isX86Variant(variant)) 'release',
      if (!_isX86Variant(variant)) 'profile'
    ]) {
      yield variant.copyWith(mode: mode);
    }
  }

  static bool _isX86Variant(EngineVariant variant) =>
      variant.arch == 'x86' || variant.arch == 'x64';
}

extension EngineVariantEx on EngineVariant {
  String get pretty => '$os-$arch-$mode';
}

/// Specific engine variant built at the given engine hash.
@freezed
class EngineBuild with _$EngineBuild {
  factory EngineBuild({
    required String engineHash,
    required EngineVariant variant,
  }) = _EngineBuild;

  factory EngineBuild.fromJson(Map<String, dynamic> json) =>
      _$EngineBuildFromJson(json);
}

/// Backtrace frame extracted from a textual crash report.
@freezed
class CrashFrame with _$CrashFrame {
  /// Frame of a native iOS crash.
  factory CrashFrame.ios({
    required String no,
    required String binary,

    /// Absolute PC of the frame.
    required int pc,
    required String symbol,
    required int? offset,
    required String location,
  }) = IosCrashFrame;

  /// Frame of a native Android crash.
  factory CrashFrame.android({
    required String no,

    /// Relative PC of the frame.
    required int pc,
    required String binary,
    required String rest,
    required String? buildId,
  }) = AndroidCrashFrame;

  factory CrashFrame.custom({
    required String no,
    required int pc,
    required String binary,
    required int? offset,
    required String? location,
    required String? symbol,
  }) = CustomCrashFrame;

  /// Frame of a Dart VM crash.
  factory CrashFrame.dartvm({
    /// Absolute PC of the frame.
    required int pc,

    /// Binary which contains the given PC.
    required String binary,

    /// Offset from load base of the binary to the PC.
    required int offset,
  }) = DartvmCrashFrame;

  factory CrashFrame.fromJson(Map<String, dynamic> json) =>
      _$CrashFrameFromJson(json);

  static const crashalyticsMissingSymbol = '(Missing)';
}

/// Information about an engine crash extracted from a GitHub comment.
@freezed
class Crash with _$Crash {
  factory Crash({
    required EngineVariant engineVariant,
    required List<CrashFrame> frames,
    required String format,
    int? androidMajorVersion,
  }) = _Crash;

  factory Crash.fromJson(Map<String, dynamic> json) => _$CrashFromJson(json);
}

enum SymbolizationNoteKind {
  unknownEngineHash,
  unknownAbi,
  exceptionWhileGettingEngineHash,
  exceptionWhileSymbolizing,
  exceptionWhileLookingByBuildId,
  defaultedToReleaseBuildIdUnavailable,
  noSymbolsAvailableOnIos,
  buildIdMismatch,
  loadBaseDetected,
  exceptionWhileParsing,
}

const noteMessage = <SymbolizationNoteKind, String>{
  SymbolizationNoteKind.unknownEngineHash: 'Unknown engine hash',
  SymbolizationNoteKind.unknownAbi: 'Unknown engine ABI',
  SymbolizationNoteKind.exceptionWhileGettingEngineHash:
      'Exception occurred while trying to lookup full engine hash',
  SymbolizationNoteKind.exceptionWhileSymbolizing:
      'Exception occurred while symbolizing',
  SymbolizationNoteKind.exceptionWhileLookingByBuildId:
      'Exception occurred while trying to find symbols using build-id',
  SymbolizationNoteKind.defaultedToReleaseBuildIdUnavailable:
      'Defaulted to release engine because build-id is unavailable or unreliable',
  SymbolizationNoteKind.noSymbolsAvailableOnIos:
      'Symbols are available only for release iOS builds',
  SymbolizationNoteKind.buildIdMismatch: 'Build-ID mismatch',
  SymbolizationNoteKind.loadBaseDetected:
      'Load address missing from the report, detected heuristically',
  SymbolizationNoteKind.exceptionWhileParsing:
      'Exception occured while parsing',
};

@freezed
class SymbolizationResult with _$SymbolizationResult {
  @JsonSerializable(explicitToJson: true)
  factory SymbolizationResult.ok({
    required List<CrashSymbolizationResult> results,
  }) = SymbolizationResultOk;

  @JsonSerializable(explicitToJson: true)
  factory SymbolizationResult.error({
    required SymbolizationNote error,
  }) = SymbolizationResultError;

  factory SymbolizationResult.fromJson(Map<String, dynamic> json) =>
      _$SymbolizationResultFromJson(json);
}

/// Result of symbolizing an engine crash.
@freezed
class CrashSymbolizationResult with _$CrashSymbolizationResult {
  @JsonSerializable(explicitToJson: true)
  factory CrashSymbolizationResult({
    required Crash crash,
    required EngineBuild? engineBuild,

    /// Symbolization result - not null if symbolization succeeded.
    required String? symbolized,
    @Default([]) List<SymbolizationNote> notes,
  }) = _CrashSymbolizationResult;

  factory CrashSymbolizationResult.fromJson(Map<String, dynamic> json) =>
      _$CrashSymbolizationResultFromJson(json);
}

extension WithNote on CrashSymbolizationResult {
  CrashSymbolizationResult withNote(SymbolizationNoteKind kind,
      [String? message]) {
    return copyWith(
      notes: [
        ...notes,
        SymbolizationNote(kind: kind, message: message),
      ],
    );
  }
}

@freezed
class SymbolizationNote with _$SymbolizationNote {
  factory SymbolizationNote(
      {required SymbolizationNoteKind kind,
      String? message}) = _SymbolizationNote;

  factory SymbolizationNote.fromJson(Map<String, dynamic> json) =>
      _$SymbolizationNoteFromJson(json);
}

/// Command to [Bot].
@freezed
class BotCommand with _$BotCommand {
  factory BotCommand({
    /// Overrides that should be used for symbolization. These overrides
    /// replace or augment information available in the comments themselves.
    required SymbolizationOverrides overrides,

    /// [true] if the user requested to symbolize the comment that contains
    /// command.
    required bool symbolizeThis,

    /// List of references to comments which need to be symbolized. Each reference
    /// is either in `issue-id` or in `issuecomment-id` format.
    required Set<String> worklist,
  }) = _BotCommand;
}

@freezed
class SymbolizationOverrides with _$SymbolizationOverrides {
  factory SymbolizationOverrides({
    String? engineHash,
    String? flutterVersion,
    String? arch,
    String? mode,
    @Default(false) bool force,
    String? format,
    String? os,
  }) = _SymbolizationOverrides;
}

@freezed
class ServerConfig with _$ServerConfig {
  factory ServerConfig({
    required String githubToken,
    required String sendgridToken,
    required String failureEmail,
  }) = _ServerConfig;

  factory ServerConfig.fromJson(Map<String, dynamic> json) =>
      _$ServerConfigFromJson(json);
}
