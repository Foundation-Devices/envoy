// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ble/bluetooth_manager.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/onboard/prime/state/ble_onboarding_state.dart';
import 'package:envoy/ui/widgets/envoy_step_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum PrimeFwUpdateStep {
  downloading,
  transferring,
  verifying,
  installing,
  rebooting,
  finished,
  error,
  idle,
}

final primeUpdateStateProvider = Provider<PrimeFwUpdateStep>((ref) {
  final asyncState = ref.watch(fwUpdateStepProvider);
  return asyncState.when(
    data: (data) {
      return data;
    },
    loading: () {
      return PrimeFwUpdateStep.idle;
    },
    error: (err, stack) {
      return PrimeFwUpdateStep.error;
    },
  );
});

final fwDownloadStateProvider = Provider<StepModel>((ref) {
  final asyncState = ref.watch(fwDownloadStreamProvider);
  return asyncState.when(
    data: (data) {
      return StepModel(stepName: data.message, state: data.step);
    },
    loading: () {
      return StepModel(
          stepName: S().firmware_updatingDownload_downloading,
          state: EnvoyStepState.IDLE);
    },
    error: (err, stack) {
      return StepModel(
          stepName: S().firmware_updateError_downloadFailed,
          state: EnvoyStepState.ERROR);
    },
  );
});

final fwDownloadProgressProvider = StateProvider<double>((ref) => 0.0);

final fwTransferStateProvider =
    StateNotifierProvider<StepNotifier, StepModel>((ref) {
  final updateState = ref.watch(primeUpdateStateProvider);
  if (updateState == PrimeFwUpdateStep.transferring) {
    return StepNotifier(
        stepName: S().firmware_downloadingUpdate_transferring,
        state: EnvoyStepState.LOADING);
  } else {
    return StepNotifier(
        stepName: "Transferring to Passport Prime", state: EnvoyStepState.IDLE);
  }
});

final primeFwSigVerifyStateProvider = Provider<StepModel>((ref) {
  final update = ref.watch(primeUpdateStateProvider);
  final completedUpdateStates =
      BluetoothManager().fwUpdateHandler.completedUpdateStates;
  if (update == PrimeFwUpdateStep.verifying) {
    return StepModel(
        stepName: S().firmware_updatingPrime_verifying,
        state: EnvoyStepState.LOADING);
  } else if (completedUpdateStates.contains(PrimeFwUpdateStep.installing) ||
      completedUpdateStates.contains(PrimeFwUpdateStep.rebooting) ||
      completedUpdateStates.contains(PrimeFwUpdateStep.finished)) {
    return StepModel(
        stepName: S().firmware_updatingPrime_verified,
        state: EnvoyStepState.FINISHED);
  } else {
    return StepModel(
        //TODO: localization
        stepName: "Verifying Signatures",
        state: EnvoyStepState.IDLE);
  }
});

final primeFwInstallStateProvider = Provider<StepModel>((ref) {
  final update = ref.watch(primeUpdateStateProvider);
  final completedUpdateStates =
      BluetoothManager().fwUpdateHandler.completedUpdateStates;
  if (update == PrimeFwUpdateStep.installing) {
    return StepModel(
        stepName: S().firmware_updatingPrime_installingUpdate,
        state: EnvoyStepState.LOADING);
  } else if (completedUpdateStates.contains(PrimeFwUpdateStep.installing) ||
      completedUpdateStates.contains(PrimeFwUpdateStep.rebooting) ||
      completedUpdateStates.contains(PrimeFwUpdateStep.finished)) {
    return StepModel(
        stepName: S().firmware_updatingPrime_updateInstalled,
        state: EnvoyStepState.FINISHED);
  } else {
    return StepModel(
        stepName: S().firmware_updatingPrime_installUpdate,
        state: EnvoyStepState.IDLE);
  }
});

final primeFwRebootStateProvider = Provider<StepModel>((ref) {
  final update = ref.watch(primeUpdateStateProvider);
  final completedUpdateStates =
      BluetoothManager().fwUpdateHandler.completedUpdateStates;
  if (update == PrimeFwUpdateStep.rebooting) {
    return StepModel(
        stepName: S().firmware_updatingPrime_primeRestarting,
        state: EnvoyStepState.LOADING);
  } else if (completedUpdateStates.contains(PrimeFwUpdateStep.rebooting)) {
    return StepModel(
        stepName: S().firmware_updatingPrime_primeRestarting,
        state: EnvoyStepState.FINISHED);
  } else {
    return StepModel(
        stepName: S().firmware_updatingPrime_restartPrime,
        state: EnvoyStepState.IDLE);
  }
});
