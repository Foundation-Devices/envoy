// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

use crate::frb_generated::StreamSink;
use core::fmt::{self, Display};
use std::sync::{Mutex, OnceLock};
use tracing_subscriber::{
    filter::{Filtered, LevelFilter},
    layer::SubscriberExt,
    util::SubscriberInitExt,
    Layer,
};

static LOG_BUILDER: OnceLock<Mutex<LogBuilder>> = OnceLock::new();

struct LogBuilder {
    loggers: Vec<Logger>,
    enabled: bool,
}

#[derive(Clone)]
struct Logger {
    sink: Option<StreamSink<String>>,
    name: String,
    level: LogLevel,
}

#[derive(Clone)]
pub enum LogLevel {
    Debug,
    Info,
}

impl LogLevel {
    fn to_level_filter(&self) -> LevelFilter {
        match self {
            LogLevel::Debug => LevelFilter::DEBUG,
            LogLevel::Info => LevelFilter::INFO,
        }
    }
}

pub fn add_logger(name: String, level: LogLevel) {
    let log_builder = LOG_BUILDER.get_or_init(|| {
        Mutex::new(LogBuilder {
            loggers: vec![],
            enabled: false,
        })
    });

    let mut log_builder = log_builder.lock().unwrap();
    let logger = Logger {
        sink: None,
        name,
        level,
    };
    log_builder.loggers.push(logger);
}

/// This function creates the tracing_subscriber::Registry and must be called at most once.
pub fn enable_logging(sink: StreamSink<String>) -> anyhow::Result<()> {
    if let Some(log_builder) = LOG_BUILDER.get() {
        let mut log_builder = log_builder.lock().unwrap();
        if !log_builder.enabled {
            log_builder.enabled = true;
            let loggers = log_builder.loggers.clone();

            let loggers = loggers
                .into_iter()
                .map(|mut logger| {
                    logger.sink = Some(sink.clone());
                    let level_filter = logger.level.to_level_filter();
                    logger.with_filter(level_filter)
                })
                .collect::<Vec<Filtered<Logger, LevelFilter, _>>>();

            tracing_subscriber::registry().with(loggers).init();
        }
        Ok(())
    } else {
        Err(anyhow::anyhow!("No logger registered."))
    }
}

#[derive(Default)]
pub struct LogVisitor {
    pub message: Option<String>,
    pub module_path: Option<String>,
    pub line: Option<String>,
    pub rest: String,
}

impl Display for LogVisitor {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        if let Some(message) = &self.message {
            if let (Some(module_path), Some(line)) = (&self.module_path, &self.line) {
                write!(f, "{}\n    at {}:{}", message, module_path, line)
            } else {
                write!(f, "{}", message)
            }
        } else {
            write!(f, "{}", self.rest)
        }
    }
}

impl tracing::field::Visit for LogVisitor {
    fn record_debug(&mut self, field: &tracing::field::Field, value: &dyn fmt::Debug) {
        let value = format!("{value:?}");
        match field.name() {
            "message" => self.message = Some(value),
            "log.module_path" => self.module_path = Some(value),
            "log.line" => self.line = Some(value),
            _ => self
                .rest
                .push_str(&format!("{}: {:?}\n", field.name(), value)),
        }
    }

    fn record_str(&mut self, field: &tracing::field::Field, value: &str) {
        self.rest
            .push_str(&format!("{}: {}\n", field.name(), value));
    }

    fn record_u64(&mut self, field: &tracing::field::Field, value: u64) {
        self.rest
            .push_str(&format!("{}: {}\n", field.name(), value));
    }
}

impl<S: tracing_core::Subscriber> tracing_subscriber::Layer<S> for Logger {
    fn on_event(
        &self,
        event: &tracing::Event<'_>,
        _ctx: tracing_subscriber::layer::Context<'_, S>,
    ) {
        let mut visitor = LogVisitor::default();
        event.record(&mut visitor);
        self.sink
            .as_ref()
            .unwrap()
            .add(format!("{}: {}", self.name, visitor))
            .unwrap();
    }
}
