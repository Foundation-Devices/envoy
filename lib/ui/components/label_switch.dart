// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:flutter/material.dart';

class LabelSwitchOption {
  final String label;
  final EnvoyIcons? icon;

  const LabelSwitchOption({
    required this.label,
    this.icon,
  });
}

class LabelSwitch extends StatefulWidget {
  final LabelSwitchOption trueOption;
  final LabelSwitchOption falseOption;
  final bool initialValue;
  final ValueChanged<bool> onChanged;

  const LabelSwitch({
    super.key,
    required this.trueOption,
    required this.falseOption,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  State<LabelSwitch> createState() => _LabelSwitchState();
}

class _LabelSwitchState extends State<LabelSwitch> {
  late bool selected;

  @override
  void initState() {
    super.initState();
    selected = widget.initialValue;
  }

  void _onTap(bool value) {
    setState(() {
      selected = value;
    });
    widget.onChanged(value);
  }

  Widget _buildOption(LabelSwitchOption option, bool isActive, bool value) {
    Color color = isActive ? EnvoyColors.solidWhite : EnvoyColors.textTertiary;
    return Expanded(
      child: GestureDetector(
        onTap: () => _onTap(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: EnvoySpacing.small),
          height: EnvoySpacing.large1,
          color: Colors.transparent,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (option.icon != null)
                EnvoyIcon(
                  option.icon!,
                  color: color,
                ),
              if (option.icon != null) SizedBox(width: EnvoySpacing.xs),
              Text(
                option.label,
                style: EnvoyTypography.info.copyWith(
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTrue = selected;
    return Container(
      height: EnvoySpacing.large1,
      decoration: BoxDecoration(
        color: EnvoyColors.surface1,
        borderRadius: BorderRadius.circular(34),
      ),
      padding: const EdgeInsets.all(2),
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 200),
            alignment: isTrue ? Alignment.centerLeft : Alignment.centerRight,
            child: Container(
              width:
                  MediaQuery.of(context).size.width / 2 - 32, // or fixed width
              height: double.infinity,
              decoration: BoxDecoration(
                color: EnvoyColors.accentPrimary,
                borderRadius: BorderRadius.circular(EnvoySpacing.medium3),
              ),
            ),
          ),
          Row(
            children: [
              _buildOption(widget.trueOption, isTrue, true),
              _buildOption(widget.falseOption, !isTrue, false),
            ],
          ),
        ],
      ),
    );
  }
}
