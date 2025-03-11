use flutter_rust_bridge::frb;
use anyhow::Result;
use bdk_wallet::{AddressInfo, KeychainKind, PersistedWallet, Update, WalletTx};
use bdk_wallet::bitcoin::Psbt;
use bdk_wallet::chain::spk_client::FullScanResponse;
use bdk_wallet::rusqlite::Connection;
use ngwallet::NgTransaction;
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

pub fn get_wallet() -> NgWallet {
    NgWallet::new().unwrap_or(NgWallet::load().unwrap())
}

#[frb(external)]
impl NgWallet {
    pub fn new() -> Result<NgWallet> {

    }

    pub fn persist(&mut self) -> Result<bool> {

    }

    pub fn load() -> Result<NgWallet> {

    }

    pub fn next_address(&mut self) -> Result<AddressInfo> {

    }

    pub fn transactions(&self) -> Vec<NgTransaction> {

    }

    pub fn scan(&self) -> Result<FullScanResponse<KeychainKind>> {

    }

    pub fn apply(&mut self, update: Update) -> Result<()> {

    }

    pub fn balance(&self) -> bdk_wallet::Balance {
    }

    pub fn create_send(&mut self, address: String, amount: u64) -> Result<Psbt> {

    }

    pub fn sign(&self, psbt: &Psbt) -> Result<Psbt> {}

    pub fn broadcast(&mut self, psbt: Psbt) -> Result<()> {}
}
