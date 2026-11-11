// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

use crate::api::rpc_macros::{rpc_download, rpc_request, rpc_subscription, rpc_upload};

rpc_request!(
    BackupShard,
    direction = inbound,
    route = RequestBackupShard,
    params = ql_api::BackupShardParams,
    response = ql_api::BackupShardResponse
);

rpc_request!(
    RestoreShard,
    direction = inbound,
    route = RequestRestoreShard,
    params = ql_api::RestoreShardParams,
    response = ql_api::RestoreShardResponse
);

rpc_subscription!(
    PassportMagicBackupEnabled,
    direction = outbound,
    route = SubscribePassportMagicBackupEnabled,
    params = ql_api::Empty,
    event = ql_api::PassportMagicBackupEnabled
);

rpc_request!(
    PassportMagicBackupStatus,
    direction = inbound,
    route = RequestPassportMagicBackupStatus,
    params = ql_api::PassportMagicBackupStatusParams,
    response = ql_api::PassportMagicBackupStatusResponse
);

rpc_upload!(
    UploadMagicBackup,
    direction = inbound,
    route = UploadMagicBackup,
    params = ql_api::UploadMagicBackupParams,
    part_header = ql_api::UploadMagicBackupPartHeader,
    response = ql_api::UploadMagicBackupResponse
);

rpc_download!(
    DownloadMagicBackup,
    direction = inbound,
    route = DownloadMagicBackup,
    params = ql_api::DownloadMagicBackupParams,
    header = ql_api::DownloadMagicBackupHeader,
    part_header = ql_api::Empty
);

rpc_subscription!(
    RestoreMagicBackupComplete,
    direction = outbound,
    route = SubscribeMagicBackupRestoreCompleted,
    params = ql_api::Empty,
    event = ql_api::MagicBackupRestoreResult
);
