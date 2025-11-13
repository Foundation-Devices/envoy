package com.foundationdevices.envoy

import android.Manifest
import android.annotation.SuppressLint
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
import android.bluetooth.le.ScanFilter
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
import androidx.core.app.ActivityCompat
import io.flutter.plugin.common.BasicMessageChannel
import io.flutter.plugin.common.BinaryCodec
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import java.nio.ByteBuffer
import java.util.UUID


class BluetoothChannel(private val context: Context, binaryMessenger: BinaryMessenger) :
    MethodChannel.MethodCallHandler {

    companion object {
        private const val TAG = "BluetoothChannel"
        private const val METHOD_CHANNEL_NAME = "envoy/bluetooth"
        private const val BLE_READ_CHANNEL_NAME = "envoy/ble/read"
        private const val BLE_WRITE_CHANNEL_NAME = "envoy/ble/write"
        private const val BLE_CONNECTION_STREAM_NAME = "envoy/bluetooth/connection/stream"
        private const val BLE_WRITE_PROGRESS_STREAM_NAME = "envoy/ble/write/progress"
        private const val BLUETOOTH_DISCOVERY_DELAY_MS = 500L

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
    private var currentMtu: Int = 247

    private val scope = CoroutineScope(Dispatchers.Main)

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
            handleBinaryWrite(message, reply)
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
        Log.d(TAG, "Bonding receiver registered")
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
    private fun handleBondingStateChange(intent: Intent) {
        val device = intent.getParcelableExtra<BluetoothDevice>(BluetoothDevice.EXTRA_DEVICE)
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

        Log.d(TAG, "Bonding state changed for (${device?.address})")
        Log.d(TAG, "  Previous state: ${getBondStateString(previousBondState)}")
        Log.d(TAG, "  New state: ${getBondStateString(bondState)}")
        sendConnectionEvent(
            BluetoothConnectionStatus(
                type = when (bondState) {
                    BluetoothDevice.BOND_BONDED -> BluetoothConnectionEventType.DEVICE_CONNECTED
                    BluetoothDevice.BOND_NONE -> BluetoothConnectionEventType.DEVICE_DISCONNECTED
                    BluetoothDevice.BOND_BONDING -> BluetoothConnectionEventType.CONNECTION_ATTEMPT
                    else -> BluetoothConnectionEventType.DEVICE_DISCONNECTED
                },
                connected = bondState == BluetoothDevice.BOND_BONDED,
                peripheralId = device.address,
                peripheralName = device.name ?: "Unknown Device",
                bonded = bondState == BluetoothDevice.BOND_BONDED
            ).toMap()
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
            "stopScan" -> stopDeviceScan(result)
            "deviceName" -> getDeviceName(result)
            "disconnect" -> disconnectDevice(result)
            "getConnectedPeripheralId" -> result.success(getConnectedPeripheralId())
            "isConnected" -> result.success(isConnected())
            else -> result.notImplemented()
        }
    }

    private fun getDeviceName(result: MethodChannel.Result) {
        result.success(bluetoothAdapter?.name ?: "Envoy ")
    }

    @SuppressLint("MissingPermission")
    private fun handleBinaryWrite(
        message: ByteBuffer?,
        reply: BasicMessageChannel.Reply<ByteBuffer>
    ) {
        val failureBuffer = createDirectByteBuffer(0)

        if (message == null) {
            Log.e(TAG, "Message is null, sending FAILURE (0)")
            reply.reply(failureBuffer)
            return
        }

        val data = ByteArray(message.remaining())
        message.get(data)

        if (!checkBluetoothPermissions()) {
            Log.e(TAG, "Missing Bluetooth permissions for binary write")
            reply.reply(failureBuffer)
            return
        }

        val gatt = bluetoothGatt
        if (gatt == null) {
            Log.e(TAG, "No active Bluetooth connection for binary write")
            reply.reply(createDirectByteBuffer(0))
            return
        }

        val writeChar = writeCharacteristic
        if (writeChar == null) {
            Log.e(TAG, "No write characteristic available for binary write")
            reply.reply(createDirectByteBuffer(0))
            return
        }
        if (data.size < 8) {
            Log.e(
                TAG,
                "ERROR: Binary data size (${data.size} bytes) is less than required minimum (8 bytes)"
            )
            reply.reply(createDirectByteBuffer(0))
            return
        }
        val writeType =
            if (writeChar.properties and BluetoothGattCharacteristic.PROPERTY_WRITE_NO_RESPONSE != 0) {
                BluetoothGattCharacteristic.WRITE_TYPE_NO_RESPONSE
            } else {
                BluetoothGattCharacteristic.WRITE_TYPE_DEFAULT
            }

        val writeTypeString = if (writeType == BluetoothGattCharacteristic.WRITE_TYPE_NO_RESPONSE) {
            "without_response"
        } else {
            "with_response"
        }


        // Get effective payload size (MTU - 3 bytes for ATT overhead)
        val payloadPerPacket = maxOf(1, currentMtu - 3)

        Log.d(
            TAG,
            "MTU: $currentMtu, payload: $payloadPerPacket, data: ${data.size} bytes, writeType: $writeTypeString"
        )

        if (data.size <= payloadPerPacket) {
            // Store data for potential retry
            pendingWriteData = data
            writeRetryCount = 0

            // Send progress update for single packet (100%)
            sendWriteProgress(1.0f)


            val writeSuccess = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                // API 33+
                val success = gatt.writeCharacteristic(writeChar, data, writeType)
                if (success != BluetoothStatusCodes.SUCCESS) {
                    Log.e(TAG, "Error writeCharacteristic : $success")
                }
                success == BluetoothStatusCodes.SUCCESS
            } else {
                // Below API 33
                @Suppress("DEPRECATION")
                writeChar.writeType = writeType
                @Suppress("DEPRECATION")
                writeChar.value = data
                @Suppress("DEPRECATION")
                gatt.writeCharacteristic(writeChar)
            }

            if (!writeSuccess) {
                Log.e(TAG, "Failed to write characteristic")
            }

            if (!writeSuccess) {
                Log.e(TAG, " Failed to initiate binary write operation")
                reply.reply(createDirectByteBuffer(0))
                return
            }

            val successBuffer = createDirectByteBuffer(1)
            reply.reply(successBuffer)
        } else {
            val chunks = data.chunked(payloadPerPacket)
            Log.d(
                TAG,
                "Writing chunks ${chunks.size}: ${
                    chunks.map { chunks.size }.reduce { acc, i -> acc + i }
                } bytes"
            )
            for ((index, chunk) in chunks.withIndex()) {

                // Send progress update
                val progress = (index + 1).toFloat() / chunks.size.toFloat()
                sendWriteProgress(progress)

                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                    gatt.writeCharacteristic(
                        writeChar,
                        chunk,
                        writeType
                    )
                } else {
                    writeChar.writeType = writeType
                    @Suppress("DEPRECATION")
                    writeChar.value = chunk
                    @Suppress("DEPRECATION")
                    gatt.writeCharacteristic(writeChar)
                }

                if (writeType == BluetoothGattCharacteristic.WRITE_TYPE_NO_RESPONSE && index < chunks.size - 1) {
                    Thread.sleep(10)
                }
            }

            val successBuffer = createDirectByteBuffer(1)
            reply.reply(successBuffer)
        }
    }

    private inner class ConnectionStreamHandler : EventChannel.StreamHandler {

        override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
            connectionEventSink = events

            connectedDevice?.let { device ->
                if (ActivityCompat.checkSelfPermission(
                        context,
                        Manifest.permission.BLUETOOTH_CONNECT
                    ) != PackageManager.PERMISSION_GRANTED
                ) {
                    return
                }
                val connectionState =
                    bluetoothManager.getConnectionState(device, BluetoothProfile.GATT)
                sendConnectionEvent(
                    BluetoothConnectionStatus(
                        type = BluetoothConnectionEventType.DEVICE_DISCONNECTED,
                        connected = false,
                        bonded = connectedDevice?.bondState == BluetoothDevice.BOND_BONDED,
                    ).toMap()
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

        val scanner = bluetoothLeScanner
        if (scanner == null) {
            result.error("SCANNER_ERROR", "Bluetooth LE scanner not available", null)
            return
        }

        try {
            scanner.stopScan(scanCallback)
        } catch (e: Exception) {
            Log.w(TAG, "No ongoing scan to stop: ${e.message}")
        }

        var scanFilters = knownPrimeDevicesMAC.map { bleMac ->
            ScanFilter.Builder()
                .setDeviceName("Passport Prime")
                .setDeviceAddress(bleMac)
                .setServiceUuid(ParcelUuid(PRIME_SERVICE_UUID))
                .setDeviceName("Passport Prime")
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
            scanner.startScan(scanFilters, scanSettings, scanCallback)

            result.success(mapOf("scanning" to true, "message" to "Scan started"))
            mainHandler.postDelayed({
                try {
                    scanner.stopScan(scanCallback)

                    sendConnectionEvent(
                        BluetoothConnectionStatus(
                            type = BluetoothConnectionEventType.SCAN_STOPPED,
                            connected = false,
                            bonded = false
                        ).toMap()
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

    private val scanCallback = object : android.bluetooth.le.ScanCallback() {
        @SuppressLint("MissingPermission")
        override fun onScanResult(callbackType: Int, result: android.bluetooth.le.ScanResult?) {
            result?.device?.let { device ->
                Log.d(TAG, "Found device: ${device.name ?: "Unknown"} (${device.address})")

                sendConnectionEvent(
                    BluetoothConnectionStatus(
                        type = BluetoothConnectionEventType.DEVICE_FOUND,
                        connected = false,
                        peripheralId = device.address,
                        peripheralName = device.name ?: "Unknown Device",
                        rssi = result.rssi,
                        bonded = device.bondState == BluetoothDevice.BOND_BONDED
                    ).toMap()
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

        override fun onBatchScanResults(results: MutableList<android.bluetooth.le.ScanResult>?) {

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
                BluetoothConnectionStatus(
                    type = BluetoothConnectionEventType.SCAN_ERROR,
                    connected = false,
                    error = errorMessage,
                    bonded = false
                ).toMap()
            )
        }
    }

    private fun connectToDevice(deviceAddress: String, result: MethodChannel.Result) {
        if (!checkBluetoothPermissions()) {
            result.error("PERMISSION_ERROR", "Bluetooth connect permission not granted", null)
            return
        }
        Log.i(TAG, "connectToDevice: Connecting to $deviceAddress")
        try {
            val device = bluetoothAdapter?.getRemoteDevice(deviceAddress)
            Log.i(TAG, "connectToDevice: bluetoothAdapter $bluetoothAdapter $device")

            if (device == null) {
                result.error(
                    "DEVICE_NOT_FOUND",
                    "Device with address $deviceAddress not found",
                    null
                )
                return
            }

            connectAndBondDevice(device)

            result.success(mapOf("connecting" to true, "deviceAddress" to deviceAddress))

        } catch (e: IllegalArgumentException) {
            result.error("INVALID_ADDRESS", "Invalid device address: $deviceAddress", null)
        } catch (e: Exception) {
            result.error("CONNECTION_ERROR", "Failed to connect: ${e.message}", null)
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
            BluetoothConnectionStatus(
                type = BluetoothConnectionEventType.CONNECTION_ATTEMPT,
                connected = false,
                peripheralId = device.address,
                peripheralName = device.name ?: "Unknown Device",
                bonded = device.bondState == BluetoothDevice.BOND_BONDED
            ).toMap()
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
                    BluetoothConnectionStatus(
                        type = BluetoothConnectionEventType.CONNECTION_ERROR,
                        connected = false,
                        peripheralId = device.address,
                        error = "Failed to create GATT connection",
                        bonded = device.bondState == BluetoothDevice.BOND_BONDED
                    ).toMap()
                )
                return
            }

        } catch (e: SecurityException) {
            Log.e(TAG, "Security exception during connection: ${e.message}")
            sendConnectionEvent(
                BluetoothConnectionStatus(
                    type = BluetoothConnectionEventType.CONNECTION_ERROR,
                    connected = false,
                    peripheralId = device.address,
                    bonded = device.bondState == BluetoothDevice.BOND_BONDED,
                    error = "Permission denied: ${e.message}"
                ).toMap()
            )
        } catch (e: Exception) {
            Log.e(TAG, "Unexpected error during connection: ${e.message}")
            sendConnectionEvent(
                BluetoothConnectionStatus(
                    type = BluetoothConnectionEventType.CONNECTION_ERROR,
                    connected = false,
                    peripheralId = device.address,
                    bonded = device.bondState == BluetoothDevice.BOND_BONDED,
                    error = "Connection failed: ${e.message}"
                ).toMap()
            )
        }
    }


    private fun sendConnectionEvent(payload: Map<String, Any?>) {
        scope.launch {
            connectionEventSink?.success(payload)
        }
    }

    private fun sendWriteProgress(progress: Float) {
        scope.launch {
            if (writeProgressEventSink == null) {
                return@launch
            }
            writeProgressEventSink?.success(progress)
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
            Log.d(TAG, "MTU changed to $mtu (status: $status)")
            currentMtu = mtu
        }

        @SuppressLint("MissingPermission")
        override fun onConnectionStateChange(gatt: BluetoothGatt?, status: Int, newState: Int) {
            when (newState) {
                BluetoothProfile.STATE_CONNECTED -> {
                    Log.d(TAG, "Connected to GATT server")
                    connectedDevice = gatt?.device
                    if (!checkBluetoothPermissions()) {
                        return
                    }
                    if (connectedDevice?.bondState == BluetoothDevice.BOND_BONDED) {
                        sendConnectionEvent(
                            BluetoothConnectionStatus(
                                type = BluetoothConnectionEventType.DEVICE_CONNECTED,
                                connected = true,
                                bonded = connectedDevice?.bondState == BluetoothDevice.BOND_BONDED,
                            ).toMap()
                        )
                    }
                    connectedDevice?.let { device ->
                        when (device.bondState) {
                            BluetoothDevice.BOND_NONE -> {
                                Log.d(TAG, "Starting bonding after GATT connection...")
                                val bondResult = device.createBond()
                                if (!bondResult) {
                                    Log.e(TAG, "Failed to start bonding")
                                    sendConnectionEvent(
                                        BluetoothConnectionStatus(
                                            type = BluetoothConnectionEventType.CONNECTION_ERROR,
                                            connected = true,
                                            peripheralId = device.address,
                                            peripheralName = device.name ?: "Unknown Device",
                                            bonded = false,
                                            error = "Failed to start bonding"
                                        ).toMap()
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

                    val requestMtu = bluetoothGatt?.requestMtu(247)
                    bluetoothGatt?.apply {
                        //TODO: use method channel to enable high priority connection from flutter side
                        //use only for large data transfers
                        requestConnectionPriority(BluetoothGatt.CONNECTION_PRIORITY_HIGH)

                        setPreferredPhy(
                            BluetoothDevice.PHY_LE_1M_MASK or BluetoothDevice.PHY_LE_2M_MASK,  // txPhy
                            BluetoothDevice.PHY_LE_1M_MASK or BluetoothDevice.PHY_LE_2M_MASK,  // rxPhy
                            BluetoothDevice.PHY_OPTION_NO_PREFERRED
                        )

                    }
                    Log.i(TAG, "onConnectionStateChange: requestMtu $requestMtu")
                    // Discover services
                    if (checkBluetoothPermissions()) {
                        scope.launch {
                            delay(BLUETOOTH_DISCOVERY_DELAY_MS)
                            gatt?.discoverServices()
                        }
                    }

                    if (connectedDevice == null) {
                        Log.i(TAG, "onConnectionStateChange: ")
                        return;
                    }
                    val device = connectedDevice
                    // Initiate bonding (pairing) if not already bonded
                    when (device?.bondState) {
                        BluetoothDevice.BOND_NONE -> {
                            val bondResult = device.createBond()
                            if (bondResult) {

                                sendConnectionEvent(
                                    BluetoothConnectionStatus(
                                        type = BluetoothConnectionEventType.CONNECTION_ATTEMPT,
                                        connected = false,
                                        peripheralId = device.address,
                                        peripheralName = device.name ?: "Unknown Device",
                                        bonded = device.bondState == BluetoothDevice.BOND_BONDED
                                    ).toMap()
                                )
                            } else {
                                Log.e(TAG, "Failed to start bonding")
                                sendConnectionEvent(
                                    BluetoothConnectionStatus(
                                        type = BluetoothConnectionEventType.CONNECTION_ERROR,
                                        connected = false,
                                        peripheralId = device.address,
                                        bonded = device.bondState == BluetoothDevice.BOND_BONDED,
                                        error = "Failed to start bonding"
                                    ).toMap()
                                )
                            }
                        }

                        BluetoothDevice.BOND_BONDING -> {

                            sendConnectionEvent(
                                BluetoothConnectionStatus(
                                    type = BluetoothConnectionEventType.CONNECTION_ATTEMPT,
                                    connected = false,
                                    peripheralId = device.address,
                                    bonded = device.bondState == BluetoothDevice.BOND_BONDED,
                                    peripheralName = device.name ?: "Unknown Device"
                                ).toMap()
                            )
                        }

                        BluetoothDevice.BOND_BONDED -> {

                            sendConnectionEvent(
                                BluetoothConnectionStatus(
                                    type = BluetoothConnectionEventType.DEVICE_CONNECTED,
                                    connected = false,
                                    peripheralId = device.address,
                                    bonded = device.bondState == BluetoothDevice.BOND_BONDED,
                                    peripheralName = device.name ?: "Unknown Device"
                                ).toMap()
                            )
                        }
                    }
                }

                BluetoothProfile.STATE_DISCONNECTED -> {
                    Log.d(TAG, "Disconnected from GATT server")

                    sendConnectionEvent(
                        BluetoothConnectionStatus(
                            type = BluetoothConnectionEventType.DEVICE_DISCONNECTED,
                            connected = false,
                            bonded = connectedDevice?.bondState == BluetoothDevice.BOND_BONDED,
                        ).toMap()
                    )

                    connectedDevice = null
                    writeCharacteristic = null
                    readCharacteristic = null
                }
            }
        }

        @SuppressLint("MissingPermission")
        override fun onServicesDiscovered(gatt: BluetoothGatt?, status: Int) {
            if (status == BluetoothGatt.GATT_SUCCESS) {
                Log.d(TAG, "Services discovered successfully")

                val service = gatt?.getService(PRIME_SERVICE_UUID)
                if (service != null) {
                    Log.d(TAG, "Found Prime service: ${service.uuid}")

                    // Find characteristics
                    service.characteristics.forEach { characteristic ->
                        val properties = characteristic.properties
                        val propertiesString = getPropertiesString(properties)

                        Log.d(
                            TAG,
                            "Found characteristic: ${characteristic.uuid} (properties: $propertiesString)"
                        )

                        when {
                            properties and BluetoothGattCharacteristic.PROPERTY_WRITE != 0 ||
                                    properties and BluetoothGattCharacteristic.PROPERTY_WRITE_NO_RESPONSE != 0 -> {
                                writeCharacteristic = characteristic
                            }

                            properties and BluetoothGattCharacteristic.PROPERTY_READ != 0 ||
                                    properties and BluetoothGattCharacteristic.PROPERTY_NOTIFY != 0 -> {
                                readCharacteristic = characteristic

                                // Enable notifications if supported
                                if (properties and BluetoothGattCharacteristic.PROPERTY_NOTIFY != 0) {
                                    val notificationEnabled =
                                        gatt.setCharacteristicNotification(characteristic, true)
                                    Log.d(TAG, "Notification setup result: $notificationEnabled")
                                    val descriptor = characteristic.getDescriptor(CCCD_UUID)
                                    if (descriptor != null) {
                                        val enableNotificationValue =
                                            BluetoothGattDescriptor.ENABLE_NOTIFICATION_VALUE
                                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                                            // Android 13+ (API 33): new overload
                                            gatt.writeDescriptor(
                                                descriptor,
                                                enableNotificationValue
                                            )
                                        } else {
                                            // Older APIs: legacy call
                                            @Suppress("DEPRECATION")
                                            descriptor.value = enableNotificationValue
                                            @Suppress("DEPRECATION")
                                            gatt.writeDescriptor(descriptor)
                                        }
                                    } else {
                                        Log.e(
                                            TAG,
                                            " CCCD descriptor not found! Notifications won't work"
                                        )
                                        Log.e(TAG, "   Available descriptors:")
                                        characteristic.descriptors.forEach { desc ->
                                            Log.e(TAG, "   - ${desc.uuid}")
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Log.d(TAG, " Characteristics Summary:")
                    Log.d(TAG, "  - Write characteristic: ${writeCharacteristic?.uuid ?: "None"}")
                    Log.d(TAG, "  - Read characteristic: ${readCharacteristic?.uuid ?: "None"}")
                } else {
                    Log.w(TAG, "Prime service not found")
                }
            } else {
                Log.e(TAG, "Service discovery failed with status: $status")
            }
        }

        @SuppressLint("MissingPermission")
        override fun onCharacteristicWrite(
            gatt: BluetoothGatt?,
            characteristic: BluetoothGattCharacteristic?,
            status: Int
        ) {
            if (status == BluetoothGatt.GATT_SUCCESS) {

                if (!checkBluetoothPermissions()) {
                    Log.d(TAG, "permission denied")
                    return
                }
                if (writeRetryCount > 0) {
                    Log.d(TAG, "  - Success after $writeRetryCount retries")
                }

                // Clear retry data on success
                pendingWriteData = null
                writeRetryCount = 0
            } else {
                Log.e(TAG, "WRITE ERROR:")
                Log.e(TAG, "  - Characteristic: ${characteristic?.uuid}")
                Log.e(TAG, "  - Status: $status")
                Log.e(TAG, "  - Retry attempt: $writeRetryCount/$MAX_WRITE_RETRIES")
                // Retry logic
                if (writeRetryCount < MAX_WRITE_RETRIES && pendingWriteData != null && characteristic != null && gatt != null) {
                    writeRetryCount++
                    Log.d(
                        TAG,
                        "Retrying write operation (attempt $writeRetryCount/$MAX_WRITE_RETRIES)"
                    )
                    scope.launch {
                        delay(RETRY_DELAY_MS)
                        val writeSuccess =
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                                // API 33+
                                if (pendingWriteData != null) {
                                    val success = gatt.writeCharacteristic(
                                        characteristic,
                                        pendingWriteData!!,
                                        characteristic.writeType
                                    )
                                    if (success != BluetoothStatusCodes.SUCCESS) {
                                        Log.e(TAG, "Error writeCharacteristic : $success")
                                    }
                                    success == BluetoothStatusCodes.SUCCESS
                                } else {
                                    Log.e(TAG, "Error  pendingWriteData: is null")
                                    false
                                }

                            } else {
                                // Below API 33
                                @Suppress("DEPRECATION")
                                characteristic.value = pendingWriteData
                                @Suppress("DEPRECATION")
                                gatt.writeCharacteristic(characteristic)
                            }
                        if (!writeSuccess) {
                            Log.e(TAG, "Failed to write characteristic on retry")
                        }
                    }

                    return
                }

                // Max retries reached, send error
                Log.e(TAG, "Write failed after $MAX_WRITE_RETRIES retries")
                pendingWriteData = null
                val finalRetryCount = writeRetryCount
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
                Log.w(TAG, "onCharacteristicRead received but data is null")
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
                if (status == BluetoothGatt.GATT_SUCCESS) {
                    Log.d(TAG, "CCCD write successful - Notifications enabled")
                } else {
                    Log.e(TAG, "CCCD write failed with status: $status")
                }
            }
        }
    }


    private fun getConnectedPeripheralId(): String? {
        return connectedDevice?.address
    }

    private fun isConnected(): Boolean {
        return connectedDevice != null &&
                bluetoothGatt?.getConnectionState(connectedDevice!!) == BluetoothProfile.STATE_CONNECTED
    }

    private fun checkBluetoothPermissions(): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val hasConnectPermission = ActivityCompat.checkSelfPermission(
                context,
                Manifest.permission.BLUETOOTH_CONNECT
            ) == PackageManager.PERMISSION_GRANTED
            val hasScanPermission = ActivityCompat.checkSelfPermission(
                context,
                Manifest.permission.BLUETOOTH_SCAN
            ) == PackageManager.PERMISSION_GRANTED
            return hasConnectPermission && hasScanPermission
        } else {
            val hasBluetoothPermission = ActivityCompat.checkSelfPermission(
                context,
                Manifest.permission.BLUETOOTH
            ) == PackageManager.PERMISSION_GRANTED
            val hasBluetoothAdminPermission = ActivityCompat.checkSelfPermission(
                context,
                Manifest.permission.BLUETOOTH_ADMIN
            ) == PackageManager.PERMISSION_GRANTED
            return hasBluetoothPermission && hasBluetoothAdminPermission
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
                    BluetoothConnectionStatus(
                        type = BluetoothConnectionEventType.SCAN_STOPPED,
                        connected = false,
                        bonded = false
                    ).toMap()
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
