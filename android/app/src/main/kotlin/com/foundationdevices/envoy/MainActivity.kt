package com.foundationdevices.envoy

import android.app.Activity
import android.app.backup.BackupManager
import android.content.ComponentName
import android.content.Intent
import android.content.pm.verify.domain.DomainVerificationManager
import android.content.pm.verify.domain.DomainVerificationUserState
import android.os.Build
import android.os.Bundle
import android.os.Environment
import android.os.Handler
import android.os.PersistableBundle
import android.provider.DocumentsContract
import android.provider.Settings
import android.provider.Settings.ACTION_MANAGE_ALL_FILES_ACCESS_PERMISSION
import android.system.Os
import android.util.Log
import android.view.WindowManager
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
            if (!fullRoute.isNullOrEmpty()) {
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

                    // Get the file descriptor and fsync to make sure it's on the SD
                    val pfd = applicationContext.contentResolver.openFileDescriptor(uri, "w")
                    Os.fsync(pfd!!.fileDescriptor)

                    pfd.close()

                    // Boolean down the chute means success
                    Handler().postDelayed(
                        {
                            sdCardEventSink?.success(true)
                        },
                        1000
                    )
                }
            }
        } else if (requestCode == saveFileRequestCode && resultCode == Activity.RESULT_CANCELED) {
            Handler().postDelayed(
                {
                    sdCardEventSink?.success(false)
                },
                1000
            )
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
                    sdCard = paths.last().toPath().subpath(0, 2).toFile()
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

                "open_settings" -> {
                    try {
                        val intent = Intent()
                        intent.component = ComponentName(
                            "com.android.settings",
                            "com.android.settings.backup.UserBackupSettingsActivity"
                        )
                        startActivity(intent)
                    } catch (e: Exception) {
                        startActivity(Intent(Settings.ACTION_SETTINGS))
                    }
                    result.success(true)
                }

                "make_screen_secure" -> {
                    val secure = call.argument<Boolean>("secure") ?: false
                    if (secure) {
                        window.setFlags(
                            WindowManager.LayoutParams.FLAG_SECURE,
                            WindowManager.LayoutParams.FLAG_SECURE
                        );
                    } else {
                        window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
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