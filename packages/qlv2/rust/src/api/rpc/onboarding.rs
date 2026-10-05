// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

use crate::api::rpc_macros::rpc_subscription;

rpc_subscription!(
    OnboardingStatus,
    direction = outbound,
    route = SubscribeOnboardingStatus,
    params = ql_api::Empty,
    event = ql_api::OnboardingState
);
