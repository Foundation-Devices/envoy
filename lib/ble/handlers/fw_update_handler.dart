// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later
// ignore_for_file: constant_identifier_names///

import 'dart:async';
import 'dart:typed_data';

import 'package:envoy/ble/bluetooth_manager.dart';
import 'package:envoy/ble/handlers/firmware_update_check_queue.dart';
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
import 'package:foundation_api/foundation_api.dart' as api;
import 'package:http_tor/http_tor.dart';

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

List<api.QuantumLinkMessage> buildFirmwareChunks(
  List<Uint8List> patches, {
  required int chunkSize,
}) {
  if (chunkSize <= 0) {
    throw ArgumentError.value(chunkSize, 'chunkSize', 'Must be positive');
  }
  if (patches.length > 255) {
    throw ArgumentError.value(
      patches.length,
      'patches',
      'Cannot exceed 255 patches',
    );
  }

  final messages = <api.QuantumLinkMessage>[];
  for (final (patchIndex, patch) in patches.indexed) {
    final totalChunks = (patch.length + chunkSize - 1) ~/ chunkSize;
    for (var chunkIndex = 0; chunkIndex < totalChunks; chunkIndex++) {
      final start = chunkIndex * chunkSize;
      final end =
          start + chunkSize < patch.length ? start + chunkSize : patch.length;
      messages.add(
        api.QuantumLinkMessage.firmwareFetchEvent(
          api.FirmwareFetchEvent.chunk(
            api.FirmwareChunk(
              patchIndex: patchIndex,
              totalPatches: patches.length,
              chunkIndex: chunkIndex,
              totalChunks: totalChunks,
              data: Uint8List.sublistView(patch, start, end),
            ),
          ),
        ),
      );
    }
  }
  return messages;
}

class FwUpdateHandler extends PassportMessageHandler {
  FwUpdateHandler(super.connection);

  // Average transfer speed in bytes per second, used for estimating remaining time. T
  // his is a rough estimate and can vary based on device and connection quality.
  static const int _averageTxSped = 30 * 1024;

  Set<PrimeFwUpdateStep> _completedUpdateStates = {};

  PrimeFwUpdateStep _latestStep = PrimeFwUpdateStep.idle;

  String newVersion = "";
  String currentVersion = "";
  int totalPatchBytes = 0;
  List<PrimePatch> _availablePatches = const [];

  // Transfer rate estimator
  // reset this every time a new transfer starts
  final _transferEstimator = TransferRateEstimator();
  ControlledQueue<api.QuantumLinkMessage>? _chunkQueue;
  Future<void>? _firmwareFetchTask;
  Future<bool>? _firmwarePreparationAcknowledgement;
  DownloadCancellationToken? _firmwareDownloadCancellationToken;
  bool _firmwarePreparationInProgress = false;
  int _firmwareFetchRequestId = 0;
  // A user-blocking check uses HttpTor's foreground lane and bootstrap budget.
  static final _firmwareUpdateFetchTimeout =
      HttpTor.foregroundTorRequestTimeout;
  static final _firmwareUpdateCheckTimeout =
      _firmwareUpdateFetchTimeout + const Duration(minutes: 2);
  final _firmwareUpdateChecks = FirmwareUpdateCheckQueue();
  FwUpdateState? _activeFirmwareUpdateCheckLoadingState;
  bool _firmwareUpdateCheckRunning = false;
  bool _disposed = false;
  int _firmwareUpdateGeneration = 0;
  bool _firmwareFetchActive = false;
  bool _firmwareTransferPaused = false;

  // High-water mark to prevent progress regression during chunk retries
  double _highWaterProgress = 0.0;
  final _fetchState = StreamController<FwUpdateState>.broadcast();
  FwUpdateState? _latestFetchState;
  final _downloadState = StreamController<FwUpdateState>.broadcast();
  final _transferState = StreamController<FwUpdateState>.broadcast();
  final _primeFwUpdate = StreamController<PrimeFwUpdateStep>.broadcast();
  final _downloadProgress = StreamController<double>.broadcast();
  final _transferProgress = StreamController<FwTransferProgress>.broadcast();
  final _settingsUpdateStarted = StreamController<void>.broadcast();

  Stream<FwUpdateState> get fetchStateStream =>
      _fetchState.stream.asBroadcastStream();

  Stream<FwTransferProgress> get transferProgress =>
      _transferProgress.stream.asBroadcastStream();

  Stream<double> get downloadProgress =>
      _downloadProgress.stream.asBroadcastStream();

  Stream<PrimeFwUpdateStep> get primeFwUpdate =>
      _primeFwUpdate.stream.asBroadcastStream().replayLatest(_latestStep);

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

