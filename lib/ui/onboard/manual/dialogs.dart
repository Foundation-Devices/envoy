// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:envoy/business/envoy_seed.dart';
import 'package:envoy/business/restore_account_metadata.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/components/pop_up.dart';
import 'package:envoy/ui/onboard/wallet_setup_success.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

Future showRestoreFailedDialog(
  BuildContext context, {
  bool accountRestoreFailed = false,
  Function(BuildContext context)? onContinueWithRestored,
}) async {
  // When some accounts were recovered before the failure, the primary
  // action continues with them so they are not left unreachable.
  await showEnvoyPopUp(
    context,
    accountRestoreFailed
        ? S().menu_toast_unexpectedError
        : S().manual_setup_import_backup_fails_modal_subheading,
    S().component_continue,
    onContinueWithRestored ??
        (context) {
          Navigator.pop(context);
        },
    title: accountRestoreFailed
        ? S().magic_setup_recovery_fail_heading
        : S().manual_setup_import_backup_fails_modal_heading,
    secondaryButtonLabel:
        onContinueWithRestored != null ? S().component_back : null,
    onSecondaryButtonTap: onContinueWithRestored != null
        ? (context) {
            Navigator.pop(context);
          }
        : null,
    dismissible: false,
    showCloseButton: false,
    typeOfMessage: PopUpState.warning,
    icon: EnvoyIcons.alert,
  );
}

Future<bool> openBackupFile(
  BuildContext buildContext, {
  String? seed,
  String? passphrase,
}) async {
  var success = false;
  final file = await openFile();
  if (file != null) {
    try {
      success = await EnvoySeed().restoreData(
        filePath: file.path,
        seed: seed,
        passphrase: passphrase,
      );
    } on AccountRestoreException {
      // Callers must distinguish a found-but-unrestorable backup from a
      // simply unreadable file.
      rethrow;
    } catch (e) {
      success = false;
    }
  }
  return success;
}

Future<void> openMaestroBackupFile(BuildContext buildContext) async {
  final navigator = Navigator.of(buildContext);
  final context = buildContext;

  String path = 'assets/maestro_backup.mla.txt';

  var success = false;
  var seed = await EnvoySeed().get();

  try {
    final byteData = await rootBundle.load(path);
    final bytes = byteData.buffer.asUint8List();

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/maestro_backup.mla.txt');

    await file.writeAsBytes(bytes);

    success = await EnvoySeed().restoreData(seed: seed, filePath: file.path);
  } catch (e) {
    success = false;
  }
  if (success) {
    navigator.push(
      MaterialPageRoute(
        builder: (context) {
          return const WalletSetupSuccess();
        },
      ),
    );
  } else {
    if (context.mounted) {
      showRestoreFailedDialog(context);
    }
  }
}
