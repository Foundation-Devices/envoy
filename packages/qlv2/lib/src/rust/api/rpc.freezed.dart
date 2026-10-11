// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'rpc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$InboundRpc {
  RustOpaqueInterface get field0;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is InboundRpc &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'InboundRpc(field0: $field0)';
  }
}

/// @nodoc
class $InboundRpcCopyWith<$Res> {
  $InboundRpcCopyWith(InboundRpc _, $Res Function(InboundRpc) __);
}

/// Adds pattern-matching-related methods to [InboundRpc].
extension InboundRpcPatterns on InboundRpc {
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
    TResult Function(InboundRpc_ListApps value)? listApps,
    TResult Function(InboundRpc_AppDownload value)? appDownload,
    TResult Function(InboundRpc_Timezone value)? timezone,
    TResult Function(InboundRpc_SecurityCheck value)? securityCheck,
    TResult Function(InboundRpc_FirmwareUpdateCheck value)? firmwareUpdateCheck,
    TResult Function(InboundRpc_FirmwareDownload value)? firmwareDownload,
    TResult Function(InboundRpc_ExchangeRateSubscription value)?
        exchangeRateSubscription,
    TResult Function(InboundRpc_ExchangeRateHistory value)? exchangeRateHistory,
    TResult Function(InboundRpc_CurrentTime value)? currentTime,
    TResult Function(InboundRpc_BroadcastTransaction value)?
        broadcastTransaction,
    TResult Function(InboundRpc_BackupShard value)? backupShard,
    TResult Function(InboundRpc_RestoreShard value)? restoreShard,
    TResult Function(InboundRpc_PassportMagicBackupStatus value)?
        passportMagicBackupStatus,
    TResult Function(InboundRpc_UploadMagicBackup value)? uploadMagicBackup,
    TResult Function(InboundRpc_DownloadMagicBackup value)? downloadMagicBackup,
    TResult Function(InboundRpc_Echo value)? echo,
    TResult Function(InboundRpc_DownloadBenchmark value)? downloadBenchmark,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case InboundRpc_ListApps() when listApps != null:
        return listApps(_that);
      case InboundRpc_AppDownload() when appDownload != null:
        return appDownload(_that);
      case InboundRpc_Timezone() when timezone != null:
        return timezone(_that);
      case InboundRpc_SecurityCheck() when securityCheck != null:
        return securityCheck(_that);
      case InboundRpc_FirmwareUpdateCheck() when firmwareUpdateCheck != null:
        return firmwareUpdateCheck(_that);
      case InboundRpc_FirmwareDownload() when firmwareDownload != null:
        return firmwareDownload(_that);
      case InboundRpc_ExchangeRateSubscription()
          when exchangeRateSubscription != null:
        return exchangeRateSubscription(_that);
      case InboundRpc_ExchangeRateHistory() when exchangeRateHistory != null:
        return exchangeRateHistory(_that);
      case InboundRpc_CurrentTime() when currentTime != null:
        return currentTime(_that);
      case InboundRpc_BroadcastTransaction() when broadcastTransaction != null:
        return broadcastTransaction(_that);
      case InboundRpc_BackupShard() when backupShard != null:
        return backupShard(_that);
      case InboundRpc_RestoreShard() when restoreShard != null:
        return restoreShard(_that);
      case InboundRpc_PassportMagicBackupStatus()
          when passportMagicBackupStatus != null:
        return passportMagicBackupStatus(_that);
      case InboundRpc_UploadMagicBackup() when uploadMagicBackup != null:
        return uploadMagicBackup(_that);
      case InboundRpc_DownloadMagicBackup() when downloadMagicBackup != null:
        return downloadMagicBackup(_that);
      case InboundRpc_Echo() when echo != null:
        return echo(_that);
      case InboundRpc_DownloadBenchmark() when downloadBenchmark != null:
        return downloadBenchmark(_that);
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
    required TResult Function(InboundRpc_ListApps value) listApps,
    required TResult Function(InboundRpc_AppDownload value) appDownload,
    required TResult Function(InboundRpc_Timezone value) timezone,
    required TResult Function(InboundRpc_SecurityCheck value) securityCheck,
    required TResult Function(InboundRpc_FirmwareUpdateCheck value)
        firmwareUpdateCheck,
    required TResult Function(InboundRpc_FirmwareDownload value)
        firmwareDownload,
    required TResult Function(InboundRpc_ExchangeRateSubscription value)
        exchangeRateSubscription,
    required TResult Function(InboundRpc_ExchangeRateHistory value)
        exchangeRateHistory,
    required TResult Function(InboundRpc_CurrentTime value) currentTime,
    required TResult Function(InboundRpc_BroadcastTransaction value)
        broadcastTransaction,
    required TResult Function(InboundRpc_BackupShard value) backupShard,
    required TResult Function(InboundRpc_RestoreShard value) restoreShard,
    required TResult Function(InboundRpc_PassportMagicBackupStatus value)
        passportMagicBackupStatus,
    required TResult Function(InboundRpc_UploadMagicBackup value)
        uploadMagicBackup,
    required TResult Function(InboundRpc_DownloadMagicBackup value)
        downloadMagicBackup,
    required TResult Function(InboundRpc_Echo value) echo,
    required TResult Function(InboundRpc_DownloadBenchmark value)
        downloadBenchmark,
  }) {
    final _that = this;
    switch (_that) {
      case InboundRpc_ListApps():
        return listApps(_that);
      case InboundRpc_AppDownload():
        return appDownload(_that);
      case InboundRpc_Timezone():
        return timezone(_that);
      case InboundRpc_SecurityCheck():
        return securityCheck(_that);
      case InboundRpc_FirmwareUpdateCheck():
        return firmwareUpdateCheck(_that);
      case InboundRpc_FirmwareDownload():
        return firmwareDownload(_that);
      case InboundRpc_ExchangeRateSubscription():
        return exchangeRateSubscription(_that);
      case InboundRpc_ExchangeRateHistory():
        return exchangeRateHistory(_that);
      case InboundRpc_CurrentTime():
        return currentTime(_that);
      case InboundRpc_BroadcastTransaction():
        return broadcastTransaction(_that);
      case InboundRpc_BackupShard():
        return backupShard(_that);
      case InboundRpc_RestoreShard():
        return restoreShard(_that);
      case InboundRpc_PassportMagicBackupStatus():
        return passportMagicBackupStatus(_that);
      case InboundRpc_UploadMagicBackup():
        return uploadMagicBackup(_that);
      case InboundRpc_DownloadMagicBackup():
        return downloadMagicBackup(_that);
      case InboundRpc_Echo():
        return echo(_that);
      case InboundRpc_DownloadBenchmark():
        return downloadBenchmark(_that);
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
    TResult? Function(InboundRpc_ListApps value)? listApps,
    TResult? Function(InboundRpc_AppDownload value)? appDownload,
    TResult? Function(InboundRpc_Timezone value)? timezone,
    TResult? Function(InboundRpc_SecurityCheck value)? securityCheck,
    TResult? Function(InboundRpc_FirmwareUpdateCheck value)?
        firmwareUpdateCheck,
    TResult? Function(InboundRpc_FirmwareDownload value)? firmwareDownload,
    TResult? Function(InboundRpc_ExchangeRateSubscription value)?
        exchangeRateSubscription,
    TResult? Function(InboundRpc_ExchangeRateHistory value)?
        exchangeRateHistory,
    TResult? Function(InboundRpc_CurrentTime value)? currentTime,
    TResult? Function(InboundRpc_BroadcastTransaction value)?
        broadcastTransaction,
    TResult? Function(InboundRpc_BackupShard value)? backupShard,
    TResult? Function(InboundRpc_RestoreShard value)? restoreShard,
    TResult? Function(InboundRpc_PassportMagicBackupStatus value)?
        passportMagicBackupStatus,
    TResult? Function(InboundRpc_UploadMagicBackup value)? uploadMagicBackup,
    TResult? Function(InboundRpc_DownloadMagicBackup value)?
        downloadMagicBackup,
    TResult? Function(InboundRpc_Echo value)? echo,
    TResult? Function(InboundRpc_DownloadBenchmark value)? downloadBenchmark,
  }) {
    final _that = this;
    switch (_that) {
      case InboundRpc_ListApps() when listApps != null:
        return listApps(_that);
      case InboundRpc_AppDownload() when appDownload != null:
        return appDownload(_that);
      case InboundRpc_Timezone() when timezone != null:
        return timezone(_that);
      case InboundRpc_SecurityCheck() when securityCheck != null:
        return securityCheck(_that);
      case InboundRpc_FirmwareUpdateCheck() when firmwareUpdateCheck != null:
        return firmwareUpdateCheck(_that);
      case InboundRpc_FirmwareDownload() when firmwareDownload != null:
        return firmwareDownload(_that);
      case InboundRpc_ExchangeRateSubscription()
          when exchangeRateSubscription != null:
        return exchangeRateSubscription(_that);
      case InboundRpc_ExchangeRateHistory() when exchangeRateHistory != null:
        return exchangeRateHistory(_that);
      case InboundRpc_CurrentTime() when currentTime != null:
        return currentTime(_that);
      case InboundRpc_BroadcastTransaction() when broadcastTransaction != null:
        return broadcastTransaction(_that);
      case InboundRpc_BackupShard() when backupShard != null:
        return backupShard(_that);
      case InboundRpc_RestoreShard() when restoreShard != null:
        return restoreShard(_that);
      case InboundRpc_PassportMagicBackupStatus()
          when passportMagicBackupStatus != null:
        return passportMagicBackupStatus(_that);
      case InboundRpc_UploadMagicBackup() when uploadMagicBackup != null:
        return uploadMagicBackup(_that);
      case InboundRpc_DownloadMagicBackup() when downloadMagicBackup != null:
        return downloadMagicBackup(_that);
      case InboundRpc_Echo() when echo != null:
        return echo(_that);
      case InboundRpc_DownloadBenchmark() when downloadBenchmark != null:
        return downloadBenchmark(_that);
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
    TResult Function(InboundRequestListApps field0)? listApps,
    TResult Function(InboundDownloadApp field0)? appDownload,
    TResult Function(InboundRequestTimezone field0)? timezone,
    TResult Function(InboundRunSecurityCheck field0)? securityCheck,
    TResult Function(InboundRequestCheckFirmwareUpdate field0)?
        firmwareUpdateCheck,
    TResult Function(InboundDownloadFirmware field0)? firmwareDownload,
    TResult Function(InboundSubscribeExchangeRate field0)?
        exchangeRateSubscription,
    TResult Function(InboundRequestExchangeRateHistory field0)?
        exchangeRateHistory,
    TResult Function(InboundRequestCurrentTime field0)? currentTime,
    TResult Function(InboundRequestBroadcastTransaction field0)?
        broadcastTransaction,
    TResult Function(InboundRequestBackupShard field0)? backupShard,
    TResult Function(InboundRequestRestoreShard field0)? restoreShard,
    TResult Function(InboundRequestPassportMagicBackupStatus field0)?
        passportMagicBackupStatus,
    TResult Function(InboundUploadMagicBackup field0)? uploadMagicBackup,
    TResult Function(InboundDownloadMagicBackup field0)? downloadMagicBackup,
    TResult Function(InboundRequestEcho field0)? echo,
    TResult Function(InboundDownloadBenchmark field0)? downloadBenchmark,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case InboundRpc_ListApps() when listApps != null:
        return listApps(_that.field0);
      case InboundRpc_AppDownload() when appDownload != null:
        return appDownload(_that.field0);
      case InboundRpc_Timezone() when timezone != null:
        return timezone(_that.field0);
      case InboundRpc_SecurityCheck() when securityCheck != null:
        return securityCheck(_that.field0);
      case InboundRpc_FirmwareUpdateCheck() when firmwareUpdateCheck != null:
        return firmwareUpdateCheck(_that.field0);
      case InboundRpc_FirmwareDownload() when firmwareDownload != null:
        return firmwareDownload(_that.field0);
      case InboundRpc_ExchangeRateSubscription()
          when exchangeRateSubscription != null:
        return exchangeRateSubscription(_that.field0);
      case InboundRpc_ExchangeRateHistory() when exchangeRateHistory != null:
        return exchangeRateHistory(_that.field0);
      case InboundRpc_CurrentTime() when currentTime != null:
        return currentTime(_that.field0);
      case InboundRpc_BroadcastTransaction() when broadcastTransaction != null:
        return broadcastTransaction(_that.field0);
      case InboundRpc_BackupShard() when backupShard != null:
        return backupShard(_that.field0);
      case InboundRpc_RestoreShard() when restoreShard != null:
        return restoreShard(_that.field0);
      case InboundRpc_PassportMagicBackupStatus()
          when passportMagicBackupStatus != null:
        return passportMagicBackupStatus(_that.field0);
      case InboundRpc_UploadMagicBackup() when uploadMagicBackup != null:
        return uploadMagicBackup(_that.field0);
      case InboundRpc_DownloadMagicBackup() when downloadMagicBackup != null:
        return downloadMagicBackup(_that.field0);
      case InboundRpc_Echo() when echo != null:
        return echo(_that.field0);
      case InboundRpc_DownloadBenchmark() when downloadBenchmark != null:
        return downloadBenchmark(_that.field0);
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
    required TResult Function(InboundRequestListApps field0) listApps,
    required TResult Function(InboundDownloadApp field0) appDownload,
    required TResult Function(InboundRequestTimezone field0) timezone,
    required TResult Function(InboundRunSecurityCheck field0) securityCheck,
    required TResult Function(InboundRequestCheckFirmwareUpdate field0)
        firmwareUpdateCheck,
    required TResult Function(InboundDownloadFirmware field0) firmwareDownload,
    required TResult Function(InboundSubscribeExchangeRate field0)
        exchangeRateSubscription,
    required TResult Function(InboundRequestExchangeRateHistory field0)
        exchangeRateHistory,
    required TResult Function(InboundRequestCurrentTime field0) currentTime,
    required TResult Function(InboundRequestBroadcastTransaction field0)
        broadcastTransaction,
    required TResult Function(InboundRequestBackupShard field0) backupShard,
    required TResult Function(InboundRequestRestoreShard field0) restoreShard,
    required TResult Function(InboundRequestPassportMagicBackupStatus field0)
        passportMagicBackupStatus,
    required TResult Function(InboundUploadMagicBackup field0)
        uploadMagicBackup,
    required TResult Function(InboundDownloadMagicBackup field0)
        downloadMagicBackup,
    required TResult Function(InboundRequestEcho field0) echo,
    required TResult Function(InboundDownloadBenchmark field0)
        downloadBenchmark,
  }) {
    final _that = this;
    switch (_that) {
      case InboundRpc_ListApps():
        return listApps(_that.field0);
      case InboundRpc_AppDownload():
        return appDownload(_that.field0);
      case InboundRpc_Timezone():
        return timezone(_that.field0);
      case InboundRpc_SecurityCheck():
        return securityCheck(_that.field0);
      case InboundRpc_FirmwareUpdateCheck():
        return firmwareUpdateCheck(_that.field0);
      case InboundRpc_FirmwareDownload():
        return firmwareDownload(_that.field0);
      case InboundRpc_ExchangeRateSubscription():
        return exchangeRateSubscription(_that.field0);
      case InboundRpc_ExchangeRateHistory():
        return exchangeRateHistory(_that.field0);
      case InboundRpc_CurrentTime():
        return currentTime(_that.field0);
      case InboundRpc_BroadcastTransaction():
        return broadcastTransaction(_that.field0);
      case InboundRpc_BackupShard():
        return backupShard(_that.field0);
      case InboundRpc_RestoreShard():
        return restoreShard(_that.field0);
      case InboundRpc_PassportMagicBackupStatus():
        return passportMagicBackupStatus(_that.field0);
      case InboundRpc_UploadMagicBackup():
        return uploadMagicBackup(_that.field0);
      case InboundRpc_DownloadMagicBackup():
        return downloadMagicBackup(_that.field0);
      case InboundRpc_Echo():
        return echo(_that.field0);
      case InboundRpc_DownloadBenchmark():
        return downloadBenchmark(_that.field0);
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
    TResult? Function(InboundRequestListApps field0)? listApps,
    TResult? Function(InboundDownloadApp field0)? appDownload,
    TResult? Function(InboundRequestTimezone field0)? timezone,
    TResult? Function(InboundRunSecurityCheck field0)? securityCheck,
    TResult? Function(InboundRequestCheckFirmwareUpdate field0)?
        firmwareUpdateCheck,
    TResult? Function(InboundDownloadFirmware field0)? firmwareDownload,
    TResult? Function(InboundSubscribeExchangeRate field0)?
        exchangeRateSubscription,
    TResult? Function(InboundRequestExchangeRateHistory field0)?
        exchangeRateHistory,
    TResult? Function(InboundRequestCurrentTime field0)? currentTime,
    TResult? Function(InboundRequestBroadcastTransaction field0)?
        broadcastTransaction,
    TResult? Function(InboundRequestBackupShard field0)? backupShard,
    TResult? Function(InboundRequestRestoreShard field0)? restoreShard,
    TResult? Function(InboundRequestPassportMagicBackupStatus field0)?
        passportMagicBackupStatus,
    TResult? Function(InboundUploadMagicBackup field0)? uploadMagicBackup,
    TResult? Function(InboundDownloadMagicBackup field0)? downloadMagicBackup,
    TResult? Function(InboundRequestEcho field0)? echo,
    TResult? Function(InboundDownloadBenchmark field0)? downloadBenchmark,
  }) {
    final _that = this;
    switch (_that) {
      case InboundRpc_ListApps() when listApps != null:
        return listApps(_that.field0);
      case InboundRpc_AppDownload() when appDownload != null:
        return appDownload(_that.field0);
      case InboundRpc_Timezone() when timezone != null:
        return timezone(_that.field0);
      case InboundRpc_SecurityCheck() when securityCheck != null:
        return securityCheck(_that.field0);
      case InboundRpc_FirmwareUpdateCheck() when firmwareUpdateCheck != null:
        return firmwareUpdateCheck(_that.field0);
      case InboundRpc_FirmwareDownload() when firmwareDownload != null:
        return firmwareDownload(_that.field0);
      case InboundRpc_ExchangeRateSubscription()
          when exchangeRateSubscription != null:
        return exchangeRateSubscription(_that.field0);
      case InboundRpc_ExchangeRateHistory() when exchangeRateHistory != null:
        return exchangeRateHistory(_that.field0);
      case InboundRpc_CurrentTime() when currentTime != null:
        return currentTime(_that.field0);
      case InboundRpc_BroadcastTransaction() when broadcastTransaction != null:
        return broadcastTransaction(_that.field0);
      case InboundRpc_BackupShard() when backupShard != null:
        return backupShard(_that.field0);
      case InboundRpc_RestoreShard() when restoreShard != null:
        return restoreShard(_that.field0);
      case InboundRpc_PassportMagicBackupStatus()
          when passportMagicBackupStatus != null:
        return passportMagicBackupStatus(_that.field0);
      case InboundRpc_UploadMagicBackup() when uploadMagicBackup != null:
        return uploadMagicBackup(_that.field0);
      case InboundRpc_DownloadMagicBackup() when downloadMagicBackup != null:
        return downloadMagicBackup(_that.field0);
      case InboundRpc_Echo() when echo != null:
        return echo(_that.field0);
      case InboundRpc_DownloadBenchmark() when downloadBenchmark != null:
        return downloadBenchmark(_that.field0);
      case _:
        return null;
    }
  }
}

