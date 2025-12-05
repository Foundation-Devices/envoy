import AccessorySetupKit
import CoreBluetooth
import Flutter
import Foundation
import UIKit

class BleWriteQueue {
    private let gatt: CBPeripheral
    private let characteristic: CBCharacteristic
    private let queue = DispatchQueue(label: "com.envoy.ble.writequeue", qos: .userInteractive)

    private var writeQueue: [WriteRequest] = []
    private var currentRequest: WriteRequest?
    private var isActive = true
    private var isProcessing = false
    private var writeType: CBCharacteristicWriteType = .withResponse

    // Continuation for async/await pattern (like CompletableDeferred in Kotlin)
    private var writeContinuation: CheckedContinuation<Bool, Never>?

    init(peripheral: CBPeripheral, characteristic: CBCharacteristic) {
        self.gatt = peripheral
        self.characteristic = characteristic

        // Determine write type based on characteristic properties
        self.writeType =
            characteristic.properties.contains(.writeWithoutResponse)
            ? .withoutResponse : .withResponse

        // Start processing queue
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

                    if !success {
                        print("BleWriteQueue: Write failed, clearing queue")
                        self.isActive = false
                        request.completion(false)
                        self.clearQueue()
                        self.isProcessing = false
                        return
                    }

                    request.completion(true)
                    self.currentRequest = nil
                }
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
                    print("BleWriteQueue: Queue inactive, rejecting write")
                    continuation.resume(returning: false)
                    return
                }

                let request = WriteRequest(id: data.hashValue, data: data) { success in
                    continuation.resume(returning: success)
                }

                self.writeQueue.append(request)

                if !self.isProcessing {
                    self.processQueue()
                }
            }
        }
    }

    func onCharacteristicWrite(error: Error?) {
        queue.async { [weak self] in
            guard let self = self else { return }

            let success = error == nil
            
            self.writeContinuation?.resume(returning: success)
            self.writeContinuation = nil
        }
    }

    // Called when peripheral is ready for next write
    func onPeripheralReady() {
        queue.async { [weak self] in
            guard let self = self else { return }
            self.writeContinuation?.resume(returning: true)
            self.writeContinuation = nil
        }
    }

    func cancel() {
        queue.async { [weak self] in
            guard let self = self else { return }

            self.writeContinuation?.resume(returning: false)
            self.writeContinuation = nil

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

                if !self.isActive {
                    print("BleWriteQueue: Queue inactive during performWrite")
                    continuation.resume(returning: false)
                    return
                }

                self.writeContinuation = continuation

                self.gatt.writeValue(data, for: self.characteristic, type: self.writeType)
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

    private class WriteRequest {
        let id: Int
        let data: Data
        let completion: (Bool) -> Void

        init(id: Int, data: Data, completion: @escaping (Bool) -> Void) {
            self.id = id
            self.data = data
            self.completion = completion
        }
    }
}
