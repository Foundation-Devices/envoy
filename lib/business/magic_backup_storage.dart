// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:envoy/business/local_storage.dart';
import 'package:envoy/util/bug_report_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Owns Magic Backup seed storage and v1 compatibility paths.
class MagicBackupStorage {
  static const v1SecureSeedKey = "seed";
  static const v1SeedFileName = "local.secret";
  static const v1BackupTimestampFileName = "$v1SeedFileName.backup_timestamp";
  static const backupTimestampFileName = "magic_backup.backup_timestamp";

  static const _channel = MethodChannel('envoy/magic_backup');

  static final MagicBackupStorage _instance = MagicBackupStorage._internal();

  factory MagicBackupStorage() => _instance;

  MagicBackupStorage._internal();

  String? _androidRecoverySource;
  bool _androidSeedSourceLogged = false;
  bool _androidLaunchStatusLogged = false;
  bool _v1CleanupCompleted = false;

  Future<bool?> restoreIOSBackupEnabled({
    required bool fallbackBackupEnabled,
  }) async {
    if (!Platform.isIOS) {
      return null;
    }
    await _channel.invokeMethod<String>('read_seed', {
      'backup_enabled': fallbackBackupEnabled,
    });
    return getBackupEnabled();
  }

  Future<bool?> getBackupEnabled() async {
    if (Platform.isIOS || Platform.isAndroid) {
      return _channel.invokeMethod<bool>('get_backup_enabled');
    }
    return null;
  }

  Future<void> storeSeed(
    String seed, {
    required bool backupEnabled,
  }) async {
    if (Platform.isIOS) {
      await _channel.invokeMethod<bool>('write_seed', {
        'seed': seed,
        'backup_enabled': backupEnabled,
      });
      await removeV1Data(bestEffort: true);
    } else if (Platform.isAndroid) {
      await _writeAndroidSeed(seed, backupEnabled: backupEnabled);
      await removeV1Data(bestEffort: true);
    } else {
      if (backupEnabled) {
        await LocalStorage().saveFile(v1SeedFileName, seed);
      }
      await LocalStorage().saveSecure(v1SecureSeedKey, seed);
    }
    if (Platform.isIOS || Platform.isAndroid) {
      final readback = await _channel.invokeMethod<String>(
        'read_seed',
        Platform.isIOS ? {'backup_enabled': backupEnabled} : null,
      );
      if (readback != seed) {
        throw StateError("Magic Backup seed post-cleanup readback failed");
      }
    }
  }

  /// The only seed retrieval entry point.
  Future<String?> retrieveSeed({required bool backupEnabled}) async {
    String? seed;
    if (Platform.isIOS) {
      seed = await _channel.invokeMethod<String>('read_seed', {
        'backup_enabled': backupEnabled,
      });
      if (seed != null && !_v1CleanupCompleted) {
        await removeV1Data(bestEffort: true);
      }
    } else if (Platform.isAndroid) {
      seed = await _retrieveAndroidSeed(backupEnabled: backupEnabled);
    } else {
      seed = await LocalStorage().readSecure(v1SecureSeedKey);
      if (seed == null && await LocalStorage().fileExists(v1SeedFileName)) {
        seed = await LocalStorage().readFile(v1SeedFileName);
      }
    }
    return seed;
  }

  /// Upgrades Android v1 storage after Dart has loaded secure storage and the
  /// user's backup setting. An existing v2 record remains authoritative;
  /// otherwise the v1 secure slot wins over the v1 backup-eligible file.
  Future<String?> upgradeV1Seed({required bool backupEnabled}) async {
    if (!Platform.isAndroid) {
      return null;
    }

    await LocalStorage().deleteSecure("seed_cleared");
    final secureSeed = await LocalStorage().readSecure(v1SecureSeedKey);
    final currentSeed = await _channel.invokeMethod<String>('read_seed');
    final localFilePresent = await LocalStorage().fileExists(
      v1SeedFileName,
    );
    final localFileSeed =
        localFilePresent ? await LocalStorage().readFile(v1SeedFileName) : null;

    // With no v1 seed, avoid rewriting v2 and scheduling an Android backup on
    // every launch.
    if (secureSeed == null && localFileSeed == null) {
      _androidRecoverySource = null;
      return currentSeed;
    }

    final candidate = selectAndroidV1UpgradeCandidate(
      v1SecureSeed: secureSeed,
      currentSeed: currentSeed,
      v1FileSeed: localFileSeed,
    );
    if (candidate == null) {
      _androidRecoverySource = null;
      return null;
    }

    // Rewriting verifies the selected seed and records the restored user
    // setting before any v1 copy is removed or any backup is requested.
    await _writeAndroidSeed(candidate.seed, backupEnabled: backupEnabled);
    await removeV1Data();
    _androidRecoverySource = candidate.source;
    await EnvoyReport().log("Magic Backup", "copied seed from v1 to v2");
    return candidate.seed;
  }

