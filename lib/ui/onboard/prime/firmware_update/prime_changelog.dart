// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/server.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

Future<void> showPrimeChangelogDialog({
  required BuildContext context,
  required String newVersion,
  required List<PrimePatch> changelogs,
}) {
  final size = MediaQuery.sizeOf(context);
  return showEnvoyDialog(
      context: context,
      useRootNavigator: true,
      builder: Builder(
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: size.height * .75,
              width: (size.width * 0.7).clamp(300, 540),
              child: PrimeChangelog(
                newVersion: newVersion,
                patches: changelogs,
              ),
            ),
          );
        },
      ));
}

class PrimeChangelog extends StatelessWidget {
  final String newVersion;
  final List<PrimePatch> patches;

  const PrimeChangelog({
    super.key,
    required this.newVersion,
    required this.patches,
  });

  @override
  Widget build(BuildContext context) {
    final visibleChangelogs = patches
        .where((changelog) => changelog.changelog.trim().isNotEmpty)
        .toList(growable: false)
        .reversed
        .toList();

    return Container(
      padding: const EdgeInsets.all(EnvoySpacing.small),
      child: Scaffold(
        body: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: CloseButton(
                color: Theme.of(context).primaryColor,
                onPressed: () => context.pop(),
              ),
            ),
            Image.asset("assets/fw_download.png", height: 68, width: 68),
            SizedBox(
              height: 12,
            ),
            Text(
                style: EnvoyTypography.subheading,
                textAlign: TextAlign.center,
                S().firmware_updateAvailable_whatsNew(
                  "KeyOS v$newVersion",
                )),
            SizedBox(
              height: 8,
            ),
            Container(color: Colors.black38, height: .5),
            SizedBox(
              height: 8,
            ),
            Expanded(
              child: ListView.separated(
                key: const Key("prime_changelog_list"),
                itemCount: visibleChangelogs.length,
                itemBuilder: (context, index) => ListTile(
                  title: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      visibleChangelogs[index].version,
                      style: EnvoyTypography.subheading.copyWith(
                        color: EnvoyColors.textSecondary,
                      ),
                    ),
                  ),
                  subtitle: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Text(
                      visibleChangelogs[index].changelog,
                      style: EnvoyTypography.explainer.copyWith(
                        color: EnvoyColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                separatorBuilder: (context, index) =>
                    Container(color: Colors.black38, height: .1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
