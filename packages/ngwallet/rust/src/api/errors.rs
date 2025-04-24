use bdk_wallet::error::CreateTxError;
use bdk_wallet::KeychainKind;

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
            CreateTxError::Policy(e) => {
                ComposeTxError::Error(format!("Policy error: {}", e))
            }
            CreateTxError::SpendingPolicyRequired(e) => {
                ComposeTxError::Error(format!("SpendingPolicyRequired : {}", match e {
                    KeychainKind::External => {
                        "External".to_string()
                    }
                    KeychainKind::Internal => {
                        "Internal".to_string()
                    }
                }))
            }
            CreateTxError::Version0 => {
                ComposeTxError::Error("Version0".to_string())
            }
            CreateTxError::Version1Csv => {
                ComposeTxError::Error("Version1Csv ".to_string())
            }
            CreateTxError::LockTime { requested, required } => {
                ComposeTxError::Error(format!("LockTime requested: {}, required: {}", requested, required))
            }
            CreateTxError::RbfSequenceCsv { sequence, csv } => {
                ComposeTxError::Error(format!("RbfSequenceCsv sequence: {}, csv: {}", sequence, csv))
            }
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
            CreateTxError::NoRecipients => {
                ComposeTxError::Error("NoRecipients".to_string())
            }
            CreateTxError::Psbt(e) => {
                ComposeTxError::Error(format!("Psbt {}", e))
            }
            CreateTxError::MissingKeyOrigin(e) => {
                ComposeTxError::Error(format!("MissingKeyOrigin {}", e))
            }
            CreateTxError::UnknownUtxo => {
                ComposeTxError::Error("UnknownUtxo".to_string())
            }
            CreateTxError::MissingNonWitnessUtxo(e) => {
                ComposeTxError::Error(format!("MissingNonWitnessUtxo {}", e))
            }
            CreateTxError::MiniscriptPsbt(e) => {
                ComposeTxError::Error(format!("MiniscriptPsbt {}", e))
            }
        }
    }
}