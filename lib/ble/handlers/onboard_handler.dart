// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later
// ignore_for_file: constant_identifier_names///
import 'dart:async';

import 'package:envoy/ble/bluetooth_manager.dart';
import 'package:envoy/ble/quantum_link_router.dart';
import 'package:envoy/business/devices.dart';
import 'package:envoy/business/envoy_seed.dart';
import 'package:envoy/business/updates_manager.dart';
import 'package:envoy/channels/bluetooth_channel.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/routes/routes.dart';
import 'package:envoy/ui/widgets/envoy_step_item.dart';
import 'package:envoy/util/bug_report_helper.dart';
import 'package:envoy/util/console.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:foundation_api/foundation_api.dart' as api;
import 'package:foundation_api/foundation_api.dart';

class BleConnectionState {
  final String message;
  final EnvoyStepState step;

  BleConnectionState({required this.message, required this.step});
}

class BleOnboardHandler extends PassportMessageHandler with ChangeNotifier {
  BleOnboardHandler(super.writer);

  api.PairingResponse? _pairingResponse;
  final Set<OnboardingState> _completedOnboardingStates = {};
  BleConnectionState? _lastState;

  final StreamController<BleConnectionState> _blePairingState =
      StreamController<BleConnectionState>.broadcast();

  final StreamController<OnboardingState> _onboardingState =
      StreamController<OnboardingState>.broadcast();

  Stream<BleConnectionState> get blePairingState =>
      _blePairingState.stream.asBroadcastStream();

  BleConnectionState? get lastBleState => _lastState;

  Stream<OnboardingState> get onboardingState =>
      _onboardingState.stream.asBroadcastStream();

  Set<OnboardingState> get completedSteps => _completedOnboardingStates;
  bool get pairingDone => _pairingResponse != null;

  @override
  bool canHandle(api.QuantumLinkMessage message) {
    return message is api.QuantumLinkMessage_PairingResponse ||
        message is api.QuantumLinkMessage_OnboardingState;
  }

  @override
  Future<void> handleMessage(
      api.QuantumLinkMessage message, String bleId) async {
    if (message case api.QuantumLinkMessage_PairingResponse response) {
      _handlePairingResponse(response.field0);
    } else if (message case api.QuantumLinkMessage_OnboardingState state) {
      _handleOnboardingState(state.field0);
    }
  }

  void _handlePairingResponse(api.PairingResponse response) async {
    try {
      updateBlePairState(S().onboarding_connectionIntro_connectedToPrime,
          EnvoyStepState.FINISHED);
      _pairingResponse = response;

      if (response.onboardingComplete) {
        await addDevice(response);
        UpdatesManager().checkAndStoreLatestPrimeFirmware(
            _pairingResponse?.passportFirmwareVersion.field0);
        await EnvoyStorage().setBool(PREFS_ONBOARDED, true);
        await EnvoySeed().generateAndBackupWalletSilently();
        //no need to send security challenge if onboarding is already complete
        try {
          BluetoothManager().sendExchangeRateHistory();
        } catch (e) {
          kPrint(
              "Could not send exchange rate history at onboarding completion: ${e.toString()}");
        }
        return;
      }

      BluetoothManager().scvAccountHandler.sendSecurityChallenge();
    } catch (e, stack) {
      EnvoyReport().log("BleOnboardHandler", e.toString(), stackTrace: stack);
      updateBlePairState("Unable to complete pairing.", EnvoyStepState.ERROR);
    }
  }

  Future<void> addDevice(api.PairingResponse response) async {
    final deviceColor = response.passportColor == PassportColor.dark
        ? DeviceColor.dark
        : DeviceColor.light;
    final peripheralId = BluetoothChannel().lastDeviceStatus.peripheralId;

    await BluetoothManager().addDevice(
      response.passportSerial.field0,
      sanitizeVersion(response.passportFirmwareVersion.field0),
      BluetoothManager().bleId,
      deviceColor,
      peripheralId: peripheralId ?? "",
      onboardingComplete: response.onboardingComplete,
    );
  }

  void _handleOnboardingState(OnboardingState onboardingState) async {
    if (!_completedOnboardingStates.contains(onboardingState)) {
      _completedOnboardingStates.add(onboardingState);
      kPrint(
          "Onboarding States :\n ${_completedOnboardingStates.map((e) => e.name).join(" -> ")}\n");
    }

    if (onboardingState == api.OnboardingState.completed) {
      await Devices().markPrimeOnboarded(true);
      try {
        if (_pairingResponse != null) {
          await addDevice(_pairingResponse!);
          UpdatesManager().checkAndStoreLatestPrimeFirmware(
              _pairingResponse?.passportFirmwareVersion.field0);
          await EnvoyStorage().setBool(PREFS_ONBOARDED, true);
        }
        await EnvoySeed().generateAndBackupWalletSilently();
        await BluetoothManager().sendExchangeRateHistory();
      } catch (e) {
        kPrint("Could not finish onboarding: ${e.toString()}");
      }
    }
    _onboardingState.sink.add(onboardingState);
  }

  void updateBlePairState(String message, EnvoyStepState step) {
    final state = BleConnectionState(message: message, step: step);
    _lastState = state;
    _blePairingState.add(state);
  }

  Future<api.PairingResponse> waitForPairResponse(
      {Duration timeout = const Duration(seconds: 15)}) async {
    final deadline = DateTime.now().add(timeout);
    while (_pairingResponse == null) {
      if (DateTime.now().isAfter(deadline)) {
        throw TimeoutException(
            'Timed out waiting for pairing response', timeout);
      }
      await Future.delayed(const Duration(milliseconds: 500));
    }
    return _pairingResponse!;
  }

  void reset() {
    _pairingResponse = null;
    _completedOnboardingStates.clear();
    updateBlePairState("Connecting to device", EnvoyStepState.IDLE);
  }
}
