// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

package com.foundationdevices.envoy

import android.content.Context
import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import org.json.JSONArray
import org.json.JSONObject

// Sends native logs to Dart. Do not put secrets here.
object NativeLogStream : EventChannel.StreamHandler {
    private const val CHANNEL_NAME = "envoy/native_logs"
    private const val PREFERENCES_NAME = "native_log_stream"
    private const val PENDING_EVENTS_KEY = "pending_events"
    private const val MAX_PENDING_EVENTS = 100
    private const val MAX_CATEGORY_LENGTH = 128
    private const val MAX_MESSAGE_LENGTH = 1024

    private val mainHandler = Handler(Looper.getMainLooper())
    private var applicationContext: Context? = null
    private var eventSink: EventChannel.EventSink? = null

    fun register(context: Context, messenger: BinaryMessenger) {
        applicationContext = context.applicationContext
        EventChannel(messenger, CHANNEL_NAME).setStreamHandler(this)
    }

    fun log(context: Context, category: String, message: String) {
        append(
            context.applicationContext,
            mapOf(
                "category" to category.take(MAX_CATEGORY_LENGTH),
                "message" to message.take(MAX_MESSAGE_LENGTH)
            )
        )
        mainHandler.post(::publishPendingEvents)
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        if (events == null) {
            return
        }
        eventSink = events
        publishPendingEvents()
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    @Synchronized
    private fun append(context: Context, event: Map<String, String>) {
        // BackupAgent can log before Dart is running.
        val preferences = context.getSharedPreferences(PREFERENCES_NAME, Context.MODE_PRIVATE)
        val events = decode(preferences.getString(PENDING_EVENTS_KEY, null)).toMutableList()
        events.add(event)
        val boundedEvents = events.takeLast(MAX_PENDING_EVENTS)
        val encoded = JSONArray().apply {
            boundedEvents.forEach { pendingEvent ->
                put(JSONObject(pendingEvent))
            }
        }
        preferences.edit().putString(PENDING_EVENTS_KEY, encoded.toString()).commit()
    }

    @Synchronized
    private fun publishPendingEvents() {
        val context = applicationContext ?: return
        val sink = eventSink ?: return
        val preferences = context.getSharedPreferences(PREFERENCES_NAME, Context.MODE_PRIVATE)
        val events = decode(preferences.getString(PENDING_EVENTS_KEY, null))
        if (events.isEmpty()) {
            return
        }
        // Send each event once, then clear the queue.
        events.forEach(sink::success)
        preferences.edit().remove(PENDING_EVENTS_KEY).commit()
    }

    private fun decode(encoded: String?): List<Map<String, String>> {
        if (encoded.isNullOrBlank()) {
            return emptyList()
        }
        return try {
            val array = JSONArray(encoded)
            List(array.length()) { index ->
                val event = array.getJSONObject(index)
                mapOf(
                    "category" to event.getString("category"),
                    "message" to event.getString("message")
                )
            }
        } catch (_: Exception) {
            emptyList()
        }
    }
}
