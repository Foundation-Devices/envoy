// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later
// ignore_for_file: constant_identifier_names

import 'dart:async';

import 'package:envoy/ble/qlv2/protocol_handler.dart';
import 'package:envoy/ble/qlv2/session_controller.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/channels/ql_connection.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/onboard/prime/state/ble_onboarding_session_state.dart';
import 'package:envoy/ui/onboard/prime/state/prime_onboarding_controller.dart';
import 'package:envoy/ui/onboard/prime/state/qlv2/prime_onboarding_qlv2_router.dart';
import 'package:envoy/ui/onboard/prime/state/qlv2/prime_onboarding_qlv2_onboarding_status.dart';
import 'package:envoy/ui/widgets/envoy_step_item.dart';
import 'package:envoy/util/console.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qlv2/qlv2.dart' as qlv2;

class Qlv2PrimeOnboardingAdapter implements PrimeOnboardingAdapter {
  final QLConnection device;
  final QLV2ProtocolHandler handler;
  final bool isSettingsUpdate;

  Qlv2PrimeOnboardingAdapter({
    required this.device,
    required this.handler,
    this.isSettingsUpdate = false,
  });

  final _subscriptions = <StreamSubscription<dynamic>>[];
  PrimeOnboardingController? _controller;
  Timer? _onboardingRetryTimer;
  bool _disposed = false;
  bool _onboardingComplete = false;
  bool _onboardingSubscriptionOpen = false;

  bool get _isAttached => !_disposed && _controller != null;

  void _update(void Function(PrimeOnboardingController controller) update) {
    final controller = _controller;
    if (!_isAttached || controller == null) return;
    update(controller);
  }

  void _updateFirmwareMetadata() {
    final events = handler.firmwareEvents;
    _update(
      (controller) => controller.updateFirmwareMetadata(
        currentVersion: events.currentVersion,
        targetVersion: events.newVersion,
        estimatedTime: events.estimatedUpdateTime,
        changelogs: events.changelogs,
      ),
    );
  }

  @override
  void attach(PrimeOnboardingController controller) {
    _controller = controller;
    _disposed = false;
    controller.setSettingsFirmwareUpdate(isSettingsUpdate);
    if (!isSettingsUpdate) {
      handler.sessionController.registerScope(
        QLV2RouteScopes.primeOnboarding,
        buildPrimeOnboardingQlv2Router(
          controller,
          skipSecurityCheck: Settings().skipPrimeSecurityCheck,
          shouldHandle: () => _isAttached,
        ),
      );
    }
    controller.updateBleConnection(
      handler.isActive
          ? S().onboarding_connectionIntro_connectedToPrime
          : "Connecting to Prime",
      handler.isActive ? EnvoyStepState.FINISHED : EnvoyStepState.LOADING,
    );

    final firmwareEvents = handler.firmwareEvents;
    final lastCheck = firmwareEvents.lastCheckState;
    if (lastCheck != null) {
      controller.updateFirmwareCheck(lastCheck.message, lastCheck.step);
    }
    final lastDownload = firmwareEvents.lastDownloadState;
    if (lastDownload != null) {
      controller.updateFirmwareDownload(
        lastDownload.message,
        lastDownload.step,
      );
    }
    controller.replaceCompletedFirmwareSteps(
      firmwareEvents.completedUpdateStates,
    );
    controller.recordFirmwareUpdateStep(firmwareEvents.lastUpdateStep);
    _updateFirmwareMetadata();

    _subscriptions.add(handler.activeStream.listen(_updateActive));
    _subscriptions.add(
      handler.peerStatusStream.listen(
        (event) => _update(
          (controller) => controller.updateBleConnection(
            _mapQlv2PeerStatusMessage(event.status),
            _mapQlv2PeerStatusStep(event.status),
          ),
        ),
      ),
    );
    _subscriptions.add(
      handler.errorStream.listen(
        (_) => _update(
          (controller) => controller.updateBleConnection(
            S().onboarding_modalBluetoothUnableConnect_content,
            EnvoyStepState.ERROR,
          ),
        ),
      ),
    );
    _subscriptions.add(
      firmwareEvents.check.listen((state) {
        _update(
          (controller) =>
              controller.updateFirmwareCheck(state.message, state.step),
        );
        _updateFirmwareMetadata();
      }),
    );
    _subscriptions.add(
      firmwareEvents.download.listen((state) {
        _update(
          (controller) =>
              controller.updateFirmwareDownload(state.message, state.step),
        );
        _updateFirmwareMetadata();
      }),
    );
    _subscriptions.add(
      firmwareEvents.downloadProgress.listen(
        (progress) => _update(
          (controller) => controller.updateFirmwareDownloadProgress(progress),
        ),
      ),
    );
    _subscriptions.add(
      firmwareEvents.updateStep.listen((step) {
        _update((controller) => controller.recordFirmwareUpdateStep(step));
        _updateFirmwareMetadata();
      }),
    );
    _subscriptions.add(
      firmwareEvents.transferProgress.listen(
        (progress) => _update(
          (controller) => controller.updateFirmwareTransferProgress(
            progress: progress.progress,
            remainingTime: progress.remainingTime,
          ),
        ),
      ),
    );

    _subscriptions.add(
      handler.accountUpdateEvents.status.listen(
        (state) => _update((controller) {
          controller.updateAccountConnection(state.message, state.step);
          if (state.step == EnvoyStepState.LOADING) {
            controller.recordStep(PrimeOnboardingStep.connectingWallet);
          } else if (state.step == EnvoyStepState.FINISHED) {
            controller.recordStep(PrimeOnboardingStep.walletConnected);
          }
        }),
      ),
    );

    if (handler.isActive) {
      _updateActive(true);
    }
  }

