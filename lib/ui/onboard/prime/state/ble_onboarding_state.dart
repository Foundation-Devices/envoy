// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later
// ignore_for_file: constant_identifier_names

import 'package:envoy/ble/bluetooth_manager.dart';
import 'package:envoy/ble/handlers/fw_update_handler.dart';
import 'package:envoy/ble/handlers/onboard_handler.dart';
import 'package:envoy/ble/handlers/scv_handler.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/onboard/prime/firmware_update/prime_fw_update_state.dart';
import 'package:envoy/ui/widgets/envoy_step_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation_api/foundation_api.dart';

/// Stream Providers for various BLE onboarding states
final fwUpdateStreamProvider = StreamProvider<FwUpdateState>((ref) {
  return BluetoothManager().fwUpdateHandler.fetchStateStream;
});

final blePairingStreamProvider = StreamProvider<BleConnectionState>((ref) {
  return BluetoothManager().bleOnboardHandler.blePairingState;
});

final onboardingStateStreamProvider = StreamProvider<OnboardingState>((ref) {
  return BluetoothManager().bleOnboardHandler.onboardingState;
});

final scvStateProvider = StreamProvider<ScvUpdateState>((ref) {
  return BluetoothManager().scvAccountHandler.scvUpdateController;
});

final fwDownloadStreamProvider = StreamProvider<FwUpdateState>((ref) {
  return BluetoothManager().fwUpdateHandler.downloadStateStream;
});

final fwUpdateStepProvider = StreamProvider<PrimeFwUpdateStep>((ref) {
  return BluetoothManager().fwUpdateHandler.primeFwUpdate;
});

final fwTransferState = StreamProvider<FwUpdateState>((ref) {
  return BluetoothManager().fwUpdateHandler.transferStateStream;
});

class StepNotifier extends StateNotifier<StepModel> {
  StepNotifier(
      {String stepName = "Loading",
      EnvoyStepState state = EnvoyStepState.HIDDEN})
      : super(StepModel(stepName: stepName, state: state));

  Future<void> updateStep(String stepName, EnvoyStepState state) async {
    this.state = StepModel(stepName: stepName, state: state);
  }
}

final bleConnectionProvider = Provider<StepModel>((ref) {
  final asyncState = ref.watch(blePairingStreamProvider);
  return asyncState.when(
    data: (data) {
      return StepModel(stepName: data.message, state: data.step);
    },
    loading: () {
      return StepModel(
          stepName: "Connecting to device", state: EnvoyStepState.IDLE);
    },
    error: (err, stack) {
      return StepModel(
          stepName: "Unable to connect to device", state: EnvoyStepState.ERROR);
    },
  );
});

final deviceSecurityProvider = Provider<StepModel>((ref) {
  final asyncState = ref.watch(scvStateProvider);
  return asyncState.when(
    data: (data) {
      return StepModel(stepName: data.message, state: data.step);
    },
    loading: () {
      return StepModel(
          stepName: S().onboarding_connectionIntro_checkingDeviceSecurity,
          state: EnvoyStepState.IDLE);
    },
    error: (err, stack) {
      return StepModel(
          stepName: S().onboarding_connectionIntroError_securityCheckFailed,
          state: EnvoyStepState.ERROR);
    },
  );
});

final firmWareUpdateProvider = Provider<StepModel>((ref) {
  final asyncState = ref.watch(fwUpdateStreamProvider);

  return asyncState.when(
    data: (data) {
      return StepModel(stepName: data.message, state: data.step);
    },
    loading: () {
      return StepModel(
          stepName: S().onboarding_connectionIntro_checkForUpdates,
          state: EnvoyStepState.IDLE);
    },
    error: (err, stack) {
      return StepModel(
          stepName: S().onboarding_connectionIntro_checkForUpdates,
          state: EnvoyStepState.ERROR);
    },
  );
});

final creatingPinProvider = Provider<StepModel>((ref) {
  ref.watch(onboardingStateStreamProvider);
  final stateHistory = BluetoothManager().bleOnboardHandler.completedSteps;
  if (stateHistory.contains(OnboardingState.deviceSecured)) {
    return StepModel(
        stepName: S().finalize_catchAll_pinCreated,
        state: EnvoyStepState.FINISHED);
  } else if (stateHistory.contains(OnboardingState.securingDevice)) {
    return StepModel(
        stepName: S().finalize_catchAll_creatingPin,
        state: EnvoyStepState.LOADING);
  } else {
    return StepModel(
        stepName: S().finalize_catchAll_creatingPin,
        state: EnvoyStepState.IDLE);
  }
});

final setUpMasterKeyProvider = Provider<StepModel>((ref) {
  ref.watch(onboardingStateStreamProvider);
  final stateHistory = BluetoothManager().bleOnboardHandler.completedSteps;
  if (stateHistory.contains(OnboardingState.walletCreated)) {
    return StepModel(
        stepName: S().finalize_catchAll_masterKeySetUp,
        state: EnvoyStepState.FINISHED);
  } else if (stateHistory.contains(OnboardingState.walletCreationScreen)) {
    return StepModel(
        stepName: S().finalize_catchAll_settingUpMasterKey,
        state: EnvoyStepState.LOADING);
  } else {
    return StepModel(
        stepName: S().finalize_catchAll_setUpMasterKey,
        state: EnvoyStepState.IDLE);
  }
});

final backUpMasterKeyProvider = Provider<StepModel>((ref) {
  ref.watch(onboardingStateStreamProvider);
  final stateHistory = BluetoothManager().bleOnboardHandler.completedSteps;
  if (stateHistory.contains(OnboardingState.magicBackupCreated) ||
      stateHistory.contains(OnboardingState.connectingWallet)) {
    return StepModel(
        stepName: S().finalize_catchAll_masterKeyBackedUp,
        state: EnvoyStepState.FINISHED);
  } else if (stateHistory.contains(OnboardingState.magicBackupScreen) ||
      stateHistory.contains(OnboardingState.creatingManualBackup)) {
    return StepModel(
        stepName: S().finalize_catchAll_backingUpMasterKey,
        state: EnvoyStepState.LOADING);
  } else {
    return StepModel(
        stepName: S().finalize_catchAll_backUpMasterKey,
        state: EnvoyStepState.IDLE);
  }
});

final connectAccountProvider = Provider<StepModel>((ref) {
  ref.watch(onboardingStateStreamProvider);
  final stateHistory = BluetoothManager().bleOnboardHandler.completedSteps;
  if (stateHistory.contains(OnboardingState.walletConected)) {
    return StepModel(
        stepName: S().finalize_catchAll_connectingAccount,
        state: EnvoyStepState.FINISHED);
  } else if (stateHistory.contains(OnboardingState.connectingWallet)) {
    return StepModel(
        stepName: S().finalize_catchAll_connectingAccount,
        state: EnvoyStepState.LOADING);
  } else {
    return StepModel(
        stepName: S().finalize_catchAll_connectAccount,
        state: EnvoyStepState.IDLE);
  }
});

void resetOnboardingPrimeProviders(WidgetRef ref) {}
