// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

//use std::ffi::CString;
//use android_log_sys::__android_log_write;
use arti::socks;
use arti_client::config::TorClientConfigBuilder;
use arti_client::TorClient;
use lazy_static::lazy_static;
use std::io;
use tokio::runtime::{Builder, Runtime};
use tor_rtcompat::tokio::TokioNativeTlsRuntime;
use tor_rtcompat::BlockOn;

lazy_static! {
    static ref RUNTIME: io::Result<Runtime> = Builder::new_multi_thread().enable_all().build();
}

#[no_mangle]
pub unsafe extern "C" fn tor_start(socks_port: u16) -> *mut TorClient<TokioNativeTlsRuntime> {
    let runtime = TokioNativeTlsRuntime::create().unwrap();

    let state_dir = tempfile::tempdir().unwrap();
    let cache_dir = tempfile::tempdir().unwrap();
    let cfg = TorClientConfigBuilder::from_directories(state_dir, cache_dir)
        .build()
        .unwrap();

    // __android_log_write(
    //     6,
    //     CString::new("envoy").unwrap().into_raw(),
    //     CString::new("BOOTSTRAP").unwrap().into_raw(),
    // );

    let client = runtime.block_on(async {
        let res = TorClient::with_runtime(runtime.clone())
            .config(cfg)
            .create_bootstrapped()
            .await;

        res.unwrap()
    });

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

    client.runtime().block_on(client.bootstrap()).unwrap();
    true
}

// Due to its simple signature this dummy function is the one added (unused) to iOS swift codebase to force Xcode to link the lib
#[no_mangle]
pub unsafe extern "C" fn tor_hello() {
    println!("HELLO THERE");
}
