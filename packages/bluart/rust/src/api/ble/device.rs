use super::peripheral::Peripheral;

/// This is the BleDevice intended to show in Dart/Flutter
#[derive(Debug, Clone)]
pub struct BleDevice {
    pub id: String,
    pub name: String,
    pub connected: bool,
}

impl BleDevice {
    pub async fn from_peripheral(peripheral: &Peripheral) -> BleDevice {
        Self {
            id: peripheral.id().to_string(),
            name: peripheral.name().await.unwrap_or_default(),
            connected: peripheral.is_connected(),
        }
    }
}
