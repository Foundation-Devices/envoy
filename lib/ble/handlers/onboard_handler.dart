// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later
// ignore_for_file: constant_identifier_names///
import 'dart:async';

import 'package:envoy/ble/bluetooth_manager.dart';
import 'package:envoy/ble/quantum_link_router.dart';
import 'package:envoy/business/devices.dart';
import 'package:envoy/channels/bluetooth_channel.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/widgets/envoy_step_item.dart';
import 'package:envoy/util/bug_report_helper.dart';
import 'package:envoy/util/console.dart';
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

  final Set<OnboardingState> _completedOnboardingStates = {};
  final StreamController<BleConnectionState> _blePairingState =
      StreamController<BleConnectionState>.broadcast();

  final StreamController<OnboardingState> _onboardingState =
      StreamController<OnboardingState>.broadcast();

  Stream<BleConnectionState> get blePairingState =>
      _blePairingState.stream.asBroadcastStream();

  Stream<OnboardingState> get onboardingState =>
      _onboardingState.stream.asBroadcastStream();

  Set<OnboardingState> get completedSteps => _completedOnboardingStates;

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
      final deviceColor = response.passportColor == PassportColor.dark
          ? DeviceColor.dark
          : DeviceColor.light;
      final peripheralId = BluetoothChannel().lastDeviceStatus.peripheralId;
      await BluetoothManager().addDevice(
        response.passportSerial.field0,
        response.passportFirmwareVersion.field0,
        BluetoothManager().bleId,
        deviceColor,
        peripheralId: peripheralId ?? "",
        onboardingComplete: response.onboardingComplete,
      );

      updateBlePairState(S().onboarding_connectionIntro_connectedToPrime,
          EnvoyStepState.FINISHED);

      BluetoothManager().scvAccountHandler.sendSecurityChallenge();
    } catch (e, stack) {
      EnvoyReport().log("BleOnboardHandler", e.toString(), stackTrace: stack);
      updateBlePairState("Unable to complete pairing.", EnvoyStepState.ERROR);
    }
  }

  void _handleOnboardingState(OnboardingState onboardingState) {
    if (!_completedOnboardingStates.contains(onboardingState)) {
      _completedOnboardingStates.add(onboardingState);
      kPrint(
          "Onboarding States :\n ${_completedOnboardingStates.map((e) => e.name).join(" -> ")}\n");
    }
    _onboardingState.sink.add(onboardingState);
  }

  void updateBlePairState(String message, EnvoyStepState step) {
    final state = BleConnectionState(message: message, step: step);
    _blePairingState.add(state);
  }
}
