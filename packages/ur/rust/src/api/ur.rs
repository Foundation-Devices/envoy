// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

use flutter_rust_bridge::frb;
use foundation_ur::bytewords;
use foundation_ur::bytewords::Style;
use foundation_ur::UR;
use foundation_ur::{Decoder, Encoder};
use std::sync::Mutex;

#[frb(init)]
pub fn init_app() {
    flutter_rust_bridge::setup_default_user_utils();
}

/// Output from decoder containing progress and decoded message
pub struct DecoderOutput {
    pub progress: f64,
    pub message: Vec<u8>,
}

/// UR Encoder wrapper for Flutter Rust Bridge
pub struct UrEncoderWrapper {
    encoder: Mutex<Encoder<'static, 'static>>,
}

impl UrEncoderWrapper {
    #[frb(sync)]
    pub fn new(ur_type: String, message: Vec<u8>, max_fragment_len: usize) -> UrEncoderWrapper {
        let mut encoder = Encoder::new();
        // We need to leak the data to get 'static lifetime
        let ur_type_static: &'static str = Box::leak(ur_type.into_boxed_str());
        let message_static: &'static [u8] = Box::leak(message.into_boxed_slice());
        encoder.start(ur_type_static, message_static, max_fragment_len);
        UrEncoderWrapper {
            encoder: Mutex::new(encoder),
        }
    }

    #[frb(sync)]
    pub fn next_part(&self) -> String {
        let mut encoder = self.encoder.lock().unwrap();
        let ur = encoder.next_part();
        ur.to_string()
    }
}

/// UR Decoder wrapper for Flutter Rust Bridge
pub struct UrDecoderWrapper {
    decoder: Mutex<Decoder>,
}

impl UrDecoderWrapper {
    #[frb(sync)]
    pub fn new() -> UrDecoderWrapper {
        UrDecoderWrapper {
            decoder: Mutex::new(Decoder::default()),
        }
    }

    #[frb(sync)]
    pub fn receive(&self, value: String) -> Result<DecoderOutput, String> {
        let mut decoder = self.decoder.lock().unwrap();

        let ur = UR::parse(&value).map_err(|e| e.to_string())?;
        decoder.receive(ur).map_err(|e| e.to_string())?;

        let message = if decoder.is_complete() {
            decoder
                .message()
                .map_err(|e| e.to_string())?
                .map(|m| m.to_vec())
                .unwrap_or_default()
        } else {
            Vec::new()
        };

        Ok(DecoderOutput {
            progress: decoder.estimated_percent_complete(),
            message,
        })
    }
}

/// Decode a single-part UR
#[frb(sync)]
pub fn decode_single_part(value: String) -> Result<Vec<u8>, String> {
    let parsed_ur = UR::parse(&value).map_err(|e| e.to_string())?;
    let bytewords = parsed_ur
        .as_bytewords()
        .ok_or_else(|| "No bytewords in UR".to_string())?;
    bytewords::decode(bytewords, Style::Minimal).map_err(|e| format!("Error decoding: {e:?}"))
}
