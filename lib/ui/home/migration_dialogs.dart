// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

// ignore_for_file: constant_identifier_names

import 'package:envoy/business/local_storage.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/components/button.dart';
import 'package:envoy/ui/migrations/migration_manager.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:envoy/util/easing.dart';
import 'package:flutter/material.dart';

//shows migration related dialogs
void notifyAboutNetworkMigrationDialog(BuildContext context) {
  Widget buildContent(String title, String subtitle, Function onTap) {
    Color accentColor = EnvoyColors.accentPrimary;
    return Padding(
      padding: const EdgeInsets.all(EnvoySpacing.medium2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: EnvoySpacing.medium3),
            child: EnvoyIcon(
              EnvoyIcons.info,
              size: EnvoyIconSize.big,
              color: accentColor,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: EnvoySpacing.medium1),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: EnvoyTypography.heading,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: EnvoySpacing.medium3),
            child: Text(
              subtitle,
              style: EnvoyTypography.info,
              textAlign: TextAlign.center,
            ),
          ),
          EnvoyButton(
              label: S().component_confirm,
              type: ButtonType.primary,
              state: ButtonState.defaultState,
              onTap: () {
                onTap();
              }),
        ],
      ),
    );
  }

  void notifyAboutNetworkMigration(
    bool showT4Dialog,
    bool showSignetDialog,
    bool accountUnified,
    BuildContext context,
  ) {
    final prefs = LocalStorage().prefs;

    if (context.mounted) {
      PageController controller = PageController();
      List<Widget> pages = [];
      void nextPageOrClose(String key) async {
        await prefs.setBool(key, false);
        if (controller.page == pages.length - 1) {
          if (context.mounted) Navigator.pop(context);
        } else {
          controller.nextPage(
              duration: const Duration(milliseconds: 360),
              curve: EnvoyEasing.easeInOut);
        }
      }

      if (showT4Dialog) {
        pages.add(buildContent(
          S().accounts_upgradeBdkTestnetModal_header,
          S().accounts_upgradeBdkTestnetModal_content,
          () => nextPageOrClose(MigrationManager.migratedToTestnet4),
        ));
      }
      if (showSignetDialog) {
        pages.add(buildContent(
          S().accounts_upgradeBdkSignetModal_header,
          S().accounts_upgradeBdkSignetModal_content,
          () => nextPageOrClose(MigrationManager.migratedToSignetGlobal),
        ));
      }
      if (accountUnified) {
        pages.add(buildContent(
          S().onboardin_unifiedAccountsModal_tilte,
          S().onboardin_unifiedAccountsModal_content,
          () => nextPageOrClose(MigrationManager.migratedToUnifiedAccounts),
        ));
      }

      showEnvoyDialog(
          context: context,
          useRootNavigator: true,
          dialog: SizedBox(
            width: MediaQuery.of(context).size.width * 0.85,
            height: MediaQuery.of(context).size.height * 0.44,
            child: PageView(
              controller: controller,
              children: [...pages],
            ),
          ),
          dismissible: false);
    }
  }

  final prefs = LocalStorage().prefs;

  final bool showT4Dialog =
      prefs.getBool(MigrationManager.migratedToTestnet4) ?? false;
  final bool showSignetDialog =
      prefs.getBool(MigrationManager.migratedToSignetGlobal) ?? false;
  final bool accountUnified =
      prefs.getBool(MigrationManager.migratedToUnifiedAccounts) ?? false;

  if (showT4Dialog || showSignetDialog || accountUnified) {
    notifyAboutNetworkMigration(
      showT4Dialog,
      showSignetDialog,
      accountUnified,
      context,
    );
  }
}
