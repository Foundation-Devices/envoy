// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

package com.foundationdevices.envoy

import android.app.backup.BackupAgent
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class MagicBackupTransportPolicyTest {
    @Test
    fun allowsSoftwareBackedKeyOnlyOnDebugEmulators() {
        assertTrue(allowSoftwareBackedMagicBackupKey(true, "ranchu"))
        assertTrue(allowSoftwareBackedMagicBackupKey(true, "goldfish"))
        assertFalse(allowSoftwareBackedMagicBackupKey(false, "ranchu"))
        assertFalse(allowSoftwareBackedMagicBackupKey(true, "physical-device"))
    }

    @Test
    fun rejectsTransportWithoutProtectedBackupFlags() {
        assertFalse(isProtectedMagicBackupTransport(0))
        assertFalse(isProtectedMagicBackupTransport(1 shl 20))
    }

    @Test
    fun acceptsClientSideEncryptedTransport() {
        assertTrue(
            isProtectedMagicBackupTransport(
                BackupAgent.FLAG_CLIENT_SIDE_ENCRYPTION_ENABLED
            )
        )
    }

    @Test
    fun acceptsDeviceToDeviceTransport() {
        assertTrue(
            isProtectedMagicBackupTransport(
                BackupAgent.FLAG_DEVICE_TO_DEVICE_TRANSFER
            )
        )
    }
}
