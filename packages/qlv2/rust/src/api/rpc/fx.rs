// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

use crate::api::rpc_macros::{rpc_request, rpc_subscription};

rpc_subscription!(
    ExchangeRateSubscription,
    direction = inbound,
    route = SubscribeExchangeRate,
    params = ql_api::ExchangeRateParams,
    event = ql_api::ExchangeRate
);

rpc_request!(
    ExchangeRateHistory,
    direction = inbound,
    route = RequestExchangeRateHistory,
    params = ql_api::ExchangeRateHistoryParams,
    response = ql_api::ExchangeRateHistory
);

rpc_subscription!(
    PassportFiatPreference,
    direction = outbound,
    route = SubscribePassportFiatPreference,
    params = ql_api::Empty,
    event = ql_api::PassportFiatPreferenceEvent
);
