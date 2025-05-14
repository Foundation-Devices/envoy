// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

use anyhow::Result;
use bdk_wallet::bitcoin::Network;
use bdk_wallet::miniscript::descriptor::DescriptorType;
use bip39::{Language, Mnemonic};
use log::info;
use ngwallet::bip39::{Descriptors, get_descriptors, get_random_seed};
use ngwallet::config::AddressType;

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
        true
    }

    pub fn generate_seed() -> Result<String> {
        get_random_seed()
    }

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
        match  get_descriptors(
            seed_words.to_string(),
            network,
            passphrase,
        ) {
            Ok(descriptors) => {
                let mut derived_descriptors = Vec::new();
                info!("Descriptors Size: {:?}", descriptors.len());
                for descriptor in descriptors {
                    let address_type = Self::get_address_type(descriptor.descriptor_type);
                    if let Some(address_type) = address_type {
                        let derived_descriptor = DerivedDescriptor {
                            external_descriptor: descriptor.descriptor_xprv,
                            external_pub_descriptor: descriptor.descriptor_xpub,
                            internal_pub_descriptor: descriptor.change_descriptor_xpub,
                            internal_descriptor: descriptor.change_descriptor_xprv,
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

    //
    fn get_address_type(descriptor_type: DescriptorType) -> Option<AddressType> {
        match descriptor_type {
            DescriptorType::Pkh => Some(AddressType::P2pkh),
            DescriptorType::Sh => Some(AddressType::P2sh),
            DescriptorType::Wpkh => Some(AddressType::P2wpkh),
            DescriptorType::Wsh => Some(AddressType::P2wsh),
            DescriptorType::Tr => Some(AddressType::P2tr),
            DescriptorType::ShWpkh => Some(AddressType::P2ShWpkh),
            _ => {
                None
            }
        }
    }
}
