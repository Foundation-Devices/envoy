// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

use std::sync::Arc;

use flutter_rust_bridge::frb;

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
