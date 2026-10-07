// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:envoy/ble/qlv2/rpc_dispatcher.dart';
import 'package:envoy/business/devices.dart';
import 'package:envoy/business/local_storage.dart';
import 'package:envoy/business/server.dart';
import 'package:envoy/business/updates_manager.dart';
import 'package:envoy/channels/ql_connection.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/onboard/prime/state/prime_onboarding_controller.dart';
import 'package:envoy/ui/widgets/envoy_step_item.dart';
import 'package:envoy/util/bug_report_helper.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:envoy/util/transfer_rate_estimator.dart';
import 'package:http_tor/http_tor.dart';
import 'package:qlv2/qlv2.dart' as qlv2;

class QLV2FirmwareStepState {
  const QLV2FirmwareStepState({
    required this.message,
    required this.step,
  });

  final String message;
  final EnvoyStepState step;
}

class QLV2FirmwareTransferProgress {
  const QLV2FirmwareTransferProgress({
    required this.progress,
    required this.remainingTime,
  });

  final double progress;
  final String remainingTime;
}

class QLV2FirmwareEvents {
  QLV2FirmwareEvents();

  final _check = StreamController<QLV2FirmwareStepState>.broadcast();
  final _download = StreamController<QLV2FirmwareStepState>.broadcast();
  final _updateStep = StreamController<PrimeFwUpdateStep>.broadcast();
  final _downloadProgress = StreamController<double>.broadcast();
  final _settingsUpdateStarted = StreamController<void>.broadcast();
  final _transferProgress =
      StreamController<QLV2FirmwareTransferProgress>.broadcast();

  QLV2FirmwareStepState? _lastCheckState;
  QLV2FirmwareStepState? _lastDownloadState;
  PrimeFwUpdateStep _lastUpdateStep = PrimeFwUpdateStep.idle;
  final Set<PrimeFwUpdateStep> _completedUpdateStates = {};
  String _currentVersion = "";
  String _newVersion = "";
  int _totalPatchBytes = 0;
  List<PrimeFirmwareChangelog> _changelogs = const [];
  Future<void> _operationChain = Future.value();
  bool _disposed = false;

  Stream<QLV2FirmwareStepState> get check => _check.stream;

  Stream<QLV2FirmwareStepState> get download => _download.stream;

  Stream<PrimeFwUpdateStep> get updateStep => _updateStep.stream;

  Stream<double> get downloadProgress => _downloadProgress.stream;

  Stream<void> get settingsUpdateStarted => _settingsUpdateStarted.stream;

  Stream<QLV2FirmwareTransferProgress> get transferProgress =>
      _transferProgress.stream;

  QLV2FirmwareStepState? get lastCheckState => _lastCheckState;

  QLV2FirmwareStepState? get lastDownloadState => _lastDownloadState;

  PrimeFwUpdateStep get lastUpdateStep => _lastUpdateStep;

  Set<PrimeFwUpdateStep> get completedUpdateStates =>
      Set.unmodifiable(_completedUpdateStates);

  String get currentVersion => _currentVersion;

  String get newVersion => _newVersion;

  int get totalPatchBytes => _totalPatchBytes;

  List<PrimeFirmwareChangelog> get changelogs => _changelogs;

  String get estimatedUpdateTime => _formatEstimatedUpdateTime(
        _totalPatchBytes,
      );

  void emitCheck(String message, EnvoyStepState step) {
    if (_disposed) return;
    _logQlv2Firmware("event: check step=$step message=$message");
    final state = QLV2FirmwareStepState(message: message, step: step);
    _lastCheckState = state;
    _check.add(state);
  }

  void emitDownload(String message, EnvoyStepState step) {
    if (_disposed) return;
    _logQlv2Firmware("event: download step=$step message=$message");
    final state = QLV2FirmwareStepState(message: message, step: step);
    _lastDownloadState = state;
    _download.add(state);
  }

  void emitUpdateStep(PrimeFwUpdateStep step) {
    if (_disposed) return;
    _logQlv2Firmware("event: update_step step=$step");
    _lastUpdateStep = step;
    if (step == PrimeFwUpdateStep.idle) {
      _completedUpdateStates.clear();
    } else {
      _completedUpdateStates.add(step);
    }
    _updateStep.add(step);
  }