/// @nodoc

class InboundRpc_ListApps extends InboundRpc {
  const InboundRpc_ListApps(this.field0) : super._();

  @override
  final InboundRequestListApps field0;

  /// Create a copy of InboundRpc
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $InboundRpc_ListAppsCopyWith<InboundRpc_ListApps> get copyWith =>
      _$InboundRpc_ListAppsCopyWithImpl<InboundRpc_ListApps>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is InboundRpc_ListApps &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'InboundRpc.listApps(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $InboundRpc_ListAppsCopyWith<$Res>
    implements $InboundRpcCopyWith<$Res> {
  factory $InboundRpc_ListAppsCopyWith(
          InboundRpc_ListApps value, $Res Function(InboundRpc_ListApps) _then) =
      _$InboundRpc_ListAppsCopyWithImpl;
  @useResult
  $Res call({InboundRequestListApps field0});
}

/// @nodoc
class _$InboundRpc_ListAppsCopyWithImpl<$Res>
    implements $InboundRpc_ListAppsCopyWith<$Res> {
  _$InboundRpc_ListAppsCopyWithImpl(this._self, this._then);

  final InboundRpc_ListApps _self;
  final $Res Function(InboundRpc_ListApps) _then;

  /// Create a copy of InboundRpc
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(InboundRpc_ListApps(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as InboundRequestListApps,
    ));
  }
}

