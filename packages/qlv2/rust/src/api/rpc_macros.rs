// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

macro_rules! assert_inbound_route {
    ($route:ident) => {
        const _: () = {
            struct Assert<T: ql_rpc::Route<Key = ql_api::ServiceRouteKey>>(
                std::marker::PhantomData<T>,
            );
            let _ = Assert::<ql_api::$route>(std::marker::PhantomData);
        };
    };
}

macro_rules! assert_outbound_route {
    ($route:ident) => {
        const _: () = {
            struct Assert<T: ql_rpc::Route<Key = ql_api::AppRouteKey>>(std::marker::PhantomData<T>);
            let _ = Assert::<ql_api::$route>(std::marker::PhantomData);
        };
    };
}

macro_rules! rpc_request {
    ($variant:ident, direction = inbound, route = $route:ident, params = $params:ty, response = $response:ty) => {
        paste::paste! {
            $crate::api::rpc_macros::assert_inbound_route!($route);

            #[flutter_rust_bridge::frb(opaque)]
            pub struct [<Inbound $route>] {
                pub payload: $params,
                response: ql_rpc::request::Response<$response, ql_runtime::StreamWriter>,
            }

            impl [<Inbound $route>] {
                pub async fn respond(
                    self,
                    response: $response,
                ) -> anyhow::Result<()> {
                    self.response
                        .respond(response)
                        .await
                        .map_err(|e| anyhow::anyhow!("respond failed {e:?}"))?;
                    Ok(())
                }
            }

            impl ql_rpc::request::RequestHandler<ql_api::$route, ql_runtime::QlStream> for $crate::api::rpc::RouterState {
                async fn handle(
                    self,
                    _:ql_rpc::Context,
                    payload: $params,
                    response: ql_rpc::request::Response<$response, ql_runtime::StreamWriter>,
                ) {
                    let _ = self.inner
                        .add($crate::api::rpc::InboundRpc::$variant([<Inbound $route>] {
                            payload,
                            response,
                        }));
                }
            }
        }
    };
    ($variant:ident, direction = outbound, route = $route:ident, params = $params:ty, response = $response:ty) => {
        paste::paste! {
            $crate::api::rpc_macros::assert_outbound_route!($route);

            impl $crate::api::ql_link::QLSession {
                pub async fn [<$route:snake>](
                    &self,
                    request: $params,
                ) -> anyhow::Result<$response> {
                    Ok(self.handle.rpc().request::<ql_api::$route>(&request,Default::default()).await?)
                }
            }
        }
    };
}

macro_rules! rpc_subscription {
    ($variant:ident, direction = inbound, route = $route:ident, params = $params:ty, event = $event:ty) => {
        paste::paste! {
            $crate::api::rpc_macros::assert_inbound_route!($route);

            #[flutter_rust_bridge::frb(opaque)]
            pub struct [<Inbound $route>] {
                pub payload: $params,
                responder: Option<ql_rpc::subscription::SubscriptionResponder<$event, ql_runtime::StreamWriter>>,
            }

            impl [<Inbound $route>] {
                pub async fn send(&mut self, event: $event) -> anyhow::Result<()> {
                    let responder = self
                        .responder
                        .as_mut()
                        .ok_or_else(|| anyhow::anyhow!("Send after finished"))?;
                    responder
                        .send(&event)
                        .await
                        .map_err(|e| anyhow::anyhow!("Send failed ${e:?}"))?;
                    Ok(())
                }

                pub async fn finish(&mut self) -> anyhow::Result<()> {
                    self.responder
                        .take()
                        .ok_or_else(|| anyhow::anyhow!("already finished"))?
                        .finish()
                        .await
                        .map_err(|e| anyhow::anyhow!("Failed to finish: {e:?}"))?;
                    Ok(())
                }
            }

            impl Drop for [<Inbound $route>] {
                fn drop(&mut self) {
                    log::warn!("{} Dropped....", stringify!([<Inbound $route>]))
                }
            }

            impl ql_rpc::subscription::SubscriptionHandler<ql_api::$route, ql_runtime::QlStream> for $crate::api::rpc::RouterState {
                async fn handle(
                    self,
                    _:ql_rpc::Context,
                    payload: $params,
                    responder: ql_rpc::subscription::SubscriptionResponder<$event, ql_runtime::StreamWriter>,
                ) {
                    let _ = self.inner
                        .add($crate::api::rpc::InboundRpc::$variant([<Inbound $route>] {
                            payload,
                            responder: Some(responder),
                        }));
                }
            }
        }
    };
    ($variant:ident, direction = outbound, route = $route:ident, params = $params:ty, event = $event:ty) => {
        paste::paste! {
            $crate::api::rpc_macros::assert_outbound_route!($route);

            impl $crate::api::ql_link::QLSession {
                pub async fn [<$route:snake>](
                    &self,
                    request: $params,
                    sink: $crate::frb_generated::StreamSink<$event>,
                ) -> anyhow::Result<()> {
                    log::info!("opening {} subscription", stringify!($route));
                    let mut subscription = match self
                        .handle
                        .rpc()
                        .subscribe::<ql_api::$route>(&request, Default::default())
                        .await
                    {
                        Ok(subscription) => subscription,
                        Err(error) => {
                            log::warn!(
                                "{} subscription unavailable: {error}",
                                stringify!($route)
                            );
                            return Ok(());
                        }
                    };
                    log::info!("{} subscription opened", stringify!($route));
                    tokio::spawn(async move {
                        loop {
                            match subscription.next_event().await {
                                Some(Ok(event)) => {
                                    log::info!(
                                        "{} subscription event received",
                                        stringify!($route)
                                    );
                                    if sink.add(event).is_err() {
                                        log::info!(
                                            "{} subscription Dart listener closed",
                                            stringify!($route)
                                        );
                                        return;
                                    }
                                }
                                Some(Err(error)) => {
                                    log::warn!(
                                        "{} subscription ended with error: {error}",
                                        stringify!($route)
                                    );
                                    return;
                                }
                                None => {
                                    log::warn!(
                                        "{} subscription ended by peer",
                                        stringify!($route)
                                    );
                                    return;
                                }
                            }
                        }
                    });
                    Ok(())
                }
            }
        }
    };
}

