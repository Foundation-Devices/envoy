use bc_envelope::base::envelope;
use bc_envelope::prelude::*;
use flutter_rust_bridge::for_generated::anyhow;
use foundation_ur::{Decoder, UR};

#[flutter_rust_bridge::frb(sync)] // Synchronous mode for simplicity of the demo
pub fn greet(name: String) -> String {
    format!("Hello, {name}!")
}

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    flutter_rust_bridge::setup_default_user_utils();
}

pub async fn get_decoder() -> MultipartDecoder {
    MultipartDecoder::new()
}

pub struct DecoderStatus {
    pub progress: f64,
    pub payload: Option<Envelope>,
}

pub async fn decode_qr(qr: String, decoder: &mut MultipartDecoder) -> anyhow::Result<DecoderStatus> {
    decoder.receive(&*qr)?;

    if decoder.is_complete() {
        let ur = decoder.message()?.unwrap();
        let envelope = Envelope::from_ur(ur)?;

        return Ok(DecoderStatus {
            progress: 1.0,
            payload: Some(envelope),
        });
    }

    Ok(DecoderStatus {
        progress: 0.5,
        payload: None,
    })
}

// Only after user presses 'continue'
pub fn pair_device(envelope: Envelope) {
    
}
