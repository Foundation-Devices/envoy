// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

package com.foundationdevices.envoy

import android.content.ContentProvider
import android.content.ContentValues
import android.content.UriMatcher
import android.database.Cursor
import android.database.MatrixCursor
import android.net.Uri
import java.io.File

class EnvoyDataProvider : ContentProvider() {

    companion object {
        const val AUTHORITY = "com.foundationdevices.envoy.provider"
        private const val PATH_SHARD = "link"
        private const val CODE_SHARD = 1

        val SHARD_URI: Uri = Uri.parse("content://$AUTHORITY/$PATH_SHARD")

        private val uriMatcher = UriMatcher(UriMatcher.NO_MATCH).apply {
            addURI(AUTHORITY, PATH_SHARD, CODE_SHARD)
        }
    }

    override fun onCreate(): Boolean = true

    override fun query(
        uri: Uri,
        projection: Array<out String>?,
        selection: String?,
        selectionArgs: Array<out String>?,
        sortOrder: String?
    ): Cursor? {
        if (uriMatcher.match(uri) != CODE_SHARD) return null
        val file = File(context!!.filesDir, "prime.secret")
        if (!file.exists()) return null
        val bytes = file.readBytes()
        val cursor = MatrixCursor(arrayOf("data"))
        cursor.addRow(arrayOf(bytes))
        return cursor
    }

    override fun getType(uri: Uri): String? = null
    override fun insert(uri: Uri, values: ContentValues?): Uri? = null
    override fun delete(uri: Uri, selection: String?, selectionArgs: Array<out String>?): Int = 0
    override fun update(uri: Uri, values: ContentValues?, selection: String?, selectionArgs: Array<out String>?): Int = 0
}
