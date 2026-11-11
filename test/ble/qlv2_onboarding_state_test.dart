// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ble/bluetooth_manager.dart';
import 'package:envoy/ble/qlv2/handlers/account_update_handler.dart';
import 'package:envoy/ble/qlv2/handlers/firmware_handler.dart';
import 'package:envoy/ble/qlv2/protocol_handler.dart';
import 'package:envoy/ble/qlv2/session_controller.dart';
import 'package:envoy/channels/ql_connection.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/onboard/prime/firmware_update/prime_fw_update.dart';
import 'package:envoy/ui/onboard/prime/firmware_update/prime_fw_update_state.dart';
import 'package:envoy/ui/onboard/prime/state/ble_onboarding_state.dart';
import 'package:envoy/ui/onboard/prime/state/prime_onboarding_controller.dart';
import 'package:envoy/ui/onboard/prime/state/qlv2/prime_onboarding_qlv2_state.dart';
import 'package:envoy/ui/onboard/prime/state/qlv2/prime_onboarding_qlv2_onboarding_status.dart';
import 'package:envoy/ui/routes/accounts_router.dart';
import 'package:envoy/ui/widgets/envoy_gradient_progress.dart';
import 'package:envoy/ui/widgets/envoy_step_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation_api/foundation_api.dart' as qlv1;
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';
import 'package:qlv2/qlv2.dart' as qlv2;

