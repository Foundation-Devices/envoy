package com.foundationdevices.envoy

import android.app.backup.BackupAgentHelper
import android.app.backup.BackupDataInput
import android.app.backup.BackupDataOutput
import android.app.backup.FileBackupHelper
import android.os.ParcelFileDescriptor
import java.io.File

const val LOCAL_SECRET = "local.secret"
const val PRIME_SECRET = "prime.secret"

// A key to uniquely identify the set of backup data
const val SECRETS_BACKUP_KEY = "secrets"
const val PRIME_BACKUP_KEY = "prime"

class EnvoyBackupAgent : BackupAgentHelper() {
    override fun onCreate() {
        // Allocate a helper and add it to the backup agent
        FileBackupHelper(this, LOCAL_SECRET).also {
            addHelper(SECRETS_BACKUP_KEY, it)
        }
        // Allocate a helper and add it to the backup agent
        FileBackupHelper(this, PRIME_SECRET).also {
            addHelper(PRIME_BACKUP_KEY, it)
        }
    }

    override fun onBackup(
        oldState: ParcelFileDescriptor?,
        data: BackupDataOutput?,
        newState: ParcelFileDescriptor?
    ) {
        super.onBackup(oldState, data, newState)

        File(filesDir.absolutePath + "/$LOCAL_SECRET.backup_timestamp").writeText(
            System.currentTimeMillis().toString()
        )

        File(filesDir.absolutePath + "/$PRIME_SECRET.backup_timestamp").writeText(
            System.currentTimeMillis().toString()
        )
    }

    override fun onRestore(
        data: BackupDataInput?,
        appVersionCode: Int,
        newState: ParcelFileDescriptor?
    ) {
        super.onRestore(data, appVersionCode, newState)
    }
}