  @visibleForTesting
  static ({String seed, String source})? selectAndroidV1UpgradeCandidate({
    required String? v1SecureSeed,
    required String? currentSeed,
    required String? v1FileSeed,
  }) {
    if (currentSeed != null) {
      return (seed: currentSeed, source: "v2");
    }
    if (v1SecureSeed != null) {
      return (seed: v1SecureSeed, source: "v1");
    }
    if (v1FileSeed != null) {
      return (seed: v1FileSeed, source: "v1");
    }
    return null;
  }

  /// Removes all obsolete v1 seed slots.
  Future<void> removeV1Data({bool bestEffort = false}) async {
    try {
      if (Platform.isIOS) {
        // iOS owns v1 cleanup natively so the Keychain deletion remains
        // restricted to Envoy's private v1 access group.
        await _channel.invokeMethod<bool>('remove_v1_data');
      } else if (Platform.isAndroid) {
        await _channel.invokeMethod<bool>('remove_v1_data');
        await LocalStorage().deleteSecure(v1SecureSeedKey);
      } else {
        await LocalStorage().deleteSecure(v1SecureSeedKey);
      }

      await LocalStorage().deleteFile(v1SeedFileName);
      await LocalStorage().deleteFile(v1BackupTimestampFileName);
      _v1CleanupCompleted = true;
    } on Exception {
      if (!bestEffort) {
        rethrow;
      }
      await EnvoyReport().log(
        "Magic Backup",
        "v1 seed cleanup will be retried",
      );
    }
  }

  Future<void> deleteAllSeedData() async {
    if (Platform.isIOS || Platform.isAndroid) {
      await _channel.invokeMethod<bool>('delete_seed');
    }
    await removeV1Data();
    await EnvoyReport().log("Magic Backup", "deleted seed data");
  }

  Future<void> disableBackup() async {
    if (Platform.isIOS || Platform.isAndroid) {
      await _channel.invokeMethod<bool>('set_backup_enabled', {
        'enabled': false,
      });
    }
    if (Platform.isIOS || Platform.isAndroid) {
      await removeV1Data();
    } else {
      await LocalStorage().deleteFile(v1SeedFileName);
      await LocalStorage().deleteFile(v1BackupTimestampFileName);
    }
    await EnvoyReport().log("Magic Backup", "disabled device backup");
  }

  Future<DateTime?> getLastBackupTimestamp() async {
    if (!await LocalStorage().fileExists(backupTimestampFileName)) {
      return null;
    }

    final timestampString =
        await LocalStorage().readFile(backupTimestampFileName);
    final timestamp = int.parse(
      timestampString.replaceAll(".", "").substring(0, 13),
    );
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  Future<String?> _retrieveAndroidSeed({required bool backupEnabled}) async {
    final logLaunchStatus = kDebugMode && !_androidLaunchStatusLogged;
    if (logLaunchStatus) {
      _androidLaunchStatusLogged = true;
      await _logAndroidStorageStatus("before read");
    }

    var seed = await _channel.invokeMethod<String>('read_seed');
    String? recoverySource;
    if (seed != null) {
      recoverySource = "v2";
      if (!_v1CleanupCompleted) {
        await removeV1Data(bestEffort: true);
      }
    } else {
      seed = await upgradeV1Seed(backupEnabled: backupEnabled);
      recoverySource = _androidRecoverySource;
    }

    if (logLaunchStatus) {
      await _logAndroidStorageStatus("after read");
    }
    if (seed != null && !_androidSeedSourceLogged) {
      _androidSeedSourceLogged = true;
      await EnvoyReport().log(
        "Magic Backup",
        "seed recovery source=${recoverySource ?? 'unknown'}",
      );
    }
    return seed;
  }

  /// Android write_seed
  // ├── Requires backup_enabled
  // ├── Encrypts with a StrongBox/TEE key
  // ├── Writes the encrypted record
  // ├── Stores backupEnabled in that record
  // └── Dart performs an additional readback verification
  Future<void> _writeAndroidSeed(
    String seed, {
    required bool backupEnabled,
  }) async {
    final written = await _channel.invokeMethod<bool>('write_seed', {
      'seed': seed,
      'backup_enabled': backupEnabled,
    });
    if (written != true) {
      throw StateError("Android Magic Backup seed write failed");
    }

    final readback = await _channel.invokeMethod<String>('read_seed');
    if (readback != seed) {
      throw StateError("Android Magic Backup seed readback failed");
    }
  }

  Future<void> _logAndroidStorageStatus(String phase) async {
    try {
      final status = await _channel.invokeMapMethod<String, dynamic>(
        'storage_status',
      );
      final v1SecurePresent = await LocalStorage().containsSecure(
        v1SecureSeedKey,
      );
      final v1Present = v1SecurePresent || status?['v1_local_file'] == true;
      final v2Present = status?['current_storage_ready'] == true;
      final v1State = v1Present ? "present" : "empty";
      final v2State = v2Present ? "present" : "empty";
      final backupEnabled = status?['backup_enabled'] == true;
      await EnvoyReport().log(
        "Magic Backup",
        "storage versions ($phase): "
            "v1=$v1State, v2=$v2State, "
            "backupEnabled=$backupEnabled",
      );
    } on Exception {
      await EnvoyReport().log(
        "Magic Backup",
        "storage versions unavailable",
      );
    }
  }
}
