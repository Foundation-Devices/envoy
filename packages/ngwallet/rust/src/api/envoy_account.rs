// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

use crate::api::envoy_wallet::Network;
use flutter_rust_bridge::frb;
use ngwallet::config::{AddressType, NgDescriptor};
use ngwallet::transaction::{BitcoinTransaction, Output};

#[derive(Clone)]
#[frb(dart_metadata = ("freezed"))]
pub struct EnvoyAccount {
    pub name: String,
    pub color: String,
    pub device_serial: Option<String>,
    pub date_added: Option<String>,
    pub preferred_address_type: AddressType,
    pub seed_has_passphrase: bool,
    pub index: u32,
    pub descriptors: Vec<NgDescriptor>,
    pub date_synced: Option<String>,
    pub wallet_path: Option<String>,
    pub network: Network,
    pub id: String,
    pub next_address: Vec<(String,AddressType)>,
    pub balance: u64,
    pub unlocked_balance: u64,
    pub is_hot: bool,
    pub transactions: Vec<BitcoinTransaction>,
    pub utxo: Vec<Output>,
    pub tags: Vec<String>,
}

#[derive(Clone)]
pub struct Tag {
    pub utxo: Vec<Output>,
    pub tag: String,
}
