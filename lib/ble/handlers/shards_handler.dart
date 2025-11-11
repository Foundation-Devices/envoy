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
  ShardsHandler(super.writer);

  @override
  bool canHandle(api.QuantumLinkMessage message) {
    return message is api.QuantumLinkMessage_BackupShardRequest ||
        message is api.QuantumLinkMessage_RestoreShardRequest;
  }

  @override
  Future<void> handleMessage(api.QuantumLinkMessage message) async {
    if (message case api.QuantumLinkMessage_BackupShardRequest request) {
      kPrint("Got shard backup request!");
      final shard = request.field0.field0;

      // TODO: add shard ids to API
      try {
        await PrimeShard().addShard(shard: shard.payload);
        writer.writeMessage(api.QuantumLinkMessage.backupShardResponse(
            api.BackupShardResponse_Success()));
        kPrint("Shard backed up!");
      } catch (e, _) {
        kPrint("Shard backup failure: $e");
        writer.writeMessage(api.QuantumLinkMessage.backupShardResponse(
            api.BackupShardResponse_Success()));
      }
    }

    if (message case api.QuantumLinkMessage_RestoreShardRequest request) {
      kPrint("Got shard restore request!");
      final fingerprint = request.field0.seedFingerprint;

      try {
        final shard = await PrimeShard()
            .getShard(fingerprint: Uint8List.fromList(fingerprint));
        if (shard == null) {
          await writer.writeMessage(api.QuantumLinkMessage.restoreShardResponse(
              api.RestoreShardResponse_NotFound("Shard not found")));
          throw Exception("Shard not found!");
        }

        final result = await writer.writeMessage(
            api.QuantumLinkMessage.restoreShardResponse(
                api.RestoreShardResponse_Success(
                    api.Shard(payload: shard.shard))));

        kPrint("Shard restored! success ? $result");
      } catch (e, _) {
        kPrint("Shard restore failure: $e");
        await writer.writeMessage(api.QuantumLinkMessage.backupShardResponse(
            api.BackupShardResponse_Error(e.toString())));
      }
    }
  }
}
