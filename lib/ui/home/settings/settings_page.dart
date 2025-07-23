// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/envoy_seed.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/amount_entry.dart';
import 'package:envoy/ui/components/pop_up.dart';
import 'package:envoy/ui/home/settings/fiat/settings_fiat_chooser.dart';
import 'package:envoy/ui/home/settings/logs_report.dart';
import 'package:envoy/ui/home/settings/setting_text.dart';
import 'package:envoy/ui/home/settings/setting_toggle.dart';
import 'package:envoy/ui/home/setup_overlay.dart';
import 'package:envoy/ui/state/accounts_state.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/util/bug_report_helper.dart';
import 'package:envoy/util/console.dart';
import 'package:envoy/util/easing.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:ngwallet/ngwallet.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:envoy/ui/state/send_screen_state.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/business/region_manager.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final _animationsDuration = const Duration(milliseconds: 200);
  bool _advancedVisible = false;
  bool canBuy = true;
  bool buyDisabledByCountry = true;

  final LocalAuthentication auth = LocalAuthentication();

  final s = Settings();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _checkCanBuy();
      buyDisabledByCountry = await AllowedRegions.checkBuyDisabled();
    });
  }

  Future<void> _checkCanBuy() async {
    var region = await EnvoyStorage().getCountry();

    if (region != null) {
      bool newRegionCanBuy =
          await AllowedRegions.isRegionAllowed(region.code, region.division);
      setState(() {
        canBuy = newRegionCanBuy;
      });
    } else {
      setState(() {
        canBuy = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double nestedMargin = 8;
    double marginBetweenItems = 6;

    return Container(
      // color: Colors.black,
      padding: const EdgeInsets.symmetric(
          vertical: EnvoySpacing.small, horizontal: EnvoySpacing.medium3),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: ListTile(
              contentPadding: const EdgeInsets.all(0),
              dense: true,
              title: Wrap(
                children: [SettingText(S().settings_show_fiat)],
              ),
              trailing: SettingToggle(() => s.displayFiat() != null, (enabled) {
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
            ),
          ),
          SliverToBoxAdapter(
            child: AnimatedContainer(
              duration: _animationsDuration,
              curve: EnvoyEasing.easeInOut,
              margin: EdgeInsets.only(
                  top: s.selectedFiat != null ? marginBetweenItems : 0),
              height: s.selectedFiat == null ? 0 : 52,
              child: GestureDetector(
                onTap: () {
                  showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    sheetAnimationStyle: AnimationStyle(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOutSine,
                    ),
                    backgroundColor: Colors.transparent,
                    isDismissible: true,
                    useSafeArea: true,
                    builder: (context) {
                      return FiatCurrencyChooser(onSelect: (String selection) {
                        setState(() {
                          s.setDisplayFiat(selection);
                        });
                      });
                    },
                  );
                },
                child: Padding(
                  padding: EdgeInsets.only(left: nestedMargin),
                  child: ListTile(
                    dense: true,
                    contentPadding:
                        const EdgeInsets.only(right: EnvoySpacing.medium1),
                    title: SettingText(S().settings_currency),
                    trailing: Text(s.selectedFiat ?? "",
                        style: EnvoyTypography.body
                            .copyWith(color: EnvoyColors.accentPrimary)),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(padding: EdgeInsets.all(marginBetweenItems)),
          SliverToBoxAdapter(
            child: ListTile(
              dense: true,
              contentPadding: const EdgeInsets.all(0),
              title: SettingText(S().settings_amount),
              trailing: SettingToggle(s.displayUnitSat, s.setDisplayUnitSat),
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
                      showDialog(
                        context: context,
                        builder: (context) {
                          return const _DevOptions();
                        },
                      );
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
              ListTile(
                dense: true,
                contentPadding: const EdgeInsets.all(0),
                title: Wrap(
                  children: [SettingText(S().settings_advanced_testnet)],
                ),
                trailing: SettingToggle(
                    s.showTestnetAccounts, s.setShowTestnetAccounts,
                    onEnabled: () {
                  showEnvoyDialog(
                      context: context, dialog: const TestnetInfoModal());
                }),
              ),
              ListTile(
                dense: true,
                contentPadding: const EdgeInsets.all(0),
                title: Wrap(
                  children: [SettingText(S().settings_advanced_signet)],
                ),
                trailing: SettingToggle(
                  s.showSignetAccounts,
                  s.setShowSignetAccounts,
                  onEnabled: () {
                    showEnvoyDialog(
                        context: context, dialog: const SignetInfoModal());
                  },
                ),
              ),
              ListTile(
                dense: true,
                contentPadding: const EdgeInsets.all(0),
                title: SettingText(S().settings_advanced_receiveToTaproot),
                trailing: SettingToggle(
                  s.taprootEnabled,
                  s.setTaprootEnabled,
                  onEnabled: () async {
                    if (context.mounted) {
                      showEnvoyPopUp(
                        context,
                        icon: EnvoyIcons.info,
                        showCloseButton: false,
                        title: S().settings_advancedModalReceiveTaproot_title,
                        S().settings_advancedModalReceiveTaproot_content,
                        S().component_confirm,
                        (BuildContext context) {
                          s.enableTaprootSetting = true;
                          Navigator.pop(context);

                          if (hasAccountWithoutTaprootXpub()) {
                            showEnvoyPopUp(
                              context,
                              icon: EnvoyIcons.info,
                              showCloseButton: true,
                              title: S().taproot_passport_dialog_heading,
                              S().taproot_passport_dialog_subheading,
                              S().taproot_passport_dialog_reconnect,
                              (BuildContext modalContext) {
                                Navigator.pop(modalContext);
                                scanForDevice(context);
                              },
                              secondaryButtonLabel:
                                  S().taproot_passport_dialog_later,
                              onSecondaryButtonTap: (BuildContext context) {
                                Navigator.pop(context);
                              },
                            );
                          }
                        },
                      );
                    }
                  },
                  onDisabled: () async {
                    if (context.mounted) {
                      showEnvoyPopUp(
                        context,
                        icon: EnvoyIcons.info,
                        showCloseButton: false,
                        title: S().settings_advancedModalReceiveSegwit_title,
                        S().settings_advancedModalReceiveSegwit_content,
                        S().component_confirm,
                        (BuildContext context) {
                          s.enableTaprootSetting = false;
                          Navigator.pop(context);
                        },
                      );
                    }
                  },
                ),
              ),
              canBuy && !buyDisabledByCountry
                  ? ListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.all(0),
                      title: Wrap(
                        children: [
                          SettingText(S().settings_advanced_enableBuyRamp)
                        ],
                      ),
                      trailing: SettingToggle(
                        s.isAllowedBuyInEnvoy,
                        s.setAllowBuyInEnvoy,
                      ),
                    )
                  : const SizedBox.shrink(),
              ListTile(
                dense: true,
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EnvoyLogsScreen(),
                      ));
                },
                contentPadding: const EdgeInsets.all(0),
                title: SettingText(S().settings_viewEnvoyLogs, onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EnvoyLogsScreen(),
                      ));
                }),
              ),
            ],
          )),
          SliverPadding(padding: EdgeInsets.all(marginBetweenItems)),
        ],
      ),
    );
  }

  bool hasAccountWithoutTaprootXpub() {
    final accounts = ref.read(accountsProvider);

    return accounts.any((account) {
      // Look for a taproot descriptor in this account
      final taprootDescriptor = account.externalPublicDescriptors.firstWhere(
        (pair) => pair.$1 == AddressType.p2Tr,
        orElse: () => (AddressType.p2Tr, ''),
      );

      // If the xpub (pair.$2) is empty, this account lacks a taproot xpub
      return taprootDescriptor.$2.isEmpty;
    });
  }
}

class _DevOptions extends StatelessWidget {
  const _DevOptions();

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
                    final navigator = Navigator.of(context);
                    try {
                      setState(() {
                        loading = true;
                      });
                      await EnvoySeed().delete();
                      setState(() {
                        loading = false;
                      });
                      navigator.pop();
                    } catch (e) {
                      setState(() {
                        loading = false;
                      });
                      navigator.pop();
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

    return SizedBox(
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

class SignetInfoModal extends StatelessWidget {
  const SignetInfoModal({super.key});

  @override
  Widget build(BuildContext context) {
    var textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontSize: 13,
        );

    return SizedBox(
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
                    S().settings_advanced_enabled_signet_modal_subheading,
                    textAlign: TextAlign.center,
                    style: textStyle,
                  ),
                ),
                const Padding(padding: EdgeInsets.all(4)),
                Padding(
                    padding: const EdgeInsets.only(top: 18.0),
                    child: LinkText(
                        text: S().settings_advanced_enabled_signet_modal_link,
                        textStyle: textStyle,
                        linkStyle: EnvoyTypography.button
                            .copyWith(color: EnvoyColors.accentPrimary),
                        onTap: () {
                          launchUrlString("https://en.bitcoin.it/wiki/Signet");
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
