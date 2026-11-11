// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:ngwallet/ngwallet.dart';

/// A backup was found, but its accounts could not be completely restored.
class AccountRestoreException implements Exception {
  /// True when a hot wallet exists despite the failure; callers offer to
  /// continue with it. Cold accounts can predate the restore and don't count.
  final bool anyRestored;

  const AccountRestoreException({this.anyRestored = false});
}

/// Attempts every account and reports partial recovery to the caller.
Future<bool> restoreAccountBackups({
  required Iterable<NgAccountBackup> backups,
  required Future<void> Function(NgAccountBackup) restore,
  required void Function(Object, StackTrace) onError,
}) async {
  var complete = true;
  for (final backup in backups) {
    try {
      await restore(backup);
    } catch (error, stack) {
      complete = false;
      onError(error, stack);
    }
  }
  return complete;
}

/// Restores metadata without reopening a wallet already created from its seed.
/// Returns the matching open handler, or null when the caller still needs to
/// restore the wallet itself.
Future<EnvoyAccountHandler?> restoreExistingAccountMetadata({
  required Iterable<EnvoyAccountHandler> handlers,
  required String directoryPath,
  required NgAccountBackup backup,
}) async {
  for (final handler in handlers) {
    if (handler.getDirectoryPath() != directoryPath) continue;

    await handler.migrateMeta(
      notes: backup.notes,
      tags: backup.tags,
      doNotSpend: backup.doNotSpend,
    );
    // migrateMeta writes storage but does not publish the updated account,
    // and sendUpdate is a no-op while nothing subscribes to the stream, so
    // the caller must refresh any state it has cached from this handler.
    await handler.sendUpdate();
    return handler;
  }
  return null;
}