void main() {
  setUpAll(() => S.load(const Locale('en')));

  test('QL v2 onboarding events update the shared onboarding state', () async {
    final controller = PrimeOnboardingController();
    final handler = PrimeOnboardingQlv2OnboardingStatusHandler(controller);

    await handler.handleEvent(
      qlv2.OnboardingState.securingDevice,
      _MockQLConnection(),
    );

    expect(controller.state.latestStep, PrimeOnboardingStep.securingDevice);
    expect(
      controller.state.completedSteps,
      contains(PrimeOnboardingStep.securingDevice),
    );
  });

  test('QL v1 and QL v2 map shared setup states identically', () {
    expect(
      mapQlv1OnboardingStep(qlv1.OnboardingState.firmwareUpdateScreen),
      mapQlv2OnboardingStep(qlv2.OnboardingState.firmwareUpdateScreen),
    );
    expect(
      mapQlv1OnboardingStep(qlv1.OnboardingState.securingDevice),
      mapQlv2OnboardingStep(qlv2.OnboardingState.securingDevice),
    );
    expect(
      mapQlv1OnboardingStep(qlv1.OnboardingState.walletCreated),
      mapQlv2OnboardingStep(qlv2.OnboardingState.walletCreated),
    );
    expect(
      mapQlv1OnboardingStep(qlv1.OnboardingState.completed),
      mapQlv2OnboardingStep(qlv2.OnboardingState.completed),
    );
  });

  test('adapter replacement disposes old adapter and ignores late events',
      () async {
    final controller = PrimeOnboardingController();
    addTearDown(controller.dispose);
    final first = FakePrimeOnboardingAdapter();
    final second = FakePrimeOnboardingAdapter();

    await controller.useAdapter(first);
    first.emitStep(PrimeOnboardingStep.securingDevice);
    expect(controller.state.latestStep, PrimeOnboardingStep.securingDevice);

    await controller.useAdapter(second);
    expect(first.disposed, isTrue);
    first.emitStep(PrimeOnboardingStep.walletCreated);
    expect(controller.state.latestStep, isNull);

    second.emitStep(PrimeOnboardingStep.walletCreated);
    expect(controller.state.latestStep, PrimeOnboardingStep.walletCreated);
  });

  test('QL v2 settings update ignores account routing events', () async {
    final controller = PrimeOnboardingController();
    addTearDown(controller.dispose);
    final firmwareEvents = QLV2FirmwareEvents();
    final accountEvents = QLV2AccountUpdateEvents();
    addTearDown(firmwareEvents.dispose);
    addTearDown(accountEvents.dispose);
    final handler = _MockQLV2ProtocolHandler(
      firmwareEvents: firmwareEvents,
      accountUpdateEvents: accountEvents,
    );
    final adapter = Qlv2PrimeOnboardingAdapter(
      device: _MockQLConnection(),
      handler: handler,
      isSettingsUpdate: true,
    );
    addTearDown(adapter.dispose);
    adapter.attach(controller);

    accountEvents.emit('Connecting wallet', EnvoyStepState.LOADING);
    accountEvents.emit('Wallet connected', EnvoyStepState.FINISHED);
    await Future<void>.delayed(Duration.zero);

    expect(controller.state.latestStep, isNull);
    expect(controller.state.accountConnection, isNull);
    expect(controller.state.firmwareUpdateStep, PrimeFwUpdateStep.idle);
  });

  test('reset and clear delegate adapter lifecycle and clear UI state',
      () async {
    final controller = PrimeOnboardingController();
    addTearDown(controller.dispose);
    final adapter = FakePrimeOnboardingAdapter();
    await controller.useAdapter(adapter);
    adapter.emitStep(PrimeOnboardingStep.securingDevice);

    controller.resetSession();
    expect(adapter.resetCount, 1);
    expect(controller.state.latestStep, isNull);

    await controller.clearSession();
    expect(adapter.disposed, isTrue);
    expect(controller.state.completedSteps, isEmpty);
  });

  test('fake adapter drives every protocol-neutral UI provider', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final adapter = FakePrimeOnboardingAdapter();
    final notifications = <String, int>{};

    void watch<T>(String name, ProviderListenable<T> provider) {
      container.listen<T>(
        provider,
        (_, __) => notifications.update(
          name,
          (count) => count + 1,
          ifAbsent: () => 1,
        ),
        fireImmediately: true,
      );
    }

    watch('connection', bleConnectionProvider);
    watch('security', deviceSecurityProvider);
    watch('firmwareCheck', firmWareUpdateProvider);
    watch('pin', creatingPinProvider);
    watch('masterKey', setUpMasterKeyProvider);
    watch('backup', backUpMasterKeyProvider);
    watch('account', connectAccountProvider);
    watch('latestStep', primeOnboardingStepProvider);
    watch('completedSteps', primeOnboardingCompletedStepsProvider);
    watch('firmwareStep', primeUpdateStateProvider);
    watch('downloadState', fwDownloadStateProvider);
    watch('transferState', fwTransferStateProvider);
    watch('signatureState', primeFwSigVerifyStateProvider);
    watch('installState', primeFwInstallStateProvider);
    watch('rebootState', primeFwRebootStateProvider);
    watch('downloadProgress', fwDownloadProgress);
    watch('transferProgress', fwTransferProgress);

    await container
        .read(primeOnboardingControllerProvider.notifier)
        .useAdapter(adapter);

    adapter.emit(
      (controller) => controller.updateBleConnection(
        'Connected',
        EnvoyStepState.FINISHED,
      ),
    );
    expect(container.read(bleConnectionProvider).stepName, 'Connected');
    expect(
        container.read(bleConnectionProvider).state, EnvoyStepState.FINISHED);

    adapter.emit(
      (controller) => controller.updateSecurity(
        'Security passed',
        EnvoyStepState.FINISHED,
      ),
    );
    expect(container.read(deviceSecurityProvider).stepName, 'Security passed');
    expect(
        container.read(deviceSecurityProvider).state, EnvoyStepState.FINISHED);

    adapter.emit(
      (controller) => controller.updateFirmwareCheck(
        'Update available',
        EnvoyStepState.FINISHED,
      ),
    );
    expect(container.read(firmWareUpdateProvider).stepName, 'Update available');

    adapter.emitStep(PrimeOnboardingStep.securingDevice);
    expect(container.read(creatingPinProvider).state, EnvoyStepState.LOADING);
    adapter.emitStep(PrimeOnboardingStep.deviceSecured);
    expect(container.read(creatingPinProvider).state, EnvoyStepState.FINISHED);

    adapter.emitStep(PrimeOnboardingStep.walletCreationScreen);
    expect(
        container.read(setUpMasterKeyProvider).state, EnvoyStepState.LOADING);
    adapter.emitStep(PrimeOnboardingStep.walletCreated);
    expect(
        container.read(setUpMasterKeyProvider).state, EnvoyStepState.FINISHED);

    adapter.emitStep(PrimeOnboardingStep.magicBackupScreen);
    expect(
        container.read(backUpMasterKeyProvider).state, EnvoyStepState.LOADING);
    adapter.emitStep(PrimeOnboardingStep.magicBackupCreated);
    expect(
        container.read(backUpMasterKeyProvider).state, EnvoyStepState.FINISHED);

    adapter.emitStep(PrimeOnboardingStep.connectingWallet);
    expect(
        container.read(connectAccountProvider).state, EnvoyStepState.LOADING);
    adapter.emitAccount('Account connected', EnvoyStepState.FINISHED);
    expect(
        container.read(connectAccountProvider).stepName, 'Account connected');
    expect(
        container.read(connectAccountProvider).state, EnvoyStepState.FINISHED);

    adapter.emit(
      (controller) => controller.updateFirmwareDownload(
        'Downloading',
        EnvoyStepState.LOADING,
      ),
    );
    adapter
      ..emitFirmwareDownloadProgress(.4)
      ..emitFirmwareStep(PrimeFwUpdateStep.downloading);
    expect(container.read(fwDownloadStateProvider).stepName, 'Downloading');
    expect(container.read(fwDownloadProgress), .4);
    expect(container.read(primeUpdateStateProvider),
        PrimeFwUpdateStep.downloading);

    adapter
      ..emitFirmwareTransferProgress(.7, '2 min')
      ..emitFirmwareStep(PrimeFwUpdateStep.transferring);
    expect(
        container.read(fwTransferStateProvider).state, EnvoyStepState.LOADING);
    expect(container.read(fwTransferProgress)?.progress, .7);
    expect(container.read(fwTransferProgress)?.remainingTime, '2 min');

    adapter.emitFirmwareStep(PrimeFwUpdateStep.verifying);
    expect(container.read(primeFwSigVerifyStateProvider).state,
        EnvoyStepState.LOADING);
    adapter.emitFirmwareStep(PrimeFwUpdateStep.installing);
    expect(container.read(primeFwSigVerifyStateProvider).state,
        EnvoyStepState.FINISHED);
    expect(container.read(primeFwInstallStateProvider).state,
        EnvoyStepState.LOADING);
    adapter.emitFirmwareStep(PrimeFwUpdateStep.rebooting);
    expect(container.read(primeFwInstallStateProvider).state,
        EnvoyStepState.FINISHED);
    expect(container.read(primeFwRebootStateProvider).state,
        EnvoyStepState.LOADING);
    adapter.emitFirmwareStep(PrimeFwUpdateStep.finished);
    expect(container.read(primeFwRebootStateProvider).state,
        EnvoyStepState.FINISHED);

    adapter.emitFirmwareMetadata();
    adapter.emit(
      (controller) => controller.setSettingsFirmwareUpdate(true),
    );
    final state = container.read(primeOnboardingControllerProvider);
    expect(state.currentFirmwareVersion, '1.0.0');
    expect(state.targetFirmwareVersion, '2.0.0');
    expect(state.estimatedFirmwareUpdateTime, '3 min');
    expect(state.firmwareChangelogs.single.changelog, 'Changes');
    expect(state.isSettingsFirmwareUpdate, isTrue);

    adapter.emitStep(PrimeOnboardingStep.completed);
    expect(container.read(primeOnboardingStepProvider),
        PrimeOnboardingStep.completed);
    expect(
      container.read(primeOnboardingCompletedStepsProvider),
      contains(PrimeOnboardingStep.completed),
    );

    adapter
      ..emitSecurityError()
      ..emitFirmwareStep(PrimeFwUpdateStep.error);
    expect(container.read(deviceSecurityProvider).state, EnvoyStepState.ERROR);
    expect(container.read(primeUpdateStateProvider), PrimeFwUpdateStep.error);

    for (final entry in notifications.entries) {
      expect(entry.value, greaterThan(1), reason: '${entry.key} did not fire');
    }
  });

  testWidgets('cached setup and completion events render after widget mount',
      (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final adapter = FakePrimeOnboardingAdapter();
    await container
        .read(primeOnboardingControllerProvider.notifier)
        .useAdapter(adapter);

    adapter
      ..emitStep(PrimeOnboardingStep.securingDevice)
      ..emitStep(PrimeOnboardingStep.deviceSecured)
      ..emitStep(PrimeOnboardingStep.connectingWallet)
      ..emitAccount('Account connected', EnvoyStepState.FINISHED)
      ..emitStep(PrimeOnboardingStep.walletConnected)
      ..emitStep(PrimeOnboardingStep.completed);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: _PrimeStateProbe())),
      ),
    );

    expect(find.textContaining('latest:completed'), findsOneWidget);
    expect(find.textContaining('pin:FINISHED'), findsOneWidget);
    expect(find.textContaining('account:FINISHED'), findsOneWidget);
  });

  testWidgets('firmware error and progress render from neutral state',
      (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final adapter = FakePrimeOnboardingAdapter();
    await container
        .read(primeOnboardingControllerProvider.notifier)
        .useAdapter(adapter);

    adapter
      ..emitFirmwareMetadata()
      ..emitFirmwareDownloadProgress(.4)
      ..emitFirmwareTransferProgress(.7, '2 min')
      ..emitFirmwareStep(PrimeFwUpdateStep.error)
      ..emitSecurityError();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: _PrimeStateProbe())),
      ),
    );

    expect(find.textContaining('firmware:error'), findsOneWidget);
    expect(find.textContaining('download:0.4'), findsOneWidget);
    expect(find.textContaining('transfer:0.7/2 min'), findsOneWidget);
    expect(find.textContaining('security:ERROR'), findsOneWidget);
    expect(find.textContaining('versions:1.0.0>2.0.0'), findsOneWidget);
  });

  testWidgets('settings reboot clears the session and closes the update page',
      (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final controller =
        container.read(primeOnboardingControllerProvider.notifier);
    controller
      ..setSettingsFirmwareUpdate(true)
      ..recordFirmwareUpdateStep(PrimeFwUpdateStep.installing);
    final router = GoRouter(
      initialLocation: '/update',
      routes: [
        GoRoute(
          path: '/update',
          builder: (_, __) => const Scaffold(body: PrimeFwFlashProgress()),
        ),
        GoRoute(
          path: ROUTE_ACCOUNTS_HOME,
          builder: (_, __) => const SizedBox(key: ValueKey('accounts-home')),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    expect(find.text(S().component_continue), findsNothing);

    controller.recordFirmwareUpdateStep(PrimeFwUpdateStep.rebooting);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('accounts-home')), findsOneWidget);
    expect(container.read(onboardingDeviceProvider), isNull);
    expect(container.read(primeUpdateStateProvider), PrimeFwUpdateStep.idle);
  });

  testWidgets('QL v2 transfer uses indeterminate progress', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final firmwareEvents = QLV2FirmwareEvents();
    final accountEvents = QLV2AccountUpdateEvents();
    addTearDown(firmwareEvents.dispose);
    addTearDown(accountEvents.dispose);
    final handler = _MockQLV2ProtocolHandler(
      firmwareEvents: firmwareEvents,
      accountUpdateEvents: accountEvents,
    );
    final connection = _MockQLConnection();
    when(connection.v2Handler).thenReturn(handler);
    container.read(onboardingDeviceProvider.notifier).state = connection;
    final controller =
        container.read(primeOnboardingControllerProvider.notifier);
    controller
      ..updateFirmwareTransferProgress(progress: .5, remainingTime: '2 min')
      ..recordFirmwareUpdateStep(PrimeFwUpdateStep.transferring);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(body: PrimeFwDownloadProgress()),
        ),
      ),
    );

    expect(
      find.text(S().firmware_downloadingUpdate_timeRemaining('2 min')),
      findsNothing,
    );
    expect(
      find.text(S().firmware_downloadingUpdate_estimating),
      findsNothing,
    );
    expect(
      tester
          .widget<EnvoyGradientProgress>(find.byType(EnvoyGradientProgress))
          .indeterminate,
      isTrue,
    );
    final indicator = tester
        .widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator));
    expect(indicator.value, isNull);
    expect(indicator.controller?.isAnimating, isTrue);

    controller.recordFirmwareUpdateStep(PrimeFwUpdateStep.downloading);
    await tester.pump();

    expect(
      tester
          .widget<EnvoyGradientProgress>(find.byType(EnvoyGradientProgress))
          .indeterminate,
      isFalse,
    );
  });
}

