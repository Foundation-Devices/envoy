@file:OptIn(ExperimentalAtomicApi::class)

package com.foundationdevices.envoy.ble

import android.Manifest
import android.annotation.SuppressLint
import android.app.Activity
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothManager
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
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import java.io.FileInputStream
import java.util.UUID
import kotlin.concurrent.atomics.AtomicBoolean
import kotlin.concurrent.atomics.ExperimentalAtomicApi

/**
 * BluetoothChannel manages shared Bluetooth operations and multiple BLE device connections.
 *
 * Shared operations (handled here):
 * - Bluetooth permissions
 * - Enabling/disabling Bluetooth
 * - Device scanning and discovery
 * - Managing known device MAC addresses
 * - Bonding state broadcast receiver
 *
 * Device-specific operations (handled by QLConnection):
 * - GATT connection and state
 * - Characteristics and MTU
 * - Data transfer (read/write)
 * - Device-specific Flutter channels
 *
 * Channel naming:
 * - Main channel: envoy/bluetooth (for shared operations)
 * - Scan stream: envoy/bluetooth/scan/stream
 */
class BluetoothChannel(
    private val context: Context,
    private val activity: ComponentActivity,
    private val binaryMessenger: BinaryMessenger
) : MethodChannel.MethodCallHandler, QLConnectionCallback {

    companion object {
        private const val TAG = "BluetoothChannel"
        private const val METHOD_CHANNEL_NAME = "envoy/bluetooth"
        private const val BLE_SCAN_STREAM_NAME = "envoy/bluetooth/scan/stream"

        private val PRIME_SERVICE_UUID = UUID.fromString("6E400001-B5A3-F393-E0A9-E50E24DCCA9E")
    }

    // Main method channel for shared operations
    private val methodChannel: MethodChannel = MethodChannel(binaryMessenger, METHOD_CHANNEL_NAME)

    // Scan event channel
    private val scanEventChannel: EventChannel = EventChannel(binaryMessenger, BLE_SCAN_STREAM_NAME)
    private var scanEventSink: EventChannel.EventSink? = null

    // Bluetooth adapter and scanner
    private val bluetoothManager: BluetoothManager =
        context.getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
    private val bluetoothAdapter: BluetoothAdapter? = bluetoothManager.adapter
    private var bluetoothLeScanner: BluetoothLeScanner? = null

    // Known device MAC addresses
    private var knownPrimeDevicesMAC: MutableSet<String> = mutableSetOf()

    // Connected QLConnection instances, keyed by MAC address
    private val devices: MutableMap<String, QLConnection> = mutableMapOf()

    private val mainHandler = Handler(Looper.getMainLooper())
    private val scope = CoroutineScope(Dispatchers.Main)

    // Bonding broadcast receiver
    private var bondingReceiver: BroadcastReceiver? = null
    private var isReceiverRegistered = false

    // Bluetooth enable launcher
    private var pendingEnableResult: MethodChannel.Result? = null
    val enableBtLauncher = activity.registerForActivityResult(StartActivityForResult()) { res ->
        pendingEnableResult?.success(res.resultCode == Activity.RESULT_OK)
        pendingEnableResult = null
    }

    init {
        methodChannel.setMethodCallHandler(this)
        scanEventChannel.setStreamHandler(ScanStreamHandler())
        bluetoothLeScanner = bluetoothAdapter?.bluetoothLeScanner
        setupBondingReceiver()
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            // Shared operations
            "enableBluetooth" -> enableBluetooth(result)
            "deviceName" -> getDeviceName(result)
            "startScan" -> startDeviceScan(call, result)
            "stopScan" -> stopDeviceScan(result)
            "pair" -> pairWithDevice(call, result)
            "apiLevel" -> {
                result.success(Build.VERSION.SDK_INT)
            }

            "prepareDevice" -> prepareDevice(call, result)
            "reconnect" -> reconnect(call, result)
            "getConnectedDevices" -> getConnectedDevices(result)
            "removeDevice" -> removeDevice(call, result)
            else -> result.notImplemented()
        }
    }

    // ==================== QLConnectionCallback ====================

    override fun onDeviceDisconnected(device: QLConnection) {
        Log.d(TAG, "Device disconnected: ${device.deviceId}")
        // Keep the device in the map but note it's disconnected

        // The device can be reconnected using the reconnect method
    }

    // ==================== Shared Operations ====================

    private fun enableBluetooth(result: MethodChannel.Result) {
        if (bluetoothAdapter?.isEnabled == true) {
            result.success(true)
            return
        }
        if (ActivityCompat.checkSelfPermission(
                context, Manifest.permission.BLUETOOTH_CONNECT
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            result.error("PERMISSION_ERROR", "Bluetooth connect permission not granted", null)
            return
        }
        pendingEnableResult = result
        val enableBtIntent = Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE)
        enableBtLauncher.launch(enableBtIntent)
    }

    @SuppressLint("MissingPermission")
    private fun getDeviceName(result: MethodChannel.Result) {
        if (!checkBluetoothPermissions()) {
            result.error("PERMISSION_ERROR", "Bluetooth permissions not granted", null)
            return
        }
        result.success(bluetoothAdapter?.name ?: "Envoy")
    }

    private fun getConnectedDevices(result: MethodChannel.Result) {
        val connectedDevices = devices.filter { it.value.isConnected() }.map { (deviceId, device) ->
            mapOf(
                "deviceId" to deviceId,
                "name" to (device.peripheralName ?: "Unknown"),
                "bonded" to device.isBonded
            )
        }
        result.success(connectedDevices)
    }

    private fun removeDevice(call: MethodCall, result: MethodChannel.Result) {
        val deviceId = call.argument<String>("deviceId")
        if (deviceId.isNullOrBlank()) {
            result.error("INVALID_DEVICE_ID", "Device ID is required", null)
            return
        }

        val device = devices.remove(deviceId)
        if (device != null) {
            device.cleanup()
            knownPrimeDevicesMAC.remove(deviceId)
            Log.d(TAG, "Removed device: $deviceId")
            result.success(true)
        } else {
            result.success(false)
        }
    }

    // ==================== Scanning ====================

    @SuppressLint("MissingPermission")
    private fun pairWithDevice(call: MethodCall, result: MethodChannel.Result) {
        if (!checkBluetoothPermissions()) {
            result.error("PERMISSION_ERROR", "Bluetooth permissions not granted", null)
            return
        }

        val deviceId = call.argument<String>("deviceId")
        if (!deviceId.isNullOrBlank()) {
            knownPrimeDevicesMAC.add(deviceId)
            // Create QLConnection immediately so its channels are registered
            // before Dart tries to listen to them
            getOrCreateDevice(deviceId)
        }
        startDeviceScan(call, result)
    }

    /**
     * Get or create a QLConnection for the given device ID.
     * This ensures the device's channels are registered before Dart tries to use them.
     */
    private fun getOrCreateDevice(deviceId: String): QLConnection {
        return devices.getOrPut(deviceId) {
            Log.d(TAG, "Creating QLConnection for: $deviceId")
            QLConnection(
                deviceId = deviceId,
                context = context,
                bluetoothManager = bluetoothManager,
                binaryMessenger = binaryMessenger,
                callback = this,
                scope = scope
            )
        }
    }

    /**
     * Prepare a device for connection by creating its QLConnection and registering channels.
     * This must be called BEFORE Dart creates its QLConnection to ensure the native
     * EventChannel StreamHandler is registered before Dart tries to listen.
     */
    private fun prepareDevice(call: MethodCall, result: MethodChannel.Result) {
        val deviceId = call.argument<String>("deviceId")
        if (deviceId.isNullOrBlank()) {
            result.error("INVALID_DEVICE_ID", "Device ID is required", null)
            return
        }
        try {
            // Create QLConnection so its channels are registered
            getOrCreateDevice(deviceId)

            result.success(true)
        } catch (e: Exception) {
            Log.e(TAG, "Error preparing device: ${e.message}", e)
            result.error("PREPARE_ERROR", "Failed to prepare device: ${e.message}", null)
        }
    }

    /**
     * Reconnect to a previously paired device.
     * prepareDevice() should be called first to register native channels.
     */
    @SuppressLint("MissingPermission")
    private fun reconnect(call: MethodCall, result: MethodChannel.Result) {
        if (!checkBluetoothPermissions()) {
            result.error("PERMISSION_ERROR", "Bluetooth permissions not granted", null)
            return
        }

        val deviceId = call.argument<String>("deviceId")
        if (deviceId.isNullOrBlank()) {
            result.error("INVALID_DEVICE_ID", "Device ID is required", null)
            return
        }

        try {
            val adapter = bluetoothManager.adapter
            if (adapter == null) {
                result.error("NO_ADAPTER", "Bluetooth adapter not available", null)
                return
            }

            // Get or create QLConnection (may already exist from prepareDevice)
            val qlConnection = getOrCreateDevice(deviceId)

            // Get the remote device
            val remoteDevice = adapter.getRemoteDevice(deviceId)
            if (remoteDevice == null) {
                result.error("DEVICE_NOT_FOUND", "Device not found: $deviceId", null)
                return
            }

            Log.d(TAG, "Reconnecting to device: $deviceId")
            qlConnection.connect(remoteDevice)
            result.success(true)
        } catch (e: Exception) {
            Log.e(TAG, "Error reconnecting to device: ${e.message}")
            result.error("RECONNECT_ERROR", "Failed to reconnect: ${e.message}", null)
        }
    }

    @SuppressLint("MissingPermission")
    private fun startDeviceScan(call: MethodCall, result: MethodChannel.Result) {
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

        // Stop any ongoing scan
        try {
            bluetoothLeScanner?.stopScan(scanCallback)
        } catch (e: Exception) {
            Log.w(TAG, "No ongoing scan to stop: ${e.message}")
        }

        // Build scan filters
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
            sendScanEvent(BluetoothConnectionEventType.SCAN_STARTED)
            result.success(mapOf("scanning" to true, "message" to "Scan started"))

            // Auto-stop scan after 15 seconds
            mainHandler.postDelayed({
                try {
                    bluetoothLeScanner?.stopScan(scanCallback)
                    sendScanEvent(BluetoothConnectionEventType.SCAN_STOPPED)
                } catch (e: Exception) {
                    Log.w(TAG, "startDeviceScan: Error stopping scan: ${e.message}")
                }
            }, 15000)
        } catch (e: SecurityException) {
            Log.e(TAG, "startDeviceScan: FAILED - Security exception: ${e.message}")
            result.error("SECURITY_ERROR", "Missing scan permission: ${e.message}", null)
        } catch (e: Exception) {
            Log.e(TAG, "startDeviceScan: FAILED - Exception: ${e.message}")
            result.error("SCAN_ERROR", "Failed to start scan: ${e.message}", null)
        }
    }

    @SuppressLint("MissingPermission")
    private fun stopDeviceScan(result: MethodChannel.Result) {
        try {
            if (checkBluetoothPermissions()) {
                bluetoothLeScanner?.stopScan(scanCallback)
                sendScanEvent(BluetoothConnectionEventType.SCAN_STOPPED)
                result.success(mapOf("scanning" to false, "message" to "Scan stopped"))
            } else {
                result.error("PERMISSION_ERROR", "Bluetooth permissions not granted", null)
            }
        } catch (e: Exception) {
            Log.w(TAG, "Error stopping scan: ${e.message}")
            result.error("STOP_SCAN_ERROR", "Failed to stop scan: ${e.message}", null)
        }
    }

    private val scanCallback = object : ScanCallback() {
        @SuppressLint("MissingPermission")
        override fun onScanResult(callbackType: Int, result: ScanResult?) {
            result?.device?.let { device ->
                sendScanEvent(BluetoothConnectionEventType.DEVICE_FOUND, device)

                val isKnownDevice = knownPrimeDevicesMAC.contains(device.address)
                val isPrimeByName = device.name?.contains("Prime", ignoreCase = true) == true
                val isPrimeByService =
                    result.scanRecord?.serviceUuids?.any { it.uuid == PRIME_SERVICE_UUID } == true

                if (isKnownDevice || isPrimeByName || isPrimeByService) {
                    bluetoothLeScanner?.stopScan(this)
                    connectToDevice(device)
                } else {
                    Log.d(TAG, "onScanResult: No match, ignoring device")
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
            sendScanEvent(BluetoothConnectionEventType.SCAN_ERROR)
        }
    }

    @SuppressLint("MissingPermission")
    private fun connectToDevice(device: BluetoothDevice) {
        if (!checkBluetoothPermissions()) {
            Log.e(TAG, "connectToDevice: FAILED - Missing Bluetooth permissions")
            return
        }

        val deviceId = device.address

        // Get or create QLConnection instance (channels will already be registered)
        val qlConnection = getOrCreateDevice(deviceId)

        // Add to known devices
        knownPrimeDevicesMAC.add(deviceId)

        // Connect
        qlConnection.connect(device)
    }

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

    @SuppressLint("MissingPermission", "NewApi")
    private fun handleBondingStateChange(intent: Intent) {
        val device = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE, BluetoothDevice::class.java)
        } else {
            @Suppress("DEPRECATION") intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE)
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

        val deviceId = device.address
        val foundMAC = knownPrimeDevicesMAC.contains(deviceId)
        val foundName = device.alias?.contains("Prime", ignoreCase = true) ?: false

        if (!foundMAC && !foundName) {
            Log.w(TAG, "Non-Prime device bonding event ignored: ${device.name} ($deviceId)")
            return
        }


        // Route the bonding event to the appropriate QLConnection
        devices[deviceId]?.onBondingStateChanged(bondState)
    }

    private fun getBondStateString(bondState: Int): String {
        return when (bondState) {
            BluetoothDevice.BOND_NONE -> "BOND_NONE"
            BluetoothDevice.BOND_BONDING -> "BOND_BONDING"
            BluetoothDevice.BOND_BONDED -> "BOND_BONDED"
            else -> "UNKNOWN ($bondState)"
        }
    }

    @SuppressLint("MissingPermission")
    private fun sendScanEvent(type: BluetoothConnectionEventType, device: BluetoothDevice? = null) {
        scope.launch {
            scanEventSink?.success(
                mapOf(
                    "type" to type.toStringValue(),
                    "deviceId" to device?.address,
                    "deviceName" to device?.name
                )
            )
        }
    }


    private inner class ScanStreamHandler : EventChannel.StreamHandler {
        override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
            scanEventSink = events
        }

        override fun onCancel(arguments: Any?) {
            scanEventSink = null
        }
    }

    private fun checkBluetoothPermissions(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val hasConnectPermission = ActivityCompat.checkSelfPermission(
                context, Manifest.permission.BLUETOOTH_CONNECT
            ) == PackageManager.PERMISSION_GRANTED
            val hasScanPermission = ActivityCompat.checkSelfPermission(
                context, Manifest.permission.BLUETOOTH_SCAN
            ) == PackageManager.PERMISSION_GRANTED
            hasConnectPermission && hasScanPermission
        } else {
            val hasBluetoothPermission = ActivityCompat.checkSelfPermission(
                context, Manifest.permission.BLUETOOTH
            ) == PackageManager.PERMISSION_GRANTED
            val hasBluetoothAdminPermission = ActivityCompat.checkSelfPermission(
                context, Manifest.permission.BLUETOOTH_ADMIN
            ) == PackageManager.PERMISSION_GRANTED
            hasBluetoothPermission && hasBluetoothAdminPermission
        }
    }

    fun cleanup() {
        try {
            unregisterBondingReceiver()

            if (checkBluetoothPermissions()) {
                bluetoothLeScanner?.stopScan(scanCallback)
            }

            // Cleanup all devices
            devices.values.forEach { it.cleanup() }
            devices.clear()
        } catch (e: SecurityException) {
            Log.w(TAG, "Permission denied during cleanup: ${e.message}")
        } catch (e: Exception) {
            Log.w(TAG, "Error during cleanup: ${e.message}")
        }

        scanEventSink = null
        bondingReceiver = null
        Log.d(TAG, "BluetoothChannel cleaned up")
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
        if (lock.compareAndSet(false, true)) {
            result.success(value)
        }
    }

    fun error(code: String, message: String?, details: Any?) {
        if (lock.compareAndSet(false, true)) {
            result.error(code, message, details)
        }
    }

    fun notImplemented() {
        if (lock.compareAndSet(false, true)) {
            result.notImplemented()
        }
    }
}