macro_rules! rpc_upload {
    ($variant:ident, direction = inbound, route = $route:ident, params = $params:ty, part_header = $part_header:ty, response = $response:ty) => {
        paste::paste! {
            $crate::api::rpc_macros::assert_inbound_route!($route);

            #[flutter_rust_bridge::frb(non_opaque)]
            pub enum [<$route StreamItem>] {
                PartHeader($part_header),
                PartChunk(Vec<u8>),
            }

            #[flutter_rust_bridge::frb(opaque)]
            pub struct [<Inbound $route>] {
                pub request: $params,
                reader: Option<ql_rpc::MultipartReader<$part_header, ql_runtime::StreamReader>>,
                responder: Option<ql_rpc::upload::UploadResponder<$response, ql_runtime::StreamWriter>>,
            }

            impl [<Inbound $route>] {
                pub async fn listen(
                    &mut self,
                    sink: $crate::frb_generated::StreamSink<[<$route StreamItem>]>,
                ) -> anyhow::Result<()> {
                    let mut reader = self
                        .reader
                        .take()
                        .ok_or_else(|| anyhow::anyhow!("already listening"))?;
                    tokio::spawn(async move {
                        loop {
                            match reader.next_part().await {
                                Ok(Some((part_header, mut part))) => {
                                    if sink
                                        .add([<$route StreamItem>]::PartHeader(part_header))
                                        .is_err()
                                    {
                                        return;
                                    }
                                    loop {
                                        match part.read_chunk().await {
                                            Ok(chunk) if !chunk.is_empty() => {
                                                if sink
                                                    .add([<$route StreamItem>]::PartChunk(
                                                        chunk.to_vec(),
                                                    ))
                                                    .is_err()
                                                {
                                                    return;
                                                }
                                            }
                                            Ok(_) => break,
                                            Err(error) => {
                                                log::warn!("Upload read failed: {error:?}");
                                                return;
                                            }
                                        }
                                    }
                                }
                                Ok(None) => return,
                                Err(error) => {
                                    log::warn!("Upload read failed: {error:?}");
                                    return;
                                }
                            }
                        }
                    });
                    Ok(())
                }

                pub async fn respond(&mut self, response: $response) -> anyhow::Result<()> {
                    self.responder
                        .take()
                        .ok_or_else(|| anyhow::anyhow!("already responded"))?
                        .respond(response)
                        .await
                        .map_err(|e| anyhow::anyhow!("respond failed ${e:?}"))?;
                    Ok(())
                }
            }

            impl Drop for [<Inbound $route>] {
                fn drop(&mut self) {
                    log::warn!("{} Dropped....", stringify!([<Inbound $route>]))
                }
            }

            impl ql_rpc::upload::UploadHandler<ql_api::$route, ql_runtime::QlStream> for $crate::api::rpc::RouterState {
                async fn handle(
                    self,
                    _:ql_rpc::Context,
                    request: $params,
                    reader: ql_rpc::MultipartReader<$part_header, ql_runtime::StreamReader>,
                    responder: ql_rpc::upload::UploadResponder<$response, ql_runtime::StreamWriter>,
                ) {
                    let _ = self.inner
                        .add($crate::api::rpc::InboundRpc::$variant([<Inbound $route>] {
                            request,
                            reader: Some(reader),
                            responder: Some(responder),
                        }));
                }
            }
        }
    };
    ($variant:ident, direction = outbound, route = $route:ident, params = $params:ty, part_header = $part_header:ty, response = $response:ty) => {
        paste::paste! {
            $crate::api::rpc_macros::assert_outbound_route!($route);

            #[flutter_rust_bridge::frb(opaque)]
            pub struct [<$route Call>] {
                inner: Option<ql_rpc::upload::UploadCall<ql_api::$route,ql_runtime::StreamWriter,ql_runtime::StreamReader>>,
            }

            impl $crate::api::ql_link::QLSession {
                pub async fn [<$route:snake>](
                    &self,
                    request: $params,
                ) -> anyhow::Result<[<$route Call>]> {
                    let upload = self.handle.rpc().upload::<ql_api::$route>(&request,Default::default()).await?;
                    Ok([<$route Call>] {
                        inner: Some(upload),
                    })
                }
            }

            impl [<$route Call>] {
                pub async fn send(
                    &mut self,
                    part_header: $part_header,
                    data: Vec<u8>,
                ) -> anyhow::Result<()> {
                    let upload = self
                        .inner
                        .as_mut()
                        .ok_or_else(|| anyhow::anyhow!("Send after finished"))?;
                    let mut part = upload
                        .start_part(part_header)
                        .await
                        .map_err(|e| anyhow::anyhow!("Start part failed ${e:?}"))?;
                    part
                        .send(data.into())
                        .await
                        .map_err(|e| anyhow::anyhow!("Send failed ${e:?}"))?;
                    part.finish()
                        .await
                        .map_err(|e| anyhow::anyhow!("Finish part failed ${e:?}"))?;
                    Ok(())
                }

                pub async fn send_chunked(
                    &mut self,
                    part_header: $part_header,
                    chunks: Vec<Vec<u8>>,
                ) -> anyhow::Result<()> {
                    let upload = self
                        .inner
                        .as_mut()
                        .ok_or_else(|| anyhow::anyhow!("Send after finished"))?;
                    let mut part = upload
                        .start_part(part_header)
                        .await
                        .map_err(|e| anyhow::anyhow!("Start part failed ${e:?}"))?;
                    for data in chunks {
                        part
                            .send(data.into())
                            .await
                            .map_err(|e| anyhow::anyhow!("Send failed ${e:?}"))?;
                    }
                    part.finish()
                        .await
                        .map_err(|e| anyhow::anyhow!("Finish part failed ${e:?}"))?;
                    Ok(())
                }

                pub async fn send_part(
                    &mut self,
                    part_header: $part_header,
                    data: Vec<u8>,
                ) -> anyhow::Result<()> {
                    self.send(part_header, data).await
                }

                pub async fn finish(&mut self) -> anyhow::Result<$response> {
                    self.inner
                        .take()
                        .ok_or_else(|| anyhow::anyhow!("finish after finished"))?
                        .finish()
                        .await
                        .map_err(|e| anyhow::anyhow!("finish failed ${e:?}"))
                }
            }

            impl Drop for [<$route Call>] {
                fn drop(&mut self) {
                    log::warn!("{} Dropped....", stringify!([<$route Call>]))
                }
            }
        }
    };
}

