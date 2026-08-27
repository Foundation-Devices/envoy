// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$QuantumLinkMessage {
  Object get field0;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is QuantumLinkMessage &&
            const DeepCollectionEquality().equals(other.field0, field0));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(field0));

  @override
  String toString() {
    return 'QuantumLinkMessage(field0: $field0)';
  }
}

/// @nodoc
class $QuantumLinkMessageCopyWith<$Res> {
  $QuantumLinkMessageCopyWith(
      QuantumLinkMessage _, $Res Function(QuantumLinkMessage) __);
}

/// Adds pattern-matching-related methods to [QuantumLinkMessage].
extension QuantumLinkMessagePatterns on QuantumLinkMessage {
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
    TResult Function(QuantumLinkMessage_ExchangeRate value)? exchangeRate,
    TResult Function(QuantumLinkMessage_ExchangeRateHistory value)?
        exchangeRateHistory,
    TResult Function(QuantumLinkMessage_FirmwareUpdateCheckRequest value)?
        firmwareUpdateCheckRequest,
    TResult Function(QuantumLinkMessage_FirmwareUpdateCheckResponse value)?
        firmwareUpdateCheckResponse,
    TResult Function(QuantumLinkMessage_FirmwareFetchRequest value)?
        firmwareFetchRequest,
    TResult Function(QuantumLinkMessage_FirmwareFetchEvent value)?
        firmwareFetchEvent,
    TResult Function(QuantumLinkMessage_FirmwareInstallEvent value)?
        firmwareInstallEvent,
    TResult Function(QuantumLinkMessage_DeviceStatus value)? deviceStatus,
    TResult Function(QuantumLinkMessage_EnvoyStatus value)? envoyStatus,
    TResult Function(QuantumLinkMessage_PairingRequest value)? pairingRequest,
    TResult Function(QuantumLinkMessage_PairingResponse value)? pairingResponse,
    TResult Function(QuantumLinkMessage_SecurityCheck value)? securityCheck,
    TResult Function(QuantumLinkMessage_OnboardingState value)? onboardingState,
    TResult Function(QuantumLinkMessage_SignPsbt value)? signPsbt,
    TResult Function(QuantumLinkMessage_BroadcastTransaction value)?
        broadcastTransaction,
    TResult Function(QuantumLinkMessage_AccountUpdate value)? accountUpdate,
    TResult Function(QuantumLinkMessage_ApplyPassphrase value)? applyPassphrase,
    TResult Function(QuantumLinkMessage_EnvoyMagicBackupEnabledRequest value)?
        envoyMagicBackupEnabledRequest,
    TResult Function(QuantumLinkMessage_EnvoyMagicBackupEnabledResponse value)?
        envoyMagicBackupEnabledResponse,
    TResult Function(QuantumLinkMessage_PrimeMagicBackupEnabled value)?
        primeMagicBackupEnabled,
    TResult Function(QuantumLinkMessage_PrimeMagicBackupStatusRequest value)?
        primeMagicBackupStatusRequest,
    TResult Function(QuantumLinkMessage_PrimeMagicBackupStatusResponse value)?
        primeMagicBackupStatusResponse,
    TResult Function(QuantumLinkMessage_BackupShardRequest value)?
        backupShardRequest,
    TResult Function(QuantumLinkMessage_BackupShardResponse value)?
        backupShardResponse,
    TResult Function(QuantumLinkMessage_RestoreShardRequest value)?
        restoreShardRequest,
    TResult Function(QuantumLinkMessage_RestoreShardResponse value)?
        restoreShardResponse,
    TResult Function(QuantumLinkMessage_CreateMagicBackupEvent value)?
        createMagicBackupEvent,
    TResult Function(QuantumLinkMessage_CreateMagicBackupResult value)?
        createMagicBackupResult,
    TResult Function(QuantumLinkMessage_RestoreMagicBackupRequest value)?
        restoreMagicBackupRequest,
    TResult Function(QuantumLinkMessage_RestoreMagicBackupEvent value)?
        restoreMagicBackupEvent,
    TResult Function(QuantumLinkMessage_RestoreMagicBackupResult value)?
        restoreMagicBackupResult,
    TResult Function(QuantumLinkMessage_Heartbeat value)? heartbeat,
    TResult Function(QuantumLinkMessage_TimezoneRequest value)? timezoneRequest,
    TResult Function(QuantumLinkMessage_TimezoneResponse value)?
        timezoneResponse,
    TResult Function(QuantumLinkMessage_UnpairingRequest value)?
        unpairingRequest,
    TResult Function(QuantumLinkMessage_UnpairingResponse value)?
        unpairingResponse,
    TResult Function(QuantumLinkMessage_DeviceNameUpdate value)?
        deviceNameUpdate,
    TResult Function(QuantumLinkMessage_MagicBackupRequestV2 value)?
        magicBackupRequestV2,
    TResult Function(QuantumLinkMessage_MagicBackupResponseV2 value)?
        magicBackupResponseV2,
    TResult Function(QuantumLinkMessage_PrimeFiatPreference value)?
        primeFiatPreference,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case QuantumLinkMessage_ExchangeRate() when exchangeRate != null:
        return exchangeRate(_that);
      case QuantumLinkMessage_ExchangeRateHistory()
          when exchangeRateHistory != null:
        return exchangeRateHistory(_that);
      case QuantumLinkMessage_FirmwareUpdateCheckRequest()
          when firmwareUpdateCheckRequest != null:
        return firmwareUpdateCheckRequest(_that);
      case QuantumLinkMessage_FirmwareUpdateCheckResponse()
          when firmwareUpdateCheckResponse != null:
        return firmwareUpdateCheckResponse(_that);
      case QuantumLinkMessage_FirmwareFetchRequest()
          when firmwareFetchRequest != null:
        return firmwareFetchRequest(_that);
      case QuantumLinkMessage_FirmwareFetchEvent()
          when firmwareFetchEvent != null:
        return firmwareFetchEvent(_that);
      case QuantumLinkMessage_FirmwareInstallEvent()
          when firmwareInstallEvent != null:
        return firmwareInstallEvent(_that);
      case QuantumLinkMessage_DeviceStatus() when deviceStatus != null:
        return deviceStatus(_that);
      case QuantumLinkMessage_EnvoyStatus() when envoyStatus != null:
        return envoyStatus(_that);
      case QuantumLinkMessage_PairingRequest() when pairingRequest != null:
        return pairingRequest(_that);
      case QuantumLinkMessage_PairingResponse() when pairingResponse != null:
        return pairingResponse(_that);
      case QuantumLinkMessage_SecurityCheck() when securityCheck != null:
        return securityCheck(_that);
      case QuantumLinkMessage_OnboardingState() when onboardingState != null:
        return onboardingState(_that);
      case QuantumLinkMessage_SignPsbt() when signPsbt != null:
        return signPsbt(_that);
      case QuantumLinkMessage_BroadcastTransaction()
          when broadcastTransaction != null:
        return broadcastTransaction(_that);
      case QuantumLinkMessage_AccountUpdate() when accountUpdate != null:
        return accountUpdate(_that);
      case QuantumLinkMessage_ApplyPassphrase() when applyPassphrase != null:
        return applyPassphrase(_that);
      case QuantumLinkMessage_EnvoyMagicBackupEnabledRequest()
          when envoyMagicBackupEnabledRequest != null:
        return envoyMagicBackupEnabledRequest(_that);
      case QuantumLinkMessage_EnvoyMagicBackupEnabledResponse()
          when envoyMagicBackupEnabledResponse != null:
        return envoyMagicBackupEnabledResponse(_that);
      case QuantumLinkMessage_PrimeMagicBackupEnabled()
          when primeMagicBackupEnabled != null:
        return primeMagicBackupEnabled(_that);
      case QuantumLinkMessage_PrimeMagicBackupStatusRequest()
          when primeMagicBackupStatusRequest != null:
        return primeMagicBackupStatusRequest(_that);
      case QuantumLinkMessage_PrimeMagicBackupStatusResponse()
          when primeMagicBackupStatusResponse != null:
        return primeMagicBackupStatusResponse(_that);
      case QuantumLinkMessage_BackupShardRequest()
          when backupShardRequest != null:
        return backupShardRequest(_that);
      case QuantumLinkMessage_BackupShardResponse()
          when backupShardResponse != null:
        return backupShardResponse(_that);
      case QuantumLinkMessage_RestoreShardRequest()
          when restoreShardRequest != null:
        return restoreShardRequest(_that);
      case QuantumLinkMessage_RestoreShardResponse()
          when restoreShardResponse != null:
        return restoreShardResponse(_that);
      case QuantumLinkMessage_CreateMagicBackupEvent()
          when createMagicBackupEvent != null:
        return createMagicBackupEvent(_that);
      case QuantumLinkMessage_CreateMagicBackupResult()
          when createMagicBackupResult != null:
        return createMagicBackupResult(_that);
      case QuantumLinkMessage_RestoreMagicBackupRequest()
          when restoreMagicBackupRequest != null:
        return restoreMagicBackupRequest(_that);
      case QuantumLinkMessage_RestoreMagicBackupEvent()
          when restoreMagicBackupEvent != null:
        return restoreMagicBackupEvent(_that);
      case QuantumLinkMessage_RestoreMagicBackupResult()
          when restoreMagicBackupResult != null:
        return restoreMagicBackupResult(_that);
      case QuantumLinkMessage_Heartbeat() when heartbeat != null:
        return heartbeat(_that);
      case QuantumLinkMessage_TimezoneRequest() when timezoneRequest != null:
        return timezoneRequest(_that);
      case QuantumLinkMessage_TimezoneResponse() when timezoneResponse != null:
        return timezoneResponse(_that);
      case QuantumLinkMessage_UnpairingRequest() when unpairingRequest != null:
        return unpairingRequest(_that);
      case QuantumLinkMessage_UnpairingResponse()
          when unpairingResponse != null:
        return unpairingResponse(_that);
      case QuantumLinkMessage_DeviceNameUpdate() when deviceNameUpdate != null:
        return deviceNameUpdate(_that);
      case QuantumLinkMessage_MagicBackupRequestV2()
          when magicBackupRequestV2 != null:
        return magicBackupRequestV2(_that);
      case QuantumLinkMessage_MagicBackupResponseV2()
          when magicBackupResponseV2 != null:
        return magicBackupResponseV2(_that);
      case QuantumLinkMessage_PrimeFiatPreference()
          when primeFiatPreference != null:
        return primeFiatPreference(_that);
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
    required TResult Function(QuantumLinkMessage_ExchangeRate value)
        exchangeRate,
    required TResult Function(QuantumLinkMessage_ExchangeRateHistory value)
        exchangeRateHistory,
    required TResult Function(
            QuantumLinkMessage_FirmwareUpdateCheckRequest value)
        firmwareUpdateCheckRequest,
    required TResult Function(
            QuantumLinkMessage_FirmwareUpdateCheckResponse value)
        firmwareUpdateCheckResponse,
    required TResult Function(QuantumLinkMessage_FirmwareFetchRequest value)
        firmwareFetchRequest,
    required TResult Function(QuantumLinkMessage_FirmwareFetchEvent value)
        firmwareFetchEvent,
    required TResult Function(QuantumLinkMessage_FirmwareInstallEvent value)
        firmwareInstallEvent,
    required TResult Function(QuantumLinkMessage_DeviceStatus value)
        deviceStatus,
    required TResult Function(QuantumLinkMessage_EnvoyStatus value) envoyStatus,
    required TResult Function(QuantumLinkMessage_PairingRequest value)
        pairingRequest,
    required TResult Function(QuantumLinkMessage_PairingResponse value)
        pairingResponse,
    required TResult Function(QuantumLinkMessage_SecurityCheck value)
        securityCheck,
    required TResult Function(QuantumLinkMessage_OnboardingState value)
        onboardingState,
    required TResult Function(QuantumLinkMessage_SignPsbt value) signPsbt,
    required TResult Function(QuantumLinkMessage_BroadcastTransaction value)
        broadcastTransaction,
    required TResult Function(QuantumLinkMessage_AccountUpdate value)
        accountUpdate,
    required TResult Function(QuantumLinkMessage_ApplyPassphrase value)
        applyPassphrase,
    required TResult Function(
            QuantumLinkMessage_EnvoyMagicBackupEnabledRequest value)
        envoyMagicBackupEnabledRequest,
    required TResult Function(
            QuantumLinkMessage_EnvoyMagicBackupEnabledResponse value)
        envoyMagicBackupEnabledResponse,
    required TResult Function(QuantumLinkMessage_PrimeMagicBackupEnabled value)
        primeMagicBackupEnabled,
    required TResult Function(
            QuantumLinkMessage_PrimeMagicBackupStatusRequest value)
        primeMagicBackupStatusRequest,
    required TResult Function(
            QuantumLinkMessage_PrimeMagicBackupStatusResponse value)
        primeMagicBackupStatusResponse,
    required TResult Function(QuantumLinkMessage_BackupShardRequest value)
        backupShardRequest,
    required TResult Function(QuantumLinkMessage_BackupShardResponse value)
        backupShardResponse,
    required TResult Function(QuantumLinkMessage_RestoreShardRequest value)
        restoreShardRequest,
    required TResult Function(QuantumLinkMessage_RestoreShardResponse value)
        restoreShardResponse,
    required TResult Function(QuantumLinkMessage_CreateMagicBackupEvent value)
        createMagicBackupEvent,
    required TResult Function(QuantumLinkMessage_CreateMagicBackupResult value)
        createMagicBackupResult,
    required TResult Function(
            QuantumLinkMessage_RestoreMagicBackupRequest value)
        restoreMagicBackupRequest,
    required TResult Function(QuantumLinkMessage_RestoreMagicBackupEvent value)
        restoreMagicBackupEvent,
    required TResult Function(QuantumLinkMessage_RestoreMagicBackupResult value)
        restoreMagicBackupResult,
    required TResult Function(QuantumLinkMessage_Heartbeat value) heartbeat,
    required TResult Function(QuantumLinkMessage_TimezoneRequest value)
        timezoneRequest,
    required TResult Function(QuantumLinkMessage_TimezoneResponse value)
        timezoneResponse,
    required TResult Function(QuantumLinkMessage_UnpairingRequest value)
        unpairingRequest,
    required TResult Function(QuantumLinkMessage_UnpairingResponse value)
        unpairingResponse,
    required TResult Function(QuantumLinkMessage_DeviceNameUpdate value)
        deviceNameUpdate,
    required TResult Function(QuantumLinkMessage_MagicBackupRequestV2 value)
        magicBackupRequestV2,
    required TResult Function(QuantumLinkMessage_MagicBackupResponseV2 value)
        magicBackupResponseV2,
    required TResult Function(QuantumLinkMessage_PrimeFiatPreference value)
        primeFiatPreference,
  }) {
    final _that = this;
    switch (_that) {
      case QuantumLinkMessage_ExchangeRate():
        return exchangeRate(_that);
      case QuantumLinkMessage_ExchangeRateHistory():
        return exchangeRateHistory(_that);
      case QuantumLinkMessage_FirmwareUpdateCheckRequest():
        return firmwareUpdateCheckRequest(_that);
      case QuantumLinkMessage_FirmwareUpdateCheckResponse():
        return firmwareUpdateCheckResponse(_that);
      case QuantumLinkMessage_FirmwareFetchRequest():
        return firmwareFetchRequest(_that);
      case QuantumLinkMessage_FirmwareFetchEvent():
        return firmwareFetchEvent(_that);
      case QuantumLinkMessage_FirmwareInstallEvent():
        return firmwareInstallEvent(_that);
      case QuantumLinkMessage_DeviceStatus():
        return deviceStatus(_that);
      case QuantumLinkMessage_EnvoyStatus():
        return envoyStatus(_that);
      case QuantumLinkMessage_PairingRequest():
        return pairingRequest(_that);
      case QuantumLinkMessage_PairingResponse():
        return pairingResponse(_that);
      case QuantumLinkMessage_SecurityCheck():
        return securityCheck(_that);
      case QuantumLinkMessage_OnboardingState():
        return onboardingState(_that);
      case QuantumLinkMessage_SignPsbt():
        return signPsbt(_that);
      case QuantumLinkMessage_BroadcastTransaction():
        return broadcastTransaction(_that);
      case QuantumLinkMessage_AccountUpdate():
        return accountUpdate(_that);
      case QuantumLinkMessage_ApplyPassphrase():
        return applyPassphrase(_that);
      case QuantumLinkMessage_EnvoyMagicBackupEnabledRequest():
        return envoyMagicBackupEnabledRequest(_that);
      case QuantumLinkMessage_EnvoyMagicBackupEnabledResponse():
        return envoyMagicBackupEnabledResponse(_that);
      case QuantumLinkMessage_PrimeMagicBackupEnabled():
        return primeMagicBackupEnabled(_that);
      case QuantumLinkMessage_PrimeMagicBackupStatusRequest():
        return primeMagicBackupStatusRequest(_that);
      case QuantumLinkMessage_PrimeMagicBackupStatusResponse():
        return primeMagicBackupStatusResponse(_that);
      case QuantumLinkMessage_BackupShardRequest():
        return backupShardRequest(_that);
      case QuantumLinkMessage_BackupShardResponse():
        return backupShardResponse(_that);
      case QuantumLinkMessage_RestoreShardRequest():
        return restoreShardRequest(_that);
      case QuantumLinkMessage_RestoreShardResponse():
        return restoreShardResponse(_that);
      case QuantumLinkMessage_CreateMagicBackupEvent():
        return createMagicBackupEvent(_that);
      case QuantumLinkMessage_CreateMagicBackupResult():
        return createMagicBackupResult(_that);
      case QuantumLinkMessage_RestoreMagicBackupRequest():
        return restoreMagicBackupRequest(_that);
      case QuantumLinkMessage_RestoreMagicBackupEvent():
        return restoreMagicBackupEvent(_that);
      case QuantumLinkMessage_RestoreMagicBackupResult():
        return restoreMagicBackupResult(_that);
      case QuantumLinkMessage_Heartbeat():
        return heartbeat(_that);
      case QuantumLinkMessage_TimezoneRequest():
        return timezoneRequest(_that);
      case QuantumLinkMessage_TimezoneResponse():
        return timezoneResponse(_that);
      case QuantumLinkMessage_UnpairingRequest():
        return unpairingRequest(_that);
      case QuantumLinkMessage_UnpairingResponse():
        return unpairingResponse(_that);
      case QuantumLinkMessage_DeviceNameUpdate():
        return deviceNameUpdate(_that);
      case QuantumLinkMessage_MagicBackupRequestV2():
        return magicBackupRequestV2(_that);
      case QuantumLinkMessage_MagicBackupResponseV2():
        return magicBackupResponseV2(_that);
      case QuantumLinkMessage_PrimeFiatPreference():
        return primeFiatPreference(_that);
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
    TResult? Function(QuantumLinkMessage_ExchangeRate value)? exchangeRate,
    TResult? Function(QuantumLinkMessage_ExchangeRateHistory value)?
        exchangeRateHistory,
    TResult? Function(QuantumLinkMessage_FirmwareUpdateCheckRequest value)?
        firmwareUpdateCheckRequest,
    TResult? Function(QuantumLinkMessage_FirmwareUpdateCheckResponse value)?
        firmwareUpdateCheckResponse,
    TResult? Function(QuantumLinkMessage_FirmwareFetchRequest value)?
        firmwareFetchRequest,
    TResult? Function(QuantumLinkMessage_FirmwareFetchEvent value)?
        firmwareFetchEvent,
    TResult? Function(QuantumLinkMessage_FirmwareInstallEvent value)?
        firmwareInstallEvent,
    TResult? Function(QuantumLinkMessage_DeviceStatus value)? deviceStatus,
    TResult? Function(QuantumLinkMessage_EnvoyStatus value)? envoyStatus,
    TResult? Function(QuantumLinkMessage_PairingRequest value)? pairingRequest,
    TResult? Function(QuantumLinkMessage_PairingResponse value)?
        pairingResponse,
    TResult? Function(QuantumLinkMessage_SecurityCheck value)? securityCheck,
    TResult? Function(QuantumLinkMessage_OnboardingState value)?
        onboardingState,
    TResult? Function(QuantumLinkMessage_SignPsbt value)? signPsbt,
    TResult? Function(QuantumLinkMessage_BroadcastTransaction value)?
        broadcastTransaction,
    TResult? Function(QuantumLinkMessage_AccountUpdate value)? accountUpdate,
    TResult? Function(QuantumLinkMessage_ApplyPassphrase value)?
        applyPassphrase,
    TResult? Function(QuantumLinkMessage_EnvoyMagicBackupEnabledRequest value)?
        envoyMagicBackupEnabledRequest,
    TResult? Function(QuantumLinkMessage_EnvoyMagicBackupEnabledResponse value)?
        envoyMagicBackupEnabledResponse,
    TResult? Function(QuantumLinkMessage_PrimeMagicBackupEnabled value)?
        primeMagicBackupEnabled,
    TResult? Function(QuantumLinkMessage_PrimeMagicBackupStatusRequest value)?
        primeMagicBackupStatusRequest,
    TResult? Function(QuantumLinkMessage_PrimeMagicBackupStatusResponse value)?
        primeMagicBackupStatusResponse,
    TResult? Function(QuantumLinkMessage_BackupShardRequest value)?
        backupShardRequest,
    TResult? Function(QuantumLinkMessage_BackupShardResponse value)?
        backupShardResponse,
    TResult? Function(QuantumLinkMessage_RestoreShardRequest value)?
        restoreShardRequest,
    TResult? Function(QuantumLinkMessage_RestoreShardResponse value)?
        restoreShardResponse,
    TResult? Function(QuantumLinkMessage_CreateMagicBackupEvent value)?
        createMagicBackupEvent,
    TResult? Function(QuantumLinkMessage_CreateMagicBackupResult value)?
        createMagicBackupResult,
    TResult? Function(QuantumLinkMessage_RestoreMagicBackupRequest value)?
        restoreMagicBackupRequest,
    TResult? Function(QuantumLinkMessage_RestoreMagicBackupEvent value)?
        restoreMagicBackupEvent,
    TResult? Function(QuantumLinkMessage_RestoreMagicBackupResult value)?
        restoreMagicBackupResult,
    TResult? Function(QuantumLinkMessage_Heartbeat value)? heartbeat,
    TResult? Function(QuantumLinkMessage_TimezoneRequest value)?
        timezoneRequest,
    TResult? Function(QuantumLinkMessage_TimezoneResponse value)?
        timezoneResponse,
    TResult? Function(QuantumLinkMessage_UnpairingRequest value)?
        unpairingRequest,
    TResult? Function(QuantumLinkMessage_UnpairingResponse value)?
        unpairingResponse,
    TResult? Function(QuantumLinkMessage_DeviceNameUpdate value)?
        deviceNameUpdate,
    TResult? Function(QuantumLinkMessage_MagicBackupRequestV2 value)?
        magicBackupRequestV2,
    TResult? Function(QuantumLinkMessage_MagicBackupResponseV2 value)?
        magicBackupResponseV2,
    TResult? Function(QuantumLinkMessage_PrimeFiatPreference value)?
        primeFiatPreference,
  }) {
    final _that = this;
    switch (_that) {
      case QuantumLinkMessage_ExchangeRate() when exchangeRate != null:
        return exchangeRate(_that);
      case QuantumLinkMessage_ExchangeRateHistory()
          when exchangeRateHistory != null:
        return exchangeRateHistory(_that);
      case QuantumLinkMessage_FirmwareUpdateCheckRequest()
          when firmwareUpdateCheckRequest != null:
        return firmwareUpdateCheckRequest(_that);
      case QuantumLinkMessage_FirmwareUpdateCheckResponse()
          when firmwareUpdateCheckResponse != null:
        return firmwareUpdateCheckResponse(_that);
      case QuantumLinkMessage_FirmwareFetchRequest()
          when firmwareFetchRequest != null:
        return firmwareFetchRequest(_that);
      case QuantumLinkMessage_FirmwareFetchEvent()
          when firmwareFetchEvent != null:
        return firmwareFetchEvent(_that);
      case QuantumLinkMessage_FirmwareInstallEvent()
          when firmwareInstallEvent != null:
        return firmwareInstallEvent(_that);
      case QuantumLinkMessage_DeviceStatus() when deviceStatus != null:
        return deviceStatus(_that);
      case QuantumLinkMessage_EnvoyStatus() when envoyStatus != null:
        return envoyStatus(_that);
      case QuantumLinkMessage_PairingRequest() when pairingRequest != null:
        return pairingRequest(_that);
      case QuantumLinkMessage_PairingResponse() when pairingResponse != null:
        return pairingResponse(_that);
      case QuantumLinkMessage_SecurityCheck() when securityCheck != null:
        return securityCheck(_that);
      case QuantumLinkMessage_OnboardingState() when onboardingState != null:
        return onboardingState(_that);
      case QuantumLinkMessage_SignPsbt() when signPsbt != null:
        return signPsbt(_that);
      case QuantumLinkMessage_BroadcastTransaction()
          when broadcastTransaction != null:
        return broadcastTransaction(_that);
      case QuantumLinkMessage_AccountUpdate() when accountUpdate != null:
        return accountUpdate(_that);
      case QuantumLinkMessage_ApplyPassphrase() when applyPassphrase != null:
        return applyPassphrase(_that);
      case QuantumLinkMessage_EnvoyMagicBackupEnabledRequest()
          when envoyMagicBackupEnabledRequest != null:
        return envoyMagicBackupEnabledRequest(_that);
      case QuantumLinkMessage_EnvoyMagicBackupEnabledResponse()
          when envoyMagicBackupEnabledResponse != null:
        return envoyMagicBackupEnabledResponse(_that);
      case QuantumLinkMessage_PrimeMagicBackupEnabled()
          when primeMagicBackupEnabled != null:
        return primeMagicBackupEnabled(_that);
      case QuantumLinkMessage_PrimeMagicBackupStatusRequest()
          when primeMagicBackupStatusRequest != null:
        return primeMagicBackupStatusRequest(_that);
      case QuantumLinkMessage_PrimeMagicBackupStatusResponse()
          when primeMagicBackupStatusResponse != null:
        return primeMagicBackupStatusResponse(_that);
      case QuantumLinkMessage_BackupShardRequest()
          when backupShardRequest != null:
        return backupShardRequest(_that);
      case QuantumLinkMessage_BackupShardResponse()
          when backupShardResponse != null:
        return backupShardResponse(_that);
      case QuantumLinkMessage_RestoreShardRequest()
          when restoreShardRequest != null:
        return restoreShardRequest(_that);
      case QuantumLinkMessage_RestoreShardResponse()
          when restoreShardResponse != null:
        return restoreShardResponse(_that);
      case QuantumLinkMessage_CreateMagicBackupEvent()
          when createMagicBackupEvent != null:
        return createMagicBackupEvent(_that);
      case QuantumLinkMessage_CreateMagicBackupResult()
          when createMagicBackupResult != null:
        return createMagicBackupResult(_that);
      case QuantumLinkMessage_RestoreMagicBackupRequest()
          when restoreMagicBackupRequest != null:
        return restoreMagicBackupRequest(_that);
      case QuantumLinkMessage_RestoreMagicBackupEvent()
          when restoreMagicBackupEvent != null:
        return restoreMagicBackupEvent(_that);
      case QuantumLinkMessage_RestoreMagicBackupResult()
          when restoreMagicBackupResult != null:
        return restoreMagicBackupResult(_that);
      case QuantumLinkMessage_Heartbeat() when heartbeat != null:
        return heartbeat(_that);
      case QuantumLinkMessage_TimezoneRequest() when timezoneRequest != null:
        return timezoneRequest(_that);
      case QuantumLinkMessage_TimezoneResponse() when timezoneResponse != null:
        return timezoneResponse(_that);
      case QuantumLinkMessage_UnpairingRequest() when unpairingRequest != null:
        return unpairingRequest(_that);
      case QuantumLinkMessage_UnpairingResponse()
          when unpairingResponse != null:
        return unpairingResponse(_that);
      case QuantumLinkMessage_DeviceNameUpdate() when deviceNameUpdate != null:
        return deviceNameUpdate(_that);
      case QuantumLinkMessage_MagicBackupRequestV2()
          when magicBackupRequestV2 != null:
        return magicBackupRequestV2(_that);
      case QuantumLinkMessage_MagicBackupResponseV2()
          when magicBackupResponseV2 != null:
        return magicBackupResponseV2(_that);
      case QuantumLinkMessage_PrimeFiatPreference()
          when primeFiatPreference != null:
        return primeFiatPreference(_that);
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
    TResult Function(ExchangeRate field0)? exchangeRate,
    TResult Function(ExchangeRateHistory field0)? exchangeRateHistory,
    TResult Function(FirmwareUpdateCheckRequest field0)?
        firmwareUpdateCheckRequest,
    TResult Function(FirmwareUpdateCheckResponse field0)?
        firmwareUpdateCheckResponse,
    TResult Function(FirmwareFetchRequest field0)? firmwareFetchRequest,
    TResult Function(FirmwareFetchEvent field0)? firmwareFetchEvent,
    TResult Function(FirmwareInstallEvent field0)? firmwareInstallEvent,
    TResult Function(DeviceStatus field0)? deviceStatus,
    TResult Function(EnvoyStatus field0)? envoyStatus,
    TResult Function(PairingRequest field0)? pairingRequest,
    TResult Function(PairingResponse field0)? pairingResponse,
    TResult Function(SecurityCheck field0)? securityCheck,
    TResult Function(OnboardingState field0)? onboardingState,
    TResult Function(SignPsbt field0)? signPsbt,
    TResult Function(BroadcastTransaction field0)? broadcastTransaction,
    TResult Function(AccountUpdate field0)? accountUpdate,
    TResult Function(ApplyPassphrase field0)? applyPassphrase,
    TResult Function(EnvoyMagicBackupEnabledRequest field0)?
        envoyMagicBackupEnabledRequest,
    TResult Function(EnvoyMagicBackupEnabledResponse field0)?
        envoyMagicBackupEnabledResponse,
    TResult Function(PrimeMagicBackupEnabled field0)? primeMagicBackupEnabled,
    TResult Function(PrimeMagicBackupStatusRequest field0)?
        primeMagicBackupStatusRequest,
    TResult Function(PrimeMagicBackupStatusResponse field0)?
        primeMagicBackupStatusResponse,
    TResult Function(BackupShardRequest field0)? backupShardRequest,
    TResult Function(BackupShardResponse field0)? backupShardResponse,
    TResult Function(RestoreShardRequest field0)? restoreShardRequest,
    TResult Function(RestoreShardResponse field0)? restoreShardResponse,
    TResult Function(CreateMagicBackupEvent field0)? createMagicBackupEvent,
    TResult Function(CreateMagicBackupResult field0)? createMagicBackupResult,
    TResult Function(RestoreMagicBackupRequest field0)?
        restoreMagicBackupRequest,
    TResult Function(RestoreMagicBackupEvent field0)? restoreMagicBackupEvent,
    TResult Function(RestoreMagicBackupResult field0)? restoreMagicBackupResult,
    TResult Function(Heartbeat field0)? heartbeat,
    TResult Function(TimezoneRequest field0)? timezoneRequest,
    TResult Function(TimezoneResponse field0)? timezoneResponse,
    TResult Function(UnpairingRequest field0)? unpairingRequest,
    TResult Function(UnpairingResponse field0)? unpairingResponse,
    TResult Function(DeviceNameUpdate field0)? deviceNameUpdate,
    TResult Function(MagicBackupRequestV2 field0)? magicBackupRequestV2,
    TResult Function(MagicBackupResponseV2 field0)? magicBackupResponseV2,
    TResult Function(PrimeFiatPreference field0)? primeFiatPreference,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case QuantumLinkMessage_ExchangeRate() when exchangeRate != null:
        return exchangeRate(_that.field0);
      case QuantumLinkMessage_ExchangeRateHistory()
          when exchangeRateHistory != null:
        return exchangeRateHistory(_that.field0);
      case QuantumLinkMessage_FirmwareUpdateCheckRequest()
          when firmwareUpdateCheckRequest != null:
        return firmwareUpdateCheckRequest(_that.field0);
      case QuantumLinkMessage_FirmwareUpdateCheckResponse()
          when firmwareUpdateCheckResponse != null:
        return firmwareUpdateCheckResponse(_that.field0);
      case QuantumLinkMessage_FirmwareFetchRequest()
          when firmwareFetchRequest != null:
        return firmwareFetchRequest(_that.field0);
      case QuantumLinkMessage_FirmwareFetchEvent()
          when firmwareFetchEvent != null:
        return firmwareFetchEvent(_that.field0);
      case QuantumLinkMessage_FirmwareInstallEvent()
          when firmwareInstallEvent != null:
        return firmwareInstallEvent(_that.field0);
      case QuantumLinkMessage_DeviceStatus() when deviceStatus != null:
        return deviceStatus(_that.field0);
      case QuantumLinkMessage_EnvoyStatus() when envoyStatus != null:
        return envoyStatus(_that.field0);
      case QuantumLinkMessage_PairingRequest() when pairingRequest != null:
        return pairingRequest(_that.field0);
      case QuantumLinkMessage_PairingResponse() when pairingResponse != null:
        return pairingResponse(_that.field0);
      case QuantumLinkMessage_SecurityCheck() when securityCheck != null:
        return securityCheck(_that.field0);
      case QuantumLinkMessage_OnboardingState() when onboardingState != null:
        return onboardingState(_that.field0);
      case QuantumLinkMessage_SignPsbt() when signPsbt != null:
        return signPsbt(_that.field0);
      case QuantumLinkMessage_BroadcastTransaction()
          when broadcastTransaction != null:
        return broadcastTransaction(_that.field0);
      case QuantumLinkMessage_AccountUpdate() when accountUpdate != null:
        return accountUpdate(_that.field0);
      case QuantumLinkMessage_ApplyPassphrase() when applyPassphrase != null:
        return applyPassphrase(_that.field0);
      case QuantumLinkMessage_EnvoyMagicBackupEnabledRequest()
          when envoyMagicBackupEnabledRequest != null:
        return envoyMagicBackupEnabledRequest(_that.field0);
      case QuantumLinkMessage_EnvoyMagicBackupEnabledResponse()
          when envoyMagicBackupEnabledResponse != null:
        return envoyMagicBackupEnabledResponse(_that.field0);
      case QuantumLinkMessage_PrimeMagicBackupEnabled()
          when primeMagicBackupEnabled != null:
        return primeMagicBackupEnabled(_that.field0);
      case QuantumLinkMessage_PrimeMagicBackupStatusRequest()
          when primeMagicBackupStatusRequest != null:
        return primeMagicBackupStatusRequest(_that.field0);
      case QuantumLinkMessage_PrimeMagicBackupStatusResponse()
          when primeMagicBackupStatusResponse != null:
        return primeMagicBackupStatusResponse(_that.field0);
      case QuantumLinkMessage_BackupShardRequest()
          when backupShardRequest != null:
        return backupShardRequest(_that.field0);
      case QuantumLinkMessage_BackupShardResponse()
          when backupShardResponse != null:
        return backupShardResponse(_that.field0);
      case QuantumLinkMessage_RestoreShardRequest()
          when restoreShardRequest != null:
        return restoreShardRequest(_that.field0);
      case QuantumLinkMessage_RestoreShardResponse()
          when restoreShardResponse != null:
        return restoreShardResponse(_that.field0);
      case QuantumLinkMessage_CreateMagicBackupEvent()
          when createMagicBackupEvent != null:
        return createMagicBackupEvent(_that.field0);
      case QuantumLinkMessage_CreateMagicBackupResult()
          when createMagicBackupResult != null:
        return createMagicBackupResult(_that.field0);
      case QuantumLinkMessage_RestoreMagicBackupRequest()
          when restoreMagicBackupRequest != null:
        return restoreMagicBackupRequest(_that.field0);
      case QuantumLinkMessage_RestoreMagicBackupEvent()
          when restoreMagicBackupEvent != null:
        return restoreMagicBackupEvent(_that.field0);
      case QuantumLinkMessage_RestoreMagicBackupResult()
          when restoreMagicBackupResult != null:
        return restoreMagicBackupResult(_that.field0);
      case QuantumLinkMessage_Heartbeat() when heartbeat != null:
        return heartbeat(_that.field0);
      case QuantumLinkMessage_TimezoneRequest() when timezoneRequest != null:
        return timezoneRequest(_that.field0);
      case QuantumLinkMessage_TimezoneResponse() when timezoneResponse != null:
        return timezoneResponse(_that.field0);
      case QuantumLinkMessage_UnpairingRequest() when unpairingRequest != null:
        return unpairingRequest(_that.field0);
      case QuantumLinkMessage_UnpairingResponse()
          when unpairingResponse != null:
        return unpairingResponse(_that.field0);
      case QuantumLinkMessage_DeviceNameUpdate() when deviceNameUpdate != null:
        return deviceNameUpdate(_that.field0);
      case QuantumLinkMessage_MagicBackupRequestV2()
          when magicBackupRequestV2 != null:
        return magicBackupRequestV2(_that.field0);
      case QuantumLinkMessage_MagicBackupResponseV2()
          when magicBackupResponseV2 != null:
        return magicBackupResponseV2(_that.field0);
      case QuantumLinkMessage_PrimeFiatPreference()
          when primeFiatPreference != null:
        return primeFiatPreference(_that.field0);
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
    required TResult Function(ExchangeRate field0) exchangeRate,
    required TResult Function(ExchangeRateHistory field0) exchangeRateHistory,
    required TResult Function(FirmwareUpdateCheckRequest field0)
        firmwareUpdateCheckRequest,
    required TResult Function(FirmwareUpdateCheckResponse field0)
        firmwareUpdateCheckResponse,
    required TResult Function(FirmwareFetchRequest field0) firmwareFetchRequest,
    required TResult Function(FirmwareFetchEvent field0) firmwareFetchEvent,
    required TResult Function(FirmwareInstallEvent field0) firmwareInstallEvent,
    required TResult Function(DeviceStatus field0) deviceStatus,
    required TResult Function(EnvoyStatus field0) envoyStatus,
    required TResult Function(PairingRequest field0) pairingRequest,
    required TResult Function(PairingResponse field0) pairingResponse,
    required TResult Function(SecurityCheck field0) securityCheck,
    required TResult Function(OnboardingState field0) onboardingState,
    required TResult Function(SignPsbt field0) signPsbt,
    required TResult Function(BroadcastTransaction field0) broadcastTransaction,
    required TResult Function(AccountUpdate field0) accountUpdate,
    required TResult Function(ApplyPassphrase field0) applyPassphrase,
    required TResult Function(EnvoyMagicBackupEnabledRequest field0)
        envoyMagicBackupEnabledRequest,
    required TResult Function(EnvoyMagicBackupEnabledResponse field0)
        envoyMagicBackupEnabledResponse,
    required TResult Function(PrimeMagicBackupEnabled field0)
        primeMagicBackupEnabled,
    required TResult Function(PrimeMagicBackupStatusRequest field0)
        primeMagicBackupStatusRequest,
    required TResult Function(PrimeMagicBackupStatusResponse field0)
        primeMagicBackupStatusResponse,
    required TResult Function(BackupShardRequest field0) backupShardRequest,
    required TResult Function(BackupShardResponse field0) backupShardResponse,
    required TResult Function(RestoreShardRequest field0) restoreShardRequest,
    required TResult Function(RestoreShardResponse field0) restoreShardResponse,
    required TResult Function(CreateMagicBackupEvent field0)
        createMagicBackupEvent,
    required TResult Function(CreateMagicBackupResult field0)
        createMagicBackupResult,
    required TResult Function(RestoreMagicBackupRequest field0)
        restoreMagicBackupRequest,
    required TResult Function(RestoreMagicBackupEvent field0)
        restoreMagicBackupEvent,
    required TResult Function(RestoreMagicBackupResult field0)
        restoreMagicBackupResult,
    required TResult Function(Heartbeat field0) heartbeat,
    required TResult Function(TimezoneRequest field0) timezoneRequest,
    required TResult Function(TimezoneResponse field0) timezoneResponse,
    required TResult Function(UnpairingRequest field0) unpairingRequest,
    required TResult Function(UnpairingResponse field0) unpairingResponse,
    required TResult Function(DeviceNameUpdate field0) deviceNameUpdate,
    required TResult Function(MagicBackupRequestV2 field0) magicBackupRequestV2,
    required TResult Function(MagicBackupResponseV2 field0)
        magicBackupResponseV2,
    required TResult Function(PrimeFiatPreference field0) primeFiatPreference,
  }) {
    final _that = this;
    switch (_that) {
      case QuantumLinkMessage_ExchangeRate():
        return exchangeRate(_that.field0);
      case QuantumLinkMessage_ExchangeRateHistory():
        return exchangeRateHistory(_that.field0);
      case QuantumLinkMessage_FirmwareUpdateCheckRequest():
        return firmwareUpdateCheckRequest(_that.field0);
      case QuantumLinkMessage_FirmwareUpdateCheckResponse():
        return firmwareUpdateCheckResponse(_that.field0);
      case QuantumLinkMessage_FirmwareFetchRequest():
        return firmwareFetchRequest(_that.field0);
      case QuantumLinkMessage_FirmwareFetchEvent():
        return firmwareFetchEvent(_that.field0);
      case QuantumLinkMessage_FirmwareInstallEvent():
        return firmwareInstallEvent(_that.field0);
      case QuantumLinkMessage_DeviceStatus():
        return deviceStatus(_that.field0);
      case QuantumLinkMessage_EnvoyStatus():
        return envoyStatus(_that.field0);
      case QuantumLinkMessage_PairingRequest():
        return pairingRequest(_that.field0);
      case QuantumLinkMessage_PairingResponse():
        return pairingResponse(_that.field0);
      case QuantumLinkMessage_SecurityCheck():
        return securityCheck(_that.field0);
      case QuantumLinkMessage_OnboardingState():
        return onboardingState(_that.field0);
      case QuantumLinkMessage_SignPsbt():
        return signPsbt(_that.field0);
      case QuantumLinkMessage_BroadcastTransaction():
        return broadcastTransaction(_that.field0);
      case QuantumLinkMessage_AccountUpdate():
        return accountUpdate(_that.field0);
      case QuantumLinkMessage_ApplyPassphrase():
        return applyPassphrase(_that.field0);
      case QuantumLinkMessage_EnvoyMagicBackupEnabledRequest():
        return envoyMagicBackupEnabledRequest(_that.field0);
      case QuantumLinkMessage_EnvoyMagicBackupEnabledResponse():
        return envoyMagicBackupEnabledResponse(_that.field0);
      case QuantumLinkMessage_PrimeMagicBackupEnabled():
        return primeMagicBackupEnabled(_that.field0);
      case QuantumLinkMessage_PrimeMagicBackupStatusRequest():
        return primeMagicBackupStatusRequest(_that.field0);
      case QuantumLinkMessage_PrimeMagicBackupStatusResponse():
        return primeMagicBackupStatusResponse(_that.field0);
      case QuantumLinkMessage_BackupShardRequest():
        return backupShardRequest(_that.field0);
      case QuantumLinkMessage_BackupShardResponse():
        return backupShardResponse(_that.field0);
      case QuantumLinkMessage_RestoreShardRequest():
        return restoreShardRequest(_that.field0);
      case QuantumLinkMessage_RestoreShardResponse():
        return restoreShardResponse(_that.field0);
      case QuantumLinkMessage_CreateMagicBackupEvent():
        return createMagicBackupEvent(_that.field0);
      case QuantumLinkMessage_CreateMagicBackupResult():
        return createMagicBackupResult(_that.field0);
      case QuantumLinkMessage_RestoreMagicBackupRequest():
        return restoreMagicBackupRequest(_that.field0);
      case QuantumLinkMessage_RestoreMagicBackupEvent():
        return restoreMagicBackupEvent(_that.field0);
      case QuantumLinkMessage_RestoreMagicBackupResult():
        return restoreMagicBackupResult(_that.field0);
      case QuantumLinkMessage_Heartbeat():
        return heartbeat(_that.field0);
      case QuantumLinkMessage_TimezoneRequest():
        return timezoneRequest(_that.field0);
      case QuantumLinkMessage_TimezoneResponse():
        return timezoneResponse(_that.field0);
      case QuantumLinkMessage_UnpairingRequest():
        return unpairingRequest(_that.field0);
      case QuantumLinkMessage_UnpairingResponse():
        return unpairingResponse(_that.field0);
      case QuantumLinkMessage_DeviceNameUpdate():
        return deviceNameUpdate(_that.field0);
      case QuantumLinkMessage_MagicBackupRequestV2():
        return magicBackupRequestV2(_that.field0);
      case QuantumLinkMessage_MagicBackupResponseV2():
        return magicBackupResponseV2(_that.field0);
      case QuantumLinkMessage_PrimeFiatPreference():
        return primeFiatPreference(_that.field0);
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
    TResult? Function(ExchangeRate field0)? exchangeRate,
    TResult? Function(ExchangeRateHistory field0)? exchangeRateHistory,
    TResult? Function(FirmwareUpdateCheckRequest field0)?
        firmwareUpdateCheckRequest,
    TResult? Function(FirmwareUpdateCheckResponse field0)?
        firmwareUpdateCheckResponse,
    TResult? Function(FirmwareFetchRequest field0)? firmwareFetchRequest,
    TResult? Function(FirmwareFetchEvent field0)? firmwareFetchEvent,
    TResult? Function(FirmwareInstallEvent field0)? firmwareInstallEvent,
    TResult? Function(DeviceStatus field0)? deviceStatus,
    TResult? Function(EnvoyStatus field0)? envoyStatus,
    TResult? Function(PairingRequest field0)? pairingRequest,
    TResult? Function(PairingResponse field0)? pairingResponse,
    TResult? Function(SecurityCheck field0)? securityCheck,
    TResult? Function(OnboardingState field0)? onboardingState,
    TResult? Function(SignPsbt field0)? signPsbt,
    TResult? Function(BroadcastTransaction field0)? broadcastTransaction,
    TResult? Function(AccountUpdate field0)? accountUpdate,
    TResult? Function(ApplyPassphrase field0)? applyPassphrase,
    TResult? Function(EnvoyMagicBackupEnabledRequest field0)?
        envoyMagicBackupEnabledRequest,
    TResult? Function(EnvoyMagicBackupEnabledResponse field0)?
        envoyMagicBackupEnabledResponse,
    TResult? Function(PrimeMagicBackupEnabled field0)? primeMagicBackupEnabled,
    TResult? Function(PrimeMagicBackupStatusRequest field0)?
        primeMagicBackupStatusRequest,
    TResult? Function(PrimeMagicBackupStatusResponse field0)?
        primeMagicBackupStatusResponse,
    TResult? Function(BackupShardRequest field0)? backupShardRequest,
    TResult? Function(BackupShardResponse field0)? backupShardResponse,
    TResult? Function(RestoreShardRequest field0)? restoreShardRequest,
    TResult? Function(RestoreShardResponse field0)? restoreShardResponse,
    TResult? Function(CreateMagicBackupEvent field0)? createMagicBackupEvent,
    TResult? Function(CreateMagicBackupResult field0)? createMagicBackupResult,
    TResult? Function(RestoreMagicBackupRequest field0)?
        restoreMagicBackupRequest,
    TResult? Function(RestoreMagicBackupEvent field0)? restoreMagicBackupEvent,
    TResult? Function(RestoreMagicBackupResult field0)?
        restoreMagicBackupResult,
    TResult? Function(Heartbeat field0)? heartbeat,
    TResult? Function(TimezoneRequest field0)? timezoneRequest,
    TResult? Function(TimezoneResponse field0)? timezoneResponse,
    TResult? Function(UnpairingRequest field0)? unpairingRequest,
    TResult? Function(UnpairingResponse field0)? unpairingResponse,
    TResult? Function(DeviceNameUpdate field0)? deviceNameUpdate,
    TResult? Function(MagicBackupRequestV2 field0)? magicBackupRequestV2,
    TResult? Function(MagicBackupResponseV2 field0)? magicBackupResponseV2,
    TResult? Function(PrimeFiatPreference field0)? primeFiatPreference,
  }) {
    final _that = this;
    switch (_that) {
      case QuantumLinkMessage_ExchangeRate() when exchangeRate != null:
        return exchangeRate(_that.field0);
      case QuantumLinkMessage_ExchangeRateHistory()
          when exchangeRateHistory != null:
        return exchangeRateHistory(_that.field0);
      case QuantumLinkMessage_FirmwareUpdateCheckRequest()
          when firmwareUpdateCheckRequest != null:
        return firmwareUpdateCheckRequest(_that.field0);
      case QuantumLinkMessage_FirmwareUpdateCheckResponse()
          when firmwareUpdateCheckResponse != null:
        return firmwareUpdateCheckResponse(_that.field0);
      case QuantumLinkMessage_FirmwareFetchRequest()
          when firmwareFetchRequest != null:
        return firmwareFetchRequest(_that.field0);
      case QuantumLinkMessage_FirmwareFetchEvent()
          when firmwareFetchEvent != null:
        return firmwareFetchEvent(_that.field0);
      case QuantumLinkMessage_FirmwareInstallEvent()
          when firmwareInstallEvent != null:
        return firmwareInstallEvent(_that.field0);
      case QuantumLinkMessage_DeviceStatus() when deviceStatus != null:
        return deviceStatus(_that.field0);
      case QuantumLinkMessage_EnvoyStatus() when envoyStatus != null:
        return envoyStatus(_that.field0);
      case QuantumLinkMessage_PairingRequest() when pairingRequest != null:
        return pairingRequest(_that.field0);
      case QuantumLinkMessage_PairingResponse() when pairingResponse != null:
        return pairingResponse(_that.field0);
      case QuantumLinkMessage_SecurityCheck() when securityCheck != null:
        return securityCheck(_that.field0);
      case QuantumLinkMessage_OnboardingState() when onboardingState != null:
        return onboardingState(_that.field0);
      case QuantumLinkMessage_SignPsbt() when signPsbt != null:
        return signPsbt(_that.field0);
      case QuantumLinkMessage_BroadcastTransaction()
          when broadcastTransaction != null:
        return broadcastTransaction(_that.field0);
      case QuantumLinkMessage_AccountUpdate() when accountUpdate != null:
        return accountUpdate(_that.field0);
      case QuantumLinkMessage_ApplyPassphrase() when applyPassphrase != null:
        return applyPassphrase(_that.field0);
      case QuantumLinkMessage_EnvoyMagicBackupEnabledRequest()
          when envoyMagicBackupEnabledRequest != null:
        return envoyMagicBackupEnabledRequest(_that.field0);
      case QuantumLinkMessage_EnvoyMagicBackupEnabledResponse()
          when envoyMagicBackupEnabledResponse != null:
        return envoyMagicBackupEnabledResponse(_that.field0);
      case QuantumLinkMessage_PrimeMagicBackupEnabled()
          when primeMagicBackupEnabled != null:
        return primeMagicBackupEnabled(_that.field0);
      case QuantumLinkMessage_PrimeMagicBackupStatusRequest()
          when primeMagicBackupStatusRequest != null:
        return primeMagicBackupStatusRequest(_that.field0);
      case QuantumLinkMessage_PrimeMagicBackupStatusResponse()
          when primeMagicBackupStatusResponse != null:
        return primeMagicBackupStatusResponse(_that.field0);
      case QuantumLinkMessage_BackupShardRequest()
          when backupShardRequest != null:
        return backupShardRequest(_that.field0);
      case QuantumLinkMessage_BackupShardResponse()
          when backupShardResponse != null:
        return backupShardResponse(_that.field0);
      case QuantumLinkMessage_RestoreShardRequest()
          when restoreShardRequest != null:
        return restoreShardRequest(_that.field0);
      case QuantumLinkMessage_RestoreShardResponse()
          when restoreShardResponse != null:
        return restoreShardResponse(_that.field0);
      case QuantumLinkMessage_CreateMagicBackupEvent()
          when createMagicBackupEvent != null:
        return createMagicBackupEvent(_that.field0);
      case QuantumLinkMessage_CreateMagicBackupResult()
          when createMagicBackupResult != null:
        return createMagicBackupResult(_that.field0);
      case QuantumLinkMessage_RestoreMagicBackupRequest()
          when restoreMagicBackupRequest != null:
        return restoreMagicBackupRequest(_that.field0);
      case QuantumLinkMessage_RestoreMagicBackupEvent()
          when restoreMagicBackupEvent != null:
        return restoreMagicBackupEvent(_that.field0);
      case QuantumLinkMessage_RestoreMagicBackupResult()
          when restoreMagicBackupResult != null:
        return restoreMagicBackupResult(_that.field0);
      case QuantumLinkMessage_Heartbeat() when heartbeat != null:
        return heartbeat(_that.field0);
      case QuantumLinkMessage_TimezoneRequest() when timezoneRequest != null:
        return timezoneRequest(_that.field0);
      case QuantumLinkMessage_TimezoneResponse() when timezoneResponse != null:
        return timezoneResponse(_that.field0);
      case QuantumLinkMessage_UnpairingRequest() when unpairingRequest != null:
        return unpairingRequest(_that.field0);
      case QuantumLinkMessage_UnpairingResponse()
          when unpairingResponse != null:
        return unpairingResponse(_that.field0);
      case QuantumLinkMessage_DeviceNameUpdate() when deviceNameUpdate != null:
        return deviceNameUpdate(_that.field0);
      case QuantumLinkMessage_MagicBackupRequestV2()
          when magicBackupRequestV2 != null:
        return magicBackupRequestV2(_that.field0);
      case QuantumLinkMessage_MagicBackupResponseV2()
          when magicBackupResponseV2 != null:
        return magicBackupResponseV2(_that.field0);
      case QuantumLinkMessage_PrimeFiatPreference()
          when primeFiatPreference != null:
        return primeFiatPreference(_that.field0);
      case _:
        return null;
    }
  }
}

