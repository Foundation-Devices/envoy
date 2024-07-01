// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:flutter/material.dart';

enum EnvoyButtonTypes { primary, secondary, tertiary, primaryModal }

class EnvoyButton extends StatefulWidget {
  final String label;
  final Function()? onTap;
  final EnvoyButtonTypes type;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final TextStyle? textStyle;
  final FontWeight? fontWeight;
  final bool enabled;

  const EnvoyButton(
    this.label, {
    super.key,
    this.onTap,
    this.type = EnvoyButtonTypes.primary,
    this.textStyle,
    this.borderRadius,
    this.fontWeight,
    this.backgroundColor,
    this.enabled = true,
  });

  @override
  State<EnvoyButton> createState() => _EnvoyButtonState();
}

class _EnvoyButtonState extends State<EnvoyButton> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    TextStyle? textStyle = widget.textStyle;
    if (widget.textStyle == null) {
      Color textColor = EnvoyColors.accentPrimary;
      switch (widget.type) {
        case EnvoyButtonTypes.primary:
          textColor = Colors.white;
          break;
        case EnvoyButtonTypes.secondary:
          textColor = EnvoyColors.accentPrimary;
          break;
        case EnvoyButtonTypes.tertiary:
          textColor = EnvoyColors.accentPrimary;
          break;
        case EnvoyButtonTypes.primaryModal:
          textColor = Colors.white;
          break;
      }
      textStyle = Theme.of(context).textTheme.bodySmall!.copyWith(
            color: textColor,
            fontSize: 14.0,
            fontWeight: widget.fontWeight ?? FontWeight.w700,
          );
    }
    return AnimatedScale(
      duration: const Duration(milliseconds: 200),
      scale: isPressed ? 0.97 : 1.0,
      curve: Curves.easeIn,
      child: GestureDetector(
        onTap: widget.enabled ? widget.onTap : null,
        onTapDown: (cn) {
          setState(() {
            isPressed = true;
          });
        },
        onTapUp: (cn) {
          setState(() {
            isPressed = false;
          });
        },
        onTapCancel: () {
          setState(() {
            isPressed = false;
          });
        },
        child: Stack(
          children: [
            Container(
                height: 40.0,
                decoration: _getBoxDecoration(),
                child: Center(
                    child: Text(
                  widget.label,
                  style: textStyle,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ))),
            if (!widget.enabled)
              Positioned.fill(
                child: Container(
                  color: EnvoyColors.textPrimaryInverse.withOpacity(0.5),
                ),
              ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _getBoxDecoration() {
    switch (widget.type) {
      case EnvoyButtonTypes.primary:
        {
          return BoxDecoration(
              color: widget.backgroundColor ?? EnvoyColors.accentPrimary,
              borderRadius: widget.borderRadius ??
                  const BorderRadius.all(Radius.circular(13.0)));
        }
      case EnvoyButtonTypes.secondary:
        {
          return BoxDecoration(
              color: widget.backgroundColor ?? EnvoyColors.surface3,
              borderRadius: widget.borderRadius ??
                  const BorderRadius.all(Radius.circular(13.0)));
        }

      case EnvoyButtonTypes.tertiary:
        return BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: widget.borderRadius ??
                const BorderRadius.all(Radius.circular(13.0)));

      case EnvoyButtonTypes.primaryModal:
        {
          return BoxDecoration(
              color: EnvoyColors.accentPrimary,
              borderRadius: widget.borderRadius ??
                  const BorderRadius.all(Radius.circular(13.0)));
        }
    }
  }
}
