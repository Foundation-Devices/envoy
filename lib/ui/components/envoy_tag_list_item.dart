// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:flutter/scheduler.dart';
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
  final Widget? button;

  const EnvoyInfoCardListItem(
      {super.key,
      required this.title,
      required this.icon,
      required this.trailing,
      this.priority = false,
      this.textColor,
      this.spacingPriority = FlexPriority.title,
      this.button,
      this.centerSingleLineTitle = false});

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
  double trailingHeight = 50.0;
  double maxHeight = 70.0;

  @override
  void initState() {
    super.initState();
    if (widget.centerSingleLineTitle) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _checkIfSingleLineTitle());
    }
  }

  void _onTrailingSizeChanged(Size size) {
    setState(() {
      trailingHeight = size.height + EnvoySpacing.medium3;
    });
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
      child: widget.spacingPriority == FlexPriority.trailing
          ? WidgetSize(
              onChange: _onTrailingSizeChanged,
              child: Row(
                crossAxisAlignment: isTitleSingleLine
                    ? CrossAxisAlignment.center
                    : CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          crossAxisAlignment: isTitleSingleLine
                              ? CrossAxisAlignment.center
                              : CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                  top: isTitleSingleLine
                                      ? 0
                                      : EnvoySpacing.xs / 2),
                              child: SizedBox(
                                width: 26,
                                child: widget.icon,
                              ),
                            ),
                            const SizedBox(width: EnvoySpacing.xs),
                            Flexible(
                              child: Text(
                                widget.title,
                                key: _titleTextKey,
                                style: titleTextStyle,
                              ),
                            ),
                          ],
                        ),
                        if (widget.button != null) ...{
                          const Spacer(),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: EnvoySpacing.xs),
                            child: widget.button!,
                          )
                        }
                      ],
                    ),
                  ),
                  const SizedBox(width: EnvoySpacing.small),
                  widget.trailing,
                ],
              ),
            )
          : WidgetSize(
              onChange: _onTrailingSizeChanged,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    constraints: BoxConstraints(
                        maxHeight: trailingHeight > maxHeight
                            ? maxHeight
                            : trailingHeight),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          crossAxisAlignment: isTitleSingleLine
                              ? CrossAxisAlignment.center
                              : CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                  top: isTitleSingleLine
                                      ? 0
                                      : EnvoySpacing.xs / 2),
                              child: SizedBox(
                                width: 26,
                                child: widget.icon,
                              ),
                            ),
                            const SizedBox(width: EnvoySpacing.xs),
                            Text(
                              widget.title,
                              key: _titleTextKey,
                              style: titleTextStyle,
                            ),
                          ],
                        ),
                        if (widget.button != null) ...{
                          const Spacer(),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: EnvoySpacing.xs),
                            child: widget.button!,
                          ),
                        }
                      ],
                    ),
                  ),
                  const SizedBox(width: EnvoySpacing.small),
                  Flexible(
                    child: widget.trailing,
                  ),
                ],
              ),
            ),
    );
  }
}

class WidgetSize extends StatefulWidget {
  final Widget child;
  final Function(Size) onChange;

  const WidgetSize({
    super.key,
    required this.onChange,
    required this.child,
  });

  @override
  WidgetSizeState createState() => WidgetSizeState();
}

class WidgetSizeState extends State<WidgetSize> {
  final GlobalKey _widgetKey = GlobalKey();
  Size? _oldSize;

  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback(_postFrameCallback);
    return Container(
      key: _widgetKey,
      child: widget.child,
    );
  }

  void _postFrameCallback(_) {
    final context = _widgetKey.currentContext;
    if (context == null) return;

    final newSize = context.size;
    if (_oldSize == newSize) return;

    _oldSize = newSize;
    widget.onChange(newSize!);
  }
}