    //add prime installation overhead, ~1 min
    final totalTime = (roundedMinutes + 1).toInt();
    return "~$totalTime min";
  }

  /// Emits when a firmware fetch request is received from an already-onboarded
  Stream<void> get settingsUpdateStarted =>
      _settingsUpdateStarted.stream.asBroadcastStream();

  Set<PrimeFwUpdateStep> get completedUpdateStates => _completedUpdateStates;

  String get estimatedUpdateTime => _formatEstimatedUpdateTime(totalPatchBytes);

  List<PrimePatch> get availablePatches => _availablePatches;

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
        _queueFirmwareUpdateCheck(updateRequest.field0.currentVersion);
      case api.QuantumLinkMessage_FirmwareFetchRequest fetchRequest:
        final api.FirmwareFetchRequest firmwareFetchRequest =
            fetchRequest.field0;
        if (firmwareFetchRequest.chunkOffset case final offset?) {
          kPrint("Restarting chunkQueue from offset $offset");
          final queue = _chunkQueue;
          final resumed = queue?.restartFrom(offset.toInt());
          if (queue != null) {
            _setFirmwareTransferLifecycle(active: true, paused: false);
            _updateFwUpdateState(PrimeFwUpdateStep.transferring);
            qlConnection.setFirmwareTransferInProgress(true);
          }
          if (resumed != null) {
            // Queue had already finished — re-request high BLE priority
            // and track the new send loop.
            kPrint(
              "Queue was completed, re-launching send loop from offset $offset",
            );
            final requestId = _firmwareFetchRequestId;
            await qlConnection.requestHighConnectionPriority();
            unawaited(
              resumed.whenComplete(() async {
                _finishFirmwareFetchRequest(requestId);
                await qlConnection.requestBalancedConnectionPriority();
              }),
            );
          }
          return;
        }
        _startFirmwareFetch(firmwareFetchRequest.currentVersion);
      case api.QuantumLinkMessage_FirmwareInstallEvent installEvent:
        _handleOnboardingState(installEvent.field0);
      default:
        break;
    }
  }

  void _queueFirmwareUpdateCheck(String requestedVersion) {
    if (_disposed) return;
    currentVersion = requestedVersion;
    _firmwareUpdateChecks.add(requestedVersion);
    if (!_firmwareUpdateCheckRunning) {
      unawaited(_drainFirmwareUpdateChecks());
    }
  }

  Future<void> _drainFirmwareUpdateChecks() async {
    if (_firmwareUpdateCheckRunning || _disposed) return;
    _firmwareUpdateCheckRunning = true;
    try {
      while (!_disposed) {
        final request = _firmwareUpdateChecks.takeNext();
        if (request == null) break;
        var delivery = FirmwareUpdateCheckDelivery.abandoned;
        try {
          delivery = await _handleFwUpdateCheckRequest(
            request.id,
            request.currentVersion,
          ).timeout(_firmwareUpdateCheckTimeout);
        } on TimeoutException catch (error, stackTrace) {
          if (_disposed) return;
          EnvoyReport().log(
            "fw_update_handler",
            "Firmware update check timed out: $error",
            stackTrace: stackTrace,
          );
          if (_isCurrentFirmwareUpdateCheck(request.id) &&
              !_firmwareUpdateInProgress &&
              identical(
                _latestFetchState,
                _activeFirmwareUpdateCheckLoadingState,
              )) {
            _updateFetchState(
              S().firmware_updateError_downloadFailed,
              EnvoyStepState.ERROR,
            );
          }
        } catch (error, stackTrace) {
          if (_disposed) return;
          EnvoyReport().log(
            "fw_update_handler",
            "Unhandled queued firmware check error: $error",
            stackTrace: stackTrace,
          );
        } finally {
          _activeFirmwareUpdateCheckLoadingState = null;
          _firmwareUpdateChecks.complete(request, delivery);
        }
      }
    } finally {
      _firmwareUpdateCheckRunning = false;
    }
  }

  bool _isCurrentFirmwareUpdateCheck(int requestId) =>
      !_disposed && _firmwareUpdateChecks.isCurrent(requestId);

  void _startFirmwareFetch(String currentVersion) {
    if (_firmwareFetchTask != null) {
      EnvoyReport().log(
        "fw_update_handler",
        "Firmware fetch already in progress; coalescing duplicate request",
      );
      if (_firmwarePreparationInProgress) {
        unawaited(
          _acknowledgeFirmwarePreparation(_firmwareFetchRequestId),
        );
      }
      return;
    }

    this.currentVersion = currentVersion;
    final requestId = _startFirmwareFetchRequest();
    final task = _handleFirmwareFetchRequest(currentVersion, requestId);
    _firmwareFetchTask = task;
    unawaited(
      task.whenComplete(() {
        if (identical(_firmwareFetchTask, task)) {
          _firmwareFetchTask = null;
        }
      }),
    );
  }

  //Downloads and sends firmware update to the device
  Future<void> _handleFirmwareFetchRequest(
    String currentVersion,
    int requestId,
  ) async {
    List<PrimePatch> patches = [];

    if (qlConnection.getDevice()?.onboardingComplete == true) {
      _settingsUpdateStarted.add(null);
    }

    try {
      _completedUpdateStates = {};
      _transferProgress.add(
        FwTransferProgress(progress: 0.0, remainingTime: ""),
      );
      _downloadProgress.add(0.0);
      _updateFwUpdateState(PrimeFwUpdateStep.downloading);
      _updateDownloadState(
        S().firmware_downloadingUpdate_header,
        EnvoyStepState.LOADING,
      );
      await _acknowledgeFirmwarePreparation(requestId);
      if (!_isCurrentFirmwareFetchRequest(requestId)) return;
      patches = await Server().fetchPrimePatches(currentVersion);
      if (!_isCurrentFirmwareFetchRequest(requestId)) return;
    } catch (e, stack) {
      if (!_isCurrentFirmwareFetchRequest(requestId)) return;
      _updateFwUpdateState(PrimeFwUpdateStep.error);
      _updateDownloadState(
        S().firmware_updateError_downloadFailed,
        EnvoyStepState.ERROR,
      );
      await _handleFirmwareRequestError(
        S().firmware_updateError_downloadFailed,
        requestId: requestId,
      );
      EnvoyReport().log(
        "fw_update_handler",
        "Failed to fetch firmware patches: $e",
        stackTrace: stack,
      );
      return;
    }

    if (patches.isEmpty) {
      _firmwarePreparationInProgress = false;
      final delivered = await sendFirmwareFetchEvent(
        api.FirmwareFetchEvent.updateNotAvailable(),
        requestId: requestId,
      );
      if (!_isCurrentFirmwareFetchRequest(requestId)) return;
      if (!delivered) {
        _updateFwUpdateState(PrimeFwUpdateStep.error);
        _cancelFirmwareFetchRequest();
        return;
      }
      _availablePatches = const [];
      newVersion = "";
      totalPatchBytes = 0;
      _finishFirmwareFetchRequest(requestId);
      _updateFwUpdateState(PrimeFwUpdateStep.notAvailable);
    } else {
      List<Uint8List> patchBinaries = [];
      final totalDownloadBytes = _getTotalPatchBytes(patches);
      var completedDownloadBytes = 0;
      var highWaterDownloadBytes = 0;

      try {
        for (final patch in patches) {
          if (!_isCurrentFirmwareFetchRequest(requestId)) return;
          final cancellationToken = _firmwareDownloadCancellationToken;
          if (cancellationToken == null) return;
          final binary = await Server().fetchPrimePatchBinary(
            patch,
            cancellationToken: cancellationToken,
            onProgress: (progress) {
              if (!_isCurrentFirmwareFetchRequest(requestId)) return;
              final downloadedBytes =
                  completedDownloadBytes + progress.downloaded.toInt();
              if (downloadedBytes <= highWaterDownloadBytes) return;
              highWaterDownloadBytes = downloadedBytes;
              _downloadProgress.add(
                (downloadedBytes / totalDownloadBytes).clamp(0.0, 1.0),
              );
            },
          );
          if (!_isCurrentFirmwareFetchRequest(requestId)) return;
          patchBinaries.add(binary);
          completedDownloadBytes += patch.size;
        }
        _downloadProgress.add(1.0);
        _firmwareDownloadCancellationToken = null;
        EnvoyReport().log(
          "fw_update_handler",
          "All patches downloaded: ${patchBinaries.length} patch(es), total size=${_formatMegabytes(patchBinaries.fold(0, (s, b) => s + b.length))} MB}",
        );
        if (!_isCurrentFirmwareFetchRequest(requestId)) return;
        _updateDownloadState(
          S().firmware_downloadingUpdate_downloaded,
          EnvoyStepState.FINISHED,
        );
      } catch (e, stack) {
        if (!_isCurrentFirmwareFetchRequest(requestId)) return;
        _updateFwUpdateState(PrimeFwUpdateStep.error);
        await _handleFirmwareRequestError(
          S().firmware_updateError_downloadFailed,
          requestId: requestId,
        );
        EnvoyReport().log(
          "fw_update_handler",
          "Failed to check for updates: $e",
          stackTrace: stack,
        );
        return;
      }

      try {
        if (!_isCurrentFirmwareFetchRequest(requestId)) return;
        _updateFwUpdateState(PrimeFwUpdateStep.transferring);
        final chunks = await _prepareFirmwarePayload(
          patchBinaries,
          requestId: requestId,
        );
        if (chunks == null || !_isCurrentFirmwareFetchRequest(requestId)) {
          return;
        }

        // Prime starts its no-data watchdog when it receives `starting`, so
        // only send the event once the first BLE chunk can follow immediately.
        _firmwarePreparationInProgress = false;
        final startingSent = await sendFirmwareFetchEvent(
          api.FirmwareFetchEvent.starting(updateAvailableMessage(patches)),
          requestId: requestId,
        );
        if (!_isCurrentFirmwareFetchRequest(requestId)) return;
        if (!startingSent) {
          throw StateError('Failed to notify Prime that transfer is starting');
        }

        await _sendFirmwarePayload(
          queue: ControlledQueue(chunks),
          requestId: requestId,
        );
      } catch (e) {
        if (!_isCurrentFirmwareFetchRequest(requestId)) return;
        _chunkQueue = null;
        _updateFwUpdateState(PrimeFwUpdateStep.error);
        kPrint("failed to transfer firmware: $e");
        await _handleFirmwareRequestError(
          S().firmware_updateError_receivingFailed,
          requestId: requestId,
        );
        return;
      }
    }
  }

  int _startFirmwareFetchRequest() {
    _cancelFirmwareFetchRequest();
    _setFirmwareTransferLifecycle(active: true, paused: false);
    _firmwareDownloadCancellationToken = DownloadCancellationToken();
    _firmwarePreparationInProgress = true;
    qlConnection.setFirmwareTransferInProgress(true);
    EnvoyReport().log(
      "fw_update_handler",
      "Starting firmware fetch request $_firmwareFetchRequestId",
    );
    return _firmwareFetchRequestId;
  }

  bool _isCurrentFirmwareFetchRequest(int requestId) {
    return requestId == _firmwareFetchRequestId;
  }

  void _cancelFirmwareFetchRequest({bool updateConnectionState = true}) {
    _firmwareFetchRequestId++;
    _setFirmwareTransferLifecycle(active: false, paused: true);
    _firmwareDownloadCancellationToken?.cancel();
    _firmwareDownloadCancellationToken = null;
    _firmwareFetchTask = null;
    _firmwarePreparationAcknowledgement = null;
    _firmwarePreparationInProgress = false;
    _chunkQueue?.stop();
    _chunkQueue = null;
    if (updateConnectionState) {
      qlConnection.setFirmwareTransferInProgress(false);
      unawaited(qlConnection.requestBalancedConnectionPriority());
    }
  }

  void _finishFirmwareFetchRequest(int requestId) {
    if (!_isCurrentFirmwareFetchRequest(requestId)) return;
    _setFirmwareTransferLifecycle(
        active: false, paused: _firmwareTransferPaused);
    _firmwarePreparationInProgress = false;
    qlConnection.setFirmwareTransferInProgress(false);
  }

  Future<List<api.QuantumLinkMessage>?> _prepareFirmwarePayload(
    List<Uint8List> patches, {
    required int requestId,
  }) async {
    if (!_isCurrentFirmwareFetchRequest(requestId)) return null;

    // reset this every time a new transfer starts
    _transferEstimator.reset();
    _highWaterProgress = 0.0;

    if (qlConnection.senderXid == null || qlConnection.recipientXid == null) {
      EnvoyReport().log(
        "fw_update_handler",
        "Cannot send firmware payload: missing Quantum Link identity",
      );
      throw StateError('Cannot send firmware payload without QL identity');
    }

    final totalPayloadBytes = patches.fold<int>(
      0,
      (sum, patch) => sum + patch.length,
    );
    EnvoyReport().log(
      "fw_update_handler",
      "Firmware payload size: patches=${patches.length}, total size=${_formatMegabytes(totalPayloadBytes)} MB}",
    );

    EnvoyReport().log(
      "fw_update_handler",
      "Encoding ${patches.length} patch(es) into BLE chunks (chunkSize=$bleChunkSize)",
    );
    await Future<void>.delayed(Duration.zero);
    final chunks = buildFirmwareChunks(
      patches,
      chunkSize: bleChunkSize.toInt(),
    );
    if (!_isCurrentFirmwareFetchRequest(requestId)) return null;

    return chunks;
  }

  Future<void> _sendFirmwarePayload({
    required ControlledQueue<api.QuantumLinkMessage> queue,
    required int requestId,
  }) async {
    final totalChunks = queue.length;

    try {
      await qlConnection.requestHighConnectionPriority();
      if (!_isCurrentFirmwareFetchRequest(requestId)) return;

      // Publish a resumable queue only once its sender is about to start. A
      // disconnect before this point cancels preparation instead of exposing
      // a queue that cannot yet service a chunk-offset request. Keep the fetch
      // task active until this queue finishes so retries cannot start a second
      // transfer alongside it.
      _chunkQueue = queue;
      kPrint("All FW chunks queued for sending. Total chunks: $totalChunks");

      await queue.start((index, api.QuantumLinkMessage message) async {
        if (!_isCurrentFirmwareFetchRequest(requestId)) return;
        try {
          kPrint("Sending chunk ${index + 1}/$totalChunks");
          final result = await qlConnection.writeMessage(message);
          if (!_isCurrentFirmwareFetchRequest(requestId)) return;
          kPrint("Sent chunk ${index + 1}/$totalChunks result: $result");
          _processProgress(
            WriteProgress(
              id: 'fw_update',
              progress: (index + 1) / totalChunks,
              totalBytes: totalChunks,
              bytesProcessed: index + 1,
            ),
          );
        } catch (e, stack) {
          kPrint("Failed to send firmware chunk ${index + 1}/$totalChunks: $e");
          EnvoyReport().log(
            "fw_update_handler",
            "Chunk transmission error at index $index: $e",
            stackTrace: stack,
          );
        }
      });
    } finally {
      if (_isCurrentFirmwareFetchRequest(requestId)) {
        _finishFirmwareFetchRequest(requestId);
      }
      await qlConnection.requestBalancedConnectionPriority();
    }
  }

  //Checks for firmware updates
  Future<FirmwareUpdateCheckDelivery> _handleFwUpdateCheckRequest(
    int requestId,
    String currentVersion,
  ) async {
    if (!_isCurrentFirmwareUpdateCheck(requestId)) {
      return FirmwareUpdateCheckDelivery.abandoned;
    }
    final updateGeneration = _firmwareUpdateGeneration;
    final checkLoadingState = _updateFetchState(
      S().onboarding_connectionChecking_forUpdates,
      EnvoyStepState.LOADING,
    );
    _activeFirmwareUpdateCheckLoadingState = checkLoadingState;
    try {
      final patches = await Server()
          .fetchPrimePatches(currentVersion, foreground: true)
          .timeout(_firmwareUpdateFetchTimeout);
      if (!_isCurrentFirmwareUpdateCheck(requestId)) {
        return FirmwareUpdateCheckDelivery.abandoned;
      }

      final stepUpdate = patches.isNotEmpty
          ? S().onboarding_connectionUpdatesAvailable_updatesAvailable
          : S().onboarding_connectionNoUpdates_noUpdates;

      late final FirmwareUpdateCheckDelivery delivery;
      if (patches.isEmpty) {
        delivery = await _sendFirmwareUpdateCheckResponse(
          api.QuantumLinkMessage.firmwareUpdateCheckResponse(
            api.FirmwareUpdateCheckResponse_NotAvailable(),
          ),
          requestId: requestId,
        );
        if (_isCurrentFirmwareUpdateCheck(requestId) &&
            delivery == FirmwareUpdateCheckDelivery.sent &&
            updateGeneration == _firmwareUpdateGeneration &&
            !_firmwareUpdateInProgress &&
            _latestStep != PrimeFwUpdateStep.finished) {
          // A post-install check must not replace the success confirmation
          // or clear the version it displays. A stale error may be replaced.
          _availablePatches = const [];
          newVersion = "";
          totalPatchBytes = 0;
          _replaceFwUpdateState(PrimeFwUpdateStep.notAvailable);
        }
      } else {
        final response = api.QuantumLinkMessage.firmwareUpdateCheckResponse(
          api.FirmwareUpdateCheckResponse.available(
            _buildUpdateAvailableMessage(patches),
          ),
        );
        delivery = await _sendFirmwareUpdateCheckResponse(
          response,
          requestId: requestId,
        );

        if (_isCurrentFirmwareUpdateCheck(requestId) &&
            delivery == FirmwareUpdateCheckDelivery.sent &&
            updateGeneration == _firmwareUpdateGeneration &&
            !_firmwareUpdateInProgress) {
          _storeAvailablePatchMetadata(patches);
          final isSettingsUpdate =
              qlConnection.getDevice()?.onboardingComplete == true;
          if (isSettingsUpdate ||
              _latestStep == PrimeFwUpdateStep.notAvailable ||
              _latestStep == PrimeFwUpdateStep.error) {
            _replaceFwUpdateState(PrimeFwUpdateStep.idle);
          }
          if (isSettingsUpdate) {
            _settingsUpdateStarted.add(null);
          }
        }
      }
      if (!_isCurrentFirmwareUpdateCheck(requestId) ||
          !identical(_latestFetchState, checkLoadingState)) {
        return delivery;
      }
      switch (delivery) {
        case FirmwareUpdateCheckDelivery.sent:
          _updateFetchState(stepUpdate, EnvoyStepState.FINISHED);
        case FirmwareUpdateCheckDelivery.failed:
          _updateFetchState(
            S().firmware_updateError_receivingFailed,
            EnvoyStepState.ERROR,
          );
        case FirmwareUpdateCheckDelivery.abandoned:
          break;
      }
      return delivery;
    } catch (e, stack) {
      if (_disposed) return FirmwareUpdateCheckDelivery.abandoned;
      EnvoyReport().log(
        "fw_update_handler",
        "Failed to check for updates: $e",
        stackTrace: stack,
      );
      if (!_isCurrentFirmwareUpdateCheck(requestId)) {
        return FirmwareUpdateCheckDelivery.abandoned;
      }
      if (_firmwareUpdateInProgress ||
          !identical(_latestFetchState, checkLoadingState)) {
        return FirmwareUpdateCheckDelivery.failed;
      }
      _updateFetchState(
        S().firmware_updateError_downloadFailed,
        EnvoyStepState.ERROR,
      );
      return FirmwareUpdateCheckDelivery.failed;
    }
  }

  Future<FirmwareUpdateCheckDelivery> _sendFirmwareUpdateCheckResponse(
    api.QuantumLinkMessage response, {
    required int requestId,
  }) async {
    const attempts = 2;
    bool canDeliver() => _isCurrentFirmwareUpdateCheck(requestId);

    for (var attempt = 1; attempt <= attempts; attempt++) {
      if (!canDeliver()) {
        return FirmwareUpdateCheckDelivery.abandoned;
      }
      try {
        if (await qlConnection.writeMessage(response)) {
          return FirmwareUpdateCheckDelivery.sent;
        }
        EnvoyReport().log(
          "fw_update_handler",
          "Failed to send firmware update check response (attempt $attempt/$attempts)",
        );
      } catch (e, stack) {
        EnvoyReport().log(
          "fw_update_handler",
          "Failed to send firmware update check response (attempt $attempt/$attempts): $e",
          stackTrace: stack,
        );
        return canDeliver()
            ? FirmwareUpdateCheckDelivery.failed
            : FirmwareUpdateCheckDelivery.abandoned;
      }
      if (attempt < attempts) {
        if (!canDeliver()) {
          return FirmwareUpdateCheckDelivery.abandoned;
        }
        await Future<void>.delayed(const Duration(seconds: 1));
      }
    }
    return canDeliver()
        ? FirmwareUpdateCheckDelivery.failed
        : FirmwareUpdateCheckDelivery.abandoned;
  }

  Future<void> _handleFirmwareError(
    String errorBody, {
    required int requestId,
  }) async {
    if (!_isCurrentFirmwareFetchRequest(requestId)) return;
    _updateFetchState(errorBody, EnvoyStepState.ERROR);

    await sendFirmwareFetchEvent(
      api.FirmwareFetchEvent.error(error: errorBody),
      requestId: requestId,
    );
  }

  Future<void> _handleFirmwareRequestError(
    String errorBody, {
    required int requestId,
  }) async {
    if (!_isCurrentFirmwareFetchRequest(requestId)) return;
    _firmwarePreparationInProgress = false;
    try {
      await _handleFirmwareError(errorBody, requestId: requestId);
    } catch (error, stackTrace) {
      EnvoyReport().log(
        "fw_update_handler",
        "Failed to report firmware request error: $error",
        stackTrace: stackTrace,
      );
    } finally {
      _finishFirmwareFetchRequest(requestId);
    }
  }

  Future<bool> sendFirmwareFetchEvent(
    api.FirmwareFetchEvent event, {
    required int requestId,
  }) async {
    if (!_isCurrentFirmwareFetchRequest(requestId)) return false;
    const attempts = 2;
    final message = api.QuantumLinkMessage.firmwareFetchEvent(event);
    for (var attempt = 1; attempt <= attempts; attempt++) {
      if (!_isCurrentFirmwareFetchRequest(requestId)) return false;
      try {
        if (await qlConnection.writeMessage(message)) return true;
        EnvoyReport().log(
          "fw_update_handler",
          "Failed to send firmware fetch event (attempt $attempt/$attempts)",
        );
      } catch (e, stack) {
        EnvoyReport().log(
          "fw_update_handler",
          "Failed to send firmware fetch event (attempt $attempt/$attempts): $e",
          stackTrace: stack,
        );
        return false;
      }
      if (attempt < attempts) {
        await Future<void>.delayed(const Duration(seconds: 1));
      }
    }
    return false;
  }

  Future<void> _acknowledgeFirmwarePreparation(int requestId) async {
    if (!_isCurrentFirmwareFetchRequest(requestId)) return;

    final isNewAcknowledgement = _firmwarePreparationAcknowledgement == null;
    final acknowledgement = _firmwarePreparationAcknowledgement ??=
        _startFirmwarePreparationAcknowledgement();

    try {
      final sent = await acknowledgement;
      if (!_isCurrentFirmwareFetchRequest(requestId)) return;
      if (!sent && isNewAcknowledgement) {
        EnvoyReport().log(
          "fw_update_handler",
          "Failed to acknowledge firmware preparation",
        );
      }
    } catch (error, stackTrace) {
      if (!isNewAcknowledgement) return;
      EnvoyReport().log(
        "fw_update_handler",
        "Failed to acknowledge firmware preparation: $error",
        stackTrace: stackTrace,
      );
    }
  }

  Future<bool> _startFirmwarePreparationAcknowledgement() {
    // QLConnection owns write deadlines and native BLE recovery. Keep this
    // future cached through queueing and recovery so retries cannot enqueue
    // another acknowledgement while the original operation still owns it.
    final completion = qlConnection.writeMessage(
      api.QuantumLinkMessage.firmwareFetchEvent(
        const api.FirmwareFetchEvent.downloading(),
      ),
    );
    final acknowledgement = completion.timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        EnvoyReport().log(
          "fw_update_handler",
          "Firmware preparation acknowledgement still pending after 10 seconds",
        );
        return false;
      },
    );
    unawaited(
      completion.then<void>(
        (_) => _clearFirmwarePreparationAcknowledgement(acknowledgement),
        onError: (_, __) =>
            _clearFirmwarePreparationAcknowledgement(acknowledgement),
      ),
    );
    return acknowledgement;
  }

  void _clearFirmwarePreparationAcknowledgement(
    Future<bool> acknowledgement,
  ) {
    if (identical(_firmwarePreparationAcknowledgement, acknowledgement)) {
      _firmwarePreparationAcknowledgement = null;
    }
  }

  api.FirmwareUpdateAvailable updateAvailableMessage(List<PrimePatch> patches) {
    _storeAvailablePatchMetadata(patches);
    return _buildUpdateAvailableMessage(patches);
  }

  void _storeAvailablePatchMetadata(List<PrimePatch> patches) {
    _availablePatches = List.unmodifiable(patches);
    totalPatchBytes = _getTotalPatchBytes(patches);
    newVersion = patches.last.version;
  }

  api.FirmwareUpdateAvailable _buildUpdateAvailableMessage(
    List<PrimePatch> patches,
  ) {
    final latest = patches.last;
    final patchBytes = _getTotalPatchBytes(patches);
    EnvoyReport().log(
      "fw_update_handler",
      "Firmware payload size: patches=${patches.length}, total size=${_formatMegabytes(patchBytes)} MB}",
    );
    final changelog = patches.reversed.fold(
      "",
      (acc, p) => "$acc\n${p.changelog}",
    );
    return api.FirmwareUpdateAvailable(
      version: latest.version,
      changelog: changelog,
      timestamp: latest.releaseDate.millisecondsSinceEpoch,
      totalSize: patchBytes,
      patchCount: patches.length,
    );
  }

  //UI state updates
  FwUpdateState _updateFetchState(String message, EnvoyStepState state) {
    final fetchState = FwUpdateState(message: message, step: state);
    _latestFetchState = fetchState;
    _fetchState.sink.add(fetchState);
    return fetchState;
  }

  void _updateFwUpdateState(PrimeFwUpdateStep step) {
    _firmwareUpdateGeneration++;
    _latestStep = step;
    _completedUpdateStates.add(step);
    _primeFwUpdate.sink.add(step);
  }

  bool get _firmwareUpdateInProgress =>
      _firmwareFetchActive ||
      switch (_latestStep) {
        PrimeFwUpdateStep.downloading ||
        PrimeFwUpdateStep.transferring =>
          !_firmwareTransferPaused,
        PrimeFwUpdateStep.verifying ||
        PrimeFwUpdateStep.installing ||
        PrimeFwUpdateStep.rebooting =>
          true,
        PrimeFwUpdateStep.idle ||
        PrimeFwUpdateStep.notAvailable ||
        PrimeFwUpdateStep.finished ||
        PrimeFwUpdateStep.error =>
          false,
      };

  void _replaceFwUpdateState(PrimeFwUpdateStep step) {
    _firmwareUpdateGeneration++;
    _completedUpdateStates.clear();
    _latestStep = step;
    if (step != PrimeFwUpdateStep.idle) {
      _completedUpdateStates.add(step);
    }
    _primeFwUpdate.sink.add(step);
  }

  void _setFirmwareTransferLifecycle({
    required bool active,
    required bool paused,
  }) {
    if (_firmwareFetchActive == active && _firmwareTransferPaused == paused) {
      return;
    }
    _firmwareFetchActive = active;
    _firmwareTransferPaused = paused;
    _firmwareUpdateGeneration++;
  }

  void _updateDownloadState(String message, EnvoyStepState state) {
    _downloadState.sink.add(FwUpdateState(message: message, step: state));
  }

  //send ui state updates
  void _handleOnboardingState(api.FirmwareInstallEvent event) {
    event.map(
      updateVerified: (event) {
        EnvoyReport().log(
          "fw_update_handler",
          "Install event: updateVerified — firmware signature/integrity check passed",
        );
        _updateFwUpdateState(PrimeFwUpdateStep.verifying);
      },
      installing: (event) {
        EnvoyReport().log(
          "fw_update_handler",
          "Install event: installing — device is applying the firmware",
        );
        _updateFwUpdateState(PrimeFwUpdateStep.installing);
        if (qlConnection.getDevice()?.onboardingComplete == true) {
          EnvoyReport().log(
            "fw_update_handler",
            "Settings update — marking as finished on installing",
          );
          _updateFwUpdateState(PrimeFwUpdateStep.finished);
        }
      },
      rebooting: (event) {
        if (qlConnection.getDevice()?.onboardingComplete == true) {
          EnvoyReport().log(
            "fw_update_handler",
            "Settings update — ignoring reboot event",
          );
          return;
        }
        EnvoyReport().log(
          "fw_update_handler",
          "Install event: rebooting — device is rebooting into new firmware",
        );
        _updateFwUpdateState(PrimeFwUpdateStep.rebooting);
      },
      success: (event) {
        EnvoyReport().log(
          "fw_update_handler",
          "Install event: success — firmware update completed successfully, newVersion=$newVersion",
        );
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
    final progress = _highWaterProgress = wProgress.progress.clamp(
      _highWaterProgress,
      1.0,
    );

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
    _replaceFwUpdateState(PrimeFwUpdateStep.idle);
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
    if (!_downloadProgress.isClosed) {
      _downloadProgress.sink.add(0);
    }
    newVersion = "";
    totalPatchBytes = 0;
  }

  @override
  void dispose() {
    _disposed = true;
    _firmwareUpdateChecks.clear();
    _activeFirmwareUpdateCheckLoadingState = null;
    _cancelFirmwareFetchRequest(updateConnectionState: false);
    _fetchState.close();
    _downloadState.close();
    _transferState.close();
    _primeFwUpdate.close();
    _downloadProgress.close();
    _transferProgress.close();
    _settingsUpdateStarted.close();
    super.dispose();
  }

  void stopFirmwareTransfer() {
    _cancelFirmwareFetchRequest();
  }

  void pauseFirmwareTransferForDisconnect() {
    if (_primeFwUpdate.isClosed) return;
    if (_chunkQueue == null) {
      // Preparation has no chunk offset to resume. Native write recovery must
      // still cancel it, but the UI needs a terminal result, not stale loading.
      _cancelFirmwareFetchRequest();
      _updateFwUpdateState(PrimeFwUpdateStep.error);
      _updateDownloadState(
        S().firmware_updateError_downloadFailed,
        EnvoyStepState.ERROR,
      );
      _updateFetchState(
        S().firmware_updateError_downloadFailed,
        EnvoyStepState.ERROR,
      );
      EnvoyReport().log(
        "fw_update_handler",
        "Firmware preparation cancelled because the BLE connection was lost",
      );
      return;
    }

    _chunkQueue?.stop();
    _setFirmwareTransferLifecycle(active: false, paused: true);
    qlConnection.setFirmwareTransferInProgress(false);
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
  SendOne<T>? _sendOne;

  bool get isRunning => _running;

  int get currentIndex => _cursor;

  bool get isCompleted => _cursor >= _items.length && !_running;

  int get length => _items.length;

  Future<void> start(SendOne<T> sendOne) async {
    if (_running) return;
    _sendOne = sendOne;
    await _run();
  }

  Future<void> _run() async {
    _running = true;
    _stopRequested = false;

    EnvoyReport().log(
      "ControlledQueue",
      "Queue started: total=${_items.length} items",
    );

    try {
      while (!_stopRequested && _cursor < _items.length) {
        if (_restartFrom != null) {
          _cursor = _restartFrom!;
          _restartFrom = null;
        }

        EnvoyReport().log(
          "ControlledQueue",
          "Sending index $_cursor/${_items.length - 1}",
        );
        await _sendOne!(_cursor, _items[_cursor]);

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

  /// Restart sending from [index]. If the queue has already finished,
  /// re-launches the send loop and returns the new [Future]; otherwise
  /// the running loop picks up the new cursor and returns `null`.
  Future<void>? restartFrom(int index) {
    if (index < 0 || index >= _items.length) {
      throw RangeError.index(index, _items, 'index');
    }

    _restartFrom = index;
    _stopRequested = false;

    if (!_running) {
      _cursor = index;
      // Re-launch the send loop if the queue already completed.
      if (_sendOne != null) {
        EnvoyReport().log(
          "ControlledQueue",
          "Re-launching completed queue from index $index/${_items.length - 1}",
        );
        return _run();
      }
    }
    return null;
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
