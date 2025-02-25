// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/connectivity_manager.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/background.dart';
import 'package:envoy/ui/components/big_tab.dart';
import 'package:envoy/ui/components/select_dropdown.dart';
import 'package:envoy/ui/components/settings_header.dart';
import 'package:envoy/ui/components/toggle.dart';
import 'package:envoy/ui/fading_edge_scroll_view.dart';
import 'package:envoy/ui/home/settings/electrum_server_entry.dart';
import 'package:envoy/ui/indicator_shield.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/ui/shield.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class AdvancedSettingsOptions extends ConsumerStatefulWidget {
  const AdvancedSettingsOptions({super.key});

  @override
  ConsumerState<AdvancedSettingsOptions> createState() =>
      _AdvancedSettingsOptionsState();
}

class _AdvancedSettingsOptionsState
    extends ConsumerState<AdvancedSettingsOptions> {
  final ScrollController _scrollController = ScrollController();
  bool _betterPerformance = !Settings().torEnabled();
  bool _showPersonalNodeTextField = false;
  bool enableMagicBackup = false;

  @override
  Widget build(BuildContext context) {
    var keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    var bottomPadding = keyboardHeight - 10 * EnvoySpacing.medium2;
    var s = Settings();
    return MediaQuery.removePadding(
      removeTop: false,
      context: context,
      child: Material(
        color: Colors.transparent,
        child: Scaffold(
            resizeToAvoidBottomInset: true,
            appBar: AppBar(
              elevation: 0,
              leading: CupertinoNavigationBarBackButton(
                color: Colors.white,
                onPressed: context.pop,
              ),
              flexibleSpace: SafeArea(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const SizedBox(
                      height: 100,
                      child: IndicatorShield(),
                    ),
                    Text(
                      //TODO: copy update
                      "ADVANCED OPTIONS",
                      style:
                          Theme.of(context).textTheme.displayMedium?.copyWith(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                    ),
                  ],
                ),
              ),
            ),
            body: background(
                context: context,
                child: Hero(
                    tag: "shield",
                    child: Shield(
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              bottom: EnvoySpacing.medium1),
                          child: FadingEdgeScrollView.fromSingleChildScrollView(
                              gradientFractionOnStart: 0.03,
                              gradientFractionOnEnd: 0.06,
                              child: SingleChildScrollView(
                                reverse: true,
                                controller: _scrollController,
                                child: Material(
                                  color: Colors.transparent,
                                  child: Padding(
                                    padding: const EdgeInsets.all(
                                        EnvoySpacing.medium1),
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: EnvoySpacing.medium1),
                                          child: SettingsHeader(
                                            //TODO: copy update
                                            title: "Magic Backups",
                                            linkText: S().component_learnMore,
                                            onTap: () {
                                              launchUrl(
                                                  Uri.parse(
                                                      "https://docs.foundation.xyz/envoy/envoy-menu/privacy"),
                                                  mode: LaunchMode
                                                      .externalApplication);
                                            },
                                            icon: EnvoyIcons.shield,
                                          ),
                                        ),
                                        Column(
                                          children: [
                                            ListTile(
                                              //TODO: copy update
                                              leading: Text(
                                                "This is infotext about magic backups",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleSmall,
                                              ),
                                              trailing: EnvoyToggle(
                                                value: enableMagicBackup,
                                                onChanged: (bool value) async {
                                                  setState(() {
                                                    enableMagicBackup =
                                                        !enableMagicBackup;
                                                  });
                                                },
                                              ),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      vertical:
                                                          EnvoySpacing.small,
                                                      horizontal:
                                                          EnvoySpacing.small),
                                            ),
                                            //TODO: copy update
                                            const Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: EnvoySpacing.small,
                                                  horizontal: EnvoySpacing.xs),
                                              child: Text(
                                                  "Here we can introduce the user to the special area here, what important stuff he can do."),
                                            )
                                          ],
                                        ),
                                        buildDivider(),
                                        SettingsHeader(
                                          title: S().privacy_privacyMode_title,
                                          linkText: S().component_learnMore,
                                          onTap: () {
                                            launchUrl(
                                                Uri.parse(
                                                    "https://docs.foundation.xyz/envoy/envoy-menu/privacy"),
                                                mode: LaunchMode
                                                    .externalApplication);
                                          },
                                          icon: EnvoyIcons.privacy,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: EnvoySpacing.medium2),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              BigTab(
                                                label: S()
                                                    .privacy_privacyMode_betterPerformance,
                                                icon: EnvoyIcons.performance,
                                                isActive: _betterPerformance,
                                                onSelect: (isActive) {
                                                  setState(() {
                                                    _betterPerformance = true;
                                                  });
                                                  ref
                                                          .read(
                                                              torEnabledProvider
                                                                  .notifier)
                                                          .state =
                                                      !_betterPerformance;
                                                  Settings().setTorEnabled(
                                                      !_betterPerformance);
                                                },
                                              ),
                                              BigTab(
                                                label: S()
                                                    .privacy_privacyMode_improvedPrivacy,
                                                icon: EnvoyIcons.privacy,
                                                isActive: !_betterPerformance,
                                                onSelect: (isActive) {
                                                  setState(() {
                                                    _betterPerformance = false;
                                                  });
                                                  ref
                                                          .read(
                                                              torEnabledProvider
                                                                  .notifier)
                                                          .state =
                                                      !_betterPerformance;
                                                  Settings().setTorEnabled(
                                                      !_betterPerformance);
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                        LinkText(
                                            textAlign: TextAlign.start,
                                            text: _betterPerformance
                                                ? S()
                                                    .privacy_privacyMode_torSuggestionOff
                                                : S()
                                                    .privacy_privacyMode_torSuggestionOn,
                                            textStyle: EnvoyTypography.info
                                                .copyWith(
                                                    color: EnvoyColors
                                                        .textSecondary),
                                            linkStyle: EnvoyTypography.info
                                                .copyWith(
                                                    color:
                                                        _betterPerformance
                                                            ? EnvoyColors
                                                                .accentSecondary
                                                            : EnvoyColors
                                                                .accentPrimary)),
                                        buildDivider(),
                                        SettingsHeader(
                                          title: S().privacy_node_title,
                                          linkText: S().component_learnMore,
                                          onTap: () {
                                            launchUrl(
                                                Uri.parse(
                                                    "https://docs.foundation.xyz/envoy/envoy-menu/privacy"),
                                                mode: LaunchMode
                                                    .externalApplication);
                                          },
                                          icon: EnvoyIcons.node,
                                        ),
                                        const SizedBox(
                                            height: EnvoySpacing.medium2),
                                        Material(
                                            color: Colors.transparent,
                                            child: EnvoyDropdown(
                                              initialIndex:
                                                  getInitialElectrumDropdownIndex(),
                                              options: [
                                                EnvoyDropdownOption(S()
                                                    .privacy_node_nodeType_foundation),
                                                EnvoyDropdownOption(
                                                    S()
                                                        .privacy_node_nodeType_personal,
                                                    type:
                                                        EnvoyDropdownOptionType
                                                            .personalNode),
                                                EnvoyDropdownOption(
                                                    S()
                                                        .privacy_node_nodeType_publicServers,
                                                    type:
                                                        EnvoyDropdownOptionType
                                                            .sectionBreak),
                                                EnvoyDropdownOption(
                                                    PublicServer
                                                        .blockStream.label,
                                                    type:
                                                        EnvoyDropdownOptionType
                                                            .blockStream),
                                                EnvoyDropdownOption(
                                                    PublicServer.diyNodes.label,
                                                    type:
                                                        EnvoyDropdownOptionType
                                                            .diyNodes),
                                                EnvoyDropdownOption(
                                                    PublicServer
                                                        .sethForPrivacy.label,
                                                    type:
                                                        EnvoyDropdownOptionType
                                                            .sethForPrivacy),
                                              ],
                                              onOptionChanged:
                                                  (selectedOption) {
                                                if (selectedOption != null) {
                                                  _handleDropdownChange(
                                                      selectedOption);
                                                }
                                              },
                                            )),
                                        if (_showPersonalNodeTextField)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: EnvoySpacing.medium1),
                                            child: SingleChildScrollView(
                                                child: ElectrumServerEntry(
                                                    s.customElectrumAddress,
                                                    s.setCustomElectrumAddress)),
                                          ),
                                        if (keyboardHeight != 0.0 &&
                                            bottomPadding > 0)
                                          Padding(
                                            padding: EdgeInsets.only(
                                                bottom: bottomPadding),
                                          ),
                                        Container(
                                          height: 40,
                                          color: Colors.transparent,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              )),
                        ),
                      ),
                    )))),
      ),
    );
  }

  void _handleDropdownChange(EnvoyDropdownOption newOption) {
    setState(() {
      _showPersonalNodeTextField =
          newOption.type == EnvoyDropdownOptionType.personalNode;
    });

    switch (newOption.type) {
      case EnvoyDropdownOptionType.normal:
        Settings().useDefaultElectrumServer(true);
      case EnvoyDropdownOptionType.personalNode:
        Settings().useDefaultElectrumServer(false);
      case EnvoyDropdownOptionType.blockStream:
        Settings().setCustomElectrumAddress(PublicServer.blockStream.address);
      case EnvoyDropdownOptionType.diyNodes:
        Settings().setCustomElectrumAddress(PublicServer.diyNodes.address);
      case EnvoyDropdownOptionType.sethForPrivacy:
        Settings()
            .setCustomElectrumAddress(PublicServer.sethForPrivacy.address);
      case EnvoyDropdownOptionType.sectionBreak:
      // do nothing
    }
  }

  Widget buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: EnvoySpacing.medium2),
      child: Divider(
        height: 4,
        color: EnvoyColors.border1,
      ),
    );
  }

  Widget background({required Widget child, required BuildContext context}) {
    return Stack(
      children: [
        const AppBackground(
          showRadialGradient: true,
        ),
        Positioned(
          top: 0,
          left: 5,
          bottom: const BottomAppBar().height ?? 20 + 8,
          right: 5,
          child:
              Shield(child: Material(color: Colors.transparent, child: child)),
        )
      ],
    );
  }
}