/// @nodoc

class QuantumLinkMessage_ExchangeRate extends QuantumLinkMessage {
  const QuantumLinkMessage_ExchangeRate(this.field0) : super._();

  @override
  final ExchangeRate field0;

  /// Create a copy of QuantumLinkMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $QuantumLinkMessage_ExchangeRateCopyWith<QuantumLinkMessage_ExchangeRate>
      get copyWith => _$QuantumLinkMessage_ExchangeRateCopyWithImpl<
          QuantumLinkMessage_ExchangeRate>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is QuantumLinkMessage_ExchangeRate &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'QuantumLinkMessage.exchangeRate(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $QuantumLinkMessage_ExchangeRateCopyWith<$Res>
    implements $QuantumLinkMessageCopyWith<$Res> {
  factory $QuantumLinkMessage_ExchangeRateCopyWith(
          QuantumLinkMessage_ExchangeRate value,
          $Res Function(QuantumLinkMessage_ExchangeRate) _then) =
      _$QuantumLinkMessage_ExchangeRateCopyWithImpl;
  @useResult
  $Res call({ExchangeRate field0});
}

/// @nodoc
class _$QuantumLinkMessage_ExchangeRateCopyWithImpl<$Res>
    implements $QuantumLinkMessage_ExchangeRateCopyWith<$Res> {
  _$QuantumLinkMessage_ExchangeRateCopyWithImpl(this._self, this._then);

  final QuantumLinkMessage_ExchangeRate _self;
  final $Res Function(QuantumLinkMessage_ExchangeRate) _then;

  /// Create a copy of QuantumLinkMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(QuantumLinkMessage_ExchangeRate(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as ExchangeRate,
    ));
  }
}

