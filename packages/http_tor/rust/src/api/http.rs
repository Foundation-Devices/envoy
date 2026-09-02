// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

use crate::frb_generated::StreamSink;
use anyhow::{anyhow, bail, ensure, Context, Result};
use lazy_static::lazy_static;
use openssl::sha::Sha256;
use reqwest::header::{
    HeaderMap, HeaderName, HeaderValue, ACCEPT_ENCODING, CONTENT_RANGE, RANGE, USER_AGENT,
};
use reqwest::StatusCode;
use std::collections::HashMap;
use std::fmt::Write as FmtWrite;
use std::fs::File as StdFile;
use std::io::{ErrorKind, Write as IoWrite};
use std::path::{Path, PathBuf};
use std::str::FromStr;
use std::sync::{Arc, Weak};
use std::time::Duration;
use tokio::fs::{self, OpenOptions};
use tokio::io::{AsyncReadExt, AsyncWriteExt};
use tokio::runtime::{Builder, Runtime};
use tokio::sync::Mutex;
use tokio::task::JoinHandle;
use tokio::time;
use tokio_util::sync::CancellationToken;

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
const DOWNLOAD_CONNECT_TIMEOUT: Duration = Duration::from_secs(60);
const DOWNLOAD_RESPONSE_TIMEOUT: Duration = Duration::from_secs(90);
const DOWNLOAD_STALL_TIMEOUT: Duration = Duration::from_secs(90);
const DOWNLOAD_RETRY_DELAY: Duration = Duration::from_secs(1);
const DOWNLOAD_MAX_ATTEMPTS: u32 = 5;
const DOWNLOAD_PROGRESS_STEP: u64 = 128 * 1024;

#[derive(Clone, Copy)]
struct DownloadPolicy {
    connect_timeout: Duration,
    response_timeout: Duration,
    stall_timeout: Duration,
    retry_delay: Duration,
    max_attempts: u32,
    overall_timeout: Duration,
}

fn download_policy(overall_timeout: Duration) -> DownloadPolicy {
    DownloadPolicy {
        connect_timeout: DOWNLOAD_CONNECT_TIMEOUT,
        response_timeout: DOWNLOAD_RESPONSE_TIMEOUT,
        stall_timeout: DOWNLOAD_STALL_TIMEOUT,
        retry_delay: DOWNLOAD_RETRY_DELAY,
        max_attempts: DOWNLOAD_MAX_ATTEMPTS,
        overall_timeout,
    }
}

lazy_static! {
    static ref RUNTIME: Result<Runtime> = Builder::new_multi_thread()
        .enable_all()
        .build()
        .map_err(|e| anyhow!(e));
    static ref VERIFIED_DOWNLOAD_LOCKS: Mutex<HashMap<PathBuf, Weak<Mutex<()>>>> =
        Mutex::new(HashMap::new());
}

pub struct Download {
    pub handle: Arc<JoinHandle<Result<(), anyhow::Error>>>,
}

impl Download {
    pub fn cancel(&self) {
        self.handle.abort();
    }
}

pub struct DownloadCancellationToken {
    token: CancellationToken,
}

impl DownloadCancellationToken {
    #[flutter_rust_bridge::frb(sync)]
    pub fn new() -> Self {
        Self {
            token: CancellationToken::new(),
        }
    }

    #[flutter_rust_bridge::frb(sync)]
    pub fn cancel(&self) {
        self.token.cancel();
    }
}

pub struct ProgressStream(pub StreamSink<Progress>);

/// Download and verify a large file within the caller's remaining deadline.
///
/// Partial data is stored at `<path>.part` and resumed on a later attempt. The
/// final path only becomes visible after both the expected size and SHA-256
/// digest have been verified.
#[allow(clippy::too_many_arguments)]
pub async fn download_verified_file(
    path: String,
    url: String,
    tor_port: i32,
    expected_size: u64,
    expected_sha256: String,
    progress_stream: ProgressStream,
    overall_timeout_ms: u64,
    cancellation_token: &DownloadCancellationToken,
) -> Result<()> {
    tokio::select! {
        biased;
        _ = cancellation_token.token.cancelled() => bail!("Download cancelled"),
        result = download_verified_file_with_policy(
            Path::new(&path),
            &url,
            tor_port,
            expected_size,
            &expected_sha256,
            Some(&progress_stream),
            download_policy(Duration::from_millis(overall_timeout_ms)),
        ) => result,
    }
}

