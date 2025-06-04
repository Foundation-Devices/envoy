// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

use crate::api::envoy_account::EnvoyAccount;
use crate::api::errors::{BroadcastError, ComposeTxError};
use crate::api::migration::get_last_used_index;
use crate::frb_generated::StreamSink;
use anyhow::{anyhow, Context, Error, Result};
use bdk_wallet::bip39::{Language, Mnemonic};
use bdk_wallet::bitcoin::address::{NetworkUnchecked, ParseError};
use bdk_wallet::bitcoin::base64::prelude::BASE64_STANDARD;
use bdk_wallet::bitcoin::base64::Engine;
use bdk_wallet::bitcoin::bip32::Error::Secp256k1;
use bdk_wallet::bitcoin::{absolute, psbt, Address, Amount, OutPoint, Sequence, Txid};
pub use bdk_wallet::bitcoin::{Network, Psbt, ScriptBuf};
use bdk_wallet::chain::spk_client::{FullScanRequest, FullScanResponse, SyncRequest};
use bdk_wallet::chain::{CheckPoint, Indexed};
use bdk_wallet::descriptor::policy::PolicyError;
use bdk_wallet::descriptor::{DescriptorError, DescriptorPublicKey, ExtendedDescriptor};
use bdk_wallet::error::{CreateTxError, MiniscriptPsbtError};
use bdk_wallet::rusqlite::{Connection, OpenFlags};
use bdk_wallet::serde::{Deserialize, Serialize};
use bdk_wallet::{
    bitcoin, coin_selection, AddressInfo, KeychainKind, PersistedWallet, Update, Wallet, WalletTx,
};
use chrono::{DateTime, Local, Utc};
use flutter_rust_bridge::frb;
use log::info;
use ngwallet::account::{Descriptor, NgAccount};
use ngwallet::config::{AddressType, NgAccountBackup, NgAccountBuilder, NgAccountConfig, NgDescriptor};
use ngwallet::ngwallet::NgWallet;
use ngwallet::rbf::BumpFeeError;
use ngwallet::redb::backends::FileBackend;
use ngwallet::send::{DraftTransaction, TransactionFeeResult, TransactionParams};
use ngwallet::transaction::{BitcoinTransaction, Output};
use std::collections::BTreeMap;
use std::env;
use std::fmt::format;
use std::fs::File;
use std::path::{Path, PathBuf};
use std::str::FromStr;
use std::sync::{Arc, LockResult, Mutex};
use std::time::{Duration, SystemTime, UNIX_EPOCH};
use std::{fs, thread};
use std::any::Any;
use bdk_wallet::serde_json::json;
use crate::api::bip39::EnvoyBip39;

#[frb(init)]
pub fn init_app() {
    flutter_rust_bridge::setup_default_user_utils();
}

#[derive(Clone)]
pub struct EnvoyAccountHandler {
    pub stream_sink: Option<StreamSink<EnvoyAccount>>,
    pub ng_account: Arc<Mutex<NgAccount<Connection>>>,
    //temporary list of transactions,which are not yet in the wallet yet
    mempool_txs: Vec<BitcoinTransaction>,
    //account to access handler, lifting id from ng_account
    id: String,
}

#[frb(external)]
impl Output {
    #[frb(sync)]
    pub fn get_id(&self) -> String {}
}

#[frb(mirror(Network))]
pub enum _Network {
    /// Mainnet Bitcoin.
    Bitcoin,
    /// Bitcoin's testnet network. (In future versions this will be combined
    /// into a single variant containing the version)
    Testnet,
    /// Bitcoin's testnet4 network. (In future versions this will be combined
    /// into a single variant containing the version)
    Testnet4,
    /// Bitcoin's signet network.
    Signet,
    /// Bitcoin's regtest network.
    Regtest,
}

