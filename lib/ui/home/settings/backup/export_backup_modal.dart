// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/envoy_seed.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/components/button.dart';
import 'package:flutter/material.dart';

class ExportBackupModal extends StatefulWidget {
  final Function? onExport;

  const ExportBackupModal({super.key, this.onExport});

  @override
  State<ExportBackupModal> createState() => _ExportBackupModalState();
}

class _ExportBackupModalState extends State<ExportBackupModal> {
  bool _isExporting = false;

  @override
  Widget build(BuildContext context) {
    var textStyle = Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500);

    return SingleChildScrollView(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.85,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
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
                  const Padding(padding: EdgeInsets.all(4)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 28),
              child: Column(
                children: [
                  EnvoyButton(
                    label: S().export_backup_send_CTA2,
                    type: ButtonType.secondary,
                    height: 40,
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: EnvoyButton(
                      label: S().export_backup_send_CTA1,
                      type: ButtonType.primary,
                      height: 40,
                      state: _isExporting
                          ? ButtonState.loading
                          : ButtonState.defaultState,
                      onTap: () async {
                        setState(() {
                          _isExporting = true;
                        });
                        await EnvoySeed().saveOfflineData();
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                        if (widget.onExport != null) {
                          widget.onExport!();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
