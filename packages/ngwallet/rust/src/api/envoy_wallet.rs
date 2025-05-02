// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

use crate::api::envoy_account::EnvoyAccount;
use crate::api::errors::{BroadcastError, ComposeTxError};
use crate::api::migration::get_last_used_index;
use crate::frb_generated::StreamSink;
use anyhow::{anyhow, Error, Result};
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
use bdk_wallet::descriptor::DescriptorError;
use bdk_wallet::error::{CreateTxError, MiniscriptPsbtError};
use bdk_wallet::rusqlite::{Connection, OpenFlags};
use bdk_wallet::serde::{Deserialize, Serialize};
use bdk_wallet::{
    bitcoin, coin_selection, AddressInfo, KeychainKind, PersistedWallet, Update, Wallet, WalletTx,
};
use chrono::{DateTime, Local, Utc};
use flutter_rust_bridge::frb;
use log::info;
use ngwallet::account::NgAccount;
use ngwallet::config::{AddressType, NgAccountConfig};
use ngwallet::ngwallet::NgWallet;
use ngwallet::rbf::BumpFeeError;
use ngwallet::redb::backends::FileBackend;
use ngwallet::send::{DraftTransaction, TransactionFeeResult, TransactionParams};
use ngwallet::transaction::{BitcoinTransaction, Output};
use std::collections::BTreeMap;
use std::env;
use std::fmt::format;
use std::fs::File;
use std::path::Path;
use std::str::FromStr;
use std::sync::{Arc, LockResult, Mutex};
use std::time::{Duration, SystemTime, UNIX_EPOCH};
use std::{fs, thread};

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
        internal_descriptor: String,
        external_descriptor: String,
        db_path: String,
        network: Network,
        id: String,
    ) -> EnvoyAccountHandler {
        let bdk_db_path = Path::new(&db_path).join("wallet.sqlite");

        let connection = Connection::open(bdk_db_path).unwrap();
        info!("Creating BDK database ");

        EnvoyAccountHandler {
            stream_sink: None,
            mempool_txs: vec![],
            id: id.clone(),
            ng_account: Arc::new(Mutex::new(NgAccount::new_from_descriptor(
                name,
                color,
                device_serial,
                date_added,
                network,
                address_type,
                internal_descriptor,
                Some(external_descriptor),
                index,
                Some(db_path),
                Arc::new(Mutex::new(connection)),
                None::<FileBackend>,
                id.clone(),
                None,
            ))),
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
        internal_descriptor: String,
        external_descriptor: String,
        db_path: String,
        sled_db_path: String,
        network: Network,
    ) -> EnvoyAccountHandler {
        let bdk_db_path = Path::new(&db_path.clone()).join("wallet.sqlite");
        let sled_db_path = Path::new(&sled_db_path).to_path_buf();
        let connection = Connection::open(bdk_db_path).unwrap();
        let indexes = get_last_used_index(&sled_db_path, name.clone());
        let account = EnvoyAccountHandler {
            stream_sink: None,
            mempool_txs: vec![],
            id: id.clone(),
            ng_account: Arc::new(Mutex::new(NgAccount::new_from_descriptor(
                name,
                color,
                device_serial,
                date_added,
                network,
                address_type,
                internal_descriptor,
                Some(external_descriptor),
                index,
                Some(db_path.clone()),
                Arc::new(Mutex::new(connection)),
                None::<FileBackend>,
                id.clone(),
                None,
            ))),
        };

        account
            .ng_account
            .lock()
            .unwrap()
            .wallet
            .reveal_addresses_up_to(
                KeychainKind::Internal,
                *indexes.get(&KeychainKind::Internal).unwrap_or(&0),
            )
            .unwrap();

        account
            .ng_account
            .lock()
            .unwrap()
            .wallet
            .reveal_addresses_up_to(
                KeychainKind::External,
                *indexes.get(&KeychainKind::External).unwrap_or(&0),
            )
            .unwrap();

        account
    }

    pub fn stream(&mut self, stream_sink: StreamSink<EnvoyAccount>) {
        self.stream_sink = Some(stream_sink);
    }

    pub fn open_wallet(db_path: String) -> EnvoyAccountHandler {
        let bdk_db_path = Path::new(&db_path).join("wallet.sqlite");
        let connection = Connection::open(bdk_db_path.clone()).unwrap();
        info!("Opening BDK database at: {}", bdk_db_path.display());
        let ng_account = NgAccount::open_wallet(
            db_path,
            Arc::new(Mutex::new(connection)),
            None::<FileBackend>,
        );
        let account = EnvoyAccountHandler {
            stream_sink: None,
            mempool_txs: vec![],
            id: ng_account.config.clone().id,
            ng_account: Arc::new(Mutex::new(ng_account)),
        };
        account
    }

    pub fn rename_account(&mut self, name: &str) -> Result<()> {
        {
            let mut account = self.ng_account.lock().unwrap();
            account.rename(name).unwrap();
        }
        self.send_update();
        Ok(())
    }

    pub fn state(&mut self) -> Result<EnvoyAccount, Error> {
        return match self.ng_account.lock() {
            Ok(mut account) => {
                let config = account.config.clone();
                let balance = account.wallet.balance().unwrap().total().to_sat();
                let wallet_transactions = account.wallet.transactions().unwrap_or(vec![]);
                let utxo = account.wallet.unspend_outputs().unwrap_or(vec![]);
                let tags = account.wallet.list_tags().unwrap_or(vec![]);

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

                Ok(EnvoyAccount {
                    name: config.name.clone(),
                    color: config.color.clone(),
                    device_serial: config.device_serial.clone(),
                    date_added: config.date_added.clone(),
                    address_type: config.address_type,
                    index: config.index,
                    internal_descriptor: config.internal_descriptor.clone(),
                    external_descriptor: config.external_descriptor.clone(),
                    date_synced: config.date_synced.clone(),
                    wallet_path: config.wallet_path.clone(),
                    network: config.network,
                    id: config.id.clone(),
                    is_hot: account.wallet.is_hot(),
                    next_address: account.wallet.next_address().unwrap().address.to_string(),
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

    pub fn next_address(&mut self) -> String {
        self.ng_account
            .lock()
            .unwrap()
            .wallet
            .next_address()
            .unwrap()
            .address
            .to_string()
    }

    pub fn request_full_scan(&mut self) -> Arc<Mutex<Option<FullScanRequest<KeychainKind>>>> {
        let scan_request = self.ng_account.lock().unwrap().wallet.full_scan_request();
        return Arc::new(Mutex::new(Some(scan_request)));
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
                    .wallet
                    .set_note_unchecked(&tx.tx_id.to_string(), &tx.note.unwrap())
                    .unwrap();
            }
            for output in tx.outputs.iter() {
                if output.tag.is_some() {
                    account
                        .wallet
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
            account.wallet.mark_utxo_as_used(psbt.unsigned_tx.clone());
        }
        self.send_update();
    }

    pub fn request_sync(&mut self) -> Arc<Mutex<Option<SyncRequest<(KeychainKind, u32)>>>> {
        let scan_request = self.ng_account.lock().unwrap().wallet.sync_request();
        return Arc::new(Mutex::new(Some(scan_request)));
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

    pub fn scan(
        scan_request: Arc<Mutex<Option<FullScanRequest<KeychainKind>>>>,
        electrum_server: &str,
        tor_port: Option<u16>,
    ) -> Result<Arc<Mutex<Update>>, Error> {
        let socks_proxy = tor_port.map(|port| format!("127.0.0.1:{}", port));
        let socks_proxy = socks_proxy.as_ref().map(|s| s.as_str());
        let mut scan_request_guard = scan_request.lock().unwrap();
        return if let Some(scan_request) = scan_request_guard.take() {
            // Use take() to move the value out
            // Simulate a delay for the scan operation
            let update =
                NgWallet::<Connection>::scan(scan_request, electrum_server, socks_proxy).unwrap();
            Ok(Arc::new(Mutex::new(Update::from(update))))
        } else {
            Err(anyhow!("No Scan request found"))
        };
    }

    pub fn apply_update(&mut self, update: Arc<Mutex<Update>>)  {
        let scan_request_guard = update.lock().unwrap();
        {
            let mut account = self.ng_account.lock().unwrap();
            account.wallet.apply(scan_request_guard.to_owned()).unwrap();
            account.config.date_synced = Some(format!("{:?}", chrono::Utc::now()));
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
            .wallet
            .balance()
            .unwrap()
            .total()
            .to_sat()
    }
    pub fn utxo(&mut self) -> Vec<Output> {
        self.ng_account
            .lock()
            .unwrap()
            .wallet
            .unspend_outputs()
            .unwrap_or_default()
    }
    pub fn transactions(&mut self) -> Vec<BitcoinTransaction> {
        self.ng_account
            .lock()
            .unwrap()
            .wallet
            .transactions()
            .unwrap()
    }
    pub fn set_tag(&mut self, utxo: &Output, tag: &str) -> Result<bool> {
        let status = self.ng_account.lock().unwrap().wallet.set_tag(utxo, tag);
        self.send_update();
        status
    }
    pub fn set_tags(&mut self, utxo: Vec<Output>, tag: &str) -> Result<bool> {
        utxo.iter().for_each(|utxo| {
            self.ng_account
                .lock()
                .unwrap()
                .wallet
                .set_tag(utxo, tag)
                .unwrap();
        });
        self.send_update();
        Ok(true)
    }
    pub fn set_do_not_spend(&mut self, utxo: &Output, do_not_spend: bool) -> Result<bool> {
        let result = self
            .ng_account
            .lock()
            .unwrap()
            .wallet
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
                    .wallet
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
                    .wallet
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
            .wallet
            .remove_tag(existing_tag, new_tag_ref)
            .unwrap();
        self.send_update();
        Ok(())
    }
    pub fn set_note(&mut self, tx_id: &str, note: &str) -> Result<bool> {
        let result = self.ng_account.lock().unwrap().wallet.set_note(tx_id, note);
        self.send_update();
        result
    }
    #[frb(sync)]
    pub fn is_hot(&self) -> bool {
        self.ng_account.lock().unwrap().wallet.is_hot()
    }
    #[frb(sync)]
    pub fn config(&self) -> NgAccountConfig {
        self.ng_account.lock().unwrap().config.clone()
    }
    #[frb(sync)]
    pub fn id(&self) -> String {
        self.id.clone()
    }
    pub fn send(&mut self, address: String, amount: u64) -> Result<String, Error> {
        let result = self
            .ng_account
            .lock()
            .unwrap()
            .wallet
            .create_send(address, amount)
            .map_err(|e| anyhow!("Failed to create send transaction: {}", e))?;
        Ok(result.serialize_hex())
    }

    pub fn get_max_fee(
        &mut self,
        transaction_params: TransactionParams,
    ) -> Result<TransactionFeeResult, ComposeTxError> {
        self.ng_account
            .lock()
            .unwrap()
            .wallet
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
            .wallet
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
            .wallet
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
            .wallet
            .get_max_bump_fee(selected_outputs, bitcoin_transaction)
    }

    pub fn compose_rbf_psbt(
        &mut self,
        selected_outputs: Vec<Output>,
        fee_rate: u64,
        bitcoin_transaction: BitcoinTransaction,
    ) -> Result<DraftTransaction, BumpFeeError> {
        self.ng_account.lock().unwrap().wallet.get_rbf_draft_tx(
            selected_outputs,
            bitcoin_transaction,
            fee_rate,
        )
    }

    pub fn decode_psbt(
        draft_transaction: DraftTransaction,
        psbt_base64: &str,
    ) -> Result<DraftTransaction> {
        NgWallet::<Connection>::decode_psbt(draft_transaction, psbt_base64)
    }

    pub fn broadcast(
        draft_transaction: DraftTransaction,
        electrum_server: &str,
        tor_port: Option<u16>,
    ) -> std::result::Result<String, BroadcastError> {
        let socks_proxy = tor_port.map(|port| format!("127.0.0.1:{}", port));
        let socks_proxy = socks_proxy.as_ref().map(|s| s.as_str());
        NgWallet::<Connection>::broadcast_psbt(draft_transaction, electrum_server, socks_proxy)
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
}