  void emitTransferProgress({
    required double progress,
    required String remainingTime,
  }) {
    if (_disposed) return;
    _transferProgress.add(
      QLV2FirmwareTransferProgress(
        progress: progress,
        remainingTime: remainingTime,
      ),
    );
  }

  void emitDownloadProgress(double progress) {
    if (_disposed) return;
    _downloadProgress.add(progress.clamp(0.0, 1.0));
  }

  void emitSettingsUpdateStarted() {
    if (_disposed) return;
    _settingsUpdateStarted.add(null);
  }

  void recordUpdateMetadata({
    required String currentVersion,
    required List<QLV2FirmwarePatch> patches,
  }) {
    _currentVersion = currentVersion;
    _newVersion = patches.isEmpty ? "" : patches.last.version;
    _totalPatchBytes = patches.fold<int>(
      0,
      (sum, patch) => sum + patch.size,
    );
    _changelogs = patches
        .map(
          (patch) => PrimeFirmwareChangelog(
            version: patch.version,
            changelog: patch.changelog,
          ),
        )
        .toList(growable: false);
  }

  void reset() {
    _lastCheckState = null;
    _lastDownloadState = null;
    _lastUpdateStep = PrimeFwUpdateStep.idle;
    _completedUpdateStates.clear();
    _currentVersion = "";
    _newVersion = "";
    _totalPatchBytes = 0;
    _changelogs = const [];
    emitDownloadProgress(0);
    emitTransferProgress(progress: 0.0, remainingTime: "");
  }

  Future<void> runExclusive(Future<void> Function() operation) {
    if (_disposed) return Future.value();
    final result = _operationChain.then((_) => operation());
    _operationChain = result.catchError((_) {});
    return result;
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    unawaited(_check.close());
    unawaited(_download.close());
    unawaited(_updateStep.close());
    unawaited(_downloadProgress.close());
    unawaited(_settingsUpdateStarted.close());
    unawaited(_transferProgress.close());
  }
}

class QLV2FirmwareUpdateCheckHandler
    implements QLV2RequestHandler<qlv2.InboundRpc_FirmwareUpdateCheck> {
  QLV2FirmwareUpdateCheckHandler({
    required QLV2FirmwareEvents events,
    QLV2FirmwareSource? firmwareSource,
  })  : _events = events,
        _firmwareSource = firmwareSource;

  final QLV2FirmwareEvents _events;
  final QLV2FirmwareSource? _firmwareSource;

  @override
  Future<void> handleRequest(
    qlv2.InboundRpc_FirmwareUpdateCheck rpc,
    QLConnection device,
  ) {
    return _events.runExclusive(() => _handleRequest(rpc, device));
  }

  Future<void> _handleRequest(
    qlv2.InboundRpc_FirmwareUpdateCheck rpc,
    QLConnection device,
  ) async {
    final currentVersion = rpc.field0.payload.currentVersion;
    _logQlv2Firmware(
      "update_check: received currentVersion=$currentVersion "
      "deviceId=${device.deviceId}",
    );
    _events.emitCheck(
      S().onboarding_connectionChecking_forUpdates,
      EnvoyStepState.LOADING,
    );
    try {
      final source = _firmwareSource ?? _selectedFirmwareSource();
      _logQlv2Firmware(
        "update_check: fetching patches source=${_firmwareSourceName(source)} "
        "currentVersion=$currentVersion",
      );
      final patches = await source.fetchPatches(currentVersion);
      _logQlv2Firmware(
        "update_check: fetched ${patches.length} patch(es) "
        "${_describePatches(patches)}",
      );
      _events.recordUpdateMetadata(
        currentVersion: currentVersion,
        patches: patches,
      );

      if (patches.isEmpty) {
        _logQlv2Firmware("update_check: responding notAvailable");
        await rpc.field0.respond(
          response: qlv2.FirmwareUpdateCheckResponse.notAvailable(),
        );
        _events.emitCheck(
          S().onboarding_connectionNoUpdates_noUpdates,
          EnvoyStepState.FINISHED,
        );
        _events.emitUpdateStep(PrimeFwUpdateStep.notAvailable);
      } else {
        final update = _firmwareUpdateAvailable(patches);
        _logQlv2Firmware(
          "update_check: responding available version=${update.version} "
          "patchCount=${update.patchCount} "
          "totalSize=${_formatBytes(update.totalSize)}",
        );
        await rpc.field0.respond(
          response: qlv2.FirmwareUpdateCheckResponse.available(
            update,
          ),
        );
        _events.emitCheck(
          S().onboarding_connectionUpdatesAvailable_updatesAvailable,
          EnvoyStepState.FINISHED,
        );
        if (device.getDevice()?.onboardingComplete == true) {
          _events.emitSettingsUpdateStarted();
        }
      }
    } catch (e, stack) {
      _logQlv2Firmware(
        "update_check: failed currentVersion=$currentVersion error=$e",
        stackTrace: stack,
      );
      EnvoyReport().log(
        "qlv2_fw_update_handler",
        "Failed to check for updates: $e",
        stackTrace: stack,
      );
      _events.emitCheck(
        S().firmware_updateError_downloadFailed,
        EnvoyStepState.ERROR,
      );
      _events.emitUpdateStep(PrimeFwUpdateStep.error);
    }
  }
}

