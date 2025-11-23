import AccessorySetupKit
import CoreBluetooth
import Flutter
import Foundation
import UIKit

class BluetoothChannel: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate,
    FlutterStreamHandler
{

    private let methodChannelName = "envoy/bluetooth"
    private let bleStreamName = "envoy/bluetooth/stream"
    private let bleReadChannelName = "envoy/ble/read"
    private let bleWriteChannelName = "envoy/ble/write"
    private let bleConnectionStreamName = "envoy/bluetooth/connection/stream"
    private let bleWriteStreamProgressChannelName = "envoy/ble/write/progress"

    var centralManager: CBCentralManager?
    var connectedPeripheral: CBPeripheral?
    var methodChannel: FlutterMethodChannel?
    private var eventSink: FlutterEventSink? = nil
    var connectionEventSink: FlutterEventSink? = nil
    var writeStreamSink: FlutterEventSink? = nil
    var setupResult: FlutterResult? = nil
    let session = ASAccessorySession()

    // Binary message channel for efficient BLE data transmission
    var bleBinaryChannel: FlutterBasicMessageChannel?

    // Binary message channel for write operations
    var bleWriteChannel: FlutterBasicMessageChannel?

    // Characteristics for reading/writing
    var writeCharacteristic: CBCharacteristic?
    var readCharacteristic: CBCharacteristic?

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

    var needsToResendConnectionState: [String: Any]? = nil

    // Write retry 
    private var pendingWriteData: Data?
    private var writeRetryCount: Int = 0
    private let maxWriteRetries: Int = 2

    // Connection state tracking
    private var isPickerPresented = false
    private var deviceReady = false
    private var reconnectionTimer: Timer?
    private var reconnectionAttempts: Int = 0
    
    private let bleQueue = DispatchQueue(label: "com.envoy.ble", qos: .userInteractive)

    let connectOptions: [String: Any] = [
        CBConnectPeripheralOptionNotifyOnConnectionKey: true,
        CBConnectPeripheralOptionNotifyOnDisconnectionKey: true,
        CBConnectPeripheralOptionNotifyOnNotificationKey: true,
        CBConnectPeripheralOptionStartDelayKey: 0,
    ]

    // MARK: - Initialization

    init(flutterController: FlutterViewController) {
        super.init()
        
        print(UIDevice.current.name)
        
        self.flutterController = flutterController

        // Set up event channel for streaming Bluetooth metadata (connection status, errors, etc.)
        FlutterEventChannel(name: bleStreamName, binaryMessenger: flutterController.binaryMessenger)
            .setStreamHandler(self)

        bleBinaryChannel = FlutterBasicMessageChannel(
            name: bleReadChannelName,
            binaryMessenger: flutterController.binaryMessenger,
            codec: FlutterBinaryCodec.sharedInstance()
        )

        bleWriteChannel = FlutterBasicMessageChannel(
            name: bleWriteChannelName,
            binaryMessenger: flutterController.binaryMessenger,
            codec: FlutterBinaryCodec.sharedInstance()
        )

        // Set up connection event channel for streaming connection status
        FlutterEventChannel(
            name: bleConnectionStreamName, binaryMessenger: flutterController.binaryMessenger
        )
        .setStreamHandler(ConnectionStreamHandler(bluetoothChannel: self))

        // Set up connection event channel for streaming write updates
        FlutterEventChannel(
            name: bleWriteStreamProgressChannelName,
            binaryMessenger: flutterController.binaryMessenger
        )
        .setStreamHandler(ProgressStreamHandler(bluetoothChannel: self))

        bleWriteChannel?.setMessageHandler({ [weak self] (message, reply) in
            guard let self = self else {
                // Send failure buffer (0 bytes) when deallocated
                reply(Data())
                return
            }

            if let data = message as? Data {
               let replyStaus =   self.handleBinaryWrite(data: data)
                reply(replyStaus)
            } else {
                // Send failure buffer (0 bytes) for invalid data
                reply(Data())
            }
        })

        print("Initialized BLE channels:")

        // Set up method channel for method calls
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
            case "showAccessorySetup":
                self.showAccessorySetup(call: call, result: result)
            case "getConnectedPeripheralId":
                result(self.getConnectedPeripheralId())
            case "isConnected":
                result(self.isConnected())
            case "reconnect":
                reconnect( result: result)
            case "disconnect":
                self.disconnectPeripheral()
                result(true)
            case "deviceName":
                result(UIDevice.current.name)
            case "transmitFromFile":
                self.transmitFromFile(call: call, result: result)
            case "getAccessories":
                self.getAccessories(result: result)
            case "getCurrentDeviceStatus":
                self.getCurrentDeviceStatus(result: result)
            default:
                result(FlutterMethodNotImplemented)
            }
        })

        setupBluetoothManager()
        setupAccessorySession()
        //
    }

    override init() {
        super.init()
        setupBluetoothManager()
        setupAccessorySession()
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

    private func reconnect(result: @escaping FlutterResult) {
        attemptReconnection()
        result(["reconnecting": true])
    }
    
    private func attemptReconnection() {

        let accessories = session.accessories
        
        guard !accessories.isEmpty else {
            print("No accessories available - stopping reconnection")
            stopReconnection()
            return
        }
        
        // Try to reconnect to the first paired accessory (or previously connected one)
        // TODO: multi-accessory support
        let targetAccessory = accessories.first { accessory in
            accessory.bluetoothIdentifier == primeAccessory?.bluetoothIdentifier
        } ?? accessories.first
        
        guard let accessory = targetAccessory else {
            print("No valid accessory to reconnect")
            scheduleReconnection()
            return
        }
        
        print("Attempting reconnection to: \(accessory.displayName) (attempt \(reconnectionAttempts + 1))")
        
        primeAccessory = accessory
        
        if let bluetoothId = accessory.bluetoothIdentifier {

            guard let central = centralManager, central.state == .poweredOn else {
                print("Central manager not ready, will retry...")
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
        print("Reconnection attempts stopped")
    }

    private func transmitFromFile(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let path = arguments["path"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Expected path parameter", details: nil))
            return
        }
        
        
        if path.isEmpty {
            result(FlutterError(code: "INVALID_PATH", message: "File path is null or empty", details: nil))
            return
        }
        
        let fileURL = URL(fileURLWithPath: path)
        guard FileManager.default.fileExists(atPath: path) else {
            result(FlutterError(code: "FILE_NOT_FOUND", message: "File does not exist: \(path)", details: nil))
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            do {
                // Get file size
                let attributes = try FileManager.default.attributesOfItem(atPath: path)
                let fileSize = attributes[.size] as? Int64 ?? 0
                var bytesProcessed: Int64 = 0
                
                let fileHandle = try FileHandle(forReadingFrom: fileURL)
                defer { fileHandle.closeFile() }
                
                while true {
                    // Read inner list length (4 bytes)
                    let lengthData = fileHandle.readData(ofLength: 4)
                    guard lengthData.count == 4 else {
                        break
                    }
                    
                    bytesProcessed += Int64(lengthData.count)
                    
                    let innerLength = lengthData.withUnsafeBytes { bytes in
                        return bytes.load(fromByteOffset: 0, as: UInt32.self).bigEndian
                    }
                    for _ in 0..<innerLength {

                        let itemLengthData = fileHandle.readData(ofLength: 4)
                        guard itemLengthData.count == 4 else {
                            throw NSError(domain: "FileReadError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to read item length"])
                        }
                        
                        bytesProcessed += Int64(itemLengthData.count)
                        
                        let itemLength = itemLengthData.withUnsafeBytes { bytes in
                            return bytes.load(fromByteOffset: 0, as: UInt32.self).bigEndian
                        }
                        
                        let itemData = fileHandle.readData(ofLength: Int(itemLength))
                        guard itemData.count == Int(itemLength) else {
                            throw NSError(domain: "FileReadError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to read item data"])
                        }
                        
                        bytesProcessed += Int64(itemData.count)
                        
                        // Send progress update
                        let progress = fileSize > 0 ? Float(bytesProcessed) / Float(fileSize) : 0.0
                        self.sendWriteProgress(progress, id: path, bytesProcessed: bytesProcessed, totalBytes: fileSize)
                        
                        let _ = self.handleBinaryWrite(data: itemData)
                        
                        Thread.sleep(forTimeInterval: 0.012)
                    }
                }
                
                // Send final progress update
                self.sendWriteProgress(1.0, id: path, bytesProcessed: fileSize, totalBytes: fileSize)
                
                // Success, delete file after ble transmit
                do {
                    try FileManager.default.removeItem(at: fileURL)
                    print("Successfully deleted file: \(path)")
                } catch {
                    print("Warning: Failed to delete file after processing: \(error.localizedDescription)")
                }
                
                DispatchQueue.main.async {
                    result([
                        "success": true,
                        "message": "Large data processed successfully"
                    ])
                }
                
            } catch {
                print("Error reading large data file: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    result(FlutterError(code: "FILE_READ_ERROR", message: "Failed to read file: \(error.localizedDescription)", details: nil))
                }
            }
        }
    }

    private func setupAccessorySession() {
        session.activate(on: DispatchQueue.main, eventHandler: handleAccessoryEvent)
    }

    func getConnectedPeripheralId() -> String? {
        if let peripheral = connectedPeripheral {
            print("connectedPeripheral: \(peripheral.identifier.uuidString)")
            print("description: \(peripheral.identifier.description)")
            return peripheral.identifier.uuidString
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
            let isConnected = accessory.bluetoothIdentifier != nil && 
                             connectedPeripheral?.identifier == accessory.bluetoothIdentifier &&
                             connectedPeripheral?.state == .connected
            
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
    
    func getCurrentDeviceStatus(result: @escaping FlutterResult) {
        let peripheralId = connectedPeripheral?.identifier.uuidString
        let peripheralName = connectedPeripheral?.name ?? primeAccessory?.displayName ?? "Unknown Device"
        let connected = isConnected()
        let bonded = primeAccessory != nil
        
        let statusData: [String: Any?] = [
            "type": nil,
            "connected": connected,
            "peripheralId": peripheralId,
            "peripheralName": peripheralName,
            "bonded": bonded,
            "rssi": nil,
            "error": nil
        ]
        
        result(statusData)
    }

    func showAccessorySetup(call: FlutterMethodCall, result: @escaping FlutterResult) {
        // Ensure we have a flutter controller to present on
        guard let controller = flutterController else {
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
            saveAccessory(accessory: accessory)
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

    private func saveAccessory(accessory: ASAccessory) {
        primeAccessory = accessory

        let peripheralId = accessory.bluetoothIdentifier?.uuidString ?? accessory.displayName
        let peripheralName = accessory.displayName
        let isConnected = accessory.bluetoothIdentifier != nil

        print("Saving accessory: \(peripheralName)")
        print("  - Bluetooth ID: \(accessory.bluetoothIdentifier?.uuidString ?? "None")")
        print("  - Is connected: \(isConnected)")

        // Initialize CoreBluetooth manager if needed
        if centralManager == nil {
            setupBluetoothManager()
        }

        // Send connection event to Flutter
        sendConnectionEvent(
            connected: isConnected,
            peripheralId: peripheralId,
            peripheralName: peripheralName
        )
        
        if(setupResult != nil){
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

        print("Accessory removed: \(peripheralName)")

        // Disconnect CoreBluetooth connection if active
        if let peripheral = connectedPeripheral {
            disconnectPeripheral()
        }

        // Clear all references
        primeAccessory = nil
        deviceReady = false

        // Send disconnection event to Flutter
        sendConnectionEvent(
            connected: false,
            peripheralId: peripheralId,
            peripheralName: peripheralName,
            type: "device_disconnected"
        )

    }

    private func connectToAccessoryPeripheral(bluetoothId: UUID) {
        guard let central = centralManager, central.state == .poweredOn else {
            print("Central manager not ready for connection")
            return
        }

        let peripherals = central.retrievePeripherals(withIdentifiers: [bluetoothId])
        guard let peripheral = peripherals.first else {
            print("Could not retrieve peripheral with ID: \(bluetoothId)")
            return
        }

        print("Connecting to accessory peripheral: \(peripheral.name ?? "Unknown")")
        connectedPeripheral = peripheral
        peripheral.delegate = self
        central.connect(peripheral, options: connectOptions)
    }

    // MARK: - Binary Channel Handlers

    private func handleBinaryWrite(data: Data) -> Data {
        // Check if device is connected and ready
        guard let peripheral = connectedPeripheral else {
            // Send failure buffer (0 bytes)
            return Data()
        }

        guard peripheral.state == .connected && deviceReady else {
            return Data()
        }

        guard let writeChar = writeCharacteristic else {
            return Data()
        }

        // Validate data size
        if data.count < 8 {
            return Data()
        }

        // Determine write type and log details
        let writeType: CBCharacteristicWriteType =
            writeChar.properties.contains(.writeWithoutResponse) ? .withoutResponse : .withResponse

        print("WRITE OPERATION DETAILS:")
        print("  - Characteristic: \(writeChar.uuid)")
        print("  - Total Bytes: \(data.count)")

        // Check MTU and split data if necessary
        let mtu = peripheral.maximumWriteValueLength(for: writeType)
        print(" iOS MTU ANALYSIS:")
        print("  - iOS maximumWriteValueLength: \(mtu) bytes")
        print("  - Data length: \(data.count) bytes")
        print("  - Will use single packet: \(data.count <= mtu)")

        if data.count <= mtu {
            // Data fits in one packet
            print("iOS: Data fits in single packet, writing \(data.count) bytes directly")

            // Store data for potential retry
            pendingWriteData = data
            writeRetryCount = 0

            peripheral.writeValue(data, for: writeChar, type: writeType)

            // For writeWithoutResponse, simulate success since there's no callback
            if writeType == .withoutResponse {
                return Data([1])
            } else {
                // For writeWithResponse, success will be handled in didWriteValueFor callback
                return Data([1])  // Success indicator
            }
        } else {

            let chunks = data.chunked(into: mtu)

            for (index, chunk) in chunks.enumerated() {

                peripheral.writeValue(chunk, for: writeChar, type: writeType)

                // Add small delay between chunks for writeWithoutResponse to prevent buffer overflow
                if writeType == .withoutResponse && index < chunks.count - 1 {
                    Thread.sleep(forTimeInterval: 0.01)  // 10ms delay
                }
            }

            if writeType == .withoutResponse {
                return Data([1])  // Success indicator
            } else {
                return Data([1])
            }
        }
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("Central manager state: \(central.state)")
        // Send state update to Flutter
        sendBluetoothState(central.state)

        switch central.state {
        case .poweredOn:
            print("Bluetooth is powered on")
            handleBluetoothPoweredOn(central: central)

        case .poweredOff:
            print("Bluetooth is powered off")
            handleBluetoothPoweredOff()

        case .unauthorized:
            print("Bluetooth access unauthorized")
            sendConnectionEvent(
                connected: false,
                peripheralId: "bluetooth_system",
                peripheralName: "Bluetooth System",
                type: nil,
                error: "Bluetooth access unauthorized"
            )

        case .unsupported:
            print("Bluetooth not supported on this device")
            sendConnectionEvent(
                connected: false,
                peripheralId: "bluetooth_system",
                peripheralName: "Bluetooth System",
                type: nil,
                error: "Bluetooth not supported"
            )

        case .unknown:
            print("Bluetooth state unknown - waiting for state update...")

        case .resetting:
            print("Bluetooth is resetting")
            handleBluetoothResetting()

        @unknown default:
            print("Unknown Bluetooth state: \(central.state.rawValue)")
            sendConnectionEvent(
                connected: false,
                peripheralId: "bluetooth_system",
                peripheralName: "Bluetooth System",
                type: nil,
                error: "Unknown Bluetooth state"
            )
        }
    }

    private func handleBluetoothPoweredOn(central: CBCentralManager) {

        // Send connection event for powered on state
        sendConnectionEvent(
            connected: false,
            peripheralId: "bluetooth_system",
            peripheralName: "Passport Prime",
            type: nil,
            error: nil
        )

        // Check if we have an accessory that needs CoreBluetooth connection
        if let accessory = primeAccessory,
            let bluetoothId = accessory.bluetoothIdentifier
        {
            connectToAccessoryPeripheral(bluetoothId: bluetoothId)
            return
        }

        if needsServiceRediscovery, let peripheral = connectedPeripheral {
            handleRestoredPeripheral(peripheral: peripheral, central: central)
            return
        }

        if primeAccessory == nil {
            print("Starting scan for peripherals...")
            central.scanForPeripherals(withServices: [primeUUID], options: nil)
        }
    }

    private func handleBluetoothPoweredOff() {
        deviceReady = false

        // Send disconnection event for any connected peripheral
        if let peripheral = connectedPeripheral {
            sendConnectionEvent(
                connected: false,
                peripheralId: peripheral.identifier.uuidString,
                peripheralName: peripheral.name,
                type: nil,
                error: "Bluetooth powered off"
            )
        } else {
            // Send generic bluetooth off event
            sendConnectionEvent(
                connected: false,
                peripheralId: "bluetooth_system",
                peripheralName: "Bluetooth System",
                type: nil,
                error: "Bluetooth powered off"
            )
        }
    }

    private func handleBluetoothResetting() {
        deviceReady = false

        // Send temporary disconnection event
        if let peripheral = connectedPeripheral {
            sendConnectionEvent(
                connected: false,
                peripheralId: peripheral.identifier.uuidString,
                peripheralName: peripheral.name,
                error: "Bluetooth resetting"
            )
        }
    }

    private func handleRestoredPeripheral(peripheral: CBPeripheral, central: CBCentralManager) {
        if peripheral.state == .connected {
            peripheral.discoverServices([primeUUID])

            // Send reconnection event
            sendConnectionEvent(
                connected: true,
                peripheralId: peripheral.identifier.uuidString,
                peripheralName: peripheral.name,
                type: "device_connected"
            )
        } else {
            print("Attempting to reconnect to restored peripheral...")
            central.connect(
                peripheral,
                options: connectOptions)
        }
        needsServiceRediscovery = false
    }

    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String: Any]) {
        print("Central state changed: \(central.state.rawValue)")

        // Retrieve peripherals that were connected or pending
        if let peripherals = dict[CBCentralManagerRestoredStatePeripheralsKey] as? [CBPeripheral] {
            for peripheral in peripherals {
                peripheral.delegate = self
                connectedPeripheral = peripheral
                print("Restored peripheral: \(peripheral.identifier)")
                print("  - Name: \(peripheral.name ?? "Unknown")")
                print("  - State: \(peripheral.state.rawValue)")
                deviceReady = false
                print("  - Characteristics will be rediscovered after restoration")
                if peripheral.state == .connected {
                    needsServiceRediscovery = true
                }
            }
        } else {
            print("No peripherals to restore")
        }
    }

    func centralManager(
        _ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
        advertisementData: [String: Any], rssi RSSI: NSNumber
    ) {
        print("Discovered peripheral: \(peripheral.name ?? "Unknown") with RSSI: \(RSSI)")
        central.stopScan()
        connectedPeripheral = peripheral
        peripheral.delegate = self
        central.connect(
            peripheral,
            options: connectOptions)
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Successfully connected to peripheral: \(peripheral.name ?? "Unknown")")
        print(" - Identifier: \(peripheral.identifier)")
        peripheral.delegate = self
        deviceReady = false  // Will be set to true once characteristics are discovered

        stopReconnection()

        peripheral.discoverServices([primeUUID])

        sendConnectionEvent(
            connected: true,
            peripheralId: peripheral.identifier.uuidString,
            peripheralName: peripheral.name,
            type:"device_connected"
        )
    }

    func centralManager(
        _ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?
    ) {

        print("Failed to connect to peripheral: \(error?.localizedDescription ?? "Unknown error")")
        connectedPeripheral = nil
        deviceReady = false
        sendConnectionEvent(
            connected: false,
            peripheralId: peripheral.identifier.uuidString,
            peripheralName: peripheral.name, error: error?.localizedDescription)
    }

    func centralManager(
        _ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?
    ) {
        print("Disconnected from peripheral: \(error?.localizedDescription ?? "No error")")

        // Clear peripheral reference and characteristics
        if connectedPeripheral?.identifier == peripheral.identifier {
            connectedPeripheral = nil
            writeCharacteristic = nil
            readCharacteristic = nil
            deviceReady = false
        }

        sendConnectionEvent(
            connected: false,
            peripheralId: peripheral.identifier.uuidString,
            peripheralName: peripheral.name,
            type:"device_disconnected",
            error: error?.localizedDescription
        )

        print("Starting automatic reconnection...")
        attemptReconnection()
    }

    // MARK: - CBPeripheralDelegate

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("Error discovering services: \(error.localizedDescription)")
            return
        }

        guard let services = peripheral.services else {
            print("No services found")
            return
        }

        print("Discovered \(services.count) services:")
        for service in services {
            print("  - Service: \(service.uuid)")
            if service.uuid == primeUUID {
                print("Found target Prime service, discovering characteristics...")
                peripheral.discoverCharacteristics(nil, for: service)
            } else {
                print("Skipping non-target service")
            }
        }
    }

    func peripheral(
        _ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?
    ) {
        if let error = error {
            print("Error discovering characteristics: \(error.localizedDescription)")
            return
        }

        guard let characteristics = service.characteristics else {
            print("No characteristics found for service: \(service.uuid)")
            return
        }

        print("Discovered \(characteristics.count) characteristics for service \(service.uuid):")

        for characteristic in characteristics {

            // Store characteristics based on their properties
            if characteristic.properties.contains(.write)
                || characteristic.properties.contains(.writeWithoutResponse)
            {
                writeCharacteristic = characteristic
                print(
                    "Set write characteristic: \(characteristic.uuid)"
                )
            }

            if characteristic.properties.contains(.read) {
                readCharacteristic = characteristic
                peripheral.readValue(for: characteristic)
                print("Set read characteristic: \(characteristic.uuid)")
            }

            if characteristic.properties.contains(.notify) {
                peripheral.setNotifyValue(true, for: characteristic)
                print("Enabled notifications for characteristic: \(characteristic.uuid)")
            }

            if characteristic.properties.contains(.indicate) {
                peripheral.setNotifyValue(true, for: characteristic)
                print("Enabled indications for characteristic: \(characteristic.uuid)")
            }
        }

        // Log the final state
        print("Characteristics setup complete:")
        print("  - Write characteristic: \(writeCharacteristic?.uuid.uuidString ?? "None")")
        print("  - Read characteristic: \(readCharacteristic?.uuid.uuidString ?? "None")")

        // Mark device as ready for communication
        if writeCharacteristic != nil || readCharacteristic != nil {
            deviceReady = true
            print("Device is ready for communication")

            // Notify Flutter that device is ready for communication
            sendConnectionEvent(
                connected: true,
                peripheralId: peripheral.identifier.uuidString,
                peripheralName: peripheral.name
            )
        } else {
            print("No usable characteristics found")
            deviceReady = false
        }
    }

    func peripheral(
        _ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic,
        error: Error?
    ) {
        if let error = error {
            print("Error reading characteristic value: \(error.localizedDescription)")
            if let sink = eventSink {
                sink(
                    FlutterError(
                        code: "BLE_READ_ERROR",
                        message: "Failed to read characteristic value",
                        details: error.localizedDescription))
            }
            return
        }

        guard let data = characteristic.value else {
            print("No data received from characteristic: \(characteristic.uuid)")
            return
        }

        sendBinaryData(data)
    }

    func peripheral(
        _ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?
    ) {
        if let error = error {
            print("WRITE ERROR:")
            print("  - Characteristic: \(characteristic.uuid)")
            print("  - Error: \(error.localizedDescription)")

            if writeRetryCount < maxWriteRetries, let retryData = pendingWriteData {
                writeRetryCount += 1
                print("Retrying write operation (attempt \(writeRetryCount)/\(maxWriteRetries))")

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    peripheral.writeValue(retryData, for: characteristic, type: .withResponse)
                }
                return
            }

            // Max retries reached, clear pending data
            pendingWriteData = nil
            writeRetryCount = 0
            return
        }

        // Clear retry data on success
        pendingWriteData = nil
        writeRetryCount = 0
         
    }
    
   

    func peripheral(
        _ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic,
        error: Error?
    ) {
        if let error = error {
            print("Error updating notification state: \(error.localizedDescription)")
            return
        }

    }

    private func sendBinaryData(_ data: Data) {
        guard let binaryChannel = bleBinaryChannel else {
            print("Warning: No binary channel available for data transmission")
            return
        }

        binaryChannel.sendMessage(data) { (reply) in
            if let error = reply as? FlutterError {
                print("Flutter binary data error: \(error.message ?? "Unknown error")")
            } else if reply != nil {

            }
        }

    }

    func isConnected() -> Bool {
        return connectedPeripheral != nil
    }

    // MARK: - Connection Management

    func disconnectPeripheral() {
        guard let central = centralManager else {
            print("No central manager available for disconnect")
            return
        }

        guard let peripheral = connectedPeripheral else {
            print("No peripheral to disconnect")
            return
        }

        // Only disconnect if actually connected
        guard peripheral.state == .connected || peripheral.state == .connecting else {
            print("Peripheral not connected (state: \(peripheral.state)), skipping disconnect")
            return
        }
        central.cancelPeripheralConnection(peripheral)
        Task {
            await removeAccessory()
        }
        deviceReady = false
    }

    // MARK: - Accessory Management

    func removeAccessory() async {
        guard let accessory = primeAccessory else { return }

        if isConnected() {
            disconnectPeripheral()
        }

        do {
            try await session.removeAccessory(accessory)
            primeAccessory = nil
            deviceReady = false
            print("Successfully removed accessory")
        } catch {
            print("Failed to remove accessory: \(error.localizedDescription)")
        }
    }

    // MARK: - Stream Helper Methods

    /// Verifies and updates connection status using proper CoreBluetooth APIs
    func verifyAndUpdateConnectionStatus() {
        guard let central = centralManager else {
            print(" No central manager available for connection verification")
            return
        }

        // Only check if central is powered on
        guard central.state == .poweredOn else {
            print(
                "Central manager not powered on (state: \(central.state)), skipping verification")
            return
        }

        let connectedPeripherals = central.retrieveConnectedPeripherals(withServices: [primeUUID])
        print(
            "CoreBluetooth reports \(connectedPeripherals.count) connected peripherals with target service"
        )

        if let storedPeripheral = connectedPeripheral {
            let isStillConnected = connectedPeripherals.contains {
                $0.identifier == storedPeripheral.identifier
            }

            if !isStillConnected {
                print("Stored peripheral is no longer connected, sending disconnect event")
                sendConnectionEvent(
                    connected: false,
                    peripheralId: storedPeripheral.identifier.uuidString,
                    peripheralName: storedPeripheral.name,
                    error: "Connection lost - not in retrieveConnectedPeripherals"
                )

                // Clear all references to avoid API misuse
                connectedPeripheral = nil
                writeCharacteristic = nil
                readCharacteristic = nil
                deviceReady = false
            }
        }

        // Check if there are new connected peripherals we don't know about
        for peripheral in connectedPeripherals {
            if connectedPeripheral?.identifier != peripheral.identifier {
                print(" Found unknown connected peripheral: \(peripheral.name ?? "Unknown")")
                print("  - State: \(peripheral.state)")
                print("  - Identifier: \(peripheral.identifier)")

                // Only update if peripheral is actually connected
                if peripheral.state == .connected {
                    connectedPeripheral = peripheral
                    peripheral.delegate = self

                    sendConnectionEvent(
                        connected: true,
                        peripheralId: peripheral.identifier.uuidString,
                        peripheralName: peripheral.name
                    )

                    // Discover services for this peripheral
                    peripheral.discoverServices([primeUUID])
                } else {
                    print("  - Peripheral not in connected state, skipping")
                }
            }
        }
    }

    func sendConnectionEvent(
        connected: Bool,
        peripheralId: String,
        peripheralName: String? = nil,
        type: String? = nil,
        error: String? = nil
    ) {

        let connectionData: [String: Any] = [
            "type": type,
            "connected": connected,
            "peripheralId": peripheralId,
            "peripheralName": peripheralName ?? NSNull(),
            "timestamp": Date().timeIntervalSince1970 * 1000,
            "error": error ?? NSNull(),
        ]

        guard let sink = connectionEventSink else {
            needsToResendConnectionState = connectionData
            print("Warning: Connection event sink not available, event not sent")
            return
        }

        sink(connectionData)
        print(
            "Connection Event -> Flutter: connected=\(connected), peripheral=\(peripheralName ?? peripheralId)"
        )
        if let error = error {
            print("   Error: \(error)")
        }
    }
    
    private func sendWriteProgress(_ progress: Float, id: String, bytesProcessed: Int64 = 0, totalBytes: Int64 = 0) {
        guard let sink = writeStreamSink else { return }
        
        let stateData: [String: Any] = [
            "id": id,
            "progress": progress,
            "bytes_processed": bytesProcessed,
            "total_bytes": totalBytes
         ]
    
        sink(stateData)
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
        print("Sent Bluetooth state to Flutter: \(stateString)")
    }

    // MARK: - FlutterStreamHandler

    public func onListen(
        withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink
    ) -> FlutterError? {
        eventSink = events
        print("Flutter stream listener attached")

        // Send current Bluetooth state when listener attaches
        if let manager = centralManager {
            sendBluetoothState(manager.state)
        }

        // Verify and send actual connection status using proper CoreBluetooth API
        verifyAndUpdateConnectionStatus()

        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        print("Flutter stream listener detached")
        return nil
    }
}

