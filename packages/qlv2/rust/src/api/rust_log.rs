// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

use std::collections::VecDeque;
use std::sync::atomic::{AtomicU64, Ordering};
use std::sync::{Mutex, OnceLock};
use std::time::{SystemTime, UNIX_EPOCH};

use crate::frb_generated::StreamSink;
use log::{LevelFilter, Log, Metadata, Record};
use tokio::sync::broadcast;

const RUST_LOG_MAX_LEVEL: LevelFilter = LevelFilter::Info;
const RUST_LOG_BACKLOG_CAPACITY: usize = 200;
const RUST_LOG_BROADCAST_CAPACITY: usize = 512;

#[derive(Clone, Debug)]
pub struct RustLogEntry {
    pub timestamp_ms: i64,
    pub level: String,
    pub target: String,
    pub message: String,
}

#[derive(Clone, Debug)]
struct SequencedRustLogEntry {
    sequence: u64,
    entry: RustLogEntry,
}

struct RustLogState {
    next_sequence: AtomicU64,
    backlog: Mutex<VecDeque<SequencedRustLogEntry>>,
    sender: broadcast::Sender<SequencedRustLogEntry>,
}

impl RustLogState {
    fn new() -> Self {
        let (sender, _) = broadcast::channel(RUST_LOG_BROADCAST_CAPACITY);
        Self {
            next_sequence: AtomicU64::new(1),
            backlog: Mutex::new(VecDeque::with_capacity(RUST_LOG_BACKLOG_CAPACITY)),
            sender,
        }
    }

    fn push(&self, entry: RustLogEntry) {
        let sequenced = SequencedRustLogEntry {
            sequence: self.next_sequence.fetch_add(1, Ordering::Relaxed),
            entry,
        };

        if let Ok(mut backlog) = self.backlog.lock() {
            backlog.push_back(sequenced.clone());
            while backlog.len() > RUST_LOG_BACKLOG_CAPACITY {
                backlog.pop_front();
            }
        }

        let _ = self.sender.send(sequenced);
    }

    fn subscribe(&self) -> broadcast::Receiver<SequencedRustLogEntry> {
        self.sender.subscribe()
    }

    fn backlog_after(&self, last_sent: Option<u64>) -> Vec<SequencedRustLogEntry> {
        let Ok(backlog) = self.backlog.lock() else {
            return Vec::new();
        };

        backlog
            .iter()
            .filter(|entry| last_sent.is_none_or(|sequence| entry.sequence > sequence))
            .cloned()
            .collect()
    }
}

struct FanOutLogger {
    #[cfg(target_os = "android")]
    android_logger: android_logger::AndroidLogger,
    #[cfg(any(target_os = "ios", target_os = "macos"))]
    os_logger: oslog::OsLogger,
}

impl FanOutLogger {
    fn new() -> Self {
        Self {
            #[cfg(target_os = "android")]
            android_logger: android_logger::AndroidLogger::new(
                android_logger::Config::default().with_max_level(RUST_LOG_MAX_LEVEL),
            ),
            #[cfg(any(target_os = "ios", target_os = "macos"))]
            os_logger: oslog::OsLogger::new("frb_user"),
        }
    }

    fn log_to_console(&self, record: &Record) {
        #[cfg(target_os = "android")]
        Log::log(&self.android_logger, record);

        #[cfg(any(target_os = "ios", target_os = "macos"))]
        Log::log(&self.os_logger, record);

        #[cfg(not(any(target_os = "android", target_os = "ios", target_os = "macos")))]
        eprintln!("{}", format_console_line(record));
    }
}

impl Log for FanOutLogger {
    fn enabled(&self, metadata: &Metadata) -> bool {
        metadata.level() <= RUST_LOG_MAX_LEVEL
    }

    fn log(&self, record: &Record) {
        if !self.enabled(record.metadata()) {
            return;
        }

        self.log_to_console(record);
        rust_log_state().push(RustLogEntry::from(record));
    }

    fn flush(&self) {}
}

impl From<&Record<'_>> for RustLogEntry {
    fn from(record: &Record) -> Self {
        Self {
            timestamp_ms: unix_timestamp_ms(),
            level: record.level().as_str().to_ascii_lowercase(),
            target: record.target().to_owned(),
            message: record.args().to_string(),
        }
    }
}

pub(crate) fn setup_log_to_console() {
    static LOGGER: OnceLock<FanOutLogger> = OnceLock::new();

    let logger = LOGGER.get_or_init(FanOutLogger::new);
    let _ = log::set_logger(logger);
    log::set_max_level(RUST_LOG_MAX_LEVEL);
}

pub async fn stream_rust_logs(sink: StreamSink<RustLogEntry>) {
    let state = rust_log_state();
    let mut receiver = state.subscribe();
    let mut last_sent = None;

    for entry in state.backlog_after(last_sent) {
        if sink.add(entry.entry).is_err() {
            return;
        }
        last_sent = Some(entry.sequence);
    }

    loop {
        match receiver.recv().await {
            Ok(entry) => {
                if last_sent.is_some_and(|sequence| entry.sequence <= sequence) {
                    continue;
                }

                last_sent = Some(entry.sequence);
                if sink.add(entry.entry).is_err() {
                    break;
                }
            }
            Err(broadcast::error::RecvError::Lagged(_)) => {
                for entry in state.backlog_after(last_sent) {
                    if sink.add(entry.entry).is_err() {
                        return;
                    }
                    last_sent = Some(entry.sequence);
                }
            }
            Err(broadcast::error::RecvError::Closed) => break,
        }
    }
}

fn rust_log_state() -> &'static RustLogState {
    static STATE: OnceLock<RustLogState> = OnceLock::new();
    STATE.get_or_init(RustLogState::new)
}

fn unix_timestamp_ms() -> i64 {
    SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .map(|duration| duration.as_millis().min(i64::MAX as u128) as i64)
        .unwrap_or_default()
}

#[cfg(not(any(target_os = "android", target_os = "ios", target_os = "macos")))]
fn format_console_line(record: &Record) -> String {
    format!("{} {}: {}", record.level(), record.target(), record.args())
}