/// @nodoc

class InboundRpc_AppDownload extends InboundRpc {
  const InboundRpc_AppDownload(this.field0) : super._();

  @override
  final InboundDownloadApp field0;

  /// Create a copy of InboundRpc
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $InboundRpc_AppDownloadCopyWith<InboundRpc_AppDownload> get copyWith =>
      _$InboundRpc_AppDownloadCopyWithImpl<InboundRpc_AppDownload>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is InboundRpc_AppDownload &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'InboundRpc.appDownload(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $InboundRpc_AppDownloadCopyWith<$Res>
    implements $InboundRpcCopyWith<$Res> {
  factory $InboundRpc_AppDownloadCopyWith(InboundRpc_AppDownload value,
          $Res Function(InboundRpc_AppDownload) _then) =
      _$InboundRpc_AppDownloadCopyWithImpl;
  @useResult
  $Res call({InboundDownloadApp field0});
}

/// @nodoc
class _$InboundRpc_AppDownloadCopyWithImpl<$Res>
    implements $InboundRpc_AppDownloadCopyWith<$Res> {
  _$InboundRpc_AppDownloadCopyWithImpl(this._self, this._then);

  final InboundRpc_AppDownload _self;
  final $Res Function(InboundRpc_AppDownload) _then;

  /// Create a copy of InboundRpc
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(InboundRpc_AppDownload(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as InboundDownloadApp,
    ));
  }
}

