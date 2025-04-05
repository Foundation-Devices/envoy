use std::collections::BTreeMap;
use std::fmt::format;
use std::fs::File;
use std::path::Path;
use std::str::FromStr;
use std::sync::{Arc, Mutex};
use std::{fs, thread};
use std::time::Duration;
use anyhow::{anyhow, Error, Result};
use bdk_wallet::chain::spk_client::{FullScanRequest, FullScanResponse, SyncRequest};
use bdk_wallet::rusqlite::{Connection, OpenFlags};
use bdk_wallet::{AddressInfo, KeychainKind, PersistedWallet, Update, Wallet, WalletTx};
use bdk_wallet::chain::{CheckPoint, Indexed};
use flutter_rust_bridge::frb;
use ngwallet::account::NgAccount;
use ngwallet::config::{AddressType, NgAccountConfig};
use ngwallet::ngwallet::NgWallet;
use ngwallet::transaction::{BitcoinTransaction, Output};
pub use bdk_wallet::bitcoin::{Network, Psbt, ScriptBuf};
use bdk_wallet::bitcoin::Address;
use bdk_wallet::bitcoin::address::{NetworkUnchecked, ParseError};
use log::info;
use ngwallet::redb::backends::FileBackend;
use crate::api::migration::get_last_used_index;
use crate::api::envoy_account::EnvoyAccount;
use crate::frb_generated::StreamSink;
use chrono::{DateTime, Local};
use std::env;


#[frb(init)]
pub fn init_app() {
    flutter_rust_bridge::setup_default_user_utils();
}

