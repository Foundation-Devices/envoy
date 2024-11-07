#![allow(unused_imports)]

// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

use btleplug::api::{Central, Manager as _, Peripheral, ScanFilter};
pub use btleplug::platform::{Adapter, Manager};

use uuid::Uuid;
use btleplug::api::bleuuid::uuid_from_u16;
use btleplug::api::WriteType;
pub use std::net::{TcpListener, TcpStream};
use flutter_rust_bridge::frb;
use std::io::{self, Read, Write};
use std::io::Error;

#[frb(opaque)]
pub enum BluartPeripheral {
    Ble(btleplug::platform::Peripheral),
    Tcp(TcpAsPeripheral),
}

#[frb(opaque)]
pub struct TcpAsPeripheral {
    pub port: String,
    stream: Option<std::net::TcpStream>,
}


impl TcpAsPeripheral {
    pub fn new(url: String) -> TcpAsPeripheral {
        TcpAsPeripheral {
            port: url.to_string(),
            stream: None,
        }
    }

    pub fn connect(&mut self) {
        // Connect to the URL and initialize the stream
        match TcpStream::connect(&self.port) {
            Ok(stream) => {
                self.stream = Some(stream);
            }
            Err(e) => {
                eprintln!("Error initializing stream: {}", e);
            }
        }
    }

    pub fn write(&self, data: Vec<u8>) {
        if let Some(ref stream) = self.stream {
            let mut stream_clone = stream.try_clone().unwrap();
            stream_clone.write(&data).expect("Failed to write data to TCP stream");
        } else {
            eprintln!("the stream hasn't been initialized yet");
        }
    }


    async fn read(&self) -> Vec<u8> {
        if let Some(ref stream) = self.stream {
            let mut buffer = [0; 128];
            let mut stream_clone = stream.try_clone().unwrap();
            match stream_clone.read(&mut buffer) {
                Ok(bytes_read) => Vec::from(&buffer[..bytes_read]),
                Err(err) => {
                    eprintln!("Error reading from TCP stream: {}", err);
                    Vec::new()
                }
            }
        } else {
            eprintln!("the stream hasn't been initialized yet");
            Vec::new()
        }
    }
}

// NOTE: this fn transfers ownership of 'adapter' to Dart side
pub async fn first_adapter() -> Option<btleplug::platform::Adapter> {
    // Initialize Bluetooth manager
    let manager = btleplug::platform::Manager::new().await.unwrap();
    // Get adapters
    let adapters = manager.adapters().await.unwrap();
    // Return the first adapter, if any
    adapters.into_iter().next()
}

pub async fn get_adapters() -> Vec<btleplug::platform::Adapter> {
    // Initialize Bluetooth manager
    let manager = btleplug::platform::Manager::new().await.unwrap();
    // Get adapters
    let adapters = manager.adapters().await.unwrap();
    // Return the first adapter, if any
    adapters
}

// NOTE: this function now takes a REFERENCE to 'adapter' owned by Dart
// NOTE: if you remove the '&' Rust takes OWNERSHIP and...
// NOTE: ...since both Dart and Rust cannot OWN 'adapter' at the same time, it is dropped on Dart side by FRB
pub async fn get_peripherals(adapter: &btleplug::platform::Adapter, tcp_ports: Option<Vec<String>>) -> Vec<BluartPeripheral> {
    println!("Started scan!");
    start_scan(&adapter).await;
    //stop_scan(&adapter).await;
    let adapter_peripherals = adapter.peripherals().await.unwrap();

    let mut result: Vec<BluartPeripheral> = Vec::new();

    // Push BLE peripherals
    for peripheral in adapter_peripherals {
        result.push(BluartPeripheral::Ble(peripheral));
    }

    // Push TCP ports to peripherals and establish connections
    match tcp_ports {
        Some(ports) => {
            for port in ports {
                let tcp = TcpAsPeripheral::new(port);
                result.push(BluartPeripheral::Tcp(tcp));
            }
        }
        None => ()
    }
    result
}