/// @nodoc

class InboundRpc_Timezone extends InboundRpc {
  const InboundRpc_Timezone(this.field0) : super._();

  @override
  final InboundRequestTimezone field0;

  /// Create a copy of InboundRpc
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $InboundRpc_TimezoneCopyWith<InboundRpc_Timezone> get copyWith =>
      _$InboundRpc_TimezoneCopyWithImpl<InboundRpc_Timezone>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is InboundRpc_Timezone &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'InboundRpc.timezone(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $InboundRpc_TimezoneCopyWith<$Res>
    implements $InboundRpcCopyWith<$Res> {
  factory $InboundRpc_TimezoneCopyWith(
          InboundRpc_Timezone value, $Res Function(InboundRpc_Timezone) _then) =
      _$InboundRpc_TimezoneCopyWithImpl;
  @useResult
  $Res call({InboundRequestTimezone field0});
}

/// @nodoc
class _$InboundRpc_TimezoneCopyWithImpl<$Res>
    implements $InboundRpc_TimezoneCopyWith<$Res> {
  _$InboundRpc_TimezoneCopyWithImpl(this._self, this._then);

  final InboundRpc_Timezone _self;
  final $Res Function(InboundRpc_Timezone) _then;

  /// Create a copy of InboundRpc
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(InboundRpc_Timezone(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as InboundRequestTimezone,
    ));
  }
}