/// @nodoc

class QuantumLinkMessage_ExchangeRateHistory extends QuantumLinkMessage {
  const QuantumLinkMessage_ExchangeRateHistory(this.field0) : super._();

  @override
  final ExchangeRateHistory field0;

  /// Create a copy of QuantumLinkMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $QuantumLinkMessage_ExchangeRateHistoryCopyWith<
          QuantumLinkMessage_ExchangeRateHistory>
      get copyWith => _$QuantumLinkMessage_ExchangeRateHistoryCopyWithImpl<
          QuantumLinkMessage_ExchangeRateHistory>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is QuantumLinkMessage_ExchangeRateHistory &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'QuantumLinkMessage.exchangeRateHistory(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $QuantumLinkMessage_ExchangeRateHistoryCopyWith<$Res>
    implements $QuantumLinkMessageCopyWith<$Res> {
  factory $QuantumLinkMessage_ExchangeRateHistoryCopyWith(
          QuantumLinkMessage_ExchangeRateHistory value,
          $Res Function(QuantumLinkMessage_ExchangeRateHistory) _then) =
      _$QuantumLinkMessage_ExchangeRateHistoryCopyWithImpl;
  @useResult
  $Res call({ExchangeRateHistory field0});
}

/// @nodoc
class _$QuantumLinkMessage_ExchangeRateHistoryCopyWithImpl<$Res>
    implements $QuantumLinkMessage_ExchangeRateHistoryCopyWith<$Res> {
  _$QuantumLinkMessage_ExchangeRateHistoryCopyWithImpl(this._self, this._then);

  final QuantumLinkMessage_ExchangeRateHistory _self;
  final $Res Function(QuantumLinkMessage_ExchangeRateHistory) _then;

  /// Create a copy of QuantumLinkMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(QuantumLinkMessage_ExchangeRateHistory(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as ExchangeRateHistory,
    ));
  }
}

