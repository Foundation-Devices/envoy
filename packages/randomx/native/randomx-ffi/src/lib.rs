// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

use randomx_rs;

use std::ffi::{CStr, CString};
use std::os::raw::c_char;
use std::thread;
use randomx_rs::{RandomXCache, RandomXDataset, RandomXFlag, RandomXVM};

static mut STARTED: bool = false;

#[no_mangle]
pub unsafe extern "C" fn randomx_get() -> bool {
    let flags = RandomXFlag::get_recommended_flags();
    let cache = RandomXCache::new(flags, &[0]).unwrap();
    let dataset = RandomXDataset::new(flags, &cache, 0).unwrap();
    let vm = RandomXVM::new(Default::default(), None, None).unwrap();

    false
}

// Due to its simple signature this dummy function is the one added (unused) to iOS swift codebase to force Xcode to link the lib
#[no_mangle]
pub unsafe extern "C" fn randomx_hello() {
    println!("HELLO THERE");
}