class QLV2FirmwareDownloadHandler
    implements QLV2DownloadHandler<qlv2.InboundRpc_FirmwareDownload> {
  QLV2FirmwareDownloadHandler({
    required QLV2FirmwareEvents events,
    QLV2FirmwareSource? firmwareSource,
  })  : _events = events,
        _firmwareSource = firmwareSource;

  final QLV2FirmwareEvents _events;
  final _transferEstimator = TransferRateEstimator();
  final QLV2FirmwareSource? _firmwareSource;
  double _highWaterProgress = 0.0;

  @override
  Future<void> handleDownload(
    qlv2.InboundRpc_FirmwareDownload rpc,
    QLConnection device,
  ) {
    return _events.runExclusive(() => _handleDownload(rpc, device));
  }

  Future<void> _handleDownload(
    qlv2.InboundRpc_FirmwareDownload rpc,
    QLConnection device,
  ) async {
    final currentVersion = rpc.field0.request.currentVersion;
    var downloadStarted = false;
    var transferStarted = false;
    StreamSubscription? disconnectSubscription;
    final cancellationToken = DownloadCancellationToken();
    _logQlv2Firmware(
      "download: received currentVersion=$currentVersion "
      "deviceId=${device.deviceId} "
      "connected=${device.lastDeviceStatus.connected} "
      "bonded=${device.lastDeviceStatus.bonded}",
    );
    try {
      if (device.getDevice()?.onboardingComplete == true) {
        _events.emitSettingsUpdateStarted();
      }
      _events.emitDownload(
        S().firmware_downloadingUpdate_header,
        EnvoyStepState.LOADING,
      );
      _events.emitUpdateStep(PrimeFwUpdateStep.downloading);
      _events.emitDownloadProgress(0);
      _resetTransferProgress();

      _logQlv2Firmware(
        "download: requested currentVersion=$currentVersion",
      );
      final source = _firmwareSource ?? _selectedFirmwareSource();
      _logQlv2Firmware(
        "download: fetching patches source=${_firmwareSourceName(source)} "
        "currentVersion=$currentVersion",
      );
      final patches = await source.fetchPatches(currentVersion);
      _logQlv2Firmware(
        "download: fetched ${patches.length} patch(es) "
        "${_describePatches(patches)}",
      );
      _events.recordUpdateMetadata(
        currentVersion: currentVersion,
        patches: patches,
      );
      if (patches.isEmpty) {
        _logQlv2Firmware("download: no patches, starting notAvailable stream");
        await rpc.field0.start(
          header: qlv2.DownloadFirmwareHeader.notAvailable(),
        );
        downloadStarted = true;
        await rpc.field0.finish();
        _logQlv2Firmware("download: finished notAvailable stream");
        return;
      }

      disconnectSubscription = device.deviceStatusStream
          .where((status) => !status.connected)
          .listen((_) => cancellationToken.cancel());
      final payloads = await source.prepareDownload(
        currentVersion,
        patches,
        cancellationToken: cancellationToken,
      );
      _events.emitDownloadProgress(1);

      final update = _firmwareUpdateAvailable(patches);
      _logQlv2Firmware(
        "transfer: starting current=$currentVersion "
        "target=${update.version} patches=${patches.length} "
        "totalBytes=${update.totalSize}",
      );
      await rpc.field0.start(
        header: qlv2.DownloadFirmwareHeader.available(
          update,
        ),
      );
      downloadStarted = true;

      _events.emitDownload(
        S().firmware_downloadingUpdate_downloaded,
        EnvoyStepState.FINISHED,
      );
      _events.emitUpdateStep(PrimeFwUpdateStep.transferring);

      final totalBytes = _totalPayloadBytes(payloads);
      var bytesSent = 0;
      var sentParts = 0;
      transferStarted = true;
      device.setFirmwareTransferInProgress(true);
      await _requestHighBlePriority(device);

      for (final payload in payloads) {
        final patch = payload.patch;
        final bytes = payload.bytes;
        final patchSha256 = sha256.convert(bytes).toString();
        sentParts++;

        _logQlv2Firmware(
          "transfer: sending patch=${patch.updateFilename} "
          "sizeBytes=${bytes.length} sha256=$patchSha256",
        );

        if (bytes.length != patch.size) {
          _logQlv2Firmware(
            "transfer: patch size mismatch patch=${patch.updateFilename} "
            "expected=${patch.size} actual=${bytes.length}",
          );
        }

        await rpc.field0.send(
          partHeader: qlv2.DownloadFirmwarePartHeader(
            patchName: patch.updateFilename,
            sizeBytes: BigInt.from(bytes.length),
          ),
          data: bytes,
        );

        bytesSent += bytes.length;
        _logQlv2Firmware(
          "transfer: sent patch=$sentParts/${payloads.length} "
          "bytes=$bytesSent/$totalBytes",
        );
        _processTransferProgress(
          bytesSent: bytesSent,
          totalBytes: totalBytes,
        );
      }

      await rpc.field0.finish();
      _logQlv2Firmware(
        "transfer: finished parts=$sentParts bytes=$bytesSent",
      );
    } catch (e, stack) {
      EnvoyReport().log(
        "qlv2_fw_download_handler",
        "Failed to send firmware: $e",
        stackTrace: stack,
      );
      _events.emitDownload(
        S().firmware_updateError_downloadFailed,
        EnvoyStepState.ERROR,
      );
      _events.emitUpdateStep(PrimeFwUpdateStep.error);
      if (!downloadStarted) {
        try {
          _logQlv2Firmware("download: sending error header to peer");
          await rpc.field0.start(
            header: qlv2.DownloadFirmwareHeader.error(
              error: S().firmware_updateError_downloadFailed,
            ),
          );
          await rpc.field0.finish();
          _logQlv2Firmware("download: error header stream finished");
        } catch (_) {}
      } else {
        try {
          await rpc.field0.finish();
        } catch (_) {}
      }
    } finally {
      cancellationToken.cancel();
      await disconnectSubscription?.cancel();
      if (transferStarted) {
        device.setFirmwareTransferInProgress(false);
        await _requestBalancedBlePriority(device);
      }
    }
  }

  void _resetTransferProgress() {
    _transferEstimator.reset();
    _highWaterProgress = 0.0;
    _events.emitTransferProgress(progress: 0.0, remainingTime: "");
  }

  void _processTransferProgress({
    required int bytesSent,
    required int totalBytes,
  }) {
    final progress = _highWaterProgress = (bytesSent / totalBytes).clamp(
      _highWaterProgress,
      1.0,
    );
    final remainingTime = _transferEstimator.updateProgress(
      bytesProcessed: bytesSent,
      totalBytes: totalBytes,
      progress: progress,
    );

    if (remainingTime == null) {
      return;
    }

    _events.emitTransferProgress(
      progress: progress,
      remainingTime: remainingTime,
    );
  }
}

