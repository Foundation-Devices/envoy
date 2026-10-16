// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

use std::sync::Arc;

use flutter_rust_bridge::frb;
use ql_common::ResetCode;
use ql_rpc::RpcError;
use ql_runtime::QlStreamError;

use crate::frb_generated::StreamSink;

pub mod app_store;
pub mod backup;
pub mod benchmark;
pub mod bitcoin;
pub mod firmware;
pub mod fx;
pub mod onboarding;
pub mod security_check;
pub mod status;
pub mod timezone;

pub use app_store::*;
pub use backup::*;
pub use benchmark::*;
pub use bitcoin::*;
pub use firmware::*;
pub use fx::*;
pub use ql_api::*;
pub use security_check::*;
pub use timezone::*;

#[derive(Debug, PartialEq, Eq)]
pub enum SubscriptionError {
    Unsupported,
    Failed(String),
}

impl std::fmt::Display for SubscriptionError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Self::Unsupported => f.write_str("subscription is not supported"),
            Self::Failed(message) => f.write_str(message),
        }
    }
}

impl std::error::Error for SubscriptionError {}

impl From<RpcError<ql_api::Error, QlStreamError>> for SubscriptionError {
    fn from(error: RpcError<ql_api::Error, QlStreamError>) -> Self {
        match error {
            RpcError::Transport(QlStreamError::StreamReset { code, .. })
                if code == ResetCode::UNKNOWN_ROUTE =>
            {
                Self::Unsupported
            }
            error => Self::Failed(error.to_string()),
        }
    }
}

#[frb(non_opaque)]
pub enum InboundRpc {
    // App store
    ListApps(InboundRequestListApps),
    AppDownload(InboundDownloadApp),

    // Passport details and setup
    Timezone(InboundRequestTimezone),

    // Security and onboarding
    SecurityCheck(InboundRunSecurityCheck),

    // Firmware
    FirmwareUpdateCheck(InboundRequestCheckFirmwareUpdate),
    FirmwareDownload(InboundDownloadFirmware),

    // Market data
    ExchangeRateSubscription(InboundSubscribeExchangeRate),
    ExchangeRateHistory(InboundRequestExchangeRateHistory),
    CurrentTime(InboundRequestCurrentTime),

    // Bitcoin and wallet
    BroadcastTransaction(InboundRequestBroadcastTransaction),

    // Backup
    BackupShard(InboundRequestBackupShard),
    RestoreShard(InboundRequestRestoreShard),
    PassportMagicBackupStatus(InboundRequestPassportMagicBackupStatus),
    UploadMagicBackup(InboundUploadMagicBackup),
    DownloadMagicBackup(InboundDownloadMagicBackup),

    // Debug and benchmarks
    Echo(InboundRequestEcho),
    DownloadBenchmark(InboundDownloadBenchmark),
}

#[derive(Clone)]
pub struct RouterState {
    pub inner: Arc<StreamSink<InboundRpc>>,
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn unknown_subscription_route_is_reported_as_unsupported() {
        let error = RpcError::Transport(QlStreamError::StreamReset {
            code: ResetCode::UNKNOWN_ROUTE,
            origin: ql_runtime::ResetOrigin::Peer,
        });

        assert_eq!(
            SubscriptionError::from(error),
            SubscriptionError::Unsupported
        );
    }

    #[test]
    fn other_subscription_failures_remain_retryable() {
        let error = RpcError::Transport(QlStreamError::NoSession);

        assert_eq!(
            SubscriptionError::from(error),
            SubscriptionError::Failed("no session".to_owned())
        );
    }
}
