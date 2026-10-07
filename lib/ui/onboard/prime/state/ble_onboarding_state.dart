// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later
// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'package:async/async.dart';
import 'package:envoy/ble/bluetooth_manager.dart';
import 'package:envoy/ble/handlers/scv_handler.dart';
import 'package:envoy/channels/ql_connection.dart';
import 'package:envoy/business/devices.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/onboard/prime/state/ble_onboarding_session_state.dart';
import 'package:envoy/ui/onboard/prime/state/prime_onboarding_controller.dart'
    as shared;
import 'package:envoy/ui/widgets/envoy_step_item.dart';
import 'package:envoy/util/console.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation_api/foundation_api.dart';

export 'package:envoy/ui/onboard/prime/state/ble_onboarding_session_state.dart'
    show onboardingDeviceProvider;
export 'package:envoy/ui/onboard/prime/state/prime_onboarding_controller.dart'
    show
        PrimeOnboardingAdapter,
        PrimeFirmwareChangelog,
        PrimeFirmwareTransferProgress,
        PrimeFwUpdateStep,
        PrimeOnboardingStep,
        PrimeOnboardingUiState,
        SecurityStepModel,
        primeOnboardingControllerProvider;
export 'package:envoy/ui/onboard/prime/state/qlv2/prime_onboarding_qlv2_state.dart'
    show setOnboardingPrimeQlv2Session, stopOnboardingPrimeQlv2Scope;

void _logPrimeOnboarding(String message) {
  kPrint("[PrimeOnboarding] $message");
}

class Qlv1PrimeOnboardingAdapter implements shared.PrimeOnboardingAdapter {
  final QLConnection device;
  final bool isSettingsUpdate;

  Qlv1PrimeOnboardingAdapter({
    required this.device,
    this.isSettingsUpdate = false,
  });

  final _subscriptions = <StreamSubscription<dynamic>>[];
  shared.PrimeOnboardingController? _controller;
  bool _disposed = false;

  void _update(
    void Function(shared.PrimeOnboardingController controller) update,
  ) {
    final controller = _controller;
    if (_disposed || controller == null) return;
    update(controller);
  }

  void _updateFirmwareMetadata() {
    final handler = device.qlHandler.fwUpdateHandler;
    _update(
      (controller) => controller.updateFirmwareMetadata(
        currentVersion: handler.currentVersion,
        targetVersion: handler.newVersion,
        estimatedTime: handler.estimatedUpdateTime,
        changelogs: handler.availablePatches
            .map(
              (patch) => shared.PrimeFirmwareChangelog(
                version: patch.version,
                changelog: patch.changelog,
              ),
            )
            .toList(growable: false),
      ),
    );
  }

  @override
  void attach(shared.PrimeOnboardingController controller) {
    _controller = controller;
    _disposed = false;

    final onboardHandler = device.qlHandler.bleOnboardHandler;
    final scvHandler = device.qlHandler.scvAccountHandler;
    final fwHandler = device.qlHandler.fwUpdateHandler;

    controller.setSettingsFirmwareUpdate(isSettingsUpdate);
    final lastBleState = onboardHandler.lastBleState;
    if (lastBleState != null) {
      controller.updateBleConnection(lastBleState.message, lastBleState.step);
    }
    controller.replaceCompletedSteps(
      onboardHandler.completedSteps.map(mapQlv1OnboardingStep).toSet(),
    );
    final lastScvState = scvHandler.lastScvState;
    if (lastScvState != null) {
      controller.updateSecurity(
        lastScvState.message,
        lastScvState.step,
        errorType: lastScvState.errorType,
      );
    }
    controller.replaceCompletedFirmwareSteps(fwHandler.completedUpdateStates);
    if (fwHandler.completedUpdateStates.isNotEmpty) {
      controller.recordFirmwareUpdateStep(
        fwHandler.completedUpdateStates.last,
      );
    }
    _updateFirmwareMetadata();

    _subscriptions.add(
      onboardHandler.blePairingState.listen((state) {
        _logPrimeOnboarding(
          "qlv1 ble_pairing=${state.step} message=${state.message}",
        );
        _update(
          (controller) =>
              controller.updateBleConnection(state.message, state.step),
        );
      }),
    );
    _subscriptions.add(
      onboardHandler.onboardingState.listen((state) {
        _logPrimeOnboarding("qlv1 onboarding=${state.name}");
        _update(
          (controller) => controller.recordStep(mapQlv1OnboardingStep(state)),
        );
      }),
    );
    _subscriptions.add(
      scvHandler.scvUpdateController.listen(
        (state) => _update(
          (controller) => controller.updateSecurity(
            state.message,
            state.step,
            errorType: state.errorType,
          ),
        ),
      ),
    );
    _subscriptions.add(
      fwHandler.fetchStateStream.listen((state) {
        _update(
          (controller) =>
              controller.updateFirmwareCheck(state.message, state.step),
        );
        _updateFirmwareMetadata();
      }),
    );
    _subscriptions.add(
      fwHandler.downloadStateStream.listen((state) {
        _update(
          (controller) =>
              controller.updateFirmwareDownload(state.message, state.step),
        );
        _updateFirmwareMetadata();
      }),
    );
    _subscriptions.add(
      fwHandler.primeFwUpdate.listen((step) {
        _update((controller) => controller.recordFirmwareUpdateStep(step));
        _updateFirmwareMetadata();
      }),
    );
    _subscriptions.add(
      fwHandler.downloadProgress.listen(
        (progress) => _update(
          (controller) => controller.updateFirmwareDownloadProgress(progress),
        ),
      ),
    );
    _subscriptions.add(
      fwHandler.transferProgress.listen(
        (progress) => _update(
          (controller) => controller.updateFirmwareTransferProgress(
            progress: progress.progress,
            remainingTime: progress.remainingTime,
          ),
        ),
      ),
    );
  }