// Envoy Wallet is a wrapper around NgWallet for Envoy app specific functionalities
impl EnvoyAccountHandler {
    pub fn new_from_descriptor(
        name: String,
        device_serial: Option<String>,
        date_added: Option<String>,
        address_type: AddressType,
        color: String,
        index: u32,
        descriptors: Vec<NgDescriptor>,
        db_path: String,
        network: Network,
        id: String,
    ) -> Result<EnvoyAccountHandler> {
        let descriptors = Self::get_descriptors(&descriptors, db_path.clone());

        let mut ng_account = NgAccountBuilder::default()
            .name(name.clone())
            .color(color.clone())
            .descriptors(descriptors)
            .device_serial(device_serial)
            .date_added(date_added)
            .date_synced(None)
            .account_path(Some(db_path.clone()))
            .network(network)
            .id(id.clone())
            .preferred_address_type(address_type.clone())
            .index(index)
            .build_from_file(Some(db_path.clone()));
        match ng_account {
            Ok(mut ng_account) => {
                match ng_account.persist() {
                    Ok(_) => {
                        Ok(EnvoyAccountHandler {
                            stream_sink: None,
                            mempool_txs: vec![],
                            id: id.clone(),
                            ng_account: Arc::new(Mutex::new(ng_account)),
                        })
                    }
                    Err(_) => {
                        return Err(anyhow!("Failed to persist account"));
                    }
                }
            }
            Err(e) => {
                return Err(anyhow!("Failed to create account : {}", e));
            }
        }
    }

    pub fn migrate(
        name: String,
        id: String,
        device_serial: Option<String>,
        date_added: Option<String>,
        address_type: AddressType,
        color: String,
        index: u32,
        descriptors: Vec<NgDescriptor>,
        db_path: String,
        legacy_sled_db_path: Vec<String>,
        network: Network,
    ) -> Result<EnvoyAccountHandler> {
        let descriptors = Self::get_descriptors(&descriptors, db_path.clone());

        let ng_account = NgAccountBuilder::default()
            .name(name.clone())
            .color(color.clone())
            .descriptors(descriptors)
            .device_serial(device_serial)
            .date_added(date_added)
            .date_synced(None)
            .account_path(Some(db_path.clone()))
            .network(network)
            .id(id.clone())
            .preferred_address_type(address_type.clone())
            .index(index)
            .build_from_file(Some(db_path.clone()));


        match ng_account {
            Ok(ng_account) => {
                let account = EnvoyAccountHandler {
                    stream_sink: None,
                    mempool_txs: vec![],
                    id: id.clone(),
                    ng_account: Arc::new(Mutex::new(ng_account)),
                };

                for (index, sled_path) in legacy_sled_db_path.iter().enumerate() {
                    let sled_db_path = Path::new(&sled_path).to_path_buf();
                    let indexes = get_last_used_index(&sled_db_path, name.clone());
                    info!("Opening sled database at: {} {:?}", sled_db_path.clone().display(),indexes.clone());
                    let mut account = account.ng_account.lock().unwrap();
                    let ngwallet = &mut account.wallets[index];
                    match ngwallet
                        .reveal_addresses_up_to(
                            KeychainKind::Internal,
                            *indexes.get(&KeychainKind::Internal).unwrap_or(&0),
                        ) {
                        Ok(_) => {
                            info!("Revealed addresses up to index Internal: {:?}", indexes);
                        }
                        Err(e) => {
                            info!("Error  up to index Internal: {:?}", e);
                        }
                    };

                    match ngwallet
                        .reveal_addresses_up_to(
                            KeychainKind::External,
                            *indexes.get(&KeychainKind::External).unwrap_or(&0),
                        ) {
                        Ok(_) => {
                            info!("Revealed addresses up to index External: {:?}", indexes);
                        }
                        Err(e) => {
                            info!("Error  up to index External: {:?}", e);
                        }
                    };
                }

                Ok(account)
            }
            Err(er) => {
                return Err(anyhow!("Failed to create account: {}", er));
            }
        }
    }

    pub fn stream(&mut self, stream_sink: StreamSink<EnvoyAccount>) {
        self.stream_sink = Some(stream_sink);
    }

    pub fn open_account(db_path: String) -> Result<EnvoyAccountHandler> {
        let config = NgAccount::<Connection>::read_config_from_file(Some(db_path.clone()));
        let Some(config) = config else {
            return Err(anyhow!("Failed to read config"));
        };
        match Self::from_config(db_path, config) {
            Ok(account) => {
                Ok(account)
            }
            Err(err) => {
                return Err(anyhow!("Failed to load account: {}", err));
            }
        }
    }