/// @nodoc

class InboundRpc_SecurityCheck extends InboundRpc {
  const InboundRpc_SecurityCheck(this.field0) : super._();

  @override
  final InboundRunSecurityCheck field0;

  /// Create a copy of InboundRpc
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $InboundRpc_SecurityCheckCopyWith<InboundRpc_SecurityCheck> get copyWith =>
      _$InboundRpc_SecurityCheckCopyWithImpl<InboundRpc_SecurityCheck>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is InboundRpc_SecurityCheck &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'InboundRpc.securityCheck(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $InboundRpc_SecurityCheckCopyWith<$Res>
    implements $InboundRpcCopyWith<$Res> {
  factory $InboundRpc_SecurityCheckCopyWith(InboundRpc_SecurityCheck value,
          $Res Function(InboundRpc_SecurityCheck) _then) =
      _$InboundRpc_SecurityCheckCopyWithImpl;
  @useResult
  $Res call({InboundRunSecurityCheck field0});
}

/// @nodoc
class _$InboundRpc_SecurityCheckCopyWithImpl<$Res>
    implements $InboundRpc_SecurityCheckCopyWith<$Res> {
  _$InboundRpc_SecurityCheckCopyWithImpl(this._self, this._then);

  final InboundRpc_SecurityCheck _self;
  final $Res Function(InboundRpc_SecurityCheck) _then;

  /// Create a copy of InboundRpc
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(InboundRpc_SecurityCheck(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as InboundRunSecurityCheck,
    ));
  }
}

/// @nodoc

class InboundRpc_FirmwareUpdateCheck extends InboundRpc {
  const InboundRpc_FirmwareUpdateCheck(this.field0) : super._();

  @override
  final InboundRequestCheckFirmwareUpdate field0;

  /// Create a copy of InboundRpc
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $InboundRpc_FirmwareUpdateCheckCopyWith<InboundRpc_FirmwareUpdateCheck>
      get copyWith => _$InboundRpc_FirmwareUpdateCheckCopyWithImpl<
          InboundRpc_FirmwareUpdateCheck>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is InboundRpc_FirmwareUpdateCheck &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'InboundRpc.firmwareUpdateCheck(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $InboundRpc_FirmwareUpdateCheckCopyWith<$Res>
    implements $InboundRpcCopyWith<$Res> {
  factory $InboundRpc_FirmwareUpdateCheckCopyWith(
          InboundRpc_FirmwareUpdateCheck value,
          $Res Function(InboundRpc_FirmwareUpdateCheck) _then) =
      _$InboundRpc_FirmwareUpdateCheckCopyWithImpl;
  @useResult
  $Res call({InboundRequestCheckFirmwareUpdate field0});
}

/// @nodoc
class _$InboundRpc_FirmwareUpdateCheckCopyWithImpl<$Res>
    implements $InboundRpc_FirmwareUpdateCheckCopyWith<$Res> {
  _$InboundRpc_FirmwareUpdateCheckCopyWithImpl(this._self, this._then);

  final InboundRpc_FirmwareUpdateCheck _self;
  final $Res Function(InboundRpc_FirmwareUpdateCheck) _then;

  /// Create a copy of InboundRpc
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(InboundRpc_FirmwareUpdateCheck(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as InboundRequestCheckFirmwareUpdate,
    ));
  }
}

/// @nodoc

class InboundRpc_FirmwareDownload extends InboundRpc {
  const InboundRpc_FirmwareDownload(this.field0) : super._();

  @override
  final InboundDownloadFirmware field0;

  /// Create a copy of InboundRpc
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $InboundRpc_FirmwareDownloadCopyWith<InboundRpc_FirmwareDownload>
      get copyWith => _$InboundRpc_FirmwareDownloadCopyWithImpl<
          InboundRpc_FirmwareDownload>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is InboundRpc_FirmwareDownload &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'InboundRpc.firmwareDownload(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $InboundRpc_FirmwareDownloadCopyWith<$Res>
    implements $InboundRpcCopyWith<$Res> {
  factory $InboundRpc_FirmwareDownloadCopyWith(
          InboundRpc_FirmwareDownload value,
          $Res Function(InboundRpc_FirmwareDownload) _then) =
      _$InboundRpc_FirmwareDownloadCopyWithImpl;
  @useResult
  $Res call({InboundDownloadFirmware field0});
}

/// @nodoc
class _$InboundRpc_FirmwareDownloadCopyWithImpl<$Res>
    implements $InboundRpc_FirmwareDownloadCopyWith<$Res> {
  _$InboundRpc_FirmwareDownloadCopyWithImpl(this._self, this._then);

  final InboundRpc_FirmwareDownload _self;
  final $Res Function(InboundRpc_FirmwareDownload) _then;

  /// Create a copy of InboundRpc
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(InboundRpc_FirmwareDownload(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as InboundDownloadFirmware,
    ));
  }
}

/// @nodoc

