// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/exchange_rate.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/ui/home/settings/setting_dropdown.dart';
import 'package:envoy/ui/home/settings/electrum_server_entry.dart';
import 'package:envoy/ui/home/settings/setting_toggle.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:envoy/generated/l10n.dart';

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

  bool _customElectrumServerVisible = Settings().customElectrumEnabled();

  @override
  Widget build(BuildContext context) {
    var s = Settings();

    Map<String, String?> fiatMap = {
      for (var fiat in supportedFiat) fiat.code: fiat.code
    };

    fiatMap.addAll({S().envoy_settings_fiat_currency_nah: null});

    return Container(
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.only(top: 100, left: 40, right: 40),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SettingText(S().envoy_settings_fiat_currency),
                SettingDropdown(fiatMap, s.displayFiat, s.setDisplayFiat),
              ],
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SettingText(S().envoy_settings_sat_amount),
                SettingToggle(s.displayUnitSat, s.setDisplayUnitSat),
              ],
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SettingText(S().envoy_settings_tor_connectivity),
                SettingToggle(
                  s.torEnabled,
                  s.setTorEnabled,
                  delay: 1,
                ),
              ],
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SettingText(S().envoy_settings_custom_electrum_server),
                SettingToggle(() => _customElectrumServerVisible,
                    _customElectrumServerToggled),
              ],
            ),
            IgnorePointer(
              ignoring: !_customElectrumServerVisible,
              child: AnimatedOpacity(
                child: Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: ElectrumServerEntry(
                      s.customElectrumAddress, s.setCustomElectrumAddress),
                ),
                duration: Duration(milliseconds: 200),
                opacity: _customElectrumServerVisible ? 1.0 : 0.0,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class SettingText extends StatelessWidget {
  final String label;

  const SettingText(
    this.label, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(label,
        style: TextStyle(
          color: Colors.white,
          fontSize: 15.0,
          fontWeight: FontWeight.w500,
        ));
  }
}
