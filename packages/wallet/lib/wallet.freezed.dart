// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wallet.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

Utxo _$UtxoFromJson(Map<String, dynamic> json) {
  return _Utxo.fromJson(json);
}

/// @nodoc
mixin _$Utxo {
  String get txid => throw _privateConstructorUsedError;
  int get vout => throw _privateConstructorUsedError;
  int get value => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UtxoCopyWith<Utxo> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UtxoCopyWith<$Res> {
  factory $UtxoCopyWith(Utxo value, $Res Function(Utxo) then) =
      _$UtxoCopyWithImpl<$Res, Utxo>;
  @useResult
  $Res call({String txid, int vout, int value});
}

/// @nodoc
class _$UtxoCopyWithImpl<$Res, $Val extends Utxo>
    implements $UtxoCopyWith<$Res> {
  _$UtxoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? txid = null,
    Object? vout = null,
    Object? value = null,
  }) {
    return _then(_value.copyWith(
      txid: null == txid
          ? _value.txid
          : txid // ignore: cast_nullable_to_non_nullable
              as String,
      vout: null == vout
          ? _value.vout
          : vout // ignore: cast_nullable_to_non_nullable
              as int,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_UtxoCopyWith<$Res> implements $UtxoCopyWith<$Res> {
  factory _$$_UtxoCopyWith(_$_Utxo value, $Res Function(_$_Utxo) then) =
      __$$_UtxoCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String txid, int vout, int value});
}

/// @nodoc
class __$$_UtxoCopyWithImpl<$Res> extends _$UtxoCopyWithImpl<$Res, _$_Utxo>
    implements _$$_UtxoCopyWith<$Res> {
  __$$_UtxoCopyWithImpl(_$_Utxo _value, $Res Function(_$_Utxo) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? txid = null,
    Object? vout = null,
    Object? value = null,
  }) {
    return _then(_$_Utxo(
      txid: null == txid
          ? _value.txid
          : txid // ignore: cast_nullable_to_non_nullable
              as String,
      vout: null == vout
          ? _value.vout
          : vout // ignore: cast_nullable_to_non_nullable
              as int,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_Utxo with DiagnosticableTreeMixin implements _Utxo {
  const _$_Utxo({required this.txid, required this.vout, required this.value});

  factory _$_Utxo.fromJson(Map<String, dynamic> json) => _$$_UtxoFromJson(json);

  @override
  final String txid;
  @override
  final int vout;
  @override
  final int value;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Utxo(txid: $txid, vout: $vout, value: $value)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'Utxo'))
      ..add(DiagnosticsProperty('txid', txid))
      ..add(DiagnosticsProperty('vout', vout))
      ..add(DiagnosticsProperty('value', value));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_Utxo &&
            (identical(other.txid, txid) || other.txid == txid) &&
            (identical(other.vout, vout) || other.vout == vout) &&
            (identical(other.value, value) || other.value == value));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, txid, vout, value);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_UtxoCopyWith<_$_Utxo> get copyWith =>
      __$$_UtxoCopyWithImpl<_$_Utxo>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_UtxoToJson(
      this,
    );
  }
}

abstract class _Utxo implements Utxo {
  const factory _Utxo(
      {required final String txid,
      required final int vout,
      required final int value}) = _$_Utxo;

  factory _Utxo.fromJson(Map<String, dynamic> json) = _$_Utxo.fromJson;

  @override
  String get txid;
  @override
  int get vout;
  @override
  int get value;
  @override
  @JsonKey(ignore: true)
  _$$_UtxoCopyWith<_$_Utxo> get copyWith => throw _privateConstructorUsedError;
}