//`download_verified_file_with_policy` is a testable internal entry point
async fn download_verified_file_with_policy(
    path: &Path,
    url: &str,
    tor_port: i32,
    expected_size: u64,
    expected_sha256: &str,
    progress_stream: Option<&ProgressStream>,
    policy: DownloadPolicy,
) -> Result<()> {
    time::timeout(
        policy.overall_timeout,
        download_verified_file_inner(
            path,
            url,
            tor_port,
            expected_size,
            expected_sha256,
            progress_stream,
            policy,
        ),
    )
    .await
    .map_err(|_| anyhow!("Download exceeded the overall time limit"))?
}

async fn download_verified_file_inner(
    path: &Path,
    url: &str,
    tor_port: i32,
    expected_size: u64,
    expected_sha256: &str,
    progress_stream: Option<&ProgressStream>,
    policy: DownloadPolicy,
) -> Result<()> {
    let path_lock = verified_download_lock(path).await;
    let _guard = path_lock.lock().await;
    ensure!(
        expected_size > 0,
        "Expected download size must be greater than zero"
    );
    ensure!(
        expected_sha256.len() == 64 && expected_sha256.chars().all(|c| c.is_ascii_hexdigit()),
        "Expected SHA-256 must contain 64 hexadecimal characters"
    );
    ensure!(
        policy.max_attempts > 0,
        "Download must allow at least one attempt"
    );

    let expected_sha256 = expected_sha256.to_ascii_lowercase();
    let part_path = partial_path(path);
    if let Some(parent) = path
        .parent()
        .filter(|parent| !parent.as_os_str().is_empty())
    {
        fs::create_dir_all(parent)
            .await
            .with_context(|| format!("Failed to create download directory {}", parent.display()))?;
    }

    if file_is_valid(path, expected_size, &expected_sha256).await? {
        publish_progress(progress_stream, expected_size, expected_size);
        return Ok(());
    }
    remove_if_exists(path).await?;

    match file_len(&part_path).await? {
        Some(size) if size == expected_size => {
            if file_is_valid(&part_path, expected_size, &expected_sha256).await? {
                fs::rename(&part_path, path).await.with_context(|| {
                    format!(
                        "Failed to promote completed download {}",
                        part_path.display()
                    )
                })?;
                publish_progress(progress_stream, expected_size, expected_size);
                return Ok(());
            }
            remove_if_exists(&part_path).await?;
        }
        Some(size) if size > expected_size => remove_if_exists(&part_path).await?,
        _ => {}
    }

    let mut client = reqwest::Client::builder().connect_timeout(policy.connect_timeout);
    if tor_port > 0 {
        client = client.proxy(reqwest::Proxy::all(format!(
            "socks5h://127.0.0.1:{tor_port}"
        ))?);
    } else {
        client = client.no_proxy();
    }
    let client = client.build()?;

    download_attempts(
        path,
        url,
        &client,
        expected_size,
        &expected_sha256,
        progress_stream,
        policy,
    )
    .await
}

