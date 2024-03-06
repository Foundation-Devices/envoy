// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/account_manager.dart';
import 'package:envoy/business/envoy_seed.dart';
import 'package:envoy/business/exchange_rate.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/business/updates_manager.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/amount_entry.dart';
import 'package:envoy/ui/components/pop_up.dart';
import 'package:envoy/ui/home/settings/logs_report.dart';
import 'package:envoy/ui/home/settings/setting_dropdown.dart';
import 'package:envoy/ui/home/settings/setting_text.dart';
import 'package:envoy/ui/home/settings/setting_toggle.dart';
import 'package:envoy/ui/pages/import_pp/single_import_pp_intro.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/util/bug_report_helper.dart';
import 'package:envoy/util/console.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:envoy/ui/state/send_screen_state.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final _animationsDuration = const Duration(milliseconds: 200);
  bool _advancedVisible = false;

  final LocalAuthentication auth = LocalAuthentication();

  Future<bool> shouldShowPassportTaprootDialog() async {
    if (!AccountManager().passportAccountsExist() &&
        !AccountManager().passportTaprootAccountsExist()) {
      return false;
    }

    final currentFwVersion = await UpdatesManager().getStoredFwVersion(1);
    if (currentFwVersion == null) {
      return false;
    }

    if (currentFwVersion >= Version(2, 3, 0)) {
      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    var s = Settings();
    double nestedMargin = 8;
    double marginBetweenItems = 8;

    Map<String, String?> fiatMap = {
      for (var fiat in supportedFiat) fiat.code: fiat.code
    };

    return Container(
      // color: Colors.black,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 34),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SettingText(S().settings_show_fiat),
                SettingToggle(() => s.displayFiat() != null, (enabled) {
                  setState(() {
                    s.setDisplayFiat(enabled ? "USD" : null); // TODO: FIGMA
                    if (!enabled) {
                      ref.read(sendScreenUnitProvider.notifier).state =
                          s.displayUnitSat()
                              ? AmountDisplayUnit.sat
                              : AmountDisplayUnit.btc;
                    }
                  });
                }),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: AnimatedContainer(
                duration: _animationsDuration,
                margin: EdgeInsets.only(
                    top: s.selectedFiat != null ? marginBetweenItems : 0),
                height: s.selectedFiat == null ? 0 : 38,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: nestedMargin),
                      child: SettingText(S().settings_currency),
                    ),
                    SettingDropdown(fiatMap, s.displayFiat, s.setDisplayFiat),
                  ],
                )),
          ),
          SliverPadding(padding: EdgeInsets.all(marginBetweenItems)),
          SliverToBoxAdapter(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SettingText(S().settings_amount),
                SettingToggle(s.displayUnitSat, s.setDisplayUnitSat),
              ],
            ),
          ),
          // SliverPadding(padding: EdgeInsets.all(marginBetweenItems)),
          // SliverToBoxAdapter(
          //     child: Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     SettingText("Allow Screenshots"),
          //     SettingToggle(s.allowScreenshots, s.setAllowScreenshots),
          //   ],
          // )),
          SliverPadding(
              padding: EdgeInsets.all(kDebugMode ? marginBetweenItems : 0)),
          SliverToBoxAdapter(
            child: kDebugMode
                ? GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EnvoyLogsScreen(),
                          ));
                    },
                    child: Container(
                      color: Colors.transparent,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SettingText("Dev options", onTap: () {
                                // TODO: FIGMA
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return const _DevOptions();
                                  },
                                );
                              }),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                : null,
          ),
          SliverToBoxAdapter(
              child: ExpansionTile(
            tilePadding: const EdgeInsets.all(0),
            onExpansionChanged: (value) {
              setState(() {
                _advancedVisible = value;
              });
            },
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(S().settings_advanced,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    )),
                AnimatedRotation(
                  duration: _animationsDuration,
                  turns: _advancedVisible ? 0.0 : 0.5,
                  child: const Icon(
                    Icons.keyboard_arrow_up_sharp,
                    color: Colors.white,
                  ),
                )
              ],
            ),
            trailing: const SizedBox(),
            controlAffinity: ListTileControlAffinity.platform,
            childrenPadding: const EdgeInsets.only(left: 8),
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SettingText(S().settings_advanced_testnet),
                  SettingToggle(s.showTestnetAccounts, s.setShowTestnetAccounts,
                      onEnabled: () {
                    showEnvoyDialog(
                        context: context, dialog: const TestnetInfoModal());
                  }),
                ],
              ),
              Padding(padding: EdgeInsets.all(marginBetweenItems)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SettingText(S().settings_advanced_taproot),
                  SettingToggle(s.taprootEnabled, s.setTaprootEnabled,
                      onEnabled: () async {
                    if (await shouldShowPassportTaprootDialog()) {
                      showEnvoyPopUp(
                        context,
                        title: S().taproot_passport_dialog_heading,
                        S().taproot_passport_dialog_subheading,
                        S().taproot_passport_dialog_reconnect,
                        (BuildContext context) {
                          Navigator.pop(context);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const SingleImportPpIntroPage()));
                        },
                        icon: EnvoyIcons.info,
                        secondaryButtonLabel: S().taproot_passport_dialog_later,
                        onSecondaryButtonTap: (BuildContext context) {
                          Navigator.pop(context);
                        },
                      );
                    }
                  }),
                ],
              ),
              Padding(padding: EdgeInsets.all(marginBetweenItems)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  const Flexible(
                    flex: 5,
                    child: SettingText("Allow LAN addresses over clearnet",
                        // TODO: Need design for this
                        maxLines: 2),
                  ),
                  Flexible(
                    flex: 2,
                    child: SettingToggle(
                      s.allowLANOverClearnet,
                      s.setLANPermission,
                    ),
                  ),
                ],
              ),
              Padding(padding: EdgeInsets.all(marginBetweenItems)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SettingText(S().settings_viewEnvoyLogs, onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EnvoyLogsScreen(),
                        ));
                  }),
                ],
              ),
            ],
          )),
          SliverPadding(padding: EdgeInsets.all(marginBetweenItems)),
        ],
      ),
    );
  }
}

