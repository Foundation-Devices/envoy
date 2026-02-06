import CoreBluetooth
import Flutter
import Foundation

/// Protocol for QLConnection to communicate events back to BluetoothChannel
protocol QLConnectionDelegate: AnyObject {
    func onDeviceDisconnected(device: QLConnection)
    func getCentralManager() -> CBCentralManager?
}

/// Represents a single BLE device connection with all device-specific state and operations.
/// Each device has its own Flutter channels for communication.
///
/// Channel naming convention:
/// - Method channel: envoy/bluetooth/{deviceId}
/// - Read channel: envoy/ble/read/{deviceId}
/// - Write channel: envoy/ble/write/{deviceId}
/// - Connection stream: envoy/bluetooth/connection/stream/{deviceId}
/// - Write progress stream: envoy/ble/write/progress/{deviceId}
class QLConnection: NSObject {

    // MARK: - Constants

    private static let TAG = "QLConnection"
    private static let METHOD_CHANNEL_NAME = "envoy/bluetooth"
    private static let BLE_READ_CHANNEL_NAME = "envoy/ble/read"
    private static let BLE_WRITE_CHANNEL_NAME = "envoy/ble/write"
    private static let BLE_CONNECTION_STREAM_NAME = "envoy/bluetooth/connection/stream"
    private static let BLE_WRITE_PROGRESS_STREAM_NAME = "envoy/ble/write/progress"
    private static let BLE_PACKET_SIZE = 244

