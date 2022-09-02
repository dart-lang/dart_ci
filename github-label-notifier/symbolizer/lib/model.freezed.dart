// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of symbolizer.model;

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

EngineVariant _$EngineVariantFromJson(Map<String, dynamic> json) {
  return _EngineVariant.fromJson(json);
}

/// @nodoc
mixin _$EngineVariant {
  String get os => throw _privateConstructorUsedError;
  String? get arch => throw _privateConstructorUsedError;
  String? get mode => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $EngineVariantCopyWith<EngineVariant> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EngineVariantCopyWith<$Res> {
  factory $EngineVariantCopyWith(
          EngineVariant value, $Res Function(EngineVariant) then) =
      _$EngineVariantCopyWithImpl<$Res>;
  $Res call({String os, String? arch, String? mode});
}

/// @nodoc
class _$EngineVariantCopyWithImpl<$Res>
    implements $EngineVariantCopyWith<$Res> {
  _$EngineVariantCopyWithImpl(this._value, this._then);

  final EngineVariant _value;
  // ignore: unused_field
  final $Res Function(EngineVariant) _then;

  @override
  $Res call({
    Object? os = freezed,
    Object? arch = freezed,
    Object? mode = freezed,
  }) {
    return _then(_value.copyWith(
      os: os == freezed
          ? _value.os
          : os // ignore: cast_nullable_to_non_nullable
              as String,
      arch: arch == freezed
          ? _value.arch
          : arch // ignore: cast_nullable_to_non_nullable
              as String?,
      mode: mode == freezed
          ? _value.mode
          : mode // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
abstract class _$$_EngineVariantCopyWith<$Res>
    implements $EngineVariantCopyWith<$Res> {
  factory _$$_EngineVariantCopyWith(
          _$_EngineVariant value, $Res Function(_$_EngineVariant) then) =
      __$$_EngineVariantCopyWithImpl<$Res>;
  @override
  $Res call({String os, String? arch, String? mode});
}

/// @nodoc
class __$$_EngineVariantCopyWithImpl<$Res>
    extends _$EngineVariantCopyWithImpl<$Res>
    implements _$$_EngineVariantCopyWith<$Res> {
  __$$_EngineVariantCopyWithImpl(
      _$_EngineVariant _value, $Res Function(_$_EngineVariant) _then)
      : super(_value, (v) => _then(v as _$_EngineVariant));

  @override
  _$_EngineVariant get _value => super._value as _$_EngineVariant;

  @override
  $Res call({
    Object? os = freezed,
    Object? arch = freezed,
    Object? mode = freezed,
  }) {
    return _then(_$_EngineVariant(
      os: os == freezed
          ? _value.os
          : os // ignore: cast_nullable_to_non_nullable
              as String,
      arch: arch == freezed
          ? _value.arch
          : arch // ignore: cast_nullable_to_non_nullable
              as String?,
      mode: mode == freezed
          ? _value.mode
          : mode // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_EngineVariant implements _EngineVariant {
  _$_EngineVariant({required this.os, required this.arch, required this.mode});

  factory _$_EngineVariant.fromJson(Map<String, dynamic> json) =>
      _$$_EngineVariantFromJson(json);

  @override
  final String os;
  @override
  final String? arch;
  @override
  final String? mode;

  @override
  String toString() {
    return 'EngineVariant(os: $os, arch: $arch, mode: $mode)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_EngineVariant &&
            const DeepCollectionEquality().equals(other.os, os) &&
            const DeepCollectionEquality().equals(other.arch, arch) &&
            const DeepCollectionEquality().equals(other.mode, mode));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(os),
      const DeepCollectionEquality().hash(arch),
      const DeepCollectionEquality().hash(mode));

  @JsonKey(ignore: true)
  @override
  _$$_EngineVariantCopyWith<_$_EngineVariant> get copyWith =>
      __$$_EngineVariantCopyWithImpl<_$_EngineVariant>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_EngineVariantToJson(
      this,
    );
  }
}

abstract class _EngineVariant implements EngineVariant {
  factory _EngineVariant(
      {required final String os,
      required final String? arch,
      required final String? mode}) = _$_EngineVariant;

  factory _EngineVariant.fromJson(Map<String, dynamic> json) =
      _$_EngineVariant.fromJson;

  @override
  String get os;
  @override
  String? get arch;
  @override
  String? get mode;
  @override
  @JsonKey(ignore: true)
  _$$_EngineVariantCopyWith<_$_EngineVariant> get copyWith =>
      throw _privateConstructorUsedError;
}

EngineBuild _$EngineBuildFromJson(Map<String, dynamic> json) {
  return _EngineBuild.fromJson(json);
}

/// @nodoc
mixin _$EngineBuild {
  String get engineHash => throw _privateConstructorUsedError;
  EngineVariant get variant => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $EngineBuildCopyWith<EngineBuild> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EngineBuildCopyWith<$Res> {
  factory $EngineBuildCopyWith(
          EngineBuild value, $Res Function(EngineBuild) then) =
      _$EngineBuildCopyWithImpl<$Res>;
  $Res call({String engineHash, EngineVariant variant});

  $EngineVariantCopyWith<$Res> get variant;
}

/// @nodoc
class _$EngineBuildCopyWithImpl<$Res> implements $EngineBuildCopyWith<$Res> {
  _$EngineBuildCopyWithImpl(this._value, this._then);

  final EngineBuild _value;
  // ignore: unused_field
  final $Res Function(EngineBuild) _then;

  @override
  $Res call({
    Object? engineHash = freezed,
    Object? variant = freezed,
  }) {
    return _then(_value.copyWith(
      engineHash: engineHash == freezed
          ? _value.engineHash
          : engineHash // ignore: cast_nullable_to_non_nullable
              as String,
      variant: variant == freezed
          ? _value.variant
          : variant // ignore: cast_nullable_to_non_nullable
              as EngineVariant,
    ));
  }

  @override
  $EngineVariantCopyWith<$Res> get variant {
    return $EngineVariantCopyWith<$Res>(_value.variant, (value) {
      return _then(_value.copyWith(variant: value));
    });
  }
}

/// @nodoc
abstract class _$$_EngineBuildCopyWith<$Res>
    implements $EngineBuildCopyWith<$Res> {
  factory _$$_EngineBuildCopyWith(
          _$_EngineBuild value, $Res Function(_$_EngineBuild) then) =
      __$$_EngineBuildCopyWithImpl<$Res>;
  @override
  $Res call({String engineHash, EngineVariant variant});

  @override
  $EngineVariantCopyWith<$Res> get variant;
}

/// @nodoc
class __$$_EngineBuildCopyWithImpl<$Res> extends _$EngineBuildCopyWithImpl<$Res>
    implements _$$_EngineBuildCopyWith<$Res> {
  __$$_EngineBuildCopyWithImpl(
      _$_EngineBuild _value, $Res Function(_$_EngineBuild) _then)
      : super(_value, (v) => _then(v as _$_EngineBuild));

  @override
  _$_EngineBuild get _value => super._value as _$_EngineBuild;

  @override
  $Res call({
    Object? engineHash = freezed,
    Object? variant = freezed,
  }) {
    return _then(_$_EngineBuild(
      engineHash: engineHash == freezed
          ? _value.engineHash
          : engineHash // ignore: cast_nullable_to_non_nullable
              as String,
      variant: variant == freezed
          ? _value.variant
          : variant // ignore: cast_nullable_to_non_nullable
              as EngineVariant,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_EngineBuild implements _EngineBuild {
  _$_EngineBuild({required this.engineHash, required this.variant});

  factory _$_EngineBuild.fromJson(Map<String, dynamic> json) =>
      _$$_EngineBuildFromJson(json);

  @override
  final String engineHash;
  @override
  final EngineVariant variant;

  @override
  String toString() {
    return 'EngineBuild(engineHash: $engineHash, variant: $variant)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_EngineBuild &&
            const DeepCollectionEquality()
                .equals(other.engineHash, engineHash) &&
            const DeepCollectionEquality().equals(other.variant, variant));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(engineHash),
      const DeepCollectionEquality().hash(variant));

  @JsonKey(ignore: true)
  @override
  _$$_EngineBuildCopyWith<_$_EngineBuild> get copyWith =>
      __$$_EngineBuildCopyWithImpl<_$_EngineBuild>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_EngineBuildToJson(
      this,
    );
  }
}

abstract class _EngineBuild implements EngineBuild {
  factory _EngineBuild(
      {required final String engineHash,
      required final EngineVariant variant}) = _$_EngineBuild;

  factory _EngineBuild.fromJson(Map<String, dynamic> json) =
      _$_EngineBuild.fromJson;

  @override
  String get engineHash;
  @override
  EngineVariant get variant;
  @override
  @JsonKey(ignore: true)
  _$$_EngineBuildCopyWith<_$_EngineBuild> get copyWith =>
      throw _privateConstructorUsedError;
}

CrashFrame _$CrashFrameFromJson(Map<String, dynamic> json) {
  switch (json['runtimeType']) {
    case 'ios':
      return IosCrashFrame.fromJson(json);
    case 'android':
      return AndroidCrashFrame.fromJson(json);
    case 'custom':
      return CustomCrashFrame.fromJson(json);
    case 'dartvm':
      return DartvmCrashFrame.fromJson(json);

    default:
      throw CheckedFromJsonException(json, 'runtimeType', 'CrashFrame',
          'Invalid union type "${json['runtimeType']}"!');
  }
}

/// @nodoc
mixin _$CrashFrame {
  String get binary => throw _privateConstructorUsedError;

  /// Absolute PC of the frame.
  int get pc => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String no, String binary, int pc, String symbol,
            int? offset, String location)
        ios,
    required TResult Function(
            String no, int pc, String binary, String rest, String? buildId)
        android,
    required TResult Function(String no, int pc, String binary, int? offset,
            String? location, String? symbol)
        custom,
    required TResult Function(int pc, String binary, int offset) dartvm,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(String no, String binary, int pc, String symbol,
            int? offset, String location)?
        ios,
    TResult Function(
            String no, int pc, String binary, String rest, String? buildId)?
        android,
    TResult Function(String no, int pc, String binary, int? offset,
            String? location, String? symbol)?
        custom,
    TResult Function(int pc, String binary, int offset)? dartvm,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String no, String binary, int pc, String symbol,
            int? offset, String location)?
        ios,
    TResult Function(
            String no, int pc, String binary, String rest, String? buildId)?
        android,
    TResult Function(String no, int pc, String binary, int? offset,
            String? location, String? symbol)?
        custom,
    TResult Function(int pc, String binary, int offset)? dartvm,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(IosCrashFrame value) ios,
    required TResult Function(AndroidCrashFrame value) android,
    required TResult Function(CustomCrashFrame value) custom,
    required TResult Function(DartvmCrashFrame value) dartvm,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(IosCrashFrame value)? ios,
    TResult Function(AndroidCrashFrame value)? android,
    TResult Function(CustomCrashFrame value)? custom,
    TResult Function(DartvmCrashFrame value)? dartvm,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(IosCrashFrame value)? ios,
    TResult Function(AndroidCrashFrame value)? android,
    TResult Function(CustomCrashFrame value)? custom,
    TResult Function(DartvmCrashFrame value)? dartvm,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CrashFrameCopyWith<CrashFrame> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CrashFrameCopyWith<$Res> {
  factory $CrashFrameCopyWith(
          CrashFrame value, $Res Function(CrashFrame) then) =
      _$CrashFrameCopyWithImpl<$Res>;
  $Res call({String binary, int pc});
}

/// @nodoc
class _$CrashFrameCopyWithImpl<$Res> implements $CrashFrameCopyWith<$Res> {
  _$CrashFrameCopyWithImpl(this._value, this._then);

  final CrashFrame _value;
  // ignore: unused_field
  final $Res Function(CrashFrame) _then;

  @override
  $Res call({
    Object? binary = freezed,
    Object? pc = freezed,
  }) {
    return _then(_value.copyWith(
      binary: binary == freezed
          ? _value.binary
          : binary // ignore: cast_nullable_to_non_nullable
              as String,
      pc: pc == freezed
          ? _value.pc
          : pc // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
abstract class _$$IosCrashFrameCopyWith<$Res>
    implements $CrashFrameCopyWith<$Res> {
  factory _$$IosCrashFrameCopyWith(
          _$IosCrashFrame value, $Res Function(_$IosCrashFrame) then) =
      __$$IosCrashFrameCopyWithImpl<$Res>;
  @override
  $Res call(
      {String no,
      String binary,
      int pc,
      String symbol,
      int? offset,
      String location});
}

/// @nodoc
class __$$IosCrashFrameCopyWithImpl<$Res> extends _$CrashFrameCopyWithImpl<$Res>
    implements _$$IosCrashFrameCopyWith<$Res> {
  __$$IosCrashFrameCopyWithImpl(
      _$IosCrashFrame _value, $Res Function(_$IosCrashFrame) _then)
      : super(_value, (v) => _then(v as _$IosCrashFrame));

  @override
  _$IosCrashFrame get _value => super._value as _$IosCrashFrame;

  @override
  $Res call({
    Object? no = freezed,
    Object? binary = freezed,
    Object? pc = freezed,
    Object? symbol = freezed,
    Object? offset = freezed,
    Object? location = freezed,
  }) {
    return _then(_$IosCrashFrame(
      no: no == freezed
          ? _value.no
          : no // ignore: cast_nullable_to_non_nullable
              as String,
      binary: binary == freezed
          ? _value.binary
          : binary // ignore: cast_nullable_to_non_nullable
              as String,
      pc: pc == freezed
          ? _value.pc
          : pc // ignore: cast_nullable_to_non_nullable
              as int,
      symbol: symbol == freezed
          ? _value.symbol
          : symbol // ignore: cast_nullable_to_non_nullable
              as String,
      offset: offset == freezed
          ? _value.offset
          : offset // ignore: cast_nullable_to_non_nullable
              as int?,
      location: location == freezed
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$IosCrashFrame implements IosCrashFrame {
  _$IosCrashFrame(
      {required this.no,
      required this.binary,
      required this.pc,
      required this.symbol,
      required this.offset,
      required this.location,
      final String? $type})
      : $type = $type ?? 'ios';

  factory _$IosCrashFrame.fromJson(Map<String, dynamic> json) =>
      _$$IosCrashFrameFromJson(json);

  @override
  final String no;
  @override
  final String binary;

  /// Absolute PC of the frame.
  @override
  final int pc;
  @override
  final String symbol;
  @override
  final int? offset;
  @override
  final String location;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'CrashFrame.ios(no: $no, binary: $binary, pc: $pc, symbol: $symbol, offset: $offset, location: $location)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$IosCrashFrame &&
            const DeepCollectionEquality().equals(other.no, no) &&
            const DeepCollectionEquality().equals(other.binary, binary) &&
            const DeepCollectionEquality().equals(other.pc, pc) &&
            const DeepCollectionEquality().equals(other.symbol, symbol) &&
            const DeepCollectionEquality().equals(other.offset, offset) &&
            const DeepCollectionEquality().equals(other.location, location));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(no),
      const DeepCollectionEquality().hash(binary),
      const DeepCollectionEquality().hash(pc),
      const DeepCollectionEquality().hash(symbol),
      const DeepCollectionEquality().hash(offset),
      const DeepCollectionEquality().hash(location));

  @JsonKey(ignore: true)
  @override
  _$$IosCrashFrameCopyWith<_$IosCrashFrame> get copyWith =>
      __$$IosCrashFrameCopyWithImpl<_$IosCrashFrame>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String no, String binary, int pc, String symbol,
            int? offset, String location)
        ios,
    required TResult Function(
            String no, int pc, String binary, String rest, String? buildId)
        android,
    required TResult Function(String no, int pc, String binary, int? offset,
            String? location, String? symbol)
        custom,
    required TResult Function(int pc, String binary, int offset) dartvm,
  }) {
    return ios(no, binary, pc, symbol, offset, location);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(String no, String binary, int pc, String symbol,
            int? offset, String location)?
        ios,
    TResult Function(
            String no, int pc, String binary, String rest, String? buildId)?
        android,
    TResult Function(String no, int pc, String binary, int? offset,
            String? location, String? symbol)?
        custom,
    TResult Function(int pc, String binary, int offset)? dartvm,
  }) {
    return ios?.call(no, binary, pc, symbol, offset, location);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String no, String binary, int pc, String symbol,
            int? offset, String location)?
        ios,
    TResult Function(
            String no, int pc, String binary, String rest, String? buildId)?
        android,
    TResult Function(String no, int pc, String binary, int? offset,
            String? location, String? symbol)?
        custom,
    TResult Function(int pc, String binary, int offset)? dartvm,
    required TResult orElse(),
  }) {
    if (ios != null) {
      return ios(no, binary, pc, symbol, offset, location);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(IosCrashFrame value) ios,
    required TResult Function(AndroidCrashFrame value) android,
    required TResult Function(CustomCrashFrame value) custom,
    required TResult Function(DartvmCrashFrame value) dartvm,
  }) {
    return ios(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(IosCrashFrame value)? ios,
    TResult Function(AndroidCrashFrame value)? android,
    TResult Function(CustomCrashFrame value)? custom,
    TResult Function(DartvmCrashFrame value)? dartvm,
  }) {
    return ios?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(IosCrashFrame value)? ios,
    TResult Function(AndroidCrashFrame value)? android,
    TResult Function(CustomCrashFrame value)? custom,
    TResult Function(DartvmCrashFrame value)? dartvm,
    required TResult orElse(),
  }) {
    if (ios != null) {
      return ios(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$IosCrashFrameToJson(
      this,
    );
  }
}

abstract class IosCrashFrame implements CrashFrame {
  factory IosCrashFrame(
      {required final String no,
      required final String binary,
      required final int pc,
      required final String symbol,
      required final int? offset,
      required final String location}) = _$IosCrashFrame;

  factory IosCrashFrame.fromJson(Map<String, dynamic> json) =
      _$IosCrashFrame.fromJson;

  String get no;
  @override
  String get binary;
  @override

  /// Absolute PC of the frame.
  int get pc;
  String get symbol;
  int? get offset;
  String get location;
  @override
  @JsonKey(ignore: true)
  _$$IosCrashFrameCopyWith<_$IosCrashFrame> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$AndroidCrashFrameCopyWith<$Res>
    implements $CrashFrameCopyWith<$Res> {
  factory _$$AndroidCrashFrameCopyWith(
          _$AndroidCrashFrame value, $Res Function(_$AndroidCrashFrame) then) =
      __$$AndroidCrashFrameCopyWithImpl<$Res>;
  @override
  $Res call({String no, int pc, String binary, String rest, String? buildId});
}

/// @nodoc
class __$$AndroidCrashFrameCopyWithImpl<$Res>
    extends _$CrashFrameCopyWithImpl<$Res>
    implements _$$AndroidCrashFrameCopyWith<$Res> {
  __$$AndroidCrashFrameCopyWithImpl(
      _$AndroidCrashFrame _value, $Res Function(_$AndroidCrashFrame) _then)
      : super(_value, (v) => _then(v as _$AndroidCrashFrame));

  @override
  _$AndroidCrashFrame get _value => super._value as _$AndroidCrashFrame;

  @override
  $Res call({
    Object? no = freezed,
    Object? pc = freezed,
    Object? binary = freezed,
    Object? rest = freezed,
    Object? buildId = freezed,
  }) {
    return _then(_$AndroidCrashFrame(
      no: no == freezed
          ? _value.no
          : no // ignore: cast_nullable_to_non_nullable
              as String,
      pc: pc == freezed
          ? _value.pc
          : pc // ignore: cast_nullable_to_non_nullable
              as int,
      binary: binary == freezed
          ? _value.binary
          : binary // ignore: cast_nullable_to_non_nullable
              as String,
      rest: rest == freezed
          ? _value.rest
          : rest // ignore: cast_nullable_to_non_nullable
              as String,
      buildId: buildId == freezed
          ? _value.buildId
          : buildId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AndroidCrashFrame implements AndroidCrashFrame {
  _$AndroidCrashFrame(
      {required this.no,
      required this.pc,
      required this.binary,
      required this.rest,
      required this.buildId,
      final String? $type})
      : $type = $type ?? 'android';

  factory _$AndroidCrashFrame.fromJson(Map<String, dynamic> json) =>
      _$$AndroidCrashFrameFromJson(json);

  @override
  final String no;

  /// Relative PC of the frame.
  @override
  final int pc;
  @override
  final String binary;
  @override
  final String rest;
  @override
  final String? buildId;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'CrashFrame.android(no: $no, pc: $pc, binary: $binary, rest: $rest, buildId: $buildId)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AndroidCrashFrame &&
            const DeepCollectionEquality().equals(other.no, no) &&
            const DeepCollectionEquality().equals(other.pc, pc) &&
            const DeepCollectionEquality().equals(other.binary, binary) &&
            const DeepCollectionEquality().equals(other.rest, rest) &&
            const DeepCollectionEquality().equals(other.buildId, buildId));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(no),
      const DeepCollectionEquality().hash(pc),
      const DeepCollectionEquality().hash(binary),
      const DeepCollectionEquality().hash(rest),
      const DeepCollectionEquality().hash(buildId));

  @JsonKey(ignore: true)
  @override
  _$$AndroidCrashFrameCopyWith<_$AndroidCrashFrame> get copyWith =>
      __$$AndroidCrashFrameCopyWithImpl<_$AndroidCrashFrame>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String no, String binary, int pc, String symbol,
            int? offset, String location)
        ios,
    required TResult Function(
            String no, int pc, String binary, String rest, String? buildId)
        android,
    required TResult Function(String no, int pc, String binary, int? offset,
            String? location, String? symbol)
        custom,
    required TResult Function(int pc, String binary, int offset) dartvm,
  }) {
    return android(no, pc, binary, rest, buildId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(String no, String binary, int pc, String symbol,
            int? offset, String location)?
        ios,
    TResult Function(
            String no, int pc, String binary, String rest, String? buildId)?
        android,
    TResult Function(String no, int pc, String binary, int? offset,
            String? location, String? symbol)?
        custom,
    TResult Function(int pc, String binary, int offset)? dartvm,
  }) {
    return android?.call(no, pc, binary, rest, buildId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String no, String binary, int pc, String symbol,
            int? offset, String location)?
        ios,
    TResult Function(
            String no, int pc, String binary, String rest, String? buildId)?
        android,
    TResult Function(String no, int pc, String binary, int? offset,
            String? location, String? symbol)?
        custom,
    TResult Function(int pc, String binary, int offset)? dartvm,
    required TResult orElse(),
  }) {
    if (android != null) {
      return android(no, pc, binary, rest, buildId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(IosCrashFrame value) ios,
    required TResult Function(AndroidCrashFrame value) android,
    required TResult Function(CustomCrashFrame value) custom,
    required TResult Function(DartvmCrashFrame value) dartvm,
  }) {
    return android(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(IosCrashFrame value)? ios,
    TResult Function(AndroidCrashFrame value)? android,
    TResult Function(CustomCrashFrame value)? custom,
    TResult Function(DartvmCrashFrame value)? dartvm,
  }) {
    return android?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(IosCrashFrame value)? ios,
    TResult Function(AndroidCrashFrame value)? android,
    TResult Function(CustomCrashFrame value)? custom,
    TResult Function(DartvmCrashFrame value)? dartvm,
    required TResult orElse(),
  }) {
    if (android != null) {
      return android(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$AndroidCrashFrameToJson(
      this,
    );
  }
}

abstract class AndroidCrashFrame implements CrashFrame {
  factory AndroidCrashFrame(
      {required final String no,
      required final int pc,
      required final String binary,
      required final String rest,
      required final String? buildId}) = _$AndroidCrashFrame;

  factory AndroidCrashFrame.fromJson(Map<String, dynamic> json) =
      _$AndroidCrashFrame.fromJson;

  String get no;
  @override

  /// Relative PC of the frame.
  int get pc;
  @override
  String get binary;
  String get rest;
  String? get buildId;
  @override
  @JsonKey(ignore: true)
  _$$AndroidCrashFrameCopyWith<_$AndroidCrashFrame> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$CustomCrashFrameCopyWith<$Res>
    implements $CrashFrameCopyWith<$Res> {
  factory _$$CustomCrashFrameCopyWith(
          _$CustomCrashFrame value, $Res Function(_$CustomCrashFrame) then) =
      __$$CustomCrashFrameCopyWithImpl<$Res>;
  @override
  $Res call(
      {String no,
      int pc,
      String binary,
      int? offset,
      String? location,
      String? symbol});
}

/// @nodoc
class __$$CustomCrashFrameCopyWithImpl<$Res>
    extends _$CrashFrameCopyWithImpl<$Res>
    implements _$$CustomCrashFrameCopyWith<$Res> {
  __$$CustomCrashFrameCopyWithImpl(
      _$CustomCrashFrame _value, $Res Function(_$CustomCrashFrame) _then)
      : super(_value, (v) => _then(v as _$CustomCrashFrame));

  @override
  _$CustomCrashFrame get _value => super._value as _$CustomCrashFrame;

  @override
  $Res call({
    Object? no = freezed,
    Object? pc = freezed,
    Object? binary = freezed,
    Object? offset = freezed,
    Object? location = freezed,
    Object? symbol = freezed,
  }) {
    return _then(_$CustomCrashFrame(
      no: no == freezed
          ? _value.no
          : no // ignore: cast_nullable_to_non_nullable
              as String,
      pc: pc == freezed
          ? _value.pc
          : pc // ignore: cast_nullable_to_non_nullable
              as int,
      binary: binary == freezed
          ? _value.binary
          : binary // ignore: cast_nullable_to_non_nullable
              as String,
      offset: offset == freezed
          ? _value.offset
          : offset // ignore: cast_nullable_to_non_nullable
              as int?,
      location: location == freezed
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      symbol: symbol == freezed
          ? _value.symbol
          : symbol // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CustomCrashFrame implements CustomCrashFrame {
  _$CustomCrashFrame(
      {required this.no,
      required this.pc,
      required this.binary,
      required this.offset,
      required this.location,
      required this.symbol,
      final String? $type})
      : $type = $type ?? 'custom';

  factory _$CustomCrashFrame.fromJson(Map<String, dynamic> json) =>
      _$$CustomCrashFrameFromJson(json);

  @override
  final String no;
  @override
  final int pc;
  @override
  final String binary;
  @override
  final int? offset;
  @override
  final String? location;
  @override
  final String? symbol;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'CrashFrame.custom(no: $no, pc: $pc, binary: $binary, offset: $offset, location: $location, symbol: $symbol)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CustomCrashFrame &&
            const DeepCollectionEquality().equals(other.no, no) &&
            const DeepCollectionEquality().equals(other.pc, pc) &&
            const DeepCollectionEquality().equals(other.binary, binary) &&
            const DeepCollectionEquality().equals(other.offset, offset) &&
            const DeepCollectionEquality().equals(other.location, location) &&
            const DeepCollectionEquality().equals(other.symbol, symbol));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(no),
      const DeepCollectionEquality().hash(pc),
      const DeepCollectionEquality().hash(binary),
      const DeepCollectionEquality().hash(offset),
      const DeepCollectionEquality().hash(location),
      const DeepCollectionEquality().hash(symbol));

  @JsonKey(ignore: true)
  @override
  _$$CustomCrashFrameCopyWith<_$CustomCrashFrame> get copyWith =>
      __$$CustomCrashFrameCopyWithImpl<_$CustomCrashFrame>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String no, String binary, int pc, String symbol,
            int? offset, String location)
        ios,
    required TResult Function(
            String no, int pc, String binary, String rest, String? buildId)
        android,
    required TResult Function(String no, int pc, String binary, int? offset,
            String? location, String? symbol)
        custom,
    required TResult Function(int pc, String binary, int offset) dartvm,
  }) {
    return custom(no, pc, binary, offset, location, symbol);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(String no, String binary, int pc, String symbol,
            int? offset, String location)?
        ios,
    TResult Function(
            String no, int pc, String binary, String rest, String? buildId)?
        android,
    TResult Function(String no, int pc, String binary, int? offset,
            String? location, String? symbol)?
        custom,
    TResult Function(int pc, String binary, int offset)? dartvm,
  }) {
    return custom?.call(no, pc, binary, offset, location, symbol);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String no, String binary, int pc, String symbol,
            int? offset, String location)?
        ios,
    TResult Function(
            String no, int pc, String binary, String rest, String? buildId)?
        android,
    TResult Function(String no, int pc, String binary, int? offset,
            String? location, String? symbol)?
        custom,
    TResult Function(int pc, String binary, int offset)? dartvm,
    required TResult orElse(),
  }) {
    if (custom != null) {
      return custom(no, pc, binary, offset, location, symbol);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(IosCrashFrame value) ios,
    required TResult Function(AndroidCrashFrame value) android,
    required TResult Function(CustomCrashFrame value) custom,
    required TResult Function(DartvmCrashFrame value) dartvm,
  }) {
    return custom(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(IosCrashFrame value)? ios,
    TResult Function(AndroidCrashFrame value)? android,
    TResult Function(CustomCrashFrame value)? custom,
    TResult Function(DartvmCrashFrame value)? dartvm,
  }) {
    return custom?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(IosCrashFrame value)? ios,
    TResult Function(AndroidCrashFrame value)? android,
    TResult Function(CustomCrashFrame value)? custom,
    TResult Function(DartvmCrashFrame value)? dartvm,
    required TResult orElse(),
  }) {
    if (custom != null) {
      return custom(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$CustomCrashFrameToJson(
      this,
    );
  }
}

abstract class CustomCrashFrame implements CrashFrame {
  factory CustomCrashFrame(
      {required final String no,
      required final int pc,
      required final String binary,
      required final int? offset,
      required final String? location,
      required final String? symbol}) = _$CustomCrashFrame;

  factory CustomCrashFrame.fromJson(Map<String, dynamic> json) =
      _$CustomCrashFrame.fromJson;

  String get no;
  @override
  int get pc;
  @override
  String get binary;
  int? get offset;
  String? get location;
  String? get symbol;
  @override
  @JsonKey(ignore: true)
  _$$CustomCrashFrameCopyWith<_$CustomCrashFrame> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$DartvmCrashFrameCopyWith<$Res>
    implements $CrashFrameCopyWith<$Res> {
  factory _$$DartvmCrashFrameCopyWith(
          _$DartvmCrashFrame value, $Res Function(_$DartvmCrashFrame) then) =
      __$$DartvmCrashFrameCopyWithImpl<$Res>;
  @override
  $Res call({int pc, String binary, int offset});
}

/// @nodoc
class __$$DartvmCrashFrameCopyWithImpl<$Res>
    extends _$CrashFrameCopyWithImpl<$Res>
    implements _$$DartvmCrashFrameCopyWith<$Res> {
  __$$DartvmCrashFrameCopyWithImpl(
      _$DartvmCrashFrame _value, $Res Function(_$DartvmCrashFrame) _then)
      : super(_value, (v) => _then(v as _$DartvmCrashFrame));

  @override
  _$DartvmCrashFrame get _value => super._value as _$DartvmCrashFrame;

  @override
  $Res call({
    Object? pc = freezed,
    Object? binary = freezed,
    Object? offset = freezed,
  }) {
    return _then(_$DartvmCrashFrame(
      pc: pc == freezed
          ? _value.pc
          : pc // ignore: cast_nullable_to_non_nullable
              as int,
      binary: binary == freezed
          ? _value.binary
          : binary // ignore: cast_nullable_to_non_nullable
              as String,
      offset: offset == freezed
          ? _value.offset
          : offset // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DartvmCrashFrame implements DartvmCrashFrame {
  _$DartvmCrashFrame(
      {required this.pc,
      required this.binary,
      required this.offset,
      final String? $type})
      : $type = $type ?? 'dartvm';

  factory _$DartvmCrashFrame.fromJson(Map<String, dynamic> json) =>
      _$$DartvmCrashFrameFromJson(json);

  /// Absolute PC of the frame.
  @override
  final int pc;

  /// Binary which contains the given PC.
  @override
  final String binary;

  /// Offset from load base of the binary to the PC.
  @override
  final int offset;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'CrashFrame.dartvm(pc: $pc, binary: $binary, offset: $offset)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DartvmCrashFrame &&
            const DeepCollectionEquality().equals(other.pc, pc) &&
            const DeepCollectionEquality().equals(other.binary, binary) &&
            const DeepCollectionEquality().equals(other.offset, offset));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(pc),
      const DeepCollectionEquality().hash(binary),
      const DeepCollectionEquality().hash(offset));

  @JsonKey(ignore: true)
  @override
  _$$DartvmCrashFrameCopyWith<_$DartvmCrashFrame> get copyWith =>
      __$$DartvmCrashFrameCopyWithImpl<_$DartvmCrashFrame>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String no, String binary, int pc, String symbol,
            int? offset, String location)
        ios,
    required TResult Function(
            String no, int pc, String binary, String rest, String? buildId)
        android,
    required TResult Function(String no, int pc, String binary, int? offset,
            String? location, String? symbol)
        custom,
    required TResult Function(int pc, String binary, int offset) dartvm,
  }) {
    return dartvm(pc, binary, offset);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(String no, String binary, int pc, String symbol,
            int? offset, String location)?
        ios,
    TResult Function(
            String no, int pc, String binary, String rest, String? buildId)?
        android,
    TResult Function(String no, int pc, String binary, int? offset,
            String? location, String? symbol)?
        custom,
    TResult Function(int pc, String binary, int offset)? dartvm,
  }) {
    return dartvm?.call(pc, binary, offset);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String no, String binary, int pc, String symbol,
            int? offset, String location)?
        ios,
    TResult Function(
            String no, int pc, String binary, String rest, String? buildId)?
        android,
    TResult Function(String no, int pc, String binary, int? offset,
            String? location, String? symbol)?
        custom,
    TResult Function(int pc, String binary, int offset)? dartvm,
    required TResult orElse(),
  }) {
    if (dartvm != null) {
      return dartvm(pc, binary, offset);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(IosCrashFrame value) ios,
    required TResult Function(AndroidCrashFrame value) android,
    required TResult Function(CustomCrashFrame value) custom,
    required TResult Function(DartvmCrashFrame value) dartvm,
  }) {
    return dartvm(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(IosCrashFrame value)? ios,
    TResult Function(AndroidCrashFrame value)? android,
    TResult Function(CustomCrashFrame value)? custom,
    TResult Function(DartvmCrashFrame value)? dartvm,
  }) {
    return dartvm?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(IosCrashFrame value)? ios,
    TResult Function(AndroidCrashFrame value)? android,
    TResult Function(CustomCrashFrame value)? custom,
    TResult Function(DartvmCrashFrame value)? dartvm,
    required TResult orElse(),
  }) {
    if (dartvm != null) {
      return dartvm(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$DartvmCrashFrameToJson(
      this,
    );
  }
}

abstract class DartvmCrashFrame implements CrashFrame {
  factory DartvmCrashFrame(
      {required final int pc,
      required final String binary,
      required final int offset}) = _$DartvmCrashFrame;

  factory DartvmCrashFrame.fromJson(Map<String, dynamic> json) =
      _$DartvmCrashFrame.fromJson;

  @override

  /// Absolute PC of the frame.
  int get pc;
  @override

  /// Binary which contains the given PC.
  String get binary;

  /// Offset from load base of the binary to the PC.
  int get offset;
  @override
  @JsonKey(ignore: true)
  _$$DartvmCrashFrameCopyWith<_$DartvmCrashFrame> get copyWith =>
      throw _privateConstructorUsedError;
}

Crash _$CrashFromJson(Map<String, dynamic> json) {
  return _Crash.fromJson(json);
}

/// @nodoc
mixin _$Crash {
  EngineVariant get engineVariant => throw _privateConstructorUsedError;
  List<CrashFrame> get frames => throw _privateConstructorUsedError;
  String get format => throw _privateConstructorUsedError;
  int? get androidMajorVersion => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CrashCopyWith<Crash> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CrashCopyWith<$Res> {
  factory $CrashCopyWith(Crash value, $Res Function(Crash) then) =
      _$CrashCopyWithImpl<$Res>;
  $Res call(
      {EngineVariant engineVariant,
      List<CrashFrame> frames,
      String format,
      int? androidMajorVersion});

  $EngineVariantCopyWith<$Res> get engineVariant;
}

/// @nodoc
class _$CrashCopyWithImpl<$Res> implements $CrashCopyWith<$Res> {
  _$CrashCopyWithImpl(this._value, this._then);

  final Crash _value;
  // ignore: unused_field
  final $Res Function(Crash) _then;

  @override
  $Res call({
    Object? engineVariant = freezed,
    Object? frames = freezed,
    Object? format = freezed,
    Object? androidMajorVersion = freezed,
  }) {
    return _then(_value.copyWith(
      engineVariant: engineVariant == freezed
          ? _value.engineVariant
          : engineVariant // ignore: cast_nullable_to_non_nullable
              as EngineVariant,
      frames: frames == freezed
          ? _value.frames
          : frames // ignore: cast_nullable_to_non_nullable
              as List<CrashFrame>,
      format: format == freezed
          ? _value.format
          : format // ignore: cast_nullable_to_non_nullable
              as String,
      androidMajorVersion: androidMajorVersion == freezed
          ? _value.androidMajorVersion
          : androidMajorVersion // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }

  @override
  $EngineVariantCopyWith<$Res> get engineVariant {
    return $EngineVariantCopyWith<$Res>(_value.engineVariant, (value) {
      return _then(_value.copyWith(engineVariant: value));
    });
  }
}

/// @nodoc
abstract class _$$_CrashCopyWith<$Res> implements $CrashCopyWith<$Res> {
  factory _$$_CrashCopyWith(_$_Crash value, $Res Function(_$_Crash) then) =
      __$$_CrashCopyWithImpl<$Res>;
  @override
  $Res call(
      {EngineVariant engineVariant,
      List<CrashFrame> frames,
      String format,
      int? androidMajorVersion});

  @override
  $EngineVariantCopyWith<$Res> get engineVariant;
}

/// @nodoc
class __$$_CrashCopyWithImpl<$Res> extends _$CrashCopyWithImpl<$Res>
    implements _$$_CrashCopyWith<$Res> {
  __$$_CrashCopyWithImpl(_$_Crash _value, $Res Function(_$_Crash) _then)
      : super(_value, (v) => _then(v as _$_Crash));

  @override
  _$_Crash get _value => super._value as _$_Crash;

  @override
  $Res call({
    Object? engineVariant = freezed,
    Object? frames = freezed,
    Object? format = freezed,
    Object? androidMajorVersion = freezed,
  }) {
    return _then(_$_Crash(
      engineVariant: engineVariant == freezed
          ? _value.engineVariant
          : engineVariant // ignore: cast_nullable_to_non_nullable
              as EngineVariant,
      frames: frames == freezed
          ? _value._frames
          : frames // ignore: cast_nullable_to_non_nullable
              as List<CrashFrame>,
      format: format == freezed
          ? _value.format
          : format // ignore: cast_nullable_to_non_nullable
              as String,
      androidMajorVersion: androidMajorVersion == freezed
          ? _value.androidMajorVersion
          : androidMajorVersion // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_Crash implements _Crash {
  _$_Crash(
      {required this.engineVariant,
      required final List<CrashFrame> frames,
      required this.format,
      this.androidMajorVersion})
      : _frames = frames;

  factory _$_Crash.fromJson(Map<String, dynamic> json) =>
      _$$_CrashFromJson(json);

  @override
  final EngineVariant engineVariant;
  final List<CrashFrame> _frames;
  @override
  List<CrashFrame> get frames {
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_frames);
  }

  @override
  final String format;
  @override
  final int? androidMajorVersion;

  @override
  String toString() {
    return 'Crash(engineVariant: $engineVariant, frames: $frames, format: $format, androidMajorVersion: $androidMajorVersion)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_Crash &&
            const DeepCollectionEquality()
                .equals(other.engineVariant, engineVariant) &&
            const DeepCollectionEquality().equals(other._frames, _frames) &&
            const DeepCollectionEquality().equals(other.format, format) &&
            const DeepCollectionEquality()
                .equals(other.androidMajorVersion, androidMajorVersion));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(engineVariant),
      const DeepCollectionEquality().hash(_frames),
      const DeepCollectionEquality().hash(format),
      const DeepCollectionEquality().hash(androidMajorVersion));

  @JsonKey(ignore: true)
  @override
  _$$_CrashCopyWith<_$_Crash> get copyWith =>
      __$$_CrashCopyWithImpl<_$_Crash>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_CrashToJson(
      this,
    );
  }
}

abstract class _Crash implements Crash {
  factory _Crash(
      {required final EngineVariant engineVariant,
      required final List<CrashFrame> frames,
      required final String format,
      final int? androidMajorVersion}) = _$_Crash;

  factory _Crash.fromJson(Map<String, dynamic> json) = _$_Crash.fromJson;

  @override
  EngineVariant get engineVariant;
  @override
  List<CrashFrame> get frames;
  @override
  String get format;
  @override
  int? get androidMajorVersion;
  @override
  @JsonKey(ignore: true)
  _$$_CrashCopyWith<_$_Crash> get copyWith =>
      throw _privateConstructorUsedError;
}

SymbolizationResult _$SymbolizationResultFromJson(Map<String, dynamic> json) {
  switch (json['runtimeType']) {
    case 'ok':
      return SymbolizationResultOk.fromJson(json);
    case 'error':
      return SymbolizationResultError.fromJson(json);

    default:
      throw CheckedFromJsonException(json, 'runtimeType', 'SymbolizationResult',
          'Invalid union type "${json['runtimeType']}"!');
  }
}

/// @nodoc
mixin _$SymbolizationResult {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(List<CrashSymbolizationResult> results) ok,
    required TResult Function(SymbolizationNote error) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(List<CrashSymbolizationResult> results)? ok,
    TResult Function(SymbolizationNote error)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(List<CrashSymbolizationResult> results)? ok,
    TResult Function(SymbolizationNote error)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SymbolizationResultOk value) ok,
    required TResult Function(SymbolizationResultError value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(SymbolizationResultOk value)? ok,
    TResult Function(SymbolizationResultError value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SymbolizationResultOk value)? ok,
    TResult Function(SymbolizationResultError value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SymbolizationResultCopyWith<$Res> {
  factory $SymbolizationResultCopyWith(
          SymbolizationResult value, $Res Function(SymbolizationResult) then) =
      _$SymbolizationResultCopyWithImpl<$Res>;
}

/// @nodoc
class _$SymbolizationResultCopyWithImpl<$Res>
    implements $SymbolizationResultCopyWith<$Res> {
  _$SymbolizationResultCopyWithImpl(this._value, this._then);

  final SymbolizationResult _value;
  // ignore: unused_field
  final $Res Function(SymbolizationResult) _then;
}

/// @nodoc
abstract class _$$SymbolizationResultOkCopyWith<$Res> {
  factory _$$SymbolizationResultOkCopyWith(_$SymbolizationResultOk value,
          $Res Function(_$SymbolizationResultOk) then) =
      __$$SymbolizationResultOkCopyWithImpl<$Res>;
  $Res call({List<CrashSymbolizationResult> results});
}

/// @nodoc
class __$$SymbolizationResultOkCopyWithImpl<$Res>
    extends _$SymbolizationResultCopyWithImpl<$Res>
    implements _$$SymbolizationResultOkCopyWith<$Res> {
  __$$SymbolizationResultOkCopyWithImpl(_$SymbolizationResultOk _value,
      $Res Function(_$SymbolizationResultOk) _then)
      : super(_value, (v) => _then(v as _$SymbolizationResultOk));

  @override
  _$SymbolizationResultOk get _value => super._value as _$SymbolizationResultOk;

  @override
  $Res call({
    Object? results = freezed,
  }) {
    return _then(_$SymbolizationResultOk(
      results: results == freezed
          ? _value._results
          : results // ignore: cast_nullable_to_non_nullable
              as List<CrashSymbolizationResult>,
    ));
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _$SymbolizationResultOk implements SymbolizationResultOk {
  _$SymbolizationResultOk(
      {required final List<CrashSymbolizationResult> results,
      final String? $type})
      : _results = results,
        $type = $type ?? 'ok';

  factory _$SymbolizationResultOk.fromJson(Map<String, dynamic> json) =>
      _$$SymbolizationResultOkFromJson(json);

  final List<CrashSymbolizationResult> _results;
  @override
  List<CrashSymbolizationResult> get results {
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_results);
  }

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'SymbolizationResult.ok(results: $results)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SymbolizationResultOk &&
            const DeepCollectionEquality().equals(other._results, _results));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_results));

  @JsonKey(ignore: true)
  @override
  _$$SymbolizationResultOkCopyWith<_$SymbolizationResultOk> get copyWith =>
      __$$SymbolizationResultOkCopyWithImpl<_$SymbolizationResultOk>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(List<CrashSymbolizationResult> results) ok,
    required TResult Function(SymbolizationNote error) error,
  }) {
    return ok(results);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(List<CrashSymbolizationResult> results)? ok,
    TResult Function(SymbolizationNote error)? error,
  }) {
    return ok?.call(results);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(List<CrashSymbolizationResult> results)? ok,
    TResult Function(SymbolizationNote error)? error,
    required TResult orElse(),
  }) {
    if (ok != null) {
      return ok(results);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SymbolizationResultOk value) ok,
    required TResult Function(SymbolizationResultError value) error,
  }) {
    return ok(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(SymbolizationResultOk value)? ok,
    TResult Function(SymbolizationResultError value)? error,
  }) {
    return ok?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SymbolizationResultOk value)? ok,
    TResult Function(SymbolizationResultError value)? error,
    required TResult orElse(),
  }) {
    if (ok != null) {
      return ok(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$SymbolizationResultOkToJson(
      this,
    );
  }
}

abstract class SymbolizationResultOk implements SymbolizationResult {
  factory SymbolizationResultOk(
          {required final List<CrashSymbolizationResult> results}) =
      _$SymbolizationResultOk;

  factory SymbolizationResultOk.fromJson(Map<String, dynamic> json) =
      _$SymbolizationResultOk.fromJson;

  List<CrashSymbolizationResult> get results;
  @JsonKey(ignore: true)
  _$$SymbolizationResultOkCopyWith<_$SymbolizationResultOk> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$SymbolizationResultErrorCopyWith<$Res> {
  factory _$$SymbolizationResultErrorCopyWith(_$SymbolizationResultError value,
          $Res Function(_$SymbolizationResultError) then) =
      __$$SymbolizationResultErrorCopyWithImpl<$Res>;
  $Res call({SymbolizationNote error});

  $SymbolizationNoteCopyWith<$Res> get error;
}

/// @nodoc
class __$$SymbolizationResultErrorCopyWithImpl<$Res>
    extends _$SymbolizationResultCopyWithImpl<$Res>
    implements _$$SymbolizationResultErrorCopyWith<$Res> {
  __$$SymbolizationResultErrorCopyWithImpl(_$SymbolizationResultError _value,
      $Res Function(_$SymbolizationResultError) _then)
      : super(_value, (v) => _then(v as _$SymbolizationResultError));

  @override
  _$SymbolizationResultError get _value =>
      super._value as _$SymbolizationResultError;

  @override
  $Res call({
    Object? error = freezed,
  }) {
    return _then(_$SymbolizationResultError(
      error: error == freezed
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as SymbolizationNote,
    ));
  }

  @override
  $SymbolizationNoteCopyWith<$Res> get error {
    return $SymbolizationNoteCopyWith<$Res>(_value.error, (value) {
      return _then(_value.copyWith(error: value));
    });
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _$SymbolizationResultError implements SymbolizationResultError {
  _$SymbolizationResultError({required this.error, final String? $type})
      : $type = $type ?? 'error';

  factory _$SymbolizationResultError.fromJson(Map<String, dynamic> json) =>
      _$$SymbolizationResultErrorFromJson(json);

  @override
  final SymbolizationNote error;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'SymbolizationResult.error(error: $error)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SymbolizationResultError &&
            const DeepCollectionEquality().equals(other.error, error));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(error));

  @JsonKey(ignore: true)
  @override
  _$$SymbolizationResultErrorCopyWith<_$SymbolizationResultError>
      get copyWith =>
          __$$SymbolizationResultErrorCopyWithImpl<_$SymbolizationResultError>(
              this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(List<CrashSymbolizationResult> results) ok,
    required TResult Function(SymbolizationNote error) error,
  }) {
    return error(this.error);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(List<CrashSymbolizationResult> results)? ok,
    TResult Function(SymbolizationNote error)? error,
  }) {
    return error?.call(this.error);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(List<CrashSymbolizationResult> results)? ok,
    TResult Function(SymbolizationNote error)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this.error);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SymbolizationResultOk value) ok,
    required TResult Function(SymbolizationResultError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(SymbolizationResultOk value)? ok,
    TResult Function(SymbolizationResultError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SymbolizationResultOk value)? ok,
    TResult Function(SymbolizationResultError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$SymbolizationResultErrorToJson(
      this,
    );
  }
}

abstract class SymbolizationResultError implements SymbolizationResult {
  factory SymbolizationResultError({required final SymbolizationNote error}) =
      _$SymbolizationResultError;

  factory SymbolizationResultError.fromJson(Map<String, dynamic> json) =
      _$SymbolizationResultError.fromJson;

  SymbolizationNote get error;
  @JsonKey(ignore: true)
  _$$SymbolizationResultErrorCopyWith<_$SymbolizationResultError>
      get copyWith => throw _privateConstructorUsedError;
}

CrashSymbolizationResult _$CrashSymbolizationResultFromJson(
    Map<String, dynamic> json) {
  return _CrashSymbolizationResult.fromJson(json);
}

/// @nodoc
mixin _$CrashSymbolizationResult {
  Crash get crash => throw _privateConstructorUsedError;
  EngineBuild? get engineBuild => throw _privateConstructorUsedError;

  /// Symbolization result - not null if symbolization succeeded.
  String? get symbolized => throw _privateConstructorUsedError;
  List<SymbolizationNote> get notes => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CrashSymbolizationResultCopyWith<CrashSymbolizationResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CrashSymbolizationResultCopyWith<$Res> {
  factory $CrashSymbolizationResultCopyWith(CrashSymbolizationResult value,
          $Res Function(CrashSymbolizationResult) then) =
      _$CrashSymbolizationResultCopyWithImpl<$Res>;
  $Res call(
      {Crash crash,
      EngineBuild? engineBuild,
      String? symbolized,
      List<SymbolizationNote> notes});

  $CrashCopyWith<$Res> get crash;
  $EngineBuildCopyWith<$Res>? get engineBuild;
}

/// @nodoc
class _$CrashSymbolizationResultCopyWithImpl<$Res>
    implements $CrashSymbolizationResultCopyWith<$Res> {
  _$CrashSymbolizationResultCopyWithImpl(this._value, this._then);

  final CrashSymbolizationResult _value;
  // ignore: unused_field
  final $Res Function(CrashSymbolizationResult) _then;

  @override
  $Res call({
    Object? crash = freezed,
    Object? engineBuild = freezed,
    Object? symbolized = freezed,
    Object? notes = freezed,
  }) {
    return _then(_value.copyWith(
      crash: crash == freezed
          ? _value.crash
          : crash // ignore: cast_nullable_to_non_nullable
              as Crash,
      engineBuild: engineBuild == freezed
          ? _value.engineBuild
          : engineBuild // ignore: cast_nullable_to_non_nullable
              as EngineBuild?,
      symbolized: symbolized == freezed
          ? _value.symbolized
          : symbolized // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: notes == freezed
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as List<SymbolizationNote>,
    ));
  }

  @override
  $CrashCopyWith<$Res> get crash {
    return $CrashCopyWith<$Res>(_value.crash, (value) {
      return _then(_value.copyWith(crash: value));
    });
  }

  @override
  $EngineBuildCopyWith<$Res>? get engineBuild {
    if (_value.engineBuild == null) {
      return null;
    }

    return $EngineBuildCopyWith<$Res>(_value.engineBuild!, (value) {
      return _then(_value.copyWith(engineBuild: value));
    });
  }
}

/// @nodoc
abstract class _$$_CrashSymbolizationResultCopyWith<$Res>
    implements $CrashSymbolizationResultCopyWith<$Res> {
  factory _$$_CrashSymbolizationResultCopyWith(
          _$_CrashSymbolizationResult value,
          $Res Function(_$_CrashSymbolizationResult) then) =
      __$$_CrashSymbolizationResultCopyWithImpl<$Res>;
  @override
  $Res call(
      {Crash crash,
      EngineBuild? engineBuild,
      String? symbolized,
      List<SymbolizationNote> notes});

  @override
  $CrashCopyWith<$Res> get crash;
  @override
  $EngineBuildCopyWith<$Res>? get engineBuild;
}

/// @nodoc
class __$$_CrashSymbolizationResultCopyWithImpl<$Res>
    extends _$CrashSymbolizationResultCopyWithImpl<$Res>
    implements _$$_CrashSymbolizationResultCopyWith<$Res> {
  __$$_CrashSymbolizationResultCopyWithImpl(_$_CrashSymbolizationResult _value,
      $Res Function(_$_CrashSymbolizationResult) _then)
      : super(_value, (v) => _then(v as _$_CrashSymbolizationResult));

  @override
  _$_CrashSymbolizationResult get _value =>
      super._value as _$_CrashSymbolizationResult;

  @override
  $Res call({
    Object? crash = freezed,
    Object? engineBuild = freezed,
    Object? symbolized = freezed,
    Object? notes = freezed,
  }) {
    return _then(_$_CrashSymbolizationResult(
      crash: crash == freezed
          ? _value.crash
          : crash // ignore: cast_nullable_to_non_nullable
              as Crash,
      engineBuild: engineBuild == freezed
          ? _value.engineBuild
          : engineBuild // ignore: cast_nullable_to_non_nullable
              as EngineBuild?,
      symbolized: symbolized == freezed
          ? _value.symbolized
          : symbolized // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: notes == freezed
          ? _value._notes
          : notes // ignore: cast_nullable_to_non_nullable
              as List<SymbolizationNote>,
    ));
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _$_CrashSymbolizationResult implements _CrashSymbolizationResult {
  _$_CrashSymbolizationResult(
      {required this.crash,
      required this.engineBuild,
      required this.symbolized,
      final List<SymbolizationNote> notes = const []})
      : _notes = notes;

  factory _$_CrashSymbolizationResult.fromJson(Map<String, dynamic> json) =>
      _$$_CrashSymbolizationResultFromJson(json);

  @override
  final Crash crash;
  @override
  final EngineBuild? engineBuild;

  /// Symbolization result - not null if symbolization succeeded.
  @override
  final String? symbolized;
  final List<SymbolizationNote> _notes;
  @override
  @JsonKey()
  List<SymbolizationNote> get notes {
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_notes);
  }

  @override
  String toString() {
    return 'CrashSymbolizationResult(crash: $crash, engineBuild: $engineBuild, symbolized: $symbolized, notes: $notes)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_CrashSymbolizationResult &&
            const DeepCollectionEquality().equals(other.crash, crash) &&
            const DeepCollectionEquality()
                .equals(other.engineBuild, engineBuild) &&
            const DeepCollectionEquality()
                .equals(other.symbolized, symbolized) &&
            const DeepCollectionEquality().equals(other._notes, _notes));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(crash),
      const DeepCollectionEquality().hash(engineBuild),
      const DeepCollectionEquality().hash(symbolized),
      const DeepCollectionEquality().hash(_notes));

  @JsonKey(ignore: true)
  @override
  _$$_CrashSymbolizationResultCopyWith<_$_CrashSymbolizationResult>
      get copyWith => __$$_CrashSymbolizationResultCopyWithImpl<
          _$_CrashSymbolizationResult>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_CrashSymbolizationResultToJson(
      this,
    );
  }
}

abstract class _CrashSymbolizationResult implements CrashSymbolizationResult {
  factory _CrashSymbolizationResult(
      {required final Crash crash,
      required final EngineBuild? engineBuild,
      required final String? symbolized,
      final List<SymbolizationNote> notes}) = _$_CrashSymbolizationResult;

  factory _CrashSymbolizationResult.fromJson(Map<String, dynamic> json) =
      _$_CrashSymbolizationResult.fromJson;

  @override
  Crash get crash;
  @override
  EngineBuild? get engineBuild;
  @override

  /// Symbolization result - not null if symbolization succeeded.
  String? get symbolized;
  @override
  List<SymbolizationNote> get notes;
  @override
  @JsonKey(ignore: true)
  _$$_CrashSymbolizationResultCopyWith<_$_CrashSymbolizationResult>
      get copyWith => throw _privateConstructorUsedError;
}

SymbolizationNote _$SymbolizationNoteFromJson(Map<String, dynamic> json) {
  return _SymbolizationNote.fromJson(json);
}

/// @nodoc
mixin _$SymbolizationNote {
  SymbolizationNoteKind get kind => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SymbolizationNoteCopyWith<SymbolizationNote> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SymbolizationNoteCopyWith<$Res> {
  factory $SymbolizationNoteCopyWith(
          SymbolizationNote value, $Res Function(SymbolizationNote) then) =
      _$SymbolizationNoteCopyWithImpl<$Res>;
  $Res call({SymbolizationNoteKind kind, String? message});
}

/// @nodoc
class _$SymbolizationNoteCopyWithImpl<$Res>
    implements $SymbolizationNoteCopyWith<$Res> {
  _$SymbolizationNoteCopyWithImpl(this._value, this._then);

  final SymbolizationNote _value;
  // ignore: unused_field
  final $Res Function(SymbolizationNote) _then;

  @override
  $Res call({
    Object? kind = freezed,
    Object? message = freezed,
  }) {
    return _then(_value.copyWith(
      kind: kind == freezed
          ? _value.kind
          : kind // ignore: cast_nullable_to_non_nullable
              as SymbolizationNoteKind,
      message: message == freezed
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
abstract class _$$_SymbolizationNoteCopyWith<$Res>
    implements $SymbolizationNoteCopyWith<$Res> {
  factory _$$_SymbolizationNoteCopyWith(_$_SymbolizationNote value,
          $Res Function(_$_SymbolizationNote) then) =
      __$$_SymbolizationNoteCopyWithImpl<$Res>;
  @override
  $Res call({SymbolizationNoteKind kind, String? message});
}

/// @nodoc
class __$$_SymbolizationNoteCopyWithImpl<$Res>
    extends _$SymbolizationNoteCopyWithImpl<$Res>
    implements _$$_SymbolizationNoteCopyWith<$Res> {
  __$$_SymbolizationNoteCopyWithImpl(
      _$_SymbolizationNote _value, $Res Function(_$_SymbolizationNote) _then)
      : super(_value, (v) => _then(v as _$_SymbolizationNote));

  @override
  _$_SymbolizationNote get _value => super._value as _$_SymbolizationNote;

  @override
  $Res call({
    Object? kind = freezed,
    Object? message = freezed,
  }) {
    return _then(_$_SymbolizationNote(
      kind: kind == freezed
          ? _value.kind
          : kind // ignore: cast_nullable_to_non_nullable
              as SymbolizationNoteKind,
      message: message == freezed
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_SymbolizationNote implements _SymbolizationNote {
  _$_SymbolizationNote({required this.kind, this.message});

  factory _$_SymbolizationNote.fromJson(Map<String, dynamic> json) =>
      _$$_SymbolizationNoteFromJson(json);

  @override
  final SymbolizationNoteKind kind;
  @override
  final String? message;

  @override
  String toString() {
    return 'SymbolizationNote(kind: $kind, message: $message)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_SymbolizationNote &&
            const DeepCollectionEquality().equals(other.kind, kind) &&
            const DeepCollectionEquality().equals(other.message, message));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(kind),
      const DeepCollectionEquality().hash(message));

  @JsonKey(ignore: true)
  @override
  _$$_SymbolizationNoteCopyWith<_$_SymbolizationNote> get copyWith =>
      __$$_SymbolizationNoteCopyWithImpl<_$_SymbolizationNote>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_SymbolizationNoteToJson(
      this,
    );
  }
}

abstract class _SymbolizationNote implements SymbolizationNote {
  factory _SymbolizationNote(
      {required final SymbolizationNoteKind kind,
      final String? message}) = _$_SymbolizationNote;

  factory _SymbolizationNote.fromJson(Map<String, dynamic> json) =
      _$_SymbolizationNote.fromJson;

  @override
  SymbolizationNoteKind get kind;
  @override
  String? get message;
  @override
  @JsonKey(ignore: true)
  _$$_SymbolizationNoteCopyWith<_$_SymbolizationNote> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$BotCommand {
  /// Overrides that should be used for symbolization. These overrides
  /// replace or augment information available in the comments themselves.
  SymbolizationOverrides get overrides => throw _privateConstructorUsedError;

  /// [true] if the user requested to symbolize the comment that contains
  /// command.
  bool get symbolizeThis => throw _privateConstructorUsedError;

  /// List of references to comments which need to be symbolized. Each reference
  /// is either in `issue-id` or in `issuecomment-id` format.
  Set<String> get worklist => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $BotCommandCopyWith<BotCommand> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BotCommandCopyWith<$Res> {
  factory $BotCommandCopyWith(
          BotCommand value, $Res Function(BotCommand) then) =
      _$BotCommandCopyWithImpl<$Res>;
  $Res call(
      {SymbolizationOverrides overrides,
      bool symbolizeThis,
      Set<String> worklist});

  $SymbolizationOverridesCopyWith<$Res> get overrides;
}

/// @nodoc
class _$BotCommandCopyWithImpl<$Res> implements $BotCommandCopyWith<$Res> {
  _$BotCommandCopyWithImpl(this._value, this._then);

  final BotCommand _value;
  // ignore: unused_field
  final $Res Function(BotCommand) _then;

  @override
  $Res call({
    Object? overrides = freezed,
    Object? symbolizeThis = freezed,
    Object? worklist = freezed,
  }) {
    return _then(_value.copyWith(
      overrides: overrides == freezed
          ? _value.overrides
          : overrides // ignore: cast_nullable_to_non_nullable
              as SymbolizationOverrides,
      symbolizeThis: symbolizeThis == freezed
          ? _value.symbolizeThis
          : symbolizeThis // ignore: cast_nullable_to_non_nullable
              as bool,
      worklist: worklist == freezed
          ? _value.worklist
          : worklist // ignore: cast_nullable_to_non_nullable
              as Set<String>,
    ));
  }

  @override
  $SymbolizationOverridesCopyWith<$Res> get overrides {
    return $SymbolizationOverridesCopyWith<$Res>(_value.overrides, (value) {
      return _then(_value.copyWith(overrides: value));
    });
  }
}

/// @nodoc
abstract class _$$_BotCommandCopyWith<$Res>
    implements $BotCommandCopyWith<$Res> {
  factory _$$_BotCommandCopyWith(
          _$_BotCommand value, $Res Function(_$_BotCommand) then) =
      __$$_BotCommandCopyWithImpl<$Res>;
  @override
  $Res call(
      {SymbolizationOverrides overrides,
      bool symbolizeThis,
      Set<String> worklist});

  @override
  $SymbolizationOverridesCopyWith<$Res> get overrides;
}

/// @nodoc
class __$$_BotCommandCopyWithImpl<$Res> extends _$BotCommandCopyWithImpl<$Res>
    implements _$$_BotCommandCopyWith<$Res> {
  __$$_BotCommandCopyWithImpl(
      _$_BotCommand _value, $Res Function(_$_BotCommand) _then)
      : super(_value, (v) => _then(v as _$_BotCommand));

  @override
  _$_BotCommand get _value => super._value as _$_BotCommand;

  @override
  $Res call({
    Object? overrides = freezed,
    Object? symbolizeThis = freezed,
    Object? worklist = freezed,
  }) {
    return _then(_$_BotCommand(
      overrides: overrides == freezed
          ? _value.overrides
          : overrides // ignore: cast_nullable_to_non_nullable
              as SymbolizationOverrides,
      symbolizeThis: symbolizeThis == freezed
          ? _value.symbolizeThis
          : symbolizeThis // ignore: cast_nullable_to_non_nullable
              as bool,
      worklist: worklist == freezed
          ? _value._worklist
          : worklist // ignore: cast_nullable_to_non_nullable
              as Set<String>,
    ));
  }
}

/// @nodoc

class _$_BotCommand implements _BotCommand {
  _$_BotCommand(
      {required this.overrides,
      required this.symbolizeThis,
      required final Set<String> worklist})
      : _worklist = worklist;

  /// Overrides that should be used for symbolization. These overrides
  /// replace or augment information available in the comments themselves.
  @override
  final SymbolizationOverrides overrides;

  /// [true] if the user requested to symbolize the comment that contains
  /// command.
  @override
  final bool symbolizeThis;

  /// List of references to comments which need to be symbolized. Each reference
  /// is either in `issue-id` or in `issuecomment-id` format.
  final Set<String> _worklist;

  /// List of references to comments which need to be symbolized. Each reference
  /// is either in `issue-id` or in `issuecomment-id` format.
  @override
  Set<String> get worklist {
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_worklist);
  }

  @override
  String toString() {
    return 'BotCommand(overrides: $overrides, symbolizeThis: $symbolizeThis, worklist: $worklist)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_BotCommand &&
            const DeepCollectionEquality().equals(other.overrides, overrides) &&
            const DeepCollectionEquality()
                .equals(other.symbolizeThis, symbolizeThis) &&
            const DeepCollectionEquality().equals(other._worklist, _worklist));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(overrides),
      const DeepCollectionEquality().hash(symbolizeThis),
      const DeepCollectionEquality().hash(_worklist));

  @JsonKey(ignore: true)
  @override
  _$$_BotCommandCopyWith<_$_BotCommand> get copyWith =>
      __$$_BotCommandCopyWithImpl<_$_BotCommand>(this, _$identity);
}

abstract class _BotCommand implements BotCommand {
  factory _BotCommand(
      {required final SymbolizationOverrides overrides,
      required final bool symbolizeThis,
      required final Set<String> worklist}) = _$_BotCommand;

  @override

  /// Overrides that should be used for symbolization. These overrides
  /// replace or augment information available in the comments themselves.
  SymbolizationOverrides get overrides;
  @override

  /// [true] if the user requested to symbolize the comment that contains
  /// command.
  bool get symbolizeThis;
  @override

  /// List of references to comments which need to be symbolized. Each reference
  /// is either in `issue-id` or in `issuecomment-id` format.
  Set<String> get worklist;
  @override
  @JsonKey(ignore: true)
  _$$_BotCommandCopyWith<_$_BotCommand> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$SymbolizationOverrides {
  String? get engineHash => throw _privateConstructorUsedError;
  String? get flutterVersion => throw _privateConstructorUsedError;
  String? get arch => throw _privateConstructorUsedError;
  String? get mode => throw _privateConstructorUsedError;
  bool get force => throw _privateConstructorUsedError;
  String? get format => throw _privateConstructorUsedError;
  String? get os => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $SymbolizationOverridesCopyWith<SymbolizationOverrides> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SymbolizationOverridesCopyWith<$Res> {
  factory $SymbolizationOverridesCopyWith(SymbolizationOverrides value,
          $Res Function(SymbolizationOverrides) then) =
      _$SymbolizationOverridesCopyWithImpl<$Res>;
  $Res call(
      {String? engineHash,
      String? flutterVersion,
      String? arch,
      String? mode,
      bool force,
      String? format,
      String? os});
}

/// @nodoc
class _$SymbolizationOverridesCopyWithImpl<$Res>
    implements $SymbolizationOverridesCopyWith<$Res> {
  _$SymbolizationOverridesCopyWithImpl(this._value, this._then);

  final SymbolizationOverrides _value;
  // ignore: unused_field
  final $Res Function(SymbolizationOverrides) _then;

  @override
  $Res call({
    Object? engineHash = freezed,
    Object? flutterVersion = freezed,
    Object? arch = freezed,
    Object? mode = freezed,
    Object? force = freezed,
    Object? format = freezed,
    Object? os = freezed,
  }) {
    return _then(_value.copyWith(
      engineHash: engineHash == freezed
          ? _value.engineHash
          : engineHash // ignore: cast_nullable_to_non_nullable
              as String?,
      flutterVersion: flutterVersion == freezed
          ? _value.flutterVersion
          : flutterVersion // ignore: cast_nullable_to_non_nullable
              as String?,
      arch: arch == freezed
          ? _value.arch
          : arch // ignore: cast_nullable_to_non_nullable
              as String?,
      mode: mode == freezed
          ? _value.mode
          : mode // ignore: cast_nullable_to_non_nullable
              as String?,
      force: force == freezed
          ? _value.force
          : force // ignore: cast_nullable_to_non_nullable
              as bool,
      format: format == freezed
          ? _value.format
          : format // ignore: cast_nullable_to_non_nullable
              as String?,
      os: os == freezed
          ? _value.os
          : os // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
abstract class _$$_SymbolizationOverridesCopyWith<$Res>
    implements $SymbolizationOverridesCopyWith<$Res> {
  factory _$$_SymbolizationOverridesCopyWith(_$_SymbolizationOverrides value,
          $Res Function(_$_SymbolizationOverrides) then) =
      __$$_SymbolizationOverridesCopyWithImpl<$Res>;
  @override
  $Res call(
      {String? engineHash,
      String? flutterVersion,
      String? arch,
      String? mode,
      bool force,
      String? format,
      String? os});
}

/// @nodoc
class __$$_SymbolizationOverridesCopyWithImpl<$Res>
    extends _$SymbolizationOverridesCopyWithImpl<$Res>
    implements _$$_SymbolizationOverridesCopyWith<$Res> {
  __$$_SymbolizationOverridesCopyWithImpl(_$_SymbolizationOverrides _value,
      $Res Function(_$_SymbolizationOverrides) _then)
      : super(_value, (v) => _then(v as _$_SymbolizationOverrides));

  @override
  _$_SymbolizationOverrides get _value =>
      super._value as _$_SymbolizationOverrides;

  @override
  $Res call({
    Object? engineHash = freezed,
    Object? flutterVersion = freezed,
    Object? arch = freezed,
    Object? mode = freezed,
    Object? force = freezed,
    Object? format = freezed,
    Object? os = freezed,
  }) {
    return _then(_$_SymbolizationOverrides(
      engineHash: engineHash == freezed
          ? _value.engineHash
          : engineHash // ignore: cast_nullable_to_non_nullable
              as String?,
      flutterVersion: flutterVersion == freezed
          ? _value.flutterVersion
          : flutterVersion // ignore: cast_nullable_to_non_nullable
              as String?,
      arch: arch == freezed
          ? _value.arch
          : arch // ignore: cast_nullable_to_non_nullable
              as String?,
      mode: mode == freezed
          ? _value.mode
          : mode // ignore: cast_nullable_to_non_nullable
              as String?,
      force: force == freezed
          ? _value.force
          : force // ignore: cast_nullable_to_non_nullable
              as bool,
      format: format == freezed
          ? _value.format
          : format // ignore: cast_nullable_to_non_nullable
              as String?,
      os: os == freezed
          ? _value.os
          : os // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$_SymbolizationOverrides implements _SymbolizationOverrides {
  _$_SymbolizationOverrides(
      {this.engineHash,
      this.flutterVersion,
      this.arch,
      this.mode,
      this.force = false,
      this.format,
      this.os});

  @override
  final String? engineHash;
  @override
  final String? flutterVersion;
  @override
  final String? arch;
  @override
  final String? mode;
  @override
  @JsonKey()
  final bool force;
  @override
  final String? format;
  @override
  final String? os;

  @override
  String toString() {
    return 'SymbolizationOverrides(engineHash: $engineHash, flutterVersion: $flutterVersion, arch: $arch, mode: $mode, force: $force, format: $format, os: $os)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_SymbolizationOverrides &&
            const DeepCollectionEquality()
                .equals(other.engineHash, engineHash) &&
            const DeepCollectionEquality()
                .equals(other.flutterVersion, flutterVersion) &&
            const DeepCollectionEquality().equals(other.arch, arch) &&
            const DeepCollectionEquality().equals(other.mode, mode) &&
            const DeepCollectionEquality().equals(other.force, force) &&
            const DeepCollectionEquality().equals(other.format, format) &&
            const DeepCollectionEquality().equals(other.os, os));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(engineHash),
      const DeepCollectionEquality().hash(flutterVersion),
      const DeepCollectionEquality().hash(arch),
      const DeepCollectionEquality().hash(mode),
      const DeepCollectionEquality().hash(force),
      const DeepCollectionEquality().hash(format),
      const DeepCollectionEquality().hash(os));

  @JsonKey(ignore: true)
  @override
  _$$_SymbolizationOverridesCopyWith<_$_SymbolizationOverrides> get copyWith =>
      __$$_SymbolizationOverridesCopyWithImpl<_$_SymbolizationOverrides>(
          this, _$identity);
}

abstract class _SymbolizationOverrides implements SymbolizationOverrides {
  factory _SymbolizationOverrides(
      {final String? engineHash,
      final String? flutterVersion,
      final String? arch,
      final String? mode,
      final bool force,
      final String? format,
      final String? os}) = _$_SymbolizationOverrides;

  @override
  String? get engineHash;
  @override
  String? get flutterVersion;
  @override
  String? get arch;
  @override
  String? get mode;
  @override
  bool get force;
  @override
  String? get format;
  @override
  String? get os;
  @override
  @JsonKey(ignore: true)
  _$$_SymbolizationOverridesCopyWith<_$_SymbolizationOverrides> get copyWith =>
      throw _privateConstructorUsedError;
}

ServerConfig _$ServerConfigFromJson(Map<String, dynamic> json) {
  return _ServerConfig.fromJson(json);
}

/// @nodoc
mixin _$ServerConfig {
  String get githubToken => throw _privateConstructorUsedError;
  String get sendgridToken => throw _privateConstructorUsedError;
  String get failureEmail => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ServerConfigCopyWith<ServerConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ServerConfigCopyWith<$Res> {
  factory $ServerConfigCopyWith(
          ServerConfig value, $Res Function(ServerConfig) then) =
      _$ServerConfigCopyWithImpl<$Res>;
  $Res call({String githubToken, String sendgridToken, String failureEmail});
}

/// @nodoc
class _$ServerConfigCopyWithImpl<$Res> implements $ServerConfigCopyWith<$Res> {
  _$ServerConfigCopyWithImpl(this._value, this._then);

  final ServerConfig _value;
  // ignore: unused_field
  final $Res Function(ServerConfig) _then;

  @override
  $Res call({
    Object? githubToken = freezed,
    Object? sendgridToken = freezed,
    Object? failureEmail = freezed,
  }) {
    return _then(_value.copyWith(
      githubToken: githubToken == freezed
          ? _value.githubToken
          : githubToken // ignore: cast_nullable_to_non_nullable
              as String,
      sendgridToken: sendgridToken == freezed
          ? _value.sendgridToken
          : sendgridToken // ignore: cast_nullable_to_non_nullable
              as String,
      failureEmail: failureEmail == freezed
          ? _value.failureEmail
          : failureEmail // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
abstract class _$$_ServerConfigCopyWith<$Res>
    implements $ServerConfigCopyWith<$Res> {
  factory _$$_ServerConfigCopyWith(
          _$_ServerConfig value, $Res Function(_$_ServerConfig) then) =
      __$$_ServerConfigCopyWithImpl<$Res>;
  @override
  $Res call({String githubToken, String sendgridToken, String failureEmail});
}

/// @nodoc
class __$$_ServerConfigCopyWithImpl<$Res>
    extends _$ServerConfigCopyWithImpl<$Res>
    implements _$$_ServerConfigCopyWith<$Res> {
  __$$_ServerConfigCopyWithImpl(
      _$_ServerConfig _value, $Res Function(_$_ServerConfig) _then)
      : super(_value, (v) => _then(v as _$_ServerConfig));

  @override
  _$_ServerConfig get _value => super._value as _$_ServerConfig;

  @override
  $Res call({
    Object? githubToken = freezed,
    Object? sendgridToken = freezed,
    Object? failureEmail = freezed,
  }) {
    return _then(_$_ServerConfig(
      githubToken: githubToken == freezed
          ? _value.githubToken
          : githubToken // ignore: cast_nullable_to_non_nullable
              as String,
      sendgridToken: sendgridToken == freezed
          ? _value.sendgridToken
          : sendgridToken // ignore: cast_nullable_to_non_nullable
              as String,
      failureEmail: failureEmail == freezed
          ? _value.failureEmail
          : failureEmail // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_ServerConfig implements _ServerConfig {
  _$_ServerConfig(
      {required this.githubToken,
      required this.sendgridToken,
      required this.failureEmail});

  factory _$_ServerConfig.fromJson(Map<String, dynamic> json) =>
      _$$_ServerConfigFromJson(json);

  @override
  final String githubToken;
  @override
  final String sendgridToken;
  @override
  final String failureEmail;

  @override
  String toString() {
    return 'ServerConfig(githubToken: $githubToken, sendgridToken: $sendgridToken, failureEmail: $failureEmail)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_ServerConfig &&
            const DeepCollectionEquality()
                .equals(other.githubToken, githubToken) &&
            const DeepCollectionEquality()
                .equals(other.sendgridToken, sendgridToken) &&
            const DeepCollectionEquality()
                .equals(other.failureEmail, failureEmail));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(githubToken),
      const DeepCollectionEquality().hash(sendgridToken),
      const DeepCollectionEquality().hash(failureEmail));

  @JsonKey(ignore: true)
  @override
  _$$_ServerConfigCopyWith<_$_ServerConfig> get copyWith =>
      __$$_ServerConfigCopyWithImpl<_$_ServerConfig>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_ServerConfigToJson(
      this,
    );
  }
}

abstract class _ServerConfig implements ServerConfig {
  factory _ServerConfig(
      {required final String githubToken,
      required final String sendgridToken,
      required final String failureEmail}) = _$_ServerConfig;

  factory _ServerConfig.fromJson(Map<String, dynamic> json) =
      _$_ServerConfig.fromJson;

  @override
  String get githubToken;
  @override
  String get sendgridToken;
  @override
  String get failureEmail;
  @override
  @JsonKey(ignore: true)
  _$$_ServerConfigCopyWith<_$_ServerConfig> get copyWith =>
      throw _privateConstructorUsedError;
}
