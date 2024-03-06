// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:flutter/material.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';

class CustomCheckBox extends StatefulWidget {
  final String label;
  final bool isChecked;
  final bool isRadio;
  final ValueChanged<bool?>? onChanged;

  const CustomCheckBox({super.key,
    required this.label,
    required this.isChecked,
    this.isRadio = false,
    this.onChanged,
  });

  @override
  CustomCheckBoxState createState() => CustomCheckBoxState();
}

class CustomCheckBoxState extends State<CustomCheckBox> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: EnvoySpacing.medium1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.label,
            style: EnvoyTypography.body.copyWith(
              color: EnvoyColors.textPrimary,
            ),
          ),
          GestureDetector(
            onTap: () {
              widget.onChanged?.call(!widget.isChecked);
            },
            child: Container(
              width: EnvoySpacing.medium2,
              height: EnvoySpacing.medium2,
              decoration: BoxDecoration(
                borderRadius: widget.isRadio
                    ? BorderRadius.circular(EnvoySpacing.medium2)
                    : BorderRadius.circular(EnvoySpacing.xs),
                border: Border.all(
                  color: widget.isChecked
                      ? EnvoyColors.accentPrimary
                      : EnvoyColors.border1,
                  width: 1.0,
                ),
                color: widget.isChecked
                    ? EnvoyColors.accentPrimary
                    : EnvoyColors.surface1,
              ),
              child: widget.isChecked
                  ? const EnvoyIcon(
                      EnvoyIcons.check,
                      color: EnvoyColors.textPrimaryInverse,
                      size: EnvoyIconSize.small,
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

//ignore: must_be_immutable
class DialogCheckBox extends StatefulWidget {
  final String label;
  bool isChecked;
  final bool isRadio;
  final ValueChanged<bool?>? onChanged;

  DialogCheckBox({super.key,
    required this.label,
    required this.isChecked,
    this.isRadio = false,
    this.onChanged,
  });

  @override
  DialogCheckBoxState createState() => DialogCheckBoxState();
}

class DialogCheckBoxState extends State<DialogCheckBox> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              widget.isChecked = !widget.isChecked;
            });
            widget.onChanged!(!widget.isChecked);
          },
          child: Container(
            width: EnvoySpacing.medium2,
            height: EnvoySpacing.medium2,
            decoration: BoxDecoration(
              borderRadius: widget.isRadio
                  ? BorderRadius.circular(EnvoySpacing.medium2)
                  : BorderRadius.circular(EnvoySpacing.xs),
              border: Border.all(
                color: widget.isChecked
                    ? EnvoyColors.accentPrimary
                    : EnvoyColors.border1,
                width: 1.0,
              ),
              color: widget.isChecked
                  ? EnvoyColors.accentPrimary
                  : EnvoyColors.surface1,
            ),
            child: widget.isChecked
                ? const EnvoyIcon(
                    EnvoyIcons.check,
                    color: EnvoyColors.textPrimaryInverse,
                    size: EnvoyIconSize.small,
                  )
                : null,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: EnvoySpacing.medium1),
          child: Text(
            widget.label,
            style: EnvoyTypography.button.copyWith(
              color: EnvoyColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
