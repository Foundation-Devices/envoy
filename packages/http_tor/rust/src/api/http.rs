// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

use crate::frb_generated::StreamSink;
use anyhow::{anyhow, Result};
use lazy_static::lazy_static;
use reqwest::header::{HeaderMap, HeaderName, HeaderValue};
use std::collections::HashMap;
use std::fs::File;
use std::io::Write;
use std::str::FromStr;
use std::sync::Arc;
use std::time::Duration;
use tokio::runtime::{Builder, Runtime};
use tokio::task::JoinHandle;
use tokio::time;

/// Enum representing HTTP verbs
#[derive(Debug, Clone)]
pub enum Verb {
    Get,
    Post,
}

/// Response from an HTTP request
#[derive(Debug, Clone)]
pub struct Response {
    pub status_code: u16,
    pub body: String,
    pub body_bytes: Vec<u8>,
}

#[derive(Clone)]
pub struct Progress {
    pub downloaded: u64,
    pub total: u64,
}

const REQUEST_TIMEOUT: Duration = Duration::from_secs(30);
const CONNECT_TIMEOUT: Duration = Duration::from_secs(10);

lazy_static! {
    static ref RUNTIME: Result<Runtime> = Builder::new_multi_thread()
        .enable_all()
        .build()
        .map_err(|e| anyhow!(e));
}

pub struct Download {
    pub handle: Arc<JoinHandle<Result<(), anyhow::Error>>>,
}

impl Download {
    pub fn cancel(&self) {
        self.handle.abort();
    }
}

pub struct ProgressStream(pub StreamSink<Progress>);

/// Download a file from a URL and stream progress updates
///
/// * `path` - The local path where the file will be saved
/// * `url` - The URL to download from
/// * `tor_port` - The port for Tor proxy (0 to disable)
/// * `progress_sink` - Stream sink for progress updates in format "downloaded/total"
pub async fn get_file(
    path: String,
    url: String,
    tor_port: i32,
    progress_stream: ProgressStream,
) -> Download {
    let rt = RUNTIME.as_ref().unwrap();
    let handle = rt.spawn(async move {
        let client: reqwest::Client = if tor_port > 0 {
            let proxy = reqwest::Proxy::all(format!("socks5h://127.0.0.1:{}", tor_port))?;
            reqwest::Client::builder()
                .connect_timeout(CONNECT_TIMEOUT)
                .timeout(REQUEST_TIMEOUT)
                .proxy(proxy)
                .build()?
        } else {
            reqwest::Client::builder()
                .connect_timeout(CONNECT_TIMEOUT)
                .timeout(REQUEST_TIMEOUT)
                .build()?
        };

        let mut res = client.get(&url).send().await?;
        let total_size = res
            .content_length()
            .ok_or_else(|| anyhow!("Failed to get content length"))?;
        let mut file = File::create(path)?;
        let mut downloaded: u64 = 0;

        while let Some(chunk) = res.chunk().await? {
            file.write_all(&chunk)?;
            let new_size = std::cmp::min(downloaded + (chunk.len() as u64), total_size);
            downloaded = new_size;

            // Send progress to Dart via StreamSink
            // Handle the StreamSink error explicitly since it doesn't implement std::error::Error
            if let Err(_e) = progress_stream.0.add(Progress {
                downloaded,
                total: total_size,
            }) {
                // Progress update failed, but we can continue with the download
                // Optionally log the error if you have a logging framework set up
                // log::warn!("Failed to send progress update: {:?}", _e);
            }

            // An opportunity to yield to other tasks
            time::sleep(Duration::from_secs(0)).await;
        }

        Ok(())
    });

    Download {
        handle: Arc::new(handle),
    }
}

/// Make an HTTP request
///
/// * `verb` - The HTTP verb (GET or POST)
/// * `url` - The URL to request
/// * `tor_port` - The port for Tor proxy (0 to disable)
/// * `body` - The request body
/// * `headers` - Map of header names to values
pub fn request(
    verb: Verb,
    url: String,
    tor_port: i32,
    body: Option<Vec<u8>>,
    headers: HashMap<String, String>,
) -> Result<Response> {
    let client: reqwest::blocking::Client = if tor_port > 0 {
        let proxy = reqwest::Proxy::all(format!("socks5h://127.0.0.1:{}", tor_port))?;
        reqwest::blocking::Client::builder()
            .connect_timeout(CONNECT_TIMEOUT)
            .timeout(REQUEST_TIMEOUT)
            .proxy(proxy)
            .build()?
    } else {
        reqwest::blocking::Client::builder()
            .connect_timeout(CONNECT_TIMEOUT)
            .timeout(REQUEST_TIMEOUT)
            .build()?
    };

    let mut header_map = HeaderMap::new();
    for (key, value) in headers {
        let header_name = HeaderName::from_str(&key)?;
        let header_value = HeaderValue::from_str(&value)?;
        header_map.append(header_name, header_value);
    }

    let request = match verb {
        Verb::Get => client.get(&url),
        Verb::Post => client.post(&url),
    };

    let response = request
        .body(body.unwrap_or_default())
        .headers(header_map)
        .send()?;
    let status_code = response.status().as_u16();
    let body_bytes = response.bytes()?.to_vec();
    let body = String::from_utf8_lossy(&body_bytes).to_string();

    Ok(Response {
        status_code,
        body,
        body_bytes,
    })
}

/// Get the public IP address
///
/// * `tor_port` - The port for Tor proxy (0 to disable)
pub fn get_ip(tor_port: i32) -> Result<String> {
    let client: reqwest::blocking::Client = if tor_port > 0 {
        let proxy = reqwest::Proxy::all(format!("socks5h://127.0.0.1:{}", tor_port))?;
        reqwest::blocking::Client::builder()
            .connect_timeout(CONNECT_TIMEOUT)
            .timeout(REQUEST_TIMEOUT)
            .proxy(proxy)
            .build()?
    } else {
        reqwest::blocking::Client::builder()
            .connect_timeout(CONNECT_TIMEOUT)
            .timeout(REQUEST_TIMEOUT)
            .build()?
    };

    let response = client.get("https://icanhazip.com").send()?;
    Ok(response.text()?)
}

/// Initialize the application
#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    // Default utilities - feel free to customize
    setup_log_to_console();
}

fn setup_log_to_console() {
    #[cfg(target_os = "android")]
    let _ = android_logger::init_once(
        android_logger::Config::default().with_max_level(log::LevelFilter::Info),
    );

    #[cfg(target_os = "ios")]
    let _ = oslog::OsLogger::new("frb_user")
        .level_filter(log::LevelFilter::Info)
        .init();

    #[cfg(target_family = "wasm")]
    let _ = crate::misc::web_utils::WebConsoleLogger::init();
}
