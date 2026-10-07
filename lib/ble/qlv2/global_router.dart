// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ble/qlv2/handlers/current_time_handler.dart';
import 'package:envoy/ble/qlv2/handlers/broadcast_transaction_handler.dart';
import 'package:envoy/ble/qlv2/handlers/exchange_rate_handler.dart';
import 'package:envoy/ble/qlv2/handlers/firmware_handler.dart';
import 'package:envoy/ble/qlv2/handlers/magic_backup_handler.dart';
import 'package:envoy/ble/qlv2/handlers/shards_handler.dart';
import 'package:envoy/ble/qlv2/handlers/timezone_handler.dart';
import 'package:envoy/ble/qlv2/rpc_dispatcher.dart';
import 'package:qlv2/qlv2.dart' as qlv2;

QLV2RpcRouter buildQLV2GlobalRouter({
  required QLV2FirmwareEvents firmwareEvents,
}) {
  return QLV2RpcRouter.builder()
      .request<qlv2.InboundRpc_Timezone>(
        QLV2TimeZoneHandler(),
        debugName: "global.timezone",
      )
      .request<qlv2.InboundRpc_CurrentTime>(
        QLV2CurrentTimeHandler(),
        debugName: "global.current_time",
      )
      .request<qlv2.InboundRpc_BroadcastTransaction>(
        QLV2BroadcastTransactionHandler(),
        debugName: "global.broadcast_transaction",
      )
      .subscription<qlv2.InboundRpc_ExchangeRateSubscription>(
        QLV2ExchangeRateSubscriptionHandler(),
        debugName: "global.exchange_rate_subscription",
      )
      .request<qlv2.InboundRpc_ExchangeRateHistory>(
        QLV2ExchangeRateHistoryHandler(),
        debugName: "global.exchange_rate_history",
      )
      .request<qlv2.InboundRpc_FirmwareUpdateCheck>(
        QLV2FirmwareUpdateCheckHandler(events: firmwareEvents),
        debugName: "global.firmware_update_check",
      )
      .download<qlv2.InboundRpc_FirmwareDownload>(
        QLV2FirmwareDownloadHandler(events: firmwareEvents),
        debugName: "global.firmware_download",
      )
      .upload<qlv2.InboundRpc_UploadMagicBackup>(
        QLV2MagicBackupUploadHandler(),
        debugName: "global.upload_magic_backup",
      )
      .download<qlv2.InboundRpc_DownloadMagicBackup>(
        QLV2MagicBackupDownloadHandler(),
        debugName: "global.download_magic_backup",
      )
      .request<qlv2.InboundRpc_BackupShard>(
        QLV2BackupShardHandler(),
        debugName: "global.backup_shard",
      )
      .request<qlv2.InboundRpc_RestoreShard>(
        QLV2RestoreShardHandler(),
        debugName: "global.restore_shard",
      )
      .request<qlv2.InboundRpc_PassportMagicBackupStatus>(
        QLV2PassportMagicBackupStatusHandler(),
        debugName: "global.passport_magic_backup_status",
      )
      .build();
}
