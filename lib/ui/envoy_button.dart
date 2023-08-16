// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/envoy_colors.dart';
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
  final bool? readOnly;
  final bool enabled;

  EnvoyButton(
    this.label, {
    this.onTap,
    this.readOnly = false,
    this.type = EnvoyButtonTypes.primary,
    this.textStyle,
    this.borderRadius,
    this.fontWeight = null,
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
    TextStyle? _textStyle = widget.textStyle;
    if (widget.textStyle == null) {
      Color textColor = EnvoyColors.darkTeal;
      switch (this.widget.type) {
        case EnvoyButtonTypes.primary:
          textColor = Colors.white;
          break;
        case EnvoyButtonTypes.secondary:
          textColor = EnvoyColors.darkTeal;
          break;
        case EnvoyButtonTypes.tertiary:
          textColor = EnvoyColors.darkTeal;
          break;
        case EnvoyButtonTypes.primaryModal:
          textColor = Colors.white;
          break;
      }
      _textStyle = Theme.of(context).textTheme.bodySmall!.copyWith(
            color: textColor,
            fontSize: 14.0,
            fontWeight:
                widget.fontWeight != null ? widget.fontWeight : FontWeight.w700,
          );
    }
    return AnimatedScale(
      duration: Duration(milliseconds: 200),
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
        child: Container(
            height: 40.0,
            decoration: _getBoxDecoration(),
            child: Center(
                child: Text(
              widget.label,
              style: _textStyle,
              textAlign: TextAlign.center,
            ))),
      ),
    );
  }

  BoxDecoration _getBoxDecoration() {
    switch (this.widget.type) {
      case EnvoyButtonTypes.primary:
        {
          if (widget.readOnly == true) {
            return BoxDecoration(
                color: EnvoyColors.grey85,
                borderRadius: this.widget.borderRadius ??
                    BorderRadius.all(Radius.circular(13.0)));
          }
          var gradientColors = [EnvoyColors.teal, EnvoyColors.darkTeal];
          return BoxDecoration(
              color: this.widget.backgroundColor,
              gradient: widget.backgroundColor == null
                  ? LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: gradientColors)
                  : null,
              borderRadius: this.widget.borderRadius ??
                  BorderRadius.all(Radius.circular(13.0)));
        }
      case EnvoyButtonTypes.secondary:
        {
          return BoxDecoration(
              color: this.widget.backgroundColor ?? EnvoyColors.grey15,
              borderRadius: this.widget.borderRadius ??
                  BorderRadius.all(Radius.circular(13.0)));
        }

      case EnvoyButtonTypes.tertiary:
        return BoxDecoration(
            color: this.widget.backgroundColor,
            borderRadius: this.widget.borderRadius ??
                BorderRadius.all(Radius.circular(13.0)));

      case EnvoyButtonTypes.primaryModal:
        {
          if (widget.readOnly == true) {
            return BoxDecoration(
                color: EnvoyColors.grey85,
                borderRadius: this.widget.borderRadius ??
                    BorderRadius.all(Radius.circular(13.0)));
          }
          return BoxDecoration(
              color: EnvoyColors.darkTeal,
              borderRadius: this.widget.borderRadius ??
                  BorderRadius.all(Radius.circular(13.0)));
        }
    }
  }
}
