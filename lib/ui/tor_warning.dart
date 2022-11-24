import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/home/settings/setting_toggle.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class TorWarning extends StatefulWidget {
  const TorWarning({Key? key}) : super(key: key);

  @override
  State<TorWarning> createState() => _TorWarningState();
}

class _TorWarningState extends State<TorWarning> {
  bool torEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topRight,
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
          Column(
            children: [
              Expanded(
                  child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 48)
                    .add(EdgeInsets.only(top: 18)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline_outlined,
                        color: EnvoyColors.darkCopper, size: 84),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodyText2?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                        children: [
                          TextSpan(
                            text: "Lore ispum ",
                          ),
                          TextSpan(
                            recognizer: TapGestureRecognizer()..onTap = () {},
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                    color: EnvoyColors.darkTeal,
                                    fontWeight: FontWeight.w800),
                            text: "Link ",
                          ),
                          TextSpan(
                            text:
                                "dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et",
                          ),
                        ],
                      ),
                    ),
                    Padding(padding: EdgeInsets.all(4)),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Turn off Tor",
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                  color: EnvoyColors.darkTeal,
                                  fontWeight: FontWeight.bold),
                        ),
                        Padding(padding: EdgeInsets.all(12)),
                        SettingToggle(() => torEnabled, (enabled) {
                          setState(() {
                            torEnabled = enabled;
                          });
                        }, inactiveColor: EnvoyColors.grey85)
                      ],
                    )
                  ],
                ),
              )),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 48, vertical: 14)
                    .add(EdgeInsets.only(bottom: 14, top: 14)),
                child: EnvoyButton(
                  "Retry connection",
                  light: false,
                  onTap: () {},
                ),
              ),
            ],
          ),
        ],
      ),
      height: 341,
      width: MediaQuery.of(context).size.width * 0.85,
    );
  }
}