class InboundRpc_ExchangeRateSubscription extends InboundRpc {
  const InboundRpc_ExchangeRateSubscription(this.field0) : super._();

  @override
  final InboundSubscribeExchangeRate field0;

  /// Create a copy of InboundRpc
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $InboundRpc_ExchangeRateSubscriptionCopyWith<
          InboundRpc_ExchangeRateSubscription>
      get copyWith => _$InboundRpc_ExchangeRateSubscriptionCopyWithImpl<
          InboundRpc_ExchangeRateSubscription>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is InboundRpc_ExchangeRateSubscription &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'InboundRpc.exchangeRateSubscription(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $InboundRpc_ExchangeRateSubscriptionCopyWith<$Res>
    implements $InboundRpcCopyWith<$Res> {
  factory $InboundRpc_ExchangeRateSubscriptionCopyWith(
          InboundRpc_ExchangeRateSubscription value,
          $Res Function(InboundRpc_ExchangeRateSubscription) _then) =
      _$InboundRpc_ExchangeRateSubscriptionCopyWithImpl;
  @useResult
  $Res call({InboundSubscribeExchangeRate field0});
}

/// @nodoc
class _$InboundRpc_ExchangeRateSubscriptionCopyWithImpl<$Res>
    implements $InboundRpc_ExchangeRateSubscriptionCopyWith<$Res> {
  _$InboundRpc_ExchangeRateSubscriptionCopyWithImpl(this._self, this._then);

  final InboundRpc_ExchangeRateSubscription _self;
  final $Res Function(InboundRpc_ExchangeRateSubscription) _then;

  /// Create a copy of InboundRpc
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(InboundRpc_ExchangeRateSubscription(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as InboundSubscribeExchangeRate,
    ));
  }
}

/// @nodoc

class InboundRpc_ExchangeRateHistory extends InboundRpc {
  const InboundRpc_ExchangeRateHistory(this.field0) : super._();

  @override
  final InboundRequestExchangeRateHistory field0;

  /// Create a copy of InboundRpc
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $InboundRpc_ExchangeRateHistoryCopyWith<InboundRpc_ExchangeRateHistory>
      get copyWith => _$InboundRpc_ExchangeRateHistoryCopyWithImpl<
          InboundRpc_ExchangeRateHistory>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is InboundRpc_ExchangeRateHistory &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'InboundRpc.exchangeRateHistory(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $InboundRpc_ExchangeRateHistoryCopyWith<$Res>
    implements $InboundRpcCopyWith<$Res> {
  factory $InboundRpc_ExchangeRateHistoryCopyWith(
          InboundRpc_ExchangeRateHistory value,
          $Res Function(InboundRpc_ExchangeRateHistory) _then) =
      _$InboundRpc_ExchangeRateHistoryCopyWithImpl;
  @useResult
  $Res call({InboundRequestExchangeRateHistory field0});
}

/// @nodoc
class _$InboundRpc_ExchangeRateHistoryCopyWithImpl<$Res>
    implements $InboundRpc_ExchangeRateHistoryCopyWith<$Res> {
  _$InboundRpc_ExchangeRateHistoryCopyWithImpl(this._self, this._then);

  final InboundRpc_ExchangeRateHistory _self;
  final $Res Function(InboundRpc_ExchangeRateHistory) _then;

  /// Create a copy of InboundRpc
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(InboundRpc_ExchangeRateHistory(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as InboundRequestExchangeRateHistory,
    ));
  }
}

/// @nodoc

class InboundRpc_CurrentTime extends InboundRpc {
  const InboundRpc_CurrentTime(this.field0) : super._();

  @override
  final InboundRequestCurrentTime field0;

  /// Create a copy of InboundRpc
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $InboundRpc_CurrentTimeCopyWith<InboundRpc_CurrentTime> get copyWith =>
      _$InboundRpc_CurrentTimeCopyWithImpl<InboundRpc_CurrentTime>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is InboundRpc_CurrentTime &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'InboundRpc.currentTime(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $InboundRpc_CurrentTimeCopyWith<$Res>
    implements $InboundRpcCopyWith<$Res> {
  factory $InboundRpc_CurrentTimeCopyWith(InboundRpc_CurrentTime value,
          $Res Function(InboundRpc_CurrentTime) _then) =
      _$InboundRpc_CurrentTimeCopyWithImpl;
  @useResult
  $Res call({InboundRequestCurrentTime field0});
}

/// @nodoc
class _$InboundRpc_CurrentTimeCopyWithImpl<$Res>
    implements $InboundRpc_CurrentTimeCopyWith<$Res> {
  _$InboundRpc_CurrentTimeCopyWithImpl(this._self, this._then);

  final InboundRpc_CurrentTime _self;
  final $Res Function(InboundRpc_CurrentTime) _then;

  /// Create a copy of InboundRpc
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(InboundRpc_CurrentTime(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as InboundRequestCurrentTime,
    ));
  }
}

/// @nodoc

class InboundRpc_BroadcastTransaction extends InboundRpc {
  const InboundRpc_BroadcastTransaction(this.field0) : super._();

  @override
  final InboundRequestBroadcastTransaction field0;

