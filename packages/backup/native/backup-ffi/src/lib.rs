// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

extern crate core;

use crypto_hashes::blake2::{Blake2s256, Digest};
use rand::Rng;
use std::convert::TryInto;
use std::ptr::null_mut;
use std::thread;
use std::thread::JoinHandle;
use std::time::Instant;
use mla;

#[repr(C)]
pub struct PowHash {
    len: u32,
    data: *const u8,
}

#[no_mangle]
pub unsafe extern "C" fn backup_perform(difficulty: u32) -> PowHash {
    mla::

    PowHash {
        len: 0,
        data: null_mut(),
    }
}

// Due to its simple signature this dummy function is the one added (unused) to iOS swift codebase to force Xcode to link the lib
#[no_mangle]
pub unsafe extern "C" fn backup_hello() {
    println!("HELLO THERE");
}