  void _scheduleOnboardingSubscriptionRetry() {
    if (!_isAttached || _onboardingComplete || !handler.isActive) return;
    _onboardingRetryTimer?.cancel();
    _onboardingRetryTimer = Timer(const Duration(seconds: 2), () {
      if (!_isAttached || _onboardingComplete || !handler.isActive) return;
      _subscribeToOnboardingStatus();
    });
  }

  void _subscribeToOnboardingStatus() {
    if (!_isAttached ||
        _onboardingComplete ||
        _onboardingSubscriptionOpen ||
        !handler.isActive) {
      return;
    }
    _onboardingRetryTimer?.cancel();
    _onboardingSubscriptionOpen = true;
    final onboardingStatus = PrimeOnboardingQlv2OnboardingStatusHandler(
      _controller!,
      shouldHandle: () => _isAttached,
      onCompleted: () async {
        if (!_isAttached) return;
        _onboardingComplete = true;
        _onboardingSubscriptionOpen = false;
        _onboardingRetryTimer?.cancel();
        handler.sessionController.disposeScope(QLV2RouteScopes.primeOnboarding);
      },
    );
    final subscription = handler.subscribeOnboardingStatus().listen(
      (event) => unawaited(onboardingStatus.handleEvent(event, device)),
      onError: (Object error, StackTrace stack) {
        if (!_isAttached) return;
        _onboardingSubscriptionOpen = false;
        kPrint(
          "[PrimeOnboarding] QL v2 onboarding subscription failed: $error",
          stackTrace: stack,
        );
        _scheduleOnboardingSubscriptionRetry();
      },
      onDone: () {
        if (!_isAttached) return;
        _onboardingSubscriptionOpen = false;
        if (!_onboardingComplete && handler.isActive) {
          kPrint(
            "[PrimeOnboarding] QL v2 onboarding subscription closed; retrying",
          );
          _scheduleOnboardingSubscriptionRetry();
        }
      },
    );
    handler.sessionController.registerSubscriptions(
      QLV2RouteScopes.primeOnboarding,
      [subscription],
    );
  }

  void _updateActive(bool active) {
    _update(
      (controller) => controller.updateBleConnection(
        active
            ? S().onboarding_connectionIntro_connectedToPrime
            : "Connecting to Prime",
        active ? EnvoyStepState.FINISHED : EnvoyStepState.LOADING,
      ),
    );
    if (active && !isSettingsUpdate) {
      _subscribeToOnboardingStatus();
    } else {
      _onboardingSubscriptionOpen = false;
      _onboardingRetryTimer?.cancel();
      handler.sessionController.disposeSubscriptions(
        QLV2RouteScopes.primeOnboarding,
      );
    }
  }

  @override
  void reset() {
    if (_disposed) return;
    _onboardingComplete = false;
    _onboardingSubscriptionOpen = false;
    _onboardingRetryTimer?.cancel();
    handler.sessionController.disposeSubscriptions(
      QLV2RouteScopes.primeOnboarding,
    );
    handler.firmwareEvents.reset();
    if (handler.isActive && !isSettingsUpdate) {
      scheduleMicrotask(_subscribeToOnboardingStatus);
    }
  }

  @override
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    _controller = null;
    _onboardingRetryTimer?.cancel();
    handler.sessionController.disposeScope(QLV2RouteScopes.primeOnboarding);
    final activeSubscriptions = List.of(_subscriptions);
    _subscriptions.clear();
    await Future.wait(
      activeSubscriptions.map((subscription) => subscription.cancel()),
    );
  }
}

Future<void> setOnboardingPrimeQlv2Session({
  required ProviderContainer container,
  required QLConnection device,
  required QLV2ProtocolHandler handler,
  bool isSettingsUpdate = false,
}) async {
  device.v2Handler = handler;
  container.read(onboardingDeviceProvider.notifier).state = device;
  await container.read(primeOnboardingControllerProvider.notifier).useAdapter(
        Qlv2PrimeOnboardingAdapter(
          device: device,
          handler: handler,
          isSettingsUpdate: isSettingsUpdate,
        ),
      );
}

void stopOnboardingPrimeQlv2Scope(QLConnection? device) {
  device?.v2Handler?.sessionController.disposeScope(
    QLV2RouteScopes.primeOnboarding,
  );
}

String _mapQlv2PeerStatusMessage(qlv2.ConnectionStatus status) {
  return switch (status) {
    qlv2.ConnectionStatus.connected =>
      S().onboarding_connectionIntro_connectedToPrime,
    qlv2.ConnectionStatus.disconnected => "Connecting to Prime",
    qlv2.ConnectionStatus.unpair => "Connecting to Prime",
    qlv2.ConnectionStatus.initiator => "Connecting to Prime",
  };
}

EnvoyStepState _mapQlv2PeerStatusStep(qlv2.ConnectionStatus status) {
  return switch (status) {
    qlv2.ConnectionStatus.connected => EnvoyStepState.FINISHED,
    qlv2.ConnectionStatus.disconnected => EnvoyStepState.LOADING,
    qlv2.ConnectionStatus.unpair => EnvoyStepState.LOADING,
    qlv2.ConnectionStatus.initiator => EnvoyStepState.LOADING,
  };
}
