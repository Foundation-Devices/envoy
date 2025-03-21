use std::collections::BTreeMap;
use std::str::FromStr;
use std::sync::{Arc, Mutex};
use std::thread;
use std::time::Duration;
use anyhow::{anyhow, Error};
use bdk_wallet::bitcoin::{Psbt, ScriptBuf};
use bdk_wallet::chain::spk_client::{FullScanRequest, FullScanResponse};
use bdk_wallet::rusqlite::Connection;
use bdk_wallet::{AddressInfo, KeychainKind, PersistedWallet, Update, Wallet, WalletTx};
use bdk_wallet::chain::{CheckPoint, Indexed};
use flutter_rust_bridge::frb;
use ngwallet::account::NgAccount;
use ngwallet::ngwallet::NgWallet;
use ngwallet::transaction::{BitcoinTransaction, Output};

#[frb(init)]
pub fn init_app() {
    flutter_rust_bridge::setup_default_user_utils();
}

pub struct EnvoyAccount {
    pub ng_account: Arc<Mutex<NgAccount>>,
}

// Envoy Wallet is a wrapper around NgWallet for Envoy app specific functionalities
impl EnvoyAccount {
    pub fn new_from_descriptor(
        name: String,
        descriptor: String,
        device_serial: Option<String>,
        color: String,
        index: u32,
        db_path: Option<String>,
    ) -> EnvoyAccount {
        EnvoyAccount {
            ng_account: Arc::new(Mutex::new(
                NgAccount::new_from_descriptor(
                    name,
                    color,
                    device_serial,
                    descriptor,
                    index,
                    db_path,
                )
            )),
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

    pub fn scan(scan_request: Arc<Mutex<Option<FullScanRequest<KeychainKind>>>>) -> Arc<Mutex<Option<FullScanResponse<KeychainKind>>>> {
        let mut scan_request_guard = scan_request.lock().unwrap();
        return if let Some(scan_request) = scan_request_guard.take() {  // Use take() to move the value out
            // Simulate a delay for the scan operation
            let update = NgWallet::scan(scan_request).unwrap();
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
    pub fn set_tag(&mut self, utxo: &Output, tag: String) {
        self.ng_account
            .lock().unwrap()
            .wallet.set_tag(utxo, tag);
    }
    pub fn set_do_not_spend(&mut self, utxo: &Output, do_not_spend: bool) {
        self.ng_account
            .lock().unwrap()
            .wallet.set_do_not_spend(utxo, do_not_spend);
    }
    pub fn set_note(&mut self, tx_id: String, note: String) {
        self.ng_account
            .lock().unwrap()
            .wallet.set_note(&tx_id, &note);
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
    pub fn broadcast(&mut self, psbt: String) -> Result<(), Error> {
        self.ng_account
            .lock().unwrap()
            .wallet.
            broadcast(Psbt::from_str(&psbt).unwrap())
            .map_err(|e| {
                anyhow!("Failed to broadcast: {}", e)
            })
    }
}
