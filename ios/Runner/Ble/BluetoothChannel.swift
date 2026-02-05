import AccessorySetupKit
import CoreBluetooth
import Flutter
import Foundation
import UIKit

/// BluetoothChannel manages shared Bluetooth operations and multiple BLE device connections.
///
/// Shared operations (handled here):
/// - AccessorySetupKit integration
/// - Bluetooth state management
/// - Device scanning and discovery
/// - Managing BleDevice instances
///
/// Device-specific operations (handled by BleDevice):
/// - GATT connection and state
/// - Characteristics and MTU
/// - Data transfer (read/write)
/// - Device-specific Flutter channels
///
/// Channel naming:
/// - Main channel: envoy/bluetooth (for shared operations)
/// - Scan stream: envoy/bluetooth/scan/stream
/// - Bluetooth state stream: envoy/bluetooth/stream
class BluetoothChannel: NSObject, CBCentralManagerDelegate, FlutterStreamHandler, BleDeviceDelegate
{
    private static let TAG = "BluetoothChannel"

    private let methodChannelName = "envoy/bluetooth"
    private let bleStreamName = "envoy/bluetooth/stream"
    private let bleScanStreamName = "envoy/bluetooth/scan/stream"

    var centralManager: CBCentralManager?
    var methodChannel: FlutterMethodChannel?
    private var eventSink: FlutterEventSink? = nil
    var scanEventSink: FlutterEventSink? = nil
    var setupResult: FlutterResult? = nil
    let session = ASAccessorySession()

    // Connected BleDevice instances, keyed by UUID string
    private var devices: [String: BleDevice] = [:]

    // Accessory (for AccessorySetupKit integration)
    var primeAccessory: ASAccessory?

    // Flutter controller reference
    weak var flutterController: FlutterViewController?

