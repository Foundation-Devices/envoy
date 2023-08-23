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

  CustomCheckBox({
    required this.label,
    required this.isChecked,
    this.isRadio = false,
    this.onChanged,
  });

  @override
  _CustomCheckBoxState createState() => _CustomCheckBoxState();
}

class _CustomCheckBoxState extends State<CustomCheckBox> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: EnvoySpacing.medium1),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.label,
              style: EnvoyTypography.subtitle3Medium.copyWith(
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
                    ? EnvoyIcon(
                        EnvoyIcons.check,
                        color: EnvoyColors.textPrimaryInverse,
                        size: EnvoyIconSize.small,
                      )
                    : null,
              ),
            ),
          ],
        ),
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

  DialogCheckBox({
    required this.label,
    required this.isChecked,
    this.isRadio = false,
    this.onChanged,
  });

  @override
  _DialogCheckBoxState createState() => _DialogCheckBoxState();
}

class _DialogCheckBoxState extends State<DialogCheckBox> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: EnvoySpacing.medium1),
        child: Row(
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
                    ? EnvoyIcon(
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
                style: EnvoyTypography.body2Medium.copyWith(
                  color: EnvoyColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