/// @nodoc

class QuantumLinkMessage_FirmwareUpdateCheckRequest extends QuantumLinkMessage {
  const QuantumLinkMessage_FirmwareUpdateCheckRequest(this.field0) : super._();

  @override
  final FirmwareUpdateCheckRequest field0;

  /// Create a copy of QuantumLinkMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $QuantumLinkMessage_FirmwareUpdateCheckRequestCopyWith<
          QuantumLinkMessage_FirmwareUpdateCheckRequest>
      get copyWith =>
          _$QuantumLinkMessage_FirmwareUpdateCheckRequestCopyWithImpl<
              QuantumLinkMessage_FirmwareUpdateCheckRequest>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is QuantumLinkMessage_FirmwareUpdateCheckRequest &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'QuantumLinkMessage.firmwareUpdateCheckRequest(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $QuantumLinkMessage_FirmwareUpdateCheckRequestCopyWith<
    $Res> implements $QuantumLinkMessageCopyWith<$Res> {
  factory $QuantumLinkMessage_FirmwareUpdateCheckRequestCopyWith(
          QuantumLinkMessage_FirmwareUpdateCheckRequest value,
          $Res Function(QuantumLinkMessage_FirmwareUpdateCheckRequest) _then) =
      _$QuantumLinkMessage_FirmwareUpdateCheckRequestCopyWithImpl;
  @useResult
  $Res call({FirmwareUpdateCheckRequest field0});
}

/// @nodoc
class _$QuantumLinkMessage_FirmwareUpdateCheckRequestCopyWithImpl<$Res>
    implements $QuantumLinkMessage_FirmwareUpdateCheckRequestCopyWith<$Res> {
  _$QuantumLinkMessage_FirmwareUpdateCheckRequestCopyWithImpl(
      this._self, this._then);

  final QuantumLinkMessage_FirmwareUpdateCheckRequest _self;
  final $Res Function(QuantumLinkMessage_FirmwareUpdateCheckRequest) _then;

  /// Create a copy of QuantumLinkMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(QuantumLinkMessage_FirmwareUpdateCheckRequest(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as FirmwareUpdateCheckRequest,
    ));
  }
}

/// @nodoc

class QuantumLinkMessage_FirmwareUpdateCheckResponse
    extends QuantumLinkMessage {
  const QuantumLinkMessage_FirmwareUpdateCheckResponse(this.field0) : super._();

  @override
  final FirmwareUpdateCheckResponse field0;

  /// Create a copy of QuantumLinkMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $QuantumLinkMessage_FirmwareUpdateCheckResponseCopyWith<
          QuantumLinkMessage_FirmwareUpdateCheckResponse>
      get copyWith =>
          _$QuantumLinkMessage_FirmwareUpdateCheckResponseCopyWithImpl<
              QuantumLinkMessage_FirmwareUpdateCheckResponse>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is QuantumLinkMessage_FirmwareUpdateCheckResponse &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'QuantumLinkMessage.firmwareUpdateCheckResponse(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $QuantumLinkMessage_FirmwareUpdateCheckResponseCopyWith<
    $Res> implements $QuantumLinkMessageCopyWith<$Res> {
  factory $QuantumLinkMessage_FirmwareUpdateCheckResponseCopyWith(
          QuantumLinkMessage_FirmwareUpdateCheckResponse value,
          $Res Function(QuantumLinkMessage_FirmwareUpdateCheckResponse) _then) =
      _$QuantumLinkMessage_FirmwareUpdateCheckResponseCopyWithImpl;
  @useResult
  $Res call({FirmwareUpdateCheckResponse field0});

  $FirmwareUpdateCheckResponseCopyWith<$Res> get field0;
}

/// @nodoc
class _$QuantumLinkMessage_FirmwareUpdateCheckResponseCopyWithImpl<$Res>
    implements $QuantumLinkMessage_FirmwareUpdateCheckResponseCopyWith<$Res> {
  _$QuantumLinkMessage_FirmwareUpdateCheckResponseCopyWithImpl(
      this._self, this._then);

  final QuantumLinkMessage_FirmwareUpdateCheckResponse _self;
  final $Res Function(QuantumLinkMessage_FirmwareUpdateCheckResponse) _then;

  /// Create a copy of QuantumLinkMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(QuantumLinkMessage_FirmwareUpdateCheckResponse(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as FirmwareUpdateCheckResponse,
    ));
  }

  /// Create a copy of QuantumLinkMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $FirmwareUpdateCheckResponseCopyWith<$Res> get field0 {
    return $FirmwareUpdateCheckResponseCopyWith<$Res>(_self.field0, (value) {
      return _then(_self.copyWith(field0: value));
    });
  }
}

/// @nodoc

class QuantumLinkMessage_FirmwareFetchRequest extends QuantumLinkMessage {
  const QuantumLinkMessage_FirmwareFetchRequest(this.field0) : super._();

  @override
  final FirmwareFetchRequest field0;

  /// Create a copy of QuantumLinkMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $QuantumLinkMessage_FirmwareFetchRequestCopyWith<
          QuantumLinkMessage_FirmwareFetchRequest>
      get copyWith => _$QuantumLinkMessage_FirmwareFetchRequestCopyWithImpl<
          QuantumLinkMessage_FirmwareFetchRequest>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is QuantumLinkMessage_FirmwareFetchRequest &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'QuantumLinkMessage.firmwareFetchRequest(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $QuantumLinkMessage_FirmwareFetchRequestCopyWith<$Res>
    implements $QuantumLinkMessageCopyWith<$Res> {
  factory $QuantumLinkMessage_FirmwareFetchRequestCopyWith(
          QuantumLinkMessage_FirmwareFetchRequest value,
          $Res Function(QuantumLinkMessage_FirmwareFetchRequest) _then) =
      _$QuantumLinkMessage_FirmwareFetchRequestCopyWithImpl;
  @useResult
  $Res call({FirmwareFetchRequest field0});
}

/// @nodoc
class _$QuantumLinkMessage_FirmwareFetchRequestCopyWithImpl<$Res>
    implements $QuantumLinkMessage_FirmwareFetchRequestCopyWith<$Res> {
  _$QuantumLinkMessage_FirmwareFetchRequestCopyWithImpl(this._self, this._then);

  final QuantumLinkMessage_FirmwareFetchRequest _self;
  final $Res Function(QuantumLinkMessage_FirmwareFetchRequest) _then;

  /// Create a copy of QuantumLinkMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(QuantumLinkMessage_FirmwareFetchRequest(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as FirmwareFetchRequest,
    ));
  }
}

/// @nodoc

class QuantumLinkMessage_FirmwareFetchEvent extends QuantumLinkMessage {
  const QuantumLinkMessage_FirmwareFetchEvent(this.field0) : super._();

  @override
  final FirmwareFetchEvent field0;

  /// Create a copy of QuantumLinkMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $QuantumLinkMessage_FirmwareFetchEventCopyWith<
          QuantumLinkMessage_FirmwareFetchEvent>
      get copyWith => _$QuantumLinkMessage_FirmwareFetchEventCopyWithImpl<
          QuantumLinkMessage_FirmwareFetchEvent>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is QuantumLinkMessage_FirmwareFetchEvent &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'QuantumLinkMessage.firmwareFetchEvent(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $QuantumLinkMessage_FirmwareFetchEventCopyWith<$Res>
    implements $QuantumLinkMessageCopyWith<$Res> {
  factory $QuantumLinkMessage_FirmwareFetchEventCopyWith(
          QuantumLinkMessage_FirmwareFetchEvent value,
          $Res Function(QuantumLinkMessage_FirmwareFetchEvent) _then) =
      _$QuantumLinkMessage_FirmwareFetchEventCopyWithImpl;
  @useResult
  $Res call({FirmwareFetchEvent field0});

  $FirmwareFetchEventCopyWith<$Res> get field0;
}

/// @nodoc
class _$QuantumLinkMessage_FirmwareFetchEventCopyWithImpl<$Res>
    implements $QuantumLinkMessage_FirmwareFetchEventCopyWith<$Res> {
  _$QuantumLinkMessage_FirmwareFetchEventCopyWithImpl(this._self, this._then);

  final QuantumLinkMessage_FirmwareFetchEvent _self;
  final $Res Function(QuantumLinkMessage_FirmwareFetchEvent) _then;

  /// Create a copy of QuantumLinkMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(QuantumLinkMessage_FirmwareFetchEvent(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as FirmwareFetchEvent,
    ));
  }

  /// Create a copy of QuantumLinkMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $FirmwareFetchEventCopyWith<$Res> get field0 {
    return $FirmwareFetchEventCopyWith<$Res>(_self.field0, (value) {
      return _then(_self.copyWith(field0: value));
    });
  }
}

