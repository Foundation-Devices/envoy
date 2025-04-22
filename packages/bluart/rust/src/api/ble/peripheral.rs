// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

use std::pin::Pin;
use anyhow::Result;
use btleplug::{api::Peripheral as _, platform::PeripheralId};
use btleplug::api::{Characteristic, ValueNotification, WriteType};
use flutter_rust_bridge::frb;
use futures::Stream;
use tokio::time;
use tokio::time::Instant;
use uuid::Uuid;
use log::debug;

pub const WRITE_CHARACTERISTIC_UUID: Uuid = Uuid::from_u128(0x6E400002_B5A3_F393_E0A9_E50E24DCCA9E);
pub const READ_CHARACTERISTIC_UUID: Uuid = Uuid::from_u128(0x6E400003_B5A3_F393_E0A9_E50E24DCCA9E);

pub const APP_MTU: usize = 240;

/// Wrapper struct around btleplug::platform::Peripheral that adds the last_seen variable.
///
#[frb(ignore)]
#[derive(Debug, Clone)]
pub struct Device {
    pub peripheral: btleplug::platform::Peripheral,
    pub last_seen: time::Instant,
    pub is_connected: bool,
    //pub read_characteristic: Option<Characteristic>
}

impl Device {
    #[frb(ignore)]
    pub fn new(peripheral: btleplug::platform::Peripheral) -> Device {
        Self {
            peripheral,
            last_seen: time::Instant::now(),
            is_connected: false,
        }
    }

    #[frb(ignore)]
    pub fn id(&self) -> PeripheralId {
        self.peripheral.id()
    }

    pub async fn name(&self) -> Option<String> {
        if let Ok(Some(properties)) = self.peripheral.properties().await {
            properties.local_name
        } else {
            None
        }
    }

    pub async fn connect(&self) -> Result<()> {
        self.peripheral.connect().await?;
        self.peripheral.discover_services().await?;
        Ok(())
    }

    pub async fn disconnect(&self) -> Result<()> {
        self.peripheral.disconnect().await?;
        Ok(())
    }

    pub async fn read(&self) -> Result<Pin<Box<dyn Stream<Item = ValueNotification> + Send>>> {
        let uart_characteristic = self.get_uart_read_characteristic();
        self.peripheral.subscribe(&uart_characteristic).await?;

        self.peripheral.notifications().await.map_err(|e| e.into())
    }

    pub async fn write(&self, data: Vec<u8>) -> Result<()> {
        debug!("before uart_characteristic");
        let uart_characteristic = self.get_uart_write_characteristic();
        self.peripheral.write(&uart_characteristic, &data, WriteType::WithoutResponse)
            .await?;

        Ok(())
    }

    pub async fn write_all(&self, data: Vec<Vec<u8>>) -> Result<()> {
        let uart_characteristic = self.get_uart_write_characteristic();

        let start = Instant::now();
        for data in data {
            self.peripheral.write(&uart_characteristic, &data, WriteType::WithoutResponse)
                .await?;
            tokio::time::sleep(time::Duration::from_millis(60)).await;
        }

        let duration = start.elapsed();
        debug!("Time taken: {:?}", duration);

        Ok(())
    }

    pub async fn benchmark(&self) -> Result<u128> {
        let uart_characteristic = self.get_uart_write_characteristic();
        let data9 = [9u8; APP_MTU];
        let data10 = [10u8; APP_MTU];

        tokio::time::sleep(time::Duration::from_millis(100)).await;
        let start = Instant::now();
        self.peripheral
            .write(&uart_characteristic, &data9, WriteType::WithoutResponse)
            .await?;
        self.peripheral
            .write(&uart_characteristic, &data10, WriteType::WithoutResponse)
            .await?;
        self.peripheral
            .write(&uart_characteristic, &data9, WriteType::WithoutResponse)
            .await?;
        self.peripheral
            .write(&uart_characteristic, &data10, WriteType::WithoutResponse)
            .await?;

        let duration = start.elapsed();
        println!("Elapsed time: {:?}", duration);

        Ok(duration.as_micros())
    }

    fn get_uart_write_characteristic(&self) -> Characteristic {
        let characteristics = self.peripheral.characteristics();
        let uart_characteristic = characteristics
            .iter()
            .find(|c| c.uuid == WRITE_CHARACTERISTIC_UUID)
            .expect("Unable to find characterics");
        uart_characteristic.clone()
    }

    fn get_uart_read_characteristic(&self) -> Characteristic {
        let characteristics = self.peripheral.characteristics();

        for characteristic in characteristics.clone() {
            debug!("  {:?}", characteristic);
        };

        let uart_characteristic = characteristics
            .iter()
            .find(|c| c.uuid == READ_CHARACTERISTIC_UUID)
            .expect("Unable to find characterics");
        uart_characteristic.clone()
    }

    pub fn is_connected(&self) -> bool {
        self.is_connected
    }
}
