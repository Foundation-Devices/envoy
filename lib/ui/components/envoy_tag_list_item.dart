// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:flutter/widgets.dart';

enum FlexPriority { title, trailing }

class EnvoyInfoCardListItem extends StatefulWidget {
  final String title;
  final Widget icon;
  final Widget trailing;
  final bool priority;
  final Color? textColor;
  final FlexPriority spacingPriority;
  final bool centerSingleLineTitle;

  const EnvoyInfoCardListItem({
    super.key,
    required this.title,
    required this.icon,
    required this.trailing,
    this.priority = false,
    this.textColor,
    this.spacingPriority = FlexPriority.title,
    this.centerSingleLineTitle = false,
  });

  @override
  State<EnvoyInfoCardListItem> createState() => _EnvoyInfoCardListItemState();

  static TextStyle titleTextStyle(Color? textColor) {
    return EnvoyTypography.body.copyWith(
      color: textColor ?? EnvoyColors.textPrimary,
    );
  }
}

class _EnvoyInfoCardListItemState extends State<EnvoyInfoCardListItem> {
  final GlobalKey _titleTextKey = GlobalKey();
  bool isTitleSingleLine = false;

  @override
  void initState() {
    super.initState();
    if (widget.centerSingleLineTitle) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _checkIfSingleLineTitle());
    }
  }

  void _checkIfSingleLineTitle() {
    final TextStyle titleTextStyle =
        EnvoyInfoCardListItem.titleTextStyle(widget.textColor);

    final RenderBox renderBox =
        _titleTextKey.currentContext?.findRenderObject() as RenderBox;
    final double textHeight = renderBox.size.height;
    final double lineHeight =
        titleTextStyle.fontSize! * (titleTextStyle.height ?? 1.6);

    setState(() {
      isTitleSingleLine = textHeight <= lineHeight;
    });
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle titleTextStyle =
        EnvoyInfoCardListItem.titleTextStyle(widget.textColor);

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: EnvoySpacing.xs, vertical: EnvoySpacing.small),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: isTitleSingleLine
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
                top: isTitleSingleLine ? 0 : EnvoySpacing.xs / 2),
            child: SizedBox(
              width: 26,
              child: widget.icon,
            ),
          ),
          const SizedBox(width: EnvoySpacing.xs),
          Flexible(
            child: widget.spacingPriority == FlexPriority.trailing
                ? Row(
                    crossAxisAlignment: isTitleSingleLine
                        ? CrossAxisAlignment.center
                        : CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          widget.title,
                          key: _titleTextKey,
                          style: titleTextStyle,
                        ),
                      ),
                      const SizedBox(width: EnvoySpacing.small),
                      widget.trailing,
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.title,
                        key: _titleTextKey,
                        style: titleTextStyle,
                      ),
                      const SizedBox(width: EnvoySpacing.medium1),
                      Flexible(child: widget.trailing),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
