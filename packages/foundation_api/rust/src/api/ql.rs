// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

use anyhow::anyhow;
use anyhow::Result;
use bc_components::{PrivateKeys, ARID};
use bc_envelope::prelude::CBOREncodable;
use bc_envelope::{Envelope, EventBehavior, Expression, ExpressionBehavior};
use bc_ur::prelude::{CBORCase, CBOR};
use bc_xid::XIDDocument;
use btp::{chunk, Dechunker};
use foundation_api::message::{EnvoyMessage, PassportMessage};
use foundation_api::quantum_link::{
    generate_identity, QuantumLink, QuantumLinkIdentity, QUANTUM_LINK,
};
use gstp::SealedEvent;
use log::debug;

pub async fn get_decoder() -> Dechunker {
    Dechunker::new()
}

pub struct DecoderStatus {
    pub progress: f64,
    pub payload: Option<PassportMessage>,
}

pub async fn serialize_xid(quantum_link_identity:  &QuantumLinkIdentity) -> Vec<u8> {
   quantum_link_identity.clone().xid_document.unwrap().to_unsigned_envelope().to_cbor_data()
}

pub fn serialize_xid_document(xid_document: &XIDDocument) -> Result<Vec<u8>> {
    let envelope = xid_document.to_unsigned_envelope();
    let cbor_data = envelope.to_cbor_data();
    Ok(cbor_data)
}

pub fn deserialize_xid(data: Vec<u8>) -> Result<XIDDocument> {
    match Envelope::try_from_cbor_data(data) {
        Ok(envelope) => {
            let xid_doc = XIDDocument::from_unsigned_envelope(&envelope)?;
            Ok(xid_doc)
        }
        Err(e) => Err(anyhow!("Failed to decode XIDDocument: {:?}", e)),
    }
}

pub async fn serialize_ql_identity(quantum_link_identity: &QuantumLinkIdentity) -> Result<Vec<u8>> {
    let mut map = bc_envelope::prelude::Map::new();
    map.insert(CBOR::from("xid_document"), quantum_link_identity.clone().xid_document.unwrap());
    map.insert(CBOR::from("private_keys"), quantum_link_identity.clone().private_keys.unwrap());
    map.insert(CBOR::from("public_keys"), quantum_link_identity.clone().public_keys.unwrap());
    Ok(CBOR::from(map).to_cbor_data())
}

pub fn deserialize_ql_identity(data: Vec<u8>) -> Result<QuantumLinkIdentity> {
    let cbor = CBOR::try_from_data(data)
        .ok()
        .ok_or_else(|| anyhow::anyhow!("Invalid CBOR"))?;
    let case = cbor.into_case();

    let CBORCase::Map(map) = case else {
        return Err(anyhow::anyhow!("Invalid CBOR case"));
    };

    Ok(QuantumLinkIdentity {
        xid_document: Some(
            map.get("xid_document")
                .ok_or_else(|| anyhow::anyhow!("xid_document not found"))?,
        ),
        private_keys: Some(
            map.get("private_keys")
                .ok_or_else(|| anyhow::anyhow!("private_keys not found"))?,
        ),
        public_keys: Some(
            map.get("public_keys")
                .ok_or_else(|| anyhow::anyhow!("public_keys not found"))?,
        ),
    })
}

pub async fn decode(
    data: Vec<u8>,
    decoder: &mut Dechunker,
    quantum_link_identity: &QuantumLinkIdentity,
) -> Result<DecoderStatus> {
    debug!("receiving data");

    match decoder.receive(&data) {
        Ok(_) => {}
        Err(e) => {
            decoder.clear();
            return Err(anyhow!("Failed to receive data: {:?}", e));
        }
    };

    if decoder.is_complete() {
        debug!("We're complete!");
        let message = decoder.data().clone();
        decoder.clear();

        debug!("Trying to get envelope...");
        let envelope = match Envelope::try_from_cbor_data(message.to_owned()) {
            Ok(env) => env,
            Err(e) => {
                debug!("Failed to decode CBOR: {:?}", e);
                return Ok(DecoderStatus {
                    progress: 0.0,
                    payload: None,
                });
            }
        };
        debug!("Unsealing envelope...");

        let (passport_message, _) = PassportMessage::unseal_passport_message(
            &envelope,
            &quantum_link_identity.clone().private_keys.unwrap(),
        ).map_err(|e| {anyhow::anyhow!("Failed to unseal passport message: {:?}", e)})?;

        return Ok(DecoderStatus {
            progress: 1.0,
            payload: Some(passport_message),
        });
    }

    Ok(DecoderStatus {
        progress: 0.5,
        payload: None,
    })
}

pub async fn encode(
    message: EnvoyMessage,
    sender: &QuantumLinkIdentity,
    recipient: &XIDDocument,
) -> Vec<Vec<u8>> {
    let expression = QuantumLink::encode(&message);
    let event: SealedEvent<Expression> = SealedEvent::new(
        expression,
        ARID::new(),
        sender.clone().xid_document.unwrap(),
    );

    let envelope = event
        .to_envelope(
            None,
            Some(&sender.clone().private_keys.unwrap()),
            Some(Some(recipient)).unwrap(),
        )
        .unwrap();

    let cbor = envelope.to_cbor_data();

    let mut chunks = Vec::new();
    for chunk in chunk(&*cbor) {
        chunks.push(chunk.to_vec());
    }

    chunks
}

pub async fn generate_ql_identity() -> QuantumLinkIdentity {
    debug!("Generating identity");
    let identity = generate_identity();
    debug!("{:?}", identity);
    identity
}

#[cfg(test)]
mod tests {
    use super::*;
    use anyhow::Result;
    use tokio::test;

    #[test]
    async fn test_generate_identity() -> Result<()> {
        let identity = generate_identity();
        println!("{:?}", identity);

        Ok(())
    }
    #[tokio::test]
    async fn test_serialize_and_deserialize_xid() -> Result<()> {
        let identity = generate_ql_identity().await;
        let original_xid = identity.clone().xid_document.unwrap();

        let serialized = serialize_xid(&identity).await;
        let deserialized = deserialize_xid(serialized)?;

        let original_cbor = original_xid.to_unsigned_envelope().to_cbor_data();
        let deserialized_cbor = deserialized.to_unsigned_envelope().to_cbor_data();

        assert_eq!(original_cbor, deserialized_cbor, "CBOR mismatch after serialization/deserialization");

        Ok(())
    }
}
