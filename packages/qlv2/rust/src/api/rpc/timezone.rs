// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

use crate::api::rpc_macros::rpc_request;

rpc_request!(
    Timezone,
    direction = inbound,
    route = RequestTimezone,
    params = ql_api::Empty,
    response = ql_api::TimezoneResponse
);

rpc_request!(
    CurrentTime,
    direction = inbound,
    route = RequestCurrentTime,
    params = ql_api::Empty,
    response = ql_api::CurrentTimeResponse
);
