// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later
// ignore_for_file: constant_identifier_names

import 'package:envoy/ble/handlers/fw_update_handler.dart';
import 'package:envoy/ble/handlers/onboard_handler.dart';
import 'package:envoy/ble/handlers/scv_handler.dart';
import 'package:envoy/channels/ql_connection.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/onboard/prime/firmware_update/prime_fw_update_state.dart';
import 'package:envoy/ui/widgets/envoy_step_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation_api/foundation_api.dart';

/// State Provider for the current onboarding device
/// different onboarding steps will watch this provider to get the current onboarding device
/// and listen to its various state streams.
final onboardingDeviceProvider = StateProvider<QLConnection?>((ref) {
  return null;
});

/// Extended step model that includes error type for security check
class SecurityStepModel extends StepModel {
  final ScvErrorType errorType;

  SecurityStepModel({
    required super.stepName,
    required super.state,
    this.errorType = ScvErrorType.none,
  });
}

/// Stream Providers for various BLE onboarding states
final fwUpdateStreamProvider = StreamProvider<FwUpdateState>((ref) {
  final device = ref.watch(onboardingDeviceProvider);
  if (device == null) return const Stream.empty();
  return device.qlHandler.fwUpdateHandler.fetchStateStream;
});

final blePairingStreamProvider = StreamProvider<BleConnectionState>((ref) {
  final device = ref.watch(onboardingDeviceProvider);
  if (device == null) return const Stream.empty();
  return device.qlHandler.bleOnboardHandler.blePairingState;
});

final onboardingStateStreamProvider = StreamProvider<OnboardingState>((ref) {
  final device = ref.watch(onboardingDeviceProvider);
  if (device == null) return const Stream.empty();
  return device.qlHandler.bleOnboardHandler.onboardingState;
});

final scvStateProvider = StreamProvider<ScvUpdateState>((ref) {
  final device = ref.watch(onboardingDeviceProvider);
  if (device == null) return const Stream.empty();
  return device.qlHandler.scvAccountHandler.scvUpdateController;
});

final fwDownloadStreamProvider = StreamProvider<FwUpdateState>((ref) {
  final device = ref.watch(onboardingDeviceProvider);
  if (device == null) return const Stream.empty();
  return device.qlHandler.fwUpdateHandler.downloadStateStream;
});

final fwUpdateStepProvider = StreamProvider<PrimeFwUpdateStep>((ref) {
  final device = ref.watch(onboardingDeviceProvider);
  if (device == null) return const Stream.empty();
  return device.qlHandler.fwUpdateHandler.primeFwUpdate;
});

final fwTransferState = StreamProvider<FwUpdateState>((ref) {
  final device = ref.watch(onboardingDeviceProvider);
  if (device == null) return const Stream.empty();
  return device.qlHandler.fwUpdateHandler.transferStateStream;
});

class StepNotifier extends StateNotifier<StepModel> {
  StepNotifier({
    String stepName = "Loading",
    EnvoyStepState state = EnvoyStepState.HIDDEN,
  }) : super(StepModel(stepName: stepName, state: state));

  Future<void> updateStep(String stepName, EnvoyStepState state) async {
    this.state = StepModel(stepName: stepName, state: state);
  }
}

final bleConnectionProvider = Provider<StepModel>((ref) {
  final asyncState = ref.watch(blePairingStreamProvider);
  final lastState = ref
      .watch(onboardingDeviceProvider)
      ?.qlHandler
      .bleOnboardHandler
      .lastBleState;
  if (!asyncState.hasValue && lastState != null) {
    return StepModel(stepName: lastState.message, state: lastState.step);
  }
  return asyncState.when(
    data: (data) {
      return StepModel(stepName: data.message, state: data.step);
    },
    loading: () {
      return StepModel(
        stepName: "Connecting to device",
        state: EnvoyStepState.IDLE,
      );
    },
    error: (err, stack) {
      return StepModel(
        stepName: "Unable to connect to device",
        state: EnvoyStepState.ERROR,
      );
    },
  );
});

final deviceSecurityProvider = Provider<SecurityStepModel>((ref) {
  final asyncState = ref.watch(scvStateProvider);
  final lastState = ref
      .watch(onboardingDeviceProvider)
      ?.qlHandler
      .scvAccountHandler
      .lastScvState;
  if (!asyncState.hasValue && lastState != null) {
    return SecurityStepModel(
      stepName: lastState.message,
      state: lastState.step,
    );
  }
  return asyncState.when(
    data: (data) {
      return SecurityStepModel(
        stepName: data.message,
        state: data.step,
        errorType: data.errorType,
      );
    },
    loading: () {
      return SecurityStepModel(
        stepName: S().onboarding_connectionIntro_checkingDeviceSecurity,
        state: EnvoyStepState.IDLE,
      );
    },
    error: (err, stack) {
      return SecurityStepModel(
        stepName: S().onboarding_connectionIntroError_securityCheckFailed,
        state: EnvoyStepState.ERROR,
        errorType: ScvErrorType.verificationFailed,
      );
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
        state: EnvoyStepState.IDLE,
      );
    },
    error: (err, stack) {
      return StepModel(
        stepName: S().onboarding_connectionIntro_checkForUpdates,
        state: EnvoyStepState.ERROR,
      );
    },
  );
});

