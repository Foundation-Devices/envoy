use anyhow::anyhow;
use bc_components::{PrivateKeys, ARID};
use bc_envelope::{Envelope, EventBehavior, Expression, ExpressionBehavior};
use bc_envelope::prelude::CBOREncodable;
use bc_xid::XIDDocument;
use btp::{chunk, Dechunker};
use foundation_api::message::{EnvoyMessage, PassportMessage};
use foundation_api::quantum_link::{QuantumLink, QUANTUM_LINK, QuantumLinkIdentity, generate_identity};
use gstp::SealedEvent;

pub async fn get_decoder() -> Dechunker {
    Dechunker::new()
}

pub struct DecoderStatus {
    pub progress: f64,
    pub payload: Option<PassportMessage>,
}

pub async fn decode(data: Vec<u8>, decoder: &mut Dechunker, quantum_link_identity:  &QuantumLinkIdentity) -> anyhow::Result<DecoderStatus> {
    decoder.receive(&data)?;


    if decoder.is_complete() {
        let message = decoder.data();
        let envelope = Envelope::try_from_cbor_data(message.to_owned())?;
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

pub async fn encode(message: EnvoyMessage, sender: QuantumLinkIdentity, recipient: &XIDDocument) -> Vec<Vec<u8>> {
    let expression = QuantumLink::encode(&message);
    let event: SealedEvent<Expression> =
        SealedEvent::new(expression, ARID::new(), sender.clone().xid_document.unwrap());

    let envelope = event
        .to_envelope(
            None,
            Some(&sender.private_keys.unwrap()),
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
    generate_identity()
}
