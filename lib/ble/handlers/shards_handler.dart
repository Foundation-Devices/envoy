// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later
// ignore_for_file: constant_identifier_names///

import 'dart:typed_data';

import 'package:envoy/ble/quantum_link_router.dart';
import 'package:envoy/business/prime_shard.dart';
import 'package:envoy/util/console.dart';
import 'package:foundation_api/foundation_api.dart' as api;

class ShardsHandler extends PassportMessageHandler {
  ShardsHandler(super.connection);

  @override
  bool canHandle(api.QuantumLinkMessage message) {
    return message is api.QuantumLinkMessage_BackupShardRequest ||
        message is api.QuantumLinkMessage_SecurityCheck ||
        message is api.QuantumLinkMessage_RestoreShardRequest ||
        //checks if shard backup is enabled
        message is api.QuantumLinkMessage_PrimeMagicBackupStatusRequest;
  }

  @override
  Future<void> handleMessage(api.QuantumLinkMessage message) async {
    if (message case api.QuantumLinkMessage_BackupShardRequest request) {
      kPrint("Got shard backup request!");
      final shard = request.field0.shard;

      // TODO: add shard ids to API
      try {
        await PrimeShard().addShard(shard: shard.field0);
        qlConnection.writeMessage(api.QuantumLinkMessage.backupShardResponse(
            api.BackupShardResponse_Success()));
        kPrint("Shard backed up!");
      } catch (e, _) {
        kPrint("Shard backup failure: $e");
        qlConnection.writeMessage(api.QuantumLinkMessage.backupShardResponse(
            api.BackupShardResponse_Error(error: e.toString())));
      }
    }
    if (message
        case api.QuantumLinkMessage_PrimeMagicBackupStatusRequest request) {
      kPrint("Got shard health check request!");
      final fingerprint = request.field0.seedFingerprint;
      try {
        final shard = await PrimeShard()
            .getShard(fingerprint: Uint8List.fromList(fingerprint.field0));
        await qlConnection.writeMessage(
            api.QuantumLinkMessage.primeMagicBackupStatusResponse(
                api.PrimeMagicBackupStatusResponse(
                    shardBackupFound: shard != null)));
        kPrint("Shard health checked! found ? ${shard != null}");
      } catch (e, _) {
        kPrint("Shard health check failure: $e");
        await qlConnection.writeMessage(
            api.QuantumLinkMessage.primeMagicBackupStatusResponse(
                api.PrimeMagicBackupStatusResponse(shardBackupFound: false)));
      }
    }

    if (message case api.QuantumLinkMessage_RestoreShardRequest request) {
      kPrint("Got shard restore request!");
      final fingerprint = request.field0.seedFingerprint;

      try {
        final shard = await PrimeShard()
            .getShard(fingerprint: Uint8List.fromList(fingerprint.field0));
        if (shard == null) {
          await qlConnection.writeMessage(
              api.QuantumLinkMessage.restoreShardResponse(
                  api.RestoreShardResponse_NotFound()));
          throw Exception("Shard not found!");
        }

        final result = await qlConnection.writeMessage(
            api.QuantumLinkMessage.restoreShardResponse(
                api.RestoreShardResponse_Success(
                    shard: api.Shard(field0: shard))));

        kPrint("Shard restored! success ? $result");
      } catch (e, _) {
        kPrint("Shard restore failure: $e");
        await qlConnection.writeMessage(api.QuantumLinkMessage.backupShardResponse(
            api.BackupShardResponse_Error(error: e.toString())));
      }
    }
  }
}
