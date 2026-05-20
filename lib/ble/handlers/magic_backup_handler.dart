// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later
// ignore_for_file: constant_identifier_names///

import 'dart:async';

import 'package:backup/backup.dart' as backup_lib;
import 'package:envoy/ble/bluetooth_manager.dart';
import 'package:envoy/ble/quantum_link_router.dart';
import 'package:envoy/business/devices.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/channels/bluetooth_channel.dart';
import 'package:envoy/util/bug_report_helper.dart';
import 'package:envoy/util/console.dart';
import 'package:foundation_api/foundation_api.dart' as api;
import 'package:tor/tor.dart';

class BleMagicBackupHandler extends PassportMessageHandler {
  BleMagicBackupHandler(super.connection);

  api.CollectBackupChunks? _collectBackupChunks;

  @override
  bool canHandle(api.QuantumLinkMessage message) {
    return message is api.QuantumLinkMessage_EnvoyMagicBackupEnabledRequest ||
        message is api.QuantumLinkMessage_CreateMagicBackupEvent ||
        message is api.QuantumLinkMessage_RestoreMagicBackupRequest ||
        message is api.QuantumLinkMessage_PrimeMagicBackupEnabled ||
        message is api.QuantumLinkMessage_MagicBackupRequestV2;
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
        case api.QuantumLinkMessage_PrimeMagicBackupEnabled enabled) {
      final device = qlConnection.getDevice();
      if (device != null) {
        unawaited(
          Devices().updatePrimeBackupStatus(enabled.field0.enabled, device),
        );
      }
    } else if (message case api.QuantumLinkMessage_MagicBackupRequestV2 v2Req) {
      await _handleMagicBackupRequestV2(v2Req.field0);
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
        final device = qlConnection.getDevice();
        if (device != null) {
          unawaited(
            Devices().updatePrimeBackupStatus(true, device),
          );
        }
        _collectBackupChunks = await api.collectBackupChunks(
          seedFingerprint: payload.seedFingerprint,
          totalChunks: payload.totalChunks,
          backupHash: payload.hash,
        );
      case api.CreateMagicBackupEvent_Chunk():
        final payload = event.field0;
        if (_collectBackupChunks != null) {
          try {
            kPrint(
              "Prime Magic Backup Chunk Received: ${payload.chunkIndex + 1} of ${payload.totalChunks} ",
            );

            final api.PrimeBackupFile? file = await api.pushBackupChunk(
              chunk: payload,
              this_: _collectBackupChunks!,
            );
            if (file != null) {
              final result = await backup_lib.Backup.performPrimeBackup(
                serverUrl: Settings().envoyServerAddress,
                proxyPort: Tor.instance.port,
                seedHash: file.seedFingerprint.field0,
                payload: file.data,
              );
              kPrint(
                "Prime Magic Backup upload: ${result ? "✔︎success" : "✖︎ failure"}",
              );
              if (result == true) {
                await qlConnection.writeMessage(
                  api.QuantumLinkMessage_CreateMagicBackupResult(
                    api.CreateMagicBackupResult.success(),
                  ),
                );
              } else {
                await qlConnection.writeMessage(
                  api.QuantumLinkMessage_CreateMagicBackupResult(
                    api.CreateMagicBackupResult.error(
                      error: "Failed to upload backup",
                    ),
                  ),
                );
              }
              _collectBackupChunks = null;
            }
          } catch (e, stack) {
            await qlConnection.writeMessage(
              api.QuantumLinkMessage_RestoreMagicBackupResult(
                api.RestoreMagicBackupResult.error(error: e.toString()),
              ),
            );
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
      ).timeout(
        Duration(seconds: 30),
        onTimeout: () {
          throw Exception("Timeout fetching magic backup from server.");
        },
      );
      if (payloadRes.isNotEmpty) {
        final tempFile = await BluetoothChannel.getBleCacheFile(
          payloadRes.hashCode.toString(),
        );
        await qlConnection.encodeToFile(
          message: payloadRes,
          filePath: tempFile.path,
          chunkSize: bleChunkSize.toInt(),
        );
        await qlConnection.transmitFromFile(tempFile.path);
        kPrint("Restore magic backup file sent!");
      } else {
        qlConnection.writeMessage(
          api.QuantumLinkMessage_RestoreMagicBackupEvent(
            api.RestoreMagicBackupEvent.error(error: "Empty backup payload"),
          ),
        );
      }
    } catch (e, stack) {
      EnvoyReport().log(
        "PrimeMagicBackup",
        "Error restoring magic backup: $e",
        stackTrace: stack,
      );
      if (e is backup_lib.GetBackupException) {
        switch (e) {
          case backup_lib.GetBackupException.serverUnreachable:
            qlConnection.writeMessage(
              api.QuantumLinkMessage_RestoreMagicBackupEvent(
                api.RestoreMagicBackupEvent.error(error: "serverUnreachable"),
              ),
            );
          case backup_lib.GetBackupException.seedNotFound:
            qlConnection.writeMessage(
              api.QuantumLinkMessage_RestoreMagicBackupEvent(
                api.RestoreMagicBackupEvent.error(error: "seedNotFound"),
              ),
            );
          case backup_lib.GetBackupException.backupNotFound:
            qlConnection.writeMessage(
              api.QuantumLinkMessage_RestoreMagicBackupEvent(
                api.RestoreMagicBackupEvent.notFound(),
              ),
            );
          case backup_lib.GetBackupException.invalidServer:
            qlConnection.writeMessage(
              api.QuantumLinkMessage_RestoreMagicBackupEvent(
                api.RestoreMagicBackupEvent.error(error: "invalidServer"),
              ),
            );
          case backup_lib.GetBackupException.invalidBackupFile:
            qlConnection.writeMessage(
              api.QuantumLinkMessage_RestoreMagicBackupEvent(
                api.RestoreMagicBackupEvent.error(error: "invalidBackupFile"),
              ),
            );
          case backup_lib.GetBackupException.invalidSeed:
            qlConnection.writeMessage(
              api.QuantumLinkMessage_RestoreMagicBackupEvent(
                api.RestoreMagicBackupEvent.error(error: "invalidSeed"),
              ),
            );
        }
      } else {
        qlConnection.writeMessage(
          api.QuantumLinkMessage_RestoreMagicBackupEvent(
            api.RestoreMagicBackupEvent.error(error: "$e"),
          ),
        );
      }
    }
  }

