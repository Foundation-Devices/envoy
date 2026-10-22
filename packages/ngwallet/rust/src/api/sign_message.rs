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

    /// Verify a signed message. Returns `true` if the signature is valid for
    /// the given message and address. The verification scheme (BIP-137 for
    /// legacy/SegWit, BIP-322 for Taproot) is selected from the address type.
    pub fn verify_message(message: &str, address: &str, signature: &str) -> Result<bool> {
        sign_message::verify_signed_message(message, address, signature)
            .map_err(|e| anyhow::anyhow!("{}", e))
    }
}

#[cfg(test)]
mod tests {
    use super::EnvoySignMessage;

    // BIP-322 basic test vector "No prefix fallback". With the `smp` prefix the
    // finalized BIP requires, it is the exact shape Passport Core emits for a
    // taproot address. Without it, it is the form taproot signatures took
    // before the prefix existed, including Envoy's own earlier hot-wallet
    // signatures. The ngwallet Envoy links must accept both.
    const ADDRESS: &str = "bc1pss0zhytly75awhm6x2hhvd5lnzv3vssgrf9axfheq8ldyzn88ges79fler";
    const MESSAGE: &str = "No prefix fallback";
    const WITNESS: &str =
        "AUCJYOwOjxYAvatTAGYaVlNXBVyFuc4MwNQkOuK2tl8xhfKDONd0NjfYyNSYcRqeCp8hsAnCEPHAVEkO9h6vbQ/R";

    #[test]
    fn verifies_taproot_signature_with_and_without_prefix() {
        let prefixed = format!("smp{WITNESS}");
        for signature in [prefixed.as_str(), WITNESS] {
            assert!(EnvoySignMessage::verify_message(MESSAGE, ADDRESS, signature).unwrap());
            assert!(!EnvoySignMessage::verify_message("tampered", ADDRESS, signature).unwrap());
        }
    }
}
