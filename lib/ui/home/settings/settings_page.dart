// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/exchange_rate.dart';
import 'package:envoy/business/local_storage.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/home/settings/setting_dropdown.dart';
import 'package:envoy/ui/home/settings/electrum_server_entry.dart';
import 'package:envoy/ui/home/settings/setting_text.dart';
import 'package:envoy/ui/home/settings/setting_toggle.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:local_auth/local_auth.dart';

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

    Map<String, String?> fiatMap = {
      for (var fiat in supportedFiat) fiat.code: fiat.code
    };

    return Container(
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.only(top: 14, left: 40, right: 40),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Row(
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
            AnimatedContainer(
              duration: _animationsDuration,
              height: s.selectedFiat == null ? 0 : 16,
              child: Divider(),
            ),
            AnimatedContainer(
              duration: _animationsDuration,
              height: s.selectedFiat == null ? 0 : 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 16.0),
                    child: SettingText(S().envoy_settings_currency),
                  ),
                  SettingDropdown(fiatMap, s.displayFiat, s.setDisplayFiat),
                ],
              ),
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SettingText(S().settings_amount),
                SettingToggle(s.displayUnitSat, s.setDisplayUnitSat),
              ],
            ),
            Divider(),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     SettingText("Allow Screenshots"),
            //     SettingToggle(s.allowScreenshots, s.setAllowScreenshots),
            //   ],
            // ),
            // Divider(),
            Row(
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
            Divider(),
            FutureBuilder<bool>(
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
                        NeumorphicSwitch(
                            height: 35,
                            value: _useLocalAuth,
                            style: NeumorphicSwitchStyle(
                                inactiveThumbColor: EnvoyColors.whitePrint,
                                inactiveTrackColor: EnvoyColors.grey15,
                                activeThumbColor: EnvoyColors.whitePrint,
                                activeTrackColor: EnvoyColors.darkTeal,
                                disableDepth: true),
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
            //Advanced section
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SettingText("Advanced"),
                  IconButton(
                    icon: AnimatedRotation(
                      duration: _animationsDuration,
                      turns: _advancedVisible ? 0.0 : 0.5,
                      child: Icon(
                        Icons.keyboard_arrow_up_sharp,
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _advancedVisible = !_advancedVisible;
                      });
                    },
                  ),
                ],
              ),
            ),
            Padding(padding: EdgeInsets.all(8)),
            AnimatedContainer(
                duration: Duration(milliseconds: 200),
                height: _advancedVisible ? 40 : 0,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SettingText("Enable Testnet"),
                      SettingToggle(
                          s.showTestnetAccounts, s.setShowTestnetAccounts),
                    ],
                  ),
                )),
            Padding(padding: EdgeInsets.all(8)),
            AnimatedContainer(
                duration: Duration(milliseconds: 200),
                height: _advancedVisible ? 40 : 0,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SettingText(S().settings_electrum),
                      SettingToggle(() => _customElectrumServerVisible,
                          _customElectrumServerToggled),
                    ],
                  ),
                )),

            AnimatedContainer(
                duration: Duration(milliseconds: 200),
                height: _advancedVisible ? 120 : 0,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 14.0),
                  child: SingleChildScrollView(
                    child: AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        height: _customElectrumServerVisible ? 130 : 0,
                        child: AnimatedOpacity(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 0.0),
                            child: ElectrumServerEntry(s.customElectrumAddress,
                                s.setCustomElectrumAddress),
                          ),
                          duration: _animationsDuration,
                          opacity: _customElectrumServerVisible ? 1.0 : 0.0,
                        )),
                  ),
                )),
          ],
        ),
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
