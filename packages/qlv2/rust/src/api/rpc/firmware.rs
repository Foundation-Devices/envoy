// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

use crate::api::rpc_macros::{rpc_download, rpc_request, rpc_subscription};

rpc_request!(
    FirmwareUpdateCheck,
    direction = inbound,
    route = RequestCheckFirmwareUpdate,
    params = ql_api::FirmwareUpdateCheckParams,
    response = ql_api::FirmwareUpdateCheckResponse
);

rpc_download!(
    FirmwareDownload,
    direction = inbound,
    route = DownloadFirmware,
    params = ql_api::DownloadFirmwareParams,
    header = ql_api::DownloadFirmwareHeader,
    part_header = ql_api::DownloadFirmwarePartHeader
);

rpc_subscription!(
    FirmwareInstallStatus,
    direction = outbound,
    route = SubscribeFirmwareInstallStatus,
    params = ql_api::Empty,
    event = ql_api::FirmwareInstallEvent
);