class _DevOptions extends StatelessWidget {
  const _DevOptions({super.key});

  @override
  Widget build(BuildContext context) {
    bool loading = false;
    return AlertDialog(
      backgroundColor: Colors.white,
      title: const Text("Developer options"), // TODO: FIGMA
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
              onPressed: () {
                EnvoyStorage().clearDismissedStatesStore();
                Navigator.pop(context);
              },
              child: const Text("Clear Prompt states")), // TODO: FIGMA
          TextButton(
              onPressed: () {
                EnvoyStorage().clearPendingStore();
                Navigator.pop(context);
              },
              child: const Text("Clear Azteco states")), // TODO: FIGMA
          TextButton(
              onPressed: () {
                EnvoyReport().clearAll();
                Navigator.pop(context);
              },
              child: const Text("Clear Envoy Logs")), // TODO: FIGMA
          TextButton(
              onPressed: () {
                EnvoyStorage().clear();
                Navigator.pop(context);
              },
              child: const Text("Clear Envoy Preferences")), // TODO: FIGMA
          StatefulBuilder(
            builder: (context, setState) {
              if (loading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              return TextButton(
                  onPressed: () async {
                    try {
                      setState(() {
                        loading = true;
                      });
                      await EnvoySeed().delete();
                      setState(() {
                        loading = false;
                      });
                      Navigator.pop(context);
                    } catch (e) {
                      setState(() {
                        loading = false;
                      });
                      Navigator.pop(context);
                      kPrint(e);
                    }
                  },
                  child: const Text("Wipe Envoy Wallet")); // TODO: FIGMA
            },
          )
        ],
      ),
    );
  }
}

class TestnetInfoModal extends StatelessWidget {
  const TestnetInfoModal({super.key});

  @override
  Widget build(BuildContext context) {
    var textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontSize: 13,
        );

    return Container(
      width: MediaQuery.of(context).size.width * 0.75,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/exclamation_icon.png",
                  height: 60,
                  width: 60,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 18.0),
                  child: Text(
                    S().settings_advanced_enabled_testnet_modal_subheading,
                    textAlign: TextAlign.center,
                    style: textStyle,
                  ),
                ),
                const Padding(padding: EdgeInsets.all(4)),
                Padding(
                    padding: const EdgeInsets.only(top: 18.0),
                    child: LinkText(
                        text: S().settings_advanced_enabled_testnet_modal_link,
                        textStyle: textStyle,
                        linkStyle: EnvoyTypography.button
                            .copyWith(color: EnvoyColors.accentPrimary),
                        onTap: () {
                          launchUrlString(
                              "https://www.youtube.com/watch?v=nRGFAHlYIeU");
                        })),
                const Padding(padding: EdgeInsets.all(4)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 28),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: EnvoyButton(
                    S().component_continue,
                    type: EnvoyButtonTypes.primaryModal,
                    onTap: () {
                      Navigator.of(context).pop();
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
