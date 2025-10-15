// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

use anyhow::Result;
use bip39::{Language, Mnemonic};
use log::info;
use ngwallet::bdk_wallet::bitcoin::Network;
use ngwallet::bdk_wallet::miniscript::descriptor::DescriptorType;
use ngwallet::bip39::{get_descriptors, get_random_seed};
use ngwallet::config::AddressType;
use ngwallet::bdk_wallet::bitcoin::bip32::{Fingerprint, Xpriv};
use ngwallet::bdk_wallet::bitcoin::key::Secp256k1;

pub struct Seed {
    pub mnemonic: String,
    pub xprv: String,
    pub fingerprint: String,
}
pub struct DerivedDescriptor {
    pub external_descriptor: String,
    pub internal_descriptor: String,
    pub external_pub_descriptor: String,
    pub internal_pub_descriptor: String,
    pub address_type: AddressType,
}

pub struct EnvoyBip39 {}

impl EnvoyBip39 {
    pub fn validate_seed(seed_words: &str) -> bool {
        Mnemonic::parse(seed_words).is_ok()
    }

    pub fn generate_seed() -> Result<String> {
        get_random_seed()
    }

    #[allow(dead_code)]
    fn generate_mnemonic() -> (Mnemonic, String) {
        let mnemonic = Mnemonic::generate_in(Language::English, 12).unwrap();
        let mnemonic_string = mnemonic.to_string();
        (mnemonic, mnemonic_string)
    }
    // String seed, network network, WalletType type, String? passphrase
    pub fn derive_descriptor_from_seed(
        seed_words: &str,
        network: Network,
        passphrase: Option<String>,
    ) -> Result<Vec<DerivedDescriptor>> {
        let mnemonic = Mnemonic::parse(seed_words)?;
        let seed = mnemonic.to_seed(passphrase.unwrap_or("".to_owned()));

        match get_descriptors(&seed, network, 0) {
            Ok(descriptors) => {
                let mut derived_descriptors = Vec::new();
                info!("Descriptors Size: {:?}", descriptors.len());
                for descriptor in descriptors {
                    let address_type = Self::get_address_type(descriptor.descriptor_type);
                    if let Some(address_type) = address_type {
                        let derived_descriptor = DerivedDescriptor {
                            external_descriptor: descriptor.descriptor_xprv(),
                            external_pub_descriptor: descriptor.descriptor_xpub(),
                            internal_pub_descriptor: descriptor.change_descriptor_xpub(),
                            internal_descriptor: descriptor.change_descriptor_xprv(),
                            address_type,
                        };
                        derived_descriptors.push(derived_descriptor);
                    }
                }
                Ok(derived_descriptors)
            }
            Err(er) => {
                println!("Error: {}", er);
                Err(anyhow::anyhow!("Failed to derive descriptors"))
            }
        }
    }

    pub  fn derive_fingerprint_from_seed(
        seed_words: &str,
        passphrase: Option<String>,
        network: Network,
    ) -> Result<String> {
        let mnemonic = Mnemonic::parse(seed_words)?;
        let seed = mnemonic.to_seed(passphrase.unwrap_or("".to_owned()));
        let xprv: Xpriv = Xpriv::new_master(network, &seed)?;
        let fingerprint = xprv.fingerprint(&Secp256k1::new());
        Ok(fingerprint.to_string())
    }
    //
    fn get_address_type(descriptor_type: DescriptorType) -> Option<AddressType> {
        match descriptor_type {
            DescriptorType::Pkh => Some(AddressType::P2pkh),
            DescriptorType::Sh => Some(AddressType::P2sh),
            DescriptorType::Wpkh => Some(AddressType::P2wpkh),
            DescriptorType::Wsh => Some(AddressType::P2wsh),
            DescriptorType::Tr => Some(AddressType::P2tr),
            DescriptorType::ShWpkh => Some(AddressType::P2ShWpkh),
            _ => None,
        }
    }
}
