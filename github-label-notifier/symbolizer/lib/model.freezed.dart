// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies

part of symbolizer.model;

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;
EngineVariant _$EngineVariantFromJson(Map<String, dynamic> json) {
  return _EngineVariant.fromJson(json);
}

/// @nodoc
class _$EngineVariantTearOff {
  const _$EngineVariantTearOff();

// ignore: unused_element
  _EngineVariant call(
      {@required String os,
      @required @nullable String arch,
      @required @nullable String mode}) {
    return _EngineVariant(
      os: os,
      arch: arch,
      mode: mode,
    );
  }

// ignore: unused_element
  EngineVariant fromJson(Map<String, Object> json) {
    return EngineVariant.fromJson(json);
  }
}

/// @nodoc
// ignore: unused_element
const $EngineVariant = _$EngineVariantTearOff();

/// @nodoc
mixin _$EngineVariant {
  String get os;
  @nullable
  String get arch;
  @nullable
  String get mode;

  Map<String, dynamic> toJson();
  $EngineVariantCopyWith<EngineVariant> get copyWith;
}

/// @nodoc
abstract class $EngineVariantCopyWith<$Res> {
  factory $EngineVariantCopyWith(
          EngineVariant value, $Res Function(EngineVariant) then) =
      _$EngineVariantCopyWithImpl<$Res>;
  $Res call({String os, @nullable String arch, @nullable String mode});
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
    Object os = freezed,
    Object arch = freezed,
    Object mode = freezed,
  }) {
    return _then(_value.copyWith(
      os: os == freezed ? _value.os : os as String,
      arch: arch == freezed ? _value.arch : arch as String,
      mode: mode == freezed ? _value.mode : mode as String,
    ));
  }
}

/// @nodoc
abstract class _$EngineVariantCopyWith<$Res>
    implements $EngineVariantCopyWith<$Res> {
  factory _$EngineVariantCopyWith(
          _EngineVariant value, $Res Function(_EngineVariant) then) =
      __$EngineVariantCopyWithImpl<$Res>;
  @override
  $Res call({String os, @nullable String arch, @nullable String mode});
}

/// @nodoc
class __$EngineVariantCopyWithImpl<$Res>
    extends _$EngineVariantCopyWithImpl<$Res>
    implements _$EngineVariantCopyWith<$Res> {
  __$EngineVariantCopyWithImpl(
      _EngineVariant _value, $Res Function(_EngineVariant) _then)
      : super(_value, (v) => _then(v as _EngineVariant));

  @override
  _EngineVariant get _value => super._value as _EngineVariant;

  @override
  $Res call({
    Object os = freezed,
    Object arch = freezed,
    Object mode = freezed,
  }) {
    return _then(_EngineVariant(
      os: os == freezed ? _value.os : os as String,
      arch: arch == freezed ? _value.arch : arch as String,
      mode: mode == freezed ? _value.mode : mode as String,
    ));
  }
}

@JsonSerializable()

/// @nodoc
class _$_EngineVariant implements _EngineVariant {
  _$_EngineVariant(
      {@required this.os,
      @required @nullable this.arch,
      @required @nullable this.mode})
      : assert(os != null);

  factory _$_EngineVariant.fromJson(Map<String, dynamic> json) =>
      _$_$_EngineVariantFromJson(json);

  @override
  final String os;
  @override
  @nullable
  final String arch;
  @override
  @nullable
  final String mode;

  @override
  String toString() {
    return 'EngineVariant(os: $os, arch: $arch, mode: $mode)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _EngineVariant &&
            (identical(other.os, os) ||
                const DeepCollectionEquality().equals(other.os, os)) &&
            (identical(other.arch, arch) ||
                const DeepCollectionEquality().equals(other.arch, arch)) &&
            (identical(other.mode, mode) ||
                const DeepCollectionEquality().equals(other.mode, mode)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(os) ^
      const DeepCollectionEquality().hash(arch) ^
      const DeepCollectionEquality().hash(mode);

  @override
  _$EngineVariantCopyWith<_EngineVariant> get copyWith =>
      __$EngineVariantCopyWithImpl<_EngineVariant>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$_$_EngineVariantToJson(this);
  }
}

abstract class _EngineVariant implements EngineVariant {
  factory _EngineVariant(
      {@required String os,
      @required @nullable String arch,
      @required @nullable String mode}) = _$_EngineVariant;

  factory _EngineVariant.fromJson(Map<String, dynamic> json) =
      _$_EngineVariant.fromJson;

  @override
  String get os;
  @override
  @nullable
  String get arch;
  @override
  @nullable
  String get mode;
  @override
  _$EngineVariantCopyWith<_EngineVariant> get copyWith;
}

EngineBuild _$EngineBuildFromJson(Map<String, dynamic> json) {
  return _EngineBuild.fromJson(json);
}

/// @nodoc
class _$EngineBuildTearOff {
  const _$EngineBuildTearOff();

// ignore: unused_element
  _EngineBuild call(
      {@required String engineHash, @required EngineVariant variant}) {
    return _EngineBuild(
      engineHash: engineHash,
      variant: variant,
    );
  }

// ignore: unused_element
  EngineBuild fromJson(Map<String, Object> json) {
    return EngineBuild.fromJson(json);
  }
}

/// @nodoc
// ignore: unused_element
const $EngineBuild = _$EngineBuildTearOff();

/// @nodoc
mixin _$EngineBuild {
  String get engineHash;
  EngineVariant get variant;

  Map<String, dynamic> toJson();
  $EngineBuildCopyWith<EngineBuild> get copyWith;
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
    Object engineHash = freezed,
    Object variant = freezed,
  }) {
    return _then(_value.copyWith(
      engineHash:
          engineHash == freezed ? _value.engineHash : engineHash as String,
      variant: variant == freezed ? _value.variant : variant as EngineVariant,
    ));
  }

  @override
  $EngineVariantCopyWith<$Res> get variant {
    if (_value.variant == null) {
      return null;
    }
    return $EngineVariantCopyWith<$Res>(_value.variant, (value) {
      return _then(_value.copyWith(variant: value));
    });
  }
}

/// @nodoc
abstract class _$EngineBuildCopyWith<$Res>
    implements $EngineBuildCopyWith<$Res> {
  factory _$EngineBuildCopyWith(
          _EngineBuild value, $Res Function(_EngineBuild) then) =
      __$EngineBuildCopyWithImpl<$Res>;
  @override
  $Res call({String engineHash, EngineVariant variant});

  @override
  $EngineVariantCopyWith<$Res> get variant;
}

/// @nodoc
class __$EngineBuildCopyWithImpl<$Res> extends _$EngineBuildCopyWithImpl<$Res>
    implements _$EngineBuildCopyWith<$Res> {
  __$EngineBuildCopyWithImpl(
      _EngineBuild _value, $Res Function(_EngineBuild) _then)
      : super(_value, (v) => _then(v as _EngineBuild));

  @override
  _EngineBuild get _value => super._value as _EngineBuild;

  @override
  $Res call({
    Object engineHash = freezed,
    Object variant = freezed,
  }) {
    return _then(_EngineBuild(
      engineHash:
          engineHash == freezed ? _value.engineHash : engineHash as String,
      variant: variant == freezed ? _value.variant : variant as EngineVariant,
    ));
  }
}

@JsonSerializable()

/// @nodoc
class _$_EngineBuild implements _EngineBuild {
  _$_EngineBuild({@required this.engineHash, @required this.variant})
      : assert(engineHash != null),
        assert(variant != null);

  factory _$_EngineBuild.fromJson(Map<String, dynamic> json) =>
      _$_$_EngineBuildFromJson(json);

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
        (other is _EngineBuild &&
            (identical(other.engineHash, engineHash) ||
                const DeepCollectionEquality()
                    .equals(other.engineHash, engineHash)) &&
            (identical(other.variant, variant) ||
                const DeepCollectionEquality().equals(other.variant, variant)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(engineHash) ^
      const DeepCollectionEquality().hash(variant);

  @override
  _$EngineBuildCopyWith<_EngineBuild> get copyWith =>
      __$EngineBuildCopyWithImpl<_EngineBuild>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$_$_EngineBuildToJson(this);
  }
}

abstract class _EngineBuild implements EngineBuild {
  factory _EngineBuild(
      {@required String engineHash,
      @required EngineVariant variant}) = _$_EngineBuild;

  factory _EngineBuild.fromJson(Map<String, dynamic> json) =
      _$_EngineBuild.fromJson;

