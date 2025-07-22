// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:envoy/business/envoy_seed.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/components/pop_up.dart';
import 'package:envoy/ui/onboard/wallet_setup_success.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

Future showRestoreFailedDialog(BuildContext context) async {
  await showEnvoyPopUp(
      context,
      S().manual_setup_import_backup_fails_modal_subheading,
      S().component_continue, (context) {
    Navigator.pop(context);
  },
      title: S().manual_setup_import_backup_fails_modal_heading,
      dismissible: false,
      showCloseButton: false,
      typeOfMessage: PopUpState.warning,
      icon: EnvoyIcons.alert);
}

Future<bool> openBackupFile(BuildContext buildContext, {String? seed}) async {
  var success = false;
  var result = await FilePicker.platform.pickFiles();
  if (result != null) {
    try {
      success = await EnvoySeed()
          .restoreData(filePath: result.files.single.path!, seed: seed);
    } catch (e) {
      success = false;
    }
  }
  return success;
}

Future<void> openBeefQABackupFile(BuildContext buildContext) async {
  final navigator = Navigator.of(buildContext);
  final context = buildContext;

  String path = 'assets/beefqa_backup.mla.txt';

  var success = false;
  var seed = await EnvoySeed().get();

  try {
    final byteData = await rootBundle.load(path);
    final bytes = byteData.buffer.asUint8List();

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/beefqa_backup.mla.txt');

    await file.writeAsBytes(bytes);

    success = await EnvoySeed().restoreData(seed: seed, filePath: file.path);
  } catch (e) {
    success = false;
  }
  if (success) {
    navigator.push(MaterialPageRoute(builder: (context) {
      return const WalletSetupSuccess();
    }));
  } else {
    if (context.mounted) {
      showRestoreFailedDialog(context);
    }
  }
}