    pub fn from_config(db_path: String, config: NgAccountConfig) -> Result<EnvoyAccountHandler> {
        let descriptors = config.descriptors.
            iter()
            .enumerate()
            .map(|(index, descriptor)| {
                let internal = descriptor.clone().internal;
                let external = descriptor.clone().external;
                let bdk_db_path = Path::new(&db_path.clone()).join(format!("wallet_{}_{:?}.sqlite", index, descriptor.address_type));
                Descriptor {
                    internal: internal.clone(),
                    external,
                    bdk_persister: Arc::new(Mutex::new(Connection::open(bdk_db_path).unwrap())),
                }
            }).collect();

        let ng_account = NgAccount::open_account_from_file(
            descriptors,
            Some(db_path),
        );
        match ng_account {
            Ok(ng_account) => {
                let account = EnvoyAccountHandler {
                    stream_sink: None,
                    mempool_txs: vec![],
                    id: ng_account.config.clone().id,
                    ng_account: Arc::new(Mutex::new(ng_account)),
                };
                Ok(account)
            }
            Err(e) => {
                return Err(anyhow!("Failed to open account: {}", e));
            }
        }
    }

    pub fn rename_account(&mut self, name: &str) -> Result<()> {
        {
            let mut account = self.ng_account.lock().unwrap();
            account.rename(name).unwrap();
        }
        self.send_update();
        Ok(())
    }
    pub fn set_preferred_address_type(&mut self, address_type: AddressType) -> Result<()> {
        {
            let mut account = self.ng_account.lock().unwrap();
            account.set_preferred_address_type(address_type).unwrap();
        }
        self.send_update();
        Ok(())
    }

    pub fn state(&mut self) -> Result<EnvoyAccount, Error> {
        return match self.ng_account.lock() {
            Ok(mut account) => {
                let config = account.config.clone();
                let balance = account.balance().unwrap_or_default().total().to_sat();
                let wallet_transactions = account.transactions().unwrap_or_default();
                let utxo = account.utxos().unwrap_or_default();
                let tags = account.list_tags().unwrap_or_default();

                let mut transactions = vec![];

                wallet_transactions.clone().iter().for_each(|tx| {
                    transactions.push(tx.clone());
                });

                for (index, tx) in self.mempool_txs.clone().iter().enumerate() {
                    let tx_id = tx.tx_id.to_string();
                    let mut found = false;
                    for wallet_tx in wallet_transactions.clone().iter() {
                        if wallet_tx.tx_id == tx_id {
                            found = true;
                            self.mempool_txs.remove(index);
                            break;
                        }
                    }
                    if !found {
                        transactions.push(tx.clone());
                    }
                }
                let next_address = account
                    .next_address()
                    .unwrap_or_default()
                    .iter()
                    .map(|(address, address_type)| (address.to_string(), address_type.clone()))
                    .collect::<Vec<(String, AddressType)>>();
                Ok(EnvoyAccount {
                    name: config.name.clone(),
                    color: config.color.clone(),
                    device_serial: config.device_serial.clone(),
                    date_added: config.date_added.clone(),
                    preferred_address_type: config.preferred_address_type,
                    index: config.index,
                    descriptors: config.descriptors.clone(),
                    date_synced: config.date_synced.clone(),
                    wallet_path: config.account_path.clone(),
                    network: config.network,
                    id: config.id.clone(),
                    is_hot: account.is_hot(),
                    seed_has_passphrase: config.seed_has_passphrase,
                    next_address,
                    balance,
                    transactions,
                    unlocked_balance: 0,
                    utxo: utxo.clone(),
                    tags,
                })
            }
            Err(error) => Err(anyhow!("Failed to lock account: {}", error)),
        };
    }

    pub fn next_address(&mut self) -> Vec<(String, AddressType)> {
        self.ng_account
            .lock()
            .unwrap()
            .next_address()
            .unwrap()
            .iter().map(|(address_info, address_type)| {
            (
                address_info.address.to_string(),
                address_type.clone(),
            )
        }).collect::<Vec<(String, AddressType)>>()
    }

    pub fn request_full_scan(&mut self, address_type: AddressType) -> Arc<Mutex<Option<FullScanRequest<KeychainKind>>>> {
        let scan_request_result = self.ng_account.lock().unwrap().full_scan_request(address_type);
        match scan_request_result {
            Ok((_, request)) => Arc::new(Mutex::new(Some(request))),
            Err(_) => return Arc::new(Mutex::new(None)),
        }
    }