/// @nodoc

class QuantumLinkMessage_FirmwareInstallEvent extends QuantumLinkMessage {
  const QuantumLinkMessage_FirmwareInstallEvent(this.field0) : super._();

  @override
  final FirmwareInstallEvent field0;

  /// Create a copy of QuantumLinkMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $QuantumLinkMessage_FirmwareInstallEventCopyWith<
          QuantumLinkMessage_FirmwareInstallEvent>
      get copyWith => _$QuantumLinkMessage_FirmwareInstallEventCopyWithImpl<
          QuantumLinkMessage_FirmwareInstallEvent>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is QuantumLinkMessage_FirmwareInstallEvent &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'QuantumLinkMessage.firmwareInstallEvent(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $QuantumLinkMessage_FirmwareInstallEventCopyWith<$Res>
    implements $QuantumLinkMessageCopyWith<$Res> {
  factory $QuantumLinkMessage_FirmwareInstallEventCopyWith(
          QuantumLinkMessage_FirmwareInstallEvent value,
          $Res Function(QuantumLinkMessage_FirmwareInstallEvent) _then) =
      _$QuantumLinkMessage_FirmwareInstallEventCopyWithImpl;
  @useResult
  $Res call({FirmwareInstallEvent field0});

  $FirmwareInstallEventCopyWith<$Res> get field0;
}

/// @nodoc
class _$QuantumLinkMessage_FirmwareInstallEventCopyWithImpl<$Res>
    implements $QuantumLinkMessage_FirmwareInstallEventCopyWith<$Res> {
  _$QuantumLinkMessage_FirmwareInstallEventCopyWithImpl(this._self, this._then);

  final QuantumLinkMessage_FirmwareInstallEvent _self;
  final $Res Function(QuantumLinkMessage_FirmwareInstallEvent) _then;

  /// Create a copy of QuantumLinkMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(QuantumLinkMessage_FirmwareInstallEvent(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as FirmwareInstallEvent,
    ));
  }

  /// Create a copy of QuantumLinkMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $FirmwareInstallEventCopyWith<$Res> get field0 {
    return $FirmwareInstallEventCopyWith<$Res>(_self.field0, (value) {
      return _then(_self.copyWith(field0: value));
    });
  }
}

/// @nodoc

class QuantumLinkMessage_DeviceStatus extends QuantumLinkMessage {
  const QuantumLinkMessage_DeviceStatus(this.field0) : super._();

  @override
  final DeviceStatus field0;

  /// Create a copy of QuantumLinkMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $QuantumLinkMessage_DeviceStatusCopyWith<QuantumLinkMessage_DeviceStatus>
      get copyWith => _$QuantumLinkMessage_DeviceStatusCopyWithImpl<
          QuantumLinkMessage_DeviceStatus>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is QuantumLinkMessage_DeviceStatus &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'QuantumLinkMessage.deviceStatus(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $QuantumLinkMessage_DeviceStatusCopyWith<$Res>
    implements $QuantumLinkMessageCopyWith<$Res> {
  factory $QuantumLinkMessage_DeviceStatusCopyWith(
          QuantumLinkMessage_DeviceStatus value,
          $Res Function(QuantumLinkMessage_DeviceStatus) _then) =
      _$QuantumLinkMessage_DeviceStatusCopyWithImpl;
  @useResult
  $Res call({DeviceStatus field0});
}

/// @nodoc
class _$QuantumLinkMessage_DeviceStatusCopyWithImpl<$Res>
    implements $QuantumLinkMessage_DeviceStatusCopyWith<$Res> {
  _$QuantumLinkMessage_DeviceStatusCopyWithImpl(this._self, this._then);

  final QuantumLinkMessage_DeviceStatus _self;
  final $Res Function(QuantumLinkMessage_DeviceStatus) _then;

  /// Create a copy of QuantumLinkMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(QuantumLinkMessage_DeviceStatus(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as DeviceStatus,
    ));
  }
}

/// @nodoc

class QuantumLinkMessage_EnvoyStatus extends QuantumLinkMessage {
  const QuantumLinkMessage_EnvoyStatus(this.field0) : super._();

  @override
  final EnvoyStatus field0;

  /// Create a copy of QuantumLinkMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $QuantumLinkMessage_EnvoyStatusCopyWith<QuantumLinkMessage_EnvoyStatus>
      get copyWith => _$QuantumLinkMessage_EnvoyStatusCopyWithImpl<
          QuantumLinkMessage_EnvoyStatus>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is QuantumLinkMessage_EnvoyStatus &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'QuantumLinkMessage.envoyStatus(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $QuantumLinkMessage_EnvoyStatusCopyWith<$Res>
    implements $QuantumLinkMessageCopyWith<$Res> {
  factory $QuantumLinkMessage_EnvoyStatusCopyWith(
          QuantumLinkMessage_EnvoyStatus value,
          $Res Function(QuantumLinkMessage_EnvoyStatus) _then) =
      _$QuantumLinkMessage_EnvoyStatusCopyWithImpl;
  @useResult
  $Res call({EnvoyStatus field0});
}

/// @nodoc
class _$QuantumLinkMessage_EnvoyStatusCopyWithImpl<$Res>
    implements $QuantumLinkMessage_EnvoyStatusCopyWith<$Res> {
  _$QuantumLinkMessage_EnvoyStatusCopyWithImpl(this._self, this._then);

  final QuantumLinkMessage_EnvoyStatus _self;
  final $Res Function(QuantumLinkMessage_EnvoyStatus) _then;

  /// Create a copy of QuantumLinkMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(QuantumLinkMessage_EnvoyStatus(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as EnvoyStatus,
    ));
  }
}

/// @nodoc

class QuantumLinkMessage_PairingRequest extends QuantumLinkMessage {
  const QuantumLinkMessage_PairingRequest(this.field0) : super._();

  @override
  final PairingRequest field0;

  /// Create a copy of QuantumLinkMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $QuantumLinkMessage_PairingRequestCopyWith<QuantumLinkMessage_PairingRequest>
      get copyWith => _$QuantumLinkMessage_PairingRequestCopyWithImpl<
          QuantumLinkMessage_PairingRequest>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is QuantumLinkMessage_PairingRequest &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'QuantumLinkMessage.pairingRequest(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $QuantumLinkMessage_PairingRequestCopyWith<$Res>
    implements $QuantumLinkMessageCopyWith<$Res> {
  factory $QuantumLinkMessage_PairingRequestCopyWith(
          QuantumLinkMessage_PairingRequest value,
          $Res Function(QuantumLinkMessage_PairingRequest) _then) =
      _$QuantumLinkMessage_PairingRequestCopyWithImpl;
  @useResult
  $Res call({PairingRequest field0});
}

/// @nodoc
class _$QuantumLinkMessage_PairingRequestCopyWithImpl<$Res>
    implements $QuantumLinkMessage_PairingRequestCopyWith<$Res> {
  _$QuantumLinkMessage_PairingRequestCopyWithImpl(this._self, this._then);

  final QuantumLinkMessage_PairingRequest _self;
  final $Res Function(QuantumLinkMessage_PairingRequest) _then;

  /// Create a copy of QuantumLinkMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(QuantumLinkMessage_PairingRequest(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as PairingRequest,
    ));
  }
}

/// @nodoc

class QuantumLinkMessage_PairingResponse extends QuantumLinkMessage {
  const QuantumLinkMessage_PairingResponse(this.field0) : super._();

  @override
  final PairingResponse field0;

  /// Create a copy of QuantumLinkMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $QuantumLinkMessage_PairingResponseCopyWith<
          QuantumLinkMessage_PairingResponse>
      get copyWith => _$QuantumLinkMessage_PairingResponseCopyWithImpl<
          QuantumLinkMessage_PairingResponse>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is QuantumLinkMessage_PairingResponse &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'QuantumLinkMessage.pairingResponse(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $QuantumLinkMessage_PairingResponseCopyWith<$Res>
    implements $QuantumLinkMessageCopyWith<$Res> {
  factory $QuantumLinkMessage_PairingResponseCopyWith(
          QuantumLinkMessage_PairingResponse value,
          $Res Function(QuantumLinkMessage_PairingResponse) _then) =
      _$QuantumLinkMessage_PairingResponseCopyWithImpl;
  @useResult
  $Res call({PairingResponse field0});
}

/// @nodoc
class _$QuantumLinkMessage_PairingResponseCopyWithImpl<$Res>
    implements $QuantumLinkMessage_PairingResponseCopyWith<$Res> {
  _$QuantumLinkMessage_PairingResponseCopyWithImpl(this._self, this._then);

  final QuantumLinkMessage_PairingResponse _self;
  final $Res Function(QuantumLinkMessage_PairingResponse) _then;

  /// Create a copy of QuantumLinkMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(QuantumLinkMessage_PairingResponse(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as PairingResponse,
    ));
  }
}

/// @nodoc

class QuantumLinkMessage_SecurityCheck extends QuantumLinkMessage {
  const QuantumLinkMessage_SecurityCheck(this.field0) : super._();

  @override
  final SecurityCheck field0;

  /// Create a copy of QuantumLinkMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $QuantumLinkMessage_SecurityCheckCopyWith<QuantumLinkMessage_SecurityCheck>
      get copyWith => _$QuantumLinkMessage_SecurityCheckCopyWithImpl<
          QuantumLinkMessage_SecurityCheck>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is QuantumLinkMessage_SecurityCheck &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'QuantumLinkMessage.securityCheck(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $QuantumLinkMessage_SecurityCheckCopyWith<$Res>
    implements $QuantumLinkMessageCopyWith<$Res> {
  factory $QuantumLinkMessage_SecurityCheckCopyWith(
          QuantumLinkMessage_SecurityCheck value,
          $Res Function(QuantumLinkMessage_SecurityCheck) _then) =
      _$QuantumLinkMessage_SecurityCheckCopyWithImpl;
  @useResult
  $Res call({SecurityCheck field0});

  $SecurityCheckCopyWith<$Res> get field0;
}

/// @nodoc
class _$QuantumLinkMessage_SecurityCheckCopyWithImpl<$Res>
    implements $QuantumLinkMessage_SecurityCheckCopyWith<$Res> {
  _$QuantumLinkMessage_SecurityCheckCopyWithImpl(this._self, this._then);

  final QuantumLinkMessage_SecurityCheck _self;
  final $Res Function(QuantumLinkMessage_SecurityCheck) _then;

  /// Create a copy of QuantumLinkMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(QuantumLinkMessage_SecurityCheck(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as SecurityCheck,
    ));
  }

  /// Create a copy of QuantumLinkMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SecurityCheckCopyWith<$Res> get field0 {
    return $SecurityCheckCopyWith<$Res>(_self.field0, (value) {
      return _then(_self.copyWith(field0: value));
    });
  }
}

/// @nodoc

class QuantumLinkMessage_OnboardingState extends QuantumLinkMessage {
  const QuantumLinkMessage_OnboardingState(this.field0) : super._();

  @override
  final OnboardingState field0;

  /// Create a copy of QuantumLinkMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $QuantumLinkMessage_OnboardingStateCopyWith<
          QuantumLinkMessage_OnboardingState>
      get copyWith => _$QuantumLinkMessage_OnboardingStateCopyWithImpl<
          QuantumLinkMessage_OnboardingState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is QuantumLinkMessage_OnboardingState &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'QuantumLinkMessage.onboardingState(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $QuantumLinkMessage_OnboardingStateCopyWith<$Res>
    implements $QuantumLinkMessageCopyWith<$Res> {
  factory $QuantumLinkMessage_OnboardingStateCopyWith(
          QuantumLinkMessage_OnboardingState value,
          $Res Function(QuantumLinkMessage_OnboardingState) _then) =
      _$QuantumLinkMessage_OnboardingStateCopyWithImpl;
  @useResult
  $Res call({OnboardingState field0});
}

/// @nodoc
class _$QuantumLinkMessage_OnboardingStateCopyWithImpl<$Res>
    implements $QuantumLinkMessage_OnboardingStateCopyWith<$Res> {
  _$QuantumLinkMessage_OnboardingStateCopyWithImpl(this._self, this._then);

  final QuantumLinkMessage_OnboardingState _self;
  final $Res Function(QuantumLinkMessage_OnboardingState) _then;

  /// Create a copy of QuantumLinkMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(QuantumLinkMessage_OnboardingState(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as OnboardingState,
    ));
  }
}

/// @nodoc

class QuantumLinkMessage_SignPsbt extends QuantumLinkMessage {
  const QuantumLinkMessage_SignPsbt(this.field0) : super._();

  @override
  final SignPsbt field0;

  /// Create a copy of QuantumLinkMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $QuantumLinkMessage_SignPsbtCopyWith<QuantumLinkMessage_SignPsbt>
      get copyWith => _$QuantumLinkMessage_SignPsbtCopyWithImpl<
          QuantumLinkMessage_SignPsbt>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is QuantumLinkMessage_SignPsbt &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'QuantumLinkMessage.signPsbt(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $QuantumLinkMessage_SignPsbtCopyWith<$Res>
    implements $QuantumLinkMessageCopyWith<$Res> {
  factory $QuantumLinkMessage_SignPsbtCopyWith(
          QuantumLinkMessage_SignPsbt value,
          $Res Function(QuantumLinkMessage_SignPsbt) _then) =
      _$QuantumLinkMessage_SignPsbtCopyWithImpl;
  @useResult
  $Res call({SignPsbt field0});
}

/// @nodoc
class _$QuantumLinkMessage_SignPsbtCopyWithImpl<$Res>
    implements $QuantumLinkMessage_SignPsbtCopyWith<$Res> {
  _$QuantumLinkMessage_SignPsbtCopyWithImpl(this._self, this._then);

  final QuantumLinkMessage_SignPsbt _self;
  final $Res Function(QuantumLinkMessage_SignPsbt) _then;

  /// Create a copy of QuantumLinkMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(QuantumLinkMessage_SignPsbt(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as SignPsbt,
    ));
  }
}

/// @nodoc

class QuantumLinkMessage_BroadcastTransaction extends QuantumLinkMessage {
  const QuantumLinkMessage_BroadcastTransaction(this.field0) : super._();

  @override
  final BroadcastTransaction field0;

  /// Create a copy of QuantumLinkMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $QuantumLinkMessage_BroadcastTransactionCopyWith<
          QuantumLinkMessage_BroadcastTransaction>
      get copyWith => _$QuantumLinkMessage_BroadcastTransactionCopyWithImpl<
          QuantumLinkMessage_BroadcastTransaction>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is QuantumLinkMessage_BroadcastTransaction &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'QuantumLinkMessage.broadcastTransaction(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $QuantumLinkMessage_BroadcastTransactionCopyWith<$Res>
    implements $QuantumLinkMessageCopyWith<$Res> {
  factory $QuantumLinkMessage_BroadcastTransactionCopyWith(
          QuantumLinkMessage_BroadcastTransaction value,
          $Res Function(QuantumLinkMessage_BroadcastTransaction) _then) =
      _$QuantumLinkMessage_BroadcastTransactionCopyWithImpl;
  @useResult
  $Res call({BroadcastTransaction field0});
}

/// @nodoc
class _$QuantumLinkMessage_BroadcastTransactionCopyWithImpl<$Res>
    implements $QuantumLinkMessage_BroadcastTransactionCopyWith<$Res> {
  _$QuantumLinkMessage_BroadcastTransactionCopyWithImpl(this._self, this._then);

  final QuantumLinkMessage_BroadcastTransaction _self;
  final $Res Function(QuantumLinkMessage_BroadcastTransaction) _then;

  /// Create a copy of QuantumLinkMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(QuantumLinkMessage_BroadcastTransaction(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as BroadcastTransaction,
    ));
  }
}

/// @nodoc

class QuantumLinkMessage_AccountUpdate extends QuantumLinkMessage {
  const QuantumLinkMessage_AccountUpdate(this.field0) : super._();

  @override
  final AccountUpdate field0;