  @override
  String get engineHash;
  @override
  EngineVariant get variant;
  @override
  _$EngineBuildCopyWith<_EngineBuild> get copyWith;
}

CrashFrame _$CrashFrameFromJson(Map<String, dynamic> json) {
  switch (json['runtimeType'] as String) {
    case 'ios':
      return IosCrashFrame.fromJson(json);
    case 'android':
      return AndroidCrashFrame.fromJson(json);
    case 'custom':
      return CustomCrashFrame.fromJson(json);
    case 'dartvm':
      return DartvmCrashFrame.fromJson(json);

    default:
      throw FallThroughError();
  }
}

/// @nodoc
class _$CrashFrameTearOff {
  const _$CrashFrameTearOff();

// ignore: unused_element
  IosCrashFrame ios(
      {@required String no,
      @required String binary,
      @required int pc,
      @required String symbol,
      @required @nullable int offset,
      @required String location}) {
    return IosCrashFrame(
      no: no,
      binary: binary,
      pc: pc,
      symbol: symbol,
      offset: offset,
      location: location,
    );
  }

// ignore: unused_element
  AndroidCrashFrame android(
      {@required String no,
      @required int pc,
      @required String binary,
      @required String rest,
      @required @nullable String buildId}) {
    return AndroidCrashFrame(
      no: no,
      pc: pc,
      binary: binary,
      rest: rest,
      buildId: buildId,
    );
  }

// ignore: unused_element
  CustomCrashFrame custom(
      {@required String no,
      @required int pc,
      @required String binary,
      @required @nullable int offset,
      @required @nullable String location,
      @required @nullable String symbol}) {
    return CustomCrashFrame(
      no: no,
      pc: pc,
      binary: binary,
      offset: offset,
      location: location,
      symbol: symbol,
    );
  }

// ignore: unused_element
  DartvmCrashFrame dartvm(
      {@required int pc, @required String binary, @required int offset}) {
    return DartvmCrashFrame(
      pc: pc,
      binary: binary,
      offset: offset,
    );
  }

// ignore: unused_element
  CrashFrame fromJson(Map<String, Object> json) {
    return CrashFrame.fromJson(json);
  }
}

/// @nodoc
// ignore: unused_element
const $CrashFrame = _$CrashFrameTearOff();

/// @nodoc
mixin _$CrashFrame {
  String get binary;

  /// Absolute PC of the frame.
  int get pc;

  @optionalTypeArgs
  Result when<Result extends Object>({
    @required
        Result ios(String no, String binary, int pc, String symbol,
            @nullable int offset, String location),
    @required
        Result android(String no, int pc, String binary, String rest,
            @nullable String buildId),
    @required
        Result custom(String no, int pc, String binary, @nullable int offset,
            @nullable String location, @nullable String symbol),
    @required Result dartvm(int pc, String binary, int offset),
  });
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result ios(String no, String binary, int pc, String symbol,
        @nullable int offset, String location),
    Result android(String no, int pc, String binary, String rest,
        @nullable String buildId),
    Result custom(String no, int pc, String binary, @nullable int offset,
        @nullable String location, @nullable String symbol),
    Result dartvm(int pc, String binary, int offset),
    @required Result orElse(),
  });
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result ios(IosCrashFrame value),
    @required Result android(AndroidCrashFrame value),
    @required Result custom(CustomCrashFrame value),
    @required Result dartvm(DartvmCrashFrame value),
  });
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result ios(IosCrashFrame value),
    Result android(AndroidCrashFrame value),
    Result custom(CustomCrashFrame value),
    Result dartvm(DartvmCrashFrame value),
    @required Result orElse(),
  });
  Map<String, dynamic> toJson();
  $CrashFrameCopyWith<CrashFrame> get copyWith;
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
    Object binary = freezed,
    Object pc = freezed,
  }) {
    return _then(_value.copyWith(
      binary: binary == freezed ? _value.binary : binary as String,
      pc: pc == freezed ? _value.pc : pc as int,
    ));
  }
}

/// @nodoc
abstract class $IosCrashFrameCopyWith<$Res>
    implements $CrashFrameCopyWith<$Res> {
  factory $IosCrashFrameCopyWith(
          IosCrashFrame value, $Res Function(IosCrashFrame) then) =
      _$IosCrashFrameCopyWithImpl<$Res>;
  @override
  $Res call(
      {String no,
      String binary,
      int pc,
      String symbol,
      @nullable int offset,
      String location});
}

/// @nodoc
class _$IosCrashFrameCopyWithImpl<$Res> extends _$CrashFrameCopyWithImpl<$Res>
    implements $IosCrashFrameCopyWith<$Res> {
  _$IosCrashFrameCopyWithImpl(
      IosCrashFrame _value, $Res Function(IosCrashFrame) _then)
      : super(_value, (v) => _then(v as IosCrashFrame));

  @override
  IosCrashFrame get _value => super._value as IosCrashFrame;

  @override
  $Res call({
    Object no = freezed,
    Object binary = freezed,
    Object pc = freezed,
    Object symbol = freezed,
    Object offset = freezed,
    Object location = freezed,
  }) {
    return _then(IosCrashFrame(
      no: no == freezed ? _value.no : no as String,
      binary: binary == freezed ? _value.binary : binary as String,
      pc: pc == freezed ? _value.pc : pc as int,
      symbol: symbol == freezed ? _value.symbol : symbol as String,
      offset: offset == freezed ? _value.offset : offset as int,
      location: location == freezed ? _value.location : location as String,
    ));
  }
}

@JsonSerializable()

/// @nodoc
class _$IosCrashFrame implements IosCrashFrame {
  _$IosCrashFrame(
      {@required this.no,
      @required this.binary,
      @required this.pc,
      @required this.symbol,
      @required @nullable this.offset,
      @required this.location})
      : assert(no != null),
        assert(binary != null),
        assert(pc != null),
        assert(symbol != null),
        assert(location != null);

  factory _$IosCrashFrame.fromJson(Map<String, dynamic> json) =>
      _$_$IosCrashFrameFromJson(json);

  @override
  final String no;
  @override
  final String binary;
  @override

  /// Absolute PC of the frame.
  final int pc;
  @override
  final String symbol;
  @override
  @nullable
  final int offset;
  @override
  final String location;

