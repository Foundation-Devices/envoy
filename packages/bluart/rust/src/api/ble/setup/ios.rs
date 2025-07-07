// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

use crate::api::ble::RUNTIME;
use flutter_rust_bridge::frb;

#[frb(ignore)]
pub fn create_runtime() -> anyhow::Result<()> {
    let runtime = {
        tokio::runtime::Builder::new_multi_thread()
            .enable_all()
            .on_thread_start(|| {})
            .build()
            .unwrap()
    };
    RUNTIME
        .set(runtime)
        .map_err(|_| anyhow::anyhow!("Runtime is already set"))?;
    Ok(())
}