async fn download_attempts(
    path: &Path,
    url: &str,
    client: &reqwest::Client,
    expected_size: u64,
    expected_sha256: &str,
    progress_stream: Option<&ProgressStream>,
    policy: DownloadPolicy,
) -> Result<()> {
    let part_path = partial_path(path);
    let mut last_error = anyhow!("Download did not start");
    for attempt in 1..=policy.max_attempts {
        let mut offset = file_len(&part_path).await?.unwrap_or(0);
        let mut request = client
            .get(url)
            .header(USER_AGENT, "Wget/1.12")
            .header(ACCEPT_ENCODING, "identity");
        if offset > 0 {
            request = request.header(RANGE, format!("bytes={offset}-"));
        }

        let mut response = match time::timeout(policy.response_timeout, request.send()).await {
            Ok(Ok(response)) => response,
            Ok(Err(error)) => {
                last_error = anyhow!(error).context("Failed to start download request");
                wait_before_retry(attempt, policy).await;
                continue;
            }
            Err(_) => {
                last_error = anyhow!("Timed out waiting for download response headers");
                wait_before_retry(attempt, policy).await;
                continue;
            }
        };

        let status = response.status();
        if is_retryable_status(status) {
            last_error = anyhow!("Download server returned {status}");
            wait_before_retry(attempt, policy).await;
            continue;
        }

        if status == StatusCode::RANGE_NOT_SATISFIABLE && offset > 0 {
            remove_if_exists(&part_path).await?;
            last_error = anyhow!("Download server rejected the saved partial range");
            wait_before_retry(attempt, policy).await;
            continue;
        }

        if !status.is_success() {
            bail!("Download server returned non-retryable status {status}");
        }

        let append = match status {
            StatusCode::PARTIAL_CONTENT if offset > 0 => {
                // A wrong Content-Range must not poison the saved partial:
                // discard it and spend an attempt on a clean request instead.
                if let Err(error) = validate_content_range(&response, offset) {
                    remove_if_exists(&part_path).await?;
                    last_error = error;
                    wait_before_retry(attempt, policy).await;
                    continue;
                }
                true
            }
            StatusCode::OK => {
                offset = 0;
                false
            }
            _ => bail!("Unexpected download response status {status}"),
        };

        publish_progress(progress_stream, offset, expected_size);
        let mut last_published = offset;

        let mut options = OpenOptions::new();
        options.create(true).write(true);
        if append {
            options.append(true);
        } else {
            options.truncate(true);
        }
        let mut file = options
            .open(&part_path)
            .await
            .with_context(|| format!("Failed to open partial download {}", part_path.display()))?;
        let mut downloaded = offset;
        let mut body_error = None;
        let mut discard_partial = false;

        loop {
            let chunk = match time::timeout(policy.stall_timeout, response.chunk()).await {
                Ok(Ok(chunk)) => chunk,
                Ok(Err(error)) => {
                    body_error = Some(anyhow!(error).context("Download body failed"));
                    break;
                }
                Err(_) => {
                    body_error = Some(anyhow!(
                        "Download made no progress before the stall timeout"
                    ));
                    break;
                }
            };

            let Some(chunk) = chunk else {
                break;
            };
            if downloaded + chunk.len() as u64 > expected_size {
                // An overlong body can never validate; a clean attempt can.
                body_error = Some(anyhow!("Download exceeded expected size"));
                discard_partial = true;
                break;
            }
            file.write_all(&chunk).await.with_context(|| {
                format!("Failed to write partial download {}", part_path.display())
            })?;
            downloaded += chunk.len() as u64;
            // Throttled so a multi-megabyte body doesn't flood the FFI bridge.
            if downloaded == expected_size || downloaded - last_published >= DOWNLOAD_PROGRESS_STEP
            {
                publish_progress(progress_stream, downloaded, expected_size);
                last_published = downloaded;
            }
        }

        file.flush()
            .await
            .with_context(|| format!("Failed to flush partial download {}", part_path.display()))?;
        // Windows cannot delete a file that still has an open handle.
        drop(file);

        if discard_partial {
            remove_if_exists(&part_path).await?;
        }

        if let Some(error) = body_error {
            last_error = error;
            wait_before_retry(attempt, policy).await;
            continue;
        }

        if downloaded != expected_size {
            last_error = anyhow!("Download ended at {downloaded} bytes, expected {expected_size}");
            wait_before_retry(attempt, policy).await;
            continue;
        }

        let actual_sha256 = sha256_file(&part_path).await?;
        if actual_sha256 != expected_sha256 {
            remove_if_exists(&part_path).await?;
            let mismatch = format!(
                "Downloaded file SHA-256 mismatch: expected {expected_sha256}, got {actual_sha256}"
            );
            if append {
                last_error = anyhow!(mismatch);
                wait_before_retry(attempt, policy).await;
                continue;
            }
            bail!(mismatch);
        }

        fs::rename(&part_path, path).await.with_context(|| {
            format!(
                "Failed to promote verified download {} to {}",
                part_path.display(),
                path.display()
            )
        })?;

        return Ok(());
    }

    Err(last_error).context(format!(
        "Download failed after {} attempts",
        policy.max_attempts
    ))
}

