// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

use anyhow::Result;
use bip39::Mnemonic;
use ngwallet::bdk_wallet::bitcoin::Network;
use ngwallet::sign_message::{self, SignedMessage};

pub struct EnvoySignMessage {}

impl EnvoySignMessage {
    pub fn sign_message(
        seed_words: &str,
        passphrase: Option<String>,
        derivation_path: &str,
        message: &str,
        network: Network,
    ) -> Result<SignedMessage> {
        let mnemonic = Mnemonic::parse(seed_words)?;
        let seed = mnemonic.to_seed(passphrase.unwrap_or_default());
        sign_message::sign_message(&seed, derivation_path, message, network)
            .map_err(|e| anyhow::anyhow!("{}", e))
    }

    pub fn format_signed_message(signed: &SignedMessage) -> String {
        sign_message::format_signed_message(signed)
    }
}
