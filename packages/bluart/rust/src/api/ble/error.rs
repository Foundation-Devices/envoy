#[derive(Debug, thiserror::Error)]
pub enum Error {
    // #[error("Btleplug error: {0}")]
    // Btleplug(#[from] btleplug::Error),
    // #[error("JNI {0}")]
    // Jni(#[from] jni::errors::Error),
    #[error("Call init() first.")]
    RuntimeNotInitialized,

    #[allow(dead_code)]
    #[error("Cannot initialize CLASS_LOADER")]
    ClassLoader,

    #[allow(dead_code)]
    #[error("Cannot initialize RUNTIME")]
    Runtime,

    #[allow(dead_code)]
    #[error("Java vm not initialized")]
    JavaVM,

    #[error("TX is already set.")]
    TxAlreadySet,

    #[error("TX is not initialized.")]
    TxNotInitialized,

    #[error("There is no peripheral with id: {0}")]
    UnknownPeripheral(String),
}
