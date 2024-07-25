use std::sync::mpsc::channel;

use bc_envelope::{Envelope, Expression, ResponseBehavior};
use bc_envelope::prelude::{CBOREncodable, URDecodable};
use foundation_api::{AbstractBluetoothChannel, AbstractEnclave, BluetoothEndpoint, Discovery, PAIRING_FUNCTION, PairingResponse};

use crate::bluetooth::BluetoothChannel;
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

pub async fn pair(/*channel: &BluetoothChannel*//*, recipient: &PublicKeyBase*/) -> anyhow::Result<PairingResponse> {
    let (sender, receiver) = channel();
    let channel = BluetoothChannel::new(BluetoothEndpoint::new(), sender, receiver);

    let body = Expression::new(PAIRING_FUNCTION);
    let temp_enclave = Enclave::new();
    let recipient = temp_enclave.public_key();
    let response = channel.call(recipient, &temp_enclave, body.clone(), Some(body)).await?;
    let envelope = response.result()?;

    let pairing_response: PairingResponse = envelope.to_cbor().try_into()?;
    Ok(pairing_response)
}

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    flutter_rust_bridge::setup_default_user_utils();
}