async fn verified_download_lock(path: &Path) -> Arc<Mutex<()>> {
    let mut locks = VERIFIED_DOWNLOAD_LOCKS.lock().await;
    locks.retain(|_, lock| lock.strong_count() > 0);

    if let Some(lock) = locks.get(path).and_then(Weak::upgrade) {
        return lock;
    }

    // The final file and its `.part` sibling form one persistence unit, so
    // only one task may mutate them at a time.
    let lock = Arc::new(Mutex::new(()));
    locks.insert(path.to_path_buf(), Arc::downgrade(&lock));
    lock
}

fn partial_path(path: &Path) -> PathBuf {
    let mut partial = path.as_os_str().to_os_string();
    partial.push(".part");
    PathBuf::from(partial)
}

async fn file_len(path: &Path) -> Result<Option<u64>> {
    match fs::metadata(path).await {
        Ok(metadata) => Ok(Some(metadata.len())),
        Err(error) if error.kind() == ErrorKind::NotFound => Ok(None),
        Err(error) => Err(error)
            .with_context(|| format!("Failed to inspect download file {}", path.display())),
    }
}

async fn remove_if_exists(path: &Path) -> Result<()> {
    match fs::remove_file(path).await {
        Ok(()) => Ok(()),
        Err(error) if error.kind() == ErrorKind::NotFound => Ok(()),
        Err(error) => {
            Err(error).with_context(|| format!("Failed to remove download file {}", path.display()))
        }
    }
}

async fn file_is_valid(path: &Path, expected_size: u64, expected_sha256: &str) -> Result<bool> {
    if file_len(path).await? != Some(expected_size) {
        return Ok(false);
    }
    Ok(sha256_file(path).await? == expected_sha256)
}

async fn sha256_file(path: &Path) -> Result<String> {
    let mut file = fs::File::open(path)
        .await
        .with_context(|| format!("Failed to open download for hashing {}", path.display()))?;
    let mut hasher = Sha256::new();
    let mut buffer = vec![0_u8; 64 * 1024];
    loop {
        let read = file
            .read(&mut buffer)
            .await
            .with_context(|| format!("Failed to hash download {}", path.display()))?;
        if read == 0 {
            break;
        }
        hasher.update(&buffer[..read]);
    }
    Ok(encode_sha256(hasher.finish()))
}

fn encode_sha256(digest: [u8; 32]) -> String {
    let mut encoded = String::with_capacity(64);
    for byte in digest {
        write!(&mut encoded, "{byte:02x}").expect("writing to a String cannot fail");
    }
    encoded
}

fn validate_content_range(response: &reqwest::Response, expected_start: u64) -> Result<()> {
    let value = response
        .headers()
        .get(CONTENT_RANGE)
        .context("Partial response omitted Content-Range")?
        .to_str()
        .context("Partial response had an invalid Content-Range")?;
    let start = value
        .strip_prefix("bytes ")
        .and_then(|range| range.split_once('-'))
        .map(|(start, _)| start)
        .context("Partial response had an invalid Content-Range")?
        .parse::<u64>()
        .context("Partial response had a non-numeric Content-Range")?;
    ensure!(
        start == expected_start,
        "Partial response started at {start}, expected {expected_start}"
    );
    Ok(())
}

fn is_retryable_status(status: StatusCode) -> bool {
    matches!(
        status,
        StatusCode::TOO_MANY_REQUESTS
            | StatusCode::BAD_GATEWAY
            | StatusCode::SERVICE_UNAVAILABLE
            | StatusCode::GATEWAY_TIMEOUT
    )
}

fn publish_progress(progress_stream: Option<&ProgressStream>, downloaded: u64, total: u64) {
    if let Some(progress_stream) = progress_stream {
        let _ = progress_stream.0.add(Progress { downloaded, total });
    }
}

