package com.foundationdevices.envoy.ble

import android.annotation.SuppressLint
import android.bluetooth.BluetoothGatt
import android.bluetooth.BluetoothGattCharacteristic
import android.bluetooth.BluetoothStatusCodes
import android.os.Build
import android.util.Log
import kotlinx.coroutines.CompletableDeferred
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.channels.Channel
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import kotlin.time.measureTimedValue


private const val TAG = "BleQueue"

// Minimum time between write operations to respect BLE throughput limits. ( out of oder issue on prime)
// To stay under this limit, we need to ensure: time_per_write >= packet_size / 80kBps
// For a 240-byte packet: 240 bytes / 80 bytes/ms = 3ms (247 mtu)
const val MIN_WRITE_CYCLE_MS = 3L

@OptIn(ExperimentalCoroutinesApi::class)
class BleWriteQueue(
    private val gatt: BluetoothGatt,
    private val characteristic: BluetoothGattCharacteristic,
    externalScope: CoroutineScope
) {
    private val queue = Channel<WriteRequest>(Channel.UNLIMITED)
    private var continuation: CompletableDeferred<Boolean>? = null
    private var isActive = true

    init {
        externalScope.launch {
            for (req in queue) {
                if (!isActive) {
                    Log.w(TAG, "Queue inactive, failing write")
                    req.result.complete(false)
                    continue
                }

                val (ok, duration) = measureTimedValue {
                    performWrite(req.data)
                }
                if (!ok) {
                    Log.e(TAG, "Write failed, clearing")
                    isActive = false
                    req.result.complete(false)
                    while (!queue.isEmpty) {
                        queue.tryReceive().getOrNull()?.result?.complete(false)
                    }
                    break
                } else {
                    val durationMs = duration.inWholeMilliseconds
                    // Throttle writes to respect BLE throughput limits (~80 kBps).
                    // If the write completed faster than MIN_WRITE_CYCLE_MS, we delay
                    if (durationMs < MIN_WRITE_CYCLE_MS) {
                        delay(MIN_WRITE_CYCLE_MS - durationMs)
                    }
                }
                req.result.complete(true)
            }
        }
    }

    fun restart() {
        if (!isActive) {
            Log.i(TAG, "Restarting write queue")
            isActive = true
            continuation = null
            clearQueue()
        }
    }

    suspend fun enqueue(data: ByteArray): Boolean {
        if (!isActive) {
            Log.w(TAG, "Queue inactive, rejecting write")
            return false
        }
        val result = CompletableDeferred<Boolean>()
        queue.send(WriteRequest(data.hashCode(), data, result))
        return result.await()
    }

    fun onCharacteristicWrite(status: Int) {
        val current = continuation
        continuation = null
        current?.complete(status == BluetoothGatt.GATT_SUCCESS)
    }

    fun cancel() {
        continuation?.complete(false)
        continuation = null
        queue.cancel()
        Log.i(TAG, "Write queue cancelled")
    }

    @SuppressLint("MissingPermission")
    private suspend fun performWrite(data: ByteArray): Boolean {
        if (!isActive) {
            Log.w(TAG, "Queue inactive during performWrite")
            return false
        }

        val deferred = CompletableDeferred<Boolean>()
        continuation = deferred

        val writeType =
            if (characteristic.properties and BluetoothGattCharacteristic.PROPERTY_WRITE_NO_RESPONSE != 0) {
                BluetoothGattCharacteristic.WRITE_TYPE_NO_RESPONSE
            } else {
                BluetoothGattCharacteristic.WRITE_TYPE_DEFAULT
            }

        val writeSuccess = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            val success = gatt.writeCharacteristic(characteristic, data, writeType)
            if (success != BluetoothStatusCodes.SUCCESS) {
                Log.e(TAG, "Error writeCharacteristic: $success")
            }
            success == BluetoothStatusCodes.SUCCESS
        } else {
            @Suppress("DEPRECATION")
            characteristic.writeType = writeType
            @Suppress("DEPRECATION")
            characteristic.value = data
            @Suppress("DEPRECATION")
            gatt.writeCharacteristic(characteristic)
        }

        if (!writeSuccess) {
            continuation = null
            isActive = false
            return false
        }
        val result = deferred.await()
        return result
    }

    fun clearQueue() {
        Log.i(TAG, "Clearing write queue")
        while (!queue.isEmpty) {
            queue.tryReceive().getOrNull()?.result?.complete(false)
        }
    }

    private data class WriteRequest(
        val id: Int,
        val data: ByteArray,
        val result: CompletableDeferred<Boolean>
    ) {
        override fun equals(other: Any?): Boolean {
            if (this === other) return true
            if (javaClass != other?.javaClass) return false

            other as WriteRequest

            if (!data.contentEquals(other.data)) return false
            if (result != other.result) return false

            return true
        }

        override fun hashCode(): Int {
            var result1 = data.contentHashCode()
            result1 = 31 * result1 + result.hashCode()
            return result1
        }
    }
}
