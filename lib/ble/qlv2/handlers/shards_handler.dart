// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:typed_data';

import 'package:envoy/ble/qlv2/rpc_dispatcher.dart';
import 'package:envoy/business/prime_shard.dart';
import 'package:envoy/channels/ql_connection.dart';
import 'package:qlv2/qlv2.dart' as qlv2;

class QLV2BackupShardHandler
    implements QLV2RequestHandler<qlv2.InboundRpc_BackupShard> {
  @override
  Future<void> handleRequest(
    qlv2.InboundRpc_BackupShard rpc,
    QLConnection device,
  ) async {
    try {
      await PrimeShard().addShard(shard: rpc.field0.payload.shard.field0);
      await rpc.field0.respond(
        response: const qlv2.BackupShardResponse.success(),
      );
    } catch (_) {
      await rpc.field0.respond(
        response: const qlv2.BackupShardResponse.error(
          error: 'backup_shard_failed',
        ),
      );
    }
  }
}

class QLV2RestoreShardHandler
    implements QLV2RequestHandler<qlv2.InboundRpc_RestoreShard> {
  @override
  Future<void> handleRequest(
    qlv2.InboundRpc_RestoreShard rpc,
    QLConnection device,
  ) async {
    try {
      final request = rpc.field0.payload;
      final shard = await PrimeShard().getShard(
        fingerprint: Uint8List.fromList(request.seedFingerprint.field0),
        timestamp: request.timestamp,
      );
      await rpc.field0.respond(
        response: shard == null
            ? const qlv2.RestoreShardResponse.notFound()
            : qlv2.RestoreShardResponse.success(
                shard: qlv2.Shard(field0: shard),
              ),
      );
    } catch (_) {
      await rpc.field0.respond(
        response: const qlv2.RestoreShardResponse.error(
          error: 'restore_shard_failed',
        ),
      );
    }
  }
}

class QLV2PassportMagicBackupStatusHandler
    implements QLV2RequestHandler<qlv2.InboundRpc_PassportMagicBackupStatus> {
  @override
  Future<void> handleRequest(
    qlv2.InboundRpc_PassportMagicBackupStatus rpc,
    QLConnection device,
  ) async {
    try {
      final request = rpc.field0.payload;
      final shard = await PrimeShard().getShard(
        fingerprint: Uint8List.fromList(request.seedFingerprint.field0),
        timestamp: request.timestamp,
      );
      await rpc.field0.respond(
        response: qlv2.PassportMagicBackupStatusResponse(
          shardBackupFound: shard != null,
        ),
      );
    } catch (_) {
      await rpc.field0.respond(
        response: const qlv2.PassportMagicBackupStatusResponse(
          shardBackupFound: false,
        ),
      );
    }
  }
}
