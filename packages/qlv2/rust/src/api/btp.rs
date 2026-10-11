// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

use anyhow::Result;
use flutter_rust_bridge::frb;
use ql_btp::{chunk, Dechunker};

#[frb(opaque)]
pub struct BtpDechunker {
    inner: Dechunker,
}

pub fn get_decoder() -> BtpDechunker {
    BtpDechunker {
        inner: Dechunker::default(),
    }
}

pub struct DecoderStatus {
    pub progress: f64,
    pub payload: Option<Vec<u8>>,
}

pub fn decode(data: Vec<u8>, decoder: &mut BtpDechunker) -> Result<DecoderStatus> {
    let payload = decoder.inner.receive(&data)?;
    Ok(DecoderStatus {
        progress: if payload.is_some() { 1.0 } else { 0.0 },
        payload,
    })
}

pub fn encode(data: &[u8]) -> Vec<Vec<u8>> {
    let mut chunks = Vec::new();
    for chunk in chunk(data) {
        chunks.push(chunk.to_vec());
    }
    chunks
}

#[cfg(test)]
mod tests {
    use super::{decode, encode, get_decoder};

    #[test]
    fn encodes_a_single_chunk_record() {
        assert_eq!(encode(&[1]).len(), 1);
    }

    #[test]
    fn reassembles_a_multi_chunk_record() {
        let payload = vec![42; 4096];
        let chunks = encode(&payload);
        assert!(chunks.len() > 1);

        let mut decoder = get_decoder();
        let mut decoded = None;
        for chunk in chunks {
            decoded = decode(chunk, &mut decoder).unwrap().payload;
        }

        assert_eq!(decoded, Some(payload));
    }
}
