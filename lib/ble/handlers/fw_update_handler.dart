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
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/onboard/prime/firmware_update/prime_fw_update_state.dart';
import 'package:envoy/ui/widgets/envoy_step_item.dart';
import 'package:envoy/util/bug_report_helper.dart';
import 'package:envoy/util/console.dart';
import 'package:envoy/util/stream_replay_cache.dart';
import 'package:envoy/util/transfer_rate_estimator.dart';
import 'package:flutter/cupertino.dart';
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

  static const int _averageTxSped = 30 * 1024;

  Set<PrimeFwUpdateStep> _completedUpdateStates = {};

  String newVersion = "";
  String currentVersion = "";
  int totalPatchBytes = 0;

  // Transfer rate estimator
  // reset this every time a new transfer starts
  final _transferEstimator = TransferRateEstimator();
  StreamSubscription<WriteProgress>? _writeProgressSubscription;
  ControlledQueue<api.QuantumLinkMessage>? _chunkQueue;

  // High-water mark to prevent progress regression during chunk retries
  double _highWaterProgress = 0.0;
  final _fetchState = StreamController<FwUpdateState>.broadcast();
  final _downloadState = StreamController<FwUpdateState>.broadcast();
  final _transferState = StreamController<FwUpdateState>.broadcast();
  final _primeFwUpdate = StreamController<PrimeFwUpdateStep>.broadcast();
  final _transferProgress = StreamController<FwTransferProgress>.broadcast();
  final _settingsUpdateStarted = StreamController<void>.broadcast();

  Stream<FwUpdateState> get fetchStateStream =>
      _fetchState.stream.asBroadcastStream();

  Stream<FwTransferProgress> get transferProgress =>
      _transferProgress.stream.asBroadcastStream();

  Stream<PrimeFwUpdateStep> get primeFwUpdate =>
      _primeFwUpdate.stream.asBroadcastStream();

  Stream<FwUpdateState> get downloadStateStream =>
      _downloadState.stream.asBroadcastStream().replayLatest(
            FwUpdateState(
              message: S().firmware_updatingDownload_downloading,
              step: EnvoyStepState.LOADING,
            ),
          );

  Stream<FwUpdateState> get transferStateStream =>
      _transferState.stream.asBroadcastStream();

  String _formatMegabytes(int bytes) {
    return (bytes / (1024 * 1024)).toStringAsFixed(2);
  }

  int _getTotalPatchBytes(List<PrimePatch> patches) {
    return patches.fold<int>(0, (total, patch) => total + patch.size);
  }

  String _formatEstimatedUpdateTime(int totalBytes) {
    if (totalBytes <= 0) {
      return "~5 min";
    }

    final minutes = totalBytes / _averageTxSped / 60;

    if (minutes < 1) {
      return "1 min";
    }

    final roundedMinutes = minutes < 10
        ? (minutes * 10).ceilToDouble() / 10
        : minutes.ceilToDouble();
    final precision =
        roundedMinutes.truncateToDouble() == roundedMinutes ? 0 : 1;

    //add prime installation overhead, ~1 min
    final totalTime = roundedMinutes + 1;
    return "~${totalTime.toStringAsFixed(precision)} min";
  }

  /// Emits when a firmware fetch request is received from an already-onboarded
  Stream<void> get settingsUpdateStarted =>
      _settingsUpdateStarted.stream.asBroadcastStream();

  Set<PrimeFwUpdateStep> get completedUpdateStates => _completedUpdateStates;

  String get estimatedUpdateTime => _formatEstimatedUpdateTime(totalPatchBytes);

  @override
  bool canHandle(api.QuantumLinkMessage message) {
    return message is api.QuantumLinkMessage_FirmwareUpdateCheckRequest ||
        message is api.QuantumLinkMessage_FirmwareFetchRequest ||
        message is api.QuantumLinkMessage_FirmwareInstallEvent ||
        message is api.QuantumLinkMessage_OnboardingState;
  }

  @override
  Future<void> handleMessage(api.QuantumLinkMessage message) async {
    switch (message) {
      case api.QuantumLinkMessage_FirmwareUpdateCheckRequest updateRequest:
        currentVersion = updateRequest.field0.currentVersion;
        _handleFwUpdateCheckRequest(currentVersion);
      case api.QuantumLinkMessage_FirmwareFetchRequest fetchRequest:
        final api.FirmwareFetchRequest firmwareFetchRequest =
            fetchRequest.field0;
        if (firmwareFetchRequest.chunkOffset case final offset?) {
          kPrint("Restarting chunkQueue from offset $offset");
          _chunkQueue?.restartFrom(offset.toInt());
          return;
        }
        _handleFirmwareFetchRequest(firmwareFetchRequest.currentVersion);
      case api.QuantumLinkMessage_FirmwareInstallEvent installEvent:
        _handleOnboardingState(installEvent.field0);
      default:
        break;
    }
  }

  //Downloads and sends firmware update to the device
  Future<void> _handleFirmwareFetchRequest(String currentVersion) async {
    List<PrimePatch> patches = [];

    if (qlConnection.getDevice()?.onboardingComplete == true) {
      _settingsUpdateStarted.add(null);
    }

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
    } catch (e, stack) {
      kPrint("failed to fetch patches: $e");
      debugPrintStack(stackTrace: stack);
      _updateDownloadState(
        S().firmware_updateError_downloadFailed,
        EnvoyStepState.ERROR,
      );
      await _handleFirmwareError(S().firmware_updateError_downloadFailed);
      return;
    }

    if (patches.isEmpty) {
      EnvoyReport()
          .log("fw_update_handler", "No updates available — notifying device");
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
        EnvoyReport().log("fw_update_handler",
            "All patches downloaded: ${patchBinaries.length} patch(es), total size=${_formatMegabytes(patchBinaries.fold(0, (s, b) => s + b.length))} MB}");
        _updateDownloadState(
          S().firmware_downloadingUpdate_downloaded,
          EnvoyStepState.FINISHED,
        );
      } catch (e, stack) {
        _updateFwUpdateState(PrimeFwUpdateStep.error);
        await _handleFirmwareError(S().firmware_updateError_downloadFailed);
        EnvoyReport().log(
            "fw_update_handler", "Failed to check for updates: $e",
            stackTrace: stack);
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
    // reset this every time a new transfer starts
    _transferEstimator.reset();
    _highWaterProgress = 0.0;

    _writeProgressSubscription?.cancel();

    if (qlConnection.senderXid == null || qlConnection.recipientXid == null) {
      EnvoyReport().log(
        "fw_update_handler",
        "Cannot send firmware payload: missing identities,qlIdentity: ${qlConnection.senderXid},recipientXid ${qlConnection.senderXid}",
      );
      return;
    }

    final totalPayloadBytes =
        patches.fold<int>(0, (sum, patch) => sum + patch.length);
    EnvoyReport().log(
      "fw_update_handler",
      "Firmware payload size: patches=${patches.length}, total size=${_formatMegabytes(totalPayloadBytes)} MB}",
    );

    EnvoyReport().log("fw_update_handler",
        "Encoding ${patches.length} patch(es) into BLE chunks (chunkSize=$bleChunkSize)");
    final chunks = await api.encodeToChunks(
      payload: patches,
      sender: qlConnection.senderXid!,
      recipient: qlConnection.recipientXid!,
      chunkSize: bleChunkSize,
    );

    _chunkQueue = ControlledQueue(chunks.toList());

    try {
      //only for android
      await qlConnection.requestHighConnectionPriority();
      EnvoyReport()
          .log("fw_update_handler", "BLE high connection priority requested");
    } catch (e) {
      EnvoyReport().log("fw_update_handler",
          "Failed to set high connection priority, proceeding with normal priority: $e");
      kPrint(
          "Failed to set high connection priority, proceeding with normal priority");
    }

    unawaited(_chunkQueue?.start((index, api.QuantumLinkMessage message) async {
      try {
        kPrint("Sending chunk ${index + 1}/${chunks.length}");
        final result = await qlConnection.writeMessage(message);
        kPrint("Sent chunk ${index + 1}/${chunks.length} result: $result");
        _processProgress(WriteProgress(
          id: 'fw_update',
          progress: (index + 1) / chunks.length,
          totalBytes: chunks.length,
          bytesProcessed: index + 1,
        ));
      } catch (e, stack) {
        kPrint(
            "Failed to send firmware chunk ${index + 1}/${chunks.length}: $e");
        EnvoyReport().log(
          "fw_update_handler",
          "Chunk transmission error at index $index: $e",
          stackTrace: stack,
        );
      }
    }).whenComplete(() async {
      //only for android
      await qlConnection.requestBalancedConnectionPriority();
    }));

    kPrint("All FW chunks queued for sending. Total chunks: ${chunks.length}");
  }

  //Checks for firmware updates
  Future<void> _handleFwUpdateCheckRequest(String currentVersion) async {
    _updateFetchState(
      S().onboarding_connectionChecking_forUpdates,
      EnvoyStepState.LOADING,
    );
    try {
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

        if (qlConnection.getDevice()?.onboardingComplete == true) {
          _settingsUpdateStarted.add(null);
        }
      }
      _updateFetchState(stepUpdate, EnvoyStepState.FINISHED);
    } catch (e, stack) {
      EnvoyReport().log("fw_update_handler", "Failed to check for updates: $e",
          stackTrace: stack);
      _updateFwUpdateState(PrimeFwUpdateStep.error);
      await _handleFirmwareError(S().firmware_updateError_downloadFailed);
    }
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
    totalPatchBytes = _getTotalPatchBytes(patches);
    EnvoyReport().log(
      "fw_update_handler",
      "Firmware payload size: patches=${patches.length}, total size=${_formatMegabytes(totalPatchBytes)} MB}",
    );
    final changelog = patches.reversed.fold(
      "",
      (acc, p) => "$acc\n${p.changelog}",
    );
    newVersion = latest.version;
    return api.FirmwareUpdateAvailable(
      version: latest.version,
      changelog: changelog,
      timestamp: latest.releaseDate.millisecondsSinceEpoch,
      totalSize: totalPatchBytes,
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

  //send ui state updates
  void _handleOnboardingState(api.FirmwareInstallEvent event) {
    event.map(
      updateVerified: (event) {
        EnvoyReport().log("fw_update_handler",
            "Install event: updateVerified — firmware signature/integrity check passed");
        _updateFwUpdateState(PrimeFwUpdateStep.verifying);
      },
      installing: (event) {
        EnvoyReport().log("fw_update_handler",
            "Install event: installing — device is applying the firmware");
        _updateFwUpdateState(PrimeFwUpdateStep.installing);
      },
      rebooting: (event) {
        EnvoyReport().log("fw_update_handler",
            "Install event: rebooting — device is rebooting into new firmware");
        _updateFwUpdateState(PrimeFwUpdateStep.rebooting);
      },
      success: (event) {
        EnvoyReport().log("fw_update_handler",
            "Install event: success — firmware update completed successfully, newVersion=$newVersion");
        _updateFwUpdateState(PrimeFwUpdateStep.finished);
      },
      error: (event) {
        // Cancel any ongoing transfer
        qlConnection.qlHandler.fwUpdateHandler.stopFirmwareTransfer();
        EnvoyReport().log(
          "fw_update_handler",
          "Firmware install error: ${event.error}",
        );
        _updateFwUpdateState(PrimeFwUpdateStep.error);
      },
    );
  }

  void _processProgress(WriteProgress wProgress) {
    final totalBytes = wProgress.totalBytes;
    final bytesProcessed = wProgress.bytesProcessed;

    // Clamp to high-water mark so progress never regresses during a chunk retry
    final progress =
        _highWaterProgress = wProgress.progress.clamp(_highWaterProgress, 1.0);

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
    if (!_transferProgress.isClosed) {
      _transferProgress.sink.add(
        FwTransferProgress(progress: 0, remainingTime: ""),
      );
    }
    newVersion = "";
    totalPatchBytes = 0;
  }

  @override
  void dispose() {
    _chunkQueue?.dispose();
    _writeProgressSubscription?.cancel();
    _fetchState.close();
    _downloadState.close();
    _transferState.close();
    _primeFwUpdate.close();
    _transferProgress.close();
    _settingsUpdateStarted.close();
    super.dispose();
  }

  void stopFirmwareTransfer() {
    _chunkQueue?.stop();
  }
}

