// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later
// ignore_for_file: constant_identifier_names///

import 'dart:async';
import 'dart:typed_data';

import 'package:envoy/ble/bluetooth_manager.dart';
import 'package:envoy/ble/quantum_link_router.dart';
import 'package:envoy/business/server.dart';
import 'package:envoy/channels/ble_status.dart';
import 'package:envoy/channels/bluetooth_channel.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/onboard/prime/firmware_update/prime_fw_update_state.dart';
import 'package:envoy/ui/widgets/envoy_step_item.dart';
import 'package:envoy/util/bug_report_helper.dart';
import 'package:envoy/util/console.dart';
import 'package:envoy/util/ntp.dart';
import 'package:envoy/util/transfer_rate_estimator.dart';
import 'package:foundation_api/foundation_api.dart' as api;

class FwUpdateState {
  final String message;
  final EnvoyStepState step;

  FwUpdateState({required this.message, required this.step});
}

class FwTransferProgress {
  final double progress;
  final String remainingTime;

  FwTransferProgress({required this.progress, required this.remainingTime});
}

class FwUpdateHandler extends PassportMessageHandler {
  FwUpdateHandler(super.connection);

  Set<PrimeFwUpdateStep> _completedUpdateStates = {};

  //TODO: multi device, move this to somewhere per-device
  String newVersion = "";
  String currentVersion = "";

  // Transfer rate estimator
  // reset this every time a new transfer starts
  final _transferEstimator = TransferRateEstimator();

  final _fetchState = StreamController<FwUpdateState>.broadcast();
  final _downloadState = StreamController<FwUpdateState>.broadcast();
  final _transferState = StreamController<FwUpdateState>.broadcast();
  final _primeFwUpdate = StreamController<PrimeFwUpdateStep>.broadcast();
  final _transferProgress = StreamController<FwTransferProgress>.broadcast();

  Stream<FwUpdateState> get fetchStateStream =>
      _fetchState.stream.asBroadcastStream();

  Stream<FwTransferProgress> get transferProgress =>
      _transferProgress.stream.asBroadcastStream();

  Stream<PrimeFwUpdateStep> get primeFwUpdate =>
      _primeFwUpdate.stream.asBroadcastStream();

  Stream<FwUpdateState> get downloadStateStream =>
      _downloadState.stream.asBroadcastStream();

  Stream<FwUpdateState> get transferStateStream =>
      _transferState.stream.asBroadcastStream();

  Set<PrimeFwUpdateStep> get completedUpdateStates => _completedUpdateStates;

  @override
  bool canHandle(api.QuantumLinkMessage message) {
    return message is api.QuantumLinkMessage_FirmwareUpdateCheckRequest ||
        message is api.QuantumLinkMessage_FirmwareFetchRequest ||
        message is api.QuantumLinkMessage_FirmwareInstallEvent ||
        message is api.QuantumLinkMessage_OnboardingState;
  }

  @override
  Future<void> handleMessage(api.QuantumLinkMessage message) async {
    if (message
        case api.QuantumLinkMessage_FirmwareUpdateCheckRequest updateRequest) {
      currentVersion = updateRequest.field0.currentVersion;
      _handleFwUpdateCheckRequest(currentVersion);
    } else if (message
        case api.QuantumLinkMessage_FirmwareFetchRequest fetchRequest) {
      final version = fetchRequest.field0.currentVersion;
      _handleFirmwareFetchRequest(version);
    } else if (message
        case api.QuantumLinkMessage_FirmwareInstallEvent installEvent) {
      _handleOnboardingState(installEvent.field0);
    }
  }

