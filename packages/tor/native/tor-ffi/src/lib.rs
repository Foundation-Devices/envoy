// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

use arti::socks;
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
    //let config = TorClientConfig::default();

    println!("BOOTSTRAPPING CLIENT!");
    let client = runtime.block_on(async {
        TorClient::with_runtime(runtime.clone())
            .create_bootstrapped()
            .await
            .unwrap()
    });
    println!("BOOTSTRAPPED!");

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
    println!("SOCKS PORT: {}", socks_port);

    Box::into_raw(client_box)
}

#[no_mangle]
pub unsafe extern "C" fn tor_bootstrap(client: *mut TorClient<TokioNativeTlsRuntime>) -> bool {
    let client = {
        assert!(!client.is_null());
        &mut *client
    };

    client.runtime().block_on(client.bootstrap()).unwrap();
    println!("BOOTSTRAPPED!");
    true
}

// Due to its simple signature this dummy function is the one added (unused) to iOS swift codebase to force Xcode to link the lib
#[no_mangle]
pub unsafe extern "C" fn tor_hello() {
    println!("HELLO THERE");
}
