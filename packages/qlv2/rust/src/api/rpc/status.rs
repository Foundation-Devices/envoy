// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

use crate::api::rpc_macros::{rpc_request, rpc_subscription};

rpc_request!(
    PassportDetails,
    direction = outbound,
    route = RequestPassportDetails,
    params = ql_api::Empty,
    response = ql_api::PassportDetailsResponse
);

rpc_subscription!(
    PassportDetailsUpdated,
    direction = outbound,
    route = SubscribePassportDetails,
    params = ql_api::Empty,
    event = ql_api::PassportDetailsResponse
);