    pub fn update_broadcast_state(&mut self, draft_transaction: DraftTransaction) {
        let mut tx = draft_transaction.transaction;
        let now = Utc::now();
        //transaction list will show fee+amount
        tx.amount = -(((tx.amount.abs() as u64) + tx.fee) as i64);
        //use current timestamp. this will be used for sorting
        tx.date = Some(now.timestamp() as u64);
        self.mempool_txs.push(tx.clone());
        {
            let mut account = self.ng_account.lock().unwrap();
            if tx.note.is_some() {
                account
                    .set_note_unchecked(&tx.tx_id.to_string(), &tx.note.unwrap())
                    .unwrap();
            }
            for output in tx.outputs.iter() {
                if output.tag.is_some() {
                    account
                        .set_tag(output, &output.tag.clone().unwrap())
                        .unwrap();
                }
            }
        }

        let tx = BASE64_STANDARD
            .decode(draft_transaction.psbt_base64)
            .map_err(|e| anyhow::anyhow!("Failed to decode PSBT: {}", e))
            .unwrap();
        let psbt = Psbt::deserialize(tx.as_slice())
            .map_err(|er| anyhow::anyhow!("Failed to deserialize PSBT: {}", er))
            .unwrap();
        {
            let account = self.ng_account.lock().unwrap();
            account.mark_utxo_as_used(psbt.unsigned_tx.clone());
        }
        self.send_update();
    }

    pub fn sync_request(&mut self, address_type: AddressType) -> Arc<Mutex<Option<SyncRequest<(KeychainKind, u32)>>>> {
        let scan_request = self.ng_account.lock().unwrap().sync_request(address_type);
        match scan_request {
            Ok((_, request)) => Arc::new(Mutex::new(Some(request))),
            Err(_) => return Arc::new(Mutex::new(None)),
        }
    }

    //cannot use sync since it is used by flutter_rust_bridge
    pub fn sync_wallet(
        sync_request: Arc<Mutex<Option<SyncRequest<(KeychainKind, u32)>>>>,
        electrum_server: &str,
        tor_port: Option<u16>,
    ) -> Result<Arc<Mutex<Update>>, Error> {
        let socks_proxy = tor_port.map(|port| format!("127.0.0.1:{}", port));
        let socks_proxy = socks_proxy.as_ref().map(|s| s.as_str());
        let mut scan_request_guard = sync_request.lock().unwrap();
        return if let Some(sync_request) = scan_request_guard.take() {
            // Use take() to move
            let update =
                NgWallet::<Connection>::sync(sync_request, electrum_server, socks_proxy).unwrap();
            Ok(Arc::new(Mutex::new(Update::from(update))))
        } else {
            Err(anyhow!("No sync request found"))
        };
    }

    pub fn scan_wallet(
        scan_request: Arc<Mutex<Option<FullScanRequest<KeychainKind>>>>,
        electrum_server: &str,
        tor_port: Option<u16>,
    ) -> Result<Arc<Mutex<Update>>, Error> {
        let socks_proxy = tor_port.map(|port| format!("127.0.0.1:{}", port));
        let socks_proxy = socks_proxy.as_ref().map(|s| s.as_str());
        let mut scan_request_guard = scan_request.lock().expect(
            "Failed to lock scan request mutex",
        );
        return if let Some(scan_request) = scan_request_guard.take() {
            // Use take() to move the value out
            // Simulate a delay for the scan operation
            match NgWallet::<Connection>::scan(scan_request, electrum_server, socks_proxy) {
                Ok(update) => {
                    Ok(Arc::new(Mutex::new(Update::from(update))))
                }
                Err(er) => {
                    Err(anyhow!("Error during scan: {}", er))
                }
            }
        } else {
            Err(anyhow!("No Scan request found"))
        };
    }

    pub fn apply_update(&mut self, update: Arc<Mutex<Update>>, address_type: AddressType) {
        let scan_request_guard = update.lock().unwrap();
        {
            let mut account = self.ng_account.lock().unwrap();
            account.apply((address_type, scan_request_guard.to_owned(), )).unwrap();
            account.config.date_synced = Some(format!("{:?}", Utc::now()));
            account.persist().unwrap();
        }
        self.send_update();
    }

