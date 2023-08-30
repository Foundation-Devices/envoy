// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

//use android_log_sys::__android_log_write;
use arti::socks;
use arti_client::config::TorClientConfigBuilder;
use arti_client::TorClient;
use lazy_static::lazy_static;
use std::ffi::{c_char, CStr, CString};
use std::{io, ptr};
use tokio::runtime::{Builder, Runtime};
use tor_rtcompat::tokio::TokioNativeTlsRuntime;
use tor_rtcompat::BlockOn;

mod error;

lazy_static! {
    static ref RUNTIME: io::Result<Runtime> = Builder::new_multi_thread().enable_all().build();
}

#[no_mangle]
pub unsafe extern "C" fn tor_last_error_message() -> *const c_char {
    let last_error = match error::take_last_error() {
        Some(err) => err,
        None => return CString::new("").unwrap().into_raw(),
    };

    let error_message = last_error.to_string();
    CString::new(error_message).unwrap().into_raw()
}

macro_rules! unwrap_or_return {
    ($a:expr,$b:expr) => {
        match $a {
            Ok(x) => x,
            Err(e) => {
                error::update_last_error(e);
                return $b;
            }
        }
    };
}

#[no_mangle]
pub unsafe extern "C" fn tor_start(
    socks_port: u16,
    state_dir: *const c_char,
    cache_dir: *const c_char,
) -> *mut TorClient<TokioNativeTlsRuntime> {
    let err_ret = ptr::null_mut();

    let state_dir = unwrap_or_return!(CStr::from_ptr(state_dir).to_str(), err_ret);
    let cache_dir = unwrap_or_return!(CStr::from_ptr(cache_dir).to_str(), err_ret);

    let runtime = unwrap_or_return!(TokioNativeTlsRuntime::create(), err_ret);

    let cfg = unwrap_or_return!(
        TorClientConfigBuilder::from_directories(state_dir, cache_dir).build(),
        err_ret
    );

    let client = unwrap_or_return!(
        runtime.block_on(async {
            TorClient::with_runtime(runtime.clone())
                .config(cfg)
                .create_bootstrapped()
                .await
        }),
        err_ret
    );

    let client_clone = client.clone();

    println!("Starting proxy!");
    let rt = RUNTIME.as_ref().unwrap();
    let handle = rt.spawn(socks::run_socks_proxy(
        runtime.clone(),
        client_clone,
        socks_port,
    ));

    let handle_box = Box::new(handle);
    Box::leak(handle_box);

    let client_box = Box::new(client);
    Box::into_raw(client_box)
}

#[no_mangle]
pub unsafe extern "C" fn tor_bootstrap(client: *mut TorClient<TokioNativeTlsRuntime>) -> bool {
    let client = {
        assert!(!client.is_null());
        &mut *client
    };

    unwrap_or_return!(client.runtime().block_on(client.bootstrap()), false);
    true
}

// Due to its simple signature this dummy function is the one added (unused) to iOS swift codebase to force Xcode to link the lib
#[no_mangle]
pub unsafe extern "C" fn tor_hello() {
    println!("HELLO THERE");
}
