// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

enum FlexPriority { title, trailing }

class EnvoyInfoCardListItem extends StatefulWidget {
  final String title;
  final Widget icon;
  final Widget trailing;
  final bool priority;
  final Color? textColor;
  final FlexPriority spacingPriority;

  const EnvoyInfoCardListItem({
    super.key,
    required this.title,
    required this.icon,
    required this.trailing,
    this.priority = false,
    this.textColor,
    this.spacingPriority = FlexPriority.title,
  });

  @override
  State<EnvoyInfoCardListItem> createState() => _EnvoyInfoCardListItemState();
}

class _EnvoyInfoCardListItemState extends State<EnvoyInfoCardListItem> {
  double iconWidth = 26;
  double titleWidth = 0;
  double trailingWidth = 0;
  int flexSpan = 30;

  int measureCount = 0;
  double maxTrailingWidth = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measureTitleWidth();
    });
  }

  void _measureTitleWidth() {
    TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: widget.title,
        style: EnvoyTypography.body,
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();

    setState(() {
      titleWidth = textPainter.size.width;
    });
  }

  void _onTrailingSizeChange(Size size) {
    setState(() {
      measureCount++;
      maxTrailingWidth =
          size.width > maxTrailingWidth ? size.width : maxTrailingWidth;

      if (measureCount < 3) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _reMeasureTrailingWidth();
          }
        });
      } else {
        trailingWidth = maxTrailingWidth;
      }
    });
  }

  void _reMeasureTrailingWidth() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double iconAndTitleWidth = titleWidth + iconWidth + EnvoySpacing.medium1;

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: EnvoySpacing.xs, vertical: EnvoySpacing.small),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          double availableWidth = constraints.maxWidth - EnvoySpacing.medium2;

          int flexTrailing = 0;
          int flexTitle = 0;

          if (widget.spacingPriority == FlexPriority.title) {
            flexTrailing =
                (((availableWidth - iconAndTitleWidth) / availableWidth) *
                        flexSpan)
                    .round()
                    .toInt();
            flexTitle = flexSpan - flexTrailing;
          } else {
            flexTitle =
                (((availableWidth - trailingWidth) / availableWidth) * flexSpan)
                    .round()
                    .toInt();
            flexTrailing = flexSpan - flexTitle;
          }

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                flex: flexTitle,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: EnvoySpacing.xs / 2),
                      child: SizedBox(
                        width: iconWidth,
                        child: widget.icon,
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: EnvoySpacing.xs,
                        ),
                        child: Text(
                          widget.title,
                          style: EnvoyTypography.body.copyWith(
                              color:
                                  widget.textColor ?? EnvoyColors.textPrimary),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                flex: flexTrailing,
                child: MeasureSize(
                  onChange: _onTrailingSizeChange,
                  child: widget.trailing,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

typedef OnWidgetSizeChange = void Function(Size size);

class MeasureSizeRenderObject extends RenderProxyBox {
  Size? oldSize;
  final OnWidgetSizeChange onChange;

  MeasureSizeRenderObject(this.onChange);

  @override
  void performLayout() {
    super.performLayout();
    Size newSize = child?.size ?? Size.zero;
    if (oldSize == newSize) return;

    oldSize = newSize;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onChange(newSize);
    });
  }
}

class MeasureSize extends SingleChildRenderObjectWidget {
  final OnWidgetSizeChange onChange;

  const MeasureSize({
    super.key,
    required this.onChange,
    super.child,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return MeasureSizeRenderObject(onChange);
  }
}
