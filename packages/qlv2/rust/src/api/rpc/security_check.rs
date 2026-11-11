// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

use crate::api::rpc_macros::rpc_duplex;

rpc_duplex!(
    SecurityCheck,
    direction = inbound,
    route = RunSecurityCheck,
    initiator = ql_api::RunSecurityCheckInitiatorEvent,
    responder = ql_api::RunSecurityCheckResponderEvent
);
