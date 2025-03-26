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
use ngwallet::redb::backends::FileBackend;

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
                    None::<FileBackend>,
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
                    None::<FileBackend>,
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

#[cfg(test)]
mod tests {
    //     use bdk_wallet::KeychainKind;
//     use sled::Config;
    use sled::{Db, IVec, Tree};
    use std::error::Error;


    #[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
    pub enum KeychainKind {
        /// External
        External = 0,
        /// Internal, usually used for change outputs
        Internal = 1,
    }

    impl KeychainKind {
        /// Return [`KeychainKind`] as a byte
        pub fn as_byte(&self) -> u8 {
            match self {
                KeychainKind::External => b'e',
                KeychainKind::Internal => b'i',
            }
        }
    }

    impl AsRef<[u8]> for KeychainKind {
        fn as_ref(&self) -> &[u8] {
            match self {
                KeychainKind::External => b"e",
                KeychainKind::Internal => b"i",
            }
        }
    }

    pub(crate) enum MapKey {
        LastIndex(KeychainKind),
        SyncTime,
    }

    impl MapKey {
        fn as_prefix(&self) -> Vec<u8> {
            match self {
                MapKey::LastIndex(st) => [b"c", st.as_ref()].concat(),
                MapKey::SyncTime => b"l".to_vec(),
            }
        }
        fn serialize_content(&self) -> Vec<u8> {
            match self {
                _ => vec![],
            }
        }

        pub fn as_map_key(&self) -> Vec<u8> {
            let mut v = self.as_prefix();
            v.extend_from_slice(&self.serialize_content());
            v
        }
    }

    fn ivec_to_u32(b: IVec) -> Result<u32, Box<dyn Error>> {
        let array: [u8; 4] = b
            .as_ref()
            .try_into()
            .map_err(|_| "Invalid U32 Bytes")?;
        let val = u32::from_be_bytes(array);
        Ok(val)
    }

    fn get_last_index(db: &Tree, keychain: KeychainKind) -> Result<Option<u32>, Box<dyn Error>> {
        let key = MapKey::LastIndex(keychain).as_map_key();
        db.get(key)?.map(ivec_to_u32).transpose()
    }

    fn list_db_contents(db: &Db) -> Result<(), Box<dyn Error>> {
        for item in db.iter() {
            let (key, value) = item?;
            let key_str = std::str::from_utf8(&key)?;
            let value_str = std::str::from_utf8(&value)?;
            println!("Key: {}, Value: {}", key_str, value_str);
        }
        Ok(())
    }

    #[test]
    fn migration_test() {

        // Open the sled database
        let db = sled::open("c6f1b522-testnet-wpkh").unwrap();

        for (tn, tree_name) in db.tree_names().into_iter().enumerate() {
            let tree = db.open_tree(&tree_name)
                .unwrap();
            println!("Tree name: {},is tree empty ? : {}\n", std::str::from_utf8(&tree_name).unwrap(), tree.is_empty());
            // tree.iter().for_each(|item| {
            //     let (key, value) = item.unwrap();
            //     println!("Key: Value: {:?}", key);
            // });

            // println!("\n");
        }
        let db = db.open_tree("c6f1b522-testnet-wpkh".as_bytes())
            .unwrap();

        let external = db.get(MapKey::LastIndex(KeychainKind::External).as_map_key()).unwrap();
        let intenal = db.get(MapKey::LastIndex(KeychainKind::Internal).as_map_key()).unwrap();

        println!("last sync External: {:?}", external);
        println!("last sync Internal: {:?}", intenal);
    }
}