    // Service UUID for Prime device
    let primeUUID: CBUUID = CBUUID(string: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E")

    // Restore identifier for state restoration
    private let restoreIdentifier = "com.envoy.central.restore"

    // Add a flag to track if we need to rediscover services once BT is powered on
    private var needsServiceRediscovery: Bool = false
    private var restoredPeripheralId: String?

    // Connection state tracking
    private var isPickerPresented = false
    private var reconnectionTimer: Timer?
    private var reconnectionAttempts: Int = 0

    private let bleQueue = DispatchQueue(label: "com.envoy.ble", qos: .userInteractive)

    let connectOptions: [String: Any] = [
        CBConnectPeripheralOptionNotifyOnConnectionKey: true,
        CBConnectPeripheralOptionNotifyOnDisconnectionKey: true,
        CBConnectPeripheralOptionNotifyOnNotificationKey: true,
        CBConnectPeripheralOptionStartDelayKey: 0,
        CBConnectPeripheralOptionEnableTransportBridgingKey: false
    ]

    // MARK: - Initialization

    init(flutterController: FlutterViewController) {
        super.init()

        print("\(Self.TAG) Device name: \(UIDevice.current.name)")

        self.flutterController = flutterController

        // Set up event channel for streaming Bluetooth state
        FlutterEventChannel(name: bleStreamName, binaryMessenger: flutterController.binaryMessenger)
            .setStreamHandler(self)

        // Set up scan event channel
        FlutterEventChannel(name: bleScanStreamName, binaryMessenger: flutterController.binaryMessenger)
            .setStreamHandler(ScanStreamHandler(bluetoothChannel: self))

        print("\(Self.TAG) Initialized BLE channels")

        // Set up method channel for shared operations
        self.methodChannel = FlutterMethodChannel(
            name: methodChannelName,
            binaryMessenger: flutterController.binaryMessenger)

        self.methodChannel?.setMethodCallHandler({
            [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            guard let self = self else {
                result(FlutterError(code: "internal", message: "self deallocated", details: nil))
                return
            }

            switch call.method {
            // Shared operations
            case "showAccessorySetup":
                self.showAccessorySetup(call: call, result: result)
            case "deviceName":
                result(UIDevice.current.name)
            case "getAccessories":
                self.getAccessories(result: result)

            // Device management operations
            case "prepareDevice":
                self.prepareDevice(call: call, result: result)
            case "reconnect":
                self.reconnect(call: call, result: result)
            case "getConnectedDevices":
                self.getConnectedDevices(result: result)
            case "removeDevice":
                self.removeDevice(call: call, result: result)

            // Legacy single-device operations (for backward compatibility)
            case "getConnectedPeripheralId":
                result(self.getConnectedPeripheralId())
            case "isConnected":
                result(self.isConnected())
            case "disconnect":
                self.disconnectPeripheral()
                result(true)
            case "transmitFromFile":
                self.transmitFromFile(call: call, result: result)
            case "getCurrentDeviceStatus":
                self.getCurrentDeviceStatus(result: result)
            case "cancelTransfer":
                self.cancelTransfer(result: result)
            default:
                result(FlutterMethodNotImplemented)
            }
        })

        setupAccessorySession()
    }

    override init() {
        super.init()
        setupAccessorySession()
    }

    // MARK: - BleDeviceDelegate

    func onDeviceDisconnected(device: BleDevice) {
        print("\(Self.TAG) Device disconnected: \(device.deviceId)")
        // Keep the device in the map but note it's disconnected
        // The device can be reconnected using the reconnect method
    }

    func getCentralManager() -> CBCentralManager? {
        return centralManager
    }

    // MARK: - Device Management

    /// Get or create a BleDevice for the given device ID.
    /// This ensures the device's channels are registered before Dart tries to use them.
    private func getOrCreateDevice(deviceId: String) -> BleDevice {
        if let existingDevice = devices[deviceId] {
            return existingDevice
        }

        print("\(Self.TAG) Creating BleDevice for: \(deviceId)")
        guard let messenger = flutterController?.binaryMessenger else {
            fatalError("Flutter binary messenger not available")
        }

        let device = BleDevice(
            deviceId: deviceId,
            binaryMessenger: messenger,
            delegate: self
        )
        devices[deviceId] = device
        return device
    }

    /// Prepare a device for connection by creating its BleDevice and registering channels.
    /// This must be called BEFORE Dart creates its QLConnection to ensure the native
    /// EventChannel StreamHandler is registered before Dart tries to listen.
    private func prepareDevice(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let deviceId = arguments["deviceId"] as? String,
              !deviceId.isEmpty else {
            result(FlutterError(code: "INVALID_DEVICE_ID", message: "Device ID is required", details: nil))
            return
        }

        // Create BleDevice so its channels are registered
        let _ = getOrCreateDevice(deviceId: deviceId)
        print("\(Self.TAG) Prepared device: \(deviceId)")
        result(true)
    }

    /// Reconnect to a previously paired device.
    /// prepareDevice() should be called first to register native channels.
    private func reconnect(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let deviceId = arguments["deviceId"] as? String,
              !deviceId.isEmpty else {
            result(FlutterError(code: "INVALID_DEVICE_ID", message: "Device ID is required", details: nil))
            return
        }

        guard let central = centralManager, central.state == .poweredOn else {
            result(FlutterError(code: "NO_CENTRAL", message: "Central manager not available or not powered on", details: nil))
            return
        }

        guard let uuid = UUID(uuidString: deviceId) else {
            result(FlutterError(code: "INVALID_UUID", message: "Invalid device UUID: \(deviceId)", details: nil))
            return
        }

        // Get or create BleDevice (may already exist from prepareDevice)
        let bleDevice = getOrCreateDevice(deviceId: deviceId)

        // Get the remote peripheral
        let peripherals = central.retrievePeripherals(withIdentifiers: [uuid])
        guard let peripheral = peripherals.first else {
            result(FlutterError(code: "DEVICE_NOT_FOUND", message: "Device not found: \(deviceId)", details: nil))
            return
        }

        print("\(Self.TAG) Reconnecting to device: \(deviceId)")
        bleDevice.connect(peripheral: peripheral)
        result(["reconnecting": true])
    }

    private func getConnectedDevices(result: @escaping FlutterResult) {
        let connectedDevices = devices.filter { $0.value.isConnected() }.map { (deviceId, device) in
            [
                "deviceId": deviceId,
                "name": device.peripheralName ?? "Unknown",
                "bonded": device.isBonded
            ]
        }
        result(connectedDevices)
    }

    private func removeDevice(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let deviceId = arguments["deviceId"] as? String,
              !deviceId.isEmpty else {
            result(FlutterError(code: "INVALID_DEVICE_ID", message: "Device ID is required", details: nil))
            return
        }

        if let device = devices.removeValue(forKey: deviceId) {
            device.cleanup()
            print("\(Self.TAG) Removed device: \(deviceId)")
            result(true)
        } else {
            result(false)
        }
    }

    private func setupBluetoothManager() {
        // Use the shared BLE queue for all BLE operations
        centralManager = CBCentralManager(
            delegate: self,
            queue: bleQueue,
            options: [
                CBCentralManagerOptionRestoreIdentifierKey: restoreIdentifier
            ]
        )
    }

    // Legacy single-device reconnect (for backward compatibility)
    private func attemptReconnection() {
        let accessories = session.accessories

        guard !accessories.isEmpty else {
            print("\(Self.TAG) No accessories available - stopping reconnection")
            stopReconnection()
            return
        }

        // Try to reconnect to the first paired accessory (or previously connected one)
        let targetAccessory = accessories.first { accessory in
            accessory.bluetoothIdentifier == primeAccessory?.bluetoothIdentifier
        } ?? accessories.first

        guard let accessory = targetAccessory else {
            print("\(Self.TAG) No valid accessory to reconnect")
            scheduleReconnection()
            return
        }

        print("\(Self.TAG) Attempting reconnection to: \(accessory.displayName) (attempt \(reconnectionAttempts + 1))")

        primeAccessory = accessory

        if let bluetoothId = accessory.bluetoothIdentifier {
            guard let central = centralManager, central.state == .poweredOn else {
                print("\(Self.TAG) Central manager not ready, will retry...")
                scheduleReconnection()
                return
            }

            connectToAccessoryPeripheral(bluetoothId: bluetoothId)
        } else {
            scheduleReconnection()
        }
    }

    private func scheduleReconnection() {
        reconnectionAttempts += 1
        reconnectionTimer?.invalidate()
        // Schedule next reconnection attempt ( 2s, 4s, 8s, max 30s)
        let delay = min(pow(2.0, Double(reconnectionAttempts)), 30.0)
        DispatchQueue.main.async { [weak self] in
            self?.reconnectionTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
                self?.attemptReconnection()
            }
        }
    }

    private func stopReconnection() {
        reconnectionTimer?.invalidate()
        reconnectionTimer = nil
        reconnectionAttempts = 0
        print("\(Self.TAG) Reconnection attempts stopped")
    }

    // Legacy single-device transmitFromFile (for backward compatibility)
    // Delegates to the first connected device
    private func transmitFromFile(call: FlutterMethodCall, result: @escaping FlutterResult) {
        // Find the first connected device
        guard let connectedDevice = devices.values.first(where: { $0.isConnected() }) else {
            result(FlutterError(code: "NO_DEVICE", message: "No connected device", details: nil))
            return
        }

        // The BleDevice handles file transfer directly, so we need to call it
        // For legacy support, we'll handle it here but this should be called via device-specific channel
        print("\(Self.TAG) Legacy transmitFromFile forwarded to device: \(connectedDevice.deviceId)")

        // Create a mock call to the device - this is a legacy path
        // New code should use device-specific channels
        result(FlutterError(code: "USE_DEVICE_CHANNEL", message: "Use device-specific channel for transmitFromFile", details: nil))
    }

    private func setupAccessorySession() {
        session.activate(on: DispatchQueue.main, eventHandler: handleAccessoryEvent)
    }

    // Legacy single-device getConnectedPeripheralId (for backward compatibility)
    func getConnectedPeripheralId() -> String? {
        // Return the first connected device's ID
        if let connectedDevice = devices.values.first(where: { $0.isConnected() }) {
            print("\(Self.TAG) connectedPeripheral: \(connectedDevice.peripheralId)")
            return connectedDevice.peripheralId
        }
        return nil
    }

    func getAccessories(result: @escaping FlutterResult) {
        // Get all accessories from the session
        let accessories = session.accessories

        if accessories.isEmpty {
            // No accessories paired
            result([])
            return
        }

        // Build list of accessory info
        var accessoryList: [[String: Any]] = []

        for accessory in accessories {
            let peripheralId = accessory.bluetoothIdentifier?.uuidString ?? ""
            let isConnected = peripheralId.isEmpty ? false : (devices[peripheralId]?.isConnected() ?? false)

            let accessoryInfo: [String: Any] = [
                "peripheralId": peripheralId,
                "peripheralName": accessory.displayName,
                "isConnected": isConnected,
                "state": accessory.state.rawValue
            ]

            accessoryList.append(accessoryInfo)
        }

        result(accessoryList)
    }

    // Legacy single-device cancelTransfer (for backward compatibility)
    func cancelTransfer(result: @escaping FlutterResult) {
        // This should be called via device-specific channel in new code
        result(["cancelled": false, "message": "Use device-specific channel for cancelTransfer"])
        print("\(Self.TAG) cancelTransfer called on shared channel - use device-specific channel")
    }

    // Legacy single-device getCurrentDeviceStatus (for backward compatibility)
    func getCurrentDeviceStatus(result: @escaping FlutterResult) {
        // Return the first connected device's status
        if let connectedDevice = devices.values.first(where: { $0.isConnected() }) {
            let statusData: [String: Any?] = [
                "type": nil,
                "connected": true,
                "peripheralId": connectedDevice.peripheralId,
                "peripheralName": connectedDevice.peripheralName ?? "Unknown Device",
                "bonded": connectedDevice.isBonded,
                "rssi": nil,
                "error": nil
            ]
            result(statusData)
        } else {
            let statusData: [String: Any?] = [
                "type": nil,
                "connected": false,
                "peripheralId": nil,
                "peripheralName": primeAccessory?.displayName ?? "Unknown Device",
                "bonded": primeAccessory != nil,
                "rssi": nil,
                "error": nil
            ]
            result(statusData)
        }
    }

    func showAccessorySetup(call: FlutterMethodCall, result: @escaping FlutterResult) {
        // Ensure we have a flutter controller to present on
        guard flutterController != nil else {
            print("Error: No FlutterViewController available for presenting accessory sheet")
            result(false)
            return
        }
        
        // Check if app is in foreground
        guard UIApplication.shared.applicationState == .active else {
            print("Error: Application is not in foreground. Current state: \(UIApplication.shared.applicationState.rawValue)")
            result(false)
            return
        }
        
        setupResult = result

        // Ensure we're on the main thread for UI operations
        Task { @MainActor in
            await presentAccessoryPicker(call: call)
        }
    }

    @MainActor
    private func presentAccessoryPicker(call: FlutterMethodCall) async {

        let arguments = call.arguments as? [String: Any] ?? [:]
        let isMidnight = (arguments["c"] as? Int ?? 1) == 1
        let passportDescriptor = ASDiscoveryDescriptor()
        passportDescriptor.bluetoothServiceUUID = primeUUID
        passportDescriptor.bluetoothNameSubstring = "Prime"

        //Maybe tweak this if multiple primes present
        passportDescriptor.bluetoothRange = ASDiscoveryDescriptor.Range.default
        let productImage = UIImage(named:isMidnight ?  "prime_dark_midgnight_bronze" : "prime_light_arctic_copper") ?? UIImage()
        let passportDisplayItem = ASPickerDisplayItem(
            name: "Passport Prime",
            productImage: productImage,
            descriptor: passportDescriptor
        )

        do {
            try await session.showPicker(for: [passportDisplayItem])
        } catch {
            print("Failed to show picker: \(error.localizedDescription)")
            // Call the result callback with failure if picker fails to show
            if let result = setupResult {
                result(false)
                setupResult = nil
            }
        }
    }

    // MARK: - Accessory Event Handlers

    private func handleAccessoryEvent(event: ASAccessoryEvent) {
        print("ASAccessoryEvent: \(event.debugDescription)")
        for item in session.accessories {
            print("Found accessory: \(item.debugDescription)")
        }
        switch event.eventType {
        case .accessoryAdded, .accessoryChanged:
            guard let accessory = event.accessory else { return }
            initWithAccessory(accessory: accessory)
        case .activated:
            print("Accessory discovery session activated .")
        case .accessoryRemoved:
            handleAccessoryRemoved()
        case .pickerDidPresent:
            print("Accessory picker presented")
        case .pickerDidDismiss:
            if(setupResult != nil){
                setupResult!(false)
                setupResult = nil
            }
        default:
            print("Received accessory event type: \(event.eventType)")
        }
    }

    private func initWithAccessory(accessory: ASAccessory) {
        primeAccessory = accessory

        let peripheralId = accessory.bluetoothIdentifier?.uuidString ?? accessory.displayName
        let peripheralName = accessory.displayName
        let hasBluetoothId = accessory.bluetoothIdentifier != nil

        print("\(Self.TAG) Saving accessory: \(peripheralName)")
        print("\(Self.TAG)   - Bluetooth ID: \(accessory.bluetoothIdentifier?.uuidString ?? "None")")
        print("\(Self.TAG)   - Has Bluetooth ID: \(hasBluetoothId)")

        // Initialize CoreBluetooth manager if needed
        if centralManager == nil {
            setupBluetoothManager()
        }

        // Create BleDevice for this accessory if it has a Bluetooth ID
        if let bluetoothId = accessory.bluetoothIdentifier {
            let deviceId = bluetoothId.uuidString
            let _ = getOrCreateDevice(deviceId: deviceId)
        }

        // Send scan event to Flutter
        sendScanEvent(type: "device_found", deviceId: peripheralId, deviceName: peripheralName)

        if setupResult != nil {
            setupResult!(true)
            setupResult = nil
        }

        // If accessory has Bluetooth identifier, try to connect via CoreBluetooth
        if let bluetoothId = accessory.bluetoothIdentifier,
           let central = centralManager,
           central.state == .poweredOn
        {
            connectToAccessoryPeripheral(bluetoothId: bluetoothId)
        }
    }

    private func handleAccessoryRemoved() {
        guard let accessory = primeAccessory else { return }

        let peripheralId = accessory.bluetoothIdentifier?.uuidString ?? accessory.displayName
        let peripheralName = accessory.displayName

        print("\(Self.TAG) Accessory removed: \(peripheralName)")

        // Clean up the BleDevice for this accessory
        if let bluetoothId = accessory.bluetoothIdentifier {
            let deviceId = bluetoothId.uuidString
            if let device = devices[deviceId] {
                device.cleanup()
                devices.removeValue(forKey: deviceId)
            }
        }

        // Clear all references
        primeAccessory = nil

        // Send disconnection event via scan event
        sendScanEvent(type: "device_disconnected", deviceId: peripheralId, deviceName: peripheralName)
    }

    private func connectToAccessoryPeripheral(bluetoothId: UUID) {
        guard let central = centralManager, central.state == .poweredOn else {
            print("\(Self.TAG) Central manager not ready for connection")
            return
        }

        let peripherals = central.retrievePeripherals(withIdentifiers: [bluetoothId])
        guard let peripheral = peripherals.first else {
            print("\(Self.TAG) Could not retrieve peripheral with ID: \(bluetoothId)")
            return
        }

        let deviceId = peripheral.identifier.uuidString
        print("\(Self.TAG) Connecting to accessory peripheral: \(peripheral.name ?? "Unknown") (\(deviceId))")

        // Get or create BleDevice and connect
        let bleDevice = getOrCreateDevice(deviceId: deviceId)
        bleDevice.connect(peripheral: peripheral)
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("\(Self.TAG) Central manager state: \(central.state)")
        // Send state update to Flutter
        sendBluetoothState(central.state)

        switch central.state {
        case .poweredOn:
            print("\(Self.TAG) Bluetooth is powered on")
            handleBluetoothPoweredOn(central: central)

        case .poweredOff:
            print("\(Self.TAG) Bluetooth is powered off")
            handleBluetoothPoweredOff()

        case .unauthorized:
            print("\(Self.TAG) Bluetooth access unauthorized")

        case .unsupported:
            print("\(Self.TAG) Bluetooth not supported on this device")

        case .unknown:
            print("\(Self.TAG) Bluetooth state unknown - waiting for state update...")

        case .resetting:
            print("\(Self.TAG) Bluetooth is resetting")

        @unknown default:
            print("\(Self.TAG) Unknown Bluetooth state: \(central.state.rawValue)")
        }
    }

    private func handleBluetoothPoweredOn(central: CBCentralManager) {
        // Check if we have an accessory that needs CoreBluetooth connection
        if let accessory = primeAccessory,
           let bluetoothId = accessory.bluetoothIdentifier
        {
            connectToAccessoryPeripheral(bluetoothId: bluetoothId)
            return
        }

        // Handle restored peripheral
        if needsServiceRediscovery, let peripheralId = restoredPeripheralId {
            handleRestoredPeripheral(peripheralId: peripheralId, central: central)
            return
        }

        if primeAccessory == nil {
            print("\(Self.TAG) Starting scan for peripherals...")
            central.scanForPeripherals(withServices: [primeUUID], options: nil)
        }
    }

    private func handleBluetoothPoweredOff() {
        // Notify all connected devices about Bluetooth being powered off
        for (_, device) in devices {
            if device.isConnected() {
                device.sendConnectionEvent(type: nil, error: "Bluetooth powered off")
            }
        }
    }

    private func handleRestoredPeripheral(peripheralId: String, central: CBCentralManager) {
        guard let uuid = UUID(uuidString: peripheralId) else {
            needsServiceRediscovery = false
            return
        }

        let peripherals = central.retrievePeripherals(withIdentifiers: [uuid])
        guard let peripheral = peripherals.first else {
            needsServiceRediscovery = false
            return
        }

        let bleDevice = getOrCreateDevice(deviceId: peripheralId)

        if peripheral.state == .connected {
            bleDevice.onDidConnect(peripheral: peripheral)
        } else {
            print("\(Self.TAG) Attempting to reconnect to restored peripheral...")
            bleDevice.connect(peripheral: peripheral)
        }
        needsServiceRediscovery = false
        restoredPeripheralId = nil
    }

    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String: Any]) {
        print("\(Self.TAG) Central state restoration: \(central.state.rawValue)")

        // Retrieve peripherals that were connected or pending
        if let peripherals = dict[CBCentralManagerRestoredStatePeripheralsKey] as? [CBPeripheral] {
            for peripheral in peripherals {
                let deviceId = peripheral.identifier.uuidString
                print("\(Self.TAG) Restored peripheral: \(deviceId)")
                print("\(Self.TAG)   - Name: \(peripheral.name ?? "Unknown")")
                print("\(Self.TAG)   - State: \(peripheral.state.rawValue)")

                // Create BleDevice for restored peripheral
                let _ = getOrCreateDevice(deviceId: deviceId)

                if peripheral.state == .connected {
                    needsServiceRediscovery = true
                    restoredPeripheralId = deviceId
                }
            }
        } else {
            print("\(Self.TAG) No peripherals to restore")
        }
    }

    func centralManager(
        _ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
        advertisementData: [String: Any], rssi RSSI: NSNumber
    ) {
        print("\(Self.TAG) Discovered peripheral: \(peripheral.name ?? "Unknown") with RSSI: \(RSSI)")
        central.stopScan()

        let deviceId = peripheral.identifier.uuidString
        sendScanEvent(type: "device_found", deviceId: deviceId, deviceName: peripheral.name)

        // Create BleDevice and connect
        let bleDevice = getOrCreateDevice(deviceId: deviceId)
        bleDevice.connect(peripheral: peripheral)
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        let deviceId = peripheral.identifier.uuidString
        print("\(Self.TAG) Successfully connected to peripheral: \(peripheral.name ?? "Unknown") (\(deviceId))")

        stopReconnection()

        // Route to the appropriate BleDevice
        if let bleDevice = devices[deviceId] {
            bleDevice.onDidConnect(peripheral: peripheral)
        } else {
            print("\(Self.TAG) WARNING: No BleDevice found for connected peripheral: \(deviceId)")
        }
    }

    func centralManager(
        _ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?
    ) {
        let deviceId = peripheral.identifier.uuidString
        print("\(Self.TAG) Failed to connect to peripheral: \(error?.localizedDescription ?? "Unknown error")")

        // Route to the appropriate BleDevice
        if let bleDevice = devices[deviceId] {
            bleDevice.onDidFailToConnect(peripheral: peripheral, error: error)
        }
    }

    func centralManager(
        _ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?
    ) {
        let deviceId = peripheral.identifier.uuidString
        print("\(Self.TAG) Disconnected from peripheral: \(error?.localizedDescription ?? "No error")")

        // Route to the appropriate BleDevice
        if let bleDevice = devices[deviceId] {
            bleDevice.onDidDisconnect(peripheral: peripheral, error: error)
        }

        print("\(Self.TAG) Starting automatic reconnection...")
        attemptReconnection()
    }

    func isConnected() -> Bool {
        return devices.values.contains { $0.isConnected() }
    }

    // MARK: - Connection Management

    func disconnectPeripheral() {
        // Disconnect all devices
        for (_, device) in devices {
            if device.isConnected(), let peripheral = device.connectedPeripheral {
                centralManager?.cancelPeripheralConnection(peripheral)
            }
        }

        Task {
            await removeAccessory()
        }
    }

    // MARK: - Accessory Management

    func removeAccessory() async {
        guard let accessory = primeAccessory else { return }

        // Cleanup all devices
        for (_, device) in devices {
            device.cleanup()
        }
        devices.removeAll()

        do {
            try await session.removeAccessory(accessory)
            primeAccessory = nil
            print("\(Self.TAG) Successfully removed accessory")
        } catch {
            print("\(Self.TAG) Failed to remove accessory: \(error.localizedDescription)")
        }
    }

    // MARK: - Scan Event Sending

    private func sendScanEvent(type: String, deviceId: String? = nil, deviceName: String? = nil) {
        let eventData: [String: Any?] = [
            "type": type,
            "deviceId": deviceId,
            "deviceName": deviceName
        ]

        scanEventSink?(eventData)
        print("\(Self.TAG) Scan Event -> Flutter: type=\(type), device=\(deviceName ?? deviceId ?? "unknown")")
    }

    private func sendBluetoothState(_ state: CBManagerState) {
        guard let sink = eventSink else { return }

        let stateString: String
        switch state {
        case .poweredOn: stateString = "powered_on"
        case .poweredOff: stateString = "powered_off"
        case .unauthorized: stateString = "unauthorized"
        case .unsupported: stateString = "unsupported"
        case .resetting: stateString = "resetting"
        case .unknown: stateString = "unknown"
        @unknown default: stateString = "unknown"
        }

        let stateData: [String: Any] = [
            "type": "bluetooth_state",
            "state": stateString,
            "timestamp": Date().timeIntervalSince1970 * 1000,
        ]

        sink(stateData)
        print("\(Self.TAG) Sent Bluetooth state to Flutter: \(stateString)")
    }

    // MARK: - FlutterStreamHandler

    public func onListen(
        withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink
    ) -> FlutterError? {
        eventSink = events
        print("\(Self.TAG) Flutter stream listener attached")

        // Send current Bluetooth state when listener attaches
        if let manager = centralManager {
            sendBluetoothState(manager.state)
        }

        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        print("\(Self.TAG) Flutter stream listener detached")
        return nil
    }
}

// MARK: - ScanStreamHandler

class ScanStreamHandler: NSObject, FlutterStreamHandler {
    weak var bluetoothChannel: BluetoothChannel?

    init(bluetoothChannel: BluetoothChannel) {
        self.bluetoothChannel = bluetoothChannel
    }

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink)
        -> FlutterError?
    {
        bluetoothChannel?.scanEventSink = events
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        bluetoothChannel?.scanEventSink = nil
        return nil
    }
}

extension Data {
    func chunked(into size: Int) -> [Data] {
        guard count > 0 else { return [] }

        return stride(from: 0, to: count, by: size).map {
            Data(self[$0..<Swift.min($0 + size, count)])
        }
    }
}
