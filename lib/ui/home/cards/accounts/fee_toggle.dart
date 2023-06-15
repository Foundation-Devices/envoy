// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/exchange_rate.dart';
import 'package:flutter/material.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/business/settings.dart';

class FeeToggle extends StatefulWidget {
  final int standardFee;
  final int boostFee;
  final int initialIndex;

  final Function(int, bool)? onToggled;

  FeeToggle(
      {Key? key,
      this.onToggled,
      this.initialIndex = 0,
      required this.standardFee,
      required this.boostFee})
      : super(key: key);

  @override
  State<FeeToggle> createState() => _FeeToggleState();
}

class _FeeToggleState extends State<FeeToggle> {
  int _selectedIndex = 0;
  late Widget _mainRow;

  String formatFee(int fee) {
    if (Settings().selectedFiat == null) {
      return fee.toString() + " Sats";
    } else {
      return fee.toString() +
          " Sats" +
          " ~ " +
          ExchangeRate().getFormattedAmount(fee);
    }
  }

  @override
  void initState() {
    _selectedIndex = widget.initialIndex;
    _mainRow = buildRow(ValueKey("init"));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 250),
      child: _mainRow,
    );
  }

  Row buildRow(ValueKey key) {
    return Row(
      key: key,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FeeToggleButton(
            selected: _selectedIndex == 0,
            icon: Icons.timer,
            label: S().envoy_fee_standard,
            topLabel: S().envoy_fee_60_min,
            bottomLabel: formatFee(widget.standardFee),
            onTap: () {
              setState(() {
                _selectedIndex = 0;
                _mainRow = buildRow(ValueKey("standard"));
              });
              if (widget.onToggled != null) {
                widget.onToggled!(widget.standardFee, false);
              }
            }),
        SizedBox(
          width: 50,
        ),
        FeeToggleButton(
            selected: _selectedIndex != 0,
            icon: Icons.fast_forward,
            label: S().envoy_fee_boost,
            topLabel: S().envoy_fee_10_min,
            bottomLabel: formatFee(widget.boostFee),
            onTap: () {
              setState(() {
                _selectedIndex = 1;
                _mainRow = buildRow(ValueKey("boost"));
              });

              if (widget.onToggled != null) {
                widget.onToggled!(widget.boostFee, true);
              }
            }),
      ],
    );
  }
}

class FeeToggleButton extends StatelessWidget {
  final bool selected;
  final IconData icon;
  final String label;
  final String? topLabel;
  final String? bottomLabel;

  final Function()? onTap;

  const FeeToggleButton({
    Key? key,
    required this.selected,
    this.topLabel,
    this.bottomLabel,
    required this.label,
    required this.icon,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 90,
            width: 90,
            decoration: BoxDecoration(
                border: selected
                    ? Border.all(
                        color: EnvoyColors.darkTeal,
                        width: 2,
                      )
                    : null,
                gradient: LinearGradient(
                    begin:
                        selected ? Alignment.topCenter : Alignment.bottomCenter,
                    end:
                        selected ? Alignment.bottomCenter : Alignment.topCenter,
                    colors: [Colors.white12, Colors.black12]),
                borderRadius: BorderRadius.circular(15)),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon,
                      color: selected ? EnvoyColors.teal : EnvoyColors.grey),
                  Text(
                    label,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: selected ? EnvoyColors.teal : EnvoyColors.grey),
                  )
                ],
              ),
            ),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        if (topLabel != null)
          Text(
            topLabel!,
            style: TextStyle(
                color: selected ? EnvoyColors.teal : EnvoyColors.grey,
                fontWeight: FontWeight.w600),
          ),
        if (bottomLabel != null)
          Text(bottomLabel!,
              style: TextStyle(
                  fontSize: 12,
                  color: selected ? Colors.black : EnvoyColors.grey,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w300)),
      ],
    );
  }
}
