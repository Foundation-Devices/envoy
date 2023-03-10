// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/envoy_colors.dart';
import 'package:flutter/material.dart';

enum EnvoyButtonTypes {
  PRIMARY,
  SECONDARY,
  TERTIARY,
}

class EnvoyButton extends StatefulWidget {
  final String label;
  final Function()? onTap;
  final EnvoyButtonTypes type;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final TextStyle? textStyle;

  EnvoyButton(this.label,
      {this.onTap,
      this.type = EnvoyButtonTypes.PRIMARY,
      this.textStyle,
      this.borderRadius,
      this.backgroundColor});

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
        case EnvoyButtonTypes.PRIMARY:
          textColor = Colors.white;
          break;
        case EnvoyButtonTypes.SECONDARY:
          textColor = EnvoyColors.darkTeal;
          break;
        case EnvoyButtonTypes.TERTIARY:
          textColor = EnvoyColors.darkTeal;
          break;
      }
      _textStyle = TextStyle(
        color: textColor,
        fontSize: 14.0,
        fontWeight: FontWeight.w500,
      );
    }
    return AnimatedScale(
      duration: Duration(milliseconds: 200),
      scale: isPressed ? 0.97 : 1.0,
      curve: Curves.easeIn,
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (cn) {
          setState(() {
            isPressed = true;
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
      case EnvoyButtonTypes.PRIMARY:
        {
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
      case EnvoyButtonTypes.SECONDARY:
        {
          return BoxDecoration(
              color: this.widget.backgroundColor ?? EnvoyColors.grey15,
              borderRadius: this.widget.borderRadius ??
                  BorderRadius.all(Radius.circular(13.0)));
        }

      case EnvoyButtonTypes.TERTIARY:
        return BoxDecoration(
            color: this.widget.backgroundColor,
            borderRadius: this.widget.borderRadius ??
                BorderRadius.all(Radius.circular(13.0)));
    }
  }
}
