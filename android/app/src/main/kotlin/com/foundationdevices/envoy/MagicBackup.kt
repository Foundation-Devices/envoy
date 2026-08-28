// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

package com.foundationdevices.envoy

import android.app.backup.BackupManager
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyInfo
import android.security.keystore.KeyProperties
import android.security.keystore.StrongBoxUnavailableException
import android.util.AtomicFile
import android.util.Log
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import java.io.DataInputStream
import java.io.DataOutputStream
import java.io.File
import java.io.IOException
import java.nio.charset.StandardCharsets
import java.security.GeneralSecurityException
import java.security.KeyStore
import java.security.ProviderException
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import javax.crypto.SecretKeyFactory
import javax.crypto.spec.GCMParameterSpec

// Kept for old backups.
internal object MagicBackupV1Storage {
    const val SEED_FILE_NAME = "local.secret"
    const val SEED_BACKUP_TIMESTAMP_FILE_NAME = "$SEED_FILE_NAME.backup_timestamp"
    const val BACKUP_HELPER_KEY = "secrets"
}

internal object CurrentMagicBackupStorage {
    // Updated after Android finishes a seed backup.
    const val BACKUP_TIMESTAMP_FILE_NAME = "magic_backup.backup_timestamp"
}

// Flutter calls the seed storage through this channel.
object MagicBackup {
    private const val CHANNEL_NAME = "envoy/magic_backup"
    private const val TAG = "MagicBackup"
    private const val OBSOLETE_SEED_CLEARED_FILE_NAME = "magic_backup.seed_cleared"

    fun register(context: Context, messenger: BinaryMessenger) {
        val applicationContext = context.applicationContext
        // This marker is not used anymore.
        File(applicationContext.noBackupFilesDir, OBSOLETE_SEED_CLEARED_FILE_NAME).delete()
        val seedStore = MagicBackupSeedStore(applicationContext)

        MethodChannel(messenger, CHANNEL_NAME).setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "read_seed" -> {
                        result.success(seedStore.readSeed())
                    }

                    "write_seed" -> {
                        val seed = call.argument<String>("seed")
                        if (seed.isNullOrBlank()) {
                            result.error(
                                "INVALID_SEED",
                                "A non-empty seed is required",
                                null
                            )
                            return@setMethodCallHandler
                        }

                        val backupEnabled = call.argument<Boolean>("backup_enabled") ?: false
                        seedStore.writeSeed(seed, backupEnabled)
                        check(seedStore.readSeed() == seed) {
                            "Hardware-backed seed readback failed"
                        }
                        requestBackup(applicationContext, "v2_seed_written")
                        result.success(true)
                    }

                    "storage_status" -> result.success(seedStore.storageStatus())

                    "get_backup_enabled" -> result.success(seedStore.getBackupEnabled())

                    "remove_v1_data" -> {
                        seedStore.removeV1Data()
                        requestBackup(applicationContext, "v1_data_removed")
                        result.success(true)
                    }

                    "delete_seed" -> {
                        seedStore.deleteSeed()
                        requestBackup(applicationContext, "v2_seed_deleted")
                        result.success(true)
                    }

                    "set_backup_enabled" -> {
                        val enabled = call.argument<Boolean>("enabled") ?: false
                        seedStore.setBackupEnabled(enabled)
                        requestBackup(
                            applicationContext,
                            "v2_backup_setting_changed enabled=$enabled"
                        )
                        result.success(true)
                    }

                    else -> result.notImplemented()
                }
            } catch (error: Exception) {
                if (BuildConfig.DEBUG) {
                    Log.e(TAG, "Magic Backup operation failed: ${error.javaClass.simpleName}")
                }
                result.error(
                    "MAGIC_BACKUP_STORAGE_ERROR",
                    "Android Magic Backup storage operation failed",
                    null
                )
            }
        }
    }

    private fun requestBackup(context: Context, reason: String) {
        // Let Android know our backup data changed.
        BackupManager(context).dataChanged()
        if (BuildConfig.DEBUG) {
            Log.d(TAG, "Android BackupManager dataChanged reason=$reason")
        }
    }
}

// The local seed is encrypted with an Android Keystore key.
internal class MagicBackupSeedStore(private val context: Context) {
    private data class EncryptedSeedRecord(
        val backupEnabled: Boolean,
        val initializationVector: ByteArray,
        val ciphertext: ByteArray
    )

    private val encryptedSeedFile = AtomicFile(
        File(context.noBackupFilesDir, ENCRYPTED_SEED_FILE_NAME)
    )