    pub fn send_update(&mut self) {
        if let Some(sink) = self.stream_sink.clone() {
            sink.add(self.state().unwrap()).unwrap();
        };
    }
    #[frb(sync)]
    pub fn balance(&mut self) -> u64 {
        self.ng_account
            .lock()
            .unwrap()
            .balance()
            .unwrap()
            .total()
            .to_sat()
    }
    pub fn utxo(&mut self) -> Vec<Output> {
        self.ng_account
            .lock()
            .unwrap()
            .utxos()
            .unwrap_or_default()
    }
    pub fn transactions(&mut self) -> Vec<BitcoinTransaction> {
        self.ng_account
            .lock()
            .unwrap()
            .transactions()
            .unwrap()
    }
    pub fn set_tag(&mut self, utxo: &Output, tag: &str) -> Result<bool> {
        let status = self.ng_account.lock().unwrap().set_tag(utxo, tag);
        self.send_update();
        status
    }
    pub fn set_tags(&mut self, utxo: Vec<Output>, tag: &str) -> Result<bool> {
        utxo.iter().for_each(|utxo| {
            self.ng_account
                .lock()
                .unwrap()
                .set_tag(utxo, tag)
                .unwrap();
        });
        self.send_update();
        Ok(true)
    }
    pub fn set_do_not_spend(&mut self, utxo: &Output, do_not_spend: bool) -> Result<()> {
        let result = self
            .ng_account
            .lock()
            .unwrap()
            .set_do_not_spend(utxo, do_not_spend);
        self.send_update();
        result
    }
    pub fn set_do_not_spend_multiple(
        &mut self,
        utxo: Vec<String>,
        do_not_spend: bool,
    ) -> Result<()> {
        let utxos = self.utxo();

        utxos
            .iter()
            .filter(|x| utxo.contains(&x.get_id().clone()))
            .for_each(|output| {
                self.ng_account
                    .lock()
                    .unwrap()
                    .set_do_not_spend(output, do_not_spend)
                    .unwrap();
            });
        self.send_update();
        Ok(())
    }
    pub fn set_tag_multiple(&mut self, utxo: Vec<String>, tag: &str) -> Result<()> {
        let utxos = self.utxo();
        utxos
            .iter()
            .filter(|x| utxo.contains(&x.get_id().clone()))
            .for_each(|output| {
                self.ng_account
                    .lock()
                    .unwrap()
                    .set_tag(output, tag)
                    .unwrap();
            });
        self.send_update();
        Ok(())
    }
    pub fn rename_tag(&mut self, existing_tag: &str, new_tag: Option<String>) -> Result<()> {
        //update tag listing table with new tag
        let new_tag_ref = match &new_tag {
            None => None,
            Some(tag) => Some(tag.as_str()),
        };
        self.ng_account
            .lock()
            .unwrap()
            .remove_tag(existing_tag, new_tag_ref)
            .unwrap();
        self.send_update();
        Ok(())
    }
    pub fn set_note(&mut self, tx_id: &str, note: &str) -> Result<bool> {
        let result = self.ng_account.lock().unwrap().set_note(tx_id, note);
        self.send_update();
        result
    }
    #[frb(sync)]
    pub fn is_hot(&self) -> bool {
        self.ng_account.lock().unwrap().is_hot()
    }
    #[frb(sync)]
    pub fn config(&self) -> NgAccountConfig {
        self.ng_account.lock().unwrap().config.clone()
    }
    #[frb(sync)]
    pub fn id(&self) -> String {
        self.id.clone()
    }

    pub fn get_max_fee(
        &mut self,
        transaction_params: TransactionParams,
    ) -> Result<TransactionFeeResult, ComposeTxError> {
        self.ng_account
            .lock()
            .unwrap()
            .get_max_fee(transaction_params)
            .map_err(ComposeTxError::map_err)
    }

    pub fn compose_psbt(
        &mut self,
        transaction_params: TransactionParams,
    ) -> Result<DraftTransaction, ComposeTxError> {
        self.ng_account
            .lock()
            .unwrap()
            .compose_psbt(transaction_params)
            .map_err(ComposeTxError::map_err)
    }

    pub fn compose_cancellation_tx(
        &mut self,
        bitcoin_transaction: BitcoinTransaction,
    ) -> Result<DraftTransaction, BumpFeeError> {
        self.ng_account
            .lock()
            .unwrap()
            .compose_cancellation_tx(bitcoin_transaction)
    }

    pub fn get_max_bump_fee_rates(
        &mut self,
        selected_outputs: Vec<Output>,
        bitcoin_transaction: BitcoinTransaction,
    ) -> Result<TransactionFeeResult, BumpFeeError> {
        self.ng_account
            .lock()
            .unwrap()
            .get_max_bump_fee(selected_outputs, bitcoin_transaction)
    }

