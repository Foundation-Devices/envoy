// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

#[macro_use]
extern crate log;

use allo_isolate::Isolate;
use lazy_static::lazy_static;
use reqwest::header::HeaderMap;
use std::cell::RefCell;
use std::cmp::min;
use std::error::Error;
use std::ffi::{CStr, CString};
use std::fs::File;
use std::io::Write;
use std::os::raw::c_char;
use std::time::Duration;
use std::{io, ptr};
use tokio::runtime::{Builder, Runtime};
use tokio::task::JoinHandle;
use tokio::time;

#[repr(C)]
pub enum Verb {
    Get,
    Post,
}

#[repr(C)]
pub struct HttpResponse {
    status_code: i32,
    body_len: u32,
    body: *const u8,
}

thread_local! {
    static LAST_ERROR: RefCell<Option<Box<dyn Error>>> = RefCell::new(None);
}

/// Update the most recent error, clearing whatever may have been there before.
pub fn update_last_error<E: Error + 'static>(err: E) {
    error!("Setting LAST_ERROR: {}", err);
    {
        // Print a pseudo-backtrace for this error, following back each error's
        // cause until we reach the root error.
        let mut cause = err.source();
        while let Some(parent_err) = cause {
            warn!("Caused by: {}", parent_err);
            cause = parent_err.source();
        }
    }

    LAST_ERROR.with(|prev| {
        *prev.borrow_mut() = Some(Box::new(err));
    });
}

/// Retrieve the most recent error, clearing it in the process.
pub fn take_last_error() -> Option<Box<dyn Error>> {
    LAST_ERROR.with(|prev| prev.borrow_mut().take())
}

#[no_mangle]
pub unsafe extern "C" fn http_last_error_message() -> *const c_char {
    let last_error = match take_last_error() {
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
                update_last_error(e);
                return $b;
            }
        }
    };
}

lazy_static! {
    static ref RUNTIME: io::Result<Runtime> = Builder::new_multi_thread().enable_all().build();
}

#[no_mangle]
pub unsafe extern "C" fn http_get_file_cancel(handle: *mut JoinHandle<()>) {
    let handle = {
        assert!(!handle.is_null());
        &mut *handle
    };

    handle.abort();
}

#[no_mangle]
pub unsafe extern "C" fn http_get_file(
    path: *const c_char,
    url: *const c_char,
    tor_port: i32,
    isolate_port: i64,
) -> *mut JoinHandle<()> {
    let path = CStr::from_ptr(path).to_str().unwrap();
    let url = CStr::from_ptr(url).to_str().unwrap();
    let client: reqwest::Client;

    if tor_port > 0 {
        let proxy =
            reqwest::Proxy::all("socks5://127.0.0.1:".to_owned() + &tor_port.to_string()).unwrap();
        client = reqwest::Client::builder().proxy(proxy).build().unwrap();
    } else {
        client = reqwest::Client::builder().build().unwrap();
    }

    let rt = RUNTIME.as_ref().unwrap();

    let handle = rt.spawn(http_get_file_async(path, url, client, isolate_port));
    let handle_box = Box::new(handle);
    Box::into_raw(handle_box)
}

#[no_mangle]
async fn http_get_file_async(path: &str, url: &str, client: reqwest::Client, isolate_port: i64) {
    let mut res = client.get(url).send().await.unwrap();

    let total_size = res.content_length().unwrap();
    let mut file = File::create(path).unwrap();
    let mut downloaded: u64 = 0;

    let isolate = Isolate::new(isolate_port);

    while let Some(chunk) = res.chunk().await.unwrap() {
        file.write(&chunk).unwrap();
        let new_size = min(downloaded + (chunk.len() as u64), total_size);
        downloaded = new_size;

        // Send progress to Dart via Isolate
        isolate.post(format!("{}/{}", new_size, total_size));

        // An opportunity to kill it
        time::sleep(Duration::from_secs(0)).await;
    }
}

#[no_mangle]
pub unsafe extern "C" fn http_request(
    verb: Verb,
    url: *const c_char,
    tor_port: i32,
    body: *const c_char,
    header_number: u8,
    headers: *const *const c_char,
) -> HttpResponse {
    let err_ret = HttpResponse {
        status_code: 0,
        body_len: 0,
        body: ptr::null(),
    };

    let url = unwrap_or_return!(CStr::from_ptr(url).to_str(), err_ret);

    let client: reqwest::blocking::Client;

    if tor_port > 0 {
        let proxy = unwrap_or_return!(
            reqwest::Proxy::all("socks5://127.0.0.1:".to_owned() + &tor_port.to_string()),
            err_ret
        );
        client = unwrap_or_return!(
            reqwest::blocking::Client::builder().proxy(proxy).build(),
            err_ret
        );
    } else {
        client = unwrap_or_return!(reqwest::blocking::Client::builder().build(), err_ret);
    }

    let body = unwrap_or_return!(CStr::from_ptr(body).to_str(), err_ret);

    let mut header_map = HeaderMap::new();

    for i in 0..header_number {
        let key = unwrap_or_return!(
            CStr::from_ptr(*headers.offset(i as isize)).to_str(),
            err_ret
        );
        let value = unwrap_or_return!(
            CStr::from_ptr(*headers.offset((i + 1) as isize)).to_str(),
            err_ret
        );
        header_map.append(key, unwrap_or_return!(value.parse(), err_ret));
    }

    let request = match verb {
        Verb::Get => client.get(url),
        Verb::Post => client.post(url),
    };

    let response = unwrap_or_return!(request.body(body).headers(header_map).send(), err_ret);

    let status_code = response.status().as_u16();
    let body = unwrap_or_return!(response.bytes(), err_ret);
    let body_len = body.len();
    let body_ptr = body.as_ptr();

    // Freed on Dart side
    std::mem::forget(body);

    HttpResponse {
        status_code: status_code as i32,
        body_len: body_len as u32,
        body: body_ptr,
    }
}

#[no_mangle]
pub unsafe extern "C" fn http_post(uri: *const c_char) {
    let path = CStr::from_ptr(uri).to_str().unwrap();
    println!("{}", path);
}

#[no_mangle]
pub unsafe extern "C" fn http_get_ip(tor_port: i32) -> *const c_char {
    let client: reqwest::blocking::Client;

    if tor_port > 0 {
        let proxy =
            reqwest::Proxy::all("socks5://127.0.0.1:".to_owned() + &tor_port.to_string()).unwrap();
        client = reqwest::blocking::Client::builder()
            .proxy(proxy)
            .build()
            .unwrap();
    } else {
        client = reqwest::blocking::Client::builder().build().unwrap();
    }

    let response = client.get("https://icanhazip.com").send().unwrap();
    CString::new(response.text().unwrap()).unwrap().into_raw()
}

// For sanity checking
// Also - due to its simple signature this function is the one added (unused) to iOS swift codebase to force Xcode to link the lib
#[no_mangle]
pub unsafe extern "C" fn http_hello() {
    let proxy = reqwest::Proxy::all("socks5://127.0.0.1:9050").unwrap();
    let client = reqwest::blocking::Client::builder()
        .proxy(proxy)
        .build()
        .unwrap();

    let response = client.get("https://icanhazip.com").send().unwrap();

    println!("IP address: {}", response.text().unwrap());
}
