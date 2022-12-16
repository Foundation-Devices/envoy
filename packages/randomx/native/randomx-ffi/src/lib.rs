// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

extern crate core;

use std::convert::TryInto;
use std::ptr::null_mut;
use randomx_rs;
use randomx_rs::{RandomXCache, RandomXDataset, RandomXFlag, RandomXVM};
use std::thread;
use std::thread::JoinHandle;
use rand::Rng;
use std::time::Instant;


#[repr(C)]
pub struct RandomXHash {
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
pub unsafe extern "C" fn randomx_get(difficulty: u32) -> RandomXHash {
    //println!("{}",difficulty);

    let chunks = 4;

    let handles: Vec<JoinHandle<String>> = (0..chunks).map(|i| {
        let builder =
            thread::Builder::new().name(format!("Thread-{}", i));

        builder.spawn(move || {
            let now = Instant::now();

            let flags = RandomXFlag::get_recommended_flags() | RandomXFlag::FLAG_FULL_MEM;
            let key = "envoy";
            let input = rand::thread_rng().gen::<[u8; 16]>();
            let cache = RandomXCache::new(flags, key.as_bytes()).unwrap();
            let dataset = RandomXDataset::new(flags, cache.clone(), 0).unwrap();
            let vm = RandomXVM::new(flags, Some(cache.clone()), Some(dataset)).unwrap();

            let mut i: u128 = 0;

            loop {
                let hash_input = input;
                let hash = vm.calculate_hash(&*[hash_input, i.to_le_bytes()].concat()).expect("no data");

                let first_four_bytes: [u8; 4] = hash[0..4].try_into().unwrap();

                if u32::from_be_bytes(first_four_bytes) < (u32::MAX - difficulty) {
                    println!("Found in {}, in {:?}, after {} hashes!", thread::current().name().unwrap(), now.elapsed(), i);
                    //println!("{} < \n{}", u32::from_be_bytes(first_four_bytes), (u32::MAX - difficulty));
                    return thread::current().name().unwrap().to_owned();
                    //     return RandomXHash {
                    //         len: hash.len() as u32,
                    //         data: hash.as_ptr()
                    //     };
                };

                //println!("{:?}", hash);

                // Check if n first numbers are 0
                // if hash.iter().take(difficulty as usize).all(|&x| x == 0) {
                //     return RandomXHash {
                //         len: hash.len() as u32,
                //         data: hash.as_ptr()
                //     };
                // }
                i += 1;
            };
        }).unwrap()
    }).collect();

    // for i in 0..chunks {
    //     thread::spawn(move || {
    //
    //     });
    // }


    for h in handles {
        let _r = h.join().unwrap();
        //println!("thread done = {:?}", r);
    };


    RandomXHash {
        len: 0,
        data: null_mut(),
    }
}

// Due to its simple signature this dummy function is the one added (unused) to iOS swift codebase to force Xcode to link the lib
#[no_mangle]
pub unsafe extern "C" fn randomx_hello() {
    println!("HELLO THERE");
}