  @override
  String toString() {
    return 'CrashFrame.ios(no: $no, binary: $binary, pc: $pc, symbol: $symbol, offset: $offset, location: $location)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is IosCrashFrame &&
            (identical(other.no, no) ||
                const DeepCollectionEquality().equals(other.no, no)) &&
            (identical(other.binary, binary) ||
                const DeepCollectionEquality().equals(other.binary, binary)) &&
            (identical(other.pc, pc) ||
                const DeepCollectionEquality().equals(other.pc, pc)) &&
            (identical(other.symbol, symbol) ||
                const DeepCollectionEquality().equals(other.symbol, symbol)) &&
            (identical(other.offset, offset) ||
                const DeepCollectionEquality().equals(other.offset, offset)) &&
            (identical(other.location, location) ||
                const DeepCollectionEquality()
                    .equals(other.location, location)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(no) ^
      const DeepCollectionEquality().hash(binary) ^
      const DeepCollectionEquality().hash(pc) ^
      const DeepCollectionEquality().hash(symbol) ^
      const DeepCollectionEquality().hash(offset) ^
      const DeepCollectionEquality().hash(location);

  @override
  $IosCrashFrameCopyWith<IosCrashFrame> get copyWith =>
      _$IosCrashFrameCopyWithImpl<IosCrashFrame>(this, _$identity);

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required
        Result ios(String no, String binary, int pc, String symbol,
            @nullable int offset, String location),
    @required
        Result android(String no, int pc, String binary, String rest,
            @nullable String buildId),
    @required
        Result custom(String no, int pc, String binary, @nullable int offset,
            @nullable String location, @nullable String symbol),
    @required Result dartvm(int pc, String binary, int offset),
  }) {
    assert(ios != null);
    assert(android != null);
    assert(custom != null);
    assert(dartvm != null);
    return ios(no, binary, pc, symbol, offset, location);
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result ios(String no, String binary, int pc, String symbol,
        @nullable int offset, String location),
    Result android(String no, int pc, String binary, String rest,
        @nullable String buildId),
    Result custom(String no, int pc, String binary, @nullable int offset,
        @nullable String location, @nullable String symbol),
    Result dartvm(int pc, String binary, int offset),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (ios != null) {
      return ios(no, binary, pc, symbol, offset, location);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result ios(IosCrashFrame value),
    @required Result android(AndroidCrashFrame value),
    @required Result custom(CustomCrashFrame value),
    @required Result dartvm(DartvmCrashFrame value),
  }) {
    assert(ios != null);
    assert(android != null);
    assert(custom != null);
    assert(dartvm != null);
    return ios(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result ios(IosCrashFrame value),
    Result android(AndroidCrashFrame value),
    Result custom(CustomCrashFrame value),
    Result dartvm(DartvmCrashFrame value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (ios != null) {
      return ios(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$_$IosCrashFrameToJson(this)..['runtimeType'] = 'ios';
  }
}

abstract class IosCrashFrame implements CrashFrame {
  factory IosCrashFrame(
      {@required String no,
      @required String binary,
      @required int pc,
      @required String symbol,
      @required @nullable int offset,
      @required String location}) = _$IosCrashFrame;

  factory IosCrashFrame.fromJson(Map<String, dynamic> json) =
      _$IosCrashFrame.fromJson;

  String get no;
  @override
  String get binary;
  @override

  /// Absolute PC of the frame.
  int get pc;
  String get symbol;
  @nullable
  int get offset;
  String get location;
  @override
  $IosCrashFrameCopyWith<IosCrashFrame> get copyWith;
}

/// @nodoc
abstract class $AndroidCrashFrameCopyWith<$Res>
    implements $CrashFrameCopyWith<$Res> {
  factory $AndroidCrashFrameCopyWith(
          AndroidCrashFrame value, $Res Function(AndroidCrashFrame) then) =
      _$AndroidCrashFrameCopyWithImpl<$Res>;
  @override
  $Res call(
      {String no,
      int pc,
      String binary,
      String rest,
      @nullable String buildId});
}

/// @nodoc
class _$AndroidCrashFrameCopyWithImpl<$Res>
    extends _$CrashFrameCopyWithImpl<$Res>
    implements $AndroidCrashFrameCopyWith<$Res> {
  _$AndroidCrashFrameCopyWithImpl(
      AndroidCrashFrame _value, $Res Function(AndroidCrashFrame) _then)
      : super(_value, (v) => _then(v as AndroidCrashFrame));

  @override
  AndroidCrashFrame get _value => super._value as AndroidCrashFrame;

  @override
  $Res call({
    Object no = freezed,
    Object pc = freezed,
    Object binary = freezed,
    Object rest = freezed,
    Object buildId = freezed,
  }) {
    return _then(AndroidCrashFrame(
      no: no == freezed ? _value.no : no as String,
      pc: pc == freezed ? _value.pc : pc as int,
      binary: binary == freezed ? _value.binary : binary as String,
      rest: rest == freezed ? _value.rest : rest as String,
      buildId: buildId == freezed ? _value.buildId : buildId as String,
    ));
  }
}

@JsonSerializable()

/// @nodoc
class _$AndroidCrashFrame implements AndroidCrashFrame {
  _$AndroidCrashFrame(
      {@required this.no,
      @required this.pc,
      @required this.binary,
      @required this.rest,
      @required @nullable this.buildId})
      : assert(no != null),
        assert(pc != null),
        assert(binary != null),
        assert(rest != null);

  factory _$AndroidCrashFrame.fromJson(Map<String, dynamic> json) =>
      _$_$AndroidCrashFrameFromJson(json);

  @override
  final String no;
  @override

  /// Relative PC of the frame.
  final int pc;
  @override
  final String binary;
  @override
  final String rest;
  @override
  @nullable
  final String buildId;

  @override
  String toString() {
    return 'CrashFrame.android(no: $no, pc: $pc, binary: $binary, rest: $rest, buildId: $buildId)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is AndroidCrashFrame &&
            (identical(other.no, no) ||
                const DeepCollectionEquality().equals(other.no, no)) &&
            (identical(other.pc, pc) ||
                const DeepCollectionEquality().equals(other.pc, pc)) &&
            (identical(other.binary, binary) ||
                const DeepCollectionEquality().equals(other.binary, binary)) &&
            (identical(other.rest, rest) ||
                const DeepCollectionEquality().equals(other.rest, rest)) &&
            (identical(other.buildId, buildId) ||
                const DeepCollectionEquality().equals(other.buildId, buildId)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(no) ^
      const DeepCollectionEquality().hash(pc) ^
      const DeepCollectionEquality().hash(binary) ^
      const DeepCollectionEquality().hash(rest) ^
      const DeepCollectionEquality().hash(buildId);

  @override
  $AndroidCrashFrameCopyWith<AndroidCrashFrame> get copyWith =>
      _$AndroidCrashFrameCopyWithImpl<AndroidCrashFrame>(this, _$identity);

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required
        Result ios(String no, String binary, int pc, String symbol,
            @nullable int offset, String location),
    @required
        Result android(String no, int pc, String binary, String rest,
            @nullable String buildId),
    @required
        Result custom(String no, int pc, String binary, @nullable int offset,
            @nullable String location, @nullable String symbol),
    @required Result dartvm(int pc, String binary, int offset),
  }) {
    assert(ios != null);
    assert(android != null);
    assert(custom != null);
    assert(dartvm != null);
    return android(no, pc, binary, rest, buildId);
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result ios(String no, String binary, int pc, String symbol,
        @nullable int offset, String location),
    Result android(String no, int pc, String binary, String rest,
        @nullable String buildId),
    Result custom(String no, int pc, String binary, @nullable int offset,
        @nullable String location, @nullable String symbol),
    Result dartvm(int pc, String binary, int offset),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (android != null) {
      return android(no, pc, binary, rest, buildId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result ios(IosCrashFrame value),
    @required Result android(AndroidCrashFrame value),
    @required Result custom(CustomCrashFrame value),
    @required Result dartvm(DartvmCrashFrame value),
  }) {
    assert(ios != null);
    assert(android != null);
    assert(custom != null);
    assert(dartvm != null);
    return android(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result ios(IosCrashFrame value),
    Result android(AndroidCrashFrame value),
    Result custom(CustomCrashFrame value),
    Result dartvm(DartvmCrashFrame value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (android != null) {
      return android(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$_$AndroidCrashFrameToJson(this)..['runtimeType'] = 'android';
  }
}

abstract class AndroidCrashFrame implements CrashFrame {
  factory AndroidCrashFrame(
      {@required String no,
      @required int pc,
      @required String binary,
      @required String rest,
      @required @nullable String buildId}) = _$AndroidCrashFrame;

  factory AndroidCrashFrame.fromJson(Map<String, dynamic> json) =
      _$AndroidCrashFrame.fromJson;

  String get no;
  @override

  /// Relative PC of the frame.
  int get pc;
  @override
  String get binary;
  String get rest;
  @nullable
  String get buildId;
  @override
  $AndroidCrashFrameCopyWith<AndroidCrashFrame> get copyWith;
}

/// @nodoc
abstract class $CustomCrashFrameCopyWith<$Res>
    implements $CrashFrameCopyWith<$Res> {
  factory $CustomCrashFrameCopyWith(
          CustomCrashFrame value, $Res Function(CustomCrashFrame) then) =
      _$CustomCrashFrameCopyWithImpl<$Res>;
  @override
  $Res call(
      {String no,
      int pc,
      String binary,
      @nullable int offset,
      @nullable String location,
      @nullable String symbol});
}

/// @nodoc
class _$CustomCrashFrameCopyWithImpl<$Res>
    extends _$CrashFrameCopyWithImpl<$Res>
    implements $CustomCrashFrameCopyWith<$Res> {
  _$CustomCrashFrameCopyWithImpl(
      CustomCrashFrame _value, $Res Function(CustomCrashFrame) _then)
      : super(_value, (v) => _then(v as CustomCrashFrame));

  @override
  CustomCrashFrame get _value => super._value as CustomCrashFrame;

  @override
  $Res call({
    Object no = freezed,
    Object pc = freezed,
    Object binary = freezed,
    Object offset = freezed,
    Object location = freezed,
    Object symbol = freezed,
  }) {
    return _then(CustomCrashFrame(
      no: no == freezed ? _value.no : no as String,
      pc: pc == freezed ? _value.pc : pc as int,
      binary: binary == freezed ? _value.binary : binary as String,
      offset: offset == freezed ? _value.offset : offset as int,
      location: location == freezed ? _value.location : location as String,
      symbol: symbol == freezed ? _value.symbol : symbol as String,
    ));
  }
}

@JsonSerializable()

/// @nodoc
class _$CustomCrashFrame implements CustomCrashFrame {
  _$CustomCrashFrame(
      {@required this.no,
      @required this.pc,
      @required this.binary,
      @required @nullable this.offset,
      @required @nullable this.location,
      @required @nullable this.symbol})
      : assert(no != null),
        assert(pc != null),
        assert(binary != null);

  factory _$CustomCrashFrame.fromJson(Map<String, dynamic> json) =>
      _$_$CustomCrashFrameFromJson(json);

  @override
  final String no;
  @override
  final int pc;
  @override
  final String binary;
  @override
  @nullable
  final int offset;
  @override
  @nullable
  final String location;
  @override
  @nullable
  final String symbol;

  @override
  String toString() {
    return 'CrashFrame.custom(no: $no, pc: $pc, binary: $binary, offset: $offset, location: $location, symbol: $symbol)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is CustomCrashFrame &&
            (identical(other.no, no) ||
                const DeepCollectionEquality().equals(other.no, no)) &&
            (identical(other.pc, pc) ||
                const DeepCollectionEquality().equals(other.pc, pc)) &&
            (identical(other.binary, binary) ||
                const DeepCollectionEquality().equals(other.binary, binary)) &&
            (identical(other.offset, offset) ||
                const DeepCollectionEquality().equals(other.offset, offset)) &&
            (identical(other.location, location) ||
                const DeepCollectionEquality()
                    .equals(other.location, location)) &&
            (identical(other.symbol, symbol) ||
                const DeepCollectionEquality().equals(other.symbol, symbol)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(no) ^
      const DeepCollectionEquality().hash(pc) ^
      const DeepCollectionEquality().hash(binary) ^
      const DeepCollectionEquality().hash(offset) ^
      const DeepCollectionEquality().hash(location) ^
      const DeepCollectionEquality().hash(symbol);

  @override
  $CustomCrashFrameCopyWith<CustomCrashFrame> get copyWith =>
      _$CustomCrashFrameCopyWithImpl<CustomCrashFrame>(this, _$identity);

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required
        Result ios(String no, String binary, int pc, String symbol,
            @nullable int offset, String location),
    @required
        Result android(String no, int pc, String binary, String rest,
            @nullable String buildId),
    @required
        Result custom(String no, int pc, String binary, @nullable int offset,
            @nullable String location, @nullable String symbol),
    @required Result dartvm(int pc, String binary, int offset),
  }) {
    assert(ios != null);
    assert(android != null);
    assert(custom != null);
    assert(dartvm != null);
    return custom(no, pc, binary, offset, location, symbol);
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result ios(String no, String binary, int pc, String symbol,
        @nullable int offset, String location),
    Result android(String no, int pc, String binary, String rest,
        @nullable String buildId),
    Result custom(String no, int pc, String binary, @nullable int offset,
        @nullable String location, @nullable String symbol),
    Result dartvm(int pc, String binary, int offset),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (custom != null) {
      return custom(no, pc, binary, offset, location, symbol);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result ios(IosCrashFrame value),
    @required Result android(AndroidCrashFrame value),
    @required Result custom(CustomCrashFrame value),
    @required Result dartvm(DartvmCrashFrame value),
  }) {
    assert(ios != null);
    assert(android != null);
    assert(custom != null);
    assert(dartvm != null);
    return custom(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result ios(IosCrashFrame value),
    Result android(AndroidCrashFrame value),
    Result custom(CustomCrashFrame value),
    Result dartvm(DartvmCrashFrame value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (custom != null) {
      return custom(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$_$CustomCrashFrameToJson(this)..['runtimeType'] = 'custom';
  }
}

abstract class CustomCrashFrame implements CrashFrame {
  factory CustomCrashFrame(
      {@required String no,
      @required int pc,
      @required String binary,
      @required @nullable int offset,
      @required @nullable String location,
      @required @nullable String symbol}) = _$CustomCrashFrame;

  factory CustomCrashFrame.fromJson(Map<String, dynamic> json) =
      _$CustomCrashFrame.fromJson;

  String get no;
  @override
  int get pc;
  @override
  String get binary;
  @nullable
  int get offset;
  @nullable
  String get location;
  @nullable
  String get symbol;
  @override
  $CustomCrashFrameCopyWith<CustomCrashFrame> get copyWith;
}

/// @nodoc
abstract class $DartvmCrashFrameCopyWith<$Res>
    implements $CrashFrameCopyWith<$Res> {
  factory $DartvmCrashFrameCopyWith(
          DartvmCrashFrame value, $Res Function(DartvmCrashFrame) then) =
      _$DartvmCrashFrameCopyWithImpl<$Res>;
  @override
  $Res call({int pc, String binary, int offset});
}

/// @nodoc
class _$DartvmCrashFrameCopyWithImpl<$Res>
    extends _$CrashFrameCopyWithImpl<$Res>
    implements $DartvmCrashFrameCopyWith<$Res> {
  _$DartvmCrashFrameCopyWithImpl(
      DartvmCrashFrame _value, $Res Function(DartvmCrashFrame) _then)
      : super(_value, (v) => _then(v as DartvmCrashFrame));

  @override
  DartvmCrashFrame get _value => super._value as DartvmCrashFrame;

  @override
  $Res call({
    Object pc = freezed,
    Object binary = freezed,
    Object offset = freezed,
  }) {
    return _then(DartvmCrashFrame(
      pc: pc == freezed ? _value.pc : pc as int,
      binary: binary == freezed ? _value.binary : binary as String,
      offset: offset == freezed ? _value.offset : offset as int,
    ));
  }
}

@JsonSerializable()

/// @nodoc
class _$DartvmCrashFrame implements DartvmCrashFrame {
  _$DartvmCrashFrame(
      {@required this.pc, @required this.binary, @required this.offset})
      : assert(pc != null),
        assert(binary != null),
        assert(offset != null);

  factory _$DartvmCrashFrame.fromJson(Map<String, dynamic> json) =>
      _$_$DartvmCrashFrameFromJson(json);

  @override

  /// Absolute PC of the frame.
  final int pc;
  @override

  /// Binary which contains the given PC.
  final String binary;
  @override

  /// Offset from load base of the binary to the PC.
  final int offset;

  @override
  String toString() {
    return 'CrashFrame.dartvm(pc: $pc, binary: $binary, offset: $offset)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is DartvmCrashFrame &&
            (identical(other.pc, pc) ||
                const DeepCollectionEquality().equals(other.pc, pc)) &&
            (identical(other.binary, binary) ||
                const DeepCollectionEquality().equals(other.binary, binary)) &&
            (identical(other.offset, offset) ||
                const DeepCollectionEquality().equals(other.offset, offset)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(pc) ^
      const DeepCollectionEquality().hash(binary) ^
      const DeepCollectionEquality().hash(offset);

  @override
  $DartvmCrashFrameCopyWith<DartvmCrashFrame> get copyWith =>
      _$DartvmCrashFrameCopyWithImpl<DartvmCrashFrame>(this, _$identity);

  @override
  @optionalTypeArgs
  Result when<Result extends Object>({
    @required
        Result ios(String no, String binary, int pc, String symbol,
            @nullable int offset, String location),
    @required
        Result android(String no, int pc, String binary, String rest,
            @nullable String buildId),
    @required
        Result custom(String no, int pc, String binary, @nullable int offset,
            @nullable String location, @nullable String symbol),
    @required Result dartvm(int pc, String binary, int offset),
  }) {
    assert(ios != null);
    assert(android != null);
    assert(custom != null);
    assert(dartvm != null);
    return dartvm(pc, binary, offset);
  }

  @override
  @optionalTypeArgs
  Result maybeWhen<Result extends Object>({
    Result ios(String no, String binary, int pc, String symbol,
        @nullable int offset, String location),
    Result android(String no, int pc, String binary, String rest,
        @nullable String buildId),
    Result custom(String no, int pc, String binary, @nullable int offset,
        @nullable String location, @nullable String symbol),
    Result dartvm(int pc, String binary, int offset),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (dartvm != null) {
      return dartvm(pc, binary, offset);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  Result map<Result extends Object>({
    @required Result ios(IosCrashFrame value),
    @required Result android(AndroidCrashFrame value),
    @required Result custom(CustomCrashFrame value),
    @required Result dartvm(DartvmCrashFrame value),
  }) {
    assert(ios != null);
    assert(android != null);
    assert(custom != null);
    assert(dartvm != null);
    return dartvm(this);
  }

  @override
  @optionalTypeArgs
  Result maybeMap<Result extends Object>({
    Result ios(IosCrashFrame value),
    Result android(AndroidCrashFrame value),
    Result custom(CustomCrashFrame value),
    Result dartvm(DartvmCrashFrame value),
    @required Result orElse(),
  }) {
    assert(orElse != null);
    if (dartvm != null) {
      return dartvm(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$_$DartvmCrashFrameToJson(this)..['runtimeType'] = 'dartvm';
  }
}

abstract class DartvmCrashFrame implements CrashFrame {
  factory DartvmCrashFrame(
      {@required int pc,
      @required String binary,
      @required int offset}) = _$DartvmCrashFrame;

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
  $DartvmCrashFrameCopyWith<DartvmCrashFrame> get copyWith;
}

Crash _$CrashFromJson(Map<String, dynamic> json) {
  return _Crash.fromJson(json);
}

/// @nodoc
class _$CrashTearOff {
  const _$CrashTearOff();

// ignore: unused_element
  _Crash call(
      {EngineVariant engineVariant,
      List<CrashFrame> frames,
      @required String format,
      @nullable int androidMajorVersion}) {
    return _Crash(
      engineVariant: engineVariant,
      frames: frames,
      format: format,
      androidMajorVersion: androidMajorVersion,
    );
  }

// ignore: unused_element
  Crash fromJson(Map<String, Object> json) {
    return Crash.fromJson(json);
  }
}

/// @nodoc
// ignore: unused_element
const $Crash = _$CrashTearOff();

/// @nodoc
mixin _$Crash {
  EngineVariant get engineVariant;
  List<CrashFrame> get frames;
  String get format;
  @nullable
  int get androidMajorVersion;

  Map<String, dynamic> toJson();
  $CrashCopyWith<Crash> get copyWith;
}

/// @nodoc
abstract class $CrashCopyWith<$Res> {
  factory $CrashCopyWith(Crash value, $Res Function(Crash) then) =
      _$CrashCopyWithImpl<$Res>;
  $Res call(
      {EngineVariant engineVariant,
      List<CrashFrame> frames,
      String format,
      @nullable int androidMajorVersion});

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
    Object engineVariant = freezed,
    Object frames = freezed,
    Object format = freezed,
    Object androidMajorVersion = freezed,
  }) {
    return _then(_value.copyWith(
      engineVariant: engineVariant == freezed
          ? _value.engineVariant
          : engineVariant as EngineVariant,
      frames: frames == freezed ? _value.frames : frames as List<CrashFrame>,
      format: format == freezed ? _value.format : format as String,
      androidMajorVersion: androidMajorVersion == freezed
          ? _value.androidMajorVersion
          : androidMajorVersion as int,
    ));
  }

  @override
  $EngineVariantCopyWith<$Res> get engineVariant {
    if (_value.engineVariant == null) {
      return null;
    }
    return $EngineVariantCopyWith<$Res>(_value.engineVariant, (value) {
      return _then(_value.copyWith(engineVariant: value));
    });
  }
}

/// @nodoc
abstract class _$CrashCopyWith<$Res> implements $CrashCopyWith<$Res> {
  factory _$CrashCopyWith(_Crash value, $Res Function(_Crash) then) =
      __$CrashCopyWithImpl<$Res>;
  @override
  $Res call(
      {EngineVariant engineVariant,
      List<CrashFrame> frames,
      String format,
      @nullable int androidMajorVersion});

  @override
  $EngineVariantCopyWith<$Res> get engineVariant;
}

/// @nodoc
class __$CrashCopyWithImpl<$Res> extends _$CrashCopyWithImpl<$Res>
    implements _$CrashCopyWith<$Res> {
  __$CrashCopyWithImpl(_Crash _value, $Res Function(_Crash) _then)
      : super(_value, (v) => _then(v as _Crash));

  @override
  _Crash get _value => super._value as _Crash;

  @override
  $Res call({
    Object engineVariant = freezed,
    Object frames = freezed,
    Object format = freezed,
    Object androidMajorVersion = freezed,
  }) {
    return _then(_Crash(
      engineVariant: engineVariant == freezed
          ? _value.engineVariant
          : engineVariant as EngineVariant,
      frames: frames == freezed ? _value.frames : frames as List<CrashFrame>,
      format: format == freezed ? _value.format : format as String,
      androidMajorVersion: androidMajorVersion == freezed
          ? _value.androidMajorVersion
          : androidMajorVersion as int,
    ));
  }
}

@JsonSerializable()

/// @nodoc
class _$_Crash implements _Crash {
  _$_Crash(
      {this.engineVariant,
      this.frames,
      @required this.format,
      @nullable this.androidMajorVersion})
      : assert(format != null);

  factory _$_Crash.fromJson(Map<String, dynamic> json) =>
      _$_$_CrashFromJson(json);

  @override
  final EngineVariant engineVariant;
  @override
  final List<CrashFrame> frames;
  @override
  final String format;
  @override
  @nullable
  final int androidMajorVersion;

  @override
  String toString() {
    return 'Crash(engineVariant: $engineVariant, frames: $frames, format: $format, androidMajorVersion: $androidMajorVersion)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _Crash &&
            (identical(other.engineVariant, engineVariant) ||
                const DeepCollectionEquality()
                    .equals(other.engineVariant, engineVariant)) &&
            (identical(other.frames, frames) ||
                const DeepCollectionEquality().equals(other.frames, frames)) &&
            (identical(other.format, format) ||
                const DeepCollectionEquality().equals(other.format, format)) &&
            (identical(other.androidMajorVersion, androidMajorVersion) ||
                const DeepCollectionEquality()
                    .equals(other.androidMajorVersion, androidMajorVersion)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(engineVariant) ^
      const DeepCollectionEquality().hash(frames) ^
      const DeepCollectionEquality().hash(format) ^
      const DeepCollectionEquality().hash(androidMajorVersion);

  @override
  _$CrashCopyWith<_Crash> get copyWith =>
      __$CrashCopyWithImpl<_Crash>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$_$_CrashToJson(this);
  }
}

abstract class _Crash implements Crash {
  factory _Crash(
      {EngineVariant engineVariant,
      List<CrashFrame> frames,
      @required String format,
      @nullable int androidMajorVersion}) = _$_Crash;

  factory _Crash.fromJson(Map<String, dynamic> json) = _$_Crash.fromJson;

  @override
  EngineVariant get engineVariant;
  @override
  List<CrashFrame> get frames;
  @override
  String get format;
  @override
  @nullable
  int get androidMajorVersion;
  @override
  _$CrashCopyWith<_Crash> get copyWith;
}

SymbolizationResult _$SymbolizationResultFromJson(Map<String, dynamic> json) {
  return _SymbolizationResult.fromJson(json);
}

/// @nodoc
class _$SymbolizationResultTearOff {
  const _$SymbolizationResultTearOff();

// ignore: unused_element
  _SymbolizationResult call(
      {@required Crash crash,
      @required @nullable EngineBuild engineBuild,
      @required @nullable String symbolized,
      List<SymbolizationNote> notes = const []}) {
    return _SymbolizationResult(
      crash: crash,
      engineBuild: engineBuild,
      symbolized: symbolized,
      notes: notes,
    );
  }

// ignore: unused_element
  SymbolizationResult fromJson(Map<String, Object> json) {
    return SymbolizationResult.fromJson(json);
  }
}

/// @nodoc
// ignore: unused_element
const $SymbolizationResult = _$SymbolizationResultTearOff();

/// @nodoc
mixin _$SymbolizationResult {
  Crash get crash;
  @nullable
  EngineBuild get engineBuild;

  /// Symbolization result - not null if symbolization succeeded.
  @nullable
  String get symbolized;
  List<SymbolizationNote> get notes;

  Map<String, dynamic> toJson();
  $SymbolizationResultCopyWith<SymbolizationResult> get copyWith;
}

/// @nodoc
abstract class $SymbolizationResultCopyWith<$Res> {
  factory $SymbolizationResultCopyWith(
          SymbolizationResult value, $Res Function(SymbolizationResult) then) =
      _$SymbolizationResultCopyWithImpl<$Res>;
  $Res call(
      {Crash crash,
      @nullable EngineBuild engineBuild,
      @nullable String symbolized,
      List<SymbolizationNote> notes});

  $CrashCopyWith<$Res> get crash;
  $EngineBuildCopyWith<$Res> get engineBuild;
}

/// @nodoc
class _$SymbolizationResultCopyWithImpl<$Res>
    implements $SymbolizationResultCopyWith<$Res> {
  _$SymbolizationResultCopyWithImpl(this._value, this._then);

  final SymbolizationResult _value;
  // ignore: unused_field
  final $Res Function(SymbolizationResult) _then;

  @override
  $Res call({
    Object crash = freezed,
    Object engineBuild = freezed,
    Object symbolized = freezed,
    Object notes = freezed,
  }) {
    return _then(_value.copyWith(
      crash: crash == freezed ? _value.crash : crash as Crash,
      engineBuild: engineBuild == freezed
          ? _value.engineBuild
          : engineBuild as EngineBuild,
      symbolized:
          symbolized == freezed ? _value.symbolized : symbolized as String,
      notes: notes == freezed ? _value.notes : notes as List<SymbolizationNote>,
    ));
  }

  @override
  $CrashCopyWith<$Res> get crash {
    if (_value.crash == null) {
      return null;
    }
    return $CrashCopyWith<$Res>(_value.crash, (value) {
      return _then(_value.copyWith(crash: value));
    });
  }

  @override
  $EngineBuildCopyWith<$Res> get engineBuild {
    if (_value.engineBuild == null) {
      return null;
    }
    return $EngineBuildCopyWith<$Res>(_value.engineBuild, (value) {
      return _then(_value.copyWith(engineBuild: value));
    });
  }
}

/// @nodoc
abstract class _$SymbolizationResultCopyWith<$Res>
    implements $SymbolizationResultCopyWith<$Res> {
  factory _$SymbolizationResultCopyWith(_SymbolizationResult value,
          $Res Function(_SymbolizationResult) then) =
      __$SymbolizationResultCopyWithImpl<$Res>;
  @override
  $Res call(
      {Crash crash,
      @nullable EngineBuild engineBuild,
      @nullable String symbolized,
      List<SymbolizationNote> notes});

  @override
  $CrashCopyWith<$Res> get crash;
  @override
  $EngineBuildCopyWith<$Res> get engineBuild;
}

/// @nodoc
class __$SymbolizationResultCopyWithImpl<$Res>
    extends _$SymbolizationResultCopyWithImpl<$Res>
    implements _$SymbolizationResultCopyWith<$Res> {
  __$SymbolizationResultCopyWithImpl(
      _SymbolizationResult _value, $Res Function(_SymbolizationResult) _then)
      : super(_value, (v) => _then(v as _SymbolizationResult));

  @override
  _SymbolizationResult get _value => super._value as _SymbolizationResult;

  @override
  $Res call({
    Object crash = freezed,
    Object engineBuild = freezed,
    Object symbolized = freezed,
    Object notes = freezed,
  }) {
    return _then(_SymbolizationResult(
      crash: crash == freezed ? _value.crash : crash as Crash,
      engineBuild: engineBuild == freezed
          ? _value.engineBuild
          : engineBuild as EngineBuild,
      symbolized:
          symbolized == freezed ? _value.symbolized : symbolized as String,
      notes: notes == freezed ? _value.notes : notes as List<SymbolizationNote>,
    ));
  }
}

@JsonSerializable(explicitToJson: true)

/// @nodoc
class _$_SymbolizationResult implements _SymbolizationResult {
  _$_SymbolizationResult(
      {@required this.crash,
      @required @nullable this.engineBuild,
      @required @nullable this.symbolized,
      this.notes = const []})
      : assert(crash != null),
        assert(notes != null);

  factory _$_SymbolizationResult.fromJson(Map<String, dynamic> json) =>
      _$_$_SymbolizationResultFromJson(json);

  @override
  final Crash crash;
  @override
  @nullable
  final EngineBuild engineBuild;
  @override

  /// Symbolization result - not null if symbolization succeeded.
  @nullable
  final String symbolized;
  @JsonKey(defaultValue: const [])
  @override
  final List<SymbolizationNote> notes;

  @override
  String toString() {
    return 'SymbolizationResult(crash: $crash, engineBuild: $engineBuild, symbolized: $symbolized, notes: $notes)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _SymbolizationResult &&
            (identical(other.crash, crash) ||
                const DeepCollectionEquality().equals(other.crash, crash)) &&
            (identical(other.engineBuild, engineBuild) ||
                const DeepCollectionEquality()
                    .equals(other.engineBuild, engineBuild)) &&
            (identical(other.symbolized, symbolized) ||
                const DeepCollectionEquality()
                    .equals(other.symbolized, symbolized)) &&
            (identical(other.notes, notes) ||
                const DeepCollectionEquality().equals(other.notes, notes)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(crash) ^
      const DeepCollectionEquality().hash(engineBuild) ^
      const DeepCollectionEquality().hash(symbolized) ^
      const DeepCollectionEquality().hash(notes);

  @override
  _$SymbolizationResultCopyWith<_SymbolizationResult> get copyWith =>
      __$SymbolizationResultCopyWithImpl<_SymbolizationResult>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$_$_SymbolizationResultToJson(this);
  }
}

abstract class _SymbolizationResult implements SymbolizationResult {
  factory _SymbolizationResult(
      {@required Crash crash,
      @required @nullable EngineBuild engineBuild,
      @required @nullable String symbolized,
      List<SymbolizationNote> notes}) = _$_SymbolizationResult;

  factory _SymbolizationResult.fromJson(Map<String, dynamic> json) =
      _$_SymbolizationResult.fromJson;

  @override
  Crash get crash;
  @override
  @nullable
  EngineBuild get engineBuild;
  @override

  /// Symbolization result - not null if symbolization succeeded.
  @nullable
  String get symbolized;
  @override
  List<SymbolizationNote> get notes;
  @override
  _$SymbolizationResultCopyWith<_SymbolizationResult> get copyWith;
}

SymbolizationNote _$SymbolizationNoteFromJson(Map<String, dynamic> json) {
  return _SymbolizationNote.fromJson(json);
}

/// @nodoc
class _$SymbolizationNoteTearOff {
  const _$SymbolizationNoteTearOff();

// ignore: unused_element
  _SymbolizationNote call(
      {@required SymbolizationNoteKind kind, @nullable String message}) {
    return _SymbolizationNote(
      kind: kind,
      message: message,
    );
  }

// ignore: unused_element
  SymbolizationNote fromJson(Map<String, Object> json) {
    return SymbolizationNote.fromJson(json);
  }
}

/// @nodoc
// ignore: unused_element
const $SymbolizationNote = _$SymbolizationNoteTearOff();

/// @nodoc
mixin _$SymbolizationNote {
  SymbolizationNoteKind get kind;
  @nullable
  String get message;

  Map<String, dynamic> toJson();
  $SymbolizationNoteCopyWith<SymbolizationNote> get copyWith;
}

/// @nodoc
abstract class $SymbolizationNoteCopyWith<$Res> {
  factory $SymbolizationNoteCopyWith(
          SymbolizationNote value, $Res Function(SymbolizationNote) then) =
      _$SymbolizationNoteCopyWithImpl<$Res>;
  $Res call({SymbolizationNoteKind kind, @nullable String message});
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
    Object kind = freezed,
    Object message = freezed,
  }) {
    return _then(_value.copyWith(
      kind: kind == freezed ? _value.kind : kind as SymbolizationNoteKind,
      message: message == freezed ? _value.message : message as String,
    ));
  }
}

/// @nodoc
abstract class _$SymbolizationNoteCopyWith<$Res>
    implements $SymbolizationNoteCopyWith<$Res> {
  factory _$SymbolizationNoteCopyWith(
          _SymbolizationNote value, $Res Function(_SymbolizationNote) then) =
      __$SymbolizationNoteCopyWithImpl<$Res>;
  @override
  $Res call({SymbolizationNoteKind kind, @nullable String message});
}

/// @nodoc
class __$SymbolizationNoteCopyWithImpl<$Res>
    extends _$SymbolizationNoteCopyWithImpl<$Res>
    implements _$SymbolizationNoteCopyWith<$Res> {
  __$SymbolizationNoteCopyWithImpl(
      _SymbolizationNote _value, $Res Function(_SymbolizationNote) _then)
      : super(_value, (v) => _then(v as _SymbolizationNote));

  @override
  _SymbolizationNote get _value => super._value as _SymbolizationNote;

  @override
  $Res call({
    Object kind = freezed,
    Object message = freezed,
  }) {
    return _then(_SymbolizationNote(
      kind: kind == freezed ? _value.kind : kind as SymbolizationNoteKind,
      message: message == freezed ? _value.message : message as String,
    ));
  }
}

@JsonSerializable()

/// @nodoc
class _$_SymbolizationNote implements _SymbolizationNote {
  _$_SymbolizationNote({@required this.kind, @nullable this.message})
      : assert(kind != null);

  factory _$_SymbolizationNote.fromJson(Map<String, dynamic> json) =>
      _$_$_SymbolizationNoteFromJson(json);

  @override
  final SymbolizationNoteKind kind;
  @override
  @nullable
  final String message;

  @override
  String toString() {
    return 'SymbolizationNote(kind: $kind, message: $message)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _SymbolizationNote &&
            (identical(other.kind, kind) ||
                const DeepCollectionEquality().equals(other.kind, kind)) &&
            (identical(other.message, message) ||
                const DeepCollectionEquality().equals(other.message, message)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(kind) ^
      const DeepCollectionEquality().hash(message);

  @override
  _$SymbolizationNoteCopyWith<_SymbolizationNote> get copyWith =>
      __$SymbolizationNoteCopyWithImpl<_SymbolizationNote>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$_$_SymbolizationNoteToJson(this);
  }
}

abstract class _SymbolizationNote implements SymbolizationNote {
  factory _SymbolizationNote(
      {@required SymbolizationNoteKind kind,
      @nullable String message}) = _$_SymbolizationNote;

  factory _SymbolizationNote.fromJson(Map<String, dynamic> json) =
      _$_SymbolizationNote.fromJson;

  @override
  SymbolizationNoteKind get kind;
  @override
  @nullable
  String get message;
  @override
  _$SymbolizationNoteCopyWith<_SymbolizationNote> get copyWith;
}

/// @nodoc
class _$BotCommandTearOff {
  const _$BotCommandTearOff();

// ignore: unused_element
  _BotCommand call(
      {@required SymbolizationOverrides overrides,
      @required bool symbolizeThis,
      @required Set<String> worklist}) {
    return _BotCommand(
      overrides: overrides,
      symbolizeThis: symbolizeThis,
      worklist: worklist,
    );
  }
}

/// @nodoc
// ignore: unused_element
const $BotCommand = _$BotCommandTearOff();

/// @nodoc
mixin _$BotCommand {
  /// Overrides that should be used for symbolization. These overrides
  /// replace or augment information available in the comments themselves.
  SymbolizationOverrides get overrides;

  /// [true] if the user requested to symbolize the comment that contains
  /// command.
  bool get symbolizeThis;

  /// List of references to comments which need to be symbolized. Each reference
  /// is either in `issue-id` or in `issuecomment-id` format.
  Set<String> get worklist;

  $BotCommandCopyWith<BotCommand> get copyWith;
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
    Object overrides = freezed,
    Object symbolizeThis = freezed,
    Object worklist = freezed,
  }) {
    return _then(_value.copyWith(
      overrides: overrides == freezed
          ? _value.overrides
          : overrides as SymbolizationOverrides,
      symbolizeThis: symbolizeThis == freezed
          ? _value.symbolizeThis
          : symbolizeThis as bool,
      worklist: worklist == freezed ? _value.worklist : worklist as Set<String>,
    ));
  }

  @override
  $SymbolizationOverridesCopyWith<$Res> get overrides {
    if (_value.overrides == null) {
      return null;
    }
    return $SymbolizationOverridesCopyWith<$Res>(_value.overrides, (value) {
      return _then(_value.copyWith(overrides: value));
    });
  }
}

/// @nodoc
abstract class _$BotCommandCopyWith<$Res> implements $BotCommandCopyWith<$Res> {
  factory _$BotCommandCopyWith(
          _BotCommand value, $Res Function(_BotCommand) then) =
      __$BotCommandCopyWithImpl<$Res>;
  @override
  $Res call(
      {SymbolizationOverrides overrides,
      bool symbolizeThis,
      Set<String> worklist});

  @override
  $SymbolizationOverridesCopyWith<$Res> get overrides;
}

/// @nodoc
class __$BotCommandCopyWithImpl<$Res> extends _$BotCommandCopyWithImpl<$Res>
    implements _$BotCommandCopyWith<$Res> {
  __$BotCommandCopyWithImpl(
      _BotCommand _value, $Res Function(_BotCommand) _then)
      : super(_value, (v) => _then(v as _BotCommand));

  @override
  _BotCommand get _value => super._value as _BotCommand;

  @override
  $Res call({
    Object overrides = freezed,
    Object symbolizeThis = freezed,
    Object worklist = freezed,
  }) {
    return _then(_BotCommand(
      overrides: overrides == freezed
          ? _value.overrides
          : overrides as SymbolizationOverrides,
      symbolizeThis: symbolizeThis == freezed
          ? _value.symbolizeThis
          : symbolizeThis as bool,
      worklist: worklist == freezed ? _value.worklist : worklist as Set<String>,
    ));
  }
}

/// @nodoc
class _$_BotCommand implements _BotCommand {
  _$_BotCommand(
      {@required this.overrides,
      @required this.symbolizeThis,
      @required this.worklist})
      : assert(overrides != null),
        assert(symbolizeThis != null),
        assert(worklist != null);

  @override

  /// Overrides that should be used for symbolization. These overrides
  /// replace or augment information available in the comments themselves.
  final SymbolizationOverrides overrides;
  @override

  /// [true] if the user requested to symbolize the comment that contains
  /// command.
  final bool symbolizeThis;
  @override

  /// List of references to comments which need to be symbolized. Each reference
  /// is either in `issue-id` or in `issuecomment-id` format.
  final Set<String> worklist;

  @override
  String toString() {
    return 'BotCommand(overrides: $overrides, symbolizeThis: $symbolizeThis, worklist: $worklist)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _BotCommand &&
            (identical(other.overrides, overrides) ||
                const DeepCollectionEquality()
                    .equals(other.overrides, overrides)) &&
            (identical(other.symbolizeThis, symbolizeThis) ||
                const DeepCollectionEquality()
                    .equals(other.symbolizeThis, symbolizeThis)) &&
            (identical(other.worklist, worklist) ||
                const DeepCollectionEquality()
                    .equals(other.worklist, worklist)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(overrides) ^
      const DeepCollectionEquality().hash(symbolizeThis) ^
      const DeepCollectionEquality().hash(worklist);

  @override
  _$BotCommandCopyWith<_BotCommand> get copyWith =>
      __$BotCommandCopyWithImpl<_BotCommand>(this, _$identity);
}

abstract class _BotCommand implements BotCommand {
  factory _BotCommand(
      {@required SymbolizationOverrides overrides,
      @required bool symbolizeThis,
      @required Set<String> worklist}) = _$_BotCommand;

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
  _$BotCommandCopyWith<_BotCommand> get copyWith;
}

/// @nodoc
class _$SymbolizationOverridesTearOff {
  const _$SymbolizationOverridesTearOff();

// ignore: unused_element
  _SymbolizationOverrides call(
      {@nullable String engineHash,
      @nullable String flutterVersion,
      @nullable String arch,
      @nullable String mode,
      bool force = false,
      @nullable String format,
      @nullable String os}) {
    return _SymbolizationOverrides(
      engineHash: engineHash,
      flutterVersion: flutterVersion,
      arch: arch,
      mode: mode,
      force: force,
      format: format,
      os: os,
    );
  }
}

/// @nodoc
// ignore: unused_element
const $SymbolizationOverrides = _$SymbolizationOverridesTearOff();

/// @nodoc
mixin _$SymbolizationOverrides {
  @nullable
  String get engineHash;
  @nullable
  String get flutterVersion;
  @nullable
  String get arch;
  @nullable
  String get mode;
  bool get force;
  @nullable
  String get format;
  @nullable
  String get os;

  $SymbolizationOverridesCopyWith<SymbolizationOverrides> get copyWith;
}

/// @nodoc
abstract class $SymbolizationOverridesCopyWith<$Res> {
  factory $SymbolizationOverridesCopyWith(SymbolizationOverrides value,
          $Res Function(SymbolizationOverrides) then) =
      _$SymbolizationOverridesCopyWithImpl<$Res>;
  $Res call(
      {@nullable String engineHash,
      @nullable String flutterVersion,
      @nullable String arch,
      @nullable String mode,
      bool force,
      @nullable String format,
      @nullable String os});
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
    Object engineHash = freezed,
    Object flutterVersion = freezed,
    Object arch = freezed,
    Object mode = freezed,
    Object force = freezed,
    Object format = freezed,
    Object os = freezed,
  }) {
    return _then(_value.copyWith(
      engineHash:
          engineHash == freezed ? _value.engineHash : engineHash as String,
      flutterVersion: flutterVersion == freezed
          ? _value.flutterVersion
          : flutterVersion as String,
      arch: arch == freezed ? _value.arch : arch as String,
      mode: mode == freezed ? _value.mode : mode as String,
      force: force == freezed ? _value.force : force as bool,
      format: format == freezed ? _value.format : format as String,
      os: os == freezed ? _value.os : os as String,
    ));
  }
}

/// @nodoc
abstract class _$SymbolizationOverridesCopyWith<$Res>
    implements $SymbolizationOverridesCopyWith<$Res> {
  factory _$SymbolizationOverridesCopyWith(_SymbolizationOverrides value,
          $Res Function(_SymbolizationOverrides) then) =
      __$SymbolizationOverridesCopyWithImpl<$Res>;
  @override
  $Res call(
      {@nullable String engineHash,
      @nullable String flutterVersion,
      @nullable String arch,
      @nullable String mode,
      bool force,
      @nullable String format,
      @nullable String os});
}

/// @nodoc
class __$SymbolizationOverridesCopyWithImpl<$Res>
    extends _$SymbolizationOverridesCopyWithImpl<$Res>
    implements _$SymbolizationOverridesCopyWith<$Res> {
  __$SymbolizationOverridesCopyWithImpl(_SymbolizationOverrides _value,
      $Res Function(_SymbolizationOverrides) _then)
      : super(_value, (v) => _then(v as _SymbolizationOverrides));

  @override
  _SymbolizationOverrides get _value => super._value as _SymbolizationOverrides;

  @override
  $Res call({
    Object engineHash = freezed,
    Object flutterVersion = freezed,
    Object arch = freezed,
    Object mode = freezed,
    Object force = freezed,
    Object format = freezed,
    Object os = freezed,
  }) {
    return _then(_SymbolizationOverrides(
      engineHash:
          engineHash == freezed ? _value.engineHash : engineHash as String,
      flutterVersion: flutterVersion == freezed
          ? _value.flutterVersion
          : flutterVersion as String,
      arch: arch == freezed ? _value.arch : arch as String,
      mode: mode == freezed ? _value.mode : mode as String,
      force: force == freezed ? _value.force : force as bool,
      format: format == freezed ? _value.format : format as String,
      os: os == freezed ? _value.os : os as String,
    ));
  }
}

/// @nodoc
class _$_SymbolizationOverrides implements _SymbolizationOverrides {
  _$_SymbolizationOverrides(
      {@nullable this.engineHash,
      @nullable this.flutterVersion,
      @nullable this.arch,
      @nullable this.mode,
      this.force = false,
      @nullable this.format,
      @nullable this.os})
      : assert(force != null);

  @override
  @nullable
  final String engineHash;
  @override
  @nullable
  final String flutterVersion;
  @override
  @nullable
  final String arch;
  @override
  @nullable
  final String mode;
  @JsonKey(defaultValue: false)
  @override
  final bool force;
  @override
  @nullable
  final String format;
  @override
  @nullable
  final String os;

  @override
  String toString() {
    return 'SymbolizationOverrides(engineHash: $engineHash, flutterVersion: $flutterVersion, arch: $arch, mode: $mode, force: $force, format: $format, os: $os)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _SymbolizationOverrides &&
            (identical(other.engineHash, engineHash) ||
                const DeepCollectionEquality()
                    .equals(other.engineHash, engineHash)) &&
            (identical(other.flutterVersion, flutterVersion) ||
                const DeepCollectionEquality()
                    .equals(other.flutterVersion, flutterVersion)) &&
            (identical(other.arch, arch) ||
                const DeepCollectionEquality().equals(other.arch, arch)) &&
            (identical(other.mode, mode) ||
                const DeepCollectionEquality().equals(other.mode, mode)) &&
            (identical(other.force, force) ||
                const DeepCollectionEquality().equals(other.force, force)) &&
            (identical(other.format, format) ||
                const DeepCollectionEquality().equals(other.format, format)) &&
            (identical(other.os, os) ||
                const DeepCollectionEquality().equals(other.os, os)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(engineHash) ^
      const DeepCollectionEquality().hash(flutterVersion) ^
      const DeepCollectionEquality().hash(arch) ^
      const DeepCollectionEquality().hash(mode) ^
      const DeepCollectionEquality().hash(force) ^
      const DeepCollectionEquality().hash(format) ^
      const DeepCollectionEquality().hash(os);

  @override
  _$SymbolizationOverridesCopyWith<_SymbolizationOverrides> get copyWith =>
      __$SymbolizationOverridesCopyWithImpl<_SymbolizationOverrides>(
          this, _$identity);
}

abstract class _SymbolizationOverrides implements SymbolizationOverrides {
  factory _SymbolizationOverrides(
      {@nullable String engineHash,
      @nullable String flutterVersion,
      @nullable String arch,
      @nullable String mode,
      bool force,
      @nullable String format,
      @nullable String os}) = _$_SymbolizationOverrides;

  @override
  @nullable
  String get engineHash;
  @override
  @nullable
  String get flutterVersion;
  @override
  @nullable
  String get arch;
  @override
  @nullable
  String get mode;
  @override
  bool get force;
  @override
  @nullable
  String get format;
  @override
  @nullable
  String get os;
  @override
  _$SymbolizationOverridesCopyWith<_SymbolizationOverrides> get copyWith;
}

ServerConfig _$ServerConfigFromJson(Map<String, dynamic> json) {
  return _ServerConfig.fromJson(json);
}

/// @nodoc
class _$ServerConfigTearOff {
  const _$ServerConfigTearOff();

// ignore: unused_element
  _ServerConfig call(
      {String githubToken, String sendgridToken, String failureEmail}) {
    return _ServerConfig(
      githubToken: githubToken,
      sendgridToken: sendgridToken,
      failureEmail: failureEmail,
    );
  }

// ignore: unused_element
  ServerConfig fromJson(Map<String, Object> json) {
    return ServerConfig.fromJson(json);
  }
}

/// @nodoc
// ignore: unused_element
const $ServerConfig = _$ServerConfigTearOff();

/// @nodoc
mixin _$ServerConfig {
  String get githubToken;
  String get sendgridToken;
  String get failureEmail;

  Map<String, dynamic> toJson();
  $ServerConfigCopyWith<ServerConfig> get copyWith;
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
    Object githubToken = freezed,
    Object sendgridToken = freezed,
    Object failureEmail = freezed,
  }) {
    return _then(_value.copyWith(
      githubToken:
          githubToken == freezed ? _value.githubToken : githubToken as String,
      sendgridToken: sendgridToken == freezed
          ? _value.sendgridToken
          : sendgridToken as String,
      failureEmail: failureEmail == freezed
          ? _value.failureEmail
          : failureEmail as String,
    ));
  }
}

/// @nodoc
abstract class _$ServerConfigCopyWith<$Res>
    implements $ServerConfigCopyWith<$Res> {
  factory _$ServerConfigCopyWith(
          _ServerConfig value, $Res Function(_ServerConfig) then) =
      __$ServerConfigCopyWithImpl<$Res>;
  @override
  $Res call({String githubToken, String sendgridToken, String failureEmail});
}

/// @nodoc
class __$ServerConfigCopyWithImpl<$Res> extends _$ServerConfigCopyWithImpl<$Res>
    implements _$ServerConfigCopyWith<$Res> {
  __$ServerConfigCopyWithImpl(
      _ServerConfig _value, $Res Function(_ServerConfig) _then)
      : super(_value, (v) => _then(v as _ServerConfig));

  @override
  _ServerConfig get _value => super._value as _ServerConfig;

  @override
  $Res call({
    Object githubToken = freezed,
    Object sendgridToken = freezed,
    Object failureEmail = freezed,
  }) {
    return _then(_ServerConfig(
      githubToken:
          githubToken == freezed ? _value.githubToken : githubToken as String,
      sendgridToken: sendgridToken == freezed
          ? _value.sendgridToken
          : sendgridToken as String,
      failureEmail: failureEmail == freezed
          ? _value.failureEmail
          : failureEmail as String,
    ));
  }
}

@JsonSerializable()

/// @nodoc
class _$_ServerConfig implements _ServerConfig {
  _$_ServerConfig({this.githubToken, this.sendgridToken, this.failureEmail});

  factory _$_ServerConfig.fromJson(Map<String, dynamic> json) =>
      _$_$_ServerConfigFromJson(json);

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
        (other is _ServerConfig &&
            (identical(other.githubToken, githubToken) ||
                const DeepCollectionEquality()
                    .equals(other.githubToken, githubToken)) &&
            (identical(other.sendgridToken, sendgridToken) ||
                const DeepCollectionEquality()
                    .equals(other.sendgridToken, sendgridToken)) &&
            (identical(other.failureEmail, failureEmail) ||
                const DeepCollectionEquality()
                    .equals(other.failureEmail, failureEmail)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(githubToken) ^
      const DeepCollectionEquality().hash(sendgridToken) ^
      const DeepCollectionEquality().hash(failureEmail);

  @override
  _$ServerConfigCopyWith<_ServerConfig> get copyWith =>
      __$ServerConfigCopyWithImpl<_ServerConfig>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$_$_ServerConfigToJson(this);
  }
}

abstract class _ServerConfig implements ServerConfig {
  factory _ServerConfig(
      {String githubToken,
      String sendgridToken,
      String failureEmail}) = _$_ServerConfig;

  factory _ServerConfig.fromJson(Map<String, dynamic> json) =
      _$_ServerConfig.fromJson;

  @override
  String get githubToken;
  @override
  String get sendgridToken;
  @override
  String get failureEmail;
  @override
  _$ServerConfigCopyWith<_ServerConfig> get copyWith;
}
