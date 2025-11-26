// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later
// ignore_for_file: constant_identifier_names///

import 'package:backup/backup.dart' as backup_lib;
import 'package:envoy/ble/bluetooth_manager.dart';
import 'package:envoy/ble/quantum_link_router.dart';
import 'package:envoy/business/devices.dart';
import 'package:envoy/business/envoy_seed.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/channels/bluetooth_channel.dart';
import 'package:envoy/util/bug_report_helper.dart';
import 'package:envoy/util/console.dart';
import 'package:flutter/cupertino.dart';
import 'package:foundation_api/foundation_api.dart' as api;
import 'package:tor/tor.dart';

class BleMagicBackupHandler extends PassportMessageHandler {
  BleMagicBackupHandler(super.writer);

  api.CollectBackupChunks? _collectBackupChunks;

  @override
  bool canHandle(api.QuantumLinkMessage message) {
    return message is api.QuantumLinkMessage_EnvoyMagicBackupEnabledRequest ||
        message is api.QuantumLinkMessage_CreateMagicBackupEvent ||
        message is api.QuantumLinkMessage_RestoreMagicBackupRequest ||
        message is api.QuantumLinkMessage_PrimeMagicBackupEnabled;
  }

  @override
  Future<void> handleMessage(
      api.QuantumLinkMessage message, String bleId) async {
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
      await _handleMagicBackupEnabledRequest(enabledRequest.field0, bleId);
    } else if (message
        case api.QuantumLinkMessage_PrimeMagicBackupEnabled enabled) {
      // TODO: enable/disable prime backup
      Devices().updatePrimeBackupStatus(bleId, enabled.field0.enabled);
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
                  seedHash: file.seedFingerprint.field0,
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
                            error: "Failed to upload backup")));
              }
              _collectBackupChunks = null;
            }
          } catch (e, stack) {
            await writer.writeMessage(
                api.QuantumLinkMessage_RestoreMagicBackupResult(
                    api.RestoreMagicBackupResult.error(error: e.toString())));
            kPrint("Error prime magic backup: $e", stackTrace: stack);
          }
        } else {
          kPrint("No active backup collection!");
        }
    }
  }

  Future<void> _restoreMagicBackup(api.RestoreMagicBackupRequest event) async {
    try {
      kPrint("RestoreMagicBackupRequest received...");
      final fingerPrint = event.seedFingerprint;
      final payloadRes = await backup_lib.Backup.getPrimeBackup(
        serverUrl: Settings().envoyServerAddress,
        proxyPort: Tor.instance.port,
        hash: fingerPrint.field0,
      );
      if (payloadRes.isNotEmpty) {
        final tempFile = await BluetoothChannel.getBleCacheFile(
            payloadRes.hashCode.toString());
        await BluetoothManager().encodeToFile(
            message: payloadRes, filePath: tempFile.path, chunkSize: 10000);
        await BluetoothChannel().transmitFromFile(tempFile.path);
        kPrint("Restore magic backup file sent!");
      } else {
        writer.writeMessage(api.QuantumLinkMessage_RestoreMagicBackupEvent(
            api.RestoreMagicBackupEvent.notFound()));
      }
    } catch (e, stack) {
      debugPrintStack(stackTrace: stack);
      writer.writeMessage(api.QuantumLinkMessage_RestoreMagicBackupEvent(
          api.RestoreMagicBackupEvent.error(error: "$e")));
      EnvoyReport().log("PrimeMagicBackup", "Error restoring magic backup: $e",
          stackTrace: stack);
    }
  }

  Future _handleMagicBackupEnabledRequest(
      api.EnvoyMagicBackupEnabledRequest _, String bleId) async {
    kPrint(
        "Got magic backup enabled request! sending response enabled=${Settings().syncToCloud}");
    await writer.writeMessage(
        api.QuantumLinkMessage.envoyMagicBackupEnabledResponse(
            api.EnvoyMagicBackupEnabledResponse(
                enabled: Settings().syncToCloud)));

    if (Settings().syncToCloud) {
      Devices().updatePrimeBackupStatus(bleId, true);

      if (!EnvoySeed().walletDerived()) {
        await EnvoySeed().generate();
        await EnvoySeed().backupData();
      }
    }
  }

  Future<void> _handleStatusRequest(
      api.PrimeMagicBackupStatusRequest statusRequest) async {
    //TODO: implement
  }
}
