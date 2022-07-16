use std::ffi::{CStr, CString};
use std::os::raw::c_char;
use ur::ur::decode;
use ur::ur::{Decoder, Encoder};

#[repr(C)]
pub struct StringArray {
    len: u32,
    strings: *const *const c_char,
}

#[repr(C)]
pub struct CharArray {
    len: u32,
    string: *const c_char,
}

#[no_mangle]
pub unsafe extern "C" fn ur_encoder(
    ur_type: *const c_char,
    message: *const c_char,
    message_len: usize,
    max_fragment_len: usize,
) -> *mut Encoder {
    let ur_type = CStr::from_ptr(ur_type);

    let slice = { std::slice::from_raw_parts(message, message_len) };
    let u8_slice: &[u8] = { &*(slice as *const [c_char] as *const [u8]) };
    let encoder = Encoder::new(u8_slice, max_fragment_len, ur_type.to_str().unwrap()).unwrap();
    let encoder_box = Box::new(encoder);
    Box::into_raw(encoder_box)
}

#[no_mangle]
pub unsafe extern "C" fn ur_encoder_next_part(encoder: *mut Encoder) -> *const c_char {
    let encoder = {
        assert!(!encoder.is_null());
        &mut *encoder
    };

    let part = encoder.next_part().unwrap();
    let c_string = CString::new(part).unwrap();
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
) -> *const CharArray {
    let decoder = {
        assert!(!decoder.is_null());
        &mut *decoder
    };

    let c_string = { CStr::from_ptr(value) };
    let receive = decoder.receive(c_string.to_str().unwrap());
    match receive {
        Ok(_) => {}
        Err(e) => {
            println!("Error receiving: {:?}", e)
        }
    }

    let mut message: Vec<u8> = Vec::new();

    if decoder.complete() {
        message = decoder.message().unwrap().unwrap();
    }

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
    let decoded = match decode(c_string.to_str().unwrap()) {
        Ok(d) => d,
        Err(e) => {
            println!("Error decoding: {:?}", e);
            Vec::new()
        }
    };

    // Drop here so data is not freed when we are out of scope
    let mut message = std::mem::ManuallyDrop::new(decoded);

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
