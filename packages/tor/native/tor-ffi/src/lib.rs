// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

use tor_sys::*;

use std::ffi::{CStr, CString};
use std::os::raw::c_char;
use std::thread;

static mut STARTED: bool = false;

#[no_mangle]
pub unsafe extern "C" fn tor_start(conf_path: *const c_char) -> bool {
    if !STARTED {
        STARTED = true;
        let path = CStr::from_ptr(conf_path).to_str().unwrap();
        thread::spawn(move || {
            let config = tor_main_configuration_new();
            let argv = vec![
                CString::new("tor").unwrap(),
                CString::new("-f").unwrap(),
                CString::new(path).unwrap(),
            ];
            let argv: Vec<_> = argv.iter().map(|s| s.as_ptr()).collect();
            tor_main_configuration_set_command_line(config, argv.len() as i32, argv.as_ptr());
            tor_run_main(config);
            tor_main_configuration_free(config);
            STARTED = false;
        });
        return true;
    }
    false
}

// Due to its simple signature this dummy function is the one added (unused) to iOS swift codebase to force Xcode to link the lib
#[no_mangle]
pub unsafe extern "C" fn tor_hello() {
    println!("HELLO THERE");
}
