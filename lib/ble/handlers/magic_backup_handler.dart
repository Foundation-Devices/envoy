// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later
// ignore_for_file: constant_identifier_names///

import 'package:backup/backup.dart' as backup_lib;
import 'package:envoy/ble/quantum_link_router.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/util/bug_report_helper.dart';
import 'package:envoy/util/console.dart';
import 'package:foundation_api/foundation_api.dart' as api;
import 'package:tor/tor.dart';

class BleMagicBackupHandler extends PassportMessageHandler {
  BleMagicBackupHandler(super.writer);

  api.CollectBackupChunks? _collectBackupChunks;

  @override
  bool canHandle(api.QuantumLinkMessage message) {
    return message is api.QuantumLinkMessage_EnvoyMagicBackupEnabledRequest ||
        message is api.QuantumLinkMessage_CreateMagicBackupEvent ||
        message is api.QuantumLinkMessage_RestoreMagicBackupRequest;
  }

  @override
  Future<void> handleMessage(api.QuantumLinkMessage message) async {
    if (message
        case api.QuantumLinkMessage_CreateMagicBackupEvent createEvent) {
      final event = createEvent.field0;
      await _handleCreateEvent(event);
    } else if (message
        case api.QuantumLinkMessage_RestoreMagicBackupRequest restoreRequest) {
      await _restoreMagicBackup(restoreRequest.field0);
    } else if (message
        case api.QuantumLinkMessage_EnvoyMagicBackupEnabledRequest
            enabledRequest) {
      await _handleMagicBackupEnabledRequest(enabledRequest.field0);
    } else if (message
        case api.QuantumLinkMessage_PrimeMagicBackupStatusRequest
            enabledRequest) {
      await _handleStatusRequest(enabledRequest.field0);
    }
  }

  Future<void> _handleCreateEvent(api.CreateMagicBackupEvent event) async {
    switch (event) {
      case api.CreateMagicBackupEvent_Start():
        final payload = event.field0;
        kPrint("Magic Backup Start Event: $payload");
        _collectBackupChunks = await api.collectBackupChunks(
            seedFingerprint: payload.seedFingerprint,
            totalChunks: payload.totalChunks,
            backupHash: payload.hash);
      case api.CreateMagicBackupEvent_Chunk():
        final payload = event.field0;
        if (_collectBackupChunks != null) {
          try {
            kPrint(
                "Prime Magic Backup Chunk Received: ${payload.chunkIndex + 1} of ${payload.totalChunks} ");

            final api.PrimeBackupFile? file = await api.pushBackupChunk(
                chunk: payload, this_: _collectBackupChunks!);
            if (file != null) {
              final result = await backup_lib.Backup.performPrimeBackup(
                  serverUrl: Settings().envoyServerAddress,
                  proxyPort: Tor.instance.port,
                  seedHash: file.seedFingerprint,
                  payload: file.data);
              kPrint(
                  "Prime Magic Backup upload: ${result ? "✔︎success" : "✖︎ failure"}");
              if (result == true) {
                await writer.writeMessage(
                    api.QuantumLinkMessage_CreateMagicBackupResult(
                        api.CreateMagicBackupResult.success()));
              } else {
                await writer.writeMessage(
                    api.QuantumLinkMessage_CreateMagicBackupResult(
                        api.CreateMagicBackupResult.error(
                            "Failed to upload backup")));
              }
              _collectBackupChunks = null;
            }
          } catch (e, stack) {
            await writer.writeMessage(
                api.QuantumLinkMessage_RestoreMagicBackupResult(
                    api.RestoreMagicBackupResult.error(e.toString())));
            kPrint("Error prime magic backup: $e", stackTrace: stack);
          }
        } else {
          kPrint("No active backup collection!");
        }
    }
  }

  Future<void> _restoreMagicBackup(api.RestoreMagicBackupRequest event) async {
    try {
      final fingerPrint = event.seedFingerprint;
      final payloadRes = await backup_lib.Backup.getPrimeBackup(
        serverUrl: Settings().envoyServerAddress,
        proxyPort: Tor.instance.port,
        hash: fingerPrint,
      );
      if (payloadRes.isNotEmpty) {
        final chunks = await api.splitBackupIntoChunks(
            backup: payloadRes, chunkSize: BigInt.from(10000));
        for (final chunk in chunks) {
          kPrint("Sending restore magic backup chunk ");
          await writer.writeMessage(chunk);
        }
      }
    } catch (e, stack) {
      writer.writeMessage(api.QuantumLinkMessage_RestoreMagicBackupResult(
          api.RestoreMagicBackupResult.error(e.toString())));
      EnvoyReport().log("PrimeMagicBackup", "Error restoring magic backup: $e",
          stackTrace: stack);
    }
  }

  Future _handleMagicBackupEnabledRequest(
      api.EnvoyMagicBackupEnabledRequest _) async {
    kPrint(
        "Got magic backup enabled request! sending response enabled=${Settings().syncToCloud}");
    await writer.writeMessage(
        api.QuantumLinkMessage.envoyMagicBackupEnabledResponse(
            api.EnvoyMagicBackupEnabledResponse(
                enabled: Settings().syncToCloud)));
  }

  Future<void> _handleStatusRequest(
      api.PrimeMagicBackupStatusRequest statusRequest) async {
    //TODO: implement
  }
}