abstract interface class QLV2FirmwareSource {
  Future<List<QLV2FirmwarePatch>> fetchPatches(String currentVersion);

  Future<List<QLV2FirmwarePatchPayload>> prepareDownload(
    String currentVersion,
    List<QLV2FirmwarePatch> patches, {
    required DownloadCancellationToken cancellationToken,
  });
}

class QLV2FirmwarePatch {
  const QLV2FirmwarePatch({
    required this.version,
    required this.baseVersion,
    required this.updateFilename,
    required this.changelog,
    required this.releaseDate,
    required this.size,
    this.serverPatch,
    this.localPath,
  });

  final String version;
  final String baseVersion;
  final String updateFilename;
  final String changelog;
  final DateTime releaseDate;
  final int size;
  final PrimePatch? serverPatch;
  final String? localPath;
}

class QLV2FirmwarePatchPayload {
  const QLV2FirmwarePatchPayload({
    required this.patch,
    required this.bytes,
  });

  final QLV2FirmwarePatch patch;
  final Uint8List bytes;
}

class ServerQlv2FirmwareSource implements QLV2FirmwareSource {
  @override
  Future<List<QLV2FirmwarePatch>> fetchPatches(String currentVersion) async {
    _logQlv2Firmware(
      "server_source: fetchPatches currentVersion=$currentVersion",
    );
    final patches = await Server().fetchPrimePatches(currentVersion);
    final result = patches.map(_fromServerPatch).toList();
    _logQlv2Firmware(
      "server_source: fetchPatches returned ${result.length} patch(es) "
      "${_describePatches(result)}",
    );
    return result;
  }

