@file:OptIn(ExperimentalAtomicApi::class)

package com.foundationdevices.envoy.ble

import android.Manifest
import android.annotation.SuppressLint
import android.app.Activity
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothGatt
import android.bluetooth.BluetoothGattCallback
import android.bluetooth.BluetoothGattCharacteristic
import android.bluetooth.BluetoothGattDescriptor
import android.bluetooth.BluetoothManager
import android.bluetooth.BluetoothProfile
import android.bluetooth.BluetoothStatusCodes
import android.bluetooth.le.BluetoothLeScanner
import android.bluetooth.le.ScanCallback
import android.bluetooth.le.ScanFilter
import android.bluetooth.le.ScanResult
import android.bluetooth.le.ScanSettings
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.ParcelUuid
import android.util.Log
import androidx.activity.ComponentActivity
import androidx.activity.result.contract.ActivityResultContracts.StartActivityForResult
import androidx.core.app.ActivityCompat
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
import java.io.FileInputStream
import java.nio.ByteBuffer
import java.util.UUID
import kotlin.concurrent.atomics.AtomicBoolean
import kotlin.concurrent.atomics.ExperimentalAtomicApi


class BluetoothChannel(
    private val context: Context,
    private val activity: ComponentActivity,
    binaryMessenger: BinaryMessenger
) :
    MethodChannel.MethodCallHandler {

    companion object {
        private const val TAG = "BluetoothChannel"
        private const val METHOD_CHANNEL_NAME = "envoy/bluetooth"
        private const val BLE_READ_CHANNEL_NAME = "envoy/ble/read"
        private const val BLE_WRITE_CHANNEL_NAME = "envoy/ble/write"
        private const val BLE_CONNECTION_STREAM_NAME = "envoy/bluetooth/connection/stream"
        private const val BLE_WRITE_PROGRESS_STREAM_NAME = "envoy/ble/write/progress"
        private const val BLUETOOTH_DISCOVERY_DELAY_MS = 500L

        private const val BLE_PACKET_SIZE = 244 // Max BLE packet size for Envoy Prime

        // Service UUID for Prime device
        private val PRIME_SERVICE_UUID = UUID.fromString("6E400001-B5A3-F393-E0A9-E50E24DCCA9E")

        // Client Characteristic Configuration Descriptor UUID (standard BLE UUID)
        private val CCCD_UUID = UUID.fromString("00002902-0000-1000-8000-00805f9b34fb")

        // Write retry settings
        private const val MAX_WRITE_RETRIES = 2
        private const val RETRY_DELAY_MS = 100L
    }

    private val methodChannel: MethodChannel = MethodChannel(binaryMessenger, METHOD_CHANNEL_NAME)
    private val bleReadChannel: BasicMessageChannel<ByteBuffer> =
        BasicMessageChannel(binaryMessenger, BLE_READ_CHANNEL_NAME, BinaryCodec.INSTANCE)
    private val bleWriteChannel: BasicMessageChannel<ByteBuffer> =
        BasicMessageChannel(binaryMessenger, BLE_WRITE_CHANNEL_NAME, BinaryCodec.INSTANCE)
    private val connectionEventChannel: EventChannel =
        EventChannel(binaryMessenger, BLE_CONNECTION_STREAM_NAME)
    private val writeProgressEventChannel: EventChannel =
        EventChannel(binaryMessenger, BLE_WRITE_PROGRESS_STREAM_NAME)


    private var knownPrimeDevicesMAC: MutableSet<String> = mutableSetOf()


    private val bluetoothManager: BluetoothManager =
        context.getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
    private val bluetoothAdapter: BluetoothAdapter? = bluetoothManager.adapter
    private var bluetoothLeScanner: BluetoothLeScanner? = null
    private var bluetoothGatt: BluetoothGatt? = null
    private var connectedDevice: BluetoothDevice? = null

    private var writeCharacteristic: BluetoothGattCharacteristic? = null
    private var readCharacteristic: BluetoothGattCharacteristic? = null

    private var connectionEventSink: EventChannel.EventSink? = null
    private var writeProgressEventSink: EventChannel.EventSink? = null

    private var pendingWriteData: ByteArray? = null
    private var writeRetryCount: Int = 0

    private val mainHandler = Handler(Looper.getMainLooper())
    private var bleWriteQueue: BleWriteQueue? = null
    private var currentMtu: Int = 247

    private val scope = CoroutineScope(Dispatchers.Main)

    // Job for managing large file data transfers
    private var transferJob: Job? = null

    // BroadcastReceiver for bonding state changes
    private var bondingReceiver: BroadcastReceiver? = null
    private var isReceiverRegistered = false

    // Helper function to create direct ByteBuffers for Flutter
    private fun createDirectByteBuffer(value: Byte): ByteBuffer {
        return ByteBuffer.allocateDirect(1).put(value)
    }

    init {
        methodChannel.setMethodCallHandler(this)
        connectionEventChannel.setStreamHandler(ConnectionStreamHandler())
        writeProgressEventChannel.setStreamHandler(WriteProgressStreamHandler())

        // Set up binary write channel handler
        bleWriteChannel.setMessageHandler { message, reply ->
            scope.launch(Dispatchers.IO) {
                val response = handleBinaryWrite(message)
                withContext(Dispatchers.Main) {
                    reply.reply(response)
                }
            }
        }

        bluetoothLeScanner = bluetoothAdapter?.bluetoothLeScanner

        setupBondingReceiver()
    }

    /**
     * Setup BroadcastReceiver to listen for bonding state changes
     */
    private fun setupBondingReceiver() {
        bondingReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                if (intent?.action == BluetoothDevice.ACTION_BOND_STATE_CHANGED) {
                    handleBondingStateChange(intent)
                }
            }
        }
        val filter = IntentFilter().apply {
            addAction(BluetoothDevice.ACTION_BOND_STATE_CHANGED)
            addAction(BluetoothDevice.ACTION_PAIRING_REQUEST)
        }
        context.registerReceiver(bondingReceiver, filter)
        isReceiverRegistered = true
    }


    /**
     * Unregister the bonding broadcast receiver
     */
    private fun unregisterBondingReceiver() {
        if (isReceiverRegistered && bondingReceiver != null) {
            try {
                context.unregisterReceiver(bondingReceiver)
                isReceiverRegistered = false
                Log.d(TAG, "Bonding receiver unregistered")
            } catch (e: IllegalArgumentException) {
                Log.w(TAG, "Receiver was not registered: ${e.message}")
            }
        }
    }

    /**
     * Handle bonding state changes from broadcast receiver
     */
    @SuppressLint("MissingPermission", "NewApi")
    private fun handleBondingStateChange(intent: Intent) {
        val device = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE, BluetoothDevice::class.java)
        } else {
            @Suppress("DEPRECATION")
            intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE)
        }
        val bondState =
            intent.getIntExtra(BluetoothDevice.EXTRA_BOND_STATE, BluetoothDevice.BOND_NONE)
        val previousBondState =
            intent.getIntExtra(BluetoothDevice.EXTRA_PREVIOUS_BOND_STATE, BluetoothDevice.BOND_NONE)

        if (!checkBluetoothPermissions()) {
            Log.w(TAG, "Missing permissions for bonding state change")
            return
        }
        if (device == null) {
            Log.w(TAG, "Bonding state change received but device is null")
            return
        }
        val foundMAC = knownPrimeDevicesMAC.find { device.address == it } != null
        val foundName = device.alias?.contains("Prime", ignoreCase = true) ?: false
        if (!foundMAC && !foundName) {
            Log.w(
                TAG, "Non  Prime device bonding event ignored: ${device.name} " +
                        "(${device.address} ${device.alias} ${device})"
            )
            return
        }

        Log.d(TAG, "Bonding state changed for (${device.address})")
        Log.d(TAG, "Previous state: ${getBondStateString(previousBondState)}")
        Log.d(TAG, "New state: ${getBondStateString(bondState)}")
        sendConnectionEvent(
            when (bondState) {
                BluetoothDevice.BOND_BONDED -> BluetoothConnectionEventType.DEVICE_CONNECTED
                BluetoothDevice.BOND_NONE -> BluetoothConnectionEventType.DEVICE_DISCONNECTED
                BluetoothDevice.BOND_BONDING -> BluetoothConnectionEventType.CONNECTION_ATTEMPT
                else -> BluetoothConnectionEventType.DEVICE_DISCONNECTED
            },
        )
    }

    /**
     * Get human-readable bond state string
     */
    private fun getBondStateString(bondState: Int): String {
        return when (bondState) {
            BluetoothDevice.BOND_NONE -> "BOND_NONE"
            BluetoothDevice.BOND_BONDING -> "BOND_BONDING"
            BluetoothDevice.BOND_BONDED -> "BOND_BONDED"
            else -> "UNKNOWN ($bondState)"
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "pair" -> pairWithDevice(call, result)
            "bond" -> bond(result)
            "stopScan" -> stopDeviceScan(result)
            "getCurrentDeviceStatus" -> getCurrentDeviceStatus(result)
            "transmitFromFile" -> transmitFromFile(call, result)
            "deviceName" -> getDeviceName(result)
            "disconnect" -> disconnectDevice(result)
            "reconnect" -> reconnect(call, result)
            "getConnectedPeripheralId" -> result.success(getConnectedPeripheralId())
            "isConnected" -> result.success(isConnected())
            "cancelTransfer" -> cancelTransfer(result)
            "enableBluetooth" -> enableBluetooth(result)
            else -> result.notImplemented()
        }
    }

    private var pendingEnableResult: MethodChannel.Result? = null

    //handler for enableBluetooth, this needs to be registered before activity onResume
    val enableBtLauncher =
        activity.registerForActivityResult(StartActivityForResult()) { res ->
            pendingEnableResult?.success(res.resultCode == Activity.RESULT_OK)
            pendingEnableResult = null
        }

    private fun enableBluetooth(result: MethodChannel.Result) {
        if (bluetoothAdapter?.isEnabled == true) {
            result.success(true)
        }
        if (ActivityCompat.checkSelfPermission(
                context,
                Manifest.permission.BLUETOOTH_CONNECT
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            return
        }
        pendingEnableResult = result
        val enableBtIntent = Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE)
        enableBtLauncher.launch(enableBtIntent)
    }

    private fun cancelTransfer(result: MethodChannel.Result) {
        if (transferJob?.isActive == true) {
            transferJob?.cancel()
            bleWriteQueue?.clearQueue()
            result.success(true)
        } else {
            result.success(false)
        }
    }

    @SuppressLint("MissingPermission")
    private fun getCurrentDeviceStatus(result: MethodChannel.Result) {
        if (!checkBluetoothPermissions()) {
            result.error(
                "PERMISSION_ERROR", "Bluetooth permissions not granted", null
            )
            return
        }
        result.success(
            BluetoothConnectionStatus(
                type = null,
                connected = isConnected(),
                peripheralId = connectedDevice?.address,
                peripheralName = connectedDevice?.name ?: "Unknown Device",
                bonded = connectedDevice?.bondState == BluetoothDevice.BOND_BONDED,
                rssi = null,
                error = null
            ).toMap()
        )
    }

    private fun reconnect(call: MethodCall, result: MethodChannel.Result) {
        pairWithDevice(call, result)
    }

    @SuppressLint("MissingPermission")
    private fun bond(result: MethodChannel.Result) {
        if (!checkBluetoothPermissions()) {
            result.error(
                "PERMISSION_ERROR", "Bluetooth permissions not granted", null
            )
            return
        }
        connectedDevice?.let { device ->
            when (device.bondState) {
                BluetoothDevice.BOND_NONE -> {
                    Log.d(TAG, "Starting bonding after GATT connection...")
                    val bondResult = device.createBond()
                    if (!bondResult) {
                        Log.e(TAG, "Failed to start bonding")

                        sendConnectionEvent(
                            BluetoothConnectionEventType.CONNECTION_ERROR,
                            error = "Failed to start bonding"
                        )

                    }
                }

                BluetoothDevice.BOND_BONDED -> {
                    Log.d(
                        TAG,
                        "Device already bonded, proceeding with service discovery"
                    )
                }

                BluetoothDevice.BOND_BONDING -> {
                    Log.d(TAG, "Bonding in progress, waiting...")
                }
            }
        }
    }

    @SuppressLint("MissingPermission")
    private fun transmitFromFile(call: MethodCall, result: MethodChannel.Result) {
        val path = call.argument<String?>("path")


        if (transferJob?.isActive == true) {
            Log.i(TAG, "transmitFromFile: Transfer already in progress")
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
        Log.d(TAG, "  Requested high connection priority for transfer  : ${if (priorityResult == true) "✓ Success" else "✗ Failed"}")
        transferJob = scope.launch(Dispatchers.IO) {
            try {
                val fileSize = file.length()
                var bytesProcessed = 0L
                var writeError = false

                // Use forEachChunk extension function
                file.inputStream().use { stream ->
                    stream.forEachChunk(BLE_PACKET_SIZE) { chunk ->
                        // Await the enqueue
                        val success = bleWriteQueue?.enqueue(chunk) ?: false
                        if (!success) {
                            Log.e(TAG, "Failed to enqueue data at byte $bytesProcessed")
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
                        // Send progress update
                        val progress = bytesProcessed.toFloat() / fileSize.toFloat()
                        sendWriteProgress(progress, path, bytesProcessed, fileSize)
                    }
                }
                file.delete()


                // Send final progress update
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
                    Log.w(TAG, "transmission cancelled: ${e.message}")
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
            val priority = BluetoothGatt.CONNECTION_PRIORITY_BALANCED
            val priorityResult = bluetoothGatt?.requestConnectionPriority(priority)
            Log.d(TAG, "  Requested balance connection priority after transfer  : ${if (priorityResult == true) "✓ Success" else "✗ Failed"}")
        }
    }

    @SuppressLint("MissingPermission")
    private fun getDeviceName(result: MethodChannel.Result) {
        if (!checkBluetoothPermissions()) {
            return
        }
        result.success(bluetoothAdapter?.name ?: "Envoy ")
    }

    @SuppressLint("MissingPermission")
    private suspend fun handleBinaryWrite(
        message: ByteBuffer?,
    ): ByteBuffer {
        val failureBuffer = createDirectByteBuffer(0)

        if (transferJob?.isActive == true) {
            Log.e(TAG, "Another write operation is in progress")
            return failureBuffer
        }
        if (message == null) {
            Log.e(TAG, "Message is null, sending FAILURE (0)")
            return failureBuffer
        }

        val data = ByteArray(message.remaining())
        message.get(data)

        if (!checkBluetoothPermissions()) {
            Log.e(TAG, "Missing Bluetooth permissions for binary write")
            return failureBuffer
        }

        val gatt = bluetoothGatt
        if (gatt == null) {
            Log.e(TAG, "No active Bluetooth connection for binary write")
            return failureBuffer
        }

        val writeChar = writeCharacteristic
        if (writeChar == null) {
            Log.e(TAG, "No write characteristic available for binary write")
            return failureBuffer
        }
        if (data.size < 8) {
            return failureBuffer
        }

        if (bleWriteQueue == null) {
            Log.e(TAG, "BLE Write Queue is not initialized")
            return failureBuffer
        }
        if (data.size > BLE_PACKET_SIZE) {
            data.chunked(BLE_PACKET_SIZE).forEach { chunk ->
                val result = bleWriteQueue?.enqueue(chunk) ?: false
                if (!result) {
                    Log.e(TAG, "Failed to enqueue chunk of size ${chunk.size}")
                    return failureBuffer
                }
            }
            return createDirectByteBuffer(1)
        } else {
            val success = bleWriteQueue?.enqueue(data) ?: false
            return if (success) {
                createDirectByteBuffer(1)
            } else {
                failureBuffer
            }
        }

    }

    private inner class ConnectionStreamHandler : EventChannel.StreamHandler {

        override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
            connectionEventSink = events

            connectedDevice?.let { _ ->
                if (ActivityCompat.checkSelfPermission(
                        context,
                        Manifest.permission.BLUETOOTH_CONNECT
                    ) != PackageManager.PERMISSION_GRANTED
                ) {
                    return
                }
                sendConnectionEvent(
                    type = BluetoothConnectionEventType.DEVICE_DISCONNECTED,
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

    @SuppressLint("MissingPermission")
    private fun pairWithDevice(call: MethodCall, result: MethodChannel.Result) {
        if (!checkBluetoothPermissions()) {
            result.error(
                "PERMISSION_ERROR", "Bluetooth permissions not granted", null
            )
            return
        }

        val deviceId = call.argument<String>("deviceId")
        if (!deviceId.isNullOrBlank()) {
            knownPrimeDevicesMAC.add(deviceId)
        }
        startDeviceScan(result)
    }

    @SuppressLint("MissingPermission")
    private fun startDeviceScan(result: MethodChannel.Result) {
        if (!checkBluetoothPermissions()) {
            result.error("PERMISSION_ERROR", "Bluetooth scan permission not granted", null)
            return
        }

        if (bluetoothAdapter?.isEnabled != true) {
            result.error("BLUETOOTH_DISABLED", "Bluetooth is not enabled", null)
            return
        }
        bluetoothLeScanner = bluetoothAdapter.bluetoothLeScanner

        if (bluetoothLeScanner == null) {
            result.error("SCANNER_ERROR", "Bluetooth LE scanner not available", null)
            return
        }

        try {
            bluetoothLeScanner?.stopScan(scanCallback)
        } catch (e: Exception) {
            Log.w(TAG, "No ongoing scan to stop: ${e.message}")
        }

        var scanFilters = knownPrimeDevicesMAC.map { bleMac ->
            ScanFilter.Builder()
                .setDeviceAddress(bleMac)
                .setServiceUuid(ParcelUuid(PRIME_SERVICE_UUID))
                .build()
        }

        if (scanFilters.isEmpty()) {
            scanFilters = listOf(
                ScanFilter.Builder()
                    .setServiceUuid(ParcelUuid(PRIME_SERVICE_UUID))
                    .build()
            )
        }
        val scanSettings = ScanSettings.Builder()
            .setScanMode(ScanSettings.SCAN_MODE_LOW_LATENCY)
            .setCallbackType(ScanSettings.CALLBACK_TYPE_ALL_MATCHES)
            .build()

        try {
            bluetoothLeScanner?.startScan(scanFilters, scanSettings, scanCallback)

            result.success(mapOf("scanning" to true, "message" to "Scan started"))
            mainHandler.postDelayed({
                try {
                    bluetoothLeScanner?.stopScan(scanCallback)

                    sendConnectionEvent(
                        type = BluetoothConnectionEventType.SCAN_STOPPED,
                    )

                } catch (e: Exception) {
                    Log.w(TAG, "Error stopping scan: ${e.message}")
                }
            }, 15000) // 15 seconds

        } catch (e: SecurityException) {
            Log.e(TAG, "Security exception during scan: ${e.message}")
            result.error("SECURITY_ERROR", "Missing scan permission: ${e.message}", null)
        } catch (e: Exception) {
            Log.e(TAG, " Failed to start scan: ${e.message}")
            result.error("SCAN_ERROR", "Failed to start scan: ${e.message}", null)
        }
    }

    private val scanCallback = object : ScanCallback() {
        @SuppressLint("MissingPermission")
        override fun onScanResult(callbackType: Int, result: ScanResult?) {
            result?.device?.let { device ->
                val serviceUuids =
                    result.scanRecord?.serviceUuids?.joinToString(", ") { it.uuid.toString() }
                        ?: "none"

                sendConnectionEvent(
                    type = BluetoothConnectionEventType.DEVICE_FOUND,
                )
                // Auto-connect to first Prime device found
                if (device.name?.contains("Prime", ignoreCase = true) == true ||
                    result.scanRecord?.serviceUuids?.any { it.uuid == PRIME_SERVICE_UUID } == true
                ) {

                    bluetoothLeScanner?.stopScan(this)
                    connectAndBondDevice(device)
                }
            }
        }

        override fun onBatchScanResults(results: MutableList<ScanResult>?) {

            results?.forEach { result ->
                onScanResult(ScanSettings.CALLBACK_TYPE_ALL_MATCHES, result)
            }
        }

        override fun onScanFailed(errorCode: Int) {
            val errorMessage = when (errorCode) {
                SCAN_FAILED_ALREADY_STARTED -> "Scan already started"
                SCAN_FAILED_APPLICATION_REGISTRATION_FAILED -> "Application registration failed"
                SCAN_FAILED_FEATURE_UNSUPPORTED -> "Feature unsupported"
                SCAN_FAILED_INTERNAL_ERROR -> "Internal error"
                else -> "Unknown error ($errorCode)"
            }

            Log.e(TAG, "BLE scan failed: $errorMessage")
            sendConnectionEvent(
                type = BluetoothConnectionEventType.SCAN_ERROR,
            )
        }
    }

    @SuppressLint("MissingPermission")
    private fun connectAndBondDevice(device: BluetoothDevice) {
        if (!checkBluetoothPermissions()) {
            Log.e(TAG, "Missing Bluetooth permissions for connection")
            return
        }

        bluetoothGatt?.let { existingGatt ->
            Log.d(TAG, "Closing existing GATT connection")
            existingGatt.disconnect()
            existingGatt.close()
        }

        bluetoothGatt?.close()
        bluetoothGatt = null

        Log.d(TAG, "Connecting to: ${device.name ?: "Unknown"} (${device.address})")

        sendConnectionEvent(
            type = BluetoothConnectionEventType.CONNECTION_ATTEMPT,
        )
        try {
            Log.d(TAG, "Connecting to: connectGatt called $gattCallback")

            // Connect to GATT server
            bluetoothGatt = device.connectGatt(
                context,
                true,
                gattCallback,
                BluetoothDevice.TRANSPORT_LE
            )
            Log.d(TAG, "Connecting to: connectGatt bluetoothGatt ${device.address}")


            if (bluetoothGatt == null) {
                sendConnectionEvent(
                    type = BluetoothConnectionEventType.CONNECTION_ERROR,
                    error = "Failed to create GATT connection"
                )
                return
            }

        } catch (e: SecurityException) {
            Log.e(TAG, "Security exception during connection: ${e.message}")
            sendConnectionEvent(
                type = BluetoothConnectionEventType.CONNECTION_ERROR,
                error = "Permission denied: ${e.message}"
            )
        } catch (e: Exception) {
            Log.e(TAG, "Unexpected error during connection: ${e.message}")
            sendConnectionEvent(
                type = BluetoothConnectionEventType.CONNECTION_ERROR,
                error = "Connection failed: ${e.message}"
            )
        }
    }


    @SuppressLint("MissingPermission")
    private fun sendConnectionEvent(
        type: BluetoothConnectionEventType,
        error: String? = null
    ) {
        if (!checkBluetoothPermissions()) {
            Log.w(TAG, "Missing Bluetooth permissions for sending connection event")
            return
        }
        scope.launch {
            connectionEventSink?.success(
                BluetoothConnectionStatus(
                    type,
                    connected = isConnected(),
                    peripheralId = connectedDevice?.address,
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
            if (writeProgressEventSink == null) {
                return@launch
            }
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


    private val bufferPool = ArrayDeque<ByteBuffer>()

    private fun getPooledBuffer(size: Int): ByteBuffer {
        val buf = bufferPool.removeFirstOrNull()
        if (buf == null || buf.capacity() < size) {
            return ByteBuffer.allocateDirect(size)
        }
        buf.clear()
        return buf
    }

    private fun sendBinaryData(data: ByteArray) {
        scope.launch {
            try {
                // Create direct ByteBuffer for Flutter

                val directBuffer = getPooledBuffer(data.size)
                directBuffer.put(data)

                bleReadChannel.send(directBuffer) { _ ->
                }
            } catch (e: Exception) {
                Log.e(TAG, " Error sending binary data: ${e.message}")
            }
        }
    }


    private val gattCallback = object : BluetoothGattCallback() {

        override fun onMtuChanged(gatt: BluetoothGatt?, mtu: Int, status: Int) {
            super.onMtuChanged(gatt, mtu, status)
            Log.d(TAG, "════════════════════════════════════════")
            Log.d(TAG, "MTU CHANGED EVENT")
            Log.d(TAG, "  Device: ${gatt?.device?.address}")
            Log.d(TAG, "  New MTU: $mtu bytes")
            Log.d(TAG, "  Status: ${getGattStatusString(status)}")
            Log.d(TAG, "  Previous MTU: $currentMtu bytes")
            if (status == BluetoothGatt.GATT_SUCCESS) {
                Log.d(TAG, "  ✓ MTU negotiation successful")
                Log.d(TAG, "  Max data per packet: ${mtu - 3} bytes")
            } else {
                Log.e(TAG, "  ✗ MTU negotiation failed")
            }
            Log.d(TAG, "════════════════════════════════════════")
            currentMtu = mtu
        }

        @SuppressLint("MissingPermission")
        override fun onConnectionStateChange(gatt: BluetoothGatt?, status: Int, newState: Int) {
            Log.d(TAG, "════════════════════════════════════════")
            Log.d(TAG, "CONNECTION STATE CHANGE")
            Log.d(TAG, "  Device: ${gatt?.device?.address} (${gatt?.device?.name})")
            Log.d(TAG, "  Status: ${getGattStatusString(status)}")
            Log.d(TAG, "  New State: ${getConnectionStateString(newState)}")
            Log.d(TAG, "  Bond State: ${gatt?.device?.let { getBondStateString(it.bondState) }}")

            when (newState) {
                BluetoothProfile.STATE_CONNECTED -> {
                    Log.d(TAG, "────────────────────────────────────────")
                    Log.d(TAG, "✓ CONNECTED TO GATT SERVER")
                    Log.d(TAG, "  Device Type: ${gatt?.device?.type?.let { getDeviceTypeString(it) }}")

                    connectedDevice = gatt?.device
                    bleWriteQueue?.restart()

                    if (!checkBluetoothPermissions()) {
                        Log.e(TAG, "  ✗ Missing Bluetooth permissions")
                        return
                    }

                    if (connectedDevice?.bondState == BluetoothDevice.BOND_BONDED) {
                        Log.d(TAG, "  ✓ Device is bonded")
                        sendConnectionEvent(
                            type = BluetoothConnectionEventType.DEVICE_CONNECTED
                        )
                    } else {
                        Log.d(TAG, "  ⚠ Device is not bonded yet")
                    }

                    // Request MTU
                    Log.d(TAG, "────────────────────────────────────────")
                    Log.d(TAG, "REQUESTING MTU")
                    val requestMtu = bluetoothGatt?.requestMtu(247)
                    Log.d(TAG, "  Requested MTU: 247 bytes")
                    Log.d(TAG, "  Request sent: ${if (requestMtu == true) "✓ Success" else "✗ Failed"}")

                    bluetoothGatt?.apply {
                        // Set connection priority
                        Log.d(TAG, "────────────────────────────────────────")
                        Log.d(TAG, "SETTING CONNECTION PARAMETERS")
                        val priority = BluetoothGatt.CONNECTION_PRIORITY_BALANCED
                        val priorityResult = requestConnectionPriority(priority)
                        Log.d(TAG, "  Priority: ${getConnectionPriorityString(priority)}")
                        Log.d(TAG, "  Request result: ${if (priorityResult) "✓ Success" else "✗ Failed"}")

                        // Set preferred PHY
                        Log.d(TAG, "────────────────────────────────────────")
                        Log.d(TAG, "SETTING PREFERRED PHY")
                        Log.d(TAG, "  TX PHY: 2M")
                        Log.d(TAG, "  RX PHY: 2M")
                        Log.d(TAG, "  PHY Options: 2M")
                        setPreferredPhy(
                            BluetoothDevice.PHY_LE_2M,  // txPhy
                            BluetoothDevice.PHY_LE_2M,  // rxPhy
                            BluetoothDevice.PHY_LE_2M
                        )
                    }

                    // Discover services
                    if (checkBluetoothPermissions()) {
                        Log.d(TAG, "────────────────────────────────────────")
                        Log.d(TAG, "SCHEDULING SERVICE DISCOVERY")
                        Log.d(TAG, "  Delay: ${BLUETOOTH_DISCOVERY_DELAY_MS}ms")
                        scope.launch {
                            delay(BLUETOOTH_DISCOVERY_DELAY_MS)
                            Log.d(TAG, "  Starting service discovery...")
                            val discoveryResult = gatt?.discoverServices()
                            Log.d(TAG, "  Discovery request: ${if (discoveryResult == true) "✓ Success" else "✗ Failed"}")
                        }
                    }

                    if (connectedDevice != null) {
                        sendConnectionEvent(
                            BluetoothConnectionEventType.DEVICE_CONNECTED,
                        )
                    }
                    Log.d(TAG, "════════════════════════════════════════")
                }

                BluetoothProfile.STATE_DISCONNECTED -> {
                    Log.d(TAG, "────────────────────────────────────────")
                    Log.d(TAG, "✗ DISCONNECTED FROM GATT SERVER")
                    Log.d(TAG, "  Reason: ${getGattStatusString(status)}")
                    Log.d(TAG, "════════════════════════════════════════")

                    sendConnectionEvent(
                        BluetoothConnectionEventType.DEVICE_DISCONNECTED,
                    )
                    bleWriteQueue?.cancel()
                    connectedDevice = null
                    writeCharacteristic = null
                    readCharacteristic = null
                }

                BluetoothProfile.STATE_CONNECTING -> {
                    Log.d(TAG, "  ⟳ Connecting...")
                    Log.d(TAG, "════════════════════════════════════════")
                }

                BluetoothProfile.STATE_DISCONNECTING -> {
                    Log.d(TAG, "  ⟳ Disconnecting...")
                    Log.d(TAG, "════════════════════════════════════════")
                }
            }
        }

        override fun onPhyUpdate(gatt: BluetoothGatt?, txPhy: Int, rxPhy: Int, status: Int) {
            super.onPhyUpdate(gatt, txPhy, rxPhy, status)
            Log.d(TAG, "════════════════════════════════════════")
            Log.d(TAG, "PHY UPDATE EVENT")
            Log.d(TAG, "  Device: ${gatt?.device?.address}")
            Log.d(TAG, "  TX PHY: ${getPhyString(txPhy)}")
            Log.d(TAG, "  RX PHY: ${getPhyString(rxPhy)}")
            Log.d(TAG, "  Status: ${getGattStatusString(status)}")
            if (status == BluetoothGatt.GATT_SUCCESS) {
                Log.d(TAG, "  ✓ PHY update successful")
            } else {
                Log.e(TAG, "  ✗ PHY update failed")
            }
            Log.d(TAG, "════════════════════════════════════════")
        }

        override fun onPhyRead(gatt: BluetoothGatt?, txPhy: Int, rxPhy: Int, status: Int) {
            super.onPhyRead(gatt, txPhy, rxPhy, status)
            Log.d(TAG, "════════════════════════════════════════")
            Log.d(TAG, "PHY READ EVENT")
            Log.d(TAG, "  Device: ${gatt?.device?.address}")
            Log.d(TAG, "  Current TX PHY: ${getPhyString(txPhy)}")
            Log.d(TAG, "  Current RX PHY: ${getPhyString(rxPhy)}")
            Log.d(TAG, "  Status: ${getGattStatusString(status)}")
            Log.d(TAG, "════════════════════════════════════════")
        }

        @SuppressLint("MissingPermission")
        override fun onServicesDiscovered(gatt: BluetoothGatt?, status: Int) {
            Log.d(TAG, "════════════════════════════════════════")
            Log.d(TAG, "SERVICE DISCOVERY COMPLETE")
            Log.d(TAG, "  Device: ${gatt?.device?.address}")
            Log.d(TAG, "  Status: ${getGattStatusString(status)}")

            if (status == BluetoothGatt.GATT_SUCCESS) {
                Log.d(TAG, "  ✓ Services discovered successfully")
                Log.d(TAG, "────────────────────────────────────────")
                Log.d(TAG, "DISCOVERED SERVICES:")
                gatt?.services?.forEach { service ->
                    Log.d(TAG, "  Service: ${service.uuid}")
                    Log.d(TAG, "    Characteristics: ${service.characteristics.size}")
                }

                val service = gatt?.getService(PRIME_SERVICE_UUID)
                if (service != null) {
                    Log.d(TAG, "────────────────────────────────────────")
                    Log.d(TAG, "✓ FOUND PRIME SERVICE: ${service.uuid}")
                    Log.d(TAG, "  Characteristics count: ${service.characteristics.size}")

                    // Find characteristics
                    service.characteristics.forEach { characteristic ->
                        val properties = characteristic.properties
                        val propertiesString = getPropertiesString(properties)
                        val permissions = characteristic.permissions

                        Log.d(TAG, "────────────────────────────────────────")
                        Log.d(TAG, "Characteristic: ${characteristic.uuid}")
                        Log.d(TAG, "  Properties: $propertiesString")
                        Log.d(TAG, "  Permissions: ${getPermissionsString(permissions)}")
                        Log.d(TAG, "  Write Type: ${getWriteTypeString(characteristic.writeType)}")
                        Log.d(TAG, "  Descriptors: ${characteristic.descriptors.size}")

                        when {
                            properties and BluetoothGattCharacteristic.PROPERTY_WRITE != 0 ||
                                    properties and BluetoothGattCharacteristic.PROPERTY_WRITE_NO_RESPONSE != 0 -> {
                                Log.d(TAG, "  → Configured as WRITE characteristic")
                                bleWriteQueue = BleWriteQueue(
                                    gatt, characteristic,
                                    CoroutineScope(Dispatchers.IO)
                                )
                                writeCharacteristic = characteristic
                            }

                            properties and BluetoothGattCharacteristic.PROPERTY_READ != 0 ||
                                    properties and BluetoothGattCharacteristic.PROPERTY_NOTIFY != 0 -> {
                                Log.d(TAG, "  → Configured as READ/NOTIFY characteristic")
                                readCharacteristic = characteristic

                                // Enable notifications if supported
                                if (properties and BluetoothGattCharacteristic.PROPERTY_NOTIFY != 0) {
                                    Log.d(TAG, "  ⟳ Enabling notifications...")
                                    val notificationEnabled =
                                        gatt.setCharacteristicNotification(characteristic, true)
                                    Log.d(TAG, "  Notification enabled: ${if (notificationEnabled) "✓" else "✗"}")

                                    val descriptor = characteristic.getDescriptor(CCCD_UUID)
                                    if (descriptor != null) {
                                        Log.d(TAG, "  ✓ Found CCCD descriptor")
                                        val enableNotificationValue =
                                            BluetoothGattDescriptor.ENABLE_NOTIFICATION_VALUE
                                        val writeResult = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                                            gatt.writeDescriptor(descriptor, enableNotificationValue)
                                        } else {
                                            @Suppress("DEPRECATION")
                                            descriptor.value = enableNotificationValue
                                            @Suppress("DEPRECATION")
                                            gatt.writeDescriptor(descriptor)
                                        }
                                        Log.d(TAG, "  CCCD write initiated: ${if (writeResult == BluetoothStatusCodes.SUCCESS || writeResult == true) "✓" else "✗"}")
                                    } else {
                                        Log.e(TAG, "  ✗ CCCD descriptor not found!")
                                        Log.e(TAG, "  Available descriptors:")
                                        characteristic.descriptors.forEach { desc ->
                                            Log.e(TAG, "    - ${desc.uuid}")
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Log.d(TAG, "────────────────────────────────────────")
                    Log.d(TAG, "CHARACTERISTICS CONFIGURATION SUMMARY:")
                    Log.d(TAG, "  Write: ${writeCharacteristic?.uuid ?: "None"}")
                    Log.d(TAG, "  Read:  ${readCharacteristic?.uuid ?: "None"}")
                } else {
                    Log.w(TAG, "  ✗ Prime service not found")
                }
            } else {
                Log.e(TAG, "  ✗ Service discovery failed")
            }
            Log.d(TAG, "════════════════════════════════════════")
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
                if (!checkBluetoothPermissions()) {
                    Log.d(TAG, "permission denied")
                    return
                }
                if (writeRetryCount > 0) {
                    Log.d(TAG, "  ✓ Write success after $writeRetryCount retries")
                }

                // Clear retry data on success
                pendingWriteData = null
                writeRetryCount = 0
            } else {
                Log.e(TAG, "════════════════════════════════════════")
                Log.e(TAG, "CHARACTERISTIC WRITE ERROR")
                Log.e(TAG, "  Characteristic: ${characteristic?.uuid}")
                Log.e(TAG, "  Status: ${getGattStatusString(status)}")
                Log.e(TAG, "  Retry attempt: $writeRetryCount/$MAX_WRITE_RETRIES")
                Log.e(TAG, "  Data size: ${pendingWriteData?.size ?: 0} bytes")
                Log.e(TAG, "════════════════════════════════════════")

                // Retry logic
                if (writeRetryCount < MAX_WRITE_RETRIES && pendingWriteData != null && characteristic != null && gatt != null) {
                    writeRetryCount++
                    Log.d(TAG, "⟳ Retrying write (attempt $writeRetryCount/$MAX_WRITE_RETRIES)")
                    scope.launch {
                        delay(RETRY_DELAY_MS)
                        val writeSuccess =
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                                if (pendingWriteData != null) {
                                    val success = gatt.writeCharacteristic(
                                        characteristic,
                                        pendingWriteData!!,
                                        characteristic.writeType
                                    )
                                    if (success != BluetoothStatusCodes.SUCCESS) {
                                        Log.e(TAG, "  ✗ writeCharacteristic error: ${getGattStatusString(success)}")
                                    }
                                    success == BluetoothStatusCodes.SUCCESS
                                } else {
                                    Log.e(TAG, "  ✗ pendingWriteData is null")
                                    false
                                }
                            } else {
                                @Suppress("DEPRECATION")
                                characteristic.value = pendingWriteData
                                @Suppress("DEPRECATION")
                                gatt.writeCharacteristic(characteristic)
                            }
                        if (!writeSuccess) {
                            Log.e(TAG, "  ✗ Failed to write characteristic on retry")
                        } else {
                            Log.d(TAG, "  ✓ Retry write initiated")
                        }
                    }
                    return
                }

                // Max retries reached
                Log.e(TAG, "✗ Write failed after $MAX_WRITE_RETRIES retries")
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
                // Below API 33 - use deprecated method
                @Suppress("DEPRECATION")
                if (status == BluetoothGatt.GATT_SUCCESS) {
                    characteristic?.value?.let { data ->
                        Log.d(TAG, " BLE READ RESPONSE:")
                        Log.d(TAG, "  - Characteristic: ${characteristic.uuid}")
                        Log.d(TAG, "  - Data length: ${data.size} bytes")
                        // Send raw binary data efficiently through binary message channel
                        sendBinaryData(data)
                    } ?: Log.w(TAG, " Read response received but data is null")
                } else {
                    Log.e(TAG, " Characteristic read failed with status: $status")
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
            // API 33+ - value is provided as parameter
            if (value.isEmpty()) {
                return
            }
            sendBinaryData(value)
        }

        // API 33+ version
        override fun onCharacteristicChanged(
            gatt: BluetoothGatt,
            characteristic: BluetoothGattCharacteristic,
            value: ByteArray
        ) {
            super.onCharacteristicChanged(gatt, characteristic, value)
            if (value.isEmpty()) {
                Log.w(TAG, "Notification received but data is null")
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
                // Below API 33 - use deprecated method
                @Suppress("DEPRECATION")
                if (characteristic?.value == null) {
                    Log.w(TAG, " Notification received but data is null")
                    return
                } else {
                    val data = characteristic.value
                    sendBinaryData(data)
                }
            }
        }

        override fun onDescriptorWrite(
            gatt: BluetoothGatt?,
            descriptor: BluetoothGattDescriptor?,
            status: Int
        ) {
            if (descriptor?.uuid == CCCD_UUID) {
                Log.d(TAG, "════════════════════════════════════════")
                Log.d(TAG, "CCCD DESCRIPTOR WRITE")
                Log.d(TAG, "  Characteristic: ${descriptor.characteristic?.uuid}")
                Log.d(TAG, "  Status: ${getGattStatusString(status)}")
                if (status == BluetoothGatt.GATT_SUCCESS) {
                    Log.d(TAG, "  ✓ Notifications enabled successfully")
                } else {
                    Log.e(TAG, "  ✗ Failed to enable notifications")
                }
                Log.d(TAG, "════════════════════════════════════════")
            }
        }
    }

    // Helper functions for readable logging
    private fun getConnectionStateString(state: Int): String {
        return when (state) {
            BluetoothProfile.STATE_DISCONNECTED -> "DISCONNECTED"
            BluetoothProfile.STATE_CONNECTING -> "CONNECTING"
            BluetoothProfile.STATE_CONNECTED -> "CONNECTED"
            BluetoothProfile.STATE_DISCONNECTING -> "DISCONNECTING"
            else -> "UNKNOWN ($state)"
        }
    }

    private fun getGattStatusString(status: Int): String {
        return when (status) {
            BluetoothGatt.GATT_SUCCESS -> "SUCCESS"
            BluetoothGatt.GATT_READ_NOT_PERMITTED -> "READ_NOT_PERMITTED"
            BluetoothGatt.GATT_WRITE_NOT_PERMITTED -> "WRITE_NOT_PERMITTED"
            BluetoothGatt.GATT_INSUFFICIENT_AUTHENTICATION -> "INSUFFICIENT_AUTHENTICATION"
            BluetoothGatt.GATT_REQUEST_NOT_SUPPORTED -> "REQUEST_NOT_SUPPORTED"
            BluetoothGatt.GATT_INSUFFICIENT_ENCRYPTION -> "INSUFFICIENT_ENCRYPTION"
            BluetoothGatt.GATT_INVALID_OFFSET -> "INVALID_OFFSET"
            BluetoothGatt.GATT_INVALID_ATTRIBUTE_LENGTH -> "INVALID_ATTRIBUTE_LENGTH"
            BluetoothGatt.GATT_CONNECTION_CONGESTED -> "CONNECTION_CONGESTED"
            BluetoothGatt.GATT_FAILURE -> "FAILURE"
            133 -> "GATT_ERROR (133 - Connection issue)"
            else -> "UNKNOWN ($status)"
        }
    }

    private fun getPhyString(phy: Int): String {
        return when (phy) {
            BluetoothDevice.PHY_LE_1M -> "1M"
            BluetoothDevice.PHY_LE_2M -> "2M"
            BluetoothDevice.PHY_LE_CODED -> "CODED"
            else -> "UNKNOWN ($phy)"
        }
    }

    private fun getConnectionPriorityString(priority: Int): String {
        return when (priority) {
            BluetoothGatt.CONNECTION_PRIORITY_BALANCED -> "BALANCED"
            BluetoothGatt.CONNECTION_PRIORITY_HIGH -> "HIGH"
            BluetoothGatt.CONNECTION_PRIORITY_LOW_POWER -> "LOW_POWER"
            else -> "UNKNOWN ($priority)"
        }
    }

    private fun getDeviceTypeString(type: Int): String {
        return when (type) {
            BluetoothDevice.DEVICE_TYPE_CLASSIC -> "CLASSIC"
            BluetoothDevice.DEVICE_TYPE_LE -> "LE"
            BluetoothDevice.DEVICE_TYPE_DUAL -> "DUAL"
            else -> "UNKNOWN ($type)"
        }
    }

    private fun getWriteTypeString(writeType: Int): String {
        return when (writeType) {
            BluetoothGattCharacteristic.WRITE_TYPE_DEFAULT -> "DEFAULT"
            BluetoothGattCharacteristic.WRITE_TYPE_NO_RESPONSE -> "NO_RESPONSE"
            BluetoothGattCharacteristic.WRITE_TYPE_SIGNED -> "SIGNED"
            else -> "UNKNOWN ($writeType)"
        }
    }

    private fun getPermissionsString(permissions: Int): String {
        val perms = mutableListOf<String>()
        if (permissions and BluetoothGattCharacteristic.PERMISSION_READ != 0) perms.add("READ")
        if (permissions and BluetoothGattCharacteristic.PERMISSION_WRITE != 0) perms.add("WRITE")
        if (permissions and BluetoothGattCharacteristic.PERMISSION_READ_ENCRYPTED != 0) perms.add("READ_ENCRYPTED")
        if (permissions and BluetoothGattCharacteristic.PERMISSION_WRITE_ENCRYPTED != 0) perms.add("WRITE_ENCRYPTED")
        return if (perms.isEmpty()) "NONE" else perms.joinToString(" | ")
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

    private fun checkBluetoothPermissions(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            ActivityCompat.checkSelfPermission(
                context,
                Manifest.permission.BLUETOOTH_CONNECT
            ) == PackageManager.PERMISSION_GRANTED &&
                    ActivityCompat.checkSelfPermission(
                        context,
                        Manifest.permission.BLUETOOTH_SCAN
                    ) == PackageManager.PERMISSION_GRANTED
        } else {
            ActivityCompat.checkSelfPermission(
                context,
                Manifest.permission.BLUETOOTH
            ) == PackageManager.PERMISSION_GRANTED &&
                    ActivityCompat.checkSelfPermission(
                        context,
                        Manifest.permission.BLUETOOTH_ADMIN
                    ) == PackageManager.PERMISSION_GRANTED
        }
    }

    private fun isConnected(): Boolean {
        return connectedDevice != null && bluetoothGatt != null
    }

    private fun getConnectedPeripheralId(): String? {
        return connectedDevice?.address
    }

    fun cleanup() {
        try {
            // Unregister bonding receiver
            unregisterBondingReceiver()

            // Stop any ongoing scan
            if (checkBluetoothPermissions()) {
                bluetoothLeScanner?.stopScan(scanCallback)
            }

            // Close GATT connection
            if (checkBluetoothPermissions()) {
                bluetoothGatt?.close()
            }
        } catch (e: SecurityException) {
            Log.w(TAG, "Permission denied during cleanup: ${e.message}")
        } catch (e: Exception) {
            Log.w(TAG, "Error during cleanup: ${e.message}")
        }

        bluetoothGatt = null
        connectedDevice = null
        writeCharacteristic = null
        readCharacteristic = null
        connectionEventSink = null
        writeProgressEventSink = null
        bondingReceiver = null
        Log.d(TAG, "BluetoothChannel cleaned up")
    }

    @SuppressLint("MissingPermission")
    private fun stopDeviceScan(result: MethodChannel.Result) {
        try {
            if (checkBluetoothPermissions()) {
                bluetoothLeScanner?.stopScan(scanCallback)
                sendConnectionEvent(
                    BluetoothConnectionEventType.SCAN_STOPPED,
                )
                result.success(mapOf("scanning" to false, "message" to "Scan stopped"))
            } else {
                result.error("PERMISSION_ERROR", "Bluetooth permissions not granted", null)
            }
        } catch (e: Exception) {
            Log.w(TAG, "Error stopping scan: ${e.message}")
            result.error("STOP_SCAN_ERROR", "Failed to stop scan: ${e.message}", null)
        }
    }

    @SuppressLint("MissingPermission")
    private fun disconnectDevice(result: MethodChannel.Result) {
        try {
            if (checkBluetoothPermissions()) {
                bluetoothGatt?.disconnect()
                bluetoothGatt?.discoverServices()
                Log.d(TAG, "Disconnecting from device")
                result.success(mapOf("disconnecting" to true))
            } else {
                result.error("PERMISSION_ERROR", "Bluetooth permissions not granted", null)
            }
        } catch (e: Exception) {
            Log.w(TAG, "Error disconnecting: ${e.message}")
            result.error("DISCONNECT_ERROR", "Failed to disconnect: ${e.message}", null)
        }
    }
}

suspend fun FileInputStream.forEachChunk(chunkSize: Int, action: suspend (ByteArray) -> Unit) {
    val buffer = ByteArray(chunkSize)
    while (true) {
        val bytesRead = read(buffer)
        if (bytesRead <= 0) break
        val chunk = if (bytesRead < chunkSize) {
            buffer.copyOfRange(0, bytesRead)
        } else {
            buffer.copyOf()
        }
        action(chunk)
    }
}

// Extension function for chunking byte arrays
fun ByteArray.chunked(size: Int): List<ByteArray> {
    if (isEmpty()) return emptyList()

    val chunks = mutableListOf<ByteArray>()
    var index = 0
    while (index < this.size) {
        val end = minOf(index + size, this.size)
        chunks.add(copyOfRange(index, end))
        index += size
    }
    return chunks
}


class SafeResult(private val result: MethodChannel.Result) {
    @OptIn(ExperimentalAtomicApi::class)
    private val lock = AtomicBoolean(false)

    fun success(value: Any?) {
        if (lock.compareAndSet(expectedValue = false, newValue = true)) {
            result.success(value)
        }
    }

    fun error(code: String, message: String?, details: Any?) {
        if (lock.compareAndSet(expectedValue = false, newValue = true)) {
            result.error(code, message, details)
        }
    }

    fun notImplemented() {
        if (lock.compareAndSet(expectedValue = false, newValue = true)) {
            result.notImplemented()
        }
    }
}
