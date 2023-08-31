// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:flutter/material.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/components/button.dart';
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
      width: MediaQuery.of(context).size.width * 0.9,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(EnvoySpacing.medium2),
        ),
        color: EnvoyColors.textPrimaryInverse,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
            vertical: EnvoySpacing.medium3, horizontal: EnvoySpacing.medium1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (widget.icon != null)
              Padding(
                padding: const EdgeInsets.only(bottom: EnvoySpacing.medium3),
                child: EnvoyIcon(
                  widget.icon,
                  size: EnvoyIconSize.big,
                  color: _color,
                ),
              ),
            if (widget.title != null)
              Text(
                widget.title!,
                style: EnvoyTypography.subtitle1Semibold,
              ),
            Padding(
              padding: const EdgeInsets.only(
                  top: EnvoySpacing.small, bottom: EnvoySpacing.medium3),
              child: Text(
                widget.content,
                style: EnvoyTypography.body2Medium,
              ),
            ),
            if (widget.checkBoxText != null)
              Padding(
                padding: const EdgeInsets.only(bottom: EnvoySpacing.medium3),
                child: DialogCheckBox(
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
              ),
            EnvoyButton(
                label: widget.primaryButtonLabel,
                type: ButtonType.primary,
                state: ButtonState.default_state,
                // icon: EnvoyIcons.info,
                onTap: () {
                  widget.onPrimaryButtonTap();
                  Navigator.pop(context);
                }),
            if (widget.secondaryButtonLabel != null)
              Padding(
                padding: const EdgeInsets.only(top: EnvoySpacing.medium1),
                child: EnvoyButton(
                    label: widget.secondaryButtonLabel,
                    type: ButtonType.secondary,
                    state: ButtonState.default_state,
                    onTap: () {
                      if (widget.onSecondaryButtonTap != null) {
                        widget.onSecondaryButtonTap();
                      }
                    }),
              ),
          ],
        ),
      ),
    );
  }
}
