use bdk_wallet::error::CreateTxError;
use bdk_wallet::{bitcoin, KeychainKind};
use ngwallet::bdk_electrum::electrum_client::Error;

pub enum ComposeTxError {
    CoinSelectionError(String),
    Error(String),
    InsufficientFunds(String),
    InsufficientFees(u64),
    InsufficientFeeRate(u64),
}

impl ComposeTxError {
    pub fn map_err(create_tx_error: CreateTxError) -> Self {
        match create_tx_error {
            CreateTxError::Descriptor(e) => {
                ComposeTxError::Error(format!("Failed to create send transaction: {}", e))
            }
            CreateTxError::Policy(e) => ComposeTxError::Error(format!("Policy error: {}", e)),
            CreateTxError::SpendingPolicyRequired(e) => ComposeTxError::Error(format!(
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
            CreateTxError::Version0 => ComposeTxError::Error("Version0".to_string()),
            CreateTxError::Version1Csv => ComposeTxError::Error("Version1Csv ".to_string()),
            CreateTxError::LockTime {
                requested,
                required,
            } => ComposeTxError::Error(format!(
                "LockTime requested: {}, required: {}",
                requested, required
            )),
            CreateTxError::RbfSequenceCsv { sequence, csv } => ComposeTxError::Error(format!(
                "RbfSequenceCsv sequence: {}, csv: {}",
                sequence, csv
            )),
            CreateTxError::FeeTooLow { required } => {
                ComposeTxError::InsufficientFees(required.to_sat())
            }
            CreateTxError::FeeRateTooLow { required } => {
                ComposeTxError::InsufficientFeeRate(required.to_sat_per_vb_floor())
            }
            CreateTxError::NoUtxosSelected => {
                ComposeTxError::Error("No Utxos Selected".to_string())
            }
            CreateTxError::OutputBelowDustLimit(e) => {
                ComposeTxError::Error(format!("OutputBelowDustLimit {}", e))
            }
            CreateTxError::CoinSelection(e) => {
                ComposeTxError::CoinSelectionError(format!("CoinSelection {}", e))
            }
            CreateTxError::NoRecipients => ComposeTxError::Error("NoRecipients".to_string()),
            CreateTxError::Psbt(e) => ComposeTxError::Error(format!("Psbt {}", e)),
            CreateTxError::MissingKeyOrigin(e) => {
                ComposeTxError::Error(format!("MissingKeyOrigin {}", e))
            }
            CreateTxError::UnknownUtxo => ComposeTxError::Error("UnknownUtxo".to_string()),
            CreateTxError::MissingNonWitnessUtxo(e) => {
                ComposeTxError::Error(format!("MissingNonWitnessUtxo {}", e))
            }
            CreateTxError::MiniscriptPsbt(e) => {
                ComposeTxError::Error(format!("MiniscriptPsbt {}", e))
            }
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
                BroadcastError::Message(format!("{}", e))
            }
            Error::InvalidDNSNameError(domain) => {
                BroadcastError::Message(format!("Invalid domain name {} not matching SSL certificate", domain))
            }
            Error::MissingDomain => {
                BroadcastError::Message(format!("Missing domain while it was explicitly asked to validate it"))
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
            err => {
                BroadcastError::Message(format!("Unknown error: {:?}", err))
            }
        }
    }
}
