// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:flutter/material.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/components/checkbox.dart';

enum PopUpState {
  deafult,
  warning,
  danger,
}

void showEnvoyPopUp(
    BuildContext context, content, primaryButtonLabel, onPrimaryButtonTap,
    {icon,
    title,
    secondaryButtonLabel,
    onSecondaryButtonTap,
    typeOfMessage,
    checkBoxText,
    onCheckBoxChanged,
    checkedValue}) {
  showEnvoyDialog(
      context: context,
      dialog: EnvoyPopUp(
          title: title,
          content: content,
          icon: icon,
          primaryButtonLabel: primaryButtonLabel,
          onPrimaryButtonTap: onPrimaryButtonTap,
          secondaryButtonLabel: secondaryButtonLabel,
          onSecondaryButtonTap: onSecondaryButtonTap,
          typeOfMessage: typeOfMessage,
          checkBoxText: checkBoxText,
          onCheckBoxChanged: onCheckBoxChanged,
          checkedValue: checkedValue));
}

//ignore: must_be_immutable
class EnvoyPopUp extends StatefulWidget {
  EnvoyPopUp({
    super.key,
    this.icon,
    this.title,
    required this.content,
    required this.primaryButtonLabel,
    this.secondaryButtonLabel,
    this.onPrimaryButtonTap,
    this.onSecondaryButtonTap,
    this.typeOfMessage = PopUpState.deafult,
    this.checkBoxText,
    this.onCheckBoxChanged,
    this.checkedValue = true,
  });

  final String? title;
  final String content;
  final icon;
  final String primaryButtonLabel;
  final secondaryButtonLabel;
  final onPrimaryButtonTap;
  final onSecondaryButtonTap;
  final PopUpState? typeOfMessage;
  final checkBoxText;
  final onCheckBoxChanged;
  bool? checkedValue;

  @override
  State<EnvoyPopUp> createState() => _EnvoyPopUpState();
}

class _EnvoyPopUpState extends State<EnvoyPopUp> {
  Color _color = EnvoyColors.accentPrimary;

  @override
  Widget build(BuildContext context) {
    switch (widget.typeOfMessage) {
      case PopUpState.deafult:
        {
          setState(() {
            _color = EnvoyColors.accentPrimary;
          });
        }
        break;

      case PopUpState.danger:
        {
          setState(() {
            _color = EnvoyColors.danger;
          });
        }
        break;
      case PopUpState.warning:
        {
          setState(() {
            _color = EnvoyColors.warning;
          });
        }
        break;
      case null:
        {
          setState(() {
            _color = EnvoyColors.accentPrimary;
          });
        }
        break;
    }
    return Container(
      width: MediaQuery.of(context).size.width * 0.75,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(EnvoySpacing.medium2),
        ),
        color: EnvoyColors.textPrimaryInverse,
      ),
      child: Padding(
        padding: EdgeInsets.all(EnvoySpacing.medium2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (widget.icon != null)
              EnvoyIcon(
                widget.icon,
                size: EnvoyIconSize.big,
                color: _color,
              ),
            if (widget.title != null)
              Text(
                widget.title!,
                style: EnvoyTypography.subtitle1Semibold,
              ),
            Padding(
              padding: const EdgeInsets.all(EnvoySpacing.medium1),
              child: Text(
                widget.content,
                textAlign: TextAlign.center,
                style: EnvoyTypography.caption1Medium.copyWith(
                  color: EnvoyColors.textPrimary,
                ),
              ),
            ),
            if (widget.checkBoxText != null)
              DialogCheckBox(
                label: widget.checkBoxText,
                isChecked:
                    widget.checkedValue == null ? true : widget.checkedValue!,
                onChanged: (isChecked) {
                  setState(() {
                    widget.checkedValue = !widget.checkedValue!;
                    widget.onCheckBoxChanged(isChecked);
                  });
                },
              ),
            Padding(
              padding: const EdgeInsets.only(bottom: EnvoySpacing.medium1),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: EnvoyColors.textPrimaryInverse,
                  borderRadius: BorderRadius.circular(EnvoySpacing.small),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: EnvoySpacing.small,
                      vertical: EnvoySpacing.xs),
                  child: TextButton(
                    onPressed: () {
                      widget.onPrimaryButtonTap();
                      Navigator.pop(
                          context); // Close the dialog when cancel is pressed
                    },
                    child: Text(
                      widget.primaryButtonLabel,
                      style: EnvoyTypography.subtitle2Medium.copyWith(
                        color: EnvoyColors.accentPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (widget.secondaryButtonLabel != null)
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: EnvoyColors.accentPrimary,
                  borderRadius: BorderRadius.circular(EnvoySpacing.small),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: EnvoySpacing.small,
                      vertical: EnvoySpacing.xs),
                  child: TextButton(
                    onPressed: () {
                      if (widget.onSecondaryButtonTap != null) {
                        widget.onSecondaryButtonTap();
                      }
                    },
                    child: Text(
                      widget.secondaryButtonLabel,
                      style: EnvoyTypography.subtitle2Medium.copyWith(
                        color: EnvoyColors.textPrimaryInverse,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
