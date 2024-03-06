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
  BuildContext context,
  String content,
  primaryButtonLabel,
  Function(BuildContext context)? onPrimaryButtonTap, {
  EnvoyIcons? icon,
  String? title,
  String? secondaryButtonLabel,
  Function(BuildContext context)? onSecondaryButtonTap,
  PopUpState? typeOfMessage,
  String? checkBoxText,
  onCheckBoxChanged,
  bool? checkedValue,
  bool dismissible = true,
}) =>
    showEnvoyDialog(
        context: context,
        useRootNavigator: true,
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
            checkedValue: checkedValue),
        dismissible: dismissible);

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
    required this.onCheckBoxChanged,
    this.checkedValue = true,
  });

  final String? title;
  final String content;
  final EnvoyIcons? icon;
  final String primaryButtonLabel;
  final String? secondaryButtonLabel;
  final Function(BuildContext context)? onPrimaryButtonTap;
  final Function(BuildContext context)? onSecondaryButtonTap;
  final PopUpState? typeOfMessage;
  final String? checkBoxText;
  final Function(bool? checked) onCheckBoxChanged;
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
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(EnvoySpacing.medium2),
        ),
        color: EnvoyColors.textPrimaryInverse,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            vertical: EnvoySpacing.medium3, horizontal: EnvoySpacing.medium2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (widget.icon != null)
              Padding(
                padding: const EdgeInsets.only(bottom: EnvoySpacing.medium3),
                child: EnvoyIcon(
                  widget.icon!,
                  size: EnvoyIconSize.big,
                  color: _color,
                ),
              ),
            if (widget.title != null)
              Padding(
                padding: const EdgeInsets.only(bottom: EnvoySpacing.medium1),
                child: Text(
                  widget.title!,
                  style: EnvoyTypography.subheading,
                  textAlign: TextAlign.center,
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(bottom: EnvoySpacing.medium3),
              child: Text(
                widget.content,
                style: EnvoyTypography.body,
                textAlign: TextAlign.center,
              ),
            ),
            if (widget.checkBoxText != null)
              Padding(
                padding: const EdgeInsets.only(bottom: EnvoySpacing.medium3),
                child: DialogCheckBox(
                  label: widget.checkBoxText!,
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
            if (widget.secondaryButtonLabel != null)
              Padding(
                padding: const EdgeInsets.only(bottom: EnvoySpacing.medium1),
                child: EnvoyButton(
                    label: widget.secondaryButtonLabel!,
                    type: ButtonType.secondary,
                    state: ButtonState.defaultState,
                    onTap: () {
                      if (widget.onSecondaryButtonTap != null) {
                        widget.onSecondaryButtonTap!(context);
                      }
                    }),
              ),
            EnvoyButton(
                label: widget.primaryButtonLabel,
                type: ButtonType.primary,
                state: ButtonState.defaultState,
                onTap: () {
                  widget.onPrimaryButtonTap?.call(context);
                }),
          ],
        ),
      ),
    );
  }
}
