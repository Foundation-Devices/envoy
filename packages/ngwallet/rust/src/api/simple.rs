use anyhow::Result;
use bdk_wallet::bitcoin::Psbt;
use bdk_wallet::chain::spk_client::FullScanResponse;
use bdk_wallet::rusqlite::Connection;
use bdk_wallet::{AddressInfo, KeychainKind, PersistedWallet, Update, WalletTx};
use flutter_rust_bridge::frb;
pub use ngwallet::NgTransaction;
pub use ngwallet::NgWallet;

#[flutter_rust_bridge::frb(sync)] // Synchronous mode for simplicity of the demo
pub fn greet(name: String) -> String {
    format!("Hello, {name}!")
}

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    // Default utilities - feel free to customize
    flutter_rust_bridge::setup_default_user_utils();
}

#[flutter_rust_bridge::frb(opaque)]
pub struct Wallet {
    ngwallet: NgWallet,
}

impl Wallet {
    pub fn new(db_path: String) -> Wallet {
        Wallet {
            ngwallet: NgWallet::new(Some(db_path)).unwrap()
        }
    }

    pub fn next_address(&mut self) -> String {
        self.ngwallet.next_address().unwrap().address.to_string()
    }
}

// #[frb(external)]
// impl NgWallet {
//     pub fn new() -> Result<NgWallet> {
//
//     }
//
//     pub fn persist(&mut self) -> Result<bool> {
//
//     }
//
//     pub fn load() -> Result<NgWallet> {
//
//     }
//
//     pub fn next_address(&mut self) -> Result<AddressInfo> {
//
//     }
//
//     pub fn transactions(&self) -> Result<Vec<NgTransaction>> {
//
//     }
//
//     pub fn scan_request(&self) -> FullScanRequest<KeychainKind> {
//     }
//
//
//     pub fn scan(request: FullScanRequest<KeychainKind>) -> Result<FullScanResponse<KeychainKind>> {
//     }
//
//     pub fn apply(&mut self, update: Update) -> Result<()> {
//
//     }
//
//     pub fn balance(&self) -> Result<u64> {
//     }
//
//     pub fn create_send(&mut self, address: String, amount: u64) -> Result<Psbt> {
//
//     }
//
//     pub fn sign(&self, psbt: &Psbt) -> Result<Psbt> {}
//
//     pub fn broadcast(&mut self, psbt: Psbt) -> Result<()> {}
// }
