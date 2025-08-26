// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

use bdk_wallet::error::CreateTxError;
use bdk_wallet::KeychainKind;
use ngwallet::bdk_electrum::electrum_client::Error;
use ngwallet::rbf::BumpFeeError;
use ngwallet::send::TransactionComposeError;

pub enum TxComposeError {
    CoinSelectionError(String),
    Error(String),
    InsufficientFunds(String),
    InsufficientFees(u64),
    InsufficientFeeRate(u64),
}

impl TxComposeError {
    pub fn map_err(transaction_compose_error: TransactionComposeError) -> Self {
        match transaction_compose_error {
            TransactionComposeError::CreateTxError(create_tx_error) => match create_tx_error {
                CreateTxError::Descriptor(e) => {
                    TxComposeError::Error(format!("Failed to create send transaction: {}", e))
                }
                CreateTxError::Policy(e) => TxComposeError::Error(format!("Policy error: {}", e)),
                CreateTxError::SpendingPolicyRequired(e) => TxComposeError::Error(format!(
                    "SpendingPolicyRequired : {}",
                    match e {
                        KeychainKind::External => {
                            "External".to_string()
                        }
                        KeychainKind::Internal => {
                            "Internal".to_string()
                        }
                    }
                )),
                CreateTxError::Version0 => TxComposeError::Error("Version0".to_string()),
                CreateTxError::Version1Csv => TxComposeError::Error("Version1Csv ".to_string()),
                CreateTxError::LockTime {
                    requested,
                    required,
                } => TxComposeError::Error(format!(
                    "LockTime requested: {}, required: {}",
                    requested, required
                )),
                CreateTxError::RbfSequenceCsv { sequence, csv } => TxComposeError::Error(format!(
                    "RbfSequenceCsv sequence: {}, csv: {}",
                    sequence, csv
                )),
                CreateTxError::FeeTooLow { required } => {
                    TxComposeError::InsufficientFees(required.to_sat())
                }
                CreateTxError::FeeRateTooLow { required } => {
                    TxComposeError::InsufficientFeeRate(required.to_sat_per_vb_floor())
                }
                CreateTxError::NoUtxosSelected => {
                    TxComposeError::Error("No Utxos Selected".to_string())
                }
                CreateTxError::OutputBelowDustLimit(e) => {
                    TxComposeError::Error(format!("OutputBelowDustLimit {}", e))
                }
                CreateTxError::CoinSelection(e) => {
                    TxComposeError::CoinSelectionError(format!("CoinSelection {}", e))
                }
                CreateTxError::NoRecipients => TxComposeError::Error("NoRecipients".to_string()),
                CreateTxError::Psbt(e) => TxComposeError::Error(format!("Psbt {}", e)),
                CreateTxError::MissingKeyOrigin(e) => {
                    TxComposeError::Error(format!("MissingKeyOrigin {}", e))
                }
                CreateTxError::UnknownUtxo => TxComposeError::Error("UnknownUtxo".to_string()),
                CreateTxError::MissingNonWitnessUtxo(e) => {
                    TxComposeError::Error(format!("MissingNonWitnessUtxo {}", e))
                }
                CreateTxError::MiniscriptPsbt(e) => {
                    TxComposeError::Error(format!("MiniscriptPsbt {}", e))
                }
            },
            TransactionComposeError::WalletError(e) => {
                TxComposeError::Error(format!("WalletError {}", e))
            }
            TransactionComposeError::Error(e) => TxComposeError::Error(format!("Error {}", e)),
        }
    }
}

pub enum BroadcastError {
    //network errors
    NetworkError(String),
    //bitcoin protocol errors
    ConsensusError(String),
    Message(String),
}