  @override
  void reset() {
    if (_disposed) return;
    device.qlHandler.fwUpdateHandler.reset();
    device.qlHandler.bleOnboardHandler.reset();
    device.qlHandler.scvAccountHandler.reset();
  }

  @override
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    _controller = null;
    final activeSubscriptions = List.of(_subscriptions);
    _subscriptions.clear();
    await Future.wait(
      activeSubscriptions.map((subscription) => subscription.cancel()),
    );
  }
}

Future<void> setOnboardingPrimeQlv1Session({
  required ProviderContainer container,
  required QLConnection device,
  bool isSettingsUpdate = false,
}) async {
  container.read(onboardingDeviceProvider.notifier).state = device;
  await container
      .read(shared.primeOnboardingControllerProvider.notifier)
      .useAdapter(
        Qlv1PrimeOnboardingAdapter(
          device: device,
          isSettingsUpdate: isSettingsUpdate,
        ),
      );
}

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
  return ref.watch(shared.primeOnboardingControllerProvider).bleConnection ??
      StepModel(
        stepName: "Connecting to Prime",
        state: EnvoyStepState.LOADING,
      );
});

final deviceSecurityProvider = Provider<shared.SecurityStepModel>((ref) {
  final security = ref.watch(shared.primeOnboardingControllerProvider).security;
  return shared.SecurityStepModel(
    stepName: security?.stepName ??
        S().onboarding_connectionIntro_checkingDeviceSecurity,
    state: security?.state ?? EnvoyStepState.IDLE,
    errorType: security?.errorType ?? ScvErrorType.none,
  );
});

final firmWareUpdateProvider = Provider<StepModel>((ref) {
  return ref.watch(shared.primeOnboardingControllerProvider).firmwareCheck ??
      StepModel(
        stepName: S().onboarding_connectionIntro_checkForUpdates,
        state: EnvoyStepState.IDLE,
      );
});

final creatingPinProvider = Provider<StepModel>((ref) {
  final stateHistory =
      ref.watch(shared.primeOnboardingControllerProvider).completedSteps;
  if (stateHistory.contains(shared.PrimeOnboardingStep.deviceSecured)) {
    return StepModel(
      stepName: S().finalize_catchAll_pinCreated,
      state: EnvoyStepState.FINISHED,
    );
  } else if (stateHistory.contains(shared.PrimeOnboardingStep.securingDevice)) {
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
  final stateHistory =
      ref.watch(shared.primeOnboardingControllerProvider).completedSteps;
  if (stateHistory.contains(shared.PrimeOnboardingStep.walletCreated)) {
    return StepModel(
      stepName: S().finalize_catchAll_masterKeySetUp,
      state: EnvoyStepState.FINISHED,
    );
  } else if (stateHistory.any({
    shared.PrimeOnboardingStep.walletCreationScreen,
    shared.PrimeOnboardingStep.creatingWallet,
  }.contains)) {
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
  final stateHistory =
      ref.watch(shared.primeOnboardingControllerProvider).completedSteps;
  if (stateHistory.any({
    shared.PrimeOnboardingStep.magicBackupCreated,
    shared.PrimeOnboardingStep.connectingWallet,
    shared.PrimeOnboardingStep.walletConnected,
  }.contains)) {
    return StepModel(
      stepName: S().finalize_catchAll_masterKeyBackedUp,
      state: EnvoyStepState.FINISHED,
    );
  } else if (stateHistory.any({
    shared.PrimeOnboardingStep.magicBackupScreen,
    shared.PrimeOnboardingStep.creatingMagicBackup,
    shared.PrimeOnboardingStep.creatingManualBackup,
    shared.PrimeOnboardingStep.creatingKeycardBackup,
    shared.PrimeOnboardingStep.writingDownSeedWords,
  }.contains)) {
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
  final state = ref.watch(shared.primeOnboardingControllerProvider);
  final accountConnection = state.accountConnection;
  if (accountConnection != null) {
    return accountConnection;
  }
  if (state.completedSteps
      .contains(shared.PrimeOnboardingStep.walletConnected)) {
    return StepModel(
      stepName: S().finalize_catchAll_connectingAccount,
      state: EnvoyStepState.FINISHED,
    );
  } else if (state.completedSteps
      .contains(shared.PrimeOnboardingStep.connectingWallet)) {
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

final primeOnboardingStepProvider =
    Provider<shared.PrimeOnboardingStep?>((ref) {
  return ref.watch(shared.primeOnboardingControllerProvider).latestStep;
});

final primeOnboardingCompletedStepsProvider =
    Provider<Set<shared.PrimeOnboardingStep>>((ref) {
  return ref.watch(shared.primeOnboardingControllerProvider).completedSteps;
});

shared.PrimeOnboardingStep mapQlv1OnboardingStep(OnboardingState state) {
  return switch (state) {
    OnboardingState.securityChecked =>
      shared.PrimeOnboardingStep.securityChecked,
    OnboardingState.securityCheckFailed =>
      shared.PrimeOnboardingStep.securityCheckFailed,
    OnboardingState.firmwareUpdateScreen =>
      shared.PrimeOnboardingStep.firmwareUpdateScreen,
    OnboardingState.securingDevice => shared.PrimeOnboardingStep.securingDevice,
    OnboardingState.deviceSecured => shared.PrimeOnboardingStep.deviceSecured,
    OnboardingState.walletCreationScreen =>
      shared.PrimeOnboardingStep.walletCreationScreen,
    OnboardingState.creatingWallet => shared.PrimeOnboardingStep.creatingWallet,
    OnboardingState.walletCreated => shared.PrimeOnboardingStep.walletCreated,
    OnboardingState.magicBackupScreen =>
      shared.PrimeOnboardingStep.magicBackupScreen,
    OnboardingState.creatingMagicBackup =>
      shared.PrimeOnboardingStep.creatingMagicBackup,
    OnboardingState.magicBackupCreated =>
      shared.PrimeOnboardingStep.magicBackupCreated,
    OnboardingState.creatingManualBackup =>
      shared.PrimeOnboardingStep.creatingManualBackup,
    OnboardingState.creatingKeycardBackup =>
      shared.PrimeOnboardingStep.creatingKeycardBackup,
    OnboardingState.writingDownSeedWords =>
      shared.PrimeOnboardingStep.writingDownSeedWords,
    OnboardingState.connectingWallet =>
      shared.PrimeOnboardingStep.connectingWallet,
    OnboardingState.walletConected =>
      shared.PrimeOnboardingStep.walletConnected,
    OnboardingState.completed => shared.PrimeOnboardingStep.completed,
  };
}

final settingsUpdateConnectionProvider = StreamProvider<QLConnection>((ref) {
  final asyncConnections = ref.watch(qlConnectionStreamProvider);
  final connections = asyncConnections.valueOrNull ?? [];

  if (connections.isEmpty) return const Stream.empty();

  final controller = StreamController<QLConnection>();
  final group = StreamGroup<QLConnection>();
  for (final conn in connections) {
    final savedDevice = conn.getDevice();
    if (savedDevice?.protocol == PrimeConnectionProtocol.qlV2) {
      final handler = conn.v2Handler;
      if (handler != null) {
        group.add(
          handler.firmwareEvents.settingsUpdateStarted
              .map<QLConnection>((_) => conn),
        );
      }
    } else {
      group.add(
        conn.qlHandler.fwUpdateHandler.settingsUpdateStarted
            .map<QLConnection>((_) => conn),
      );
    }
  }
  final sub = group.stream.listen(controller.add);
  ref.onDispose(() {
    sub.cancel();
    group.close();
    controller.close();
  });
  return controller.stream;
});

void resetOnboardingPrimeProviders(ProviderContainer container) {
  try {
    container
        .read(shared.primeOnboardingControllerProvider.notifier)
        .resetSession();
  } catch (e, stack) {
    kPrint("Error resetting onboarding providers: $e");
    debugPrintStack(stackTrace: stack);
  }
}

Future<void> clearOnboardingPrimeSession(ProviderContainer container) async {
  await container
      .read(shared.primeOnboardingControllerProvider.notifier)
      .clearSession();
  container.read(onboardingDeviceProvider.notifier).state = null;
}