macro_rules! rpc_download {
    ($variant:ident, direction = inbound, route = $route:ident, params = $params:ty, header = $header:ty, part_header = $part_header:ty) => {
        paste::paste! {
            $crate::api::rpc_macros::assert_inbound_route!($route);

            #[flutter_rust_bridge::frb(opaque)]
            pub struct [<Inbound $route>] {
                pub request: $params,
                responder: Option<ql_rpc::download::DownloadStart<ql_api::$route, ql_runtime::StreamWriter>>,
                writer: Option<ql_rpc::download::DownloadWriter<ql_api::$route, ql_runtime::StreamWriter>>,
            }

            impl [<Inbound $route>] {
                pub async fn start(&mut self, header: $header) -> anyhow::Result<()> {
                    let responder = self
                        .responder
                        .take()
                        .ok_or_else(|| anyhow::anyhow!("Start called more than once"))?;
                    let writer = responder
                        .start(header)
                        .await
                        .map_err(|e| anyhow::anyhow!("Start failed ${e:?}"))?;
                    self.writer = Some(writer);
                    Ok(())
                }

                pub async fn send(
                    &mut self,
                    part_header: $part_header,
                    data: Vec<u8>,
                ) -> anyhow::Result<()> {
                    let writer = self
                        .writer
                        .as_mut()
                        .ok_or_else(|| anyhow::anyhow!("Send after finished"))?;
                    let mut part = writer
                        .start_part(part_header)
                        .await
                        .map_err(|e| anyhow::anyhow!("Start part failed ${e:?}"))?;
                    part
                        .send(data.into())
                        .await
                        .map_err(|e| anyhow::anyhow!("Send failed ${e:?}"))?;
                    part.finish()
                        .await
                        .map_err(|e| anyhow::anyhow!("Finish part failed ${e:?}"))?;
                    Ok(())
                }

                pub async fn finish(&mut self) -> anyhow::Result<()> {
                    let writer = self
                        .writer
                        .take()
                        .ok_or_else(|| anyhow::anyhow!("finish after finished"))?;
                    writer
                        .finish()
                        .await
                        .map_err(|e| anyhow::anyhow!("finish failed ${e:?}"))?;
                    Ok(())
                }
            }

            impl ql_rpc::download::DownloadHandler<ql_api::$route, ql_runtime::QlStream> for $crate::api::rpc::RouterState {
                async fn handle(
                    self,
                          _:ql_rpc::Context,

                    request: $params,
                    responder: ql_rpc::download::DownloadStart<ql_api::$route, ql_runtime::StreamWriter>,
                ) {
                    let _ = self.inner.add($crate::api::rpc::InboundRpc::$variant([<Inbound $route>] {
                        request,
                        responder: Some(responder),
                        writer: None,
                    }));
                }
            }
        }
    };
    ($variant:ident, direction = outbound, route = $route:ident, params = $params:ty, header = $header:ty, part_header = $part_header:ty) => {
        paste::paste! {
            $crate::api::rpc_macros::assert_outbound_route!($route);

            #[flutter_rust_bridge::frb(non_opaque)]
            pub enum [<$route StreamItem>] {
                PartHeader($part_header),
                PartChunk(Vec<u8>),
            }

            impl $crate::api::ql_link::QLSession {
                pub async fn [<$route:snake>](
                    &self,
                    request: $params,
                    sink: $crate::frb_generated::StreamSink<[<$route StreamItem>]>,
                ) -> anyhow::Result<$header> {
                    let download = self.handle.rpc().download::<ql_api::$route>(&request).await?;
                    let (header, mut reader) = download.start().await?;
                    tokio::spawn(async move {
                        loop {
                            match reader.next_part().await {
                                Ok(Some((part_header, mut part))) => {
                                    if sink
                                        .add([<$route StreamItem>]::PartHeader(part_header))
                                        .is_err()
                                    {
                                        return;
                                    }
                                    loop {
                                        match part.read_chunk().await {
                                            Ok(chunk) if !chunk.is_empty() => {
                                                if sink
                                                    .add([<$route StreamItem>]::PartChunk(
                                                        chunk.to_vec(),
                                                    ))
                                                    .is_err()
                                                {
                                                    return;
                                                }
                                            }
                                            Ok(_) => break,
                                            Err(error) => {
                                                log::warn!("Download read failed: {error:?}");
                                                return;
                                            }
                                        }
                                    }
                                }
                                Ok(None) => return,
                                Err(error) => {
                                    log::warn!("Download read failed: {error:?}");
                                    return;
                                }
                            }
                        }
                    });
                    Ok(header)
                }
            }
        }
    };
}

