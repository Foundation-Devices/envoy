import 'package:envoy/business/exchange_rate.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/ui/home/settings/setting_dropdown.dart';
import 'package:envoy/ui/home/settings/electrum_server_entry.dart';
import 'package:envoy/ui/home/settings/setting_toggle.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

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
                SettingText("Fiat Currency"),
                SettingDropdown(supportedFiat.map((e) => e.code).toList(),
                    s.displayFiat, s.setDisplayFiat),
              ],
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SettingText("View Amount in Sats"),
                SettingToggle(s.displayUnitSat, s.setDisplayUnitSat),
              ],
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SettingText("Tor Connectivity"),
                SettingToggle(s.torEnabled, s.setTorEnabled),
              ],
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SettingText("Custom Electrum Server"),
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