class _MockQLConnection extends Mock implements QLConnection {}

class _MockQLV2ProtocolHandler extends Mock implements QLV2ProtocolHandler {
  _MockQLV2ProtocolHandler({
    required this.firmwareEvents,
    required this.accountUpdateEvents,
  });

  @override
  final QLV2FirmwareEvents firmwareEvents;

  @override
  final QLV2AccountUpdateEvents accountUpdateEvents;

  @override
  bool get isActive => false;

  @override
  Stream<bool> get activeStream => const Stream.empty();

  @override
  Stream<qlv2.PeerStatusEvent> get peerStatusStream => const Stream.empty();

  @override
  Stream<QLV2ProtocolError> get errorStream => const Stream.empty();

  @override
  final QLV2SessionController sessionController = _MockQLV2SessionController();
}

class _MockQLV2SessionController extends Mock implements QLV2SessionController {
  @override
  bool disposeScope(String name) => false;

  @override
  bool disposeSubscriptions(String name) => false;
}

class FakePrimeOnboardingAdapter implements PrimeOnboardingAdapter {
  PrimeOnboardingController? _controller;
  bool disposed = false;
  int resetCount = 0;

  @override
  void attach(PrimeOnboardingController controller) {
    _controller = controller;
    disposed = false;
  }

  void emitStep(PrimeOnboardingStep step) {
    emit((controller) => controller.recordStep(step));
  }