    @Synchronized
    fun writeSeed(seed: String, backupEnabled: Boolean) {
        // Seed and backup setting stay in the same record.
        val plaintext = validatedSeedBytes(seed)
        val cipher = Cipher.getInstance(TRANSFORMATION)
        cipher.init(Cipher.ENCRYPT_MODE, getOrCreateHardwareBackedKey())
        cipher.updateAAD(ADDITIONAL_AUTHENTICATED_DATA)

        writeRecord(
            EncryptedSeedRecord(
                backupEnabled = backupEnabled,
                initializationVector = cipher.iv,
                ciphertext = cipher.doFinal(plaintext)
            )
        )
    }

    @Synchronized
    fun readSeed(): String? {
        val record = readRecord() ?: return null
        // The key stays inside Android Keystore.
        val key = existingKey()
            ?: throw GeneralSecurityException("Magic Backup hardware key is unavailable")
        val cipher = Cipher.getInstance(TRANSFORMATION)
        cipher.init(
            Cipher.DECRYPT_MODE,
            key,
            GCMParameterSpec(GCM_TAG_LENGTH_BITS, record.initializationVector)
        )
        cipher.updateAAD(ADDITIONAL_AUTHENTICATED_DATA)

        val plaintext = cipher.doFinal(record.ciphertext)
        if (plaintext.isEmpty() || plaintext.size > MAX_SEED_BYTES) {
            throw GeneralSecurityException("Invalid Magic Backup seed length")
        }
        val seed = plaintext.toString(StandardCharsets.UTF_8)
        if (!seed.toByteArray(StandardCharsets.UTF_8).contentEquals(plaintext)) {
            throw GeneralSecurityException("Invalid Magic Backup seed encoding")
        }
        return seed
    }

    @Synchronized
    fun isBackupEnabled(): Boolean = readRecord()?.backupEnabled == true

    @Synchronized
    fun getBackupEnabled(): Boolean? = readRecord()?.backupEnabled

    @Synchronized
    fun setBackupEnabled(enabled: Boolean) {
        val record = readRecord() ?: return
        writeRecord(record.copy(backupEnabled = enabled))
    }

    @Synchronized
    fun storageStatus(): Map<String, Any> {
        val record = readRecord()
        val hardwareKeyPresent = existingKey() != null
        return mapOf(
            "current_storage_ready" to (record != null && hardwareKeyPresent),
            "encrypted_record" to (record != null),
            "hardware_key" to hardwareKeyPresent,
            "v1_local_file" to v1SeedFile.exists(),
            "backup_enabled" to (record?.backupEnabled == true)
        )
    }

    @Synchronized
    fun deleteSeed() {
        encryptedSeedFile.delete()
        currentBackupTimestampFile.delete()
        val keyStore = keyStore()
        if (keyStore.containsAlias(KEY_ALIAS)) {
            keyStore.deleteEntry(KEY_ALIAS)
        }
    }

    @Synchronized
    fun removeV1Data() {
        // Remove the old plaintext files.
        for (file in listOf(v1SeedFile, v1BackupTimestampFile)) {
            if (file.exists() && !file.delete()) {
                throw IOException("Unable to delete v1 Magic Backup file")
            }
        }
    }

    private fun validatedSeedBytes(seed: String): ByteArray {
        val bytes = seed.toByteArray(StandardCharsets.UTF_8)
        require(seed.isNotBlank() && bytes.size <= MAX_SEED_BYTES) {
            "Invalid Magic Backup seed"
        }
        return bytes
    }

    private val v1SeedFile = File(
        context.filesDir,
        MagicBackupV1Storage.SEED_FILE_NAME
    )

    private val v1BackupTimestampFile = File(
        context.filesDir,
        MagicBackupV1Storage.SEED_BACKUP_TIMESTAMP_FILE_NAME
    )

    private val currentBackupTimestampFile = File(
        context.filesDir,
        CurrentMagicBackupStorage.BACKUP_TIMESTAMP_FILE_NAME
    )

    private fun writeRecord(record: EncryptedSeedRecord) {
        require(
            record.initializationVector.isNotEmpty() &&
                record.initializationVector.size <= MAX_IV_BYTES &&
                record.ciphertext.isNotEmpty() &&
                record.ciphertext.size <= MAX_CIPHERTEXT_BYTES
        ) {
            "Invalid encrypted Magic Backup record"
        }

        // AtomicFile avoids leaving half a record behind.
        val output = encryptedSeedFile.startWrite()
        try {
            DataOutputStream(output).apply {
                writeInt(RECORD_VERSION)
                writeBoolean(record.backupEnabled)
                writeInt(record.initializationVector.size)
                write(record.initializationVector)
                writeInt(record.ciphertext.size)
                write(record.ciphertext)
                flush()
            }
            encryptedSeedFile.finishWrite(output)
        } catch (error: Exception) {
            encryptedSeedFile.failWrite(output)
            throw error
        }
    }

