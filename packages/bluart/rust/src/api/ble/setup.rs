// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

#[cfg(target_os = "android")]
use flutter_rust_bridge::frb;

#[cfg(target_os = "android")]
mod android;

#[cfg(target_os = "android")]
#[frb(ignore)]
#[no_mangle]
pub extern "C" fn JNI_OnLoad(vm: jni::JavaVM, res: *const std::os::raw::c_void) -> jni::sys::jint {
    let _res = res;
    let env = vm.get_env().unwrap();
    jni_utils::init(&env).unwrap();
    btleplug::platform::init(&env).unwrap();
    let _ = android::JAVAVM.set(vm);
    jni::JNIVersion::V6.into()
}

#[cfg(target_os = "ios")]
mod ios;

use std::sync::OnceLock;
use tokio::runtime::Runtime;

pub static RUNTIME: OnceLock<Runtime> = OnceLock::new();
// use super::Error;

pub fn create_runtime() -> anyhow::Result<()> {
    #[cfg(target_os = "android")]
    android::create_runtime()?;
    #[cfg(target_os = "ios")]
    ios::create_runtime()?;
    #[cfg(not(any(target_os = "android", target_os = "ios")))]
    {
        use std::sync::atomic::{AtomicUsize, Ordering};

        info!("Create runtime");

        let runtime = tokio::runtime::Builder::new_multi_thread()
            .enable_all()
            .thread_name_fn(|| {
                static ATOMIC_ID: AtomicUsize = AtomicUsize::new(0);
                let id = ATOMIC_ID.fetch_add(1, Ordering::SeqCst);
                format!("bluart-thread-{}", id)
            })
            .on_thread_stop(move || {
                info!("Stopping runtime thread");
            })
            .build()
            .unwrap();
        RUNTIME
            .set(runtime)
            .map_err(|_| anyhow::anyhow!("Runtime is already set"))?;
    }
    Ok(())
}