  Future _handleMagicBackupEnabledRequest(
    api.EnvoyMagicBackupEnabledRequest _,
  ) async {
    kPrint(
      "Got magic backup enabled request! sending response enabled=${Settings().syncToCloud}",
    );
    await qlConnection.writeMessage(
      api.QuantumLinkMessage.envoyMagicBackupEnabledResponse(
        api.EnvoyMagicBackupEnabledResponse(enabled: Settings().syncToCloud),
      ),
    );
  }

  Future<void> _handleMagicBackupRequestV2(
    api.MagicBackupRequestV2 request,
  ) async {
    final v2Url = Settings().backupServerV2Address;
    final proxyPort = Tor.instance.port;

    try {
      switch (request) {
        case api.MagicBackupRequestV2_Create(:final field0):
          final success = await backup_lib.Backup.performPrimeBackupV2(
            v2ServerUrl: v2Url,
            proxyPort: proxyPort,
            timestamp: field0.timestamp,
            hash: field0.hash,
            pubkey: field0.pubkey,
            data: field0.data,
            clientSignature: field0.clientSignature,
          );
          if (success) {
            await qlConnection.writeMessage(
              api.QuantumLinkMessage_MagicBackupResponseV2(
                api.MagicBackupResponseV2.created(),
              ),
            );
          } else {
            await qlConnection.writeMessage(
              api.QuantumLinkMessage_MagicBackupResponseV2(
                api.MagicBackupResponseV2.error(
                  error: "Failed to upload v2 backup",
                ),
              ),
            );
          }
        case api.MagicBackupRequestV2_Get(:final field0):
          final data = await backup_lib.Backup.getPrimeBackupV2(
            v2ServerUrl: v2Url,
            proxyPort: proxyPort,
            key: field0.key,
            timestamp: field0.timestamp,
            signature: field0.signature,
          );
          await qlConnection.writeMessage(
            api.QuantumLinkMessage_MagicBackupResponseV2(
              api.MagicBackupResponseV2.backup(data: data),
            ),
          );
        case api.MagicBackupRequestV2_Delete(:final field0):
          await backup_lib.Backup.deletePrimeBackupV2(
            v2ServerUrl: v2Url,
            proxyPort: proxyPort,
            key: field0.key,
            timestamp: field0.timestamp,
            signature: field0.signature,
          );
          await qlConnection.writeMessage(
            api.QuantumLinkMessage_MagicBackupResponseV2(
              api.MagicBackupResponseV2.deleted(),
            ),
          );
      }
    } catch (e, stack) {
      kPrint("Error handling v2 magic backup request: $e", stackTrace: stack);
      await qlConnection.writeMessage(
        api.QuantumLinkMessage_MagicBackupResponseV2(
          api.MagicBackupResponseV2.error(error: e.toString()),
        ),
      );
    }
  }

  Future<void> _handleStatusRequest(
    api.PrimeMagicBackupStatusRequest statusRequest,
  ) async {
    //TODO: implement
  }
}