    private fun readRecord(): EncryptedSeedRecord? {
        if (!encryptedSeedFile.baseFile.exists()) {
            return null
        }

        return DataInputStream(encryptedSeedFile.openRead()).use { input ->
            val version = input.readInt()
            if (version != RECORD_VERSION) {
                throw IOException("Unsupported Magic Backup record version")
            }
            val backupEnabled = input.readBoolean()
            val initializationVector = readBoundedBytes(input, MAX_IV_BYTES)
            val ciphertext = readBoundedBytes(input, MAX_CIPHERTEXT_BYTES)
            if (input.read() != -1) {
                throw IOException("Unexpected trailing Magic Backup data")
            }
            EncryptedSeedRecord(backupEnabled, initializationVector, ciphertext)
        }
    }

    private fun readBoundedBytes(input: DataInputStream, maximumSize: Int): ByteArray {
        val size = input.readInt()
        if (size <= 0 || size > maximumSize) {
            throw IOException("Invalid Magic Backup record field length")
        }
        return ByteArray(size).also(input::readFully)
    }

    private fun getOrCreateHardwareBackedKey(): SecretKey {
        existingKey()?.let { key ->
            verifyHardwareBacked(key)
            return key
        }

        // Try StrongBox first, then fall back to the TEE.
        val strongBoxAvailable = context.packageManager.hasSystemFeature(
            PackageManager.FEATURE_STRONGBOX_KEYSTORE
        )
        if (strongBoxAvailable) {
            try {
                return generateKey(strongBoxBacked = true).also(::verifyHardwareBacked)
            } catch (error: Exception) {
                if (error !is StrongBoxUnavailableException && error !is ProviderException) {
                    throw error
                }
                keyStore().deleteEntry(KEY_ALIAS)
                if (BuildConfig.DEBUG) {
                    Log.w(TAG, "StrongBox unavailable; falling back to the TEE")
                }
            }
        }

        return generateKey(strongBoxBacked = false).also(::verifyHardwareBacked)
    }

    private fun generateKey(strongBoxBacked: Boolean): SecretKey {
        val keyGenerator = KeyGenerator.getInstance(
            KeyProperties.KEY_ALGORITHM_AES,
            ANDROID_KEY_STORE
        )
        val specification = KeyGenParameterSpec.Builder(
            KEY_ALIAS,
            KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT
        )
            .setKeySize(AES_KEY_SIZE_BITS)
            .setBlockModes(KeyProperties.BLOCK_MODE_GCM)
            .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE)
            .setRandomizedEncryptionRequired(true)
            .apply {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P && strongBoxBacked) {
                    setIsStrongBoxBacked(true)
                }
            }
            .build()
        keyGenerator.init(specification)
        return keyGenerator.generateKey()
    }

    private fun verifyHardwareBacked(key: SecretKey) {
        val keyFactory = SecretKeyFactory.getInstance(key.algorithm, ANDROID_KEY_STORE)
        val keyInfo = keyFactory.getKeySpec(key, KeyInfo::class.java) as KeyInfo
        val hardwareBacked = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            keyInfo.securityLevel == KeyProperties.SECURITY_LEVEL_STRONGBOX ||
                keyInfo.securityLevel == KeyProperties.SECURITY_LEVEL_TRUSTED_ENVIRONMENT
        } else {
            keyInfo.isInsideSecureHardware()
        }
        // Do not keep a software-only key.
        if (!hardwareBacked) {
            keyStore().deleteEntry(KEY_ALIAS)
            throw GeneralSecurityException("Magic Backup key is not hardware-backed")
        }
    }

    private fun existingKey(): SecretKey? = keyStore().getKey(KEY_ALIAS, null) as? SecretKey

    private fun keyStore(): KeyStore = KeyStore.getInstance(ANDROID_KEY_STORE).apply {
        load(null)
    }

    private companion object {
        const val TAG = "MagicBackup"
        const val ANDROID_KEY_STORE = "AndroidKeyStore"
        const val KEY_ALIAS = "com.foundationdevices.envoy.magic_backup.seed"
        const val ENCRYPTED_SEED_FILE_NAME = "magic_backup.bin"
        const val TRANSFORMATION = "AES/GCM/NoPadding"
        const val RECORD_VERSION = 1
        const val AES_KEY_SIZE_BITS = 256
        const val GCM_TAG_LENGTH_BITS = 128
        const val MAX_SEED_BYTES = 4096
        const val MAX_IV_BYTES = 32
        const val MAX_CIPHERTEXT_BYTES = MAX_SEED_BYTES + 32
        val ADDITIONAL_AUTHENTICATED_DATA =
            "com.foundationdevices.envoy.magic_backup.seed.v1"
                .toByteArray(StandardCharsets.UTF_8)
    }
}