  /// Create a copy of InboundRpc
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $InboundRpc_BroadcastTransactionCopyWith<InboundRpc_BroadcastTransaction>
      get copyWith => _$InboundRpc_BroadcastTransactionCopyWithImpl<
          InboundRpc_BroadcastTransaction>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is InboundRpc_BroadcastTransaction &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'InboundRpc.broadcastTransaction(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $InboundRpc_BroadcastTransactionCopyWith<$Res>
    implements $InboundRpcCopyWith<$Res> {
  factory $InboundRpc_BroadcastTransactionCopyWith(
          InboundRpc_BroadcastTransaction value,
          $Res Function(InboundRpc_BroadcastTransaction) _then) =
      _$InboundRpc_BroadcastTransactionCopyWithImpl;
  @useResult
  $Res call({InboundRequestBroadcastTransaction field0});
}

/// @nodoc
class _$InboundRpc_BroadcastTransactionCopyWithImpl<$Res>
    implements $InboundRpc_BroadcastTransactionCopyWith<$Res> {
  _$InboundRpc_BroadcastTransactionCopyWithImpl(this._self, this._then);

  final InboundRpc_BroadcastTransaction _self;
  final $Res Function(InboundRpc_BroadcastTransaction) _then;

  /// Create a copy of InboundRpc
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(InboundRpc_BroadcastTransaction(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as InboundRequestBroadcastTransaction,
    ));
  }
}

/// @nodoc

class InboundRpc_BackupShard extends InboundRpc {
  const InboundRpc_BackupShard(this.field0) : super._();

  @override
  final InboundRequestBackupShard field0;

  /// Create a copy of InboundRpc
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $InboundRpc_BackupShardCopyWith<InboundRpc_BackupShard> get copyWith =>
      _$InboundRpc_BackupShardCopyWithImpl<InboundRpc_BackupShard>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is InboundRpc_BackupShard &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'InboundRpc.backupShard(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $InboundRpc_BackupShardCopyWith<$Res>
    implements $InboundRpcCopyWith<$Res> {
  factory $InboundRpc_BackupShardCopyWith(InboundRpc_BackupShard value,
          $Res Function(InboundRpc_BackupShard) _then) =
      _$InboundRpc_BackupShardCopyWithImpl;
  @useResult
  $Res call({InboundRequestBackupShard field0});
}

/// @nodoc
class _$InboundRpc_BackupShardCopyWithImpl<$Res>
    implements $InboundRpc_BackupShardCopyWith<$Res> {
  _$InboundRpc_BackupShardCopyWithImpl(this._self, this._then);

  final InboundRpc_BackupShard _self;
  final $Res Function(InboundRpc_BackupShard) _then;

  /// Create a copy of InboundRpc
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(InboundRpc_BackupShard(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as InboundRequestBackupShard,
    ));
  }
}

/// @nodoc

class InboundRpc_RestoreShard extends InboundRpc {
  const InboundRpc_RestoreShard(this.field0) : super._();

  @override
  final InboundRequestRestoreShard field0;

  /// Create a copy of InboundRpc
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $InboundRpc_RestoreShardCopyWith<InboundRpc_RestoreShard> get copyWith =>
      _$InboundRpc_RestoreShardCopyWithImpl<InboundRpc_RestoreShard>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is InboundRpc_RestoreShard &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'InboundRpc.restoreShard(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $InboundRpc_RestoreShardCopyWith<$Res>
    implements $InboundRpcCopyWith<$Res> {
  factory $InboundRpc_RestoreShardCopyWith(InboundRpc_RestoreShard value,
          $Res Function(InboundRpc_RestoreShard) _then) =
      _$InboundRpc_RestoreShardCopyWithImpl;
  @useResult
  $Res call({InboundRequestRestoreShard field0});
}

/// @nodoc
class _$InboundRpc_RestoreShardCopyWithImpl<$Res>
    implements $InboundRpc_RestoreShardCopyWith<$Res> {
  _$InboundRpc_RestoreShardCopyWithImpl(this._self, this._then);

  final InboundRpc_RestoreShard _self;
  final $Res Function(InboundRpc_RestoreShard) _then;

  /// Create a copy of InboundRpc
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(InboundRpc_RestoreShard(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as InboundRequestRestoreShard,
    ));
  }
}

/// @nodoc

class InboundRpc_PassportMagicBackupStatus extends InboundRpc {
  const InboundRpc_PassportMagicBackupStatus(this.field0) : super._();

  @override
  final InboundRequestPassportMagicBackupStatus field0;

  /// Create a copy of InboundRpc
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $InboundRpc_PassportMagicBackupStatusCopyWith<
          InboundRpc_PassportMagicBackupStatus>
      get copyWith => _$InboundRpc_PassportMagicBackupStatusCopyWithImpl<
          InboundRpc_PassportMagicBackupStatus>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is InboundRpc_PassportMagicBackupStatus &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'InboundRpc.passportMagicBackupStatus(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $InboundRpc_PassportMagicBackupStatusCopyWith<$Res>
    implements $InboundRpcCopyWith<$Res> {
  factory $InboundRpc_PassportMagicBackupStatusCopyWith(
          InboundRpc_PassportMagicBackupStatus value,
          $Res Function(InboundRpc_PassportMagicBackupStatus) _then) =
      _$InboundRpc_PassportMagicBackupStatusCopyWithImpl;
  @useResult
  $Res call({InboundRequestPassportMagicBackupStatus field0});
}

/// @nodoc
class _$InboundRpc_PassportMagicBackupStatusCopyWithImpl<$Res>
    implements $InboundRpc_PassportMagicBackupStatusCopyWith<$Res> {
  _$InboundRpc_PassportMagicBackupStatusCopyWithImpl(this._self, this._then);

  final InboundRpc_PassportMagicBackupStatus _self;
  final $Res Function(InboundRpc_PassportMagicBackupStatus) _then;

  /// Create a copy of InboundRpc
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(InboundRpc_PassportMagicBackupStatus(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as InboundRequestPassportMagicBackupStatus,
    ));
  }
}

/// @nodoc

class InboundRpc_UploadMagicBackup extends InboundRpc {
  const InboundRpc_UploadMagicBackup(this.field0) : super._();

  @override
  final InboundUploadMagicBackup field0;

