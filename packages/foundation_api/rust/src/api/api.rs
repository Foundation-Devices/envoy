use anyhow::Error;
use bc_components::ARID;
use bc_envelope::{Envelope, Expression, SealedRequest};
use bc_envelope::prelude::{CBOREncodable, URDecodable};
use foundation_api::{AbstractEnclave, Discovery, PAIRING_FUNCTION, SecureFrom};

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

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    flutter_rust_bridge::setup_default_user_utils();
}