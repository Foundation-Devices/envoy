// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'backup.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UploadMagicBackupStreamItem {
  Object get field0;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is UploadMagicBackupStreamItem &&
            const DeepCollectionEquality().equals(other.field0, field0));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(field0));

  @override
  String toString() {
    return 'UploadMagicBackupStreamItem(field0: $field0)';
  }
}

/// @nodoc
class $UploadMagicBackupStreamItemCopyWith<$Res> {
  $UploadMagicBackupStreamItemCopyWith(UploadMagicBackupStreamItem _,
      $Res Function(UploadMagicBackupStreamItem) __);
}

/// Adds pattern-matching-related methods to [UploadMagicBackupStreamItem].
extension UploadMagicBackupStreamItemPatterns on UploadMagicBackupStreamItem {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(UploadMagicBackupStreamItem_PartHeader value)? partHeader,
    TResult Function(UploadMagicBackupStreamItem_PartChunk value)? partChunk,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case UploadMagicBackupStreamItem_PartHeader() when partHeader != null:
        return partHeader(_that);
      case UploadMagicBackupStreamItem_PartChunk() when partChunk != null:
        return partChunk(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(UploadMagicBackupStreamItem_PartHeader value)
        partHeader,
    required TResult Function(UploadMagicBackupStreamItem_PartChunk value)
        partChunk,
  }) {
    final _that = this;
    switch (_that) {
      case UploadMagicBackupStreamItem_PartHeader():
        return partHeader(_that);
      case UploadMagicBackupStreamItem_PartChunk():
        return partChunk(_that);
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(UploadMagicBackupStreamItem_PartHeader value)? partHeader,
    TResult? Function(UploadMagicBackupStreamItem_PartChunk value)? partChunk,
  }) {
    final _that = this;
    switch (_that) {
      case UploadMagicBackupStreamItem_PartHeader() when partHeader != null:
        return partHeader(_that);
      case UploadMagicBackupStreamItem_PartChunk() when partChunk != null:
        return partChunk(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(UploadMagicBackupPartHeader field0)? partHeader,
    TResult Function(Uint8List field0)? partChunk,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case UploadMagicBackupStreamItem_PartHeader() when partHeader != null:
        return partHeader(_that.field0);
      case UploadMagicBackupStreamItem_PartChunk() when partChunk != null:
        return partChunk(_that.field0);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(UploadMagicBackupPartHeader field0) partHeader,
    required TResult Function(Uint8List field0) partChunk,
  }) {
    final _that = this;
    switch (_that) {
      case UploadMagicBackupStreamItem_PartHeader():
        return partHeader(_that.field0);
      case UploadMagicBackupStreamItem_PartChunk():
        return partChunk(_that.field0);
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(UploadMagicBackupPartHeader field0)? partHeader,
    TResult? Function(Uint8List field0)? partChunk,
  }) {
    final _that = this;
    switch (_that) {
      case UploadMagicBackupStreamItem_PartHeader() when partHeader != null:
        return partHeader(_that.field0);
      case UploadMagicBackupStreamItem_PartChunk() when partChunk != null:
        return partChunk(_that.field0);
      case _:
        return null;
    }
  }
}

/// @nodoc

class UploadMagicBackupStreamItem_PartHeader
    extends UploadMagicBackupStreamItem {
  const UploadMagicBackupStreamItem_PartHeader(this.field0) : super._();

  @override
  final UploadMagicBackupPartHeader field0;

  /// Create a copy of UploadMagicBackupStreamItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $UploadMagicBackupStreamItem_PartHeaderCopyWith<
          UploadMagicBackupStreamItem_PartHeader>
      get copyWith => _$UploadMagicBackupStreamItem_PartHeaderCopyWithImpl<
          UploadMagicBackupStreamItem_PartHeader>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is UploadMagicBackupStreamItem_PartHeader &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'UploadMagicBackupStreamItem.partHeader(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $UploadMagicBackupStreamItem_PartHeaderCopyWith<$Res>
    implements $UploadMagicBackupStreamItemCopyWith<$Res> {
  factory $UploadMagicBackupStreamItem_PartHeaderCopyWith(
          UploadMagicBackupStreamItem_PartHeader value,
          $Res Function(UploadMagicBackupStreamItem_PartHeader) _then) =
      _$UploadMagicBackupStreamItem_PartHeaderCopyWithImpl;
  @useResult
  $Res call({UploadMagicBackupPartHeader field0});
}

/// @nodoc
class _$UploadMagicBackupStreamItem_PartHeaderCopyWithImpl<$Res>
    implements $UploadMagicBackupStreamItem_PartHeaderCopyWith<$Res> {
  _$UploadMagicBackupStreamItem_PartHeaderCopyWithImpl(this._self, this._then);

  final UploadMagicBackupStreamItem_PartHeader _self;
  final $Res Function(UploadMagicBackupStreamItem_PartHeader) _then;

  /// Create a copy of UploadMagicBackupStreamItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(UploadMagicBackupStreamItem_PartHeader(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as UploadMagicBackupPartHeader,
    ));
  }
}

/// @nodoc

class UploadMagicBackupStreamItem_PartChunk
    extends UploadMagicBackupStreamItem {
  const UploadMagicBackupStreamItem_PartChunk(this.field0) : super._();

  @override
  final Uint8List field0;

  /// Create a copy of UploadMagicBackupStreamItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $UploadMagicBackupStreamItem_PartChunkCopyWith<
          UploadMagicBackupStreamItem_PartChunk>
      get copyWith => _$UploadMagicBackupStreamItem_PartChunkCopyWithImpl<
          UploadMagicBackupStreamItem_PartChunk>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is UploadMagicBackupStreamItem_PartChunk &&
            const DeepCollectionEquality().equals(other.field0, field0));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(field0));

  @override
  String toString() {
    return 'UploadMagicBackupStreamItem.partChunk(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $UploadMagicBackupStreamItem_PartChunkCopyWith<$Res>
    implements $UploadMagicBackupStreamItemCopyWith<$Res> {
  factory $UploadMagicBackupStreamItem_PartChunkCopyWith(
          UploadMagicBackupStreamItem_PartChunk value,
          $Res Function(UploadMagicBackupStreamItem_PartChunk) _then) =
      _$UploadMagicBackupStreamItem_PartChunkCopyWithImpl;
  @useResult
  $Res call({Uint8List field0});
}

/// @nodoc
class _$UploadMagicBackupStreamItem_PartChunkCopyWithImpl<$Res>
    implements $UploadMagicBackupStreamItem_PartChunkCopyWith<$Res> {
  _$UploadMagicBackupStreamItem_PartChunkCopyWithImpl(this._self, this._then);

  final UploadMagicBackupStreamItem_PartChunk _self;
  final $Res Function(UploadMagicBackupStreamItem_PartChunk) _then;

  /// Create a copy of UploadMagicBackupStreamItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(UploadMagicBackupStreamItem_PartChunk(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as Uint8List,
    ));
  }
}

// dart format on