  /// Create a copy of QuantumLinkMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $QuantumLinkMessage_AccountUpdateCopyWith<QuantumLinkMessage_AccountUpdate>
      get copyWith => _$QuantumLinkMessage_AccountUpdateCopyWithImpl<
          QuantumLinkMessage_AccountUpdate>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is QuantumLinkMessage_AccountUpdate &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'QuantumLinkMessage.accountUpdate(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $QuantumLinkMessage_AccountUpdateCopyWith<$Res>
    implements $QuantumLinkMessageCopyWith<$Res> {
  factory $QuantumLinkMessage_AccountUpdateCopyWith(
          QuantumLinkMessage_AccountUpdate value,
          $Res Function(QuantumLinkMessage_AccountUpdate) _then) =
      _$QuantumLinkMessage_AccountUpdateCopyWithImpl;
  @useResult
  $Res call({AccountUpdate field0});
}

/// @nodoc
class _$QuantumLinkMessage_AccountUpdateCopyWithImpl<$Res>
    implements $QuantumLinkMessage_AccountUpdateCopyWith<$Res> {
  _$QuantumLinkMessage_AccountUpdateCopyWithImpl(this._self, this._then);

  final QuantumLinkMessage_AccountUpdate _self;
  final $Res Function(QuantumLinkMessage_AccountUpdate) _then;

  /// Create a copy of QuantumLinkMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(QuantumLinkMessage_AccountUpdate(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as AccountUpdate,
    ));
  }
}

/// @nodoc

class QuantumLinkMessage_ApplyPassphrase extends QuantumLinkMessage {
  const QuantumLinkMessage_ApplyPassphrase(this.field0) : super._();

  @override
  final ApplyPassphrase field0;

  /// Create a copy of QuantumLinkMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $QuantumLinkMessage_ApplyPassphraseCopyWith<
          QuantumLinkMessage_ApplyPassphrase>
      get copyWith => _$QuantumLinkMessage_ApplyPassphraseCopyWithImpl<
          QuantumLinkMessage_ApplyPassphrase>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is QuantumLinkMessage_ApplyPassphrase &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'QuantumLinkMessage.applyPassphrase(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $QuantumLinkMessage_ApplyPassphraseCopyWith<$Res>
    implements $QuantumLinkMessageCopyWith<$Res> {
  factory $QuantumLinkMessage_ApplyPassphraseCopyWith(
          QuantumLinkMessage_ApplyPassphrase value,
          $Res Function(QuantumLinkMessage_ApplyPassphrase) _then) =
      _$QuantumLinkMessage_ApplyPassphraseCopyWithImpl;
  @useResult
  $Res call({ApplyPassphrase field0});
}

/// @nodoc
class _$QuantumLinkMessage_ApplyPassphraseCopyWithImpl<$Res>
    implements $QuantumLinkMessage_ApplyPassphraseCopyWith<$Res> {
  _$QuantumLinkMessage_ApplyPassphraseCopyWithImpl(this._self, this._then);

  final QuantumLinkMessage_ApplyPassphrase _self;
  final $Res Function(QuantumLinkMessage_ApplyPassphrase) _then;

  /// Create a copy of QuantumLinkMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(QuantumLinkMessage_ApplyPassphrase(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as ApplyPassphrase,
    ));
  }
}

/// @nodoc

class QuantumLinkMessage_EnvoyMagicBackupEnabledRequest
    extends QuantumLinkMessage {
  const QuantumLinkMessage_EnvoyMagicBackupEnabledRequest(this.field0)
      : super._();

  @override
  final EnvoyMagicBackupEnabledRequest field0;

  /// Create a copy of QuantumLinkMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $QuantumLinkMessage_EnvoyMagicBackupEnabledRequestCopyWith<
          QuantumLinkMessage_EnvoyMagicBackupEnabledRequest>
      get copyWith =>
          _$QuantumLinkMessage_EnvoyMagicBackupEnabledRequestCopyWithImpl<
                  QuantumLinkMessage_EnvoyMagicBackupEnabledRequest>(
              this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is QuantumLinkMessage_EnvoyMagicBackupEnabledRequest &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'QuantumLinkMessage.envoyMagicBackupEnabledRequest(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $QuantumLinkMessage_EnvoyMagicBackupEnabledRequestCopyWith<
    $Res> implements $QuantumLinkMessageCopyWith<$Res> {
  factory $QuantumLinkMessage_EnvoyMagicBackupEnabledRequestCopyWith(
          QuantumLinkMessage_EnvoyMagicBackupEnabledRequest value,
          $Res Function(QuantumLinkMessage_EnvoyMagicBackupEnabledRequest)
              _then) =
      _$QuantumLinkMessage_EnvoyMagicBackupEnabledRequestCopyWithImpl;
  @useResult
  $Res call({EnvoyMagicBackupEnabledRequest field0});
}

/// @nodoc
class _$QuantumLinkMessage_EnvoyMagicBackupEnabledRequestCopyWithImpl<$Res>
    implements
        $QuantumLinkMessage_EnvoyMagicBackupEnabledRequestCopyWith<$Res> {
  _$QuantumLinkMessage_EnvoyMagicBackupEnabledRequestCopyWithImpl(
      this._self, this._then);

  final QuantumLinkMessage_EnvoyMagicBackupEnabledRequest _self;
  final $Res Function(QuantumLinkMessage_EnvoyMagicBackupEnabledRequest) _then;

  /// Create a copy of QuantumLinkMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(QuantumLinkMessage_EnvoyMagicBackupEnabledRequest(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as EnvoyMagicBackupEnabledRequest,
    ));
  }
}

/// @nodoc

class QuantumLinkMessage_EnvoyMagicBackupEnabledResponse
    extends QuantumLinkMessage {
  const QuantumLinkMessage_EnvoyMagicBackupEnabledResponse(this.field0)
      : super._();

  @override
  final EnvoyMagicBackupEnabledResponse field0;

  /// Create a copy of QuantumLinkMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $QuantumLinkMessage_EnvoyMagicBackupEnabledResponseCopyWith<
          QuantumLinkMessage_EnvoyMagicBackupEnabledResponse>
      get copyWith =>
          _$QuantumLinkMessage_EnvoyMagicBackupEnabledResponseCopyWithImpl<
                  QuantumLinkMessage_EnvoyMagicBackupEnabledResponse>(
              this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is QuantumLinkMessage_EnvoyMagicBackupEnabledResponse &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'QuantumLinkMessage.envoyMagicBackupEnabledResponse(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $QuantumLinkMessage_EnvoyMagicBackupEnabledResponseCopyWith<
    $Res> implements $QuantumLinkMessageCopyWith<$Res> {
  factory $QuantumLinkMessage_EnvoyMagicBackupEnabledResponseCopyWith(
          QuantumLinkMessage_EnvoyMagicBackupEnabledResponse value,
          $Res Function(QuantumLinkMessage_EnvoyMagicBackupEnabledResponse)
              _then) =
      _$QuantumLinkMessage_EnvoyMagicBackupEnabledResponseCopyWithImpl;
  @useResult
  $Res call({EnvoyMagicBackupEnabledResponse field0});
}

/// @nodoc
class _$QuantumLinkMessage_EnvoyMagicBackupEnabledResponseCopyWithImpl<$Res>
    implements
        $QuantumLinkMessage_EnvoyMagicBackupEnabledResponseCopyWith<$Res> {
  _$QuantumLinkMessage_EnvoyMagicBackupEnabledResponseCopyWithImpl(
      this._self, this._then);

  final QuantumLinkMessage_EnvoyMagicBackupEnabledResponse _self;
  final $Res Function(QuantumLinkMessage_EnvoyMagicBackupEnabledResponse) _then;

  /// Create a copy of QuantumLinkMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(QuantumLinkMessage_EnvoyMagicBackupEnabledResponse(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as EnvoyMagicBackupEnabledResponse,
    ));
  }
}

/// @nodoc

class QuantumLinkMessage_PrimeMagicBackupEnabled extends QuantumLinkMessage {
  const QuantumLinkMessage_PrimeMagicBackupEnabled(this.field0) : super._();

  @override
  final PrimeMagicBackupEnabled field0;

  /// Create a copy of QuantumLinkMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $QuantumLinkMessage_PrimeMagicBackupEnabledCopyWith<
          QuantumLinkMessage_PrimeMagicBackupEnabled>
      get copyWith => _$QuantumLinkMessage_PrimeMagicBackupEnabledCopyWithImpl<
          QuantumLinkMessage_PrimeMagicBackupEnabled>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is QuantumLinkMessage_PrimeMagicBackupEnabled &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'QuantumLinkMessage.primeMagicBackupEnabled(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $QuantumLinkMessage_PrimeMagicBackupEnabledCopyWith<$Res>
    implements $QuantumLinkMessageCopyWith<$Res> {
  factory $QuantumLinkMessage_PrimeMagicBackupEnabledCopyWith(
          QuantumLinkMessage_PrimeMagicBackupEnabled value,
          $Res Function(QuantumLinkMessage_PrimeMagicBackupEnabled) _then) =
      _$QuantumLinkMessage_PrimeMagicBackupEnabledCopyWithImpl;
  @useResult
  $Res call({PrimeMagicBackupEnabled field0});
}

/// @nodoc
class _$QuantumLinkMessage_PrimeMagicBackupEnabledCopyWithImpl<$Res>
    implements $QuantumLinkMessage_PrimeMagicBackupEnabledCopyWith<$Res> {
  _$QuantumLinkMessage_PrimeMagicBackupEnabledCopyWithImpl(
      this._self, this._then);

  final QuantumLinkMessage_PrimeMagicBackupEnabled _self;
  final $Res Function(QuantumLinkMessage_PrimeMagicBackupEnabled) _then;

  /// Create a copy of QuantumLinkMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(QuantumLinkMessage_PrimeMagicBackupEnabled(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as PrimeMagicBackupEnabled,
    ));
  }
}

/// @nodoc

class QuantumLinkMessage_PrimeMagicBackupStatusRequest
    extends QuantumLinkMessage {
  const QuantumLinkMessage_PrimeMagicBackupStatusRequest(this.field0)
      : super._();

  @override
  final PrimeMagicBackupStatusRequest field0;

  /// Create a copy of QuantumLinkMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $QuantumLinkMessage_PrimeMagicBackupStatusRequestCopyWith<
          QuantumLinkMessage_PrimeMagicBackupStatusRequest>
      get copyWith =>
          _$QuantumLinkMessage_PrimeMagicBackupStatusRequestCopyWithImpl<
                  QuantumLinkMessage_PrimeMagicBackupStatusRequest>(
              this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is QuantumLinkMessage_PrimeMagicBackupStatusRequest &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'QuantumLinkMessage.primeMagicBackupStatusRequest(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $QuantumLinkMessage_PrimeMagicBackupStatusRequestCopyWith<
    $Res> implements $QuantumLinkMessageCopyWith<$Res> {
  factory $QuantumLinkMessage_PrimeMagicBackupStatusRequestCopyWith(
          QuantumLinkMessage_PrimeMagicBackupStatusRequest value,
          $Res Function(QuantumLinkMessage_PrimeMagicBackupStatusRequest)
              _then) =
      _$QuantumLinkMessage_PrimeMagicBackupStatusRequestCopyWithImpl;
  @useResult
  $Res call({PrimeMagicBackupStatusRequest field0});
}

/// @nodoc
class _$QuantumLinkMessage_PrimeMagicBackupStatusRequestCopyWithImpl<$Res>
    implements $QuantumLinkMessage_PrimeMagicBackupStatusRequestCopyWith<$Res> {
  _$QuantumLinkMessage_PrimeMagicBackupStatusRequestCopyWithImpl(
      this._self, this._then);

  final QuantumLinkMessage_PrimeMagicBackupStatusRequest _self;
  final $Res Function(QuantumLinkMessage_PrimeMagicBackupStatusRequest) _then;

  /// Create a copy of QuantumLinkMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(QuantumLinkMessage_PrimeMagicBackupStatusRequest(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as PrimeMagicBackupStatusRequest,
    ));
  }
}

/// @nodoc

class QuantumLinkMessage_PrimeMagicBackupStatusResponse
    extends QuantumLinkMessage {
  const QuantumLinkMessage_PrimeMagicBackupStatusResponse(this.field0)
      : super._();

  @override
  final PrimeMagicBackupStatusResponse field0;

  /// Create a copy of QuantumLinkMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $QuantumLinkMessage_PrimeMagicBackupStatusResponseCopyWith<
          QuantumLinkMessage_PrimeMagicBackupStatusResponse>
      get copyWith =>
          _$QuantumLinkMessage_PrimeMagicBackupStatusResponseCopyWithImpl<
                  QuantumLinkMessage_PrimeMagicBackupStatusResponse>(
              this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is QuantumLinkMessage_PrimeMagicBackupStatusResponse &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'QuantumLinkMessage.primeMagicBackupStatusResponse(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $QuantumLinkMessage_PrimeMagicBackupStatusResponseCopyWith<
    $Res> implements $QuantumLinkMessageCopyWith<$Res> {
  factory $QuantumLinkMessage_PrimeMagicBackupStatusResponseCopyWith(
          QuantumLinkMessage_PrimeMagicBackupStatusResponse value,
          $Res Function(QuantumLinkMessage_PrimeMagicBackupStatusResponse)
              _then) =
      _$QuantumLinkMessage_PrimeMagicBackupStatusResponseCopyWithImpl;
  @useResult
  $Res call({PrimeMagicBackupStatusResponse field0});
}

/// @nodoc
class _$QuantumLinkMessage_PrimeMagicBackupStatusResponseCopyWithImpl<$Res>
    implements
        $QuantumLinkMessage_PrimeMagicBackupStatusResponseCopyWith<$Res> {
  _$QuantumLinkMessage_PrimeMagicBackupStatusResponseCopyWithImpl(
      this._self, this._then);

  final QuantumLinkMessage_PrimeMagicBackupStatusResponse _self;
  final $Res Function(QuantumLinkMessage_PrimeMagicBackupStatusResponse) _then;

  /// Create a copy of QuantumLinkMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(QuantumLinkMessage_PrimeMagicBackupStatusResponse(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as PrimeMagicBackupStatusResponse,
    ));
  }
}

/// @nodoc

class QuantumLinkMessage_BackupShardRequest extends QuantumLinkMessage {
  const QuantumLinkMessage_BackupShardRequest(this.field0) : super._();

  @override
  final BackupShardRequest field0;

  /// Create a copy of QuantumLinkMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $QuantumLinkMessage_BackupShardRequestCopyWith<
          QuantumLinkMessage_BackupShardRequest>
      get copyWith => _$QuantumLinkMessage_BackupShardRequestCopyWithImpl<
          QuantumLinkMessage_BackupShardRequest>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is QuantumLinkMessage_BackupShardRequest &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'QuantumLinkMessage.backupShardRequest(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $QuantumLinkMessage_BackupShardRequestCopyWith<$Res>
    implements $QuantumLinkMessageCopyWith<$Res> {
  factory $QuantumLinkMessage_BackupShardRequestCopyWith(
          QuantumLinkMessage_BackupShardRequest value,
          $Res Function(QuantumLinkMessage_BackupShardRequest) _then) =
      _$QuantumLinkMessage_BackupShardRequestCopyWithImpl;
  @useResult
  $Res call({BackupShardRequest field0});
}

/// @nodoc
class _$QuantumLinkMessage_BackupShardRequestCopyWithImpl<$Res>
    implements $QuantumLinkMessage_BackupShardRequestCopyWith<$Res> {
  _$QuantumLinkMessage_BackupShardRequestCopyWithImpl(this._self, this._then);

  final QuantumLinkMessage_BackupShardRequest _self;
  final $Res Function(QuantumLinkMessage_BackupShardRequest) _then;

  /// Create a copy of QuantumLinkMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(QuantumLinkMessage_BackupShardRequest(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as BackupShardRequest,
    ));
  }
}

/// @nodoc

class QuantumLinkMessage_BackupShardResponse extends QuantumLinkMessage {
  const QuantumLinkMessage_BackupShardResponse(this.field0) : super._();

  @override
  final BackupShardResponse field0;

