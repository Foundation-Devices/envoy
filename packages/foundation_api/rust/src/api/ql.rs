use anyhow::anyhow;
use bc_components::{PrivateKeys, ARID};
use bc_envelope::{Envelope, EventBehavior, Expression, ExpressionBehavior};
use bc_envelope::prelude::CBOREncodable;
use bc_xid::XIDDocument;
use btp::{chunk, Dechunker};
use foundation_api::message::{EnvoyMessage, PassportMessage};
use foundation_api::quantum_link::{QuantumLink, QUANTUM_LINK, QuantumLinkIdentity, generate_identity};
use gstp::SealedEvent;
use log::debug;
use anyhow::Result;

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

pub async fn decode(data: Vec<u8>, decoder: &mut Dechunker, quantum_link_identity:  &QuantumLinkIdentity) -> Result<DecoderStatus> {
    debug!("receiving data");

    decoder.receive(&data)?;

    if decoder.is_complete() {
        debug!("We're complete!");
        let message = decoder.data();
        debug!("Trying to get envelope...");
        let envelope = match Envelope::try_from_cbor_data(message.to_owned()) {
            Ok(env) => {
                decoder.clear();
                env
            },
            Err(e) => {
                debug!("Failed to decode CBOR: {:?}", e);
                decoder.clear(); 
                return Ok(DecoderStatus {
                    progress: 0.0,
                    payload: None,
                });
            }
        };
        debug!("Unsealing envelope...");
        let passport_message = PassportMessage::unseal_passport_message(&envelope, &quantum_link_identity.clone().private_keys.unwrap()).unwrap();

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

pub async fn encode(message: EnvoyMessage, sender: &QuantumLinkIdentity, recipient: &XIDDocument) -> Vec<Vec<u8>> {
    let expression = QuantumLink::encode(&message);
    let event: SealedEvent<Expression> =
        SealedEvent::new(expression, ARID::new(), sender.clone().xid_document.unwrap());

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
}