pub async fn start_scan(adapter: &btleplug::platform::Adapter) {
    adapter.start_scan(ScanFilter::default()).await.expect("start scan error");
}

pub async fn stop_scan(adapter: &btleplug::platform::Adapter) {
    adapter.stop_scan().await.expect("stop scan error");
}

pub async fn connect_peripheral(peripheral: &mut BluartPeripheral) {
    match peripheral {
        BluartPeripheral::Ble(p) => {
            if let Err(err) = p.connect().await {
                eprintln!("Error connecting: {}", err);
            }
        }
        BluartPeripheral::Tcp(tcp) => {
            tcp.connect();
        }
    }
}

pub async fn get_name_from_perihperal(peripheral: &BluartPeripheral) -> String {
    match peripheral {
        BluartPeripheral::Ble(p) => {
            let properties = p.properties().await.unwrap().unwrap();
            properties.local_name.unwrap_or("Unknown".to_string())
        }
        BluartPeripheral::Tcp(tcp) => {
            tcp.port.clone()  // Return the URL for the Connection variant
        }
    }
}

pub async fn is_connected(peripheral: &BluartPeripheral) -> bool {
    match peripheral {
        BluartPeripheral::Ble(p) => {
            p.is_connected().await.unwrap()
        }

        BluartPeripheral::Tcp(tcp) => {
            tcp.stream.is_some()
        }
    }
}

pub async fn write_to(peripheral: &BluartPeripheral, rx_characteristic: Uuid, data: Vec<u8>) {
    match peripheral {
        BluartPeripheral::Ble(p) => {
            p.discover_services().await.unwrap();
            let chars = p.characteristics();
            let cmd_char = chars
                .iter()
                .find(|c| c.uuid == rx_characteristic)
                .expect("Unable to find characterics");

            p.write(&cmd_char, &data, WriteType::WithoutResponse)
                .await.unwrap();
        }
        BluartPeripheral::Tcp(tcp) => {
            tcp.write(data);
        }
    }
}

pub async fn read_from(peripheral: &mut BluartPeripheral, characteristic: Uuid) -> Vec<u8> {
    match peripheral {
        BluartPeripheral::Ble(p) => {
            p.discover_services().await.unwrap();
            let chars = p.characteristics();
            let cmd_char = chars
                .iter()
                .find(|c| c.uuid == characteristic)
                .expect("Unable to find characterics");

            p.read(&cmd_char).await.unwrap()
        }
        BluartPeripheral::Tcp(tcp) => {
            tcp.read().await
        }
    }
}


// pub struct Device {
//     pub name: String,
//     pub address: String,
//
// }
// pub async fn search(adapter: btleplug::platform::Adapter) -> Vec<Device> {
//     adapter.start_scan(ScanFilter::default()).await.expect("TODO: panic message");
//     let mut devices_info = Vec::new();
//     let peripherals = adapter.peripherals().await.unwrap();
//     for peripheral in peripherals {
//         let properties = peripheral.properties().await.unwrap().unwrap(); // Unwrap the Option
//         let address = peripheral.address();
//         let name = properties.local_name.unwrap_or("Unknown".to_string());
//         let device_info = Device { name: name, address: address.to_string() };
//         println!("Name: {}, Address: {}", device_info.name, device_info.address);
//         devices_info.push(device_info);
//     }
//     devices_info
// }
//
// pub async fn connect2device(central: btleplug::platform::Adapter, device: Device) {
//     let device_name = device.name;
//     for p in central.peripherals().await.unwrap() {
//         if p.properties()
//             .await
//             .unwrap().unwrap()
//             .local_name
//             .iter()
//             .any(|name| name.contains(&device_name))
//         {
//             if let Err(err) = p.connect().await {
//                 eprintln!("Error connecting: {}", err);
//                 // Additional error handling logic can be added here
//                 // For example, return Err(err) or take appropriate action
//             }
//         }
//     }
// }