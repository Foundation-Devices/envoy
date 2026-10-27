// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

use crate::api::rpc_macros::{rpc_download, rpc_request};

rpc_request!(
    Echo,
    direction = inbound,
    route = RequestEcho,
    params = ql_api::EchoParams,
    response = ql_api::EchoResponse
);

rpc_download!(
    DownloadBenchmark,
    direction = inbound,
    route = DownloadBenchmark,
    params = ql_api::DownloadBenchmarkParams,
    header = ql_api::DownloadBenchmarkHeader,
    part_header = ql_api::DownloadBenchmarkPartHeader
);
