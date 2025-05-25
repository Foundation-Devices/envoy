// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

use std::collections::HashMap;
use std::sync::{Arc, OnceLock};

use anyhow::Result;
use btleplug::api::{bleuuid::BleUuid, Central, CentralEvent, Manager as _, ScanFilter};
use btleplug::platform::{Adapter, Manager};
use futures::stream::StreamExt;
use tokio::{
    sync::{mpsc, Mutex},
    time,
};

pub mod setup;
pub use setup::*;

pub mod device;
pub mod peripheral;

use crate::frb_generated::StreamSink;

pub use device::*;
pub use peripheral::*;

use log::{debug, error};

enum Command {
    Scan {
        filter: Vec<String>,
    },
    Connect {
        id: String,
    },
    Disconnect {
        id: String,
    },
    Benchmark {
        id: String,
        sink: StreamSink<u64>,
    },
    Read {
        id: String,
        sink: StreamSink<Vec<u8>>,
    },
    Write {
        id: String,
        data: Vec<u8>,
    },
    WriteAll {
        id: String,
        data: Vec<Vec<u8>>,
    },
}

impl Command {
    fn kind(&self) -> &'static str {
        match self {
            Command::Scan { .. } => "Scan",
            Command::Connect { .. } => "Connect",
            Command::Disconnect { .. } => "Disconnect",
            Command::Benchmark { .. } => "Benchmark",
            Command::Read { .. } => "Read",
            Command::Write { .. } => "Write",
            Command::WriteAll { .. } => "WriteAll",
        }
    }
}

#[derive(Clone)]
pub enum Event {
    ScanResult(Vec<BleDevice>),
    DeviceDisconnected,
    DeviceConnected,
}

impl std::fmt::Debug for Command {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("Scan").finish()
    }
}

static DEVICES: OnceLock<Arc<Mutex<HashMap<String, Device>>>> = OnceLock::new();

static TX: OnceLock<mpsc::UnboundedSender<Command>> = OnceLock::new();

static CENTRAL: OnceLock<Arc<Mutex<Adapter>>> = OnceLock::new();

/// Internal send function to send [Command]s into the message loop.
fn send(command: Command) -> Result<()> {
    debug!("send: {:?}", command);
    let tx = TX.get().ok_or(anyhow::anyhow!("TxNotInitialized"))?;
    debug!("send: tx: {:?}", tx);
    tx.send(command)?;
    debug!("sent command");
    Ok(())
}

/// Spawns a command future with consistent error handling
fn spawn_command<F, T>(future: F, kind: &'static str)
where
    F: std::future::Future<Output = Result<T>> + Send + 'static,
    T: Send + 'static,
{
    tokio::spawn(async move {
        if let Err(e) = future.await {
            error!("Command::{kind} failed: {e}");
        }
    });
}

/// The init() function must be called before anything else.
/// At the moment the developer has to make sure it is only called once.
pub async fn init(sink: StreamSink<Event>) -> Result<()> {
    // Disabled for now -> way too chatty
    // flutter_rust_bridge::setup_default_user_utils();

    create_runtime()?;
    let runtime = RUNTIME
        .get()
        .ok_or(anyhow::anyhow!("RuntimeNotInitialized"))?;

    let _ = DEVICES.set(Arc::new(Mutex::new(HashMap::new())));

    let manager = Manager::new().await?;
    let adapters = manager.adapters().await?;
    debug!("Number of adapters: {}", adapters.len());
    let central = adapters.into_iter().next().expect("cannot fail");

    CENTRAL.set(Arc::new(Mutex::new(central.clone()))).unwrap();

    runtime.spawn(async move {
        let (tx, mut rx) = mpsc::unbounded_channel::<Command>();
        TX.set(tx).unwrap();

        while let Some(msg) = rx.recv().await {
            let kind = msg.kind();
            debug!("got message {}", kind);

            match msg {
                Command::Scan { filter } => {
                    spawn_command(inner_scan(filter), kind);
                }
                Command::Connect { id } => {
                    spawn_command(inner_connect(id), kind);
                }
                Command::Disconnect { id } => {
                    spawn_command(inner_disconnect(id), kind);
                }
                Command::Benchmark { id, sink } => {
                    spawn_command(inner_benchmark(id, sink), kind);
                }
                Command::Read { id, sink } => {
                    spawn_command(inner_read(id, sink), kind);
                }
                Command::Write { id, data } => {
                    spawn_command(inner_write(id, data), kind);
                }
                Command::WriteAll { id, data } => {
                    spawn_command(inner_write_all(id, data), kind);
                }
            }
        }

        log::info!("Exiting command processing task!");
    });

    let sink_clone = sink.clone();
    runtime.spawn(async move {
        let mut device_send_interval = time::interval(time::Duration::from_secs(1));
        loop {
            device_send_interval.tick().await;
            remove_stale_devices(60).await;
            if send_devices(&sink_clone).await.is_err() {
                break;
            }
        }
    });

    runtime.spawn(async move {
        let mut events = central.events().await.unwrap();
        debug!("Subscribed to events!");

        //central.start_scan(ScanFilter::default()).await.unwrap();

        while let Some(event) = events.next().await {
            debug!("{:?}", event);
            match event {
                CentralEvent::DeviceDiscovered(id) => {
                    debug!("{}", format!("DeviceDiscovered: {:?}", &id));
                    let peripheral = central.peripheral(&id).await.unwrap();
                    let peripheral = Device::new(peripheral);
                    let mut devices = DEVICES.get().unwrap().lock().await;
                    devices.insert(id.to_string(), peripheral);
                }
                CentralEvent::DeviceUpdated(id) => {
                    let mut devices = DEVICES.get().unwrap().lock().await;
                    if let Some(device) = devices.get_mut(&id.to_string()) {
                        device.last_seen = time::Instant::now();
                    }
                }
                CentralEvent::DeviceConnected(id) => {
                    debug!("{}", format!("DeviceConnected: {:?}", id));
                    let mut devices = DEVICES.get().unwrap().lock().await;
                    if let Some(device) = devices.get_mut(&id.to_string()) {
                        device.is_connected = true;
                        sink.add(Event::DeviceConnected).unwrap();
                    }
                }
                CentralEvent::DeviceDisconnected(id) => {
                    debug!("{}", format!("DeviceDisconnected: {:?}", id));
                    let mut devices = DEVICES.get().unwrap().lock().await;
                    if let Some(device) = devices.get_mut(&id.to_string()) {
                        device.is_connected = false;
                        sink.add(Event::DeviceDisconnected).unwrap();
                    }
                }
                CentralEvent::ManufacturerDataAdvertisement {
                    id: _,
                    manufacturer_data: _,
                } => {
                    // tracing::debug!("{}",format!(
                    //     "ManufacturerDataAdvertisement: {:?}, {:?}",
                    //     id, manufacturer_data
                    // ));
                }
                CentralEvent::ServiceDataAdvertisement {
                    id: _,
                    service_data: _,
                } => {
                    // tracing::debug!("{}",format!(
                    //     "ServiceDataAdvertisement: {:?}, {:?}",
                    //     id, service_data
                    // ));
                }
                CentralEvent::ServicesAdvertisement { id: _, services } => {
                    let _services: Vec<String> =
                        services.into_iter().map(|s| s.to_short_string()).collect();
                    // tracing::debug!("{}",format!("ServicesAdvertisement: {:?}, {:?}", id, services));
                }
                CentralEvent::StateUpdate(_) => {}
            }
        }
        debug!("Exiting event task!");
    });

    debug!("Exiting init!");
    Ok(())
}

/// Removes all devices that haven't been seen for longer than [timeout] seconds, from the [DEVICES] list.
///
/// # Parameters
/// * timeout - A `u64` representing the maximum age of a device (in seconds)
///   that should be allowed to remain in the list.
///
/// # Example
///
/// Removing all devices that were last seen more than ten seconds ago:
///
/// ```rust
/// # use async_fn;
/// async_fn::remove_stale_devices(10);
/// ```
async fn remove_stale_devices(timeout: u64) {
    let mut devices = DEVICES.get().unwrap().lock().await;
    devices.retain(|_, d| d.is_connected() || d.last_seen.elapsed().as_secs() < timeout);
}

/// Helper function to send all [BleDevice]s to Dart/Flutter.
///
/// # Arguments
///
/// sink: StreamSink<Vec<BleDevice>>
///     The StreamSink to which the Vec<BleDevice> should be sent
///
/// # Return
///
/// Returns false if the stream is closed.
async fn send_devices(sink: &StreamSink<Event>) -> Result<()> {
    let devices = DEVICES.get().unwrap().lock().await;
    let mut d = vec![];
    for device in devices.values() {
        let dev = BleDevice::from_peripheral(device).await;
        d.push(dev.clone())
    }
    sink.add(Event::ScanResult(d))
        .map_err(|_| anyhow::anyhow!("No listeners"))?;
    Ok(())
}

/// This function is used to scan for BLE devices and returns the results via the given stream sink.
///
/// Parameters
///
/// sink: StreamSink<Vec<BleDevice>> - A stream sink to which the results are send
///
/// filter: Vec<String> - A vector of strings to filter the results with
pub fn scan(filter: Vec<String>) -> Result<()> {
    send(Command::Scan { filter })
}

async fn inner_scan(_filter: Vec<String>) -> Result<()> {
    let central = CENTRAL.get().unwrap().lock().await;
    central.start_scan(ScanFilter::default()).await?;
    // tracing::debug!("Scan finished");
    Ok(())
}

pub fn connect(id: String) -> Result<()> {
    debug!("{}", format!("Try to connect to: {id}"));
    send(Command::Connect { id })
}

async fn inner_connect(id: String) -> Result<()> {
    debug!("{}", format!("Try to connect to: {id}"));

    let mut devices = DEVICES.get().unwrap().lock().await;
    let device = match devices.get_mut(&id) {
        Some(device) => device,
        None => {
            return Err(anyhow::anyhow!("UnknownPeripheral(id)"));

            // TODO: create peripheral and add to DEVICES IF NOT THERE
            // let manager = Manager::new().await?;
            // let adapters = manager.adapters().await?;
            // let central = adapters.into_iter().next().expect("cannot fail");
            //
            // let address = BDAddr::from_str(&id)?;
            //
            // let peripheral_id = PeripheralId::from(address);
            // let peripheral = central
            //     .add_peripheral(&peripheral_id)
            //     .await?;
            //
            // let mut devices = DEVICES.get().unwrap().lock().await;
            // let device = Device::new(peripheral);
            // devices.insert(id, device);
            // &device.clone()
        }
    };

    device.connect().await
}

pub fn disconnect(id: String) -> Result<()> {
    send(Command::Disconnect { id })
}

async fn inner_disconnect(id: String) -> Result<()> {
    debug!("{}", format!("Try to disconnect from: {id}"));
    let devices = DEVICES.get().unwrap().lock().await;
    let device = devices
        .get(&id)
        .ok_or(anyhow::anyhow!("UnknownPeripheral(id)"))?;
    device.disconnect().await
}

pub fn benchmark(id: String, sink: StreamSink<u64>) -> Result<()> {
    send(Command::Benchmark { id, sink })
}

async fn inner_benchmark(id: String, sink: StreamSink<u64>) -> Result<()> {
    debug!("{}", format!("Trying to benchmark: {id}"));
    let devices = DEVICES.get().unwrap().lock().await;
    let device = devices
        .get(&id)
        .ok_or(anyhow::anyhow!("UnknownPeripheral(id)"))?;

    loop {
        tokio::time::sleep(time::Duration::from_millis(2000)).await;
        match device.benchmark().await {
            Ok(result) => {
                sink.add(result as u64).unwrap();
            }
            Err(e) => {
                error!("{}", format!("Benchmark failed: {e}"));
                break;
            }
        }
    }

    Ok(())
}

pub fn write(id: String, data: Vec<u8>) -> Result<()> {
    debug!("{}", format!("Writing to: {id}"));
    send(Command::Write { id, data })
}

async fn inner_write(id: String, data: Vec<u8>) -> Result<()> {
    debug!("inner write");
    debug!("{}", format!("Writing to: {id}"));
    let devices = DEVICES.get().unwrap().lock().await;
    let device = devices
        .get(&id)
        .ok_or(anyhow::anyhow!("UnknownPeripheral(id)"))?;
    device.write(data).await
}

pub fn write_all(id: String, data: Vec<Vec<u8>>) -> Result<()> {
    debug!("{}", format!("Writing all to: {id}"));
    send(Command::WriteAll { id, data })
}

async fn inner_write_all(id: String, data: Vec<Vec<u8>>) -> Result<()> {
    debug!("{}", format!("Writing all to: {id}"));
    let devices = DEVICES.get().unwrap().lock().await;
    let device = devices
        .get(&id)
        .ok_or(anyhow::anyhow!("UnknownPeripheral(id)"))?;

    device.write_all(data).await
}

pub fn read(id: String, sink: StreamSink<Vec<u8>>) -> Result<()> {
    debug!("{}", format!("Reading from: {id}"));
    send(Command::Read { id, sink })
}

async fn inner_read(id: String, sink: StreamSink<Vec<u8>>) -> Result<()> {
    debug!("{}", format!("Reading from: {id}"));
    let devices = DEVICES.get().unwrap().lock().await;
    let device = devices
        .get(&id)
        .ok_or(anyhow::anyhow!("UnknownPeripheral(id)"))?;

    debug!("{}", format!("Reading from: {id}"));
    match device.read().await {
        Ok(mut stream) => {
            debug!("{}", format!("Got stream from: {id}"));
            tokio::spawn(async move {
                while let Some(data) = stream.next().await {
                    println!("Received data from [{:?}]: {:?}", data.uuid, data.value);
                    sink.add(data.value).unwrap();
                }
            });
        }
        Err(e) => {
            debug!("{}", format!("Got error: {:?}", e));
        }
    }

    Ok(())
}
