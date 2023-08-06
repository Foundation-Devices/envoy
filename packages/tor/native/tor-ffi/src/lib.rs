// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

//use tor_sys::*;

use std::ffi::{CStr, CString};
use std::os::raw::c_char;
use std::thread;
//use lazy_static::lazy_static;
use tokio::runtime::{Builder, Runtime};
use std::{io, ptr};
use std::future::Future;
use std::ops::Deref;
use arti_client::{TorClient, TorClientConfig};
use arti_client::BootstrapBehavior::OnDemand;
use arti::socks;
use lazy_static::lazy_static;
use tor_rtcompat::BlockOn;
use tor_rtcompat::tokio::TokioNativeTlsRuntime;

// static mut STARTED: bool = false;
//

// lazy_static! {
//     static ref RUNTIME: TokioNativeTlsRuntime = TokioNativeTlsRuntime::create().unwrap();
// }

lazy_static! {
    static ref RUNTIME: io::Result<Runtime> = Builder::new_multi_thread().enable_all().build();
}

type PinnedFuture<T> = std::pin::Pin<Box<dyn Future<Output=T>>>;

#[no_mangle]
pub unsafe extern "C" fn tor_start(socks_port: u16) -> *mut TorClient<TokioNativeTlsRuntime> {
    //process::use_max_file_limit(&config);

    let runtime = TokioNativeTlsRuntime::create().unwrap();
    //let config = TorClientConfig::default();

    println!("BOOTSTRAPPING CLIENT!");
    let client = runtime.block_on(async { TorClient::with_runtime(runtime.clone()).create_bootstrapped().await.unwrap() });
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


    // Box::pin(async {
    //
    // });

    // let proxy = Box::pin(async {
    //     socks::run_socks_proxy(
    //         runtime.clone(),
    //         client_clone,
    //         socks_port,
    //     ).await
    // });

    let client_box = Box::new(client);

    println!("SOCKS PORT: {}", socks_port);

    Box::into_raw(client_box)


    // if !STARTED {
    //     STARTED = true;
    //     let path = CStr::from_ptr(conf_path).to_str().unwrap();
    //     thread::spawn(move || {
    //         let config = tor_main_configuration_new();
    //         let argv = vec![
    //             CString::new("tor").unwrap(),
    //             CString::new("-f").unwrap(),
    //             CString::new(path).unwrap(),
    //         ];
    //         let argv: Vec<_> = argv.iter().map(|s| s.as_ptr()).collect();
    //         tor_main_configuration_set_command_line(config, argv.len() as i32, argv.as_ptr());
    //         tor_run_main(config);
    //         tor_main_configuration_free(config);
    //         STARTED = false;
    //     });
    //     return true;
    // }
    // false
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