    // Service UUID for Prime device
    private let primeUUID: CBUUID = CBUUID(string: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E")

    // MARK: - Properties

    let deviceId: String
    private weak var delegate: QLConnectionDelegate?
    private let binaryMessenger: FlutterBinaryMessenger
    private let bleQueue = DispatchQueue(label: "com.envoy.ble.device", qos: .userInteractive)

    // Device-specific channels
    private let methodChannel: FlutterMethodChannel
    private let bleReadChannel: FlutterBasicMessageChannel
    private let bleWriteChannel: FlutterBasicMessageChannel
    private let connectionEventChannel: FlutterEventChannel
    private let writeProgressEventChannel: FlutterEventChannel

    // Event sinks
    private var connectionEventSink: FlutterEventSink?
    private var writeProgressEventSink: FlutterEventSink?

    // Device state
    private(set) var connectedPeripheral: CBPeripheral?
    private var writeCharacteristic: CBCharacteristic?
    private var readCharacteristic: CBCharacteristic?

    // Write operation state
    private var bleWriteQueue: BleWriteQueue?
    private var deviceReady = false

    // Transfer state
    private var transferTask: Task<Void, Never>?

    // Pending connection state to resend when sink attaches
    private var needsToResendConnectionState: [String: Any]?

    /// The UUID string of the connected device
    var peripheralId: String {
        return deviceId
    }

    /// The name of the connected device
    var peripheralName: String? {
        return connectedPeripheral?.name
    }

    /// Whether the device is bonded (has accessory)
    var isBonded: Bool {
        // On iOS, we consider a device bonded if it's been paired via AccessorySetupKit
        // This is managed by the parent BluetoothChannel
        return true
    }

    // MARK: - Initialization

    init(deviceId: String, binaryMessenger: FlutterBinaryMessenger, delegate: QLConnectionDelegate) {
        self.deviceId = deviceId
        self.binaryMessenger = binaryMessenger
        self.delegate = delegate

        // Initialize device-specific channels
        self.methodChannel = FlutterMethodChannel(
            name: "\(Self.METHOD_CHANNEL_NAME)/\(deviceId)",
            binaryMessenger: binaryMessenger
        )

        self.bleReadChannel = FlutterBasicMessageChannel(
            name: "\(Self.BLE_READ_CHANNEL_NAME)/\(deviceId)",
            binaryMessenger: binaryMessenger,
            codec: FlutterBinaryCodec.sharedInstance()
        )

        self.bleWriteChannel = FlutterBasicMessageChannel(
            name: "\(Self.BLE_WRITE_CHANNEL_NAME)/\(deviceId)",
            binaryMessenger: binaryMessenger,
            codec: FlutterBinaryCodec.sharedInstance()
        )

        self.connectionEventChannel = FlutterEventChannel(
            name: "\(Self.BLE_CONNECTION_STREAM_NAME)/\(deviceId)",
            binaryMessenger: binaryMessenger
        )

        self.writeProgressEventChannel = FlutterEventChannel(
            name: "\(Self.BLE_WRITE_PROGRESS_STREAM_NAME)/\(deviceId)",
            binaryMessenger: binaryMessenger
        )

        super.init()

        print("\(Self.TAG) [\(deviceId)] QLConnection init - registering channels...")
        print("\(Self.TAG) [\(deviceId)] Method channel: \(Self.METHOD_CHANNEL_NAME)/\(deviceId)")
        print("\(Self.TAG) [\(deviceId)] Connection stream: \(Self.BLE_CONNECTION_STREAM_NAME)/\(deviceId)")

        setupChannelHandlers()
    }

    private func setupChannelHandlers() {
        if !Thread.isMainThread {
            DispatchQueue.main.async { [weak self] in
                self?.setupChannelHandlers()
            }
            return
        }

        // Set up method channel handler
        methodChannel.setMethodCallHandler { [weak self] (call, result) in
            guard let self = self else {
                result(FlutterError(code: "DEALLOCATED", message: "QLConnection deallocated", details: nil))
                return
            }
            self.handleMethodCall(call: call, result: result)
        }
        print("\(Self.TAG) [\(deviceId)] MethodChannel handler set")

        // Set up connection event stream handler
        connectionEventChannel.setStreamHandler(ConnectionStreamHandler(bleDevice: self))
        print("\(Self.TAG) [\(deviceId)] ConnectionEventChannel StreamHandler set")

        // Set up write progress stream handler
        writeProgressEventChannel.setStreamHandler(WriteProgressStreamHandler(bleDevice: self))

        // Set up binary write channel handler
        bleWriteChannel.setMessageHandler { [weak self] (message, reply) in
            guard let self = self else {
                reply(Data())
                return
            }

            if let data = message as? Data {
                let replyStatus = self.handleBinaryWrite(data: data)
                reply(replyStatus)
            } else {
                reply(Data())
            }
        }
    }

    // MARK: - Method Call Handler

    private func handleMethodCall(call: FlutterMethodCall, result: @escaping FlutterResult) {
        print("\(Self.TAG) onMethodCall: call received \(call.method)")

        switch call.method {
        case "getCurrentDeviceStatus":
            getCurrentDeviceStatus(result: result)
        case "transmitFromFile":
            transmitFromFile(call: call, result: result)
        case "disconnect":
            disconnect(result: result)
        case "getConnectedPeripheralId":
            result(peripheralId)
        case "isConnected":
            result(isConnected())
        case "cancelTransfer":
            cancelTransfer(result: result)
        case "reconnect":
            reconnect(result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // MARK: - Connection State

    func isConnected() -> Bool {
        return connectedPeripheral?.state == .connected && deviceReady
    }

    // MARK: - Connection Management

    /// Connect to a peripheral
    func connect(peripheral: CBPeripheral) {
        print("\(Self.TAG) [\(deviceId)] Connecting to: \(peripheral.name ?? "Unknown") (\(peripheral.identifier))")

        // Close existing connection if any
        if let existingPeripheral = connectedPeripheral, existingPeripheral.identifier != peripheral.identifier {
            print("\(Self.TAG) [\(deviceId)] Closing existing connection")
            delegate?.getCentralManager()?.cancelPeripheralConnection(existingPeripheral)
        }

        sendConnectionEvent(type: "connection_attempt")

        connectedPeripheral = peripheral
        peripheral.delegate = self

        // Connect via central manager
        let connectOptions: [String: Any] = [
            CBConnectPeripheralOptionNotifyOnConnectionKey: true,
            CBConnectPeripheralOptionNotifyOnDisconnectionKey: true,
            CBConnectPeripheralOptionNotifyOnNotificationKey: true,
            CBConnectPeripheralOptionStartDelayKey: 0,
            CBConnectPeripheralOptionEnableTransportBridgingKey: false
        ]

        delegate?.getCentralManager()?.connect(peripheral, options: connectOptions)
    }

    /// Disconnect from the device
    private func disconnect(result: @escaping FlutterResult) {
        guard let peripheral = connectedPeripheral else {
            result(["disconnecting": false, "message": "No device connected"])
            return
        }

        print("\(Self.TAG) [\(deviceId)] Disconnecting from device")
        bleWriteQueue?.cancel()
        bleWriteQueue = nil

        delegate?.getCentralManager()?.cancelPeripheralConnection(peripheral)
        result(["disconnecting": true])
    }

    private func getCurrentDeviceStatus(result: @escaping FlutterResult) {
        let statusData: [String: Any?] = [
            "type": nil,
            "connected": isConnected(),
            "peripheralId": deviceId,
            "peripheralName": connectedPeripheral?.name ?? "Unknown Device",
            "bonded": isBonded,
            "rssi": nil,
            "error": nil
        ]
        result(statusData)
    }

    /// Reconnect to the device
    private func reconnect(result: @escaping FlutterResult) {
        guard let central = delegate?.getCentralManager(), central.state == .poweredOn else {
            result(FlutterError(code: "NO_CENTRAL", message: "Central manager not available or not powered on", details: nil))
            return
        }

        guard let uuid = UUID(uuidString: deviceId) else {
            result(FlutterError(code: "INVALID_ID", message: "Invalid device ID: \(deviceId)", details: nil))
            return
        }

        let peripherals = central.retrievePeripherals(withIdentifiers: [uuid])
        guard let peripheral = peripherals.first else {
            result(FlutterError(code: "DEVICE_NOT_FOUND", message: "Device not found: \(deviceId)", details: nil))
            return
        }

        print("\(Self.TAG) [\(deviceId)] Reconnecting to device: \(peripheral.name ?? "Unknown")")
        connect(peripheral: peripheral)
        result(["reconnecting": true])
    }

    // MARK: - File Transfer

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

        if transferTask != nil {
            result(FlutterError(code: "TRANSFER_IN_PROGRESS", message: "Another transfer is already in progress", details: nil))
            return
        }

        transferTask = Task {
            do {
                let attributes = try FileManager.default.attributesOfItem(atPath: path)
                let fileSize = attributes[.size] as? Int64 ?? 0
                var bytesProcessed: Int64 = 0

                let fileHandle = try FileHandle(forReadingFrom: fileURL)
                defer {
                    try? fileHandle.close()
                }

                let chunkSize = Self.BLE_PACKET_SIZE

                while true {
                    if Task.isCancelled {
                        await MainActor.run {
                            result(FlutterError(code: "TRANSFER_CANCELLED", message: "Data transmission cancelled", details: nil))
                        }
                        return
                    }

                    let chunk = try fileHandle.read(upToCount: chunkSize)

                    guard let data = chunk, !data.isEmpty else {
                        break
                    }

                    let success = await bleWriteQueue?.enqueue(data: data) ?? false

                    if !success {
                        throw NSError(
                            domain: "BLEWriteError",
                            code: 1,
                            userInfo: [NSLocalizedDescriptionKey: "Failed to write data at byte \(bytesProcessed)"]
                        )
                    }

                    bytesProcessed += Int64(data.count)

                    let progress = fileSize > 0 ? Float(bytesProcessed) / Float(fileSize) : 0.0
                    sendWriteProgress(progress, id: path, bytesProcessed: bytesProcessed, totalBytes: fileSize)
                }

                sendWriteProgress(1.0, id: path, bytesProcessed: fileSize, totalBytes: fileSize)

                try? FileManager.default.removeItem(at: fileURL)
                print("\(Self.TAG) [\(deviceId)] Successfully deleted file: \(path)")

                await MainActor.run {
                    result([
                        "success": true,
                        "message": "Large data processed successfully"
                    ])
                }

            } catch {
                print("\(Self.TAG) [\(deviceId)] Error reading large data file: \(error.localizedDescription)")
                await MainActor.run {
                    result(FlutterError(code: "FILE_READ_ERROR", message: "Failed to read file: \(error.localizedDescription)", details: nil))
                }
            }

            transferTask = nil
        }
    }

    private func cancelTransfer(result: @escaping FlutterResult) {
        if let task = transferTask {
            task.cancel()
            transferTask = nil
            bleWriteQueue?.cancel()
            sendWriteProgress(0.0, id: "transfer_cancelled", bytesProcessed: 0, totalBytes: 0)
            bleWriteQueue?.restart()
            result(["cancelled": true])
            print("\(Self.TAG) [\(deviceId)] Transfer cancelled successfully")
        } else {
            result(["cancelled": false, "message": "No active transfer to cancel"])
            print("\(Self.TAG) [\(deviceId)] No active transfer to cancel")
        }
    }

    // MARK: - Binary Write Handler

    private func handleBinaryWrite(data: Data) -> Data {
        guard let peripheral = connectedPeripheral else {
            print("\(Self.TAG) [\(deviceId)] No connected peripheral")
            return Data()
        }

        guard peripheral.state == .connected && deviceReady else {
            print("\(Self.TAG) [\(deviceId)] Device not ready")
            return Data()
        }

        guard let writeChar = writeCharacteristic else {
            print("\(Self.TAG) [\(deviceId)] No write characteristic available")
            return Data()
        }

        if data.count < 8 {
            return Data()
        }

        if bleWriteQueue == nil {
            bleWriteQueue = BleWriteQueue(peripheral: peripheral, characteristic: writeChar)
        }

        let maxMTU = Self.BLE_PACKET_SIZE

        Task {
            if data.count <= maxMTU {
                let _ = await bleWriteQueue?.enqueue(data: data) ?? false
            } else {
                let chunks = data.chunked(into: maxMTU)
                print("\(Self.TAG) [\(deviceId)] Writing chunks: \(chunks.count)")
                for chunk in chunks {
                    Task {
                        let _ = await bleWriteQueue?.enqueue(data: chunk) ?? false
                    }
                }
            }
        }

        // Return success immediately (actual write happens asynchronously)
        return Data([1])
    }

    // MARK: - Event Sending

    func sendConnectionEvent(
        type: String? = nil,
        error: String? = nil
    ) {
        let connectionData: [String: Any] = [
            "type": type as Any,
            "connected": isConnected(),
            "peripheralId": deviceId,
            "peripheralName": connectedPeripheral?.name ?? "Unknown Device",
            "bonded": isBonded,
            "timestamp": Date().timeIntervalSince1970 * 1000,
            "error": error ?? NSNull()
        ]

        guard let sink = connectionEventSink else {
            needsToResendConnectionState = connectionData
            print("\(Self.TAG) [\(deviceId)] Warning: Connection event sink not available, event not sent")
            return
        }

        sink(connectionData)
        print("\(Self.TAG) [\(deviceId)] Connection Event -> Flutter: connected=\(isConnected()), type=\(type ?? "nil")")
        if let error = error {
            print("\(Self.TAG) [\(deviceId)]    Error: \(error)")
        }
    }

    private func sendWriteProgress(_ progress: Float, id: String, bytesProcessed: Int64 = 0, totalBytes: Int64 = 0) {
        guard let sink = writeProgressEventSink else { return }

        let stateData: [String: Any] = [
            "id": id,
            "progress": progress,
            "bytes_processed": bytesProcessed,
            "total_bytes": totalBytes
        ]

        sink(stateData)
    }

    private func sendBinaryData(_ data: Data) {
        bleReadChannel.sendMessage(data) { reply in
            if let error = reply as? FlutterError {
                print("\(Self.TAG) [\(self.deviceId)] Flutter binary data error: \(error.message ?? "Unknown error")")
            }
        }
    }

    // MARK: - Cleanup

    func cleanup() {
        print("\(Self.TAG) [\(deviceId)] Cleaning up QLConnection")

        transferTask?.cancel()
        bleWriteQueue?.cancel()

        if let peripheral = connectedPeripheral {
            delegate?.getCentralManager()?.cancelPeripheralConnection(peripheral)
        }

        // Clear channel handlers (must be on main thread for Flutter messenger)
        let clearHandlers = {
            self.methodChannel.setMethodCallHandler(nil)
            self.bleWriteChannel.setMessageHandler(nil)
        }
        if Thread.isMainThread {
            clearHandlers()
        } else {
            DispatchQueue.main.async(execute: clearHandlers)
        }

        connectedPeripheral = nil
        writeCharacteristic = nil
        readCharacteristic = nil
        bleWriteQueue = nil
        connectionEventSink = nil
        writeProgressEventSink = nil
        deviceReady = false

        print("\(Self.TAG) [\(deviceId)] QLConnection cleaned up")
    }

    // MARK: - Stream Handlers

    private class ConnectionStreamHandler: NSObject, FlutterStreamHandler {
        weak var bleDevice: QLConnection?

        init(bleDevice: QLConnection) {
            self.bleDevice = bleDevice
        }

        func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
            bleDevice?.connectionEventSink = events

            // Send any pending connection state
            if let needsToResend = bleDevice?.needsToResendConnectionState {
                events(needsToResend)
                bleDevice?.needsToResendConnectionState = nil
            }

            // Send current status when listener attaches
            if bleDevice?.connectedPeripheral != nil {
                bleDevice?.sendConnectionEvent(
                    type: bleDevice?.isConnected() == true ? "device_connected" : "device_disconnected"
                )
            }

            return nil
        }

        func onCancel(withArguments arguments: Any?) -> FlutterError? {
            bleDevice?.connectionEventSink = nil
            return nil
        }
    }

    private class WriteProgressStreamHandler: NSObject, FlutterStreamHandler {
        weak var bleDevice: QLConnection?

        init(bleDevice: QLConnection) {
            self.bleDevice = bleDevice
        }

        func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
            bleDevice?.writeProgressEventSink = events
            return nil
        }

        func onCancel(withArguments arguments: Any?) -> FlutterError? {
            bleDevice?.writeProgressEventSink = nil
            return nil
        }
    }
}

// MARK: - CBPeripheralDelegate

extension QLConnection: CBPeripheralDelegate {

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("\(Self.TAG) [\(deviceId)] Error discovering services: \(error.localizedDescription)")
            return
        }

        guard let services = peripheral.services else {
            print("\(Self.TAG) [\(deviceId)] No services found")
            return
        }

        print("\(Self.TAG) [\(deviceId)] Discovered \(services.count) services:")
        for service in services {
            print("\(Self.TAG) [\(deviceId)]   - Service: \(service.uuid)")
            if service.uuid == primeUUID {
                print("\(Self.TAG) [\(deviceId)] Found target Prime service, discovering characteristics...")
                peripheral.discoverCharacteristics(nil, for: service)
            } else {
                print("\(Self.TAG) [\(deviceId)] Skipping non-target service")
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            print("\(Self.TAG) [\(deviceId)] Error discovering characteristics: \(error.localizedDescription)")
            return
        }

        guard let characteristics = service.characteristics else {
            print("\(Self.TAG) [\(deviceId)] No characteristics found for service: \(service.uuid)")
            return
        }

        print("\(Self.TAG) [\(deviceId)] Discovered \(characteristics.count) characteristics for service \(service.uuid):")

        for characteristic in characteristics {
            // Store characteristics based on their properties
            if characteristic.properties.contains(.write) ||
                characteristic.properties.contains(.writeWithoutResponse) {
                writeCharacteristic = characteristic
                // Initialize write queue with new characteristic
                bleWriteQueue = BleWriteQueue(peripheral: peripheral, characteristic: characteristic)
                print("\(Self.TAG) [\(deviceId)] Set write characteristic: \(characteristic.uuid)")
            }

            if characteristic.properties.contains(.read) {
                readCharacteristic = characteristic
                peripheral.readValue(for: characteristic)
                print("\(Self.TAG) [\(deviceId)] Set read characteristic: \(characteristic.uuid)")
            }

            if characteristic.properties.contains(.notify) {
                peripheral.setNotifyValue(true, for: characteristic)
                print("\(Self.TAG) [\(deviceId)] Enabled notifications for characteristic: \(characteristic.uuid)")
            }

            if characteristic.properties.contains(.indicate) {
                peripheral.setNotifyValue(true, for: characteristic)
                print("\(Self.TAG) [\(deviceId)] Enabled indications for characteristic: \(characteristic.uuid)")
            }
        }

        // Log the final state
        print("\(Self.TAG) [\(deviceId)] Characteristics setup complete:")
        print("\(Self.TAG) [\(deviceId)]   - Write characteristic: \(writeCharacteristic?.uuid.uuidString ?? "None")")
        print("\(Self.TAG) [\(deviceId)]   - Read characteristic: \(readCharacteristic?.uuid.uuidString ?? "None")")

        // Mark device as ready for communication
        if writeCharacteristic != nil || readCharacteristic != nil {
            deviceReady = true
            print("\(Self.TAG) [\(deviceId)] Device is ready for communication")

            // Notify Flutter that device is ready for communication
            sendConnectionEvent(type: "device_connected")
        } else {
            print("\(Self.TAG) [\(deviceId)] No usable characteristics found")
            deviceReady = false
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("\(Self.TAG) [\(deviceId)] Error reading characteristic value: \(error.localizedDescription)")
            return
        }

        guard let data = characteristic.value else {
            print("\(Self.TAG) [\(deviceId)] No data received from characteristic: \(characteristic.uuid)")
            return
        }

        sendBinaryData(data)
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("\(Self.TAG) [\(deviceId)] Error updating notification state: \(error.localizedDescription)")
            return
        }
        print("\(Self.TAG) [\(deviceId)] Notification state updated for \(characteristic.uuid): \(characteristic.isNotifying)")
    }

  
}

// MARK: - Connection State Handlers (called by BluetoothChannel)

extension QLConnection {

    /// Called when the device successfully connects
    func onDidConnect(peripheral: CBPeripheral) {
        print("\(Self.TAG) [\(deviceId)] Successfully connected to peripheral: \(peripheral.name ?? "Unknown")")
        connectedPeripheral = peripheral
        peripheral.delegate = self
        deviceReady = false  // Will be set to true once characteristics are discovered

        // Discover services
        peripheral.discoverServices([primeUUID])

        sendConnectionEvent(type: "device_connected")
    }

    /// Called when the device fails to connect
    func onDidFailToConnect(peripheral: CBPeripheral, error: Error?) {
        print("\(Self.TAG) [\(deviceId)] Failed to connect to peripheral: \(error?.localizedDescription ?? "Unknown error")")
        connectedPeripheral = nil
        deviceReady = false

        sendConnectionEvent(type: "connection_error", error: error?.localizedDescription)
    }

    /// Called when the device disconnects
    func onDidDisconnect(peripheral: CBPeripheral, error: Error?) {
        print("\(Self.TAG) [\(deviceId)] Disconnected from peripheral: \(error?.localizedDescription ?? "No error")")

        // Clear peripheral reference and characteristics
        if connectedPeripheral?.identifier == peripheral.identifier {
            connectedPeripheral = nil
            writeCharacteristic = nil
            readCharacteristic = nil
            bleWriteQueue?.cancel()
            bleWriteQueue = nil
            deviceReady = false
        }

        sendConnectionEvent(type: "device_disconnected", error: error?.localizedDescription)

        delegate?.onDeviceDisconnected(device: self)
    }
}