#[derive(Clone)]
pub struct EnvoyAccountHandler {
    pub streamSink: Option<StreamSink<EnvoyAccount>>,
    pub ng_account: Arc<Mutex<NgAccount<Connection>>>,
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
            streamSink: None,
            ng_account: Arc::new(Mutex::new(
                NgAccount::new_from_descriptor(
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
                )
            )),
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
            streamSink: None,
            ng_account: Arc::new(Mutex::new(
                NgAccount::new_from_descriptor(
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
                )
            )),
        };


        account.ng_account.lock().unwrap().wallet
            .reveal_addresses_up_to(KeychainKind::Internal, *indexes.get(&KeychainKind::Internal).unwrap_or(&0))
            .unwrap();

        account.ng_account.lock().unwrap().wallet
            .reveal_addresses_up_to(KeychainKind::External, *indexes.get(&KeychainKind::External).unwrap_or(&0))
            .unwrap();

        account
    }

    pub fn stream(
        &mut self,
        stream_sink: StreamSink<EnvoyAccount>,
    ) {
        self.streamSink = Some(stream_sink);
    }

    pub fn open_wallet(
        db_path: String,
    ) -> EnvoyAccountHandler {
        let bdk_db_path = Path::new(&db_path).join("wallet.sqlite");
        let connection = Connection::open(bdk_db_path.clone()).unwrap();
        info!("Opening BDK database at: {}", bdk_db_path.display());
        let mut account = EnvoyAccountHandler {
            streamSink: None,
            ng_account: Arc::new(Mutex::new(
                NgAccount::open_wallet(
                    db_path,
                    Arc::new(Mutex::new(connection)),
                    None::<FileBackend>,
                ))),
        };
        account.send_update();
        account
    }

    pub fn rename_account(&mut self, name: &str) -> Result<()> {
        {
            let mut account = self.ng_account
                .lock().unwrap();
            account.rename(name.clone()).unwrap();
        }
        self.send_update();
        Ok(())
    }

    pub fn state(&mut self) -> EnvoyAccount {
        let mut account = self.ng_account
            .lock().unwrap();
        let config = account.config.clone();
        let balance = account.wallet.balance().unwrap().total().to_sat();
        let transactions = account.wallet.transactions().unwrap_or(vec![]);
        let utxo = account.wallet.unspend_outputs().unwrap_or(vec![]);
        EnvoyAccount {
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
            is_hot: config.is_hot(),
            next_address: account.wallet.next_address().unwrap().address.to_string(),
            balance,
            transactions,
            utxo,
        }
    }

    pub fn next_address(&mut self) -> String {
        self.ng_account
            .lock().unwrap()
            .wallet.next_address().unwrap().address.to_string()
    }

    pub fn request_full_scan(&mut self) -> Arc<Mutex<Option<FullScanRequest<KeychainKind>>>> {
        let scan_request = self.ng_account
            .lock().unwrap()
            .wallet.full_scan_request();
        return Arc::new(Mutex::new(Some(scan_request)));
    }

    pub fn request_sync(&mut self) -> Arc<Mutex<Option<SyncRequest<(KeychainKind, u32)>>>> {
        let scan_request = self.ng_account
            .lock().unwrap()
            .wallet.sync_request();
        return Arc::new(Mutex::new(Some(scan_request)));
    }

    //cannot use sync since it is used by flutter_rust_bridge
    pub fn sync_wallet(sync_request: Arc<Mutex<Option<SyncRequest<(KeychainKind, u32)>>>>, electrum_server: &str, tor_port: Option<u16>) -> Result<Arc<Mutex<Update>>, Error> {
        let socks_proxy = tor_port.map(|port| format!("127.0.0.1:{}", port));
        let socks_proxy = socks_proxy.as_ref().map(|s| s.as_str());
        let mut scan_request_guard = sync_request.lock().unwrap();
        return if let Some(sync_request) = scan_request_guard.take() {  // Use take() to move
            let update = NgWallet::<Connection>::sync(sync_request, electrum_server, socks_proxy).unwrap();
            Ok(Arc::new(Mutex::new(Update::from(update))))
        } else {
            Err(anyhow!("No sync request found"))
        };
    }

    pub fn scan(scan_request: Arc<Mutex<Option<FullScanRequest<KeychainKind>>>>, electrum_server: &str, tor_port: Option<u16>) -> Result<Arc<Mutex<Update>>, Error> {
        let socks_proxy = tor_port.map(|port| format!("127.0.0.1:{}", port));
        let socks_proxy = socks_proxy.as_ref().map(|s| s.as_str());
        let mut scan_request_guard = scan_request.lock().unwrap();
        return if let Some(scan_request) = scan_request_guard.take() {  // Use take() to move the value out
            // Simulate a delay for the scan operation
            let update = NgWallet::<Connection>::scan(scan_request, electrum_server, socks_proxy).unwrap();
            Ok(Arc::new(Mutex::new(Update::from(update))))
        } else {
            Err(anyhow!("No Scan request found"))
        };
    }

    pub fn apply_update(&mut self, update: Arc<Mutex<Update>>) -> bool {
        let scan_request_guard = update.lock().unwrap();
        {
            let mut account = self.ng_account
                .lock().unwrap();
            account.wallet.apply(scan_request_guard.to_owned()).unwrap();
            account.config.date_synced = Some(format!("{:?}", chrono::Utc::now()));
            account.persist().unwrap();
        }
        self.send_update();
        return true;
    }

    pub fn send_update(&mut self) {
        if let Some(sink) = self.streamSink.clone() {
            sink.add(self.state()).unwrap();
        }
    }
    #[frb(sync)]
    pub fn balance(&mut self) -> u64 {
        self.ng_account
            .lock().unwrap()
            .wallet.balance().unwrap().total().to_sat()
    }
    pub fn utxo(&mut self) -> Vec<Output> {
        self.ng_account
            .lock().unwrap()
            .wallet.unspend_outputs().unwrap_or(vec![])
    }
    pub fn transactions(&mut self) -> Vec<BitcoinTransaction> {
        self.ng_account
            .lock().unwrap()
            .wallet.transactions().unwrap()
    }
    pub fn set_tag(&mut self, utxo: &Output, tag: &str) -> Result<bool> {
        self.ng_account
            .lock().unwrap()
            .wallet.set_tag(utxo, tag)
    }
    pub fn set_do_not_spend(&mut self, utxo: &Output, do_not_spend: bool) -> Result<bool> {
        self.ng_account
            .lock().unwrap()
            .wallet.set_do_not_spend(utxo, do_not_spend)
    }
    pub fn set_note(&mut self, tx_id: &str, note: &str) -> Result<bool> {
        self.ng_account
            .lock().unwrap()
            .wallet.set_note(tx_id, note).unwrap();
        self.send_update();
        Ok(true)
    }
    #[frb(sync)]
    pub fn is_hot(&self) -> bool {
        self.ng_account
            .lock().unwrap()
            .config.is_hot()
    }
    #[frb(sync)]
    pub fn config(&self) -> NgAccountConfig {
        self.ng_account.lock().unwrap().config.clone()
    }
    pub fn send(&mut self, address: String, amount: u64) -> Result<String, Error> {
        let result = self.ng_account
            .lock().unwrap()
            .wallet.
            create_send(address, amount)
            .map_err(|e| {
                anyhow!("Failed to create send transaction: {}", e)
            })?;
        Ok(result.serialize_hex())
    }
    pub fn broadcast(&mut self, psbt: String, electrum_server: &str) -> Result<(), Error> {
        self.ng_account
            .lock().unwrap()
            .wallet.
            broadcast(Psbt::from_str(&psbt).unwrap(), electrum_server)
            .map_err(|e| {
                anyhow!("Failed to broadcast: {}", e)
            })
    }
    pub fn validate_address(address: &str, network: Option<Network>) -> bool {
        return match Address::from_str(address) {
            Ok(address) => {
                match network {
                    None => {
                        true
                    }
                    Some(network) => {
                        match address.require_network(network) {
                            Ok(_) => {
                                true
                            }
                            Err(_) => {
                                false
                            }
                        }
                    }
                }
            }
            Err(_) => {
                false
            }
        };
    }
}
