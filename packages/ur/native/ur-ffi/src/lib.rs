// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

#[macro_use]
extern crate log;

use std::ffi::{CStr, CString};
use std::os::raw::c_char;
use ur::bytewords;
use ur::bytewords::Style;
use ur::UR;
use ur::{Decoder, Encoder};

mod error;

#[repr(C)]
pub struct DecoderOutput {
    progress: f64,
    message: *const CharArray,
}

#[repr(C)]
pub struct CharArray {
    len: u32,
    string: *const c_char,
}

#[no_mangle]
pub unsafe extern "C" fn backup_last_error_message() -> *const c_char {
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
pub unsafe extern "C" fn ur_encoder(
    ur_type: *const c_char,
    message: *const c_char,
    message_len: usize,
    max_fragment_len: usize,
) -> *mut Encoder<'static, 'static> {
    let ur_type = CStr::from_ptr(ur_type);

    let slice = { std::slice::from_raw_parts(message, message_len) };
    let u8_slice: &[u8] = { &*(slice as *const [c_char] as *const [u8]) };
    let mut encoder = Encoder::new();
    encoder.start(ur_type.to_str().unwrap(), u8_slice, max_fragment_len);

    let encoder_box = Box::new(encoder);
    Box::into_raw(encoder_box)
}

#[no_mangle]
pub unsafe extern "C" fn ur_encoder_next_part(
    encoder: *mut Encoder<'static, 'static>,
) -> *const c_char {
    let encoder = {
        assert!(!encoder.is_null());
        &mut *encoder
    };

    let ur = encoder.next_part();
    let c_string = CString::new(ur.to_string()).unwrap();
    c_string.into_raw()
}

#[no_mangle]
pub extern "C" fn ur_decoder() -> *mut Decoder {
    let decoder = Decoder::default();
    let decoder_box = Box::new(decoder);
    Box::into_raw(decoder_box)
}

#[no_mangle]
pub unsafe extern "C" fn ur_decoder_receive(
    decoder: *mut Decoder,
    value: *const c_char,
) -> *const DecoderOutput {
    let decoder = {
        assert!(!decoder.is_null());
        &mut *decoder
    };

    let c_string = { CStr::from_ptr(value) };
    let receive = decoder.receive(UR::parse(c_string.to_str().unwrap()).unwrap());
    match receive {
        Ok(_) => {}
        Err(e) => {
            println!("Error receiving: {:?}", e)
        }
    }

    let mut message: Vec<u8> = Vec::new();

    if decoder.is_complete() {
        message = Vec::from(decoder.message().unwrap().unwrap());
    }

    let ret = DecoderOutput {
        progress: decoder.estimated_percent_complete(),
        message: u8_to_char_array(message),
    };

    let ret_box = Box::new(ret);
    Box::into_raw(ret_box)
}

unsafe fn u8_to_char_array(message: Vec<u8>) -> *mut CharArray {
    // Drop here so data is not freed when we are out of scope
    let mut message = std::mem::ManuallyDrop::new(message);

    // Convert u8 to c_char
    let p = message.as_mut_ptr();
    let len = message.len();
    let cap = message.capacity();
    let message_c_char = { Vec::from_raw_parts(p as *mut c_char, len, cap) };

    let mut boxed_slice = message_c_char.into_boxed_slice();

    let array = boxed_slice.as_mut_ptr();
    let array_len: usize = boxed_slice.len();

    std::mem::forget(boxed_slice);

    let ret = CharArray {
        len: array_len as u32,
        string: array,
    };

    let ret_box = Box::new(ret);
    Box::into_raw(ret_box)
}

#[no_mangle]
pub unsafe extern "C" fn decode_single_part(value: *const c_char) -> *const CharArray {
    let c_string = { CStr::from_ptr(value) };

    let parsed_ur = UR::parse(&c_string.to_str().unwrap()).unwrap();
    let decoded = match bytewords::decode(parsed_ur.as_bytewords().unwrap(), Style::Minimal) {
        Ok(d) => d,
        Err(e) => {
            println!("Error decoding: {:?}", e);
            Vec::new()
        }
    };

    u8_to_char_array(decoded)
}
