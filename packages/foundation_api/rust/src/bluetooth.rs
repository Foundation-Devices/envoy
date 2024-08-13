use std::sync::Arc;
use tokio::sync::mpsc::{Receiver, Sender};
use tokio::sync::Mutex;
use tokio::time::Duration;
use async_trait::async_trait;
use foundation_abstracted::AbstractBluetoothChannel;
use foundation_api::bluetooth_endpoint::BluetoothEndpoint;
use anyhow::Result;
use tokio::time;
use crate::frb_generated::StreamSink;


pub struct BluetoothChannel {
    endpoint: BluetoothEndpoint,
    sender: Mutex<StreamSink<Vec<u8>>>,
    receiver: Mutex<Receiver<Vec<u8>>>,
}

impl BluetoothChannel {
    pub fn new(
        endpoint: BluetoothEndpoint,
        sender: StreamSink<Vec<u8>>,
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

    async fn send(&self, message: impl Into<Vec<u8>> + std::marker::Send) -> Result<()> {
        let sender = self.sender.lock().await;
        sender
            .add(message.into())
            .map_err(|e| anyhow::anyhow!(e))
    }

    async fn receive(&self, timeout: Duration) -> Result<Vec<u8>> {
        let mut receiver = self.receiver.lock().await;
        Ok(time::timeout(timeout, receiver.recv()).await?.unwrap())
    }
}