impl From<Error> for BroadcastError {
    fn from(value: Error) -> Self {
        match value {
            Error::IOError(error) => {
                BroadcastError::NetworkError(format!("IOError: {:?}", error))
            }
            Error::JSON(error) => {
                BroadcastError::NetworkError(format!("JSON: {:?}", error))
            }
            Error::Hex(error) => {
                BroadcastError::Message(format!("Hex: {:?}", error))
            }
            Error::Protocol(json) => {
                BroadcastError::ConsensusError(format!("Protocol: {:?}", json))
            }
            Error::Bitcoin(error) => {
                BroadcastError::ConsensusError(format!("Bitcoin: {:?}", error))
            }
            Error::AlreadySubscribed(_) => {
                BroadcastError::Message("Already subscribed to the notifications of an address".to_string())
            }
            Error::NotSubscribed(_) => {
                BroadcastError::Message("Not subscribed to the notifications of an address".to_string())
            }
            Error::InvalidResponse(e) => {
                BroadcastError::Message(format!("Error during the deserialization of a response from the server: {}", e.clone().take()))
            }
            Error::Message(e) => {
                BroadcastError::Message(e.to_string())
            }
            Error::InvalidDNSNameError(domain) => {
                BroadcastError::Message(format!("Invalid domain name {} not matching SSL certificate", domain))
            }
            Error::MissingDomain => {
                BroadcastError::Message("Missing domain while it was explicitly asked to validate it".to_string())
            }
            Error::AllAttemptsErrored(errors) => {
                BroadcastError::Message(format!("Made one or multiple attempts, all errored: {:?}", errors))
            }
            Error::SharedIOError(e) => {
                BroadcastError::Message(format!("{}", e))
            }
            Error::CouldntLockReader => {
                BroadcastError::Message("Couldn't take a lock on the reader mutex. This means that there's already another reader thread is running".to_string())
            }
            Error::Mpsc => {
                BroadcastError::Message("Broken IPC communication channel: the other thread probably has exited".to_string())
            }
            Error::CouldNotCreateConnection(e) => {
                BroadcastError::Message(format!("{}", e))
            }
        }
    }
}

pub enum RBFBumpFeeError {
    InsufficientFunds,
    ComposeBumpTxError(String),
    ComposeTxError(String),
    ChangeOutputLocked,
    /// Happens when trying to spend an UTXO that is not in the internal database
    UnknownUtxo(String),
    /// Thrown when a tx is not found in the internal database
    TransactionNotFound,
    /// Happens when trying to bump a transaction that is already confirmed
    TransactionConfirmed(String),
    /// Trying to replace a tx that has a sequence >= `0xFFFFFFFE`
    IrreplaceableTransaction(String),
    /// Node doesn't have data to estimate a fee rate
    FeeRateUnavailable,
    UnableToAccessWallet,
    UnableToAddForeignUtxo(String),
    WalletNotAvailable,
}

impl From<BumpFeeError> for RBFBumpFeeError {
    fn from(value: BumpFeeError) -> Self {
        match value {
            BumpFeeError::InsufficientFunds => RBFBumpFeeError::InsufficientFunds,
            BumpFeeError::ComposeBumpTxError(e) => {
                RBFBumpFeeError::ComposeBumpTxError(e.to_string())
            }
            BumpFeeError::ComposeTxError(e) => RBFBumpFeeError::ComposeTxError(e.to_string()),
            BumpFeeError::ChangeOutputLocked => RBFBumpFeeError::ChangeOutputLocked,
            BumpFeeError::UnknownUtxo(outpoint) => {
                RBFBumpFeeError::UnknownUtxo(outpoint.to_string())
            }
            BumpFeeError::TransactionConfirmed(txid) => {
                RBFBumpFeeError::TransactionConfirmed(txid.to_string())
            }
            BumpFeeError::IrreplaceableTransaction(txid) => {
                RBFBumpFeeError::IrreplaceableTransaction(txid.to_string())
            }
            BumpFeeError::FeeRateUnavailable => RBFBumpFeeError::FeeRateUnavailable,
            BumpFeeError::UnableToAccessWallet => RBFBumpFeeError::UnableToAccessWallet,
            BumpFeeError::UnableToAddForeignUtxo(e) => {
                RBFBumpFeeError::UnableToAddForeignUtxo(e.to_string())
            }
            BumpFeeError::TransactionNotFound() => RBFBumpFeeError::TransactionNotFound,
        }
    }
}
