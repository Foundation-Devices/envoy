// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:flutter/widgets.dart';

enum FlexAlignment { flexLeft, flexRight, noFlex }

class EnvoyInfoCardListItem extends StatefulWidget {
  final String title;
  final Widget icon;
  final Widget trailing;
  final bool priority;
  final Color? textColor;
  final FlexAlignment flexAlignment;

  const EnvoyInfoCardListItem({
    super.key,
    required this.title,
    required this.icon,
    required this.trailing,
    this.priority = false,
    this.textColor,
    this.flexAlignment = FlexAlignment.noFlex,
  });

  @override
  State<EnvoyInfoCardListItem> createState() => _EnvoyInfoCardListItemState();
}

class _EnvoyInfoCardListItemState extends State<EnvoyInfoCardListItem> {
  double iconWidth = 26;
  double titleWidth = 0;

  // double trailingWidth = 0;
  int flexSpan = 30;

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

  @override
  Widget build(BuildContext context) {
    double iconAndTitleWidth = titleWidth + iconWidth + 15;

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: EnvoySpacing.xs, vertical: EnvoySpacing.small),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          //trailingWidth = trailingWidth == 0 ? 50 : trailingWidth;
          double availableWidth = constraints.maxWidth;

          //double totalFlexWidth = iconAndTitleWidth + trailingWidth;

          int flex1 = (((availableWidth - iconAndTitleWidth) / availableWidth) *
                  flexSpan)
              .round()
              .toInt();
          int flex2 = flexSpan - flex1;

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                flex: flex2,
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
                flex: flex1,
                // child:
                // MeasureSize(
                //   onChange: (size) {
                //     setState(() {
                //       trailingWidth = size.width;
                //     });
                //   },
                child: widget.trailing,
                //),
              ),
            ],
          );
        },
      ),
    );
  }
}

// class MeasureSize extends StatefulWidget {
//   final Widget child;
//   final ValueChanged<Size> onChange;
//
//   const MeasureSize({super.key, required this.onChange, required this.child});
//
//   @override
//   State<MeasureSize> createState() => _MeasureSizeState();
// }
//
// class _MeasureSizeState extends State<MeasureSize> {
//   @override
//   Widget build(BuildContext context) {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final size = context.size;
//       if (size != null) {
//         widget.onChange(size);
//       }
//     });
//
//     return widget.child;
//   }
// }
