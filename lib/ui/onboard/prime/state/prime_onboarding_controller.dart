// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';

import 'package:envoy/ble/handlers/scv_handler.dart';
import 'package:envoy/ui/widgets/envoy_step_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum PrimeOnboardingStep {
  securityChecked,
  securityCheckFailed,
  firmwareUpdateScreen,
  securingDevice,
  deviceSecured,
  walletCreationScreen,
  creatingWallet,
  walletCreated,
  magicBackupScreen,
  creatingMagicBackup,
  magicBackupCreated,
  creatingManualBackup,
  creatingKeycardBackup,
  writingDownSeedWords,
  connectingWallet,
  walletConnected,
  completed,
}

enum PrimeFwUpdateStep {
  downloading,
  transferring,
  verifying,
  installing,
  rebooting,
  finished,
  notAvailable,
  error,
  idle,
}

class SecurityStepModel extends StepModel {
  final ScvErrorType errorType;

  SecurityStepModel({
    required super.stepName,
    required super.state,
    this.errorType = ScvErrorType.none,
  });
}

class PrimeFirmwareTransferProgress {
  final double progress;
  final String remainingTime;

  const PrimeFirmwareTransferProgress({
    required this.progress,
    required this.remainingTime,
  });
}

class PrimeFirmwareChangelog {
  final String version;
  final String changelog;

  const PrimeFirmwareChangelog({
    required this.version,
    required this.changelog,
  });
}

abstract interface class PrimeOnboardingAdapter {
  void attach(PrimeOnboardingController controller);

  void reset();

  Future<void> dispose();
}

class PrimeOnboardingUiState {
  final StepModel? bleConnection;
  final SecurityStepModel? security;
  final StepModel? firmwareCheck;
  final StepModel? firmwareDownload;
  final StepModel? accountConnection;
  final double firmwareDownloadProgress;
  final PrimeFirmwareTransferProgress? firmwareTransferProgress;
  final String currentFirmwareVersion;
  final String targetFirmwareVersion;
  final String estimatedFirmwareUpdateTime;
  final List<PrimeFirmwareChangelog> firmwareChangelogs;
  final bool isSettingsFirmwareUpdate;
  final PrimeOnboardingStep? latestStep;
  final Set<PrimeOnboardingStep> completedSteps;
  final PrimeFwUpdateStep firmwareUpdateStep;
  final Set<PrimeFwUpdateStep> completedFirmwareSteps;

  const PrimeOnboardingUiState({
    this.bleConnection,
    this.security,
    this.firmwareCheck,
    this.firmwareDownload,
    this.accountConnection,
    this.firmwareDownloadProgress = 0,
    this.firmwareTransferProgress,
    this.currentFirmwareVersion = '',
    this.targetFirmwareVersion = '',
    this.estimatedFirmwareUpdateTime = '',
    this.firmwareChangelogs = const [],
    this.isSettingsFirmwareUpdate = false,
    this.latestStep,
    this.completedSteps = const {},
    this.firmwareUpdateStep = PrimeFwUpdateStep.idle,
    this.completedFirmwareSteps = const {},
  });

  PrimeOnboardingUiState copyWith({
    StepModel? bleConnection,
    SecurityStepModel? security,
    StepModel? firmwareCheck,
    StepModel? firmwareDownload,
    StepModel? accountConnection,
    double? firmwareDownloadProgress,
    PrimeFirmwareTransferProgress? firmwareTransferProgress,
    String? currentFirmwareVersion,
    String? targetFirmwareVersion,
    String? estimatedFirmwareUpdateTime,
    List<PrimeFirmwareChangelog>? firmwareChangelogs,
    bool? isSettingsFirmwareUpdate,
    PrimeOnboardingStep? latestStep,
    Set<PrimeOnboardingStep>? completedSteps,
    PrimeFwUpdateStep? firmwareUpdateStep,
    Set<PrimeFwUpdateStep>? completedFirmwareSteps,
    bool clearFirmwareTransferProgress = false,
    bool clearLatestStep = false,
  }) {
    return PrimeOnboardingUiState(
      bleConnection: bleConnection ?? this.bleConnection,
      security: security ?? this.security,
      firmwareCheck: firmwareCheck ?? this.firmwareCheck,
      firmwareDownload: firmwareDownload ?? this.firmwareDownload,
      accountConnection: accountConnection ?? this.accountConnection,
      firmwareDownloadProgress:
          firmwareDownloadProgress ?? this.firmwareDownloadProgress,
      firmwareTransferProgress: clearFirmwareTransferProgress
          ? null
          : firmwareTransferProgress ?? this.firmwareTransferProgress,
      currentFirmwareVersion:
          currentFirmwareVersion ?? this.currentFirmwareVersion,
      targetFirmwareVersion:
          targetFirmwareVersion ?? this.targetFirmwareVersion,
      estimatedFirmwareUpdateTime:
          estimatedFirmwareUpdateTime ?? this.estimatedFirmwareUpdateTime,
      firmwareChangelogs: firmwareChangelogs ?? this.firmwareChangelogs,
      isSettingsFirmwareUpdate:
          isSettingsFirmwareUpdate ?? this.isSettingsFirmwareUpdate,
      latestStep: clearLatestStep ? null : latestStep ?? this.latestStep,
      completedSteps: completedSteps ?? this.completedSteps,
      firmwareUpdateStep: firmwareUpdateStep ?? this.firmwareUpdateStep,
      completedFirmwareSteps:
          completedFirmwareSteps ?? this.completedFirmwareSteps,
    );
  }
}

