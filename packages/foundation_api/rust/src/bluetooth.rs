use std::sync::mpsc::{Receiver, Sender};
use std::sync::{Arc, Mutex};
use std::time::Duration;
use async_trait::async_trait;
use foundation_api::{AbstractBluetoothChannel, BluetoothEndpoint};

#[derive(Debug)]
pub struct BluetoothChannel {
    endpoint: BluetoothEndpoint,
    sender: Mutex<Sender<Vec<u8>>>,
    receiver: Mutex<Receiver<Vec<u8>>>,
}

impl BluetoothChannel {
    pub fn new(
        endpoint: BluetoothEndpoint,
        sender: Sender<Vec<u8>>,
        receiver: Receiver<Vec<u8>>,
    ) -> Arc<Self> {
        Arc::new(Self {
            endpoint,
            sender: Mutex::new(sender),
            receiver: Mutex::new(receiver),
        })
    }
}

#[async_trait]
impl AbstractBluetoothChannel for BluetoothChannel {
    fn endpoint(&self) -> &BluetoothEndpoint {
        &self.endpoint
    }

    async fn send(&self, message: impl Into<Vec<u8>> + std::marker::Send) -> bc_envelope::Result<()> {
        let sender = self.sender.lock().unwrap();
        sender
            .send(message.into())
            .map_err(|e| anyhow::anyhow!(e))
    }

    async fn receive(&self, timeout: Duration) -> bc_envelope::Result<Vec<u8>> {
        let mut receiver = self.receiver.lock().unwrap();
        Ok(vec![])
    }
}