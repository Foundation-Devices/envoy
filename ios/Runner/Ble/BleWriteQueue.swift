import CoreBluetooth
import Foundation

class BleWriteQueue {

    /**
     
        The minimum amount of time we expect needs to elapse before the Write Without Response buffer is cleared in miliseconds.
    
        The minimum connection interval time is 15 ms, as noted in this technical document: `https://developer.apple.com/library/archive/qa/qa1931/_index.html`. Therefore, it is reasonable to assume that past this interval, the BLE Radio will be powered up by the CoreBluetooth API / Subsystem to send the write values we've enqueued onto the CBPeripheral.
            based on https://github.com/NordicSemiconductor/IOS-nRF-Connect-Device-Manager/blob/e46fd30eda5397db0e58287f9236b9bfe8ef54f7/iOSMcuManagerLibrary/Source/Bluetooth/McuMgrBleROBWriteBuffer.swift#L29
        */
    static let CONNECTION_BUFFER_WAIT_TIME_MS = 15

    private let gatt: CBPeripheral
    private let characteristic: CBCharacteristic
    private let queue = DispatchQueue(label: "com.envoy.ble.writequeue", qos: .userInteractive)

    private var writeQueue: [WriteRequest] = []
    private var currentRequest: WriteRequest?
    private var isActive = true
    private var isProcessing = false

    init(peripheral: CBPeripheral, characteristic: CBCharacteristic) {
        self.gatt = peripheral
        self.characteristic = characteristic

        startProcessingQueue()
    }

    private func startProcessingQueue() {
        queue.async { [weak self] in
            guard let self = self else { return }
            self.processQueue()
        }
    }

    private func processQueue() {
        queue.async { [weak self] in
            guard let self = self else { return }

            while self.isActive {
                guard !self.writeQueue.isEmpty else {
                    self.isProcessing = false
                    return
                }

                self.isProcessing = true
                let request = self.writeQueue.removeFirst()
                self.currentRequest = request

                Task {
                    let success = await self.performWrite(data: request.data)
                    self.queue.async { [weak self] in
                        guard let self = self else {
                            request.completion(false)
                            return
                        }
                        
                        if !success {
                            print("ERROR - BleWriteQueue: Write failed, clearing queue")
                            self.isActive = false
                            request.completion(false)
                            self.clearQueue()
                            self.isProcessing = false
                            return
                        }
                        request.completion(true)
                        self.currentRequest = nil
                        
                        // Continue processing if there are more items
                        if !self.writeQueue.isEmpty {
                            self.processQueue()
                        } else {
                            self.isProcessing = false
                        }
                    }
                }
                
                return
            }
        }
    }

    func restart() {
        queue.async { [weak self] in
            guard let self = self else { return }
            if !self.isActive {
                print("BleWriteQueue: Restarting write queue")
                self.isActive = true
                self.currentRequest = nil
                self.clearQueue()
                self.startProcessingQueue()
            }
        }
    }

    func enqueue(data: Data) async -> Bool {
        return await withCheckedContinuation { continuation in
            queue.async { [weak self] in
                guard let self = self else {
                    continuation.resume(returning: false)
                    return
                }

                if !self.isActive {
                    print("WARNING - BleWriteQueue: Queue inactive, rejecting write")
                    continuation.resume(returning: false)
                    return
                }

                var hasResumed = false
                let request = WriteRequest(data: data) { success in
                    if !hasResumed {
                        hasResumed = true
                        continuation.resume(returning: success)
                    }
                }

                self.writeQueue.append(request)

                if !self.isProcessing {
                    self.processQueue()
                }
            }
        }
    }

    func cancel() {
        queue.async { [weak self] in
            guard let self = self else { return }
            self.currentRequest?.completion(false)
            self.currentRequest = nil
            self.clearQueue()
            self.isActive = false
            self.isProcessing = false
            print("BleWriteQueue: Write queue cancelled")
        }
    }

    private func performWrite(data: Data) async -> Bool {
        return await withCheckedContinuation { continuation in
            queue.async { [weak self] in
                guard let self = self else {
                    continuation.resume(returning: false)
                    return
                }
                if( self.gatt.state == .disconnected ){
                    print("Device disconnected, cannot write")
                    continuation.resume(returning: false)
                    return
                }
                if !gatt.canSendWriteWithoutResponse {
                    queue.asyncAfter(
                        deadline: .now() + .milliseconds(Self.CONNECTION_BUFFER_WAIT_TIME_MS)
                    ) { [weak self] in
                        guard let self else {
                            continuation.resume(returning: false)
                            return
                        }
                        self.gatt.writeValue(data, for: self.characteristic, type: .withoutResponse)
                        continuation.resume(returning: true)
                    }
                } else {
                    gatt.writeValue(data, for: characteristic, type: .withoutResponse)
                    continuation.resume(returning: true)
                }
            }
        }
    }

    private func clearQueue() {
        print("BleWriteQueue: Clearing write queue (\(writeQueue.count) items)")
        for request in writeQueue {
            request.completion(false)
        }
        writeQueue.removeAll()
    }

    private final class WriteRequest: @unchecked Sendable {
        let data: Data
        let completion: (Bool) -> Void

        init( data: Data, completion: @escaping (Bool) -> Void) {
            self.data = data
            self.completion = completion
        }
    }
}