class PrimeOnboardingController extends StateNotifier<PrimeOnboardingUiState> {
  PrimeOnboardingController() : super(const PrimeOnboardingUiState());

  PrimeOnboardingAdapter? _adapter;
  int _adapterGeneration = 0;

  Future<void> useAdapter(PrimeOnboardingAdapter adapter) async {
    final generation = ++_adapterGeneration;
    final previous = _adapter;
    _adapter = null;
    await previous?.dispose();
    if (generation != _adapterGeneration) {
      await adapter.dispose();
      return;
    }
    state = const PrimeOnboardingUiState();
    _adapter = adapter;
    adapter.attach(this);
  }

  void resetSession() {
    _adapter?.reset();
    state = const PrimeOnboardingUiState();
  }

  Future<void> clearSession() async {
    ++_adapterGeneration;
    final previous = _adapter;
    _adapter = null;
    await previous?.dispose();
    state = const PrimeOnboardingUiState();
  }

  void reset() {
    resetSession();
  }

  void updateBleConnection(String message, EnvoyStepState step) {
    state = state.copyWith(
      bleConnection: StepModel(stepName: message, state: step),
    );
  }

  void updateSecurity(
    String message,
    EnvoyStepState step, {
    ScvErrorType errorType = ScvErrorType.none,
  }) {
    state = state.copyWith(
      security: SecurityStepModel(
        stepName: message,
        state: step,
        errorType: errorType,
      ),
    );
  }

  void updateFirmwareCheck(String message, EnvoyStepState step) {
    state = state.copyWith(
      firmwareCheck: StepModel(stepName: message, state: step),
    );
  }

  void updateFirmwareDownload(String message, EnvoyStepState step) {
    state = state.copyWith(
      firmwareDownload: StepModel(stepName: message, state: step),
    );
  }

  void updateFirmwareDownloadProgress(double progress) {
    state = state.copyWith(firmwareDownloadProgress: progress);
  }

  void updateFirmwareMetadata({
    required String currentVersion,
    required String targetVersion,
    required String estimatedTime,
    required List<PrimeFirmwareChangelog> changelogs,
  }) {
    state = state.copyWith(
      currentFirmwareVersion: currentVersion,
      targetFirmwareVersion: targetVersion,
      estimatedFirmwareUpdateTime: estimatedTime,
      firmwareChangelogs: List.unmodifiable(changelogs),
    );
  }

  void setSettingsFirmwareUpdate(bool isSettingsUpdate) {
    state = state.copyWith(isSettingsFirmwareUpdate: isSettingsUpdate);
  }

  void updateAccountConnection(String message, EnvoyStepState step) {
    state = state.copyWith(
      accountConnection: StepModel(stepName: message, state: step),
    );
  }

  void updateFirmwareTransferProgress({
    required double progress,
    required String remainingTime,
  }) {
    state = state.copyWith(
      firmwareTransferProgress: PrimeFirmwareTransferProgress(
        progress: progress,
        remainingTime: remainingTime,
      ),
    );
  }

  void recordStep(PrimeOnboardingStep step) {
    state = state.copyWith(
      latestStep: step,
      completedSteps: {
        ...state.completedSteps,
        step,
      },
    );
  }

  void replaceCompletedSteps(Set<PrimeOnboardingStep> steps) {
    state = state.copyWith(
      completedSteps: Set.unmodifiable(steps),
      latestStep: steps.isEmpty ? null : steps.last,
      clearLatestStep: steps.isEmpty,
    );
  }

  void recordFirmwareUpdateStep(PrimeFwUpdateStep step) {
    state = state.copyWith(
      firmwareUpdateStep: step,
      completedFirmwareSteps: step == PrimeFwUpdateStep.idle
          ? const {}
          : {
              ...state.completedFirmwareSteps,
              step,
            },
      clearFirmwareTransferProgress: step == PrimeFwUpdateStep.idle,
    );
  }

  void replaceCompletedFirmwareSteps(Set<PrimeFwUpdateStep> steps) {
    state = state.copyWith(
      completedFirmwareSteps: Set.unmodifiable(steps),
    );
  }

  @override
  void dispose() {
    final adapter = _adapter;
    _adapter = null;
    if (adapter != null) {
      unawaited(adapter.dispose());
    }
    super.dispose();
  }
}

final primeOnboardingControllerProvider =
    StateNotifierProvider<PrimeOnboardingController, PrimeOnboardingUiState>(
        (ref) {
  return PrimeOnboardingController();
});
