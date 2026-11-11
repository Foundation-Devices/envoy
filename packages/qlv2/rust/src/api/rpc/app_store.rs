// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

use crate::api::rpc_macros::{rpc_download, rpc_request};

rpc_request!(
    ListApps,
    direction = inbound,
    route = RequestListApps,
    params = ql_api::Empty,
    response = ql_api::ListAppsResponse
);

rpc_download!(
    AppDownload,
    direction = inbound,
    route = DownloadApp,
    params = ql_api::DownloadAppParams,
    header = ql_api::DownloadAppHeader,
    part_header = ql_api::DownloadAppPartHeader
);
