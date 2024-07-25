# Flutter Rust Bridge BLE Dart Plugin

This Dart plugin for BLE is created using the Flutter Rust Bridge.

## Using the Plugin

To use this plugin, follow these steps:

1. **Get an Adapter:**
    - Use `firstAdapter` or `getAdapters` functions to obtain a Bluetooth adapter.

2. **Scan for Peripherals:**
    - Start scanning with `startScan` and stop scanning with `stopScan`.
    - Use `getPeripherals` to retrieve a list of peripherals for a given adapter.

3. **Connect to Peripherals:**
    - Use `connectPeripheral` to establish a connection to a Bluetooth peripheral.
    - Check the connection status with `isConnected`.
    - Retrieve the name of the peripheral using `getNameFromPeripheral`.

4. **Read and Write Data:**
    - Define specific characteristics for a peripheral.
    - Use `writeTo` to write data to the peripheral.
    - Use `readFrom` to read data from the peripheral.