macro_rules! rpc_duplex {
    ($variant:ident, direction = inbound, route = $route:ident, initiator = $initiator_event:ty, responder = $responder_event:ty) => {
        paste::paste! {
            $crate::api::rpc_macros::assert_inbound_route!($route);

            #[flutter_rust_bridge::frb(opaque)]
            pub struct [<Inbound $route>] {
                sender: Option<ql_rpc::duplex::DuplexSender<$responder_event, ql_runtime::StreamWriter>>,
                receiver: Option<ql_rpc::duplex::DuplexReceiver<$initiator_event, ql_runtime::StreamReader>>,
            }

            impl [<Inbound $route>] {
                pub async fn listen(
                    &mut self,
                    sink: $crate::frb_generated::StreamSink<$initiator_event>,
                ) -> anyhow::Result<()> {
                    let mut receiver = self
                        .receiver
                        .take()
                        .ok_or_else(|| anyhow::anyhow!("already listening"))?;
                    tokio::spawn(async move {
                        while let Some(result) = receiver.next_event().await {
                            match result {
                                Ok(event) => {
                                    if sink.add(event).is_err() {
                                        return;
                                    }
                                }
                                Err(error) => {
                                    log::warn!("Inbound duplex receive failed: {error:?}");
                                    return;
                                }
                            }
                        }
                    });
                    Ok(())
                }

                pub async fn send(&mut self, event: $responder_event) -> anyhow::Result<()> {
                    let sender = self
                        .sender
                        .as_mut()
                        .ok_or_else(|| anyhow::anyhow!("Send after finished"))?;
                    sender
                        .send(&event)
                        .await
                        .map_err(|e| anyhow::anyhow!("Send failed {e:?}"))?;
                    Ok(())
                }

                pub async fn finish(&mut self) -> anyhow::Result<()> {
                    self.sender
                        .take()
                        .ok_or_else(|| anyhow::anyhow!("already finished"))?
                        .finish()
                        .await
                        .map_err(|e| anyhow::anyhow!("Failed to finish: {e:?}"))?;
                    Ok(())
                }
            }

            impl Drop for [<Inbound $route>] {
                fn drop(&mut self) {
                    log::warn!("{} Dropped....", stringify!([<Inbound $route>]))
                }
            }

            impl ql_rpc::duplex::DuplexHandler<ql_api::$route, ql_runtime::QlStream> for $crate::api::rpc::RouterState {
                async fn handle(
                    self,
                _:ql_rpc::Context,
                    peer: ql_rpc::duplex::DuplexPeer<ql_api::$route, ql_runtime::StreamWriter, ql_runtime::StreamReader>,
                ) {
                    let _ = self.inner
                        .add($crate::api::rpc::InboundRpc::$variant([<Inbound $route>] {
                            sender: Some(peer.sender),
                            receiver: Some(peer.receiver),
                        }));
                }
            }
        }
    };
    ($variant:ident, direction = outbound, route = $route:ident, initiator = $initiator_event:ty, responder = $responder_event:ty) => {
        paste::paste! {
            $crate::api::rpc_macros::assert_outbound_route!($route);

            #[flutter_rust_bridge::frb(opaque)]
            pub struct [<$route Call>] {
                sender: Option<ql_rpc::duplex::DuplexSender<$initiator_event,ql_runtime::StreamWriter>>,
                receiver: Option<ql_rpc::duplex::DuplexReceiver<$responder_event,ql_runtime::StreamReader>>,
            }

            impl $crate::api::ql_link::QLSession {
                pub async fn [<$route:snake>](&self) -> anyhow::Result<[<$route Call>]> {
                    let duplex = self.handle.rpc().duplex::<ql_api::$route>().await?;
                    Ok([<$route Call>] {
                        sender: Some(duplex.sender),
                        receiver: Some(duplex.receiver),
                    })
                }
            }

            impl [<$route Call>] {
                pub async fn listen(
                    &mut self,
                    sink: $crate::frb_generated::StreamSink<$responder_event>,
                ) -> anyhow::Result<()> {
                    let mut receiver = self
                        .receiver
                        .take()
                        .ok_or_else(|| anyhow::anyhow!("already listening"))?;
                    tokio::spawn(async move {
                        while let Some(result) = receiver.next_event().await {
                            match result {
                                Ok(event) => {
                                    if sink.add(event).is_err() {
                                        return;
                                    }
                                }
                                Err(error) => {
                                    log::warn!("Duplex receive failed: {error:?}");
                                    return;
                                }
                            }
                        }
                    });
                    Ok(())
                }

                pub async fn send(&mut self, event: $initiator_event) -> anyhow::Result<()> {
                    let sender = self
                        .sender
                        .as_mut()
                        .ok_or_else(|| anyhow::anyhow!("Send after finished"))?;
                    sender
                        .send(&event)
                        .await
                        .map_err(|e| anyhow::anyhow!("Send failed {e:?}"))?;
                    Ok(())
                }

                pub async fn finish(&mut self) -> anyhow::Result<()> {
                    self.sender
                        .take()
                        .ok_or_else(|| anyhow::anyhow!("already finished"))?
                        .finish()
                        .await
                        .map_err(|e| anyhow::anyhow!("Failed to finish: {e:?}"))?;
                    Ok(())
                }
            }

            impl Drop for [<$route Call>] {
                fn drop(&mut self) {
                    log::warn!("{} Dropped....", stringify!([<$route Call>]))
                }
            }
        }
    };
}

pub(crate) use {
    assert_inbound_route, assert_outbound_route, rpc_download, rpc_duplex, rpc_request,
    rpc_subscription, rpc_upload,
};
