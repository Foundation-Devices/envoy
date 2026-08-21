// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

package com.foundationdevices.envoy

import android.app.backup.BackupAgent
import android.app.backup.BackupAgentHelper
import android.app.backup.BackupDataInput
import android.app.backup.BackupDataInputStream
import android.app.backup.BackupDataOutput
import android.app.backup.BackupHelper
import android.app.backup.FileBackupHelper
import android.content.Context
import android.os.ParcelFileDescriptor
import android.util.Log
import java.io.IOException
import java.nio.charset.StandardCharsets

const val PRIME_SECRET = "prime.secret"

private const val PRIME_BACKUP_KEY = "prime"
private const val MAGIC_BACKUP_KEY = "magic_backup_v2"
private const val MAGIC_BACKUP_SEED_ENTITY = "seed"
private const val MAX_BACKUP_SEED_BYTES = 4096
private const val BACKUP_LOG_TAG = "MagicBackup"

private fun recordBackupLog(context: Context, message: String) {
    if (BuildConfig.DEBUG) {
        Log.d(BACKUP_LOG_TAG, "Android BackupManager: $message")
    }
    NativeLogStream.log(context, "Magic Backup", "Android BackupManager: $message")
}

class EnvoyBackupAgent : BackupAgentHelper() {
    private lateinit var seedStore: MagicBackupSeedStore
    // Set again at the start of every backup.
    private var protectedTransport = false

    private fun backupLog(message: String) = recordBackupLog(this, message)

    override fun onCreate() {
        seedStore = MagicBackupSeedStore(this)
        backupLog("agent initialized")

        // Keep the old key so old backups can still restore.
        addHelper(
            MagicBackupV1Storage.BACKUP_HELPER_KEY,
            RestoreOnlyFileBackupHelper(
                this,
                MagicBackupV1Storage.SEED_FILE_NAME,
                 ::backupLog
            )
        )
        addHelper(
            PRIME_BACKUP_KEY,
            ProtectedFileBackupHelper(
                this,
                PRIME_SECRET,
                { protectedTransport },
                ::backupLog
            )
        )
        addHelper(
            MAGIC_BACKUP_KEY,
            MagicBackupSeedBackupHelper(seedStore, { protectedTransport }, ::backupLog)
        )
    }

    override fun onBackup(
        oldState: ParcelFileDescriptor?,
        data: BackupDataOutput?,
        newState: ParcelFileDescriptor?
    ) {
        if (data == null) {
            backupLog("backup skipped reason=missing_output")
            return
        }
        val transportFlags = data.transportFlags
        val clientSideEncrypted = (
            transportFlags and BackupAgent.FLAG_CLIENT_SIDE_ENCRYPTION_ENABLED
        ) != 0
        val deviceToDevice = (
            transportFlags and BackupAgent.FLAG_DEVICE_TO_DEVICE_TRANSFER
        ) != 0
        // Only encrypted cloud backup or phone-to-phone transfer is allowed.
        protectedTransport = isProtectedMagicBackupTransport(transportFlags)
        backupLog(
            "backup started protectedTransport=$protectedTransport " +
                "clientSideEncrypted=$clientSideEncrypted " +
                "deviceToDevice=$deviceToDevice"
        )

        // Unprotected transports only get delete records.
        super.onBackup(oldState, data, newState)

        if (protectedTransport &&
            seedStore.isBackupEnabled() &&
            seedStore.readSeed() != null
        ) {
            // The UI reads this to show the latest device backup time.
            writeTimestamp(CurrentMagicBackupStorage.BACKUP_TIMESTAMP_FILE_NAME)
        }
        if (protectedTransport) {
            writeTimestamp("$PRIME_SECRET.backup_timestamp")
        }
        backupLog("backup completed")
    }

    override fun onRestore(
        data: BackupDataInput?,
        appVersionCode: Int,
        newState: ParcelFileDescriptor?
    ) {
        // Helpers put each restored item back in its storage slot.
        backupLog("restore started appVersionCode=$appVersionCode")
        super.onRestore(data, appVersionCode, newState)
        backupLog("restore completed")
    }

    private fun writeTimestamp(name: String) {
        filesDir.resolve(name).writeText(System.currentTimeMillis().toString())
    }
}

internal fun isProtectedMagicBackupTransport(transportFlags: Int): Boolean {
    val permittedFlags = BackupAgent.FLAG_CLIENT_SIDE_ENCRYPTION_ENABLED or
        BackupAgent.FLAG_DEVICE_TO_DEVICE_TRANSFER
    return transportFlags and permittedFlags != 0
}

