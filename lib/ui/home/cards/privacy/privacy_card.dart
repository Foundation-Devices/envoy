// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/connectivity_manager.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/util/console.dart';
import 'package:flutter/material.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/components/settings_header.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/components/big_tab.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/ui/components/select_dropdown.dart';
import 'package:envoy/ui/components/toggle.dart';
import 'package:envoy/business/settings.dart';
import 'package:local_auth/local_auth.dart';
import 'package:envoy/business/local_storage.dart';
import 'package:envoy/ui/fading_edge_scroll_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:envoy/ui/home/settings/electrum_server_entry.dart';
import 'dart:io';

//ignore: must_be_immutable
class PrivacyCard extends StatefulWidget {
  const PrivacyCard({super.key});

  @override
  State<PrivacyCard> createState() => PrivacyCardState();
}

class PrivacyCardState extends State<PrivacyCard> {
  bool _showPersonalNodeTextField = false;
  bool _betterPerformance = !Settings().torEnabled();

  bool? _useLocalAuth = false;
  final ScrollController _scrollController = ScrollController();
  final LocalAuthentication _auth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        _useLocalAuth = LocalStorage().prefs.getBool("useLocalAuth");
      });
    });
  }

  void _handleDropdownChange(EnvoyDropdownOption newOption) {
    setState(() {
      _showPersonalNodeTextField =
          newOption.type == EnvoyDropdownOptionType.personalNode;
    });
  }

  @override
  Widget build(BuildContext context) {
    var keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    var bottomPadding = keyboardHeight - 10 * EnvoySpacing.medium2;
    var s = Settings();
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: EnvoySpacing.medium1),
        child: FadingEdgeScrollView.fromSingleChildScrollView(
            gradientFractionOnStart: 0.03,
            gradientFractionOnEnd: 0.06,
            child: SingleChildScrollView(
              reverse: true,
              controller: _scrollController,
              child: Padding(
                padding: const EdgeInsets.all(EnvoySpacing.medium1),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: EnvoySpacing.medium1),
                      child: SettingsHeader(
                        title: S().privacy_privacyMode_title,
                        linkText: S().component_learnMore,
                        onTap: () {
                          launchUrl(
                              Uri.parse(
                                  "https://docs.foundationdevices.com/envoy/privacy"),
                              mode: LaunchMode.externalApplication);
                        },
                        icon: EnvoyIcons.privacy,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: EnvoySpacing.medium2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          BigTab(
                            label: S().privacy_privacyMode_betterPerformance,
                            icon: EnvoyIcons.performance,
                            isActive: _betterPerformance,
                            onSelect: (isActive) {
                              setState(() {
                                _betterPerformance = true;
                              });
                              Settings().setTorEnabled(!_betterPerformance);
                            },
                          ),
                          BigTab(
                            label: S().privacy_privacyMode_improvedPrivacy,
                            icon: EnvoyIcons.privacy,
                            isActive: !_betterPerformance,
                            onSelect: (isActive) {
                              setState(() {
                                _betterPerformance = false;
                              });
                              Settings().setTorEnabled(!_betterPerformance);
                            },
                          ),
                        ],
                      ),
                    ),
                    LinkText(
                        textAlign: TextAlign.start,
                        text: _betterPerformance
                            ? S().privacy_privacyMode_torSuggestionOff
                            : S().privacy_privacyMode_torSuggestionOn,
                        textStyle: EnvoyTypography.info
                            .copyWith(color: EnvoyColors.textSecondary),
                        linkStyle: EnvoyTypography.info.copyWith(
                            color: _betterPerformance
                                ? EnvoyColors.accentSecondary
                                : EnvoyColors.accentPrimary)),
                    buildDivider(),
                    SettingsHeader(
                      title: S().privacy_node_title,
                      linkText: S().component_learnMore,
                      onTap: () {
                        launchUrl(
                            Uri.parse(
                                "https://docs.foundationdevices.com/envoy/privacy"),
                            mode: LaunchMode.externalApplication);
                      },
                      icon: EnvoyIcons.node,
                    ),
                    const SizedBox(height: EnvoySpacing.medium2),
                    EnvoyDropdown(
                      initialIndex:
                          ConnectivityManager().usingDefaultServer ? 0 : 1,
                      options: [
                        EnvoyDropdownOption(
                            S().privacy_node_nodeType_foundation),
                        EnvoyDropdownOption(S().privacy_node_nodeType_personal,
                            type: EnvoyDropdownOptionType.personalNode),
                      ],
                      onOptionChanged: (selectedOption) {
                        if (selectedOption != null) {
                          setState(() {
                            _handleDropdownChange(selectedOption);
                            if (!(selectedOption.type ==
                                EnvoyDropdownOptionType.personalNode)) {
                              s.useDefaultElectrumServer(true);
                            }
                          });
                        }
                      },
                    ),
                    if (!ConnectivityManager().usingDefaultServer ||
                        _showPersonalNodeTextField)
                      Padding(
                        padding:
                            const EdgeInsets.only(top: EnvoySpacing.medium1),
                        child: SingleChildScrollView(
                            child: ElectrumServerEntry(s.customElectrumAddress,
                                s.setCustomElectrumAddress)),
                      ),
                    if (!Platform.isLinux)
                      FutureBuilder<bool>(
                        future: _auth.isDeviceSupported(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const SizedBox();
                          }
                          if (snapshot.hasData && snapshot.data! == false) {
                            return const SizedBox();
                          }

                          return Column(
                            children: [
                              buildDivider(),
                              Row(
                                children: [
                                  const EnvoyIcon(EnvoyIcons.biometrics,
                                      size: EnvoyIconSize.normal),
                                  const SizedBox(
                                    width: EnvoySpacing.small,
                                  ),
                                  Text(
                                    S().privacy_applicationLock_title,
                                    style: EnvoyTypography.body.copyWith(
                                        color: EnvoyColors.textPrimary),
                                  ),
                                ],
                              ),
                              const SizedBox(height: EnvoySpacing.medium2),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    flex: 4,
                                    child: Text(
                                      S().privacy_applicationLock_unlock,
                                      style: EnvoyTypography.body.copyWith(
                                        color: EnvoyColors.textPrimary,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    flex: 1,
                                    child: EnvoyToggle(
                                      value: _useLocalAuth ?? false,
                                      onChanged: (bool value) async {
                                        try {
                                          bool authSuccess =
                                              await _auth.authenticate(
                                            options:
                                                const AuthenticationOptions(
                                              biometricOnly: false,
                                            ),
                                            localizedReason:
                                                "Authenticate to Enable Biometrics", // TODO: Figma
                                          );

                                          if (authSuccess) {
                                            LocalStorage()
                                                .prefs
                                                .setBool("useLocalAuth", value);
                                            setState(() {
                                              _useLocalAuth = value;
                                            });
                                          }
                                        } catch (e) {
                                          kPrint(e);
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    if (keyboardHeight != 0.0 && bottomPadding > 0)
                      Padding(
                        padding: EdgeInsets.only(bottom: bottomPadding),
                      ),
                    Container(
                      height: 40,
                      color: Colors.transparent,
                    )
                  ],
                ),
              ),
            )),
      ),
    );
  }

  Padding buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: EnvoySpacing.medium2),
      child: Divider(
        height: 2,
        color: EnvoyColors.border1,
      ),
    );
  }
}
