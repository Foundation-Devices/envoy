package com.foundationdevices.envoy.ble

import android.annotation.SuppressLint
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothGatt
import android.bluetooth.BluetoothGattCallback
import android.bluetooth.BluetoothGattCharacteristic
import android.bluetooth.BluetoothGattDescriptor
import android.bluetooth.BluetoothManager
import android.bluetooth.BluetoothProfile
import android.bluetooth.BluetoothStatusCodes
import android.content.Context
import android.os.Build
import android.util.Log
import io.flutter.plugin.common.BasicMessageChannel
import io.flutter.plugin.common.BinaryCodec
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.io.File
import java.nio.ByteBuffer
import java.util.UUID

/**
 * Callback interface for QLConnection to communicate events back to BluetoothChannel
 */
interface QLConnectionCallback {
    fun onDeviceDisconnected(device: QLConnection)
}

/**
 * Represents a single BLE device connection with all device-specific state and operations.
 * Each device has its own Flutter channels for communication.
 *
 * Channel naming convention:
 * - Method channel: envoy/bluetooth/{deviceId}
 * - Read channel: envoy/ble/read/{deviceId}
 * - Write channel: envoy/ble/write/{deviceId}
 * - Connection stream: envoy/bluetooth/connection/stream/{deviceId}
 * - Write progress stream: envoy/ble/write/progress/{deviceId}
 */