    pub fn compose_rbf_psbt(
        &mut self,
        selected_outputs: Vec<Output>,
        fee_rate: u64,
        bitcoin_transaction: BitcoinTransaction,
    ) -> Result<DraftTransaction, BumpFeeError> {
        self.ng_account.lock().unwrap().get_rbf_draft_tx(
            selected_outputs,
            bitcoin_transaction,
            fee_rate,
        )
    }

    pub fn decode_psbt(
        draft_transaction: DraftTransaction,
        psbt_base64: &str,
    ) -> Result<DraftTransaction> {
        NgAccount::<Connection>::decode_psbt(draft_transaction, psbt_base64)
    }

    pub fn broadcast(
        draft_transaction: DraftTransaction,
        electrum_server: &str,
        tor_port: Option<u16>,
    ) -> std::result::Result<String, BroadcastError> {
        let socks_proxy = tor_port.map(|port| format!("127.0.0.1:{}", port));
        let socks_proxy = socks_proxy.as_ref().map(|s| s.as_str());
        NgAccount::<Connection>::broadcast_psbt(draft_transaction, electrum_server, socks_proxy)
            .map_err(BroadcastError::from)
            .map(|tx_id| tx_id.to_string())
    }
    pub fn validate_address(address: &str, network: Option<Network>) -> bool {
        return match Address::from_str(address) {
            Ok(address) => match network {
                None => true,
                Some(network) => address.require_network(network).is_ok(),
            },
            Err(_) => false,
        };
    }

    pub fn add_descriptor(&mut self,
                          ng_descriptor: NgDescriptor) -> Result<()> {
        let result = {
            let mut account = self.ng_account.lock().unwrap();
            let path = Self::bdk_db_path(&account.config.account_path.clone().expect("Unable get account path"), account.config.descriptors.len(), &ng_descriptor);
            if path.exists() {
                return Err(anyhow!("Descriptor already exists"));
            }
            let descriptor = Self::get_descriptor(&ng_descriptor, path);
            account.add_new_descriptor(&descriptor)
        };
        match result {
            Ok(_) => {
                self.send_update();
                Ok(())
            }
            Err(err) => {
                Err(anyhow!("Failed to add descriptor : {:?}", err))
            }
        }
    }

    fn get_descriptors(descriptors: &Vec<NgDescriptor>, db_path: String) -> Vec<Descriptor<Connection>> {
        descriptors
            .iter()
            .enumerate()
            .map(|(index, descriptor)| {
                Self::get_descriptor(descriptor, Self::bdk_db_path(&db_path, index, descriptor))
            })
            .collect::<Vec<Descriptor<Connection>>>()
    }

    fn get_descriptor(descriptor: &NgDescriptor, bdk_db_path: PathBuf) -> Descriptor<Connection> {
        let internal = descriptor.clone().internal;
        let external = descriptor.clone().external;
        let connection = Connection::open(bdk_db_path).unwrap();
        Descriptor {
            internal: internal.clone(),
            external,
            bdk_persister: Arc::new(Mutex::new(connection)),
        }
    }

    fn bdk_db_path(db_path: &String, index: usize, descriptor: &NgDescriptor) -> PathBuf {
        let bdk_db_path = Path::new(&db_path.clone()).join(format!("wallet_{}_{:?}.sqlite", index, descriptor.address_type));
        bdk_db_path
    }

    pub fn get_account_backup(
        &mut self,
    ) -> Result<String> {
        match self.ng_account.lock().unwrap().get_backup_json() {
            Ok(json) => {
                Ok(json)
            }
            Err(er) => {
                Err(anyhow!("Failed to get backup {:?}", er))
            }
        }
    }