async fn wait_before_retry(attempt: u32, policy: DownloadPolicy) {
    if attempt < policy.max_attempts {
        time::sleep(policy.retry_delay.saturating_mul(1 << (attempt - 1))).await;
    }
}

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
                .no_proxy()
                .build()?
        };

        let mut res = client.get(&url).send().await?;
        let total_size = res
            .content_length()
            .ok_or_else(|| anyhow!("Failed to get content length"))?;
        let mut file = StdFile::create(path)?;
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
            .no_proxy()
            .build()?
    };

    let mut header_map = HeaderMap::new();
    for (key, value) in headers {
        let header_name = HeaderName::from_str(&key)?;
        let header_value = HeaderValue::from_str(&value)?;
        header_map.append(header_name, header_value);
    }

    let mut request = match verb {
        Verb::Get => client.get(&url),
        Verb::Post => client.post(&url),
    };

    if let Some(body) = body {
        request = request.body(body);
    }

    let response = request.headers(header_map).send()?;
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
            .no_proxy()
            .build()?
    };

    let response = client.get("https://icanhazip.com").send()?;
    Ok(response.text()?)
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::sync::atomic::{AtomicU64, Ordering};
    use tokio::io::{AsyncReadExt, AsyncWriteExt};
    use tokio::net::{TcpListener, TcpStream};

    static NEXT_TEST_FILE: AtomicU64 = AtomicU64::new(0);

    fn test_policy() -> DownloadPolicy {
        DownloadPolicy {
            connect_timeout: Duration::from_secs(1),
            response_timeout: Duration::from_secs(1),
            stall_timeout: Duration::from_millis(400),
            retry_delay: Duration::from_millis(1),
            max_attempts: 2,
            overall_timeout: Duration::from_secs(20),
        }
    }

    fn test_path(name: &str) -> PathBuf {
        std::env::temp_dir().join(format!(
            "envoy-http-tor-{}-{}-{name}",
            std::process::id(),
            NEXT_TEST_FILE.fetch_add(1, Ordering::Relaxed)
        ))
    }

    fn sha256(bytes: &[u8]) -> String {
        let mut hasher = Sha256::new();
        hasher.update(bytes);
        encode_sha256(hasher.finish())
    }

    async fn try_read_request(stream: &mut TcpStream) -> Option<String> {
        let mut request = Vec::new();
        let mut buffer = [0_u8; 1024];
        while !request.windows(4).any(|window| window == b"\r\n\r\n") {
            let read = stream.read(&mut buffer).await.unwrap();
            if read == 0 {
                return None;
            }
            request.extend_from_slice(&buffer[..read]);
        }
        Some(String::from_utf8(request).unwrap())
    }

    async fn read_request(stream: &mut TcpStream) -> String {
        try_read_request(stream)
            .await
            .expect("client closed before sending HTTP headers")
    }

    async fn write_response(
        stream: &mut TcpStream,
        status: &str,
        extra_headers: &str,
        body: &[u8],
    ) {
        stream
            .write_all(
                format!(
                    "HTTP/1.1 {status}\r\nContent-Length: {}\r\n{extra_headers}Connection: close\r\n\r\n",
                    body.len()
                )
                .as_bytes(),
            )
            .await
            .unwrap();
        stream.write_all(body).await.unwrap();
    }

    async fn cleanup(path: &Path) {
        let _ = fs::remove_file(path).await;
        let _ = fs::remove_file(partial_path(path)).await;
    }

    #[tokio::test]
    async fn serializes_downloads_to_the_same_path() {
        let contents = b"one-path-has-one-download-writer";
        let listener = TcpListener::bind("127.0.0.1:0").await.unwrap();
        let address = listener.local_addr().unwrap();
        let server = tokio::spawn(async move {
            let (mut first, _) = listener.accept().await.unwrap();
            read_request(&mut first).await;
            first
                .write_all(
                    format!(
                        "HTTP/1.1 200 OK\r\nContent-Length: {}\r\nConnection: close\r\n\r\n",
                        contents.len()
                    )
                    .as_bytes(),
                )
                .await
                .unwrap();
            time::sleep(Duration::from_millis(25)).await;
            first.write_all(contents).await.unwrap();

            if let Ok(Ok((mut second, _))) =
                time::timeout(Duration::from_millis(100), listener.accept()).await
            {
                read_request(&mut second).await;
                second
                    .write_all(
                        format!(
                            "HTTP/1.1 200 OK\r\nContent-Length: {}\r\nConnection: close\r\n\r\n",
                            contents.len()
                        )
                        .as_bytes(),
                    )
                    .await
                    .unwrap();
                second.write_all(contents).await.unwrap();
                return 2;
            }

            1
        });

        let path = test_path("serialized");
        let url = format!("http://{address}/firmware");
        let digest = sha256(contents);
        let first = download_verified_file_with_policy(
            &path,
            &url,
            -1,
            contents.len() as u64,
            &digest,
            None,
            test_policy(),
        );
        let second = download_verified_file_with_policy(
            &path,
            &url,
            -1,
            contents.len() as u64,
            &digest,
            None,
            test_policy(),
        );
        let (first, second) = tokio::join!(first, second);

        first.unwrap();
        second.unwrap();
        assert_eq!(server.await.unwrap(), 1);
        assert_eq!(fs::read(&path).await.unwrap(), contents);
        cleanup(&path).await;
    }

    #[tokio::test]
    async fn progressing_body_can_outlive_the_stall_timeout() {
        let contents = b"firmware-download-that-keeps-making-progress";
        let listener = TcpListener::bind("127.0.0.1:0").await.unwrap();
        let address = listener.local_addr().unwrap();
        let server = tokio::spawn(async move {
            let (mut stream, _) = listener.accept().await.unwrap();
            read_request(&mut stream).await;
            stream
                .write_all(
                    format!(
                        "HTTP/1.1 200 OK\r\nContent-Length: {}\r\nConnection: close\r\n\r\n",
                        contents.len()
                    )
                    .as_bytes(),
                )
                .await
                .unwrap();
            for chunk in contents.chunks(8) {
                time::sleep(Duration::from_millis(150)).await;
                stream.write_all(chunk).await.unwrap();
            }
        });

        let path = test_path("progress");
        download_verified_file_with_policy(
            &path,
            &format!("http://{address}/firmware"),
            -1,
            contents.len() as u64,
            &sha256(contents),
            None,
            test_policy(),
        )
        .await
        .unwrap();

        server.await.unwrap();
        assert_eq!(fs::read(&path).await.unwrap(), contents);
        cleanup(&path).await;
    }

    #[tokio::test]
    async fn overall_time_limit_includes_path_lock_wait() {
        let path = test_path("lock-timeout");
        let path_lock = verified_download_lock(&path).await;
        let guard = path_lock.lock().await;
        let mut policy = test_policy();
        policy.overall_timeout = Duration::from_millis(20);

        let result = time::timeout(
            Duration::from_millis(200),
            download_verified_file_with_policy(
                &path,
                "http://127.0.0.1:1/firmware",
                -1,
                1,
                &sha256(b"x"),
                None,
                policy,
            ),
        )
        .await
        .expect("download deadline did not cover the path lock")
        .unwrap_err();

        assert!(result.to_string().contains("overall time limit"));
        drop(guard);
        cleanup(&path).await;
    }

    #[tokio::test]
    async fn resumes_after_the_response_body_is_interrupted() {
        let contents = b"firmware-download-resumes-from-the-last-saved-byte";
        let split = contents.len() / 2;
        let listener = TcpListener::bind("127.0.0.1:0").await.unwrap();
        let address = listener.local_addr().unwrap();
        let server = tokio::spawn(async move {
            let (mut first, _) = listener.accept().await.unwrap();
            let first_request = read_request(&mut first).await.to_ascii_lowercase();
            assert!(!first_request.contains("\r\nrange:"));
            first
                .write_all(
                    format!(
                        "HTTP/1.1 200 OK\r\nContent-Length: {}\r\nConnection: close\r\n\r\n",
                        contents.len()
                    )
                    .as_bytes(),
                )
                .await
                .unwrap();
            first.write_all(&contents[..split]).await.unwrap();
            first.shutdown().await.unwrap();

            let (mut second, _) = listener.accept().await.unwrap();
            let second_request = read_request(&mut second).await.to_ascii_lowercase();
            assert!(second_request.contains(&format!("\r\nrange: bytes={split}-")));
            second
                .write_all(
                    format!(
                        "HTTP/1.1 206 Partial Content\r\nContent-Length: {}\r\nContent-Range: bytes {}-{}/{}\r\nConnection: close\r\n\r\n",
                        contents.len() - split,
                        split,
                        contents.len() - 1,
                        contents.len()
                    )
                    .as_bytes(),
                )
                .await
                .unwrap();
            second.write_all(&contents[split..]).await.unwrap();
        });

        let path = test_path("resume");
        download_verified_file_with_policy(
            &path,
            &format!("http://{address}/firmware"),
            -1,
            contents.len() as u64,
            &sha256(contents),
            None,
            test_policy(),
        )
        .await
        .unwrap();

        server.await.unwrap();
        assert_eq!(fs::read(&path).await.unwrap(), contents);
        cleanup(&path).await;
    }

    #[tokio::test]
    async fn retries_from_zero_after_a_resumed_hash_mismatch() {
        let contents = b"firmware-download-replaces-a-corrupt-partial-prefix";
        let split = contents.len() / 2;
        let listener = TcpListener::bind("127.0.0.1:0").await.unwrap();
        let address = listener.local_addr().unwrap();
        let server = tokio::spawn(async move {
            let (mut resumed, _) = listener.accept().await.unwrap();
            let resumed_request = read_request(&mut resumed).await.to_ascii_lowercase();
            assert!(resumed_request.contains(&format!("\r\nrange: bytes={split}-")));
            resumed
                .write_all(
                    format!(
                        "HTTP/1.1 206 Partial Content\r\nContent-Length: {}\r\nContent-Range: bytes {}-{}/{}\r\nConnection: close\r\n\r\n",
                        contents.len() - split,
                        split,
                        contents.len() - 1,
                        contents.len()
                    )
                    .as_bytes(),
                )
                .await
                .unwrap();
            resumed.write_all(&contents[split..]).await.unwrap();

            let (mut clean, _) = listener.accept().await.unwrap();
            let clean_request = read_request(&mut clean).await.to_ascii_lowercase();
            assert!(!clean_request.contains("\r\nrange:"));
            clean
                .write_all(
                    format!(
                        "HTTP/1.1 200 OK\r\nContent-Length: {}\r\nConnection: close\r\n\r\n",
                        contents.len()
                    )
                    .as_bytes(),
                )
                .await
                .unwrap();
            clean.write_all(contents).await.unwrap();
        });

        let path = test_path("corrupt-resume");
        fs::write(partial_path(&path), vec![b'x'; split])
            .await
            .unwrap();
        download_verified_file_with_policy(
            &path,
            &format!("http://{address}/firmware"),
            -1,
            contents.len() as u64,
            &sha256(contents),
            None,
            test_policy(),
        )
        .await
        .unwrap();

        server.await.unwrap();
        assert_eq!(fs::read(&path).await.unwrap(), contents);
        cleanup(&path).await;
    }

    #[tokio::test]
    async fn invalid_content_range_restarts_without_the_saved_partial() {
        let contents = b"firmware-download-discards-an-invalid-content-range";
        let split = contents.len() / 2;
        let listener = TcpListener::bind("127.0.0.1:0").await.unwrap();
        let address = listener.local_addr().unwrap();
        let server = tokio::spawn(async move {
            let (mut invalid, _) = listener.accept().await.unwrap();
            let invalid_request = read_request(&mut invalid).await.to_ascii_lowercase();
            assert!(invalid_request.contains(&format!("\r\nrange: bytes={split}-")));
            write_response(
                &mut invalid,
                "206 Partial Content",
                &format!(
                    "Content-Range: bytes {}-{}/{}\r\n",
                    split + 1,
                    contents.len() - 1,
                    contents.len()
                ),
                &contents[split..],
            )
            .await;
            drop(invalid);

            let (mut clean, _) = listener.accept().await.unwrap();
            let clean_request = read_request(&mut clean).await.to_ascii_lowercase();
            assert!(!clean_request.contains("\r\nrange:"));
            write_response(&mut clean, "200 OK", "", contents).await;
        });

        let path = test_path("invalid-content-range");
        fs::write(partial_path(&path), &contents[..split])
            .await
            .unwrap();
        download_verified_file_with_policy(
            &path,
            &format!("http://{address}/firmware"),
            -1,
            contents.len() as u64,
            &sha256(contents),
            None,
            test_policy(),
        )
        .await
        .unwrap();

        server.await.unwrap();
        assert_eq!(fs::read(&path).await.unwrap(), contents);
        cleanup(&path).await;
    }

    #[tokio::test]
    async fn oversized_body_restarts_without_the_saved_partial() {
        let contents = b"firmware-download-discards-an-oversized-body";
        let mut oversized = contents.to_vec();
        oversized.push(b'x');
        let listener = TcpListener::bind("127.0.0.1:0").await.unwrap();
        let address = listener.local_addr().unwrap();
        let server = tokio::spawn(async move {
            let (mut invalid, _) = listener.accept().await.unwrap();
            let invalid_request = read_request(&mut invalid).await.to_ascii_lowercase();
            assert!(!invalid_request.contains("\r\nrange:"));
            write_response(&mut invalid, "200 OK", "", &oversized).await;
            drop(invalid);

            let (mut clean, _) = listener.accept().await.unwrap();
            let clean_request = read_request(&mut clean).await.to_ascii_lowercase();
            assert!(!clean_request.contains("\r\nrange:"));
            write_response(&mut clean, "200 OK", "", contents).await;
        });

        let path = test_path("oversized-body");
        download_verified_file_with_policy(
            &path,
            &format!("http://{address}/firmware"),
            -1,
            contents.len() as u64,
            &sha256(contents),
            None,
            test_policy(),
        )
        .await
        .unwrap();

        server.await.unwrap();
        assert_eq!(fs::read(&path).await.unwrap(), contents);
        cleanup(&path).await;
    }

    #[tokio::test]
    async fn rejects_a_fresh_download_hash_mismatch_without_retry() {
        let contents = b"firmware-download-rejects-corrupt-fresh-bytes";
        let listener = TcpListener::bind("127.0.0.1:0").await.unwrap();
        let address = listener.local_addr().unwrap();
        let server = tokio::spawn(async move {
            let (mut corrupt, _) = listener.accept().await.unwrap();
            read_request(&mut corrupt).await;
            corrupt
                .write_all(
                    format!(
                        "HTTP/1.1 200 OK\r\nContent-Length: {}\r\nConnection: close\r\n\r\n",
                        contents.len()
                    )
                    .as_bytes(),
                )
                .await
                .unwrap();
            corrupt
                .write_all(&vec![b'x'; contents.len()])
                .await
                .unwrap();
        });

        let path = test_path("fresh-mismatch");
        let error = download_verified_file_with_policy(
            &path,
            &format!("http://{address}/firmware"),
            -1,
            contents.len() as u64,
            &sha256(contents),
            None,
            test_policy(),
        )
        .await
        .unwrap_err();

        assert!(error.to_string().contains("SHA-256 mismatch"));
        server.await.unwrap();
        assert_eq!(file_len(&path).await.unwrap(), None);
        assert_eq!(file_len(&partial_path(&path)).await.unwrap(), None);
        cleanup(&path).await;
    }

    #[tokio::test]
    async fn overall_time_limit_bounds_a_crawling_download() {
        let listener = TcpListener::bind("127.0.0.1:0").await.unwrap();
        let address = listener.local_addr().unwrap();
        let server = tokio::spawn(async move {
            let (mut stream, _) = listener.accept().await.unwrap();
            read_request(&mut stream).await;
            if stream
                .write_all(
                    b"HTTP/1.1 200 OK\r\nContent-Length: 100000\r\nConnection: close\r\n\r\n",
                )
                .await
                .is_err()
            {
                return 0;
            }
            // Drip below the stall timeout until the client hangs up.
            let mut chunks_written = 0;
            for _ in 0..60 {
                if stream.write_all(b"x").await.is_err() {
                    break;
                }
                chunks_written += 1;
                time::sleep(Duration::from_millis(50)).await;
            }
            chunks_written
        });

        let mut policy = test_policy();
        policy.overall_timeout = Duration::from_secs(2);

        let path = test_path("crawl");
        let error = download_verified_file_with_policy(
            &path,
            &format!("http://{address}/firmware"),
            -1,
            100_000,
            &sha256(b"irrelevant"),
            None,
            policy,
        )
        .await
        .unwrap_err();

        assert!(error.to_string().contains("overall time limit"));
        assert!(
            server.await.unwrap() >= 9,
            "the body must make progress beyond the 400 ms stall timeout"
        );
        cleanup(&path).await;
    }
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