typedef SendOne<T> = Future<void> Function(int index, T item);

class ControlledQueue<T> {
  ControlledQueue(List<T> items) : _items = List<T>.from(items);

  final List<T> _items;

  int _cursor = 0;
  int? _restartFrom;
  bool _running = false;
  bool _stopRequested = false;

  bool get isRunning => _running;

  int get currentIndex => _cursor;

  bool get isCompleted => _cursor >= _items.length;

  Future<void> start(SendOne<T> sendOne) async {
    if (_running) return;

    _running = true;
    _stopRequested = false;

    EnvoyReport()
        .log("ControlledQueue", "Queue started: total=${_items.length} items");

    try {
      while (!_stopRequested && _cursor < _items.length) {
        if (_restartFrom != null) {
          _cursor = _restartFrom!;
          _restartFrom = null;
        }

        EnvoyReport().log(
            "ControlledQueue", "Sending index $_cursor/${_items.length - 1}");
        await sendOne(_cursor, _items[_cursor]);

        // If restart was requested during await, next loop will jump.
        if (_restartFrom == null) {
          _cursor++;
        }
      }
    } finally {
      _running = false;
    }
  }

  void stop() {
    _stopRequested = true;
  }

  void restartFrom(int index) {
    if (index < 0 || index >= _items.length) {
      throw RangeError.index(index, _items, 'index');
    }

    _restartFrom = index;
    _stopRequested = false;

    // If not running now, next start() begins from this index.
    if (!_running) {
      _cursor = index;
    }
  }

  void reset() {
    _cursor = 0;
    _restartFrom = null;
    _stopRequested = false;
  }

  void dispose() {
    stop();
  }
}
