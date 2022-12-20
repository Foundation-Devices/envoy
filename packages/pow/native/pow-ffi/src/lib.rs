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

#[repr(C)]
pub struct PowHash {
    len: u32,
    data: *const u8,
}

// 1. GET backup_challenge

// 2. JSON
// input -- random data
// key -- string
// difficulty -- int
// timestamp -- utc timedate
// signature -- input + key + difficulty + timestamp

// 3. JSON
// input
// key
// difficulty
// timestamp
// signature
// proof --> 640 byte
// backup data --> ? bytes --> upsert

#[no_mangle]
pub unsafe extern "C" fn pow_get(difficulty: u32) -> PowHash {
    let chunks = 4;

    let handles: Vec<JoinHandle<String>> = (0..chunks)
        .map(|i| {
            let builder = thread::Builder::new().name(format!("Thread-{}", i));

            builder
                .spawn(move || {
                    let now = Instant::now();

                    let input: [u8; 16] = rand::thread_rng().gen();

                    //let challenge = Vec::from(input);

                    let mut i: u128 = 0;

                    loop {
                        let mut hasher = Blake2s256::new();
                        hasher.update([input, i.to_le_bytes()].concat());
                        let hash = hasher.finalize();
                        let first_four_bytes: [u8; 4] = hash[0..4].try_into().unwrap();

                        if u32::from_be_bytes(first_four_bytes) < (u32::MAX - difficulty) {
                            println!(
                                "Found in {}, in {:?}, after {} hashes!",
                                thread::current().name().unwrap(),
                                now.elapsed(),
                                i
                            );
                            //println!("{} < \n{}", u32::from_be_bytes(first_four_bytes), (u32::MAX - difficulty));
                            return thread::current().name().unwrap().to_owned();
                        };
                        i += 1;
                    }
                })
                .unwrap()
        })
        .collect();

    // for i in 0..chunks {
    //     thread::spawn(move || {
    //
    //     });
    // }

    for h in handles {
        let _r = h.join().unwrap();
        //println!("thread done = {:?}", r);
    }

    PowHash {
        len: 0,
        data: null_mut(),
    }
}

// Due to its simple signature this dummy function is the one added (unused) to iOS swift codebase to force Xcode to link the lib
#[no_mangle]
pub unsafe extern "C" fn pow_hello() {
    println!("HELLO THERE");
}