class QLConnection(
    val deviceId: String,
    private val context: Context,
    private val bluetoothManager: BluetoothManager,
    private val binaryMessenger: BinaryMessenger,
    private val callback: QLConnectionCallback,
    private val scope: CoroutineScope = CoroutineScope(Dispatchers.Main)
) : MethodChannel.MethodCallHandler {

    companion object {
        private const val TAG = "QLConnection"
        private const val METHOD_CHANNEL_NAME = "envoy/bluetooth"
        private const val BLE_READ_CHANNEL_NAME = "envoy/ble/read"
        private const val BLE_WRITE_CHANNEL_NAME = "envoy/ble/write"
        private const val BLE_CONNECTION_STREAM_NAME = "envoy/bluetooth/connection/stream"
        private const val BLE_WRITE_PROGRESS_STREAM_NAME = "envoy/ble/write/progress"
        private const val BLUETOOTH_DISCOVERY_DELAY_MS = 500L
        private const val BLE_PACKET_SIZE = 244
        private val PRIME_SERVICE_UUID = UUID.fromString("6E400001-B5A3-F393-E0A9-E50E24DCCA9E")
        private val CCCD_UUID = UUID.fromString("00002902-0000-1000-8000-00805f9b34fb")
        private const val MAX_WRITE_RETRIES = 2
        private const val RETRY_DELAY_MS = 100L
    }

    // Device-specific channels
    private val methodChannel: MethodChannel = MethodChannel(
        binaryMessenger,
        "$METHOD_CHANNEL_NAME/$deviceId"
    )
    private val bleReadChannel: BasicMessageChannel<ByteBuffer> = BasicMessageChannel(
        binaryMessenger,
        "$BLE_READ_CHANNEL_NAME/$deviceId",
        BinaryCodec.INSTANCE
    )
    private val bleWriteChannel: BasicMessageChannel<ByteBuffer> = BasicMessageChannel(
        binaryMessenger,
        "$BLE_WRITE_CHANNEL_NAME/$deviceId",
        BinaryCodec.INSTANCE
    )
    private val connectionEventChannel: EventChannel = EventChannel(
        binaryMessenger,
        "$BLE_CONNECTION_STREAM_NAME/$deviceId"
    )

    private val writeProgressEventChannel: EventChannel = EventChannel(
        binaryMessenger,
        "$BLE_WRITE_PROGRESS_STREAM_NAME/$deviceId"
    )

    // Event sinks
    private var connectionEventSink: EventChannel.EventSink? = null
    private var writeProgressEventSink: EventChannel.EventSink? = null

    // Device state
    private var bluetoothGatt: BluetoothGatt? = null
    private var connectedDevice: BluetoothDevice? = null
    private var writeCharacteristic: BluetoothGattCharacteristic? = null
    private var readCharacteristic: BluetoothGattCharacteristic? = null

    // Write operation state
    private var bleWriteQueue: BleWriteQueue? = null
    private var pendingWriteData: ByteArray? = null
    private var writeRetryCount: Int = 0
    private var currentMtu: Int = 247

    // Transfer state
    private var transferJob: Job? = null

    // Buffer pool for efficient ByteBuffer reuse
    private val bufferPool = kotlin.collections.ArrayDeque<ByteBuffer>()

    /**
     * The MAC address of the connected device
     */
    val peripheralId: String
        get() = deviceId

    /**
     * The name of the connected device
     */
    val peripheralName: String?
        @SuppressLint("MissingPermission")
        get() = connectedDevice?.name

    /**
     * The bond state of the connected device
     */
    val isBonded: Boolean
        @SuppressLint("MissingPermission")
        get() = connectedDevice?.bondState == BluetoothDevice.BOND_BONDED

    init {
        Log.d(TAG, "[$deviceId] QLConnection init - registering channels...")
        Log.d(TAG, "[$deviceId] Method channel: $METHOD_CHANNEL_NAME/$deviceId")
        Log.d(TAG, "[$deviceId] Connection stream: $BLE_CONNECTION_STREAM_NAME/$deviceId")

        methodChannel.setMethodCallHandler(this)
        Log.d(TAG, "[$deviceId] MethodChannel handler set")

        connectionEventChannel.setStreamHandler(ConnectionStreamHandler())
        Log.d(TAG, "[$deviceId] ConnectionEventChannel StreamHandler set")

        writeProgressEventChannel.setStreamHandler(WriteProgressStreamHandler())

        bleWriteChannel.setMessageHandler { message, reply ->
            scope.launch(Dispatchers.IO) {
                val response = handleBinaryWrite(message)
                withContext(Dispatchers.Main) {
                    reply.reply(response)
                }
            }
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        Log.i(TAG, "onMethodCall: call received ma ${call.method}")
        when (call.method) {
            "bond" -> bond(result)
            "getCurrentDeviceStatus" -> getCurrentDeviceStatus(result)
            "transmitFromFile" -> transmitFromFile(call, result)
            "disconnect" -> disconnect(result)
            "getConnectedPeripheralId" -> result.success(peripheralId)
            "isConnected" -> result.success(isConnected())
            "cancelTransfer" -> cancelTransfer(result)
            "reconnect" -> reconnect(result)
            else -> result.notImplemented()
        }
    }

    /**
     * Check if the device is currently connected
     */
    @SuppressLint("MissingPermission")
    fun isConnected(): Boolean {
        val device = connectedDevice ?: return false

        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            bluetoothManager.getConnectionState(
                device,
                BluetoothProfile.GATT
            ) == BluetoothProfile.STATE_CONNECTED
        } else {
            @Suppress("DEPRECATION")
            bluetoothGatt?.getConnectionState(device) == BluetoothProfile.STATE_CONNECTED
        }
    }

    /**
     * Connect to a Bluetooth device
     */
    @SuppressLint("MissingPermission")
    fun connect(device: BluetoothDevice) {
        // Close existing connection if any
        bluetoothGatt?.let { existingGatt ->
            Log.d(TAG, "[$deviceId] Closing existing GATT connection")
            existingGatt.disconnect()
            existingGatt.close()
        }

        bluetoothGatt?.close()
        bluetoothGatt = null

        Log.d(TAG, "[$deviceId] Connecting to: ${device.name ?: "Unknown"} (${device.address})")

        sendConnectionEvent(BluetoothConnectionEventType.CONNECTION_ATTEMPT)

        try {
            bluetoothGatt = device.connectGatt(
                context,
                true,
                gattCallback,
                BluetoothDevice.TRANSPORT_LE
            )
            Log.d(TAG, "[$deviceId] connectGatt called")

            if (bluetoothGatt == null) {
                sendConnectionEvent(
                    BluetoothConnectionEventType.CONNECTION_ERROR,
                    "Failed to create GATT connection"
                )
            }
        } catch (e: SecurityException) {
            Log.e(TAG, "[$deviceId] Security exception during connection: ${e.message}")
            sendConnectionEvent(
                BluetoothConnectionEventType.CONNECTION_ERROR,
                "Permission denied: ${e.message}"
            )
        } catch (e: Exception) {
            Log.e(TAG, "[$deviceId] Unexpected error during connection: ${e.message}")
            sendConnectionEvent(
                BluetoothConnectionEventType.CONNECTION_ERROR,
                "Connection failed: ${e.message}"
            )
        }
    }

    /**
     * Disconnect from the device
     */
    @SuppressLint("MissingPermission")
    private fun disconnect(result: MethodChannel.Result) {
        try {
            bluetoothGatt?.disconnect()
            Log.d(TAG, "[$deviceId] Disconnecting from device")
            result.success(mapOf("disconnecting" to true))
        } catch (e: Exception) {
            Log.w(TAG, "[$deviceId] Error disconnecting: ${e.message}")
            result.error("DISCONNECT_ERROR", "Failed to disconnect: ${e.message}", null)
        }
    }

    /**
     * Initiate bonding with the connected device
     */
    @SuppressLint("MissingPermission")
    private fun bond(result: MethodChannel.Result) {
        val device = connectedDevice
        if (device == null) {
            result.error("NO_DEVICE", "No device connected", null)
            return
        }

        when (device.bondState) {
            BluetoothDevice.BOND_NONE -> {
                Log.d(TAG, "[$deviceId] Starting bonding...")
                val bondResult = device.createBond()
                if (!bondResult) {
                    Log.e(TAG, "[$deviceId] Failed to start bonding")
                    sendConnectionEvent(
                        BluetoothConnectionEventType.CONNECTION_ERROR,
                        "Failed to start bonding"
                    )
                }
                result.success(bondResult)
            }
            BluetoothDevice.BOND_BONDED -> {
                Log.d(TAG, "[$deviceId] Device already bonded")
                result.success(true)
            }
            BluetoothDevice.BOND_BONDING -> {
                Log.d(TAG, "[$deviceId] Bonding in progress...")
                result.success(true)
            }
            else -> result.success(false)
        }
    }

    @SuppressLint("MissingPermission")
    private fun getCurrentDeviceStatus(result: MethodChannel.Result) {
        result.success(
            BluetoothConnectionStatus(
                type = null,
                connected = isConnected(),
                peripheralId = deviceId,
                peripheralName = connectedDevice?.name ?: "Unknown Device",
                bonded = connectedDevice?.bondState == BluetoothDevice.BOND_BONDED,
                rssi = null,
                error = null
            ).toMap()
        )
    }

    /**
     * Transmit data from a file over BLE
     */
    @SuppressLint("MissingPermission")
    private fun transmitFromFile(call: MethodCall, result: MethodChannel.Result) {
        val path = call.argument<String?>("path")

        if (transferJob?.isActive == true) {
            Log.i(TAG, "[$deviceId] transmitFromFile: Transfer already in progress")
            result.error("TRANSFER_IN_PROGRESS", "Another transfer is already in progress", null)
            return
        }

        if (path.isNullOrEmpty()) {
            result.error("INVALID_PATH", "File path is null or empty", null)
            return
        }

        val file = File(path)
        if (!file.exists()) {
            result.error("FILE_NOT_FOUND", "File does not exist: $path", null)
            return
        }

        val safeResult = SafeResult(result)
        val priority = BluetoothGatt.CONNECTION_PRIORITY_HIGH
        val priorityResult = bluetoothGatt?.requestConnectionPriority(priority)
        Log.d(TAG, "[$deviceId] Requested high connection priority: ${if (priorityResult == true) "✓" else "✗"}")

        transferJob = scope.launch(Dispatchers.IO) {
            try {
                val fileSize = file.length()
                var bytesProcessed = 0L
                var writeError = false

                file.inputStream().use { stream ->
                    stream.forEachChunk(BLE_PACKET_SIZE) { chunk ->
                        val success = bleWriteQueue?.enqueue(chunk) ?: false
                        if (!success) {
                            Log.e(TAG, "[$deviceId] Failed to enqueue data at byte $bytesProcessed")
                            writeError = true
                            withContext(Dispatchers.Main) {
                                safeResult.error(
                                    "WRITE_ERROR",
                                    "Failed to write data at byte $bytesProcessed",
                                    null
                                )
                            }
                            return@forEachChunk
                        }
                        bytesProcessed += chunk.size
                        val progress = bytesProcessed.toFloat() / fileSize.toFloat()
                        sendWriteProgress(progress, path, bytesProcessed, fileSize)
                    }
                }
                file.delete()

                sendWriteProgress(1.0f, path, fileSize, fileSize)
                withContext(Dispatchers.Main) {
                    safeResult.success(
                        mapOf(
                            "success" to true,
                            "message" to "Large data processed successfully"
                        )
                    )
                }
            } catch (e: Exception) {
                if (e is CancellationException) {
                    Log.w(TAG, "[$deviceId] Transmission cancelled: ${e.message}")
                    withContext(Dispatchers.Main) {
                        safeResult.error("TRANSFER_CANCELLED", "Data transmission cancelled", null)
                    }
                    return@launch
                }
                withContext(Dispatchers.Main) {
                    safeResult.error("FILE_READ_ERROR", "Failed to read file: ${e.message}", null)
                }
            }
        }

        transferJob?.invokeOnCompletion {
            val balancedPriority = BluetoothGatt.CONNECTION_PRIORITY_BALANCED
            val r = bluetoothGatt?.requestConnectionPriority(balancedPriority)
            Log.d(TAG, "[$deviceId] Requested balanced connection priority: ${if (r == true) "✓" else "✗"}")
        }
    }

    /**
     * Cancel an ongoing file transfer
     */
    private fun cancelTransfer(result: MethodChannel.Result) {
        if (transferJob?.isActive == true) {
            transferJob?.cancel()
            bleWriteQueue?.clearQueue()
            result.success(true)
        } else {
            result.success(false)
        }
    }

    /**
     * Reconnect to a previously bonded device.
     * This is called when restoring a connection after app restart.
     */
    @SuppressLint("MissingPermission")
    private fun reconnect(result: MethodChannel.Result) {
        try {
            val adapter = bluetoothManager.adapter
            if (adapter == null) {
                result.error("NO_ADAPTER", "Bluetooth adapter not available", null)
                return
            }

            val device = adapter.getRemoteDevice(deviceId)
            if (device == null) {
                result.error("DEVICE_NOT_FOUND", "Device not found: $deviceId", null)
                return
            }

            Log.d(TAG, "[$deviceId] Reconnecting to bonded device: ${device.name ?: "Unknown"}")
            connect(device)
            result.success(true)
        } catch (e: Exception) {
            Log.e(TAG, "[$deviceId] Error reconnecting: ${e.message}")
            result.error("RECONNECT_ERROR", "Failed to reconnect: ${e.message}", null)
        }
    }

    @SuppressLint("MissingPermission")
    private suspend fun handleBinaryWrite(message: ByteBuffer?): ByteBuffer {
        val failureBuffer = createDirectByteBuffer(0)

        if (transferJob?.isActive == true) {
            Log.e(TAG, "[$deviceId] Another write operation is in progress")
            return failureBuffer
        }

        if (message == null) {
            Log.e(TAG, "[$deviceId] Message is null")
            return failureBuffer
        }

        val data = ByteArray(message.remaining())
        message.get(data)

        if (bluetoothGatt == null) {
            Log.e(TAG, "[$deviceId] No active Bluetooth connection")
            return failureBuffer
        }

        if (writeCharacteristic == null) {
            Log.e(TAG, "[$deviceId] No write characteristic available")
            return failureBuffer
        }

        if (bleWriteQueue == null) {
            Log.e(TAG, "[$deviceId] BLE Write Queue is not initialized")
            return failureBuffer
        }

        if (data.size < 8) {
            return failureBuffer
        }

        return if (data.size > BLE_PACKET_SIZE) {
            var success = true
            data.chunked(BLE_PACKET_SIZE).forEach { chunk ->
                val result = bleWriteQueue?.enqueue(chunk) ?: false
                if (!result) {
                    Log.e(TAG, "[$deviceId] Failed to enqueue chunk of size ${chunk.size}")
                    success = false
                    return@forEach
                }
            }
            if (success) createDirectByteBuffer(1) else failureBuffer
        } else {
            val success = bleWriteQueue?.enqueue(data) ?: false
            if (success) createDirectByteBuffer(1) else failureBuffer
        }
    }

    /**
     * Called by BluetoothChannel when bonding state changes for this device
     */
    @SuppressLint("MissingPermission")
    fun onBondingStateChanged(bondState: Int) {
        sendConnectionEvent(
            when (bondState) {
                BluetoothDevice.BOND_BONDED -> BluetoothConnectionEventType.DEVICE_CONNECTED
                BluetoothDevice.BOND_NONE -> BluetoothConnectionEventType.DEVICE_DISCONNECTED
                BluetoothDevice.BOND_BONDING -> BluetoothConnectionEventType.CONNECTION_ATTEMPT
                else -> BluetoothConnectionEventType.DEVICE_DISCONNECTED
            }
        )
    }

    @SuppressLint("MissingPermission")
    private fun sendConnectionEvent(type: BluetoothConnectionEventType, error: String? = null) {
        scope.launch {
            Log.i(TAG, "sendConnectionEvent: ${if(connectionEventSink==null) "no sink" else "has sink"}")
            connectionEventSink?.success(
                BluetoothConnectionStatus(
                    type,
                    connected = isConnected(),
                    peripheralId = deviceId,
                    peripheralName = connectedDevice?.name ?: "Unknown Device",
                    bonded = connectedDevice?.bondState == BluetoothDevice.BOND_BONDED,
                    rssi = null,
                    error = error
                ).toMap()
            )
        }
    }

    private fun sendWriteProgress(
        progress: Float,
        id: String,
        bytesProcessed: Long = 0,
        totalBytes: Long = 0
    ) {
        scope.launch {
            writeProgressEventSink?.success(
                mapOf<String, Any>(
                    "progress" to progress,
                    "id" to id,
                    "bytes_processed" to bytesProcessed,
                    "total_bytes" to totalBytes
                )
            )
        }
    }

    private fun sendBinaryData(data: ByteArray) {
        scope.launch {
            try {
                val directBuffer = getPooledBuffer(data.size)
                directBuffer.put(data)
                bleReadChannel.send(directBuffer) { _ -> }
            } catch (e: Exception) {
                Log.e(TAG, "[$deviceId] Error sending binary data: ${e.message}")
            }
        }
    }

    private fun createDirectByteBuffer(value: Byte): ByteBuffer {
        return ByteBuffer.allocateDirect(1).put(value)
    }

    private fun getPooledBuffer(size: Int): ByteBuffer {
        val buf = bufferPool.removeFirstOrNull()
        if (buf == null || buf.capacity() < size) {
            return ByteBuffer.allocateDirect(size)
        }
        buf.clear()
        return buf
    }

    /**
     * Clean up resources and unregister channels
     */
    @SuppressLint("MissingPermission")
    fun cleanup() {
        try {
            transferJob?.cancel()
            bleWriteQueue?.cancel()
            bluetoothGatt?.close()
        } catch (e: SecurityException) {
            Log.w(TAG, "[$deviceId] Permission denied during cleanup: ${e.message}")
        } catch (e: Exception) {
            Log.w(TAG, "[$deviceId] Error during cleanup: ${e.message}")
        }

        // Clear channel handlers
        methodChannel.setMethodCallHandler(null)
        bleWriteChannel.setMessageHandler(null)

        bluetoothGatt = null
        connectedDevice = null
        writeCharacteristic = null
        readCharacteristic = null
        bleWriteQueue = null
        connectionEventSink = null
        writeProgressEventSink = null

        Log.d(TAG, "[$deviceId] QLConnection cleaned up")
    }

    private inner class ConnectionStreamHandler : EventChannel.StreamHandler {
        @SuppressLint("MissingPermission")
        override fun onListen(arguments: Any?, sink: EventChannel.EventSink?) {
            connectionEventSink = sink
            // Send current status when listener attaches
            connectedDevice?.let {
                sendConnectionEvent(
                    if (isConnected()) BluetoothConnectionEventType.DEVICE_CONNECTED
                    else BluetoothConnectionEventType.DEVICE_DISCONNECTED
                )
            }
        }

        override fun onCancel(arguments: Any?) {
            connectionEventSink = null
        }
    }

    private inner class WriteProgressStreamHandler : EventChannel.StreamHandler {
        override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
            writeProgressEventSink = events
        }

        override fun onCancel(arguments: Any?) {
            writeProgressEventSink = null
        }
    }

    private val gattCallback = object : BluetoothGattCallback() {

        override fun onMtuChanged(gatt: BluetoothGatt?, mtu: Int, status: Int) {
            super.onMtuChanged(gatt, mtu, status)
            Log.d(TAG, "[$deviceId] ════════════════════════════════════════")
            Log.d(TAG, "[$deviceId] MTU CHANGED: $mtu bytes (was $currentMtu)")
            if (status == BluetoothGatt.GATT_SUCCESS) {
                Log.d(TAG, "[$deviceId] ✓ MTU negotiation successful, max data: ${mtu - 3} bytes")
            } else {
                Log.e(TAG, "[$deviceId] ✗ MTU negotiation failed")
            }
            Log.d(TAG, "[$deviceId] ════════════════════════════════════════")
            currentMtu = mtu
        }

        @SuppressLint("MissingPermission")
        override fun onConnectionStateChange(gatt: BluetoothGatt?, status: Int, newState: Int) {
            when (newState) {
                BluetoothProfile.STATE_CONNECTED -> {
                    Log.d(TAG, "[$deviceId] ✓ CONNECTED TO GATT SERVER")
                    connectedDevice = gatt?.device
                    bleWriteQueue?.restart()

                    if (connectedDevice?.bondState == BluetoothDevice.BOND_BONDED) {
                        sendConnectionEvent(BluetoothConnectionEventType.DEVICE_CONNECTED)
                    }

                    bluetoothGatt?.requestMtu(247)?.let { success ->
                        if (success) Log.i(TAG, "[$deviceId] MTU request sent: 247")
                    }

                    bluetoothGatt?.apply {
                        requestConnectionPriority(BluetoothGatt.CONNECTION_PRIORITY_BALANCED)
                        setPreferredPhy(
                            BluetoothDevice.PHY_LE_2M,
                            BluetoothDevice.PHY_LE_2M,
                            BluetoothDevice.PHY_LE_2M
                        )
                        Log.i(TAG, "[$deviceId] setPreferredPhy 2M")
                    }

                    scope.launch {
                        delay(BLUETOOTH_DISCOVERY_DELAY_MS)
                        gatt?.discoverServices()
                    }

                    if (connectedDevice != null) {
                        sendConnectionEvent(BluetoothConnectionEventType.DEVICE_CONNECTED)
                    }
                }

                BluetoothProfile.STATE_DISCONNECTED -> {
                    Log.d(TAG, "[$deviceId] Disconnected from GATT server")
                    sendConnectionEvent(BluetoothConnectionEventType.DEVICE_DISCONNECTED)
                    bleWriteQueue?.cancel()
                    connectedDevice = null
                    writeCharacteristic = null
                    readCharacteristic = null
                    callback.onDeviceDisconnected(this@QLConnection)
                }
            }
        }

        @SuppressLint("MissingPermission")
        override fun onServicesDiscovered(gatt: BluetoothGatt?, status: Int) {
            if (status == BluetoothGatt.GATT_SUCCESS) {
                Log.d(TAG, "[$deviceId] Services discovered successfully")

                val service = gatt?.getService(PRIME_SERVICE_UUID)
                if (service != null) {
                    Log.d(TAG, "[$deviceId] Found Prime service: ${service.uuid}")

                    service.characteristics.forEach { characteristic ->
                        val properties = characteristic.properties
                        val propertiesString = getPropertiesString(properties)

                        Log.d(TAG, "[$deviceId] Found characteristic: ${characteristic.uuid} ($propertiesString)")

                        when {
                            properties and BluetoothGattCharacteristic.PROPERTY_WRITE != 0 ||
                                    properties and BluetoothGattCharacteristic.PROPERTY_WRITE_NO_RESPONSE != 0 -> {
                                bleWriteQueue = BleWriteQueue(
                                    gatt, characteristic,
                                    CoroutineScope(Dispatchers.IO)
                                )
                                writeCharacteristic = characteristic
                            }

                            properties and BluetoothGattCharacteristic.PROPERTY_READ != 0 ||
                                    properties and BluetoothGattCharacteristic.PROPERTY_NOTIFY != 0 -> {
                                readCharacteristic = characteristic

                                if (properties and BluetoothGattCharacteristic.PROPERTY_NOTIFY != 0) {
                                    gatt.setCharacteristicNotification(characteristic, true)
                                    val descriptor = characteristic.getDescriptor(CCCD_UUID)
                                    if (descriptor != null) {
                                        val enableNotificationValue = BluetoothGattDescriptor.ENABLE_NOTIFICATION_VALUE
                                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                                            gatt.writeDescriptor(descriptor, enableNotificationValue)
                                        } else {
                                            @Suppress("DEPRECATION")
                                            descriptor.value = enableNotificationValue
                                            @Suppress("DEPRECATION")
                                            gatt.writeDescriptor(descriptor)
                                        }
                                    } else {
                                        Log.e(TAG, "[$deviceId] CCCD descriptor not found!")
                                        characteristic.descriptors.forEach { desc ->
                                            Log.e(TAG, "[$deviceId]    - ${desc.uuid}")
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Log.d(TAG, "[$deviceId] Characteristics: write=${writeCharacteristic?.uuid}, read=${readCharacteristic?.uuid}")
                } else {
                    Log.w(TAG, "[$deviceId] Prime service not found")
                }
            } else {
                Log.e(TAG, "[$deviceId] Service discovery failed with status: $status")
            }
        }

        @SuppressLint("MissingPermission")
        override fun onCharacteristicWrite(
            gatt: BluetoothGatt?,
            characteristic: BluetoothGattCharacteristic?,
            status: Int
        ) {
            if (characteristic?.uuid == writeCharacteristic?.uuid) {
                bleWriteQueue?.onCharacteristicWrite(status)
            }

            if (status == BluetoothGatt.GATT_SUCCESS) {
                if (writeRetryCount > 0) {
                    Log.d(TAG, "[$deviceId] Success after $writeRetryCount retries")
                }
                pendingWriteData = null
                writeRetryCount = 0
            } else {
                Log.e(TAG, "[$deviceId] WRITE ERROR: char=${characteristic?.uuid}, status=$status, retry=$writeRetryCount/$MAX_WRITE_RETRIES")

                if (writeRetryCount < MAX_WRITE_RETRIES && pendingWriteData != null && characteristic != null && gatt != null) {
                    writeRetryCount++
                    Log.d(TAG, "[$deviceId] Retrying write (attempt $writeRetryCount/$MAX_WRITE_RETRIES)")
                    scope.launch {
                        delay(RETRY_DELAY_MS)
                        val writeSuccess = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                            pendingWriteData?.let { data ->
                                val success = gatt.writeCharacteristic(characteristic, data, characteristic.writeType)
                                if (success != BluetoothStatusCodes.SUCCESS) {
                                    Log.e(TAG, "[$deviceId] writeCharacteristic error: $success")
                                }
                                success == BluetoothStatusCodes.SUCCESS
                            } ?: false
                        } else {
                            @Suppress("DEPRECATION")
                            characteristic.value = pendingWriteData
                            @Suppress("DEPRECATION")
                            gatt.writeCharacteristic(characteristic)
                        }
                        if (!writeSuccess) {
                            Log.e(TAG, "[$deviceId] Failed to write characteristic on retry")
                        }
                    }
                    return
                }

                Log.e(TAG, "[$deviceId] Write failed after $MAX_WRITE_RETRIES retries")
                pendingWriteData = null
                writeRetryCount = 0
            }
        }

        @Deprecated("Deprecated in Java")
        override fun onCharacteristicRead(
            gatt: BluetoothGatt?,
            characteristic: BluetoothGattCharacteristic?,
            status: Int
        ) {
            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) {
                @Suppress("DEPRECATION")
                if (status == BluetoothGatt.GATT_SUCCESS) {
                    characteristic?.value?.let { data ->
                        Log.d(TAG, "[$deviceId] BLE READ: ${data.size} bytes")
                        sendBinaryData(data)
                    }
                } else {
                    Log.e(TAG, "[$deviceId] Read failed with status: $status")
                }
            }
        }

        override fun onCharacteristicRead(
            gatt: BluetoothGatt,
            characteristic: BluetoothGattCharacteristic,
            value: ByteArray,
            status: Int
        ) {
            super.onCharacteristicRead(gatt, characteristic, value, status)
            if (value.isNotEmpty()) {
                sendBinaryData(value)
            }
        }

        override fun onCharacteristicChanged(
            gatt: BluetoothGatt,
            characteristic: BluetoothGattCharacteristic,
            value: ByteArray
        ) {
            super.onCharacteristicChanged(gatt, characteristic, value)
            if (value.isEmpty()) {
                Log.w(TAG, "[$deviceId] Notification received but data is empty")
                return
            }
            sendBinaryData(value)
        }

        @Suppress("DEPRECATION")
        override fun onCharacteristicChanged(
            gatt: BluetoothGatt?,
            characteristic: BluetoothGattCharacteristic?
        ) {
            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) {
                @Suppress("DEPRECATION")
                characteristic?.value?.let { data ->
                    sendBinaryData(data)
                } ?: Log.w(TAG, "[$deviceId] Notification received but data is null")
            }
        }

        override fun onDescriptorWrite(
            gatt: BluetoothGatt?,
            descriptor: BluetoothGattDescriptor?,
            status: Int
        ) {
            if (descriptor?.uuid == CCCD_UUID) {
                if (status == BluetoothGatt.GATT_SUCCESS) {
                    Log.d(TAG, "[$deviceId] CCCD write successful - Notifications enabled")
                } else {
                    Log.e(TAG, "[$deviceId] CCCD write failed with status: $status")
                }
            }
        }
    }

    private fun getPropertiesString(properties: Int): String {
        val props = mutableListOf<String>()
        if (properties and BluetoothGattCharacteristic.PROPERTY_READ != 0) props.add("READ")
        if (properties and BluetoothGattCharacteristic.PROPERTY_WRITE != 0) props.add("WRITE")
        if (properties and BluetoothGattCharacteristic.PROPERTY_WRITE_NO_RESPONSE != 0) props.add("WRITE_NO_RESPONSE")
        if (properties and BluetoothGattCharacteristic.PROPERTY_NOTIFY != 0) props.add("NOTIFY")
        if (properties and BluetoothGattCharacteristic.PROPERTY_INDICATE != 0) props.add("INDICATE")
        return if (props.isEmpty()) "NONE" else props.joinToString(" | ")
    }
}
