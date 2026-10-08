import CoreBluetooth
import Foundation

class BleWriteQueue {

    private static let TAG = "BleWriteQueue"

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

    // Backpressure: set when canSendWriteWithoutResponse was false; resumed by notifyReady()
    private var writeContinuation: CheckedContinuation<Bool, Never>?
    private var pendingWriteData: Data?
    private var pendingWriteGeneration: UInt64?
    private var readyTimeoutWorkItem: DispatchWorkItem?
    private var queueGeneration: UInt64 = 0

    init(
        peripheral: CBPeripheral,
        characteristic: CBCharacteristic,
    ) {
        self.gatt = peripheral
        self.characteristic = characteristic

        startProcessingQueue()
    }

    private func logFailure(_ message: String) {
        NativeLogStream.shared.log(
            category: Self.TAG,
            message: "[\(gatt.identifier.uuidString)] \(message)"
        )
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
                let generation = self.queueGeneration

                Task {
                    let success = await self.performWrite(data: request.data, generation: generation)
                    self.queue.async { [weak self] in
                        guard let self = self else {
                            request.completion(false)
                            return
                        }

                        // Ignore completions that belong to a cancelled/restarted queue instance.
                        guard self.queueGeneration == generation else {
                            return
                        }

                        if !success {
                            self.logFailure(
                                "Write failed size=\(request.data.count) peripheralState=\(self.gatt.state.rawValue); clearing queue"
                            )
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
                self.queueGeneration &+= 1
                self.resetPendingWrite(result: false)
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
                    self.logFailure("Write rejected size=\(data.count); queue inactive")
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
                    self.isProcessing = true
                    self.processQueue()
                }
            }
        }
    }

    func cancel() {
        queue.async { [weak self] in
            guard let self = self else { return }
            self.queueGeneration &+= 1
            self.resetPendingWrite(result: false)
            self.currentRequest?.completion(false)
            self.currentRequest = nil
            self.clearQueue()
            self.isActive = false
            self.isProcessing = false
        }
    }

    private func performWrite(data: Data, generation: UInt64) async -> Bool {
        return await withCheckedContinuation { continuation in
            queue.async { [weak self] in
                guard let self = self else {
                    continuation.resume(returning: false)
                    return
                }
                guard self.isActive, self.queueGeneration == generation else {
                    continuation.resume(returning: false)
                    return
                }
                if self.gatt.state == .disconnected {
                    continuation.resume(returning: false)
                    return
                }
                if !self.gatt.canSendWriteWithoutResponse {
                    // Buffer full — suspend until peripheralIsReady(toSendWriteWithoutResponse:) fires
                    self.resetPendingWrite(result: false)
                    self.writeContinuation = continuation
                    self.pendingWriteData = data
                    self.pendingWriteGeneration = generation
                    self.scheduleReadyTimeout(generation: generation)

                } else {
                    self.gatt.writeValue(data, for: self.characteristic, type: .withoutResponse)
                    continuation.resume(returning: true)
                }
            }
        }
    }

    /// Resumes the suspended write that was waiting for buffer space.
    func notifyReady() {
        queue.async { [weak self] in
            guard let self = self else { return }
            guard self.isActive else {
                return
            }
            guard let continuation = self.writeContinuation,
                  let data = self.pendingWriteData,
                  let generation = self.pendingWriteGeneration else {
                return
            }
            guard self.queueGeneration == generation else {
                self.resetPendingWrite(result: false)
                return
            }
            self.readyTimeoutWorkItem?.cancel()
            self.readyTimeoutWorkItem = nil
            self.writeContinuation = nil
            self.pendingWriteData = nil
            self.pendingWriteGeneration = nil
            guard self.gatt.state != .disconnected else {
                continuation.resume(returning: false)
                return
            }
            self.gatt.writeValue(data, for: self.characteristic, type: .withoutResponse)
            continuation.resume(returning: true)
        }
    }

    private func scheduleReadyTimeout(generation: UInt64) {
        readyTimeoutWorkItem?.cancel()

        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            guard self.isActive else { return }
            guard let continuation = self.writeContinuation,
                  let data = self.pendingWriteData,
                  let pendingGeneration = self.pendingWriteGeneration else {
                return
            }
            guard self.queueGeneration == generation, pendingGeneration == generation else {
                self.resetPendingWrite(result: false)
                return
            }
            guard self.gatt.state != .disconnected else {
                self.resetPendingWrite(result: false)
                return
            }

            self.readyTimeoutWorkItem = nil
            self.writeContinuation = nil
            self.pendingWriteData = nil
            self.pendingWriteGeneration = nil
            self.gatt.writeValue(data, for: self.characteristic, type: .withoutResponse)
            continuation.resume(returning: true)
        }

        readyTimeoutWorkItem = workItem
        queue.asyncAfter(
            deadline: .now() + .milliseconds(Self.CONNECTION_BUFFER_WAIT_TIME_MS),
            execute: workItem
        )
    }

    private func resetPendingWrite(result: Bool) {
        readyTimeoutWorkItem?.cancel()
        readyTimeoutWorkItem = nil

        guard let continuation = writeContinuation else {
            pendingWriteData = nil
            pendingWriteGeneration = nil
            return
        }

        writeContinuation = nil
        pendingWriteData = nil
        pendingWriteGeneration = nil
        continuation.resume(returning: result)
    }

    private func clearQueue() {
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