  /// Create a copy of QuantumLinkMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $QuantumLinkMessage_BackupShardResponseCopyWith<
          QuantumLinkMessage_BackupShardResponse>
      get copyWith => _$QuantumLinkMessage_BackupShardResponseCopyWithImpl<
          QuantumLinkMessage_BackupShardResponse>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is QuantumLinkMessage_BackupShardResponse &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'QuantumLinkMessage.backupShardResponse(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $QuantumLinkMessage_BackupShardResponseCopyWith<$Res>
    implements $QuantumLinkMessageCopyWith<$Res> {
  factory $QuantumLinkMessage_BackupShardResponseCopyWith(
          QuantumLinkMessage_BackupShardResponse value,
          $Res Function(QuantumLinkMessage_BackupShardResponse) _then) =
      _$QuantumLinkMessage_BackupShardResponseCopyWithImpl;
  @useResult
  $Res call({BackupShardResponse field0});

  $BackupShardResponseCopyWith<$Res> get field0;
}

/// @nodoc
class _$QuantumLinkMessage_BackupShardResponseCopyWithImpl<$Res>
    implements $QuantumLinkMessage_BackupShardResponseCopyWith<$Res> {
  _$QuantumLinkMessage_BackupShardResponseCopyWithImpl(this._self, this._then);

  final QuantumLinkMessage_BackupShardResponse _self;
  final $Res Function(QuantumLinkMessage_BackupShardResponse) _then;

  /// Create a copy of QuantumLinkMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(QuantumLinkMessage_BackupShardResponse(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as BackupShardResponse,
    ));
  }

  /// Create a copy of QuantumLinkMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BackupShardResponseCopyWith<$Res> get field0 {
    return $BackupShardResponseCopyWith<$Res>(_self.field0, (value) {
      return _then(_self.copyWith(field0: value));
    });
  }
}

/// @nodoc

class QuantumLinkMessage_RestoreShardRequest extends QuantumLinkMessage {
  const QuantumLinkMessage_RestoreShardRequest(this.field0) : super._();

  @override
  final RestoreShardRequest field0;

  /// Create a copy of QuantumLinkMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $QuantumLinkMessage_RestoreShardRequestCopyWith<
          QuantumLinkMessage_RestoreShardRequest>
      get copyWith => _$QuantumLinkMessage_RestoreShardRequestCopyWithImpl<
          QuantumLinkMessage_RestoreShardRequest>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is QuantumLinkMessage_RestoreShardRequest &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'QuantumLinkMessage.restoreShardRequest(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $QuantumLinkMessage_RestoreShardRequestCopyWith<$Res>
    implements $QuantumLinkMessageCopyWith<$Res> {
  factory $QuantumLinkMessage_RestoreShardRequestCopyWith(
          QuantumLinkMessage_RestoreShardRequest value,
          $Res Function(QuantumLinkMessage_RestoreShardRequest) _then) =
      _$QuantumLinkMessage_RestoreShardRequestCopyWithImpl;
  @useResult
  $Res call({RestoreShardRequest field0});
}

/// @nodoc
class _$QuantumLinkMessage_RestoreShardRequestCopyWithImpl<$Res>
    implements $QuantumLinkMessage_RestoreShardRequestCopyWith<$Res> {
  _$QuantumLinkMessage_RestoreShardRequestCopyWithImpl(this._self, this._then);

  final QuantumLinkMessage_RestoreShardRequest _self;
  final $Res Function(QuantumLinkMessage_RestoreShardRequest) _then;

  /// Create a copy of QuantumLinkMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(QuantumLinkMessage_RestoreShardRequest(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as RestoreShardRequest,
    ));
  }
}

/// @nodoc

class QuantumLinkMessage_RestoreShardResponse extends QuantumLinkMessage {
  const QuantumLinkMessage_RestoreShardResponse(this.field0) : super._();

  @override
  final RestoreShardResponse field0;

  /// Create a copy of QuantumLinkMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $QuantumLinkMessage_RestoreShardResponseCopyWith<
          QuantumLinkMessage_RestoreShardResponse>
      get copyWith => _$QuantumLinkMessage_RestoreShardResponseCopyWithImpl<
          QuantumLinkMessage_RestoreShardResponse>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is QuantumLinkMessage_RestoreShardResponse &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'QuantumLinkMessage.restoreShardResponse(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $QuantumLinkMessage_RestoreShardResponseCopyWith<$Res>
    implements $QuantumLinkMessageCopyWith<$Res> {
  factory $QuantumLinkMessage_RestoreShardResponseCopyWith(
          QuantumLinkMessage_RestoreShardResponse value,
          $Res Function(QuantumLinkMessage_RestoreShardResponse) _then) =
      _$QuantumLinkMessage_RestoreShardResponseCopyWithImpl;
  @useResult
  $Res call({RestoreShardResponse field0});

  $RestoreShardResponseCopyWith<$Res> get field0;
}

/// @nodoc
class _$QuantumLinkMessage_RestoreShardResponseCopyWithImpl<$Res>
    implements $QuantumLinkMessage_RestoreShardResponseCopyWith<$Res> {
  _$QuantumLinkMessage_RestoreShardResponseCopyWithImpl(this._self, this._then);

  final QuantumLinkMessage_RestoreShardResponse _self;
  final $Res Function(QuantumLinkMessage_RestoreShardResponse) _then;

  /// Create a copy of QuantumLinkMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(QuantumLinkMessage_RestoreShardResponse(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as RestoreShardResponse,
    ));
  }

  /// Create a copy of QuantumLinkMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RestoreShardResponseCopyWith<$Res> get field0 {
    return $RestoreShardResponseCopyWith<$Res>(_self.field0, (value) {
      return _then(_self.copyWith(field0: value));
    });
  }
}

/// @nodoc

class QuantumLinkMessage_CreateMagicBackupEvent extends QuantumLinkMessage {
  const QuantumLinkMessage_CreateMagicBackupEvent(this.field0) : super._();

  @override
  final CreateMagicBackupEvent field0;

  /// Create a copy of QuantumLinkMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $QuantumLinkMessage_CreateMagicBackupEventCopyWith<
          QuantumLinkMessage_CreateMagicBackupEvent>
      get copyWith => _$QuantumLinkMessage_CreateMagicBackupEventCopyWithImpl<
          QuantumLinkMessage_CreateMagicBackupEvent>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is QuantumLinkMessage_CreateMagicBackupEvent &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'QuantumLinkMessage.createMagicBackupEvent(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $QuantumLinkMessage_CreateMagicBackupEventCopyWith<$Res>
    implements $QuantumLinkMessageCopyWith<$Res> {
  factory $QuantumLinkMessage_CreateMagicBackupEventCopyWith(
          QuantumLinkMessage_CreateMagicBackupEvent value,
          $Res Function(QuantumLinkMessage_CreateMagicBackupEvent) _then) =
      _$QuantumLinkMessage_CreateMagicBackupEventCopyWithImpl;
  @useResult
  $Res call({CreateMagicBackupEvent field0});

  $CreateMagicBackupEventCopyWith<$Res> get field0;
}

/// @nodoc
class _$QuantumLinkMessage_CreateMagicBackupEventCopyWithImpl<$Res>
    implements $QuantumLinkMessage_CreateMagicBackupEventCopyWith<$Res> {
  _$QuantumLinkMessage_CreateMagicBackupEventCopyWithImpl(
      this._self, this._then);

  final QuantumLinkMessage_CreateMagicBackupEvent _self;
  final $Res Function(QuantumLinkMessage_CreateMagicBackupEvent) _then;

  /// Create a copy of QuantumLinkMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(QuantumLinkMessage_CreateMagicBackupEvent(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as CreateMagicBackupEvent,
    ));
  }

  /// Create a copy of QuantumLinkMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CreateMagicBackupEventCopyWith<$Res> get field0 {
    return $CreateMagicBackupEventCopyWith<$Res>(_self.field0, (value) {
      return _then(_self.copyWith(field0: value));
    });
  }
}

/// @nodoc

class QuantumLinkMessage_CreateMagicBackupResult extends QuantumLinkMessage {
  const QuantumLinkMessage_CreateMagicBackupResult(this.field0) : super._();

  @override
  final CreateMagicBackupResult field0;

  /// Create a copy of QuantumLinkMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $QuantumLinkMessage_CreateMagicBackupResultCopyWith<
          QuantumLinkMessage_CreateMagicBackupResult>
      get copyWith => _$QuantumLinkMessage_CreateMagicBackupResultCopyWithImpl<
          QuantumLinkMessage_CreateMagicBackupResult>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is QuantumLinkMessage_CreateMagicBackupResult &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'QuantumLinkMessage.createMagicBackupResult(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $QuantumLinkMessage_CreateMagicBackupResultCopyWith<$Res>
    implements $QuantumLinkMessageCopyWith<$Res> {
  factory $QuantumLinkMessage_CreateMagicBackupResultCopyWith(
          QuantumLinkMessage_CreateMagicBackupResult value,
          $Res Function(QuantumLinkMessage_CreateMagicBackupResult) _then) =
      _$QuantumLinkMessage_CreateMagicBackupResultCopyWithImpl;
  @useResult
  $Res call({CreateMagicBackupResult field0});

  $CreateMagicBackupResultCopyWith<$Res> get field0;
}

/// @nodoc
class _$QuantumLinkMessage_CreateMagicBackupResultCopyWithImpl<$Res>
    implements $QuantumLinkMessage_CreateMagicBackupResultCopyWith<$Res> {
  _$QuantumLinkMessage_CreateMagicBackupResultCopyWithImpl(
      this._self, this._then);

  final QuantumLinkMessage_CreateMagicBackupResult _self;
  final $Res Function(QuantumLinkMessage_CreateMagicBackupResult) _then;

  /// Create a copy of QuantumLinkMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(QuantumLinkMessage_CreateMagicBackupResult(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as CreateMagicBackupResult,
    ));
  }

  /// Create a copy of QuantumLinkMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CreateMagicBackupResultCopyWith<$Res> get field0 {
    return $CreateMagicBackupResultCopyWith<$Res>(_self.field0, (value) {
      return _then(_self.copyWith(field0: value));
    });
  }
}

/// @nodoc

class QuantumLinkMessage_RestoreMagicBackupRequest extends QuantumLinkMessage {
  const QuantumLinkMessage_RestoreMagicBackupRequest(this.field0) : super._();

  @override
  final RestoreMagicBackupRequest field0;

  /// Create a copy of QuantumLinkMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $QuantumLinkMessage_RestoreMagicBackupRequestCopyWith<
          QuantumLinkMessage_RestoreMagicBackupRequest>
      get copyWith =>
          _$QuantumLinkMessage_RestoreMagicBackupRequestCopyWithImpl<
              QuantumLinkMessage_RestoreMagicBackupRequest>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is QuantumLinkMessage_RestoreMagicBackupRequest &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'QuantumLinkMessage.restoreMagicBackupRequest(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $QuantumLinkMessage_RestoreMagicBackupRequestCopyWith<$Res>
    implements $QuantumLinkMessageCopyWith<$Res> {
  factory $QuantumLinkMessage_RestoreMagicBackupRequestCopyWith(
          QuantumLinkMessage_RestoreMagicBackupRequest value,
          $Res Function(QuantumLinkMessage_RestoreMagicBackupRequest) _then) =
      _$QuantumLinkMessage_RestoreMagicBackupRequestCopyWithImpl;
  @useResult
  $Res call({RestoreMagicBackupRequest field0});
}

/// @nodoc
class _$QuantumLinkMessage_RestoreMagicBackupRequestCopyWithImpl<$Res>
    implements $QuantumLinkMessage_RestoreMagicBackupRequestCopyWith<$Res> {
  _$QuantumLinkMessage_RestoreMagicBackupRequestCopyWithImpl(
      this._self, this._then);

  final QuantumLinkMessage_RestoreMagicBackupRequest _self;
  final $Res Function(QuantumLinkMessage_RestoreMagicBackupRequest) _then;

  /// Create a copy of QuantumLinkMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(QuantumLinkMessage_RestoreMagicBackupRequest(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as RestoreMagicBackupRequest,
    ));
  }
}

/// @nodoc

class QuantumLinkMessage_RestoreMagicBackupEvent extends QuantumLinkMessage {
  const QuantumLinkMessage_RestoreMagicBackupEvent(this.field0) : super._();

  @override
  final RestoreMagicBackupEvent field0;

  /// Create a copy of QuantumLinkMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $QuantumLinkMessage_RestoreMagicBackupEventCopyWith<
          QuantumLinkMessage_RestoreMagicBackupEvent>
      get copyWith => _$QuantumLinkMessage_RestoreMagicBackupEventCopyWithImpl<
          QuantumLinkMessage_RestoreMagicBackupEvent>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is QuantumLinkMessage_RestoreMagicBackupEvent &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'QuantumLinkMessage.restoreMagicBackupEvent(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $QuantumLinkMessage_RestoreMagicBackupEventCopyWith<$Res>
    implements $QuantumLinkMessageCopyWith<$Res> {
  factory $QuantumLinkMessage_RestoreMagicBackupEventCopyWith(
          QuantumLinkMessage_RestoreMagicBackupEvent value,
          $Res Function(QuantumLinkMessage_RestoreMagicBackupEvent) _then) =
      _$QuantumLinkMessage_RestoreMagicBackupEventCopyWithImpl;
  @useResult
  $Res call({RestoreMagicBackupEvent field0});

  $RestoreMagicBackupEventCopyWith<$Res> get field0;
}

/// @nodoc
class _$QuantumLinkMessage_RestoreMagicBackupEventCopyWithImpl<$Res>
    implements $QuantumLinkMessage_RestoreMagicBackupEventCopyWith<$Res> {
  _$QuantumLinkMessage_RestoreMagicBackupEventCopyWithImpl(
      this._self, this._then);

  final QuantumLinkMessage_RestoreMagicBackupEvent _self;
  final $Res Function(QuantumLinkMessage_RestoreMagicBackupEvent) _then;

  /// Create a copy of QuantumLinkMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(QuantumLinkMessage_RestoreMagicBackupEvent(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as RestoreMagicBackupEvent,
    ));
  }

  /// Create a copy of QuantumLinkMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RestoreMagicBackupEventCopyWith<$Res> get field0 {
    return $RestoreMagicBackupEventCopyWith<$Res>(_self.field0, (value) {
      return _then(_self.copyWith(field0: value));
    });
  }
}

/// @nodoc

class QuantumLinkMessage_RestoreMagicBackupResult extends QuantumLinkMessage {
  const QuantumLinkMessage_RestoreMagicBackupResult(this.field0) : super._();

  @override
  final RestoreMagicBackupResult field0;

  /// Create a copy of QuantumLinkMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $QuantumLinkMessage_RestoreMagicBackupResultCopyWith<
          QuantumLinkMessage_RestoreMagicBackupResult>
      get copyWith => _$QuantumLinkMessage_RestoreMagicBackupResultCopyWithImpl<
          QuantumLinkMessage_RestoreMagicBackupResult>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is QuantumLinkMessage_RestoreMagicBackupResult &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'QuantumLinkMessage.restoreMagicBackupResult(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $QuantumLinkMessage_RestoreMagicBackupResultCopyWith<$Res>
    implements $QuantumLinkMessageCopyWith<$Res> {
  factory $QuantumLinkMessage_RestoreMagicBackupResultCopyWith(
          QuantumLinkMessage_RestoreMagicBackupResult value,
          $Res Function(QuantumLinkMessage_RestoreMagicBackupResult) _then) =
      _$QuantumLinkMessage_RestoreMagicBackupResultCopyWithImpl;
  @useResult
  $Res call({RestoreMagicBackupResult field0});

  $RestoreMagicBackupResultCopyWith<$Res> get field0;
}

/// @nodoc
class _$QuantumLinkMessage_RestoreMagicBackupResultCopyWithImpl<$Res>
    implements $QuantumLinkMessage_RestoreMagicBackupResultCopyWith<$Res> {
  _$QuantumLinkMessage_RestoreMagicBackupResultCopyWithImpl(
      this._self, this._then);

  final QuantumLinkMessage_RestoreMagicBackupResult _self;
  final $Res Function(QuantumLinkMessage_RestoreMagicBackupResult) _then;

  /// Create a copy of QuantumLinkMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(QuantumLinkMessage_RestoreMagicBackupResult(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as RestoreMagicBackupResult,
    ));
  }

  /// Create a copy of QuantumLinkMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RestoreMagicBackupResultCopyWith<$Res> get field0 {
    return $RestoreMagicBackupResultCopyWith<$Res>(_self.field0, (value) {
      return _then(_self.copyWith(field0: value));
    });
  }
}

/// @nodoc

class QuantumLinkMessage_Heartbeat extends QuantumLinkMessage {
  const QuantumLinkMessage_Heartbeat(this.field0) : super._();

  @override
  final Heartbeat field0;

