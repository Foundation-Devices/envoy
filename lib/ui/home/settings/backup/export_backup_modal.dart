// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/envoy_button.dart';
import 'package:flutter/material.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/business/envoy_seed.dart';

class ExportBackupModal extends StatefulWidget {
  const ExportBackupModal({Key? key}) : super(key: key);

  @override
  State<ExportBackupModal> createState() => _ExportBackupModalState();
}

class _ExportBackupModalState extends State<ExportBackupModal> {
  @override
  Widget build(BuildContext context) {
    var textStyle = Theme.of(context).textTheme.bodyText2?.copyWith(
          fontWeight: FontWeight.w500,
        );

    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 48),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/exclamation_icon.png",
                  height: 100,
                  width: 100,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 18.0),
                  child: Text(
                    S().export_backup_modal_subheading,
                    textAlign: TextAlign.center,
                    style: textStyle,
                  ),
                ),
                Padding(padding: EdgeInsets.all(4)),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 48, vertical: 28),
            child: Column(
              children: [
                EnvoyButton(
                  S().export_backup_send_CTA2,
                  type: EnvoyButtonTypes.SECONDARY,
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: EnvoyButton(
                    S().export_backup_send_CTA1,
                    onTap: () {
                      Navigator.of(context).pop();
                      EnvoySeed().saveOfflineData();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
