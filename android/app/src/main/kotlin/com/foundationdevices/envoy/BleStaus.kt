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
    CONNECTION_ERROR,
    BONDING_STARTED,
    BONDING_IN_PROGRESS,
    BONDING_ERROR,
    ALREADY_BONDED;

    companion object {
        /**
         * Parse event type string to enum
         */
        fun fromString(typeValue: String?): BluetoothConnectionEventType? {
            return when (typeValue) {
                "device_connected" -> DEVICE_CONNECTED
                "device_disconnected" -> DEVICE_DISCONNECTED
                "device_found" -> DEVICE_FOUND
                "scan_started" -> SCAN_STARTED
                "scan_stopped" -> SCAN_STOPPED
                "scan_error" -> SCAN_ERROR
                "connection_attempt" -> CONNECTION_ATTEMPT
                "connection_error" -> CONNECTION_ERROR
                "bonding_started" -> BONDING_STARTED
                "bonding_in_progress" -> BONDING_IN_PROGRESS
                "bonding_error" -> BONDING_ERROR
                "already_bonded" -> ALREADY_BONDED
                else -> null
            }
        }
    }

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
            BONDING_STARTED -> "bonding_started"
            BONDING_IN_PROGRESS -> "bonding_in_progress"
            BONDING_ERROR -> "bonding_error"
            ALREADY_BONDED -> "already_bonded"
        }
    }
}

/**
 * Kotlin data class representing BLE connection status updates from native platforms
 */
data class BluetoothConnectionStatus(
    val type: BluetoothConnectionEventType? = null,
    val connected: Boolean,
    val peripheralId: String? = null,
    val peripheralName: String? = null,
    val error: String? = null,
    val rssi: Int? = null
) {
    companion object {
        /**
         * Create BluetoothConnectionStatus from platform event data
         */
        fun fromMap(map: Map<String, Any?>): BluetoothConnectionStatus {
            return BluetoothConnectionStatus(
                type = BluetoothConnectionEventType.fromString(map["type"]?.toString()),
                connected = map["connected"] as? Boolean ?: false,
                peripheralId = map["peripheralId"]?.toString(),
                peripheralName = map["peripheralName"]?.toString(),
                error = map["error"]?.toString(),
                rssi = map["rssi"] as? Int
            )
        }
    } 

    
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
            "rssi" to rssi
        )
    }

    override fun toString(): String {
        val errorInfo = if (error != null) ", error: $error" else ""
        return "BluetoothConnectionStatus{type: $type, connected: $connected, error: $errorInfo}"
    }
}