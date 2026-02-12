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
/// - Managing QLConnection instances
///
/// Device-specific operations (handled by QLConnection):
/// - GATT connection and state
/// - Characteristics and MTU
/// - Data transfer (read/write)
/// - Device-specific Flutter channels
///
/// Channel naming:
/// - Main channel: envoy/bluetooth (for shared operations)
/// - Scan stream: envoy/bluetooth/scan/stream
/// - Bluetooth state stream: envoy/bluetooth/stream
class BluetoothChannel: NSObject, CBCentralManagerDelegate, FlutterStreamHandler, QLConnectionDelegate
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

    // Connected QLConnection instances, keyed by UUID string
    private var devices: [String: QLConnection] = [:]

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
    private var isShuttingDown = false

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
                self.removeDeviceAndAccessory(call: call, result: result)
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

    // MARK: - QLConnectionDelegate

    func onDeviceDisconnected(device: QLConnection) {
        print("\(Self.TAG) Device disconnected: \(device.deviceId)")
        // Keep the device in the map but note it's disconnected
        // The device can be reconnected using the reconnect method
    }

    func getCentralManager() -> CBCentralManager? {
        return centralManager
    }

    // MARK: - Device Management

    /// Get or create a QLConnection for the given device ID.
    /// This ensures the device's channels are registered before Dart tries to use them.
    private func getOrCreateDevice(deviceId: String) -> QLConnection {
        if let existingDevice = devices[deviceId] {
            return existingDevice
        }

        print("\(Self.TAG) Creating QLConnection for: \(deviceId)")
        guard let messenger = flutterController?.binaryMessenger else {
            fatalError("Flutter binary messenger not available")
        }

        let device = QLConnection(
            deviceId: deviceId,
            binaryMessenger: messenger,
            delegate: self,
            accessorySession: session
        )
        devices[deviceId] = device
        return device
    }

    /// Prepare a device for connection by creating its QLConnection and registering channels.
    /// This must be called BEFORE Dart creates its QLConnection to ensure the native
    /// EventChannel StreamHandler is registered before Dart tries to listen.
    private func prepareDevice(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let deviceId = arguments["deviceId"] as? String,
              !deviceId.isEmpty else {
            result(FlutterError(code: "INVALID_DEVICE_ID", message: "Device ID is required", details: nil))
            return
        }

        // Create QLConnection so its channels are registered
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

        // Get or create QLConnection (may already exist from prepareDevice)
        let qlConnection = getOrCreateDevice(deviceId: deviceId)

        // Get the remote peripheral
        let peripherals = central.retrievePeripherals(withIdentifiers: [uuid])
        guard let peripheral = peripherals.first else {
            result(FlutterError(code: "DEVICE_NOT_FOUND", message: "Device not found: \(deviceId)", details: nil))
            return
        }

        print("\(Self.TAG) Reconnecting to device: \(deviceId)")
        qlConnection.connect(peripheral: peripheral)
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
    
    private func removeDeviceAndAccessory(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let deviceId = arguments["deviceId"] as? String,
              !deviceId.isEmpty else {
            result(FlutterError(code: "INVALID_DEVICE_ID", message: "Device ID is required", details: nil))
            return
        }

        var didRemoveLocalDevice = false
        if let device = devices.removeValue(forKey: deviceId) {
            device.cleanup()
            didRemoveLocalDevice = true
            print("\(Self.TAG) Removed device: \(deviceId)")
        }

        guard let uuid = UUID(uuidString: deviceId) else {
            // Not a UUID; only local cleanup is possible.
            result(didRemoveLocalDevice)
            return
        }

        guard let accessory = session.accessories.first(where: { $0.bluetoothIdentifier == uuid }) else {
            if primeAccessory?.bluetoothIdentifier == uuid {
                primeAccessory = nil
            }
            print("\(Self.TAG) No accessory found for device: \(deviceId)")
            result(didRemoveLocalDevice)
            return
        }

        session.removeAccessory(accessory) { [weak self] error in
            if let error = error {
                print("\(Self.TAG) Failed to remove accessory for \(deviceId): \(error.localizedDescription)")
                result(
                    FlutterError(
                        code: "REMOVE_ACCESSORY_FAILED",
                        message: "Failed to remove accessory",
                        details: error.localizedDescription
                    )
                )
                return
            }

            if self?.primeAccessory?.bluetoothIdentifier == uuid {
                self?.primeAccessory = nil
            }

            print("\(Self.TAG) Removed accessory for device: \(deviceId)")
            result(true)
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

    /// Clean up Bluetooth resources before app termination.
    /// This prevents CoreBluetooth callbacks from firing after Flutter engine is destroyed.
    func cleanup() {
        // Set flag first to prevent any further Flutter channel communication
        isShuttingDown = true

        // Stop any pending reconnection timers
        stopReconnection()

        // Stop scanning if active
        centralManager?.stopScan()

        // Clean up all device connections
        for (_, device) in devices {
            device.cleanup()
        }
        devices.removeAll()

        // Clear all Flutter sinks to prevent callbacks to destroyed engine
        eventSink = nil
        scanEventSink = nil
        setupResult = nil

        // Clear accessory reference
        primeAccessory = nil

        // Remove delegate to prevent further callbacks
        centralManager?.delegate = nil
        centralManager = nil
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

    private func setupAccessorySession() {
        session.activate(on: DispatchQueue.main, eventHandler: handleAccessoryEvent)
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


    func showAccessorySetup(call: FlutterMethodCall, result: @escaping FlutterResult) {
        // Ensure we have a flutter controller to present on
        guard flutterController != nil else {
            print("Error: No FlutterViewController available for presenting accessory sheet")
            result(nil)
            return
        }

        // Check if app is in foreground
        guard UIApplication.shared.applicationState == .active else {
            print("Error: Application is not in foreground. Current state: \(UIApplication.shared.applicationState.rawValue)")
            result(nil)
            return
        }

        // Check for existing paired accessories first
        let existingAccessories = session.accessories
        if let existingAccessory = existingAccessories.first {
            print("Found existing accessory: \(existingAccessory.displayName)")

            // Initialize with the existing accessory
            primeAccessory = existingAccessory

            // Initialize CoreBluetooth manager if needed
            if centralManager == nil {
                setupBluetoothManager()
            }

            //[ENV-2697] If accessory has Bluetooth identifier, connect to it
            if let bluetoothId = existingAccessory.bluetoothIdentifier {
                print("Connecting to existing accessory with Bluetooth ID: \(bluetoothId)")

                // Send connection event to Flutter
                sendConnectionEvent(
                    connected: false,
                    peripheralId: bluetoothId.uuidString,
                    peripheralName: existingAccessory.displayName,
                    type: "connecting"
                )

                // Connect if central manager is ready
                if let central = centralManager, central.state == .poweredOn {
                    connectToAccessoryPeripheral(bluetoothId: bluetoothId)
                }

                result(true)
                return
            } else {
                print("Existing accessory has no Bluetooth ID, will show picker")
            }
        }

        setupResult = result

        // No existing accessories found, show the picker
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
                result(nil)
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
            print("Accessory discovery session activated.")
            checkAndConnectToExistingAccessories()
        case .accessoryRemoved:
            handleAccessoryRemoved()
        case .pickerDidPresent:
            print("Accessory picker presented")
        case .pickerDidDismiss:
            if let result = setupResult {
                result(nil)
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

        // Create QLConnection for this accessory if it has a Bluetooth ID
        var deviceId: String? = nil
        if let bluetoothId = accessory.bluetoothIdentifier {
            deviceId = bluetoothId.uuidString
            let _ = getOrCreateDevice(deviceId: deviceId!)
        }

        // Send scan event to Flutter
        sendScanEvent(type: "device_found", deviceId: peripheralId, deviceName: peripheralName)

        if let result = setupResult {
            result(deviceId)
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


    private func checkAndConnectToExistingAccessories() {
        let accessories = session.accessories

        guard let existingAccessory = accessories.first else {
            print("No existing accessories found on app open")
            return
        }

        print("Found existing accessory on app open: \(existingAccessory.displayName)")

        // Initialize with the existing accessory
        primeAccessory = existingAccessory

        // Initialize CoreBluetooth manager if needed
        if centralManager == nil {
            setupBluetoothManager()
        }

        // If accessory has Bluetooth identifier, connect to it
        if let bluetoothId = existingAccessory.bluetoothIdentifier {
            print("Auto-connecting to existing accessory with Bluetooth ID: \(bluetoothId)")

            // Ensure QLConnection exists so channels are registered
            let _ = getOrCreateDevice(deviceId: bluetoothId.uuidString)

            // Send scan event to Flutter so UI can reflect the device
            sendScanEvent(type: "device_found", deviceId: bluetoothId.uuidString, deviceName: existingAccessory.displayName)

            // Connect if central manager is ready, otherwise it will connect when powered on
            if let central = centralManager, central.state == .poweredOn {
                connectToAccessoryPeripheral(bluetoothId: bluetoothId)
            }
        } else {
            print("Existing accessory has no Bluetooth ID yet")
        }
    }

    private func handleAccessoryRemoved() {
        guard let accessory = primeAccessory else { return }

        let peripheralId = accessory.bluetoothIdentifier?.uuidString ?? accessory.displayName
        let peripheralName = accessory.displayName

        print("\(Self.TAG) Accessory removed: \(peripheralName)")

        // Clean up the QLConnection for this accessory
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

        // Get or create QLConnection and connect
        let qlConnection = getOrCreateDevice(deviceId: deviceId)
        qlConnection.connect(peripheral: peripheral)
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

        let qlConnection = getOrCreateDevice(deviceId: peripheralId)

        if peripheral.state == .connected {
            qlConnection.onDidConnect(peripheral: peripheral)
        } else {
            print("\(Self.TAG) Attempting to reconnect to restored peripheral...")
            qlConnection.connect(peripheral: peripheral)
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

                // Create QLConnection for restored peripheral
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

        // Create QLConnection and connect
        let qlConnection = getOrCreateDevice(deviceId: deviceId)
        qlConnection.connect(peripheral: peripheral)
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        let deviceId = peripheral.identifier.uuidString
        print("\(Self.TAG) Successfully connected to peripheral: \(peripheral.name ?? "Unknown") (\(deviceId))")

        stopReconnection()

        // Route to the appropriate QLConnection
        if let qlConnection = devices[deviceId] {
            qlConnection.onDidConnect(peripheral: peripheral)
        } else {
            print("\(Self.TAG) WARNING: No QLConnection found for connected peripheral: \(deviceId)")
        }
    }

    func centralManager(
        _ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?
    ) {
        let deviceId = peripheral.identifier.uuidString
        print("\(Self.TAG) Failed to connect to peripheral: \(error?.localizedDescription ?? "Unknown error")")

        // Route to the appropriate QLConnection
        if let qlConnection = devices[deviceId] {
            qlConnection.onDidFailToConnect(peripheral: peripheral, error: error)
        }
    }

    func centralManager(
        _ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?
    ) {
        let deviceId = peripheral.identifier.uuidString
        print("\(Self.TAG) Disconnected from peripheral: \(error?.localizedDescription ?? "No error")")

        // Route to the appropriate QLConnection
        if let qlConnection = devices[deviceId] {
            qlConnection.onDidDisconnect(peripheral: peripheral, error: error)
        }

        print("\(Self.TAG) Starting automatic reconnection...")
        attemptReconnection()
    }

    // MARK: - Scan Event Sending

    private func sendScanEvent(type: String, deviceId: String? = nil, deviceName: String? = nil) {
        guard !isShuttingDown else { return }
        let eventData: [String: Any?] = [
            "type": type,
            "deviceId": deviceId,
            "deviceName": deviceName
        ]

        scanEventSink?(eventData)
        print("\(Self.TAG) Scan Event -> Flutter: type=\(type), device=\(deviceName ?? deviceId ?? "unknown")")
    }

    private func sendBluetoothState(_ state: CBManagerState) {
        guard !isShuttingDown else { return }
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
