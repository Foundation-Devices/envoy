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
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/envoy_colors.dart' as old_color;
import 'package:envoy/ui/envoy_button.dart';

enum PopUpState {
  deafult,
  warning,
  danger,
}

Future showEnvoyPopUp(
  BuildContext context,
  String? content,
  String primaryButtonLabel,
  Function(BuildContext context)? onPrimaryButtonTap, {
  EnvoyIcons? icon,
  String? title,
  String? secondaryButtonLabel,
  Function(BuildContext context)? onSecondaryButtonTap,
  String? tertiaryButtonLabel,
  Color? tertiaryButtonTextColor,
  Function(BuildContext context)? onTertiaryButtonTap,
  PopUpState? typeOfMessage,
  String? checkBoxText,
  Function(bool checked)? onCheckBoxChanged,
  bool? checkedValue,
  bool dismissible = true,
  Function? onLearnMore,
  String? learnMoreText,
  Widget? customWidget,
  bool? showCloseButton,
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
          tertiaryButtonLabel: tertiaryButtonLabel,
          tertiaryButtonTextColor: tertiaryButtonTextColor,
          onTertiaryButtonTap: onTertiaryButtonTap,
          typeOfMessage: typeOfMessage,
          checkBoxText: checkBoxText,
          onCheckBoxChanged: onCheckBoxChanged,
          checkedValue: checkedValue ?? true,
          onLearnMore: onLearnMore,
          learnMoreText: learnMoreText ?? '',
          customWidget: customWidget,
          showCloseButton: showCloseButton ?? true,
        ),
        dismissible: dismissible);

//ignore: must_be_immutable
class EnvoyPopUp extends StatefulWidget {
  EnvoyPopUp({
    super.key,
    this.icon,
    this.title,
    this.content,
    required this.primaryButtonLabel,
    this.secondaryButtonLabel,
    this.tertiaryButtonLabel,
    this.tertiaryButtonTextColor,
    this.onPrimaryButtonTap,
    this.onSecondaryButtonTap,
    this.onTertiaryButtonTap,
    this.typeOfMessage = PopUpState.deafult,
    this.checkBoxText,
    this.onCheckBoxChanged,
    this.checkedValue = true,
    this.onLearnMore,
    this.learnMoreText = '',
    this.customWidget,
    this.showCloseButton = true,
    this.primaryButtonColor,
  });

  final String? title;
  final String? content;
  final EnvoyIcons? icon;
  final String primaryButtonLabel;
  final String? secondaryButtonLabel;
  final String? tertiaryButtonLabel;
  final Color? tertiaryButtonTextColor;
  final Function(BuildContext context)? onPrimaryButtonTap;
  final Function(BuildContext context)? onSecondaryButtonTap;
  final Function(BuildContext context)? onTertiaryButtonTap;
  final PopUpState? typeOfMessage;
  final String? checkBoxText;
  final Function(bool checked)? onCheckBoxChanged;
  bool? checkedValue;
  final Function? onLearnMore;
  final String learnMoreText;
  final Widget? customWidget;
  final bool showCloseButton;
  final Color? primaryButtonColor;

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
            _color = old_color.EnvoyColors.listAccountTileColors[3];
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
      width: MediaQuery.of(context).size.width * 0.85,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(EnvoySpacing.medium2),
        ),
        color: EnvoyColors.textPrimaryInverse,
      ),
      child: Padding(
        padding: const EdgeInsets.all(EnvoySpacing.medium2),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (widget.showCloseButton)
                Padding(
                  padding: const EdgeInsets.only(bottom: EnvoySpacing.xs),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ),
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
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: EnvoyTypography.heading,
                    textAlign: TextAlign.center,
                  ),
                ),
              if (widget.content != null)
                Padding(
                  padding: EdgeInsets.only(
                      bottom: widget.onLearnMore == null &&
                              widget.customWidget == null
                          ? EnvoySpacing.medium3
                          : EnvoySpacing.medium1),
                  child: Text(
                    widget.content!,
                    style: EnvoyTypography.info,
                    textAlign: TextAlign.center,
                  ),
                ),
              if (widget.customWidget != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: EnvoySpacing.medium1),
                  child: widget.customWidget!,
                ),
              if (widget.onLearnMore != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: EnvoySpacing.medium3),
                  child: GestureDetector(
                    onTap: () {
                      widget.onLearnMore!();
                    },
                    child: Text(
                      widget.learnMoreText.isEmpty
                          ? S().component_learnMore
                          : widget.learnMoreText,
                      style: EnvoyTypography.button
                          .copyWith(color: EnvoyColors.accentPrimary),
                    ),
                  ),
                ),
              if (widget.checkBoxText != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: EnvoySpacing.medium3),
                  child: DialogCheckBox(
                    label: widget.checkBoxText!,
                    isChecked: widget.checkedValue == null
                        ? true
                        : widget.checkedValue!,
                    onChanged: (isChecked) {
                      setState(() {
                        widget.checkedValue = !widget.checkedValue!;
                        if (widget.onCheckBoxChanged != null) {
                          widget.onCheckBoxChanged!(isChecked!);
                        }
                      });
                    },
                  ),
                ),
              if (widget.tertiaryButtonLabel != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: EnvoySpacing.medium1),
                  child: EnvoyButton(widget.tertiaryButtonLabel!,
                      type: EnvoyButtonTypes.tertiary, onTap: () {
                    if (widget.onTertiaryButtonTap != null) {
                      widget.onTertiaryButtonTap!(context);
                    }
                  }),
                ),
              if (widget.secondaryButtonLabel != null)
                Padding(
                  padding: EdgeInsets.only(
                      bottom: widget.onPrimaryButtonTap == null
                          ? 0
                          : EnvoySpacing.medium1),
                  child: EnvoyButton(widget.secondaryButtonLabel!,
                      type: EnvoyButtonTypes.secondary, onTap: () {
                    if (widget.onSecondaryButtonTap != null) {
                      widget.onSecondaryButtonTap!(context);
                    }
                  }),
                ),
              if (widget.onPrimaryButtonTap != null)
                EnvoyButton(widget.primaryButtonLabel,
                    type: EnvoyButtonTypes.primary, onTap: () {
                  widget.onPrimaryButtonTap?.call(context);
                }, backgroundColor: widget.primaryButtonColor),
            ],
          ),
        ),
      ),
    );
  }
}