  /// Create a copy of InboundRpc
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $InboundRpc_UploadMagicBackupCopyWith<InboundRpc_UploadMagicBackup>
      get copyWith => _$InboundRpc_UploadMagicBackupCopyWithImpl<
          InboundRpc_UploadMagicBackup>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is InboundRpc_UploadMagicBackup &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'InboundRpc.uploadMagicBackup(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $InboundRpc_UploadMagicBackupCopyWith<$Res>
    implements $InboundRpcCopyWith<$Res> {
  factory $InboundRpc_UploadMagicBackupCopyWith(
          InboundRpc_UploadMagicBackup value,
          $Res Function(InboundRpc_UploadMagicBackup) _then) =
      _$InboundRpc_UploadMagicBackupCopyWithImpl;
  @useResult
  $Res call({InboundUploadMagicBackup field0});
}

/// @nodoc
class _$InboundRpc_UploadMagicBackupCopyWithImpl<$Res>
    implements $InboundRpc_UploadMagicBackupCopyWith<$Res> {
  _$InboundRpc_UploadMagicBackupCopyWithImpl(this._self, this._then);

  final InboundRpc_UploadMagicBackup _self;
  final $Res Function(InboundRpc_UploadMagicBackup) _then;

  /// Create a copy of InboundRpc
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(InboundRpc_UploadMagicBackup(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as InboundUploadMagicBackup,
    ));
  }
}

/// @nodoc

class InboundRpc_DownloadMagicBackup extends InboundRpc {
  const InboundRpc_DownloadMagicBackup(this.field0) : super._();

  @override
  final InboundDownloadMagicBackup field0;

  /// Create a copy of InboundRpc
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $InboundRpc_DownloadMagicBackupCopyWith<InboundRpc_DownloadMagicBackup>
      get copyWith => _$InboundRpc_DownloadMagicBackupCopyWithImpl<
          InboundRpc_DownloadMagicBackup>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is InboundRpc_DownloadMagicBackup &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'InboundRpc.downloadMagicBackup(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $InboundRpc_DownloadMagicBackupCopyWith<$Res>
    implements $InboundRpcCopyWith<$Res> {
  factory $InboundRpc_DownloadMagicBackupCopyWith(
          InboundRpc_DownloadMagicBackup value,
          $Res Function(InboundRpc_DownloadMagicBackup) _then) =
      _$InboundRpc_DownloadMagicBackupCopyWithImpl;
  @useResult
  $Res call({InboundDownloadMagicBackup field0});
}

/// @nodoc
class _$InboundRpc_DownloadMagicBackupCopyWithImpl<$Res>
    implements $InboundRpc_DownloadMagicBackupCopyWith<$Res> {
  _$InboundRpc_DownloadMagicBackupCopyWithImpl(this._self, this._then);

  final InboundRpc_DownloadMagicBackup _self;
  final $Res Function(InboundRpc_DownloadMagicBackup) _then;

  /// Create a copy of InboundRpc
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(InboundRpc_DownloadMagicBackup(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as InboundDownloadMagicBackup,
    ));
  }
}

/// @nodoc

class InboundRpc_Echo extends InboundRpc {
  const InboundRpc_Echo(this.field0) : super._();

  @override
  final InboundRequestEcho field0;

  /// Create a copy of InboundRpc
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $InboundRpc_EchoCopyWith<InboundRpc_Echo> get copyWith =>
      _$InboundRpc_EchoCopyWithImpl<InboundRpc_Echo>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is InboundRpc_Echo &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'InboundRpc.echo(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $InboundRpc_EchoCopyWith<$Res>
    implements $InboundRpcCopyWith<$Res> {
  factory $InboundRpc_EchoCopyWith(
          InboundRpc_Echo value, $Res Function(InboundRpc_Echo) _then) =
      _$InboundRpc_EchoCopyWithImpl;
  @useResult
  $Res call({InboundRequestEcho field0});
}

/// @nodoc
class _$InboundRpc_EchoCopyWithImpl<$Res>
    implements $InboundRpc_EchoCopyWith<$Res> {
  _$InboundRpc_EchoCopyWithImpl(this._self, this._then);

  final InboundRpc_Echo _self;
  final $Res Function(InboundRpc_Echo) _then;

  /// Create a copy of InboundRpc
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(InboundRpc_Echo(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as InboundRequestEcho,
    ));
  }
}

/// @nodoc

class InboundRpc_DownloadBenchmark extends InboundRpc {
  const InboundRpc_DownloadBenchmark(this.field0) : super._();

  @override
  final InboundDownloadBenchmark field0;

  /// Create a copy of InboundRpc
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $InboundRpc_DownloadBenchmarkCopyWith<InboundRpc_DownloadBenchmark>
      get copyWith => _$InboundRpc_DownloadBenchmarkCopyWithImpl<
          InboundRpc_DownloadBenchmark>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is InboundRpc_DownloadBenchmark &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'InboundRpc.downloadBenchmark(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $InboundRpc_DownloadBenchmarkCopyWith<$Res>
    implements $InboundRpcCopyWith<$Res> {
  factory $InboundRpc_DownloadBenchmarkCopyWith(
          InboundRpc_DownloadBenchmark value,
          $Res Function(InboundRpc_DownloadBenchmark) _then) =
      _$InboundRpc_DownloadBenchmarkCopyWithImpl;
  @useResult
  $Res call({InboundDownloadBenchmark field0});
}

/// @nodoc
class _$InboundRpc_DownloadBenchmarkCopyWithImpl<$Res>
    implements $InboundRpc_DownloadBenchmarkCopyWith<$Res> {
  _$InboundRpc_DownloadBenchmarkCopyWithImpl(this._self, this._then);

  final InboundRpc_DownloadBenchmark _self;
  final $Res Function(InboundRpc_DownloadBenchmark) _then;

  /// Create a copy of InboundRpc
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(InboundRpc_DownloadBenchmark(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as InboundDownloadBenchmark,
    ));
  }
}

// dart format on