    pub fn restore_from_backup(
        backup_json: &str,
        db_path: String,
        seed: Option<String>,
        passphrase: Option<String>,
    ) -> Result<EnvoyAccountHandler> {
        match NgAccountBackup::deserialize(backup_json) {
            Ok(backup) => {
                let config = backup.ng_account_config;
                let indexes = backup.last_used_index;
                if config.descriptors.is_empty() && seed.is_none() {
                    return Err(anyhow!("No descriptors or seed required for restore"));
                }
                let descriptors = {
                    if config.descriptors.is_empty() {
                        match EnvoyBip39::derive_descriptor_from_seed(
                            seed.unwrap().as_str(),
                            config.network,
                            passphrase,
                        ) {
                            Ok(descriptors) => {
                                let ng_descriptors = descriptors
                                    .iter()
                                    .filter(|descriptor| {
                                        //envoy hot wallets only support  P2wpkh, P2tr
                                        descriptor.address_type == AddressType::P2tr ||
                                            descriptor.address_type == AddressType::P2wpkh
                                    })
                                    .map(|descriptor| {
                                        NgDescriptor {
                                            internal: descriptor.internal_descriptor.clone(),
                                            external: Some(descriptor.external_descriptor.clone()),
                                            address_type: descriptor.address_type.clone(),
                                        }
                                    })
                                    .collect::<Vec<NgDescriptor>>();
                                Self::get_descriptors(&ng_descriptors, db_path.clone())
                            }
                            Err(err) => {
                                return Err(anyhow!("Failed to derive descriptor from seed: {:?}", err));
                            }
                        }
                    } else {
                        Self::get_descriptors(&config.descriptors, db_path.clone())
                    }
                };

                let ng_account = NgAccountBuilder::default()
                    .name(config.name.clone())
                    .color(config.color.clone())
                    .descriptors(descriptors)
                    .device_serial(config.device_serial)
                    .date_added(config.date_added)
                    .date_synced(config.date_synced)
                    .account_path(Some(db_path.clone()))
                    .network(config.network)
                    .id(config.id.clone())
                    .preferred_address_type(config.preferred_address_type)
                    .index(config.index)
                    .build_from_file(Some(db_path));

                match ng_account {
                    Ok(mut account) => {
                        // Reveal addresses up to the last used index
                        for mut wallet in &mut account.wallets {
                            let address_type = wallet.address_type;
                            for index in &indexes {
                                if index.0 == address_type {
                                    info!("Revealing addresses up to index: {:?}", index);
                                    let _ = wallet.reveal_addresses_up_to(
                                        index.1,
                                        index.2,
                                    ).unwrap_or_default();
                                }
                            }
                        }
                        Ok(EnvoyAccountHandler {
                            stream_sink: None,
                            mempool_txs: vec![],
                            id: config.id.clone(),
                            ng_account: Arc::new(Mutex::new(account)),
                        })
                    }
                    Err(err) => {
                        return Err(anyhow!("Failed to create account: {:?}", err));
                    }
                }
            }
            Err(_) => {
                return Err(anyhow!("Failed to deserialize backup"));
            }
        }
    }

    #[frb(sync)]
    pub fn get_config_from_backup(
        backup_json: &str,
    ) -> Result<NgAccountConfig> {
        match NgAccountBackup::deserialize(backup_json) {
            Ok(backup) => {
                let config = backup.ng_account_config;
                Ok(config)
            }
            Err(_) => {
                return Err(anyhow!("Failed to deserialize backup"));
            }
        }
    }


    pub fn add_account_from_config(
        config: NgAccountConfig,
        db_path: String,
    ) -> Result<EnvoyAccountHandler> {
        let descriptors = Self::get_descriptors(&config.descriptors, db_path.clone());

        let ng_account = NgAccountBuilder::default()
            .name(config.name.clone())
            .color(config.color.clone())
            .descriptors(descriptors)
            .device_serial(config.device_serial)
            .date_added(config.date_added)
            .date_synced(None)
            .account_path(Some(db_path.clone()))
            .network(config.network)
            .id(config.id.clone())
            .preferred_address_type(config.preferred_address_type.clone())
            .index(config.index)
            .build_from_file(Some(db_path.clone()));

        match ng_account {
            Ok(mut account) => {
                match account.persist() {
                    Ok(_) => {
                        Ok(EnvoyAccountHandler {
                            stream_sink: None,
                            mempool_txs: vec![],
                            id: config.id.clone(),
                            ng_account: Arc::new(Mutex::new(account)),
                        })
                    }
                    Err(err) => {
                        return Err(anyhow!("Failed to persist: {:?}", err));
                    }
                }
            }
            Err(err) => {
                return Err(anyhow!("Failed to create account: {:?}", err));
            }
        }
    }


    pub fn get_config_from_remote(
        remote_update: Vec<u8>,
    ) -> Result<NgAccountConfig> {
        NgAccountConfig::from_remote(remote_update)
    }
}
