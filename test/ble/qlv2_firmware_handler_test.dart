// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ble/qlv2/handlers/firmware_handler.dart';
import 'package:envoy/business/devices.dart';
import 'package:envoy/channels/ql_connection.dart';
import 'package:envoy/ui/onboard/prime/state/prime_onboarding_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_tor/http_tor.dart';
import 'package:mockito/mockito.dart';
import 'package:qlv2/qlv2.dart' as qlv2;

void main() {
  test('only completed devices start the settings firmware flow', () async {
    final events = QLV2FirmwareEvents();
    addTearDown(events.dispose);
    final connection = _MockQLConnection();
    final settingsUpdates = <void>[];
    final subscription =
        events.settingsUpdateStarted.listen(settingsUpdates.add);
    addTearDown(subscription.cancel);
    const currentVersion = '1.0.0';
    final patch = QLV2FirmwarePatch(
      version: '1.1.0',
      baseVersion: currentVersion,
      updateFilename: 'update.tar',
      changelog: 'Update',
      releaseDate: DateTime.utc(2026),
      size: 1,
    );
    final source = _FakeFirmwareSource([patch]);
    final request = _FakeInboundRequestCheckFirmwareUpdate(currentVersion);
    final device = _FakeDevice(false);

    when(connection.getDevice()).thenReturn(device);

    final handler = QLV2FirmwareUpdateCheckHandler(
      events: events,
      firmwareSource: source,
    );
    await handler.handleRequest(
      qlv2.InboundRpc_FirmwareUpdateCheck(request),
      connection,
    );
    await Future<void>.delayed(Duration.zero);

    expect(settingsUpdates, isEmpty);

    device.onboardingComplete = true;
    await handler.handleRequest(
      qlv2.InboundRpc_FirmwareUpdateCheck(request),
      connection,
    );
    await Future<void>.delayed(Duration.zero);

    expect(settingsUpdates, hasLength(1));
  });

  test('ignores a cached install error replay when subscriptions restart',
      () async {
    final events = QLV2FirmwareEvents();
    addTearDown(events.dispose);
    final connection = _MockQLConnection();
    const error = qlv2.FirmwareInstallEvent.error(
      error: 'download error: internal error',
      stage: qlv2.InstallErrorStage.download,
    );

    await QLV2FirmwareInstallStatusHandler(events).handleEvent(
      error,
      connection,
    );

    expect(events.lastUpdateStep, PrimeFwUpdateStep.idle);

    events.emitUpdateStep(PrimeFwUpdateStep.downloading);
    await QLV2FirmwareInstallStatusHandler(events).handleEvent(
      error,
      connection,
    );

    expect(events.lastUpdateStep, PrimeFwUpdateStep.downloading);
  });

  test('accepts a new install error during an active firmware update',
      () async {
    final events = QLV2FirmwareEvents();
    addTearDown(events.dispose);
    final connection = _MockQLConnection();
    const error = qlv2.FirmwareInstallEvent.error(
      error: 'download error: internal error',
      stage: qlv2.InstallErrorStage.download,
    );

    events.emitUpdateStep(PrimeFwUpdateStep.downloading);
    await QLV2FirmwareInstallStatusHandler(events).handleEvent(
      error,
      connection,
    );

    expect(events.lastUpdateStep, PrimeFwUpdateStep.error);
  });

  test('accepts a changed install error after subscriptions restart', () async {
    final events = QLV2FirmwareEvents();
    addTearDown(events.dispose);
    final connection = _MockQLConnection();

    await QLV2FirmwareInstallStatusHandler(events).handleEvent(
      const qlv2.FirmwareInstallEvent.error(
        error: 'download error: internal error',
        stage: qlv2.InstallErrorStage.download,
      ),
      connection,
    );
    events.emitUpdateStep(PrimeFwUpdateStep.transferring);
    await QLV2FirmwareInstallStatusHandler(events).handleEvent(
      const qlv2.FirmwareInstallEvent.error(
        error: 'verify error: invalid signature',
        stage: qlv2.InstallErrorStage.verify,
      ),
      connection,
    );

    expect(events.lastUpdateStep, PrimeFwUpdateStep.error);
  });
}

class _MockQLConnection extends Mock implements QLConnection {
  @override
  String get deviceId => 'device-id';
}

class _FakeDevice extends Fake implements Device {
  _FakeDevice(this.onboardingComplete);

  @override
  bool onboardingComplete;
}

class _FakeFirmwareSource implements QLV2FirmwareSource {
  _FakeFirmwareSource(this.patches);

  final List<QLV2FirmwarePatch> patches;

  @override
  Future<List<QLV2FirmwarePatch>> fetchPatches(String currentVersion) async =>
      patches;

  @override
  Future<List<QLV2FirmwarePatchPayload>> prepareDownload(
    String currentVersion,
    List<QLV2FirmwarePatch> patches, {
    required DownloadCancellationToken cancellationToken,
    required void Function(double progress) onProgress,
  }) {
    throw UnimplementedError();
  }
}

class _FakeInboundRequestCheckFirmwareUpdate
    implements qlv2.InboundRequestCheckFirmwareUpdate {
  _FakeInboundRequestCheckFirmwareUpdate(String currentVersion)
      : payload =
            qlv2.FirmwareUpdateCheckParams(currentVersion: currentVersion);

  @override
  qlv2.FirmwareUpdateCheckParams payload;

  qlv2.FirmwareUpdateCheckResponse? response;

  @override
  Future<void> respond({
    required qlv2.FirmwareUpdateCheckResponse response,
  }) async {
    this.response = response;
  }

  @override
  bool get isDisposed => false;

  @override
  void dispose() {}
}
