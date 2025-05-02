// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

use crate::api::envoy_account::EnvoyAccount;
use crate::api::envoy_wallet::EnvoyAccountHandler;
use anyhow::Result;
use bdk_wallet::bitcoin::bip32::{DerivationPath, KeySource};
use bdk_wallet::bitcoin::secp256k1::Secp256k1;
use bdk_wallet::bitcoin::Network;
use bdk_wallet::descriptor::Segwitv0;
use bdk_wallet::keys::bip39::MnemonicWithPassphrase;
use bdk_wallet::keys::DescriptorKey::Secret;
use bdk_wallet::keys::{DerivableKey, DescriptorKey, ExtendedKey, GeneratableKey};
use bdk_wallet::miniscript;
use bip39::{Language, Mnemonic};
use core::str::FromStr;
use ngwallet::config::AddressType;

pub struct Seed {
    pub mnemonic: String,
    pub xprv: String,
    pub fingerprint: String,
}
pub struct DescriptorFromSeed {
    pub external_descriptor: String,
    pub internal_descriptor: String,
    pub external_pub_descriptor: String,
    pub internal_pub_descriptor: String,
}

pub struct EnvoyBip39 {}

impl EnvoyBip39 {
    pub fn validate_seed(seed_words: &str) -> bool {
        Mnemonic::parse_in(Language::English, seed_words).is_ok()
    }

    pub fn generate_seed(network: Network) -> Seed {
        let secp = Secp256k1::new();

        let (mut mnemonic, mut mnemonic_string) = EnvoyBip39::generate_mnemonic();
        // SFT-2340: try until we get a valid mnemonic (moon rays bug)
        while Mnemonic::parse(mnemonic_string.clone()).is_err() {
            (mnemonic, mnemonic_string) = EnvoyBip39::generate_mnemonic();
        }

        let xkey: ExtendedKey<miniscript::BareCtx> = mnemonic.into_extended_key().unwrap();
        let xprv = xkey.into_xprv(network.into()).unwrap();

        let fingerprint = xprv.fingerprint(&secp);

        Seed {
            mnemonic: mnemonic_string,
            xprv: xprv.to_string(),
            fingerprint: fingerprint.to_string(),
        }
    }

    fn generate_mnemonic() -> (Mnemonic, String) {
        let mnemonic = Mnemonic::generate_in(Language::English, 12).unwrap();
        let mnemonic_string = mnemonic.to_string();
        (mnemonic, mnemonic_string)
    }
    // String seed, Network network, WalletType type, String? passphrase
    pub fn derive_descriptor_from_seed(
        seed_words: &str,
        network: Network,
        address_type: AddressType,
        derivation_path: &str,
        passphrase: Option<String>,
    ) -> Result<DescriptorFromSeed> {
        let mnemonic_words = Mnemonic::parse(seed_words)
            .map_err(|_| anyhow::anyhow!("Invalid seed"))
            .unwrap();

        let mnemonic: MnemonicWithPassphrase = {
            if passphrase.is_some() {
                (mnemonic_words, passphrase)
            } else {
                (mnemonic_words, None)
            }
        };

        let xkey: ExtendedKey = mnemonic.into_extended_key().unwrap();
        let derivation_path = DerivationPath::from_str(derivation_path).unwrap();
        let secp = Secp256k1::new();

        // Derive
        let xprv = xkey.into_xprv(network.into()).unwrap();

        let derived_xprv = &xprv.derive_priv(&secp, &derivation_path).unwrap();
        let origin: KeySource = (xprv.fingerprint(&secp), derivation_path);

        // Get descriptors
        let derived_xprv_desc_key: DescriptorKey<Segwitv0> = derived_xprv
            .into_descriptor_key(Some(origin), DerivationPath::default())
            .unwrap();

        let (descriptor_prv, descriptor_pub) = match derived_xprv_desc_key {
            DescriptorKey::Public(_, _, _) => {
                anyhow::bail!("Cannot derive private key from public key")
            }
            Secret(desc_seckey, _, _) => (desc_seckey.to_string(), {
                let desc_pubkey = desc_seckey.to_public(&secp).unwrap();
                desc_pubkey.to_string()
            }),
        };
        let wallet_type = match address_type {
            AddressType::P2wpkh => "wpkh",
            AddressType::P2wsh => "wsh",
            AddressType::P2tr => "tr",
            _ => "wpkh",
        };

        let external_pub_descriptor =
            format!("{wallet_type}({descriptor_pub})").replace("/*", "/0/*");
        let internal_pub_descriptor = external_pub_descriptor.replace("/0/*", "/1/*");

        let external_prv_descriptor =
            format!("{wallet_type}({descriptor_prv})").replace("/*", "/0/*");
        let internal_prv_descriptor = external_prv_descriptor.replace("/0/*", "/1/*");

        Ok(DescriptorFromSeed {
            external_descriptor: external_prv_descriptor,
            internal_descriptor: internal_prv_descriptor,
            external_pub_descriptor,
            internal_pub_descriptor,
        })
    }
}