  void emit(void Function(PrimeOnboardingController controller) update) {
    final controller = _controller;
    if (disposed || controller == null) return;
    update(controller);
  }

  void emitAccount(String message, EnvoyStepState state) {
    emit((controller) => controller.updateAccountConnection(message, state));
  }

  void emitFirmwareStep(PrimeFwUpdateStep step) {
    emit((controller) => controller.recordFirmwareUpdateStep(step));
  }

  void emitFirmwareDownloadProgress(double progress) {
    emit((controller) => controller.updateFirmwareDownloadProgress(progress));
  }

  void emitFirmwareTransferProgress(double progress, String remainingTime) {
    emit(
      (controller) => controller.updateFirmwareTransferProgress(
        progress: progress,
        remainingTime: remainingTime,
      ),
    );
  }

  void emitFirmwareMetadata() {
    emit(
      (controller) => controller.updateFirmwareMetadata(
        currentVersion: '1.0.0',
        targetVersion: '2.0.0',
        estimatedTime: '3 min',
        changelogs: const [
          PrimeFirmwareChangelog(version: '2.0.0', changelog: 'Changes'),
        ],
      ),
    );
  }

  void emitSecurityError() {
    emit(
      (controller) =>
          controller.updateSecurity('Security failed', EnvoyStepState.ERROR),
    );
  }

  @override
  void reset() {
    resetCount++;
  }

  @override
  Future<void> dispose() async {
    disposed = true;
    _controller = null;
  }
}

class _PrimeStateProbe extends ConsumerWidget {
  const _PrimeStateProbe();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(primeOnboardingControllerProvider);
    final pin = ref.watch(creatingPinProvider);
    final account = ref.watch(connectAccountProvider);
    final firmware = ref.watch(primeUpdateStateProvider);
    return Text(
      'latest:${state.latestStep?.name}\n'
      'pin:${pin.state.name}\n'
      'account:${account.state.name}\n'
      'firmware:${firmware.name}\n'
      'download:${state.firmwareDownloadProgress}\n'
      'transfer:${state.firmwareTransferProgress?.progress}/'
      '${state.firmwareTransferProgress?.remainingTime}\n'
      'security:${state.security?.state.name}\n'
      'versions:${state.currentFirmwareVersion}>'
      '${state.targetFirmwareVersion}',
    );
  }
}
