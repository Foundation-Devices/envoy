// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/envoy_seed.dart';
import 'package:envoy/business/exchange_rate.dart';
import 'package:envoy/business/local_storage.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/home/settings/electrum_server_entry.dart';
import 'package:envoy/ui/home/settings/logs_report.dart';
import 'package:envoy/ui/home/settings/setting_dropdown.dart';
import 'package:envoy/ui/home/settings/setting_text.dart';
import 'package:envoy/ui/home/settings/setting_toggle.dart';
import 'package:envoy/util/bug_report_helper.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';

class SettingsPage extends StatefulWidget {
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  _customElectrumServerToggled(bool enabled) {
    setState(() {
      _customElectrumServerVisible = enabled;
    });

    Settings().useDefaultElectrumServer(!enabled);
  }

  final _animationsDuration = Duration(milliseconds: 200);
  bool _advancedVisible = false;
  bool _customElectrumServerVisible = Settings().customElectrumEnabled();
  bool _useLocalAuth = false;

  final LocalAuthentication auth = LocalAuthentication();

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
                    s.setDisplayFiat(enabled ? "USD" : null);
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
                      child: SettingText(S().envoy_settings_currency),
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
          SliverPadding(padding: EdgeInsets.all(marginBetweenItems)),
          SliverToBoxAdapter(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SettingText(S().settings_tor),
                SettingToggle(
                  s.torEnabled,
                  s.setTorEnabled,
                  delay: 1,
                ),
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
          SliverPadding(padding: EdgeInsets.all(marginBetweenItems)),
          SliverToBoxAdapter(
            child: FutureBuilder<bool>(
              future: auth.isDeviceSupported(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return SizedBox();
                }
                if (snapshot.hasData && snapshot.data! == false) {
                  return SizedBox();
                }
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SettingText(S().settings_biometric),
                        EnvoySwitch(
                            value: _useLocalAuth,
                            onChanged: (enabled) async {
                              try {
                                bool authSuccess = await auth.authenticate(
                                    options: AuthenticationOptions(
                                        biometricOnly: false),
                                    localizedReason:
                                        "Authenticate to Enable Biometrics");
                                if (authSuccess) {
                                  LocalStorage()
                                      .prefs
                                      .setBool("useLocalAuth", enabled);
                                  setState(() {
                                    _useLocalAuth = enabled;
                                  });
                                }
                              } catch (e) {
                                print(e);
                              }
                            })
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
          SliverPadding(
              padding: EdgeInsets.all(kDebugMode ? marginBetweenItems : 0)),
          SliverToBoxAdapter(
            child: kDebugMode
                ? GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EnvoyLogsScreen(),
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
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return _DevOptions();
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
            tilePadding: EdgeInsets.all(0),
            onExpansionChanged: (value) {
              setState(() {
                _advancedVisible = value;
              });
            },
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text("Advanced",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    )),
                AnimatedRotation(
                  duration: _animationsDuration,
                  turns: _advancedVisible ? 0.0 : 0.5,
                  child: Icon(
                    Icons.keyboard_arrow_up_sharp,
                    color: Colors.white,
                  ),
                )
              ],
            ),
            trailing: SizedBox(),
            controlAffinity: ListTileControlAffinity.platform,
            childrenPadding: EdgeInsets.only(left: 8),
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SettingText(S().settings_advanced_testnet),
                  SettingToggle(s.showTestnetAccounts, s.setShowTestnetAccounts,
                      onEnabled: () {
                    showEnvoyDialog(
                        context: context, dialog: TestnetInfoModal());
                  }),
                ],
              ),
              Padding(padding: EdgeInsets.all(marginBetweenItems)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SettingText(S().settings_electrum),
                  SettingToggle(() => _customElectrumServerVisible,
                      _customElectrumServerToggled),
                ],
              ),
              AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  child: Padding(
                    padding: EdgeInsets.only(left: nestedMargin, top: 14.0),
                    child: SingleChildScrollView(
                      child: AnimatedContainer(
                          duration: Duration(milliseconds: 200),
                          height: _customElectrumServerVisible ? 86 : 0,
                          child: AnimatedOpacity(
                            child: SingleChildScrollView(
                                child: ElectrumServerEntry(
                                    s.customElectrumAddress,
                                    s.setCustomElectrumAddress)),
                            duration: _animationsDuration,
                            opacity: _customElectrumServerVisible ? 1.0 : 0.0,
                          )),
                    ),
                  )),
              Container(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EnvoyLogsScreen(),
                        ));
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SettingText("View Envoy Logs", onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EnvoyLogsScreen(),
                            ));
                      }),
                    ],
                  ),
                ),
              ),
            ],
          )),
          SliverPadding(padding: EdgeInsets.all(marginBetweenItems)),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      bool? value = LocalStorage().prefs.getBool("useLocalAuth");
      if (value != null)
        setState(() {
          _useLocalAuth = value;
        });
    });
  }
}

class _DevOptions extends StatelessWidget {
  const _DevOptions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool loading = false;
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Text("Developer options"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
              onPressed: () {
                EnvoyStorage().clearDismissedStatesStore();
                Navigator.pop(context);
              },
              child: Text("Clear Prompt states")),
          TextButton(
              onPressed: () {
                EnvoyStorage().clearPendingStore();
                Navigator.pop(context);
              },
              child: Text("Clear Azteco states")),
          TextButton(
              onPressed: () {
                EnvoyReport().clearAll();
                Navigator.pop(context);
              },
              child: Text("Clear Envoy Logs")),
          StatefulBuilder(
            builder: (context, setState) {
              if (loading) {
                return Center(
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
                      print(e);
                    }
                  },
                  child: Text("Wipe Envoy Wallet"));
            },
          )
        ],
      ),
    );
  }
}

class TestnetInfoModal extends StatelessWidget {
  const TestnetInfoModal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.bold,
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
                Padding(padding: EdgeInsets.all(4)),
                Padding(
                    padding: const EdgeInsets.only(top: 18.0),
                    child: LinkText(
                        text: S().settings_advanced_enabled_testnet_modal_link,
                        textStyle: textStyle,
                        onTap: () {
                          launchUrlString(
                              "https://www.youtube.com/watch?v=nRGFAHlYIeU");
                        })),
                Padding(padding: EdgeInsets.all(4)),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 48, vertical: 28),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: EnvoyButton(
                    S().settings_advanced_enabled_testnet_modal_cta,
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