// Restores old local.secret backups.
private class RestoreOnlyFileBackupHelper(
    context: Context,
    private val fileName: String,
    private val log: (String) -> Unit
) : BackupHelper {
    private val restoreDelegate = FileBackupHelper(context, fileName)

    override fun performBackup(
        oldState: ParcelFileDescriptor?,
        data: BackupDataOutput,
        newState: ParcelFileDescriptor?
    ) {
        // Delete the old cloud entity instead of uploading v1 again.
        log("v1 seed entity action=delete")
        data.writeEntityHeader(fileName, -1)
    }

    override fun restoreEntity(data: BackupDataInputStream) {
        log("v1 seed entity action=restore")
        restoreDelegate.restoreEntity(data)
    }

    override fun writeNewStateDescription(newState: ParcelFileDescriptor?) = Unit
}

// Only backs up Prime data on a protected transport.
private class ProtectedFileBackupHelper(
    context: Context,
    private val fileName: String,
    private val isBackupAllowed: () -> Boolean,
    private val log: (String) -> Unit
) : BackupHelper {
    private val delegate = FileBackupHelper(context, fileName)

    override fun performBackup(
        oldState: ParcelFileDescriptor?,
        data: BackupDataOutput,
        newState: ParcelFileDescriptor?
    ) {
        if (isBackupAllowed()) {
            log("prime.secret action=export")
            delegate.performBackup(oldState, data, newState)
        } else {
            log("prime.secret action=delete reason=unprotected_transport")
            data.writeEntityHeader(fileName, -1)
        }
    }

    override fun restoreEntity(data: BackupDataInputStream) {
        log("prime.secret action=restore")
        delegate.restoreEntity(data)
    }

    override fun writeNewStateDescription(newState: ParcelFileDescriptor?) {
        if (isBackupAllowed()) {
            delegate.writeNewStateDescription(newState)
        }
    }
}

// Sends the seed through Android backup.
private class MagicBackupSeedBackupHelper(
    private val seedStore: MagicBackupSeedStore,
    private val isBackupAllowed: () -> Boolean,
    private val log: (String) -> Unit
) : BackupHelper {
    override fun performBackup(
        oldState: ParcelFileDescriptor?,
        data: BackupDataOutput,
        newState: ParcelFileDescriptor?
    ) {
        if (!isBackupAllowed()) {
            // A delete record also clears older copies from the transport.
            log("v2 seed entity action=delete reason=unprotected_transport")
            data.writeEntityHeader(MAGIC_BACKUP_SEED_ENTITY, -1)
            return
        }

        if (!seedStore.isBackupEnabled()) {
            log("v2 seed entity action=delete reason=backup_disabled")
            data.writeEntityHeader(MAGIC_BACKUP_SEED_ENTITY, -1)
            return
        }
        val seed = seedStore.readSeed()
        if (seed == null) {
            log("v2 seed entity action=delete reason=seed_unavailable")
            data.writeEntityHeader(MAGIC_BACKUP_SEED_ENTITY, -1)
            return
        }

        val bytes = seed.toByteArray(StandardCharsets.UTF_8)
        if (bytes.isEmpty() || bytes.size > MAX_BACKUP_SEED_BYTES) {
            throw IOException("Invalid Magic Backup seed length")
        }
        data.writeEntityHeader(MAGIC_BACKUP_SEED_ENTITY, bytes.size)
        data.writeEntityData(bytes, bytes.size)
        log("v2 seed entity action=export result=success")
    }

    override fun restoreEntity(data: BackupDataInputStream) {
        if (data.key != MAGIC_BACKUP_SEED_ENTITY) {
            log("v2 seed entity action=discard reason=unexpected_key")
            discardEntity(data)
            return
        }
        if (data.size() < 0) {
            seedStore.deleteSeed()
            log("v2 seed entity action=delete_from_restore")
            return
        }
        if (data.size() == 0 || data.size() > MAX_BACKUP_SEED_BYTES) {
            throw IOException("Invalid Magic Backup restore length")
        }

        val bytes = ByteArray(data.size())
        readEntityFully(data, bytes)
        // Keep backupEnabled true because this seed came from device backup.
        val seed = bytes.toString(StandardCharsets.UTF_8)
        if (!seed.toByteArray(StandardCharsets.UTF_8).contentEquals(bytes)) {
            throw IOException("Invalid Magic Backup restore encoding")
        }
        seedStore.writeSeed(seed, backupEnabled = true)
        if (seedStore.readSeed() != seed) {
            throw IOException("Magic Backup restore readback failed")
        }
        log("v2 seed entity action=restore result=success")
    }

    override fun writeNewStateDescription(newState: ParcelFileDescriptor?) = Unit

    private fun discardEntity(data: BackupDataInputStream) {
        if (data.size() <= 0) {
            return
        }
        readEntityFully(data, ByteArray(data.size()))
    }

    private fun readEntityFully(data: BackupDataInputStream, target: ByteArray) {
        var offset = 0
        while (offset < target.size) {
            val count = data.read(target, offset, target.size - offset)
            if (count <= 0) {
                throw IOException("Unexpected end of Magic Backup restore data")
            }
            offset += count
        }
    }
}
