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

pub enum Command {
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
        sink: StreamSink<f64>,
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

impl std::fmt::Debug for Command {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Command::Scan { filter } => f.debug_struct("Scan").field("filter", filter).finish(),
            Command::Connect { id } => f.debug_struct("Connect").field("id", id).finish(),
            Command::Disconnect { id } => f.debug_struct("Disconnect").field("id", id).finish(),
            Command::Benchmark { id, sink: _ } => {
                f.debug_struct("Benchmark").field("id", id).finish()
            }
            Command::Read { id, sink: _ } => f.debug_struct("Read").field("id", id).finish(),
            Command::Write { id, .. } => f.debug_struct("Write").field("id", id).finish(),
            Command::WriteAll { id, sink: _, .. } => {
                f.debug_struct("WriteAll").field("id", id).finish()
            }
        }
    }
}

#[derive(Clone)]
pub enum Event {
    ScanResult(Vec<BleDevice>),
    DeviceDisconnected(BleDevice),
    DeviceConnected(BleDevice),
}

#[derive(Clone)]
pub struct BleState {
    devices: Arc<Mutex<HashMap<String, Device>>>,
    tx: mpsc::UnboundedSender<Command>,
    central: Arc<Mutex<Adapter>>,
}

static BLE_STATE: OnceLock<BleState> = OnceLock::new();

fn ble_state() -> &'static BleState {
    BLE_STATE.get().expect("BleState not initialized")
}

#[allow(unused_variables)]
fn init_logging(level: log::LevelFilter) {
    #[cfg(target_os = "android")]
    let _ = android_logger::init_once(android_logger::Config::default().with_max_level(level));

//    #[cfg(any(target_os = "ios", target_os = "macos"))]
//    let _ = oslog::OsLogger::new("frb_user").level_filter(level).init();
}

/// The init() function must be called before anything else.
/// At the moment the developer has to make sure it is only called once.
pub async fn init(sink: StreamSink<Event>) -> Result<()> {
    init_logging(log::LevelFilter::Info);

    create_runtime()?;
    let runtime = RUNTIME
        .get()
        .ok_or(anyhow::anyhow!("RuntimeNotInitialized"))?;

    let (tx, rx) = mpsc::unbounded_channel::<Command>();
    let manager = Manager::new().await?;
    let adapters = manager.adapters().await?;
    debug!("Number of adapters: {}", adapters.len());
    let central = adapters.into_iter().next().expect("cannot fail");

    let _ = BLE_STATE.set(BleState {
        devices: Arc::new(Mutex::new(HashMap::new())),
        tx,
        central: Arc::new(Mutex::new(central.clone())),
    });

    command::init(runtime, rx);

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

        while let Some(event) = events.next().await {
            debug!("{:?}", event);
            match event {
                CentralEvent::DeviceDiscovered(id) => {
                    debug!("DeviceDiscovered: {:?}", &id);
                    let peripheral = central.peripheral(&id).await.unwrap();
                    let peripheral = Device::new(peripheral);
                    let mut devices = ble_state().devices.lock().await;
                    devices.insert(id.to_string(), peripheral);
                }
                CentralEvent::DeviceUpdated(id) => {
                    let mut devices = ble_state().devices.lock().await;
                    if let Some(device) = devices.get_mut(&id.to_string()) {
                        device.last_seen = time::Instant::now();
                    }
                }
                CentralEvent::DeviceConnected(id) => {
                    debug!("DeviceConnected: {:?}", id);
                    let mut devices = ble_state().devices.lock().await;
                    if let Some(device) = devices.get_mut(&id.to_string()) {
                        device.is_connected = true;
                        sink.add(Event::DeviceConnected(
                            BleDevice::from_peripheral(device).await,
                        ))
                        .unwrap();
                    }
                }
                CentralEvent::DeviceDisconnected(id) => {
                    debug!("DeviceDisconnected: {:?}", id);
                    let mut devices = ble_state().devices.lock().await;
                    if let Some(device) = devices.get_mut(&id.to_string()) {
                        device.is_connected = false;
                        sink.add(Event::DeviceDisconnected(
                            BleDevice::from_peripheral(device).await,
                        ))
                        .unwrap();
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
    let mut devices = ble_state().devices.lock().await;
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
    let devices = ble_state().devices.lock().await;
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
    command::send(Command::Scan { filter })
}

pub fn connect(id: String) -> Result<()> {
    command::send(Command::Connect { id })
}

pub fn disconnect(id: String) -> Result<()> {
    command::send(Command::Disconnect { id })
}

pub fn benchmark(id: String, sink: StreamSink<u64>) -> Result<()> {
    command::send(Command::Benchmark { id, sink })
}

pub fn write(id: String, data: Vec<u8>) -> Result<()> {
    command::send(Command::Write { id, data })
}

pub fn write_all(id: String, data: Vec<Vec<u8>>, sink: StreamSink<f64>) -> Result<()> {
    command::send(Command::WriteAll { id, data, sink })
}

pub fn read(id: String, sink: StreamSink<Vec<u8>>) -> Result<()> {
    command::send(Command::Read { id, sink })
}

/// flutter_rust_bridge:ignore
mod command {
    use super::*;
    use anyhow::Context;
    use uuid::Uuid;

    pub fn init(runtime: &tokio::runtime::Runtime, mut rx: mpsc::UnboundedReceiver<Command>) {
        runtime.spawn(async move {
            log::info!("Starting command processing task");
            while let Some(msg) = rx.recv().await {
                debug!("got message {:?}", msg);
                let kind = msg.kind();

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
                    Command::WriteAll { id, data, sink } => {
                        spawn_command(inner_write_all(id, data, sink), kind);
                    }
                }
            }

            log::info!("Exiting command processing task");
        });
    }

    /// Internal send function to send [Command]s into the message loop.
    pub fn send(command: Command) -> Result<()> {
        debug!("send: {:?}", command);
        let tx = &ble_state().tx;
        debug!("send: tx: {:?}", tx);
        tx.send(command).with_context(|| "Failed to send command")?;
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

    async fn inner_scan(filter: Vec<String>) -> Result<()> {
        debug!("inner scan");
        let central = ble_state().central.lock().await;

        let services: Vec<Uuid> = filter
            .into_iter()
            .filter_map(|f| Uuid::parse_str(f.as_str()).ok())
            .collect();

        if services.is_empty() {
            debug!("Warning: empty list of services to filter for");
        }

        central.start_scan(ScanFilter { services }).await?;
        Ok(())
    }

    async fn inner_connect(id: String) -> Result<()> {
        debug!("inner connect: {id}");

        let mut devices = ble_state().devices.lock().await;
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

    async fn inner_disconnect(id: String) -> Result<()> {
        debug!("inner disconnect: {id}");
        let devices = ble_state().devices.lock().await;
        let device = devices
            .get(&id)
            .ok_or(anyhow::anyhow!("UnknownPeripheral(id)"))?;
        device.disconnect().await
    }

    async fn inner_benchmark(id: String, sink: StreamSink<u64>) -> Result<()> {
        debug!("inner benchmark: {id}");
        let devices = ble_state().devices.lock().await;
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
                    error!("Benchmark failed: {e}");
                    break;
                }
            }
        }

        Ok(())
    }

    async fn inner_read(id: String, sink: StreamSink<Vec<u8>>) -> Result<()> {
        debug!("inner read: {id}");
        let devices = ble_state().devices.lock().await;
        let device = devices
            .get(&id)
            .ok_or(anyhow::anyhow!("UnknownPeripheral(id)"))?;

        match device.read().await {
            Ok(mut stream) => {
                debug!("Got stream from: {id}");
                tokio::spawn(async move {
                    while let Some(data) = stream.next().await {
                        println!("Received data from [{:?}]: {:?}", data.uuid, data.value);
                        sink.add(data.value).unwrap();
                    }
                });
            }
            Err(e) => {
                debug!("Got error: {:?}", e);
            }
        }

        Ok(())
    }

    async fn inner_write(id: String, data: Vec<u8>) -> Result<()> {
        debug!("inner write: {id}");
        let devices = ble_state().devices.lock().await;
        let device = devices
            .get(&id)
            .ok_or(anyhow::anyhow!("UnknownPeripheral(id)"))?;
        device.write(data).await
    }

    async fn inner_write_all(id: String, data: Vec<Vec<u8>>, sink: StreamSink<f64>) -> Result<()> {
        debug!("inner write all: {id}");

        let devices = ble_state().devices.lock().await;
        let device = devices
            .get(&id)
            .ok_or(anyhow::anyhow!("UnknownPeripheral(id)"))?;

        device.write_all(data, sink).await
    }
}
