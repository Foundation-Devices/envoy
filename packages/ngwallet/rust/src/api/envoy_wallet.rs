use std::collections::BTreeMap;
use std::fmt::format;
use std::fs::File;
use std::path::Path;
use std::str::FromStr;
use std::sync::{Arc, Mutex};
use std::{fs, thread};
use std::time::Duration;
use anyhow::{anyhow, Error, Result};
use bdk_wallet::chain::spk_client::{FullScanRequest, FullScanResponse};
use bdk_wallet::rusqlite::{Connection, OpenFlags};
use bdk_wallet::{AddressInfo, KeychainKind, PersistedWallet, Update, Wallet, WalletTx};
use bdk_wallet::chain::{CheckPoint, Indexed};
use flutter_rust_bridge::frb;
use ngwallet::account::NgAccount;
use ngwallet::config::{AddressType, NgAccountConfig};
use ngwallet::ngwallet::NgWallet;
use ngwallet::transaction::{BitcoinTransaction, Output};
pub use bdk_wallet::bitcoin::{Network, Psbt, ScriptBuf};
use log::info;

#[frb(init)]
pub fn init_app() {
    flutter_rust_bridge::setup_default_user_utils();
}

pub struct EnvoyAccount {
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
impl EnvoyAccount {
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
    ) -> EnvoyAccount {
        let bdk_db_path = Path::new(&db_path).join("wallet.sqlite");

        let connection = Connection::open(bdk_db_path).unwrap();
        info!("Creating BDK database ");

        EnvoyAccount {
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
                )
            )),
        }
    }

    pub fn open_wallet(
        db_path: String,
    ) -> EnvoyAccount {
        let bdk_db_path = Path::new(&db_path).join("wallet.sqlite");

        let connection = Connection::open(bdk_db_path.clone()).unwrap();
        info!("Opening BDK database at: {}", bdk_db_path.display());
        EnvoyAccount {
            ng_account: Arc::new(Mutex::new(
                NgAccount::open_wallet(
                    db_path,
                    Arc::new(Mutex::new(connection)),
                )))
        }
    }

    pub fn next_address(&mut self) -> String {
        self.ng_account
            .lock().unwrap()
            .wallet.next_address().unwrap().address.to_string()
    }

    pub fn request_scan(&mut self) -> Arc<Mutex<Option<FullScanRequest<KeychainKind>>>> {
        let scan_request = self.ng_account
            .lock().unwrap()
            .wallet.scan_request();
        return Arc::new(Mutex::new(Some(scan_request)));
    }


    pub fn scan(scan_request: Arc<Mutex<Option<FullScanRequest<KeychainKind>>>>, electrum_server: &str) -> Arc<Mutex<Option<FullScanResponse<KeychainKind>>>> {
        let mut scan_request_guard = scan_request.lock().unwrap();
        return if let Some(scan_request) = scan_request_guard.take() {  // Use take() to move the value out
            // Simulate a delay for the scan operation
            let update = NgWallet::<Connection>::scan(scan_request, electrum_server).unwrap();
            Arc::new(Mutex::new(Some(update)))
        } else {
            Arc::new(Mutex::new(None))
        };
    }

    pub fn apply_update(&mut self, scan_request: Arc<Mutex<Option<FullScanResponse<KeychainKind>>>>) -> bool {
        let mut scan_request_guard = scan_request.lock().unwrap();
        if let Some(scan_request) = scan_request_guard.take() {  // Use take() to move the value out
            self.ng_account
                .lock().unwrap()
                .wallet.apply(Update::from(scan_request)).unwrap();
            self.ng_account.lock().unwrap().persist().unwrap();
            return true;
        }
        return false;
    }

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
            .wallet.set_note(tx_id, note)
    }

    pub fn get_config(&self) -> NgAccountConfig {
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
}
