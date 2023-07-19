import 'package:envoy/ui/envoy_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CoinTagSwitch extends StatefulWidget {
  final CoinTagSwitchState value;

  const CoinTagSwitch({super.key, required this.value});

  @override
  State<CoinTagSwitch> createState() => _CoinTagSwitchState();
}

enum CoinTagSwitchState {
  on,
  partial,
  off,
}

class _CoinTagSwitchState extends State<CoinTagSwitch> {
  @override
  Widget build(BuildContext context) {
    Alignment knobAlign = Alignment.centerLeft;

    Color gradientEnd = Color(0xFFC8C8C8);
    Color gradientStart = Color(0xFFC8C8C8);

    switch (widget.value) {
      case CoinTagSwitchState.on:
        knobAlign = Alignment.centerRight;
        gradientEnd = EnvoyColors.darkTeal;
        gradientStart = EnvoyColors.darkTeal;
        break;
      case CoinTagSwitchState.partial:
        gradientEnd = EnvoyColors.darkTeal;
        gradientStart = Color(0xFFC8C8C8);
        knobAlign = Alignment.center;
        break;
      case CoinTagSwitchState.off:
        gradientEnd = Color(0xFFC8C8C8);
        gradientStart = Color(0xFFC8C8C8);
        knobAlign = Alignment.centerLeft;
        break;
    }

    BoxDecoration boxDecoration = BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [gradientStart, gradientStart, gradientEnd],
        ));

    return FittedBox(
      fit: BoxFit.fitWidth,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.decelerate,
        width: 48,
        decoration: boxDecoration,
        child: AnimatedAlign(
            alignment: knobAlign,
            curve: Curves.decelerate,
            duration: Duration(milliseconds: 300),
            child: Padding(
              padding: const EdgeInsets.all(3.0),
              child: Material(
                elevation: 1,
                shape: CircleBorder(),
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        "assets/icons/ic_filter_funnel.svg",
                        width: 10,
                        height: 10,
                        fit: BoxFit.fitHeight,
                        color: widget.value == CoinTagSwitchState.partial ? EnvoyColors.darkTeal : EnvoyColors.transparent,
                      ),
                    ],
                  ),
                ),
              ),
            )),
      ),
    );
  }
}
