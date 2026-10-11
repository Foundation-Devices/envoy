// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'dart:typed_data';

import 'package:backup/backup.dart' as backup_lib;
import 'package:crypto/crypto.dart';
import 'package:envoy/ble/qlv2/rpc_dispatcher.dart';
import 'package:envoy/business/devices.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/channels/ql_connection.dart';
import 'package:qlv2/qlv2.dart' as qlv2;
import 'package:tor/tor.dart';

class QLV2PassportMagicBackupEnabledHandler
    implements QLV2SessionEventHandler<qlv2.PassportMagicBackupEnabled> {
  @override
  Future<void> handleEvent(
    qlv2.PassportMagicBackupEnabled event,
    QLConnection device,
  ) async {
    final connectedDevice = device.getDevice();
    if (connectedDevice != null) {
      await Devices().updatePrimeBackupStatus(event.enabled, connectedDevice);
    }
  }
}

class QLV2MagicBackupRestoreCompletedHandler
    implements QLV2SessionEventHandler<qlv2.MagicBackupRestoreResult> {
  @override
  Future<void> handleEvent(
    qlv2.MagicBackupRestoreResult event,
    QLConnection device,
  ) async {
    // Completion is consumed by onboarding; the server-side restore operation
    // has already finished when this event arrives.
  }
}

class QLV2MagicBackupUploadHandler
    implements QLV2UploadHandler<qlv2.InboundRpc_UploadMagicBackup> {
  @override
  Future<void> handleUpload(
    qlv2.InboundRpc_UploadMagicBackup rpc,
    QLConnection device,
  ) async {
    final request = rpc.field0.request;
    // TODO: Prime backups are currently typically under 5 MB, so buffering is
    // acceptable for now. Enforce totalSize incrementally or spool large
    // uploads to disk before supporting larger backups.
    final sink = BytesBuilder(copy: false);
    final expectedSize = request.totalSize?.toInt();

    try {
      await for (final item in rpc.field0.listen()) {
        switch (item) {
          case qlv2.UploadMagicBackupStreamItem_PartHeader():
            break;
          case qlv2.UploadMagicBackupStreamItem_PartChunk(:final field0):
            sink.add(field0);
        }
      }

      final payload = sink.takeBytes();
      if (expectedSize != null && payload.length != expectedSize) {
        await rpc.field0.respond(
          response: const qlv2.UploadMagicBackupResponse.error(
            error: 'Incomplete backup upload',
          ),
        );
        return;
      }
      if (!_matchesHash(payload, request.hash)) {
        await rpc.field0.respond(
          response: const qlv2.UploadMagicBackupResponse.error(
            error: 'Invalid backup upload hash',
          ),
        );
        return;
      }

      final success = await backup_lib.Backup.performPrimeBackup(
        serverUrl: Settings().envoyServerAddress,
        proxyPort: Tor.instance.port,
        seedHash: request.seedFingerprint.field0,
        payload: payload,
      );
      if (success) {
        final connectedDevice = device.getDevice();
        if (connectedDevice != null) {
          await Devices().updatePrimeBackupStatus(true, connectedDevice);
        }
      }
      await rpc.field0.respond(
        response: success
            ? const qlv2.UploadMagicBackupResponse.success()
            : const qlv2.UploadMagicBackupResponse.error(
                error: 'Failed to upload backup',
              ),
      );
    } catch (_) {
      try {
        await rpc.field0.respond(
          response: const qlv2.UploadMagicBackupResponse.error(
            error: 'backup_upload_failed',
          ),
        );
      } catch (_) {
        // The peer may already have closed the upload response stream.
      }
    }
  }
}

class QLV2MagicBackupDownloadHandler
    implements QLV2DownloadHandler<qlv2.InboundRpc_DownloadMagicBackup> {
  @override
  Future<void> handleDownload(
    qlv2.InboundRpc_DownloadMagicBackup rpc,
    QLConnection device,
  ) async {
    try {
      final payload = await backup_lib.Backup.getPrimeBackup(
        serverUrl: Settings().envoyServerAddress,
        proxyPort: Tor.instance.port,
        hash: rpc.field0.request.seedFingerprint.field0,
      ).timeout(const Duration(seconds: 30));

      if (payload.isEmpty) {
        await rpc.field0.start(
          header: const qlv2.DownloadMagicBackupHeader.error(
            error: 'Empty backup payload',
          ),
        );
        await rpc.field0.finish();
        return;
      }
      await rpc.field0.start(
        header: qlv2.DownloadMagicBackupHeader.found(
          qlv2.BackupMetadata(totalSize: BigInt.from(payload.length)),
        ),
      );
      await rpc.field0.send(partHeader: const qlv2.Empty(), data: payload);
      await rpc.field0.finish();
    } catch (error) {
      await rpc.field0.start(header: _downloadError(error));
      await rpc.field0.finish();
    }
  }
}

bool _matchesHash(Uint8List payload, List<int> expected) {
  final actual = sha256.convert(payload).bytes;
  if (actual.length != expected.length) return false;
  var difference = 0;
  for (var index = 0; index < actual.length; index++) {
    difference |= actual[index] ^ expected[index];
  }
  return difference == 0;
}

qlv2.DownloadMagicBackupHeader _downloadError(Object error) {
  if (error is backup_lib.GetBackupException) {
    return switch (error) {
      backup_lib.GetBackupException.backupNotFound ||
      backup_lib.GetBackupException.unauthorized =>
        const qlv2.DownloadMagicBackupHeader.notFound(),
      backup_lib.GetBackupException.serverUnreachable =>
        const qlv2.DownloadMagicBackupHeader.error(
          error: 'serverUnreachable',
        ),
      backup_lib.GetBackupException.seedNotFound =>
        const qlv2.DownloadMagicBackupHeader.error(error: 'seedNotFound'),
      backup_lib.GetBackupException.invalidServer =>
        const qlv2.DownloadMagicBackupHeader.error(error: 'invalidServer'),
      backup_lib.GetBackupException.invalidBackupFile =>
        const qlv2.DownloadMagicBackupHeader.error(
          error: 'invalidBackupFile',
        ),
      backup_lib.GetBackupException.invalidSeed =>
        const qlv2.DownloadMagicBackupHeader.error(error: 'invalidSeed'),
    };
  }
  return const qlv2.DownloadMagicBackupHeader.error(
    error: 'backup_download_failed',
  );
}
