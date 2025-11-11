package com.foundationdevices.envoy

/**
 * Represents different types of BLE connection events
 */
enum class BluetoothConnectionEventType {
    DEVICE_CONNECTED,
    DEVICE_DISCONNECTED,
    DEVICE_FOUND,
    SCAN_STARTED,
    SCAN_STOPPED,
    SCAN_ERROR,
    CONNECTION_ATTEMPT,
    CONNECTION_ERROR;

    /**
     * Convert enum to string value for platform channel communication
     */
    fun toStringValue(): String {
        return when (this) {
            DEVICE_CONNECTED -> "device_connected"
            DEVICE_DISCONNECTED -> "device_disconnected"
            DEVICE_FOUND -> "device_found"
            SCAN_STARTED -> "scan_started"
            SCAN_STOPPED -> "scan_stopped"
            SCAN_ERROR -> "scan_error"
            CONNECTION_ATTEMPT -> "connection_attempt"
            CONNECTION_ERROR -> "connection_error"
        }
    }
}

/**
 * Kotlin data class representing BLE connection status updates from native platforms
 */
data class BluetoothConnectionStatus(
    val type: BluetoothConnectionEventType? = null,
    val connected: Boolean,
    val bonded: Boolean,
    val peripheralId: String? = null,
    val peripheralName: String? = null,
    val error: String? = null,
    val rssi: Int? = null
) {
    /**
     * Convert BluetoothConnectionStatus to Map for platform channel communication
     */
    fun toMap(): Map<String, Any?> {
        return mapOf(
            "type" to type?.toStringValue(),
            "connected" to connected,
            "peripheralId" to peripheralId,
            "peripheralName" to peripheralName,
            "error" to error,
            "bonded" to bonded,
            "rssi" to rssi
        )
    }

    override fun toString(): String {
        val errorInfo = if (error != null) ", error: $error" else ""
        return "BluetoothConnectionStatus{type: $type, connected: $connected , bonded ${bonded}, error: $errorInfo}"
    }
}