final creatingPinProvider = Provider<StepModel>((ref) {
  ref.watch(onboardingStateStreamProvider);
  final device = ref.watch(onboardingDeviceProvider);
  if (device == null) {
    return StepModel(
      stepName: S().finalize_catchAll_creatingPin,
      state: EnvoyStepState.IDLE,
    );
  }
  final stateHistory = device.qlHandler.bleOnboardHandler.completedSteps;
  if (stateHistory.contains(OnboardingState.deviceSecured)) {
    return StepModel(
      stepName: S().finalize_catchAll_pinCreated,
      state: EnvoyStepState.FINISHED,
    );
  } else if (stateHistory.contains(OnboardingState.securingDevice)) {
    return StepModel(
      stepName: S().finalize_catchAll_creatingPin,
      state: EnvoyStepState.LOADING,
    );
  } else {
    return StepModel(
      stepName: S().finalize_catchAll_creatingPin,
      state: EnvoyStepState.IDLE,
    );
  }
});

final setUpMasterKeyProvider = Provider<StepModel>((ref) {
  ref.watch(onboardingStateStreamProvider);
  final device = ref.watch(onboardingDeviceProvider);
  if (device == null) {
    return StepModel(
      stepName: S().finalize_catchAll_setUpMasterKey,
      state: EnvoyStepState.IDLE,
    );
  }
  final stateHistory = device.qlHandler.bleOnboardHandler.completedSteps;
  if (stateHistory.contains(OnboardingState.walletCreated)) {
    return StepModel(
      stepName: S().finalize_catchAll_masterKeySetUp,
      state: EnvoyStepState.FINISHED,
    );
  } else if (stateHistory.contains(OnboardingState.walletCreationScreen)) {
    return StepModel(
      stepName: S().finalize_catchAll_settingUpMasterKey,
      state: EnvoyStepState.LOADING,
    );
  } else {
    return StepModel(
      stepName: S().finalize_catchAll_setUpMasterKey,
      state: EnvoyStepState.IDLE,
    );
  }
});

final backUpMasterKeyProvider = Provider<StepModel>((ref) {
  ref.watch(onboardingStateStreamProvider);
  final device = ref.watch(onboardingDeviceProvider);
  if (device == null) {
    return StepModel(
      stepName: S().finalize_catchAll_backUpMasterKey,
      state: EnvoyStepState.IDLE,
    );
  }
  final stateHistory = device.qlHandler.bleOnboardHandler.completedSteps;
  if (stateHistory.contains(OnboardingState.magicBackupCreated) ||
      stateHistory.contains(OnboardingState.connectingWallet)) {
    return StepModel(
      stepName: S().finalize_catchAll_masterKeyBackedUp,
      state: EnvoyStepState.FINISHED,
    );
  } else if (stateHistory.contains(OnboardingState.magicBackupScreen) ||
      stateHistory.contains(OnboardingState.creatingManualBackup)) {
    return StepModel(
      stepName: S().finalize_catchAll_backingUpMasterKey,
      state: EnvoyStepState.LOADING,
    );
  } else {
    return StepModel(
      stepName: S().finalize_catchAll_backUpMasterKey,
      state: EnvoyStepState.IDLE,
    );
  }
});

final connectAccountProvider = Provider<StepModel>((ref) {
  ref.watch(onboardingStateStreamProvider);
  final device = ref.watch(onboardingDeviceProvider);
  if (device == null) {
    return StepModel(
      stepName: S().finalize_catchAll_connectAccount,
      state: EnvoyStepState.IDLE,
    );
  }
  final stateHistory = device.qlHandler.bleOnboardHandler.completedSteps;
  if (stateHistory.contains(OnboardingState.walletConected)) {
    return StepModel(
      stepName: S().finalize_catchAll_connectingAccount,
      state: EnvoyStepState.FINISHED,
    );
  } else if (stateHistory.contains(OnboardingState.connectingWallet)) {
    return StepModel(
      stepName: S().finalize_catchAll_connectingAccount,
      state: EnvoyStepState.LOADING,
    );
  } else {
    return StepModel(
      stepName: S().finalize_catchAll_connectAccount,
      state: EnvoyStepState.IDLE,
    );
  }
});

void resetOnboardingPrimeProviders(ProviderContainer container) {
  final device = container.read(onboardingDeviceProvider);
  if (device != null) {
    device.qlHandler.fwUpdateHandler.reset();
    device.qlHandler.bleOnboardHandler.reset();
    device.qlHandler.scvAccountHandler.reset();
  }
  container.read(onboardingDeviceProvider.notifier).state = null;
}