  @override
  Future<List<QLV2FirmwarePatchPayload>> prepareDownload(
    String currentVersion,
    List<QLV2FirmwarePatch> patches, {
    required DownloadCancellationToken cancellationToken,
  }) async {
    final payloads = <QLV2FirmwarePatchPayload>[];
    final latest = patches.last;
    final folderName =
        "prime-patches/${_sanitizePathPart(currentVersion)}-to-${_sanitizePathPart(latest.version)}";

    for (var index = 0; index < patches.length; index++) {
      final patch = patches[index];
      final serverPatch = patch.serverPatch;
      if (serverPatch == null) {
        throw StateError("Server patch metadata missing");
      }

      _logQlv2Firmware(
        "server_source: downloading patch ${index + 1}/${patches.length} "
        "name=${patch.updateFilename} expectedSize=${_formatBytes(patch.size)}",
      );
      final binary = await Server().fetchPrimePatchBinary(
        serverPatch,
        cancellationToken: cancellationToken,
      );
      _logQlv2Firmware(
        "server_source: downloaded patch ${index + 1}/${patches.length} "
        "name=${patch.updateFilename} actualSize=${_formatBytes(binary.length)}",
      );

      final fileName = patch.updateFilename.isNotEmpty
          ? patch.updateFilename
          : "patch-${index + 1}.bin";
      final path = "$folderName/${_sanitizePathPart(fileName)}";
      _logQlv2Firmware("server_source: saving patch cachePath=$path");
      await LocalStorage().saveFileBytes(path, binary);
      payloads.add(
        QLV2FirmwarePatchPayload(
          patch: patch,
          bytes: Uint8List.fromList(binary),
        ),
      );
    }

    await EnvoyStorage().addNewFirmware(
      DeviceType.passportPrime.index,
      latest.version,
      folderName,
      currentVersion: sanitizeVersion(currentVersion),
    );
    _logQlv2Firmware(
      "server_source: recorded firmware version=${latest.version} "
      "folder=$folderName",
    );

    return payloads;
  }

  QLV2FirmwarePatch _fromServerPatch(PrimePatch patch) {
    return QLV2FirmwarePatch(
      version: patch.version,
      baseVersion: patch.baseVersion,
      updateFilename: patch.updateFilename,
      changelog: patch.changelog,
      releaseDate: patch.releaseDate,
      size: patch.size,
      serverPatch: patch,
    );
  }
}

QLV2FirmwareSource _selectedFirmwareSource() {
  _logQlv2Firmware("source: selected server");
  return ServerQlv2FirmwareSource();
}

Future<void> _requestHighBlePriority(QLConnection device) async {
  try {
    final result = await device.requestHighConnectionPriority();
    _logQlv2Firmware(
      "ble_priority: requested high result=$result deviceId=${device.deviceId}",
    );
  } catch (e, stack) {
    _logQlv2Firmware(
      "ble_priority: high request failed deviceId=${device.deviceId} error=$e",
      stackTrace: stack,
    );
  }
}

