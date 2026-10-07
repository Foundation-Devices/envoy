// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ble/qlv2/rpc_dispatcher.dart';
import 'package:envoy/channels/ql_connection.dart';
import 'package:envoy/ui/onboard/prime/state/prime_onboarding_controller.dart';
import 'package:envoy/ui/onboard/prime/state/qlv2/prime_onboarding_qlv2_device_storage.dart';
import 'package:envoy/util/console.dart';
import 'package:qlv2/qlv2.dart' as qlv2;

class PrimeOnboardingQlv2OnboardingStatusHandler
    implements QLV2SessionEventHandler<qlv2.OnboardingState> {
  PrimeOnboardingQlv2OnboardingStatusHandler(
    this._controller, {
    Future<void> Function()? onCompleted,
    bool Function()? shouldHandle,
  })  : _onCompleted = onCompleted,
        _shouldHandle = shouldHandle ?? _alwaysHandle;

  final PrimeOnboardingController _controller;
  final Future<void> Function()? _onCompleted;
  final bool Function() _shouldHandle;
  bool _storedCompletedDetails = false;
  bool _completionHandled = false;
  Future<bool>? _storeCompletedDetailsFuture;
  static const _storageRetryDelay = Duration(seconds: 2);

  @override
  Future<void> handleEvent(
    qlv2.OnboardingState event,
    QLConnection device,
  ) async {
    if (!_shouldHandle()) return;
    kPrint("[PrimeOnboarding] qlv2_onboarding: ${event.name}");
    final step = mapQlv2OnboardingStep(event);
    if (step == PrimeOnboardingStep.completed) {
      if (_completionHandled) return;
      kPrint("[PrimeOnboarding] qlv2_onboarding: completed");
      if (!await _storeCompletedPassportDetails(device) || !_shouldHandle()) {
        return;
      }
      if (_completionHandled) return;
      _completionHandled = true;
    }
    _controller.recordStep(step);
    if (step == PrimeOnboardingStep.completed) {
      await _onCompleted?.call();
    }
  }

  Future<bool> _storeCompletedPassportDetails(QLConnection device) async {
    if (_storedCompletedDetails) {
      return true;
    }
    final existing = _storeCompletedDetailsFuture;
    if (existing != null) return existing;
    final storage = _retryStoreCompletedPassportDetails(device);
    _storeCompletedDetailsFuture = storage;
    final stored = await storage;
    if (!stored) _storeCompletedDetailsFuture = null;
    return stored;
  }

  Future<bool> _retryStoreCompletedPassportDetails(
    QLConnection device,
  ) async {
    while (_shouldHandle()) {
      try {
        final handler = device.v2Handler;
        if (handler == null) {
          throw StateError("No QL v2 session available for passport details.");
        }

        await saveQlv2PassportDevice(
          device: device,
          handler: handler,
          onboardingCompleteOverride: true,
        );
        _storedCompletedDetails = true;
        kPrint(
          "[PrimeOnboarding] qlv2_onboarding: stored passport details",
        );
        return true;
      } catch (e, stack) {
        kPrint(
          "[PrimeOnboarding] qlv2_onboarding: failed to store passport details: $e",
          stackTrace: stack,
        );
        await Future<void>.delayed(_storageRetryDelay);
      }
    }
    return false;
  }
}

bool _alwaysHandle() => true;

PrimeOnboardingStep mapQlv2OnboardingStep(
  qlv2.OnboardingState state,
) {
  return switch (state) {
    qlv2.OnboardingState.firmwareUpdateScreen =>
      PrimeOnboardingStep.firmwareUpdateScreen,
    qlv2.OnboardingState.securingDevice => PrimeOnboardingStep.securingDevice,
    qlv2.OnboardingState.deviceSecured => PrimeOnboardingStep.deviceSecured,
    qlv2.OnboardingState.walletCreationScreen =>
      PrimeOnboardingStep.walletCreationScreen,
    qlv2.OnboardingState.creatingWallet => PrimeOnboardingStep.creatingWallet,
    qlv2.OnboardingState.walletCreated => PrimeOnboardingStep.walletCreated,
    qlv2.OnboardingState.magicBackupScreen =>
      PrimeOnboardingStep.magicBackupScreen,
    qlv2.OnboardingState.creatingMagicBackup =>
      PrimeOnboardingStep.creatingMagicBackup,
    qlv2.OnboardingState.magicBackupCreated =>
      PrimeOnboardingStep.magicBackupCreated,
    qlv2.OnboardingState.creatingManualBackup =>
      PrimeOnboardingStep.creatingManualBackup,
    qlv2.OnboardingState.creatingKeycardBackup =>
      PrimeOnboardingStep.creatingKeycardBackup,
    qlv2.OnboardingState.writingDownSeedWords =>
      PrimeOnboardingStep.writingDownSeedWords,
    qlv2.OnboardingState.completed => PrimeOnboardingStep.completed,
  };
}