  //Downloads and sends firmware update to the device
  Future<void> _handleFirmwareFetchRequest(String currentVersion) async {
    List<PrimePatch> patches = [];

    try {
      _completedUpdateStates = {};
      _transferProgress.add(
        FwTransferProgress(progress: 0.0, remainingTime: ""),
      );
      _updateFwUpdateState(PrimeFwUpdateStep.downloading);
      _updateDownloadState(
        S().firmware_downloadingUpdate_header,
        EnvoyStepState.LOADING,
      );
      patches = await Server().fetchPrimePatches(currentVersion);
      _updateDownloadState(
        S().firmware_downloadingUpdate_downloaded,
        EnvoyStepState.FINISHED,
      );
    } catch (e) {
      kPrint("failed to fetch patches: $e");
      _updateDownloadState(
        S().firmware_updateError_downloadFailed,
        EnvoyStepState.ERROR,
      );
      await _handleFirmwareError(S().firmware_updateError_downloadFailed);
      return;
    }

    if (patches.isEmpty) {
      await sendFirmwareFetchEvent(api.FirmwareFetchEvent.updateNotAvailable());
    } else {
      await sendFirmwareFetchEvent(
        api.FirmwareFetchEvent.starting(updateAvailableMessage(patches)),
      );

      List<Uint8List> patchBinaries = [];

      try {
        for (final patch in patches) {
          final binary = await Server().fetchPrimePatchBinary(patch);
          if (binary == null) {
            throw Exception("Must get all the patches!");
          }
          patchBinaries.add(binary);
        }
      } catch (e) {
        kPrint("failed to download patch binaries: $e");
        _updateFwUpdateState(PrimeFwUpdateStep.error);
        await _handleFirmwareError(S().firmware_updateError_downloadFailed);
        return;
      }

      try {
        _updateFwUpdateState(PrimeFwUpdateStep.transferring);
        //listen for progress
        await sendFirmwarePayload(patchBinaries);
      } catch (e) {
        _updateFwUpdateState(PrimeFwUpdateStep.error);
        kPrint("failed to transfer firmware: $e");
        await _handleFirmwareError(S().firmware_updateError_receivingFailed);
        return;
      }
    }
  }

  Future<void> sendFirmwarePayload(List<Uint8List> patches) async {
    final tempFile = await BluetoothChannel.getBleCacheFile(
      patches.hashCode.toString(),
    );

    // reset this every time a new transfer starts
    _transferEstimator.reset();

    qlConnection.writeProgressStream().listen((progress) {
      if (progress.id == tempFile.path) {
        _processProgress(progress);
      }
    });
    DateTime dateTime = DateTime.now();
    try {
      dateTime = await NTP.now(timeout: const Duration(seconds: 1));
    } catch (e) {
      kPrint("NTP error: $e");
    }
    final timestampSeconds = (dateTime.millisecondsSinceEpoch ~/ 1000);

    if (BluetoothManager().qlIdentity == null ||
        BluetoothManager().recipientXid == null) {
      EnvoyReport().log(
        "fw_update_handler",
        "Cannot send firmware payload: missing identities,qlIdentity: ${BluetoothManager().qlIdentity},recipientXid ${BluetoothManager().recipientXid}",
      );
      return;
    }
    final ready = await api.encodeToUpdateFile(
      payload: patches,
      sender: BluetoothManager().qlIdentity!,
      recipient: BluetoothManager().recipientXid!,
      path: tempFile.path,
      chunkSize: bleChunkSize,
      timestamp: timestampSeconds,
    );

    if (ready) {
      kPrint("Firmware payload encoded to file: ${tempFile.path}");
      final success = await qlConnection.transmitFromFile(tempFile.path);
      if (!success) {
        await qlConnection.writeMessage(
          api.QuantumLinkMessage.firmwareFetchEvent(
            api.FirmwareFetchEvent.error(
              error: "Firmware payload transmission failed!",
            ),
          ),
        );

        kPrint("Firmware payload transmission failed!");
        return;
      }
      kPrint("Firmware payload sent successfully! $success");
    }
  }