Future<void> _requestBalancedBlePriority(QLConnection device) async {
  try {
    final result = await device.requestBalancedConnectionPriority();
    _logQlv2Firmware(
      "ble_priority: requested balanced result=$result "
      "deviceId=${device.deviceId}",
    );
  } catch (e, stack) {
    _logQlv2Firmware(
      "ble_priority: balanced request failed deviceId=${device.deviceId} "
      "error=$e",
      stackTrace: stack,
    );
  }
}

class QLV2FirmwareInstallStatusHandler
    implements QLV2SessionEventHandler<qlv2.FirmwareInstallEvent> {
  QLV2FirmwareInstallStatusHandler(this._events);

  final QLV2FirmwareEvents _events;

  @override
  Future<void> handleEvent(
    qlv2.FirmwareInstallEvent event,
    QLConnection device,
  ) async {
    _recordFirmwareInstallEvent(_events, event);
  }
}

void _recordFirmwareInstallEvent(
  QLV2FirmwareEvents events,
  qlv2.FirmwareInstallEvent event,
) {
  event.map(
    installing: (_) {
      _logQlv2Firmware("install_status: installing");
      events.emitUpdateStep(PrimeFwUpdateStep.installing);
    },
    rebooting: (_) {
      _logQlv2Firmware("install_status: rebooting");
      events.emitUpdateStep(PrimeFwUpdateStep.rebooting);
    },
    success: (_) {
      _logQlv2Firmware("install_status: success");
      events.emitUpdateStep(PrimeFwUpdateStep.finished);
    },
    error: (event) {
      _logQlv2Firmware("install_status: error ${event.error}");
      events.emitUpdateStep(PrimeFwUpdateStep.error);
    },
  );
}

qlv2.FirmwareUpdateAvailable _firmwareUpdateAvailable(
  List<QLV2FirmwarePatch> patches,
) {
  final latest = patches.last;
  final totalBytes = patches.fold<int>(0, (sum, patch) => sum + patch.size);
  final changelog = patches.reversed.fold(
    "",
    (acc, patch) => "$acc\n${patch.changelog}",
  );

  return qlv2.FirmwareUpdateAvailable(
    version: latest.version,
    changelog: changelog,
    timestamp: latest.releaseDate.millisecondsSinceEpoch,
    totalSize: totalBytes,
    patchCount: patches.length,
  );
}

String _sanitizePathPart(String value) {
  return value.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
}

void _logQlv2Firmware(String message, {StackTrace? stackTrace}) {
  final prefixed =
      "[QLV2Firmware] platform=${Platform.operatingSystem} $message";
  try {
    unawaited(
      EnvoyReport()
          .log(
            "qlv2_firmware",
            prefixed,
            stackTrace: stackTrace,
          )
          .catchError((Object error, StackTrace stackTrace) {}),
    );
  } catch (_) {}
}

String _firmwareSourceName(QLV2FirmwareSource source) {
  return switch (source) {
    ServerQlv2FirmwareSource() => "server",
    _ => source.runtimeType.toString(),
  };
}

String _describePatches(List<QLV2FirmwarePatch> patches) {
  if (patches.isEmpty) {
    return "";
  }
  return patches
      .map(
        (patch) => "{base=${patch.baseVersion}, version=${patch.version}, "
            "name=${patch.updateFilename}, size=${_formatBytes(patch.size)}}",
      )
      .join(", ");
}

int _totalPayloadBytes(List<QLV2FirmwarePatchPayload> payloads) {
  return payloads.fold<int>(0, (sum, payload) => sum + payload.bytes.length);
}

String _formatBytes(int bytes) {
  if (bytes < 1024) {
    return "${bytes}B";
  }
  if (bytes < 1024 * 1024) {
    return "${(bytes / 1024).toStringAsFixed(1)}KiB";
  }
  return "${(bytes / (1024 * 1024)).toStringAsFixed(2)}MiB";
}

String _formatEstimatedUpdateTime(int totalBytes) {
  if (totalBytes <= 0) {
    return "~5 min";
  }

  const averageTxSpeed = 30 * 1024;
  final minutes = totalBytes / averageTxSpeed / 60;

  if (minutes < 1) {
    return "1 min";
  }

  final roundedMinutes = minutes < 10
      ? (minutes * 10).ceilToDouble() / 10
      : minutes.ceilToDouble();

  return "~${(roundedMinutes + 1).toInt()} min";
}
