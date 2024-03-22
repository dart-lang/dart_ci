// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

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
      _$EngineVariantCopyWithImpl<$Res, EngineVariant>;
  @useResult
  $Res call({String os, String? arch, String? mode});
}

/// @nodoc
class _$EngineVariantCopyWithImpl<$Res, $Val extends EngineVariant>
    implements $EngineVariantCopyWith<$Res> {
  _$EngineVariantCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? os = null,
    Object? arch = freezed,
    Object? mode = freezed,
  }) {
    return _then(_value.copyWith(
      os: null == os
          ? _value.os
          : os // ignore: cast_nullable_to_non_nullable
              as String,
      arch: freezed == arch
          ? _value.arch
          : arch // ignore: cast_nullable_to_non_nullable
              as String?,
      mode: freezed == mode
          ? _value.mode
          : mode // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EngineVariantImplCopyWith<$Res>
    implements $EngineVariantCopyWith<$Res> {
  factory _$$EngineVariantImplCopyWith(
          _$EngineVariantImpl value, $Res Function(_$EngineVariantImpl) then) =
      __$$EngineVariantImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String os, String? arch, String? mode});
}

/// @nodoc
class __$$EngineVariantImplCopyWithImpl<$Res>
    extends _$EngineVariantCopyWithImpl<$Res, _$EngineVariantImpl>
    implements _$$EngineVariantImplCopyWith<$Res> {
  __$$EngineVariantImplCopyWithImpl(
      _$EngineVariantImpl _value, $Res Function(_$EngineVariantImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? os = null,
    Object? arch = freezed,
    Object? mode = freezed,
  }) {
    return _then(_$EngineVariantImpl(
      os: null == os
          ? _value.os
          : os // ignore: cast_nullable_to_non_nullable
              as String,
      arch: freezed == arch
          ? _value.arch
          : arch // ignore: cast_nullable_to_non_nullable
              as String?,
      mode: freezed == mode
          ? _value.mode
          : mode // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EngineVariantImpl implements _EngineVariant {
  _$EngineVariantImpl(
      {required this.os, required this.arch, required this.mode});

  factory _$EngineVariantImpl.fromJson(Map<String, dynamic> json) =>
      _$$EngineVariantImplFromJson(json);

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
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EngineVariantImpl &&
            (identical(other.os, os) || other.os == os) &&
            (identical(other.arch, arch) || other.arch == arch) &&
            (identical(other.mode, mode) || other.mode == mode));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, os, arch, mode);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$EngineVariantImplCopyWith<_$EngineVariantImpl> get copyWith =>
      __$$EngineVariantImplCopyWithImpl<_$EngineVariantImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EngineVariantImplToJson(
      this,
    );
  }
}

abstract class _EngineVariant implements EngineVariant {
  factory _EngineVariant(
      {required final String os,
      required final String? arch,
      required final String? mode}) = _$EngineVariantImpl;

  factory _EngineVariant.fromJson(Map<String, dynamic> json) =
      _$EngineVariantImpl.fromJson;

  @override
  String get os;
  @override
  String? get arch;
  @override
  String? get mode;
  @override
  @JsonKey(ignore: true)
  _$$EngineVariantImplCopyWith<_$EngineVariantImpl> get copyWith =>
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
      _$EngineBuildCopyWithImpl<$Res, EngineBuild>;
  @useResult
  $Res call({String engineHash, EngineVariant variant});

  $EngineVariantCopyWith<$Res> get variant;
}

/// @nodoc
class _$EngineBuildCopyWithImpl<$Res, $Val extends EngineBuild>
    implements $EngineBuildCopyWith<$Res> {
  _$EngineBuildCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? engineHash = null,
    Object? variant = null,
  }) {
    return _then(_value.copyWith(
      engineHash: null == engineHash
          ? _value.engineHash
          : engineHash // ignore: cast_nullable_to_non_nullable
              as String,
      variant: null == variant
          ? _value.variant
          : variant // ignore: cast_nullable_to_non_nullable
              as EngineVariant,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $EngineVariantCopyWith<$Res> get variant {
    return $EngineVariantCopyWith<$Res>(_value.variant, (value) {
      return _then(_value.copyWith(variant: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$EngineBuildImplCopyWith<$Res>
    implements $EngineBuildCopyWith<$Res> {
  factory _$$EngineBuildImplCopyWith(
          _$EngineBuildImpl value, $Res Function(_$EngineBuildImpl) then) =
      __$$EngineBuildImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String engineHash, EngineVariant variant});

  @override
  $EngineVariantCopyWith<$Res> get variant;
}

/// @nodoc
class __$$EngineBuildImplCopyWithImpl<$Res>
    extends _$EngineBuildCopyWithImpl<$Res, _$EngineBuildImpl>
    implements _$$EngineBuildImplCopyWith<$Res> {
  __$$EngineBuildImplCopyWithImpl(
      _$EngineBuildImpl _value, $Res Function(_$EngineBuildImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? engineHash = null,
    Object? variant = null,
  }) {
    return _then(_$EngineBuildImpl(
      engineHash: null == engineHash
          ? _value.engineHash
          : engineHash // ignore: cast_nullable_to_non_nullable
              as String,
      variant: null == variant
          ? _value.variant
          : variant // ignore: cast_nullable_to_non_nullable
              as EngineVariant,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EngineBuildImpl implements _EngineBuild {
  _$EngineBuildImpl({required this.engineHash, required this.variant});

  factory _$EngineBuildImpl.fromJson(Map<String, dynamic> json) =>
      _$$EngineBuildImplFromJson(json);

  @override
  final String engineHash;
  @override
  final EngineVariant variant;

  @override
  String toString() {
    return 'EngineBuild(engineHash: $engineHash, variant: $variant)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EngineBuildImpl &&
            (identical(other.engineHash, engineHash) ||
                other.engineHash == engineHash) &&
            (identical(other.variant, variant) || other.variant == variant));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, engineHash, variant);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$EngineBuildImplCopyWith<_$EngineBuildImpl> get copyWith =>
      __$$EngineBuildImplCopyWithImpl<_$EngineBuildImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EngineBuildImplToJson(
      this,
    );
  }
}

abstract class _EngineBuild implements EngineBuild {
  factory _EngineBuild(
      {required final String engineHash,
      required final EngineVariant variant}) = _$EngineBuildImpl;

  factory _EngineBuild.fromJson(Map<String, dynamic> json) =
      _$EngineBuildImpl.fromJson;

  @override
  String get engineHash;
  @override
  EngineVariant get variant;
  @override
  @JsonKey(ignore: true)
  _$$EngineBuildImplCopyWith<_$EngineBuildImpl> get copyWith =>
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
    TResult? Function(String no, String binary, int pc, String symbol,
            int? offset, String location)?
        ios,
    TResult? Function(
            String no, int pc, String binary, String rest, String? buildId)?
        android,
    TResult? Function(String no, int pc, String binary, int? offset,
            String? location, String? symbol)?
        custom,
    TResult? Function(int pc, String binary, int offset)? dartvm,
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
    TResult? Function(IosCrashFrame value)? ios,
    TResult? Function(AndroidCrashFrame value)? android,
    TResult? Function(CustomCrashFrame value)? custom,
    TResult? Function(DartvmCrashFrame value)? dartvm,
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
      _$CrashFrameCopyWithImpl<$Res, CrashFrame>;
  @useResult
  $Res call({String binary, int pc});
}

/// @nodoc
class _$CrashFrameCopyWithImpl<$Res, $Val extends CrashFrame>
    implements $CrashFrameCopyWith<$Res> {
  _$CrashFrameCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? binary = null,
    Object? pc = null,
  }) {
    return _then(_value.copyWith(
      binary: null == binary
          ? _value.binary
          : binary // ignore: cast_nullable_to_non_nullable
              as String,
      pc: null == pc
          ? _value.pc
          : pc // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$IosCrashFrameImplCopyWith<$Res>
    implements $CrashFrameCopyWith<$Res> {
  factory _$$IosCrashFrameImplCopyWith(
          _$IosCrashFrameImpl value, $Res Function(_$IosCrashFrameImpl) then) =
      __$$IosCrashFrameImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String no,
      String binary,
      int pc,
      String symbol,
      int? offset,
      String location});
}

/// @nodoc
class __$$IosCrashFrameImplCopyWithImpl<$Res>
    extends _$CrashFrameCopyWithImpl<$Res, _$IosCrashFrameImpl>
    implements _$$IosCrashFrameImplCopyWith<$Res> {
  __$$IosCrashFrameImplCopyWithImpl(
      _$IosCrashFrameImpl _value, $Res Function(_$IosCrashFrameImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? no = null,
    Object? binary = null,
    Object? pc = null,
    Object? symbol = null,
    Object? offset = freezed,
    Object? location = null,
  }) {
    return _then(_$IosCrashFrameImpl(
      no: null == no
          ? _value.no
          : no // ignore: cast_nullable_to_non_nullable
              as String,
      binary: null == binary
          ? _value.binary
          : binary // ignore: cast_nullable_to_non_nullable
              as String,
      pc: null == pc
          ? _value.pc
          : pc // ignore: cast_nullable_to_non_nullable
              as int,
      symbol: null == symbol
          ? _value.symbol
          : symbol // ignore: cast_nullable_to_non_nullable
              as String,
      offset: freezed == offset
          ? _value.offset
          : offset // ignore: cast_nullable_to_non_nullable
              as int?,
      location: null == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$IosCrashFrameImpl implements IosCrashFrame {
  _$IosCrashFrameImpl(
      {required this.no,
      required this.binary,
      required this.pc,
      required this.symbol,
      required this.offset,
      required this.location,
      final String? $type})
      : $type = $type ?? 'ios';

  factory _$IosCrashFrameImpl.fromJson(Map<String, dynamic> json) =>
      _$$IosCrashFrameImplFromJson(json);

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
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$IosCrashFrameImpl &&
            (identical(other.no, no) || other.no == no) &&
            (identical(other.binary, binary) || other.binary == binary) &&
            (identical(other.pc, pc) || other.pc == pc) &&
            (identical(other.symbol, symbol) || other.symbol == symbol) &&
            (identical(other.offset, offset) || other.offset == offset) &&
            (identical(other.location, location) ||
                other.location == location));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, no, binary, pc, symbol, offset, location);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$IosCrashFrameImplCopyWith<_$IosCrashFrameImpl> get copyWith =>
      __$$IosCrashFrameImplCopyWithImpl<_$IosCrashFrameImpl>(this, _$identity);

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
    TResult? Function(String no, String binary, int pc, String symbol,
            int? offset, String location)?
        ios,
    TResult? Function(
            String no, int pc, String binary, String rest, String? buildId)?
        android,
    TResult? Function(String no, int pc, String binary, int? offset,
            String? location, String? symbol)?
        custom,
    TResult? Function(int pc, String binary, int offset)? dartvm,
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
    TResult? Function(IosCrashFrame value)? ios,
    TResult? Function(AndroidCrashFrame value)? android,
    TResult? Function(CustomCrashFrame value)? custom,
    TResult? Function(DartvmCrashFrame value)? dartvm,
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
    return _$$IosCrashFrameImplToJson(
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
      required final String location}) = _$IosCrashFrameImpl;

  factory IosCrashFrame.fromJson(Map<String, dynamic> json) =
      _$IosCrashFrameImpl.fromJson;

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
  _$$IosCrashFrameImplCopyWith<_$IosCrashFrameImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$AndroidCrashFrameImplCopyWith<$Res>
    implements $CrashFrameCopyWith<$Res> {
  factory _$$AndroidCrashFrameImplCopyWith(_$AndroidCrashFrameImpl value,
          $Res Function(_$AndroidCrashFrameImpl) then) =
      __$$AndroidCrashFrameImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String no, int pc, String binary, String rest, String? buildId});
}

/// @nodoc
class __$$AndroidCrashFrameImplCopyWithImpl<$Res>
    extends _$CrashFrameCopyWithImpl<$Res, _$AndroidCrashFrameImpl>
    implements _$$AndroidCrashFrameImplCopyWith<$Res> {
  __$$AndroidCrashFrameImplCopyWithImpl(_$AndroidCrashFrameImpl _value,
      $Res Function(_$AndroidCrashFrameImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? no = null,
    Object? pc = null,
    Object? binary = null,
    Object? rest = null,
    Object? buildId = freezed,
  }) {
    return _then(_$AndroidCrashFrameImpl(
      no: null == no
          ? _value.no
          : no // ignore: cast_nullable_to_non_nullable
              as String,
      pc: null == pc
          ? _value.pc
          : pc // ignore: cast_nullable_to_non_nullable
              as int,
      binary: null == binary
          ? _value.binary
          : binary // ignore: cast_nullable_to_non_nullable
              as String,
      rest: null == rest
          ? _value.rest
          : rest // ignore: cast_nullable_to_non_nullable
              as String,
      buildId: freezed == buildId
          ? _value.buildId
          : buildId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AndroidCrashFrameImpl implements AndroidCrashFrame {
  _$AndroidCrashFrameImpl(
      {required this.no,
      required this.pc,
      required this.binary,
      required this.rest,
      required this.buildId,
      final String? $type})
      : $type = $type ?? 'android';

  factory _$AndroidCrashFrameImpl.fromJson(Map<String, dynamic> json) =>
      _$$AndroidCrashFrameImplFromJson(json);

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
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AndroidCrashFrameImpl &&
            (identical(other.no, no) || other.no == no) &&
            (identical(other.pc, pc) || other.pc == pc) &&
            (identical(other.binary, binary) || other.binary == binary) &&
            (identical(other.rest, rest) || other.rest == rest) &&
            (identical(other.buildId, buildId) || other.buildId == buildId));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, no, pc, binary, rest, buildId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AndroidCrashFrameImplCopyWith<_$AndroidCrashFrameImpl> get copyWith =>
      __$$AndroidCrashFrameImplCopyWithImpl<_$AndroidCrashFrameImpl>(
          this, _$identity);

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
    TResult? Function(String no, String binary, int pc, String symbol,
            int? offset, String location)?
        ios,
    TResult? Function(
            String no, int pc, String binary, String rest, String? buildId)?
        android,
    TResult? Function(String no, int pc, String binary, int? offset,
            String? location, String? symbol)?
        custom,
    TResult? Function(int pc, String binary, int offset)? dartvm,
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
    TResult? Function(IosCrashFrame value)? ios,
    TResult? Function(AndroidCrashFrame value)? android,
    TResult? Function(CustomCrashFrame value)? custom,
    TResult? Function(DartvmCrashFrame value)? dartvm,
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
    return _$$AndroidCrashFrameImplToJson(
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
      required final String? buildId}) = _$AndroidCrashFrameImpl;

  factory AndroidCrashFrame.fromJson(Map<String, dynamic> json) =
      _$AndroidCrashFrameImpl.fromJson;

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
  _$$AndroidCrashFrameImplCopyWith<_$AndroidCrashFrameImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$CustomCrashFrameImplCopyWith<$Res>
    implements $CrashFrameCopyWith<$Res> {
  factory _$$CustomCrashFrameImplCopyWith(_$CustomCrashFrameImpl value,
          $Res Function(_$CustomCrashFrameImpl) then) =
      __$$CustomCrashFrameImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String no,
      int pc,
      String binary,
      int? offset,
      String? location,
      String? symbol});
}

/// @nodoc
class __$$CustomCrashFrameImplCopyWithImpl<$Res>
    extends _$CrashFrameCopyWithImpl<$Res, _$CustomCrashFrameImpl>
    implements _$$CustomCrashFrameImplCopyWith<$Res> {
  __$$CustomCrashFrameImplCopyWithImpl(_$CustomCrashFrameImpl _value,
      $Res Function(_$CustomCrashFrameImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? no = null,
    Object? pc = null,
    Object? binary = null,
    Object? offset = freezed,
    Object? location = freezed,
    Object? symbol = freezed,
  }) {
    return _then(_$CustomCrashFrameImpl(
      no: null == no
          ? _value.no
          : no // ignore: cast_nullable_to_non_nullable
              as String,
      pc: null == pc
          ? _value.pc
          : pc // ignore: cast_nullable_to_non_nullable
              as int,
      binary: null == binary
          ? _value.binary
          : binary // ignore: cast_nullable_to_non_nullable
              as String,
      offset: freezed == offset
          ? _value.offset
          : offset // ignore: cast_nullable_to_non_nullable
              as int?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      symbol: freezed == symbol
          ? _value.symbol
          : symbol // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CustomCrashFrameImpl implements CustomCrashFrame {
  _$CustomCrashFrameImpl(
      {required this.no,
      required this.pc,
      required this.binary,
      required this.offset,
      required this.location,
      required this.symbol,
      final String? $type})
      : $type = $type ?? 'custom';

  factory _$CustomCrashFrameImpl.fromJson(Map<String, dynamic> json) =>
      _$$CustomCrashFrameImplFromJson(json);

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
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CustomCrashFrameImpl &&
            (identical(other.no, no) || other.no == no) &&
            (identical(other.pc, pc) || other.pc == pc) &&
            (identical(other.binary, binary) || other.binary == binary) &&
            (identical(other.offset, offset) || other.offset == offset) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.symbol, symbol) || other.symbol == symbol));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, no, pc, binary, offset, location, symbol);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CustomCrashFrameImplCopyWith<_$CustomCrashFrameImpl> get copyWith =>
      __$$CustomCrashFrameImplCopyWithImpl<_$CustomCrashFrameImpl>(
          this, _$identity);

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
    TResult? Function(String no, String binary, int pc, String symbol,
            int? offset, String location)?
        ios,
    TResult? Function(
            String no, int pc, String binary, String rest, String? buildId)?
        android,
    TResult? Function(String no, int pc, String binary, int? offset,
            String? location, String? symbol)?
        custom,
    TResult? Function(int pc, String binary, int offset)? dartvm,
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
    TResult? Function(IosCrashFrame value)? ios,
    TResult? Function(AndroidCrashFrame value)? android,
    TResult? Function(CustomCrashFrame value)? custom,
    TResult? Function(DartvmCrashFrame value)? dartvm,
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
    return _$$CustomCrashFrameImplToJson(
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
      required final String? symbol}) = _$CustomCrashFrameImpl;

  factory CustomCrashFrame.fromJson(Map<String, dynamic> json) =
      _$CustomCrashFrameImpl.fromJson;

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
  _$$CustomCrashFrameImplCopyWith<_$CustomCrashFrameImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$DartvmCrashFrameImplCopyWith<$Res>
    implements $CrashFrameCopyWith<$Res> {
  factory _$$DartvmCrashFrameImplCopyWith(_$DartvmCrashFrameImpl value,
          $Res Function(_$DartvmCrashFrameImpl) then) =
      __$$DartvmCrashFrameImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int pc, String binary, int offset});
}

/// @nodoc
class __$$DartvmCrashFrameImplCopyWithImpl<$Res>
    extends _$CrashFrameCopyWithImpl<$Res, _$DartvmCrashFrameImpl>
    implements _$$DartvmCrashFrameImplCopyWith<$Res> {
  __$$DartvmCrashFrameImplCopyWithImpl(_$DartvmCrashFrameImpl _value,
      $Res Function(_$DartvmCrashFrameImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pc = null,
    Object? binary = null,
    Object? offset = null,
  }) {
    return _then(_$DartvmCrashFrameImpl(
      pc: null == pc
          ? _value.pc
          : pc // ignore: cast_nullable_to_non_nullable
              as int,
      binary: null == binary
          ? _value.binary
          : binary // ignore: cast_nullable_to_non_nullable
              as String,
      offset: null == offset
          ? _value.offset
          : offset // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DartvmCrashFrameImpl implements DartvmCrashFrame {
  _$DartvmCrashFrameImpl(
      {required this.pc,
      required this.binary,
      required this.offset,
      final String? $type})
      : $type = $type ?? 'dartvm';

  factory _$DartvmCrashFrameImpl.fromJson(Map<String, dynamic> json) =>
      _$$DartvmCrashFrameImplFromJson(json);

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
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DartvmCrashFrameImpl &&
            (identical(other.pc, pc) || other.pc == pc) &&
            (identical(other.binary, binary) || other.binary == binary) &&
            (identical(other.offset, offset) || other.offset == offset));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, pc, binary, offset);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DartvmCrashFrameImplCopyWith<_$DartvmCrashFrameImpl> get copyWith =>
      __$$DartvmCrashFrameImplCopyWithImpl<_$DartvmCrashFrameImpl>(
          this, _$identity);

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
    TResult? Function(String no, String binary, int pc, String symbol,
            int? offset, String location)?
        ios,
    TResult? Function(
            String no, int pc, String binary, String rest, String? buildId)?
        android,
    TResult? Function(String no, int pc, String binary, int? offset,
            String? location, String? symbol)?
        custom,
    TResult? Function(int pc, String binary, int offset)? dartvm,
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
    TResult? Function(IosCrashFrame value)? ios,
    TResult? Function(AndroidCrashFrame value)? android,
    TResult? Function(CustomCrashFrame value)? custom,
    TResult? Function(DartvmCrashFrame value)? dartvm,
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
    return _$$DartvmCrashFrameImplToJson(
      this,
    );
  }
}

abstract class DartvmCrashFrame implements CrashFrame {
  factory DartvmCrashFrame(
      {required final int pc,
      required final String binary,
      required final int offset}) = _$DartvmCrashFrameImpl;

  factory DartvmCrashFrame.fromJson(Map<String, dynamic> json) =
      _$DartvmCrashFrameImpl.fromJson;

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
  _$$DartvmCrashFrameImplCopyWith<_$DartvmCrashFrameImpl> get copyWith =>
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
      _$CrashCopyWithImpl<$Res, Crash>;
  @useResult
  $Res call(
      {EngineVariant engineVariant,
      List<CrashFrame> frames,
      String format,
      int? androidMajorVersion});

  $EngineVariantCopyWith<$Res> get engineVariant;
}

/// @nodoc
class _$CrashCopyWithImpl<$Res, $Val extends Crash>
    implements $CrashCopyWith<$Res> {
  _$CrashCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? engineVariant = null,
    Object? frames = null,
    Object? format = null,
    Object? androidMajorVersion = freezed,
  }) {
    return _then(_value.copyWith(
      engineVariant: null == engineVariant
          ? _value.engineVariant
          : engineVariant // ignore: cast_nullable_to_non_nullable
              as EngineVariant,
      frames: null == frames
          ? _value.frames
          : frames // ignore: cast_nullable_to_non_nullable
              as List<CrashFrame>,
      format: null == format
          ? _value.format
          : format // ignore: cast_nullable_to_non_nullable
              as String,
      androidMajorVersion: freezed == androidMajorVersion
          ? _value.androidMajorVersion
          : androidMajorVersion // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $EngineVariantCopyWith<$Res> get engineVariant {
    return $EngineVariantCopyWith<$Res>(_value.engineVariant, (value) {
      return _then(_value.copyWith(engineVariant: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CrashImplCopyWith<$Res> implements $CrashCopyWith<$Res> {
  factory _$$CrashImplCopyWith(
          _$CrashImpl value, $Res Function(_$CrashImpl) then) =
      __$$CrashImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {EngineVariant engineVariant,
      List<CrashFrame> frames,
      String format,
      int? androidMajorVersion});

  @override
  $EngineVariantCopyWith<$Res> get engineVariant;
}

/// @nodoc
class __$$CrashImplCopyWithImpl<$Res>
    extends _$CrashCopyWithImpl<$Res, _$CrashImpl>
    implements _$$CrashImplCopyWith<$Res> {
  __$$CrashImplCopyWithImpl(
      _$CrashImpl _value, $Res Function(_$CrashImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? engineVariant = null,
    Object? frames = null,
    Object? format = null,
    Object? androidMajorVersion = freezed,
  }) {
    return _then(_$CrashImpl(
      engineVariant: null == engineVariant
          ? _value.engineVariant
          : engineVariant // ignore: cast_nullable_to_non_nullable
              as EngineVariant,
      frames: null == frames
          ? _value._frames
          : frames // ignore: cast_nullable_to_non_nullable
              as List<CrashFrame>,
      format: null == format
          ? _value.format
          : format // ignore: cast_nullable_to_non_nullable
              as String,
      androidMajorVersion: freezed == androidMajorVersion
          ? _value.androidMajorVersion
          : androidMajorVersion // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CrashImpl implements _Crash {
  _$CrashImpl(
      {required this.engineVariant,
      required final List<CrashFrame> frames,
      required this.format,
      this.androidMajorVersion})
      : _frames = frames;

  factory _$CrashImpl.fromJson(Map<String, dynamic> json) =>
      _$$CrashImplFromJson(json);

  @override
  final EngineVariant engineVariant;
  final List<CrashFrame> _frames;
  @override
  List<CrashFrame> get frames {
    if (_frames is EqualUnmodifiableListView) return _frames;
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
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CrashImpl &&
            (identical(other.engineVariant, engineVariant) ||
                other.engineVariant == engineVariant) &&
            const DeepCollectionEquality().equals(other._frames, _frames) &&
            (identical(other.format, format) || other.format == format) &&
            (identical(other.androidMajorVersion, androidMajorVersion) ||
                other.androidMajorVersion == androidMajorVersion));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      engineVariant,
      const DeepCollectionEquality().hash(_frames),
      format,
      androidMajorVersion);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CrashImplCopyWith<_$CrashImpl> get copyWith =>
      __$$CrashImplCopyWithImpl<_$CrashImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CrashImplToJson(
      this,
    );
  }
}

abstract class _Crash implements Crash {
  factory _Crash(
      {required final EngineVariant engineVariant,
      required final List<CrashFrame> frames,
      required final String format,
      final int? androidMajorVersion}) = _$CrashImpl;

  factory _Crash.fromJson(Map<String, dynamic> json) = _$CrashImpl.fromJson;

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
  _$$CrashImplCopyWith<_$CrashImpl> get copyWith =>
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
    TResult? Function(List<CrashSymbolizationResult> results)? ok,
    TResult? Function(SymbolizationNote error)? error,
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
    TResult? Function(SymbolizationResultOk value)? ok,
    TResult? Function(SymbolizationResultError value)? error,
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
      _$SymbolizationResultCopyWithImpl<$Res, SymbolizationResult>;
}

/// @nodoc
class _$SymbolizationResultCopyWithImpl<$Res, $Val extends SymbolizationResult>
    implements $SymbolizationResultCopyWith<$Res> {
  _$SymbolizationResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$SymbolizationResultOkImplCopyWith<$Res> {
  factory _$$SymbolizationResultOkImplCopyWith(
          _$SymbolizationResultOkImpl value,
          $Res Function(_$SymbolizationResultOkImpl) then) =
      __$$SymbolizationResultOkImplCopyWithImpl<$Res>;
  @useResult
  $Res call({List<CrashSymbolizationResult> results});
}

/// @nodoc
class __$$SymbolizationResultOkImplCopyWithImpl<$Res>
    extends _$SymbolizationResultCopyWithImpl<$Res, _$SymbolizationResultOkImpl>
    implements _$$SymbolizationResultOkImplCopyWith<$Res> {
  __$$SymbolizationResultOkImplCopyWithImpl(_$SymbolizationResultOkImpl _value,
      $Res Function(_$SymbolizationResultOkImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? results = null,
  }) {
    return _then(_$SymbolizationResultOkImpl(
      results: null == results
          ? _value._results
          : results // ignore: cast_nullable_to_non_nullable
              as List<CrashSymbolizationResult>,
    ));
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _$SymbolizationResultOkImpl implements SymbolizationResultOk {
  _$SymbolizationResultOkImpl(
      {required final List<CrashSymbolizationResult> results,
      final String? $type})
      : _results = results,
        $type = $type ?? 'ok';

  factory _$SymbolizationResultOkImpl.fromJson(Map<String, dynamic> json) =>
      _$$SymbolizationResultOkImplFromJson(json);

  final List<CrashSymbolizationResult> _results;
  @override
  List<CrashSymbolizationResult> get results {
    if (_results is EqualUnmodifiableListView) return _results;
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
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SymbolizationResultOkImpl &&
            const DeepCollectionEquality().equals(other._results, _results));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_results));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SymbolizationResultOkImplCopyWith<_$SymbolizationResultOkImpl>
      get copyWith => __$$SymbolizationResultOkImplCopyWithImpl<
          _$SymbolizationResultOkImpl>(this, _$identity);

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
    TResult? Function(List<CrashSymbolizationResult> results)? ok,
    TResult? Function(SymbolizationNote error)? error,
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
    TResult? Function(SymbolizationResultOk value)? ok,
    TResult? Function(SymbolizationResultError value)? error,
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
    return _$$SymbolizationResultOkImplToJson(
      this,
    );
  }
}

abstract class SymbolizationResultOk implements SymbolizationResult {
  factory SymbolizationResultOk(
          {required final List<CrashSymbolizationResult> results}) =
      _$SymbolizationResultOkImpl;

  factory SymbolizationResultOk.fromJson(Map<String, dynamic> json) =
      _$SymbolizationResultOkImpl.fromJson;

  List<CrashSymbolizationResult> get results;
  @JsonKey(ignore: true)
  _$$SymbolizationResultOkImplCopyWith<_$SymbolizationResultOkImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$SymbolizationResultErrorImplCopyWith<$Res> {
  factory _$$SymbolizationResultErrorImplCopyWith(
          _$SymbolizationResultErrorImpl value,
          $Res Function(_$SymbolizationResultErrorImpl) then) =
      __$$SymbolizationResultErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({SymbolizationNote error});

  $SymbolizationNoteCopyWith<$Res> get error;
}

/// @nodoc
class __$$SymbolizationResultErrorImplCopyWithImpl<$Res>
    extends _$SymbolizationResultCopyWithImpl<$Res,
        _$SymbolizationResultErrorImpl>
    implements _$$SymbolizationResultErrorImplCopyWith<$Res> {
  __$$SymbolizationResultErrorImplCopyWithImpl(
      _$SymbolizationResultErrorImpl _value,
      $Res Function(_$SymbolizationResultErrorImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? error = null,
  }) {
    return _then(_$SymbolizationResultErrorImpl(
      error: null == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as SymbolizationNote,
    ));
  }

  @override
  @pragma('vm:prefer-inline')
  $SymbolizationNoteCopyWith<$Res> get error {
    return $SymbolizationNoteCopyWith<$Res>(_value.error, (value) {
      return _then(_value.copyWith(error: value));
    });
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _$SymbolizationResultErrorImpl implements SymbolizationResultError {
  _$SymbolizationResultErrorImpl({required this.error, final String? $type})
      : $type = $type ?? 'error';

  factory _$SymbolizationResultErrorImpl.fromJson(Map<String, dynamic> json) =>
      _$$SymbolizationResultErrorImplFromJson(json);

  @override
  final SymbolizationNote error;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString() {
    return 'SymbolizationResult.error(error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SymbolizationResultErrorImpl &&
            (identical(other.error, error) || other.error == error));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, error);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SymbolizationResultErrorImplCopyWith<_$SymbolizationResultErrorImpl>
      get copyWith => __$$SymbolizationResultErrorImplCopyWithImpl<
          _$SymbolizationResultErrorImpl>(this, _$identity);

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
    TResult? Function(List<CrashSymbolizationResult> results)? ok,
    TResult? Function(SymbolizationNote error)? error,
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
    TResult? Function(SymbolizationResultOk value)? ok,
    TResult? Function(SymbolizationResultError value)? error,
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
    return _$$SymbolizationResultErrorImplToJson(
      this,
    );
  }
}

abstract class SymbolizationResultError implements SymbolizationResult {
  factory SymbolizationResultError({required final SymbolizationNote error}) =
      _$SymbolizationResultErrorImpl;

  factory SymbolizationResultError.fromJson(Map<String, dynamic> json) =
      _$SymbolizationResultErrorImpl.fromJson;

  SymbolizationNote get error;
  @JsonKey(ignore: true)
  _$$SymbolizationResultErrorImplCopyWith<_$SymbolizationResultErrorImpl>
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
      _$CrashSymbolizationResultCopyWithImpl<$Res, CrashSymbolizationResult>;
  @useResult
  $Res call(
      {Crash crash,
      EngineBuild? engineBuild,
      String? symbolized,
      List<SymbolizationNote> notes});

  $CrashCopyWith<$Res> get crash;
  $EngineBuildCopyWith<$Res>? get engineBuild;
}

/// @nodoc
class _$CrashSymbolizationResultCopyWithImpl<$Res,
        $Val extends CrashSymbolizationResult>
    implements $CrashSymbolizationResultCopyWith<$Res> {
  _$CrashSymbolizationResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? crash = null,
    Object? engineBuild = freezed,
    Object? symbolized = freezed,
    Object? notes = null,
  }) {
    return _then(_value.copyWith(
      crash: null == crash
          ? _value.crash
          : crash // ignore: cast_nullable_to_non_nullable
              as Crash,
      engineBuild: freezed == engineBuild
          ? _value.engineBuild
          : engineBuild // ignore: cast_nullable_to_non_nullable
              as EngineBuild?,
      symbolized: freezed == symbolized
          ? _value.symbolized
          : symbolized // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: null == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as List<SymbolizationNote>,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $CrashCopyWith<$Res> get crash {
    return $CrashCopyWith<$Res>(_value.crash, (value) {
      return _then(_value.copyWith(crash: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $EngineBuildCopyWith<$Res>? get engineBuild {
    if (_value.engineBuild == null) {
      return null;
    }

    return $EngineBuildCopyWith<$Res>(_value.engineBuild!, (value) {
      return _then(_value.copyWith(engineBuild: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CrashSymbolizationResultImplCopyWith<$Res>
    implements $CrashSymbolizationResultCopyWith<$Res> {
  factory _$$CrashSymbolizationResultImplCopyWith(
          _$CrashSymbolizationResultImpl value,
          $Res Function(_$CrashSymbolizationResultImpl) then) =
      __$$CrashSymbolizationResultImplCopyWithImpl<$Res>;
  @override
  @useResult
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
class __$$CrashSymbolizationResultImplCopyWithImpl<$Res>
    extends _$CrashSymbolizationResultCopyWithImpl<$Res,
        _$CrashSymbolizationResultImpl>
    implements _$$CrashSymbolizationResultImplCopyWith<$Res> {
  __$$CrashSymbolizationResultImplCopyWithImpl(
      _$CrashSymbolizationResultImpl _value,
      $Res Function(_$CrashSymbolizationResultImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? crash = null,
    Object? engineBuild = freezed,
    Object? symbolized = freezed,
    Object? notes = null,
  }) {
    return _then(_$CrashSymbolizationResultImpl(
      crash: null == crash
          ? _value.crash
          : crash // ignore: cast_nullable_to_non_nullable
              as Crash,
      engineBuild: freezed == engineBuild
          ? _value.engineBuild
          : engineBuild // ignore: cast_nullable_to_non_nullable
              as EngineBuild?,
      symbolized: freezed == symbolized
          ? _value.symbolized
          : symbolized // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: null == notes
          ? _value._notes
          : notes // ignore: cast_nullable_to_non_nullable
              as List<SymbolizationNote>,
    ));
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _$CrashSymbolizationResultImpl implements _CrashSymbolizationResult {
  _$CrashSymbolizationResultImpl(
      {required this.crash,
      required this.engineBuild,
      required this.symbolized,
      final List<SymbolizationNote> notes = const []})
      : _notes = notes;

  factory _$CrashSymbolizationResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$CrashSymbolizationResultImplFromJson(json);

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
    if (_notes is EqualUnmodifiableListView) return _notes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_notes);
  }

  @override
  String toString() {
    return 'CrashSymbolizationResult(crash: $crash, engineBuild: $engineBuild, symbolized: $symbolized, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CrashSymbolizationResultImpl &&
            (identical(other.crash, crash) || other.crash == crash) &&
            (identical(other.engineBuild, engineBuild) ||
                other.engineBuild == engineBuild) &&
            (identical(other.symbolized, symbolized) ||
                other.symbolized == symbolized) &&
            const DeepCollectionEquality().equals(other._notes, _notes));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, crash, engineBuild, symbolized,
      const DeepCollectionEquality().hash(_notes));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CrashSymbolizationResultImplCopyWith<_$CrashSymbolizationResultImpl>
      get copyWith => __$$CrashSymbolizationResultImplCopyWithImpl<
          _$CrashSymbolizationResultImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CrashSymbolizationResultImplToJson(
      this,
    );
  }
}

abstract class _CrashSymbolizationResult implements CrashSymbolizationResult {
  factory _CrashSymbolizationResult(
      {required final Crash crash,
      required final EngineBuild? engineBuild,
      required final String? symbolized,
      final List<SymbolizationNote> notes}) = _$CrashSymbolizationResultImpl;

  factory _CrashSymbolizationResult.fromJson(Map<String, dynamic> json) =
      _$CrashSymbolizationResultImpl.fromJson;

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
  _$$CrashSymbolizationResultImplCopyWith<_$CrashSymbolizationResultImpl>
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
      _$SymbolizationNoteCopyWithImpl<$Res, SymbolizationNote>;
  @useResult
  $Res call({SymbolizationNoteKind kind, String? message});
}

/// @nodoc
class _$SymbolizationNoteCopyWithImpl<$Res, $Val extends SymbolizationNote>
    implements $SymbolizationNoteCopyWith<$Res> {
  _$SymbolizationNoteCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? kind = null,
    Object? message = freezed,
  }) {
    return _then(_value.copyWith(
      kind: null == kind
          ? _value.kind
          : kind // ignore: cast_nullable_to_non_nullable
              as SymbolizationNoteKind,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SymbolizationNoteImplCopyWith<$Res>
    implements $SymbolizationNoteCopyWith<$Res> {
  factory _$$SymbolizationNoteImplCopyWith(_$SymbolizationNoteImpl value,
          $Res Function(_$SymbolizationNoteImpl) then) =
      __$$SymbolizationNoteImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({SymbolizationNoteKind kind, String? message});
}

/// @nodoc
class __$$SymbolizationNoteImplCopyWithImpl<$Res>
    extends _$SymbolizationNoteCopyWithImpl<$Res, _$SymbolizationNoteImpl>
    implements _$$SymbolizationNoteImplCopyWith<$Res> {
  __$$SymbolizationNoteImplCopyWithImpl(_$SymbolizationNoteImpl _value,
      $Res Function(_$SymbolizationNoteImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? kind = null,
    Object? message = freezed,
  }) {
    return _then(_$SymbolizationNoteImpl(
      kind: null == kind
          ? _value.kind
          : kind // ignore: cast_nullable_to_non_nullable
              as SymbolizationNoteKind,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SymbolizationNoteImpl implements _SymbolizationNote {
  _$SymbolizationNoteImpl({required this.kind, this.message});

  factory _$SymbolizationNoteImpl.fromJson(Map<String, dynamic> json) =>
      _$$SymbolizationNoteImplFromJson(json);

  @override
  final SymbolizationNoteKind kind;
  @override
  final String? message;

  @override
  String toString() {
    return 'SymbolizationNote(kind: $kind, message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SymbolizationNoteImpl &&
            (identical(other.kind, kind) || other.kind == kind) &&
            (identical(other.message, message) || other.message == message));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, kind, message);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SymbolizationNoteImplCopyWith<_$SymbolizationNoteImpl> get copyWith =>
      __$$SymbolizationNoteImplCopyWithImpl<_$SymbolizationNoteImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SymbolizationNoteImplToJson(
      this,
    );
  }
}

abstract class _SymbolizationNote implements SymbolizationNote {
  factory _SymbolizationNote(
      {required final SymbolizationNoteKind kind,
      final String? message}) = _$SymbolizationNoteImpl;

  factory _SymbolizationNote.fromJson(Map<String, dynamic> json) =
      _$SymbolizationNoteImpl.fromJson;

  @override
  SymbolizationNoteKind get kind;
  @override
  String? get message;
  @override
  @JsonKey(ignore: true)
  _$$SymbolizationNoteImplCopyWith<_$SymbolizationNoteImpl> get copyWith =>
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
      _$BotCommandCopyWithImpl<$Res, BotCommand>;
  @useResult
  $Res call(
      {SymbolizationOverrides overrides,
      bool symbolizeThis,
      Set<String> worklist});

  $SymbolizationOverridesCopyWith<$Res> get overrides;
}

/// @nodoc
class _$BotCommandCopyWithImpl<$Res, $Val extends BotCommand>
    implements $BotCommandCopyWith<$Res> {
  _$BotCommandCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? overrides = null,
    Object? symbolizeThis = null,
    Object? worklist = null,
  }) {
    return _then(_value.copyWith(
      overrides: null == overrides
          ? _value.overrides
          : overrides // ignore: cast_nullable_to_non_nullable
              as SymbolizationOverrides,
      symbolizeThis: null == symbolizeThis
          ? _value.symbolizeThis
          : symbolizeThis // ignore: cast_nullable_to_non_nullable
              as bool,
      worklist: null == worklist
          ? _value.worklist
          : worklist // ignore: cast_nullable_to_non_nullable
              as Set<String>,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $SymbolizationOverridesCopyWith<$Res> get overrides {
    return $SymbolizationOverridesCopyWith<$Res>(_value.overrides, (value) {
      return _then(_value.copyWith(overrides: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$BotCommandImplCopyWith<$Res>
    implements $BotCommandCopyWith<$Res> {
  factory _$$BotCommandImplCopyWith(
          _$BotCommandImpl value, $Res Function(_$BotCommandImpl) then) =
      __$$BotCommandImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {SymbolizationOverrides overrides,
      bool symbolizeThis,
      Set<String> worklist});

  @override
  $SymbolizationOverridesCopyWith<$Res> get overrides;
}

/// @nodoc
class __$$BotCommandImplCopyWithImpl<$Res>
    extends _$BotCommandCopyWithImpl<$Res, _$BotCommandImpl>
    implements _$$BotCommandImplCopyWith<$Res> {
  __$$BotCommandImplCopyWithImpl(
      _$BotCommandImpl _value, $Res Function(_$BotCommandImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? overrides = null,
    Object? symbolizeThis = null,
    Object? worklist = null,
  }) {
    return _then(_$BotCommandImpl(
      overrides: null == overrides
          ? _value.overrides
          : overrides // ignore: cast_nullable_to_non_nullable
              as SymbolizationOverrides,
      symbolizeThis: null == symbolizeThis
          ? _value.symbolizeThis
          : symbolizeThis // ignore: cast_nullable_to_non_nullable
              as bool,
      worklist: null == worklist
          ? _value._worklist
          : worklist // ignore: cast_nullable_to_non_nullable
              as Set<String>,
    ));
  }
}

/// @nodoc

class _$BotCommandImpl implements _BotCommand {
  _$BotCommandImpl(
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
    if (_worklist is EqualUnmodifiableSetView) return _worklist;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_worklist);
  }

  @override
  String toString() {
    return 'BotCommand(overrides: $overrides, symbolizeThis: $symbolizeThis, worklist: $worklist)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BotCommandImpl &&
            (identical(other.overrides, overrides) ||
                other.overrides == overrides) &&
            (identical(other.symbolizeThis, symbolizeThis) ||
                other.symbolizeThis == symbolizeThis) &&
            const DeepCollectionEquality().equals(other._worklist, _worklist));
  }

  @override
  int get hashCode => Object.hash(runtimeType, overrides, symbolizeThis,
      const DeepCollectionEquality().hash(_worklist));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BotCommandImplCopyWith<_$BotCommandImpl> get copyWith =>
      __$$BotCommandImplCopyWithImpl<_$BotCommandImpl>(this, _$identity);
}

abstract class _BotCommand implements BotCommand {
  factory _BotCommand(
      {required final SymbolizationOverrides overrides,
      required final bool symbolizeThis,
      required final Set<String> worklist}) = _$BotCommandImpl;

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
  _$$BotCommandImplCopyWith<_$BotCommandImpl> get copyWith =>
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
      _$SymbolizationOverridesCopyWithImpl<$Res, SymbolizationOverrides>;
  @useResult
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
class _$SymbolizationOverridesCopyWithImpl<$Res,
        $Val extends SymbolizationOverrides>
    implements $SymbolizationOverridesCopyWith<$Res> {
  _$SymbolizationOverridesCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? engineHash = freezed,
    Object? flutterVersion = freezed,
    Object? arch = freezed,
    Object? mode = freezed,
    Object? force = null,
    Object? format = freezed,
    Object? os = freezed,
  }) {
    return _then(_value.copyWith(
      engineHash: freezed == engineHash
          ? _value.engineHash
          : engineHash // ignore: cast_nullable_to_non_nullable
              as String?,
      flutterVersion: freezed == flutterVersion
          ? _value.flutterVersion
          : flutterVersion // ignore: cast_nullable_to_non_nullable
              as String?,
      arch: freezed == arch
          ? _value.arch
          : arch // ignore: cast_nullable_to_non_nullable
              as String?,
      mode: freezed == mode
          ? _value.mode
          : mode // ignore: cast_nullable_to_non_nullable
              as String?,
      force: null == force
          ? _value.force
          : force // ignore: cast_nullable_to_non_nullable
              as bool,
      format: freezed == format
          ? _value.format
          : format // ignore: cast_nullable_to_non_nullable
              as String?,
      os: freezed == os
          ? _value.os
          : os // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SymbolizationOverridesImplCopyWith<$Res>
    implements $SymbolizationOverridesCopyWith<$Res> {
  factory _$$SymbolizationOverridesImplCopyWith(
          _$SymbolizationOverridesImpl value,
          $Res Function(_$SymbolizationOverridesImpl) then) =
      __$$SymbolizationOverridesImplCopyWithImpl<$Res>;
  @override
  @useResult
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
class __$$SymbolizationOverridesImplCopyWithImpl<$Res>
    extends _$SymbolizationOverridesCopyWithImpl<$Res,
        _$SymbolizationOverridesImpl>
    implements _$$SymbolizationOverridesImplCopyWith<$Res> {
  __$$SymbolizationOverridesImplCopyWithImpl(
      _$SymbolizationOverridesImpl _value,
      $Res Function(_$SymbolizationOverridesImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? engineHash = freezed,
    Object? flutterVersion = freezed,
    Object? arch = freezed,
    Object? mode = freezed,
    Object? force = null,
    Object? format = freezed,
    Object? os = freezed,
  }) {
    return _then(_$SymbolizationOverridesImpl(
      engineHash: freezed == engineHash
          ? _value.engineHash
          : engineHash // ignore: cast_nullable_to_non_nullable
              as String?,
      flutterVersion: freezed == flutterVersion
          ? _value.flutterVersion
          : flutterVersion // ignore: cast_nullable_to_non_nullable
              as String?,
      arch: freezed == arch
          ? _value.arch
          : arch // ignore: cast_nullable_to_non_nullable
              as String?,
      mode: freezed == mode
          ? _value.mode
          : mode // ignore: cast_nullable_to_non_nullable
              as String?,
      force: null == force
          ? _value.force
          : force // ignore: cast_nullable_to_non_nullable
              as bool,
      format: freezed == format
          ? _value.format
          : format // ignore: cast_nullable_to_non_nullable
              as String?,
      os: freezed == os
          ? _value.os
          : os // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$SymbolizationOverridesImpl implements _SymbolizationOverrides {
  _$SymbolizationOverridesImpl(
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
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SymbolizationOverridesImpl &&
            (identical(other.engineHash, engineHash) ||
                other.engineHash == engineHash) &&
            (identical(other.flutterVersion, flutterVersion) ||
                other.flutterVersion == flutterVersion) &&
            (identical(other.arch, arch) || other.arch == arch) &&
            (identical(other.mode, mode) || other.mode == mode) &&
            (identical(other.force, force) || other.force == force) &&
            (identical(other.format, format) || other.format == format) &&
            (identical(other.os, os) || other.os == os));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, engineHash, flutterVersion, arch, mode, force, format, os);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SymbolizationOverridesImplCopyWith<_$SymbolizationOverridesImpl>
      get copyWith => __$$SymbolizationOverridesImplCopyWithImpl<
          _$SymbolizationOverridesImpl>(this, _$identity);
}

abstract class _SymbolizationOverrides implements SymbolizationOverrides {
  factory _SymbolizationOverrides(
      {final String? engineHash,
      final String? flutterVersion,
      final String? arch,
      final String? mode,
      final bool force,
      final String? format,
      final String? os}) = _$SymbolizationOverridesImpl;

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
  _$$SymbolizationOverridesImplCopyWith<_$SymbolizationOverridesImpl>
      get copyWith => throw _privateConstructorUsedError;
}

ServerConfig _$ServerConfigFromJson(Map<String, dynamic> json) {
  return _ServerConfig.fromJson(json);
}

/// @nodoc
mixin _$ServerConfig {
  String get githubToken => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ServerConfigCopyWith<ServerConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ServerConfigCopyWith<$Res> {
  factory $ServerConfigCopyWith(
          ServerConfig value, $Res Function(ServerConfig) then) =
      _$ServerConfigCopyWithImpl<$Res, ServerConfig>;
  @useResult
  $Res call({String githubToken});
}

/// @nodoc
class _$ServerConfigCopyWithImpl<$Res, $Val extends ServerConfig>
    implements $ServerConfigCopyWith<$Res> {
  _$ServerConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? githubToken = null,
  }) {
    return _then(_value.copyWith(
      githubToken: null == githubToken
          ? _value.githubToken
          : githubToken // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ServerConfigImplCopyWith<$Res>
    implements $ServerConfigCopyWith<$Res> {
  factory _$$ServerConfigImplCopyWith(
          _$ServerConfigImpl value, $Res Function(_$ServerConfigImpl) then) =
      __$$ServerConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String githubToken});
}

/// @nodoc
class __$$ServerConfigImplCopyWithImpl<$Res>
    extends _$ServerConfigCopyWithImpl<$Res, _$ServerConfigImpl>
    implements _$$ServerConfigImplCopyWith<$Res> {
  __$$ServerConfigImplCopyWithImpl(
      _$ServerConfigImpl _value, $Res Function(_$ServerConfigImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? githubToken = null,
  }) {
    return _then(_$ServerConfigImpl(
      githubToken: null == githubToken
          ? _value.githubToken
          : githubToken // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ServerConfigImpl implements _ServerConfig {
  _$ServerConfigImpl({required this.githubToken});

  factory _$ServerConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$ServerConfigImplFromJson(json);

  @override
  final String githubToken;

  @override
  String toString() {
    return 'ServerConfig(githubToken: $githubToken)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ServerConfigImpl &&
            (identical(other.githubToken, githubToken) ||
                other.githubToken == githubToken));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, githubToken);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ServerConfigImplCopyWith<_$ServerConfigImpl> get copyWith =>
      __$$ServerConfigImplCopyWithImpl<_$ServerConfigImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ServerConfigImplToJson(
      this,
    );
  }
}

abstract class _ServerConfig implements ServerConfig {
  factory _ServerConfig({required final String githubToken}) =
      _$ServerConfigImpl;

  factory _ServerConfig.fromJson(Map<String, dynamic> json) =
      _$ServerConfigImpl.fromJson;

  @override
  String get githubToken;
  @override
  @JsonKey(ignore: true)
  _$$ServerConfigImplCopyWith<_$ServerConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
