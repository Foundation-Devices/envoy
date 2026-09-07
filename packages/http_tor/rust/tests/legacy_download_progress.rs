// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
// SPDX-License-Identifier: GPL-3.0-or-later

// Exercise the downloader with a channel in place of the Dart runtime.
mod frb_generated {
    pub struct StreamSink<T>(pub std::sync::mpsc::Sender<T>);

    impl<T> StreamSink<T> {
        pub fn add(&self, value: T) -> Result<(), std::sync::mpsc::SendError<T>> {
            self.0.send(value)
        }
    }
}

include!("../src/api/http.rs");

#[test]
fn legacy_download_progress_only_reports_readable_bytes() {
    use std::sync::mpsc;
    use tokio::net::TcpListener;

    let runtime = Builder::new_multi_thread()
        .worker_threads(1)
        .max_blocking_threads(1)
        .enable_all()
        .build()
        .unwrap();
    runtime.block_on(async {
        let path = std::env::temp_dir().join(format!(
            "envoy-http-tor-progress-{}.mp4",
            std::process::id()
        ));
        let listener = TcpListener::bind("127.0.0.1:0").await.unwrap();
        let url = format!("http://{}/video", listener.local_addr().unwrap());
        let (progress_tx, progress_rx) = mpsc::channel();
        let download = tokio::spawn(download_file_inner(
            path.clone(),
            url,
            -1,
            Some(ProgressStream(StreamSink(progress_tx))),
            file_download_policy(),
        ));
        let (mut socket, _) = listener.accept().await.unwrap();
        tests::read_request(&mut socket).await;
        socket
            .write_all(b"HTTP/1.1 200 OK\r\nContent-Length: 4096\r\nConnection: close\r\n\r\n")
            .await
            .unwrap();
        time::timeout(Duration::from_secs(5), async {
            while !path.exists() {
                time::sleep(Duration::from_millis(1)).await;
            }
        })
        .await
        .unwrap();

        // Keep the write queued while the downloader receives the body.
        let (started_tx, started_rx) = mpsc::channel();
        let (release_tx, release_rx) = mpsc::channel();
        let blocker = tokio::task::spawn_blocking(move || {
            started_tx.send(()).unwrap();
            release_rx.recv_timeout(Duration::from_secs(5)).unwrap();
        });
        started_rx.recv_timeout(Duration::from_secs(5)).unwrap();
        socket.write_all(&[42; 4096]).await.unwrap();

        let early_progress = progress_rx.recv_timeout(Duration::from_millis(100)).ok();
        let early_length = early_progress
            .as_ref()
            .map(|_| std::fs::metadata(&path).unwrap().len());
        release_tx.send(()).unwrap();
        let progress = early_progress
            .unwrap_or_else(|| progress_rx.recv_timeout(Duration::from_secs(5)).unwrap());
        let readable = early_length.unwrap_or_else(|| std::fs::metadata(&path).unwrap().len());

        blocker.await.unwrap();
        download.await.unwrap().unwrap();
        std::fs::remove_file(path).unwrap();
        assert_eq!(progress.downloaded, 4096);
        assert_eq!(progress.total, 4096);
        assert_eq!(readable, progress.downloaded);
    });
}