  //Checks for firmware updates
  Future<void> _handleFwUpdateCheckRequest(String currentVersion) async {
    _updateFetchState(
      S().onboarding_connectionChecking_forUpdates,
      EnvoyStepState.LOADING,
    );
    final patches = await Server().fetchPrimePatches(currentVersion);

    final stepUpdate = patches.isNotEmpty
        ? S().onboarding_connectionUpdatesAvailable_updatesAvailable
        : S().onboarding_connectionNoUpdates_noUpdates;

    _updateFetchState(
      S().onboarding_connectionChecking_forUpdates,
      EnvoyStepState.LOADING,
    );
    if (patches.isEmpty) {
      _updateFetchState(stepUpdate, EnvoyStepState.FINISHED);
      qlConnection.writeMessage(
        api.QuantumLinkMessage.firmwareUpdateCheckResponse(
          api.FirmwareUpdateCheckResponse_NotAvailable(),
        ),
      );
    } else {
      newVersion = patches.last.version;
      final response = api.QuantumLinkMessage.firmwareUpdateCheckResponse(
        api.FirmwareUpdateCheckResponse.available(
          updateAvailableMessage(patches),
        ),
      );
      await qlConnection.writeMessage(response);
    }

    _updateFetchState(stepUpdate, EnvoyStepState.FINISHED);
  }

  Future<void> _handleFirmwareError(String errorBody) async {
    _updateFetchState(errorBody, EnvoyStepState.ERROR);

    await sendFirmwareFetchEvent(
      api.FirmwareFetchEvent.error(error: errorBody),
    );
  }

  Future<void> sendFirmwareFetchEvent(api.FirmwareFetchEvent event) async {
    await qlConnection.writeMessage(
      api.QuantumLinkMessage.firmwareFetchEvent(event),
    );
  }

  api.FirmwareUpdateAvailable updateAvailableMessage(List<PrimePatch> patches) {
    final latest = patches.last;

    final changelog = patches.reversed.fold(
      "",
      (acc, p) => "$acc\n${p.changelog}",
    );
    newVersion = latest.version;
    return api.FirmwareUpdateAvailable(
      version: latest.version,
      changelog: changelog,
      timestamp: latest.releaseDate.millisecondsSinceEpoch,
      totalSize: 100,
      patchCount: patches.length,
    );
  }

  //UI state updates
  void _updateFetchState(String message, EnvoyStepState state) {
    _fetchState.sink.add(FwUpdateState(message: message, step: state));
  }

  void _updateFwUpdateState(PrimeFwUpdateStep step) {
    _completedUpdateStates.add(step);
    _primeFwUpdate.sink.add(step);
  }

  void _updateDownloadState(String message, EnvoyStepState state) {
    _downloadState.sink.add(FwUpdateState(message: message, step: state));
  }

  //end ui stete updates

  void _handleOnboardingState(api.FirmwareInstallEvent event) {
    event.map(
      updateVerified: (event) {
        _updateFwUpdateState(PrimeFwUpdateStep.verifying);
      },
      installing: (event) {
        _updateFwUpdateState(PrimeFwUpdateStep.installing);
      },
      rebooting: (event) {
        _updateFwUpdateState(PrimeFwUpdateStep.rebooting);
      },
      success: (event) {
        _updateFwUpdateState(PrimeFwUpdateStep.finished);
      },
      error: (event) {
        // Cancel any ongoing transfer
        unawaited(qlConnection.cancelTransfer());
        EnvoyReport().log(
          "fw_update_handler",
          "Firmware install error: ${event.error}",
        );
        _updateFwUpdateState(PrimeFwUpdateStep.error);
      },
    );
  }

  void _processProgress(WriteProgress wProgress) {
    final progress = wProgress.progress;
    final totalBytes = wProgress.totalBytes;
    final bytesProcessed = wProgress.bytesProcessed;

    final remainingTime = _transferEstimator.updateProgress(
      bytesProcessed: bytesProcessed,
      totalBytes: totalBytes,
      progress: progress,
    );

    // If null, update was throttled
    if (remainingTime == null) {
      return;
    }

    _transferProgress.sink.add(
      FwTransferProgress(progress: progress, remainingTime: remainingTime),
    );
  }

  void reset() {
    _updateFwUpdateState(PrimeFwUpdateStep.idle);
    _updateFetchState(
      S().onboarding_connectionIntro_checkForUpdates,
      EnvoyStepState.IDLE,
    );
    _updateDownloadState(
      S().firmware_updatingDownload_downloading,
      EnvoyStepState.IDLE,
    );
    _transferProgress.sink.add(
      FwTransferProgress(progress: 0, remainingTime: ""),
    );
    newVersion = "";
  }
}