  /// Create a copy of QuantumLinkMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $QuantumLinkMessage_HeartbeatCopyWith<QuantumLinkMessage_Heartbeat>
      get copyWith => _$QuantumLinkMessage_HeartbeatCopyWithImpl<
          QuantumLinkMessage_Heartbeat>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is QuantumLinkMessage_Heartbeat &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'QuantumLinkMessage.heartbeat(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $QuantumLinkMessage_HeartbeatCopyWith<$Res>
    implements $QuantumLinkMessageCopyWith<$Res> {
  factory $QuantumLinkMessage_HeartbeatCopyWith(
          QuantumLinkMessage_Heartbeat value,
          $Res Function(QuantumLinkMessage_Heartbeat) _then) =
      _$QuantumLinkMessage_HeartbeatCopyWithImpl;
  @useResult
  $Res call({Heartbeat field0});
}

/// @nodoc
class _$QuantumLinkMessage_HeartbeatCopyWithImpl<$Res>
    implements $QuantumLinkMessage_HeartbeatCopyWith<$Res> {
  _$QuantumLinkMessage_HeartbeatCopyWithImpl(this._self, this._then);

  final QuantumLinkMessage_Heartbeat _self;
  final $Res Function(QuantumLinkMessage_Heartbeat) _then;

  /// Create a copy of QuantumLinkMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(QuantumLinkMessage_Heartbeat(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as Heartbeat,
    ));
  }
}

/// @nodoc

class QuantumLinkMessage_TimezoneRequest extends QuantumLinkMessage {
  const QuantumLinkMessage_TimezoneRequest(this.field0) : super._();

  @override
  final TimezoneRequest field0;

  /// Create a copy of QuantumLinkMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $QuantumLinkMessage_TimezoneRequestCopyWith<
          QuantumLinkMessage_TimezoneRequest>
      get copyWith => _$QuantumLinkMessage_TimezoneRequestCopyWithImpl<
          QuantumLinkMessage_TimezoneRequest>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is QuantumLinkMessage_TimezoneRequest &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'QuantumLinkMessage.timezoneRequest(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $QuantumLinkMessage_TimezoneRequestCopyWith<$Res>
    implements $QuantumLinkMessageCopyWith<$Res> {
  factory $QuantumLinkMessage_TimezoneRequestCopyWith(
          QuantumLinkMessage_TimezoneRequest value,
          $Res Function(QuantumLinkMessage_TimezoneRequest) _then) =
      _$QuantumLinkMessage_TimezoneRequestCopyWithImpl;
  @useResult
  $Res call({TimezoneRequest field0});
}

/// @nodoc
class _$QuantumLinkMessage_TimezoneRequestCopyWithImpl<$Res>
    implements $QuantumLinkMessage_TimezoneRequestCopyWith<$Res> {
  _$QuantumLinkMessage_TimezoneRequestCopyWithImpl(this._self, this._then);

  final QuantumLinkMessage_TimezoneRequest _self;
  final $Res Function(QuantumLinkMessage_TimezoneRequest) _then;

  /// Create a copy of QuantumLinkMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(QuantumLinkMessage_TimezoneRequest(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as TimezoneRequest,
    ));
  }
}

/// @nodoc

class QuantumLinkMessage_TimezoneResponse extends QuantumLinkMessage {
  const QuantumLinkMessage_TimezoneResponse(this.field0) : super._();

  @override
  final TimezoneResponse field0;

  /// Create a copy of QuantumLinkMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $QuantumLinkMessage_TimezoneResponseCopyWith<
          QuantumLinkMessage_TimezoneResponse>
      get copyWith => _$QuantumLinkMessage_TimezoneResponseCopyWithImpl<
          QuantumLinkMessage_TimezoneResponse>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is QuantumLinkMessage_TimezoneResponse &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'QuantumLinkMessage.timezoneResponse(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $QuantumLinkMessage_TimezoneResponseCopyWith<$Res>
    implements $QuantumLinkMessageCopyWith<$Res> {
  factory $QuantumLinkMessage_TimezoneResponseCopyWith(
          QuantumLinkMessage_TimezoneResponse value,
          $Res Function(QuantumLinkMessage_TimezoneResponse) _then) =
      _$QuantumLinkMessage_TimezoneResponseCopyWithImpl;
  @useResult
  $Res call({TimezoneResponse field0});
}

/// @nodoc
class _$QuantumLinkMessage_TimezoneResponseCopyWithImpl<$Res>
    implements $QuantumLinkMessage_TimezoneResponseCopyWith<$Res> {
  _$QuantumLinkMessage_TimezoneResponseCopyWithImpl(this._self, this._then);

  final QuantumLinkMessage_TimezoneResponse _self;
  final $Res Function(QuantumLinkMessage_TimezoneResponse) _then;

  /// Create a copy of QuantumLinkMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(QuantumLinkMessage_TimezoneResponse(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as TimezoneResponse,
    ));
  }
}

/// @nodoc

class QuantumLinkMessage_UnpairingRequest extends QuantumLinkMessage {
  const QuantumLinkMessage_UnpairingRequest(this.field0) : super._();

  @override
  final UnpairingRequest field0;

  /// Create a copy of QuantumLinkMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $QuantumLinkMessage_UnpairingRequestCopyWith<
          QuantumLinkMessage_UnpairingRequest>
      get copyWith => _$QuantumLinkMessage_UnpairingRequestCopyWithImpl<
          QuantumLinkMessage_UnpairingRequest>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is QuantumLinkMessage_UnpairingRequest &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'QuantumLinkMessage.unpairingRequest(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $QuantumLinkMessage_UnpairingRequestCopyWith<$Res>
    implements $QuantumLinkMessageCopyWith<$Res> {
  factory $QuantumLinkMessage_UnpairingRequestCopyWith(
          QuantumLinkMessage_UnpairingRequest value,
          $Res Function(QuantumLinkMessage_UnpairingRequest) _then) =
      _$QuantumLinkMessage_UnpairingRequestCopyWithImpl;
  @useResult
  $Res call({UnpairingRequest field0});
}

/// @nodoc
class _$QuantumLinkMessage_UnpairingRequestCopyWithImpl<$Res>
    implements $QuantumLinkMessage_UnpairingRequestCopyWith<$Res> {
  _$QuantumLinkMessage_UnpairingRequestCopyWithImpl(this._self, this._then);

  final QuantumLinkMessage_UnpairingRequest _self;
  final $Res Function(QuantumLinkMessage_UnpairingRequest) _then;

  /// Create a copy of QuantumLinkMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(QuantumLinkMessage_UnpairingRequest(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as UnpairingRequest,
    ));
  }
}

/// @nodoc

class QuantumLinkMessage_UnpairingResponse extends QuantumLinkMessage {
  const QuantumLinkMessage_UnpairingResponse(this.field0) : super._();

  @override
  final UnpairingResponse field0;

  /// Create a copy of QuantumLinkMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $QuantumLinkMessage_UnpairingResponseCopyWith<
          QuantumLinkMessage_UnpairingResponse>
      get copyWith => _$QuantumLinkMessage_UnpairingResponseCopyWithImpl<
          QuantumLinkMessage_UnpairingResponse>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is QuantumLinkMessage_UnpairingResponse &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'QuantumLinkMessage.unpairingResponse(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $QuantumLinkMessage_UnpairingResponseCopyWith<$Res>
    implements $QuantumLinkMessageCopyWith<$Res> {
  factory $QuantumLinkMessage_UnpairingResponseCopyWith(
          QuantumLinkMessage_UnpairingResponse value,
          $Res Function(QuantumLinkMessage_UnpairingResponse) _then) =
      _$QuantumLinkMessage_UnpairingResponseCopyWithImpl;
  @useResult
  $Res call({UnpairingResponse field0});
}

/// @nodoc
class _$QuantumLinkMessage_UnpairingResponseCopyWithImpl<$Res>
    implements $QuantumLinkMessage_UnpairingResponseCopyWith<$Res> {
  _$QuantumLinkMessage_UnpairingResponseCopyWithImpl(this._self, this._then);

  final QuantumLinkMessage_UnpairingResponse _self;
  final $Res Function(QuantumLinkMessage_UnpairingResponse) _then;

  /// Create a copy of QuantumLinkMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(QuantumLinkMessage_UnpairingResponse(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as UnpairingResponse,
    ));
  }
}

/// @nodoc

class QuantumLinkMessage_DeviceNameUpdate extends QuantumLinkMessage {
  const QuantumLinkMessage_DeviceNameUpdate(this.field0) : super._();

  @override
  final DeviceNameUpdate field0;

  /// Create a copy of QuantumLinkMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $QuantumLinkMessage_DeviceNameUpdateCopyWith<
          QuantumLinkMessage_DeviceNameUpdate>
      get copyWith => _$QuantumLinkMessage_DeviceNameUpdateCopyWithImpl<
          QuantumLinkMessage_DeviceNameUpdate>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is QuantumLinkMessage_DeviceNameUpdate &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'QuantumLinkMessage.deviceNameUpdate(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $QuantumLinkMessage_DeviceNameUpdateCopyWith<$Res>
    implements $QuantumLinkMessageCopyWith<$Res> {
  factory $QuantumLinkMessage_DeviceNameUpdateCopyWith(
          QuantumLinkMessage_DeviceNameUpdate value,
          $Res Function(QuantumLinkMessage_DeviceNameUpdate) _then) =
      _$QuantumLinkMessage_DeviceNameUpdateCopyWithImpl;
  @useResult
  $Res call({DeviceNameUpdate field0});
}

/// @nodoc
class _$QuantumLinkMessage_DeviceNameUpdateCopyWithImpl<$Res>
    implements $QuantumLinkMessage_DeviceNameUpdateCopyWith<$Res> {
  _$QuantumLinkMessage_DeviceNameUpdateCopyWithImpl(this._self, this._then);

  final QuantumLinkMessage_DeviceNameUpdate _self;
  final $Res Function(QuantumLinkMessage_DeviceNameUpdate) _then;

  /// Create a copy of QuantumLinkMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(QuantumLinkMessage_DeviceNameUpdate(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as DeviceNameUpdate,
    ));
  }
}

/// @nodoc

class QuantumLinkMessage_MagicBackupRequestV2 extends QuantumLinkMessage {
  const QuantumLinkMessage_MagicBackupRequestV2(this.field0) : super._();

  @override
  final MagicBackupRequestV2 field0;

  /// Create a copy of QuantumLinkMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $QuantumLinkMessage_MagicBackupRequestV2CopyWith<
          QuantumLinkMessage_MagicBackupRequestV2>
      get copyWith => _$QuantumLinkMessage_MagicBackupRequestV2CopyWithImpl<
          QuantumLinkMessage_MagicBackupRequestV2>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is QuantumLinkMessage_MagicBackupRequestV2 &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'QuantumLinkMessage.magicBackupRequestV2(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $QuantumLinkMessage_MagicBackupRequestV2CopyWith<$Res>
    implements $QuantumLinkMessageCopyWith<$Res> {
  factory $QuantumLinkMessage_MagicBackupRequestV2CopyWith(
          QuantumLinkMessage_MagicBackupRequestV2 value,
          $Res Function(QuantumLinkMessage_MagicBackupRequestV2) _then) =
      _$QuantumLinkMessage_MagicBackupRequestV2CopyWithImpl;
  @useResult
  $Res call({MagicBackupRequestV2 field0});

  $MagicBackupRequestV2CopyWith<$Res> get field0;
}

/// @nodoc
class _$QuantumLinkMessage_MagicBackupRequestV2CopyWithImpl<$Res>
    implements $QuantumLinkMessage_MagicBackupRequestV2CopyWith<$Res> {
  _$QuantumLinkMessage_MagicBackupRequestV2CopyWithImpl(this._self, this._then);

  final QuantumLinkMessage_MagicBackupRequestV2 _self;
  final $Res Function(QuantumLinkMessage_MagicBackupRequestV2) _then;

  /// Create a copy of QuantumLinkMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(QuantumLinkMessage_MagicBackupRequestV2(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as MagicBackupRequestV2,
    ));
  }

  /// Create a copy of QuantumLinkMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MagicBackupRequestV2CopyWith<$Res> get field0 {
    return $MagicBackupRequestV2CopyWith<$Res>(_self.field0, (value) {
      return _then(_self.copyWith(field0: value));
    });
  }
}

/// @nodoc

class QuantumLinkMessage_MagicBackupResponseV2 extends QuantumLinkMessage {
  const QuantumLinkMessage_MagicBackupResponseV2(this.field0) : super._();

  @override
  final MagicBackupResponseV2 field0;

  /// Create a copy of QuantumLinkMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $QuantumLinkMessage_MagicBackupResponseV2CopyWith<
          QuantumLinkMessage_MagicBackupResponseV2>
      get copyWith => _$QuantumLinkMessage_MagicBackupResponseV2CopyWithImpl<
          QuantumLinkMessage_MagicBackupResponseV2>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is QuantumLinkMessage_MagicBackupResponseV2 &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'QuantumLinkMessage.magicBackupResponseV2(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $QuantumLinkMessage_MagicBackupResponseV2CopyWith<$Res>
    implements $QuantumLinkMessageCopyWith<$Res> {
  factory $QuantumLinkMessage_MagicBackupResponseV2CopyWith(
          QuantumLinkMessage_MagicBackupResponseV2 value,
          $Res Function(QuantumLinkMessage_MagicBackupResponseV2) _then) =
      _$QuantumLinkMessage_MagicBackupResponseV2CopyWithImpl;
  @useResult
  $Res call({MagicBackupResponseV2 field0});

  $MagicBackupResponseV2CopyWith<$Res> get field0;
}

/// @nodoc
class _$QuantumLinkMessage_MagicBackupResponseV2CopyWithImpl<$Res>
    implements $QuantumLinkMessage_MagicBackupResponseV2CopyWith<$Res> {
  _$QuantumLinkMessage_MagicBackupResponseV2CopyWithImpl(
      this._self, this._then);

  final QuantumLinkMessage_MagicBackupResponseV2 _self;
  final $Res Function(QuantumLinkMessage_MagicBackupResponseV2) _then;

  /// Create a copy of QuantumLinkMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(QuantumLinkMessage_MagicBackupResponseV2(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as MagicBackupResponseV2,
    ));
  }

  /// Create a copy of QuantumLinkMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MagicBackupResponseV2CopyWith<$Res> get field0 {
    return $MagicBackupResponseV2CopyWith<$Res>(_self.field0, (value) {
      return _then(_self.copyWith(field0: value));
    });
  }
}

/// @nodoc

class QuantumLinkMessage_PrimeFiatPreference extends QuantumLinkMessage {
  const QuantumLinkMessage_PrimeFiatPreference(this.field0) : super._();

  @override
  final PrimeFiatPreference field0;

  /// Create a copy of QuantumLinkMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $QuantumLinkMessage_PrimeFiatPreferenceCopyWith<
          QuantumLinkMessage_PrimeFiatPreference>
      get copyWith => _$QuantumLinkMessage_PrimeFiatPreferenceCopyWithImpl<
          QuantumLinkMessage_PrimeFiatPreference>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is QuantumLinkMessage_PrimeFiatPreference &&
            (identical(other.field0, field0) || other.field0 == field0));
  }

  @override
  int get hashCode => Object.hash(runtimeType, field0);

  @override
  String toString() {
    return 'QuantumLinkMessage.primeFiatPreference(field0: $field0)';
  }
}

/// @nodoc
abstract mixin class $QuantumLinkMessage_PrimeFiatPreferenceCopyWith<$Res>
    implements $QuantumLinkMessageCopyWith<$Res> {
  factory $QuantumLinkMessage_PrimeFiatPreferenceCopyWith(
          QuantumLinkMessage_PrimeFiatPreference value,
          $Res Function(QuantumLinkMessage_PrimeFiatPreference) _then) =
      _$QuantumLinkMessage_PrimeFiatPreferenceCopyWithImpl;
  @useResult
  $Res call({PrimeFiatPreference field0});
}

/// @nodoc
class _$QuantumLinkMessage_PrimeFiatPreferenceCopyWithImpl<$Res>
    implements $QuantumLinkMessage_PrimeFiatPreferenceCopyWith<$Res> {
  _$QuantumLinkMessage_PrimeFiatPreferenceCopyWithImpl(this._self, this._then);

  final QuantumLinkMessage_PrimeFiatPreference _self;
  final $Res Function(QuantumLinkMessage_PrimeFiatPreference) _then;

  /// Create a copy of QuantumLinkMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? field0 = null,
  }) {
    return _then(QuantumLinkMessage_PrimeFiatPreference(
      null == field0
          ? _self.field0
          : field0 // ignore: cast_nullable_to_non_nullable
              as PrimeFiatPreference,
    ));
  }
}

// dart format on
