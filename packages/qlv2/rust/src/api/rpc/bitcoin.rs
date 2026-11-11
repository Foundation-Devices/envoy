// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

use crate::api::rpc_macros::{rpc_request, rpc_subscription};

rpc_request!(
    SignPsbt,
    direction = outbound,
    route = RequestSignPsbt,
    params = ql_api::SignPsbtParams,
    response = ql_api::SignPsbtResponse
);

rpc_request!(
    BroadcastTransaction,
    direction = inbound,
    route = RequestBroadcastTransaction,
    params = ql_api::BroadcastTransactionParams,
    response = ql_api::BroadcastTransactionResponse
);

rpc_subscription!(
    AccountUpdate,
    direction = outbound,
    route = SubscribeAccountUpdated,
    params = ql_api::Empty,
    event = ql_api::AccountUpdatedEvent
);

rpc_subscription!(
    PassportActiveSeedFingerprint,
    direction = outbound,
    route = SubscribePassportActiveSeedFingerprint,
    params = ql_api::Empty,
    event = ql_api::ActiveSeedFingerprint
);

rpc_request!(
    GetPassportActiveSeedFingerprint,
    direction = outbound,
    route = RequestPassportActiveSeedFingerprint,
    params = ql_api::Empty,
    response = ql_api::ActiveSeedFingerprint
);