// MARK: - ConnectionStreamHandler

class ConnectionStreamHandler: NSObject, FlutterStreamHandler {
    weak var bluetoothChannel: BluetoothChannel?

    init(bluetoothChannel: BluetoothChannel) {
        self.bluetoothChannel = bluetoothChannel
    }

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink)
        -> FlutterError?
    {
        bluetoothChannel?.connectionEventSink = events

        // Stream attached send any pending connection state
        if let needsToResend = bluetoothChannel?.needsToResendConnectionState {
            events(needsToResend)
            bluetoothChannel?.needsToResendConnectionState = nil
        }

        // Verify and send actual connection status using proper CoreBluetooth API
        if let channel = bluetoothChannel {
            channel.verifyAndUpdateConnectionStatus()
        }

        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        bluetoothChannel?.connectionEventSink = nil
        return nil
    }

}

// MARK: - ConnectionStreamHandler

class ProgressStreamHandler: NSObject, FlutterStreamHandler {
    weak var bluetoothChannel: BluetoothChannel?

    init(bluetoothChannel: BluetoothChannel) {
        self.bluetoothChannel = bluetoothChannel
    }

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink)
        -> FlutterError?
    {
        bluetoothChannel?.writeStreamSink = events
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        bluetoothChannel?.connectionEventSink = nil
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
