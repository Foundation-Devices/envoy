// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/server.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:stupid_simple_sheet/stupid_simple_sheet.dart';

Future<void> showPrimeChangelogSheet({
  required BuildContext context,
  required String newVersion,
  required List<PrimePatch> changelogs,
}) {
  final minimumSheetHeight = MediaQuery.sizeOf(context).height * .5;

  return Navigator.of(context, rootNavigator: true).push<void>(
    StupidSimpleSheetRoute<void>(
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      draggable: true,
      motion: CupertinoMotion.snappy(snapToEnd: true),
      snappingConfig: SheetSnappingConfig([.7, 1]),
      child: SafeArea(
        bottom: false,
        left: false,
        right: false,
        child: SheetBackground(
          child: SafeArea(
            top: false,
            left: false,
            right: false,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: minimumSheetHeight),
              child: PrimeChangelog(
                newVersion: newVersion,
                patches: changelogs,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

String _mergePatchChangelogs(List<PrimePatch> patches) {
  final sections = <String>[];

  for (final patch in patches.reversed) {
    final changelog = patch.changelog.trim();
    if (changelog.isEmpty) {
      continue;
    }
    sections.add(
      sections.isEmpty ? changelog : "\n---\n### ${patch.version}\n---\n$changelog",
    );
  }

  return sections.join("\n\n");
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
    final changelogMarkdown = _mergePatchChangelogs(patches);
    final changelogTextStyle = EnvoyTypography.digitsSmall.copyWith(
      color: EnvoyColors.textSecondary,
    );
    final changelogHeadingStyle = EnvoyTypography.subheading.copyWith(
      color: EnvoyColors.textSecondary,
    );
    final markdownStyleSheet =
        MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
      h2: changelogHeadingStyle,
      h3: changelogHeadingStyle,
      p: changelogTextStyle,
      horizontalRuleDecoration: BoxDecoration(
        border: Border.all(
          width: .4,
          color: EnvoyColors.border1,
        ),
      ),
      listBullet: changelogTextStyle,
      blockSpacing: EnvoySpacing.small,
    );

    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: EnvoySpacing.small),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: SizedBox(
                height: 12,
                child: Center(
                  child: Container(
                    width: 44,
                    margin: EdgeInsets.only(top: 8),
                    height: 4,
                    decoration: BoxDecoration(
                      color: EnvoyColors.border1,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ),
            AppBar(
              automaticallyImplyLeading: false,
              primary: false,
              centerTitle: false,
              leading: CloseButton(
                color: EnvoyColors.textPrimary,
              ),
              backgroundColor: Colors.transparent,
              foregroundColor: EnvoyColors.textPrimary,
              toolbarHeight: 54,
              excludeHeaderSemantics: true,
              title: Text(
                S().firmware_updateAvailable_whatsNew(
                  "KeyOS v$newVersion",
                ),
                style: EnvoyTypography.subheading,
              ),
            ),
            Divider(
              thickness: 1,
              color: EnvoyColors.border2,
            ),
            Flexible(
              child: Markdown(
                key: const Key("prime_changelog_list"),
                data: changelogMarkdown,
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(
                  horizontal: EnvoySpacing.medium1,
                  vertical: EnvoySpacing.xs,
                ),
                styleSheet: markdownStyleSheet,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
