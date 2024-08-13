use anyhow::{bail, Error};
use bc_components::ARID;
use bc_envelope::{Envelope, Expression, ResponseBehavior, SealedRequest, SealedResponse};
use bc_envelope::prelude::{CBOREncodable, CBORTaggedEncodable, URDecodable};
use foundation_api::{Discovery, PAIRING_FUNCTION, PairingResponse};
use foundation_abstracted::{AbstractEnclave, SecureFrom, SecureTryFrom};

use crate::enclave::Enclave;

pub fn extract_discovery(qr_code: String) -> anyhow::Result<Discovery> {
    match Envelope::from_ur_string(qr_code) {
        Ok(e) => {
            let inner = e.unwrap_envelope()?;
            let discovery = Discovery::try_from(Expression::try_from(inner)?)?;
            let sender = discovery.sender();
            e.verify(sender)?;

            Ok(discovery)
        }
        Err(e) => Err(e)
    }
}

pub async fn pair(discovery_qr: String) -> Result<Vec<u8>, Error> {
    let envelope = Envelope::from_ur_string(discovery_qr).unwrap();
    let inner = envelope.unwrap_envelope()?;
    let discovery = Discovery::try_from(Expression::try_from(inner)?)?;

    let enclave = Enclave::new();

    let body = Expression::new(PAIRING_FUNCTION);
    let request = SealedRequest::new_with_body(body, ARID::new(), enclave.public_key());
    let sent_envelope = Envelope::secure_from((request, discovery.sender()), &enclave);

    Ok(sent_envelope.to_cbor_data())
}

pub async fn decode_pairing_response(response: Vec<u8>) -> anyhow::Result<PairingResponse>{
    let envelope = Envelope::try_from_cbor_data(response)?;
    let response = SealedResponse::secure_try_from(envelope, &Enclave::new())?;
    // TODO: verify that the response is from a paired device

    let result = response.result()?;
    let pairing = PairingResponse::try_from(result.tagged_cbor())?;
    Ok(pairing)
}

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    flutter_rust_bridge::setup_default_user_utils();
}