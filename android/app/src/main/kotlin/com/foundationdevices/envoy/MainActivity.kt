package com.foundationdevices.envoy

import android.app.Activity
import android.app.backup.BackupManager
import android.content.Intent
import android.os.Build
import android.os.Environment
import android.provider.DocumentsContract
import android.provider.Settings
import android.provider.Settings.ACTION_MANAGE_ALL_FILES_ACCESS_PERMISSION
import androidx.annotation.RequiresApi
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.io.File


class MainActivity : FlutterFragmentActivity(), EventChannel.StreamHandler {
    private val CHANNEL = "envoy"
    private val SD_CARD_EVENT_CHANNEL = "sd_card_events"

    private var sdCardEventSink: EventChannel.EventSink? = null

    private var sdCard: File? = null
    private var firmware: File? = null

    private var directoryContentRequestCode = 21;
    private var saveFileRequestCode = 22;

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)

        // Handle deep links
        val data = intent.data
        if (data != null) {
            var fullRoute = data.path
            if (fullRoute != null && fullRoute.isNotEmpty()) {
                if (data.query != null && data.query!!.isNotEmpty()) {
                    fullRoute += "?" + data.query
                }

                if (data.fragment != null && data.fragment!!.isNotEmpty()) {
                    fullRoute += "#" + data.fragment
                }

                flutterEngine!!.navigationChannel.pushRoute(fullRoute)
            } else {
                flutterEngine!!.navigationChannel.pushRoute(data.toString())
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == directoryContentRequestCode && resultCode == Activity.RESULT_OK) {
            if (data != null) {
                val uri = data.data
                if (uri != null) {
                    sdCardEventSink?.success(uri.path)
                }
            }
        }

        if (requestCode == saveFileRequestCode && resultCode == Activity.RESULT_OK) {
            if (data != null) {
                val uri = data.data
                if (uri != null && firmware != null) {
                    val output = applicationContext.contentResolver.openOutputStream(uri)
                    output?.write(firmware!!.readBytes())
                    output?.flush()
                    output?.close()
                }
            }
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        sdCardEventSink = events
    }

    override fun onCancel(arguments: Any?) {
        print("Android SD stream cancelled.")
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, SD_CARD_EVENT_CHANNEL)
                .setStreamHandler(this)

        MethodChannel(
                flutterEngine.dartExecutor.binaryMessenger,
                CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "save_file" -> {
                    val file = (call.argument("from") as String?)?.let { File(it) }
                    firmware = file

                    val intent = Intent(Intent.ACTION_CREATE_DOCUMENT)
                    intent.addCategory(Intent.CATEGORY_OPENABLE)
                    intent.type = "application/firmware"

                    if (file != null) {
                        intent.putExtra(
                            Intent.EXTRA_TITLE,
                            file.name
                        )
                    }

                    //intent.putExtra(DocumentsContract.EXTRA_INITIAL_URI, call.argument("path") as String?)

                    startActivityForResult(intent, saveFileRequestCode)
                    result.success(true)
                }
                "data_changed" -> {
                    BackupManager(this).dataChanged()
                    result.success(true)
                }
                "show_settings" -> {
                    startActivity(Intent(Settings.ACTION_SETTINGS))
                    result.success(true)
                }
                "get_sd_card_path" -> {
                    val paths = getExternalFilesDirs(null)
                    // TODO: If there is only 1 path that means there is no SD?
                    sdCard = paths.last().toPath().subpath(0,2).toFile()
                    result.success(sdCard?.absolutePath)
                }
                "get_directory_content_permission" -> {
                    startActivityForResult(Intent(Intent.ACTION_OPEN_DOCUMENT_TREE).apply {
                        putExtra(DocumentsContract.EXTRA_INITIAL_URI, sdCard?.toURI())
                    }, directoryContentRequestCode)
                    result.success(true)
                }
                "get_manage_files_permission" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                        getManageAllFilesPermission()
                    }
                    result.success(true)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    @RequiresApi(Build.VERSION_CODES.R)
    fun getManageAllFilesPermission() {
        if (!Environment.isExternalStorageManager()) {
            startActivity(Intent(ACTION_MANAGE_ALL_FILES_ACCESS_PERMISSION))
        }
    }
}