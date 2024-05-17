// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';

class EnvoyDialog extends StatelessWidget {
  final String? title;
  final bool dismissible;
  final Widget? content;
  final List<Widget>? actions;
  final double paddingBottom;
  final TextStyle? titleTextStyle;

  const EnvoyDialog(
      {super.key,
      this.title,
      this.content,
      this.paddingBottom = 12,
      this.actions,
      this.dismissible = true,
      this.titleTextStyle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28).add(const EdgeInsets.only(top: -6)),
      constraints: BoxConstraints(
        minHeight: 270,
        maxWidth: MediaQuery.of(context).size.width * 0.80,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            dismissible
                ? Align(
                    alignment:
                        Alignment.centerRight.add(const Alignment(.1, 0)),
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  )
                : const SizedBox(),
            title != null
                ? Text(title ?? '',
                    textAlign: TextAlign.center,
                    style: titleTextStyle ?? EnvoyTypography.subheading20)
                : const SizedBox(),
            Padding(padding: EdgeInsets.all(title != null ? 8 : 0)),
            content ?? Container(),
            Padding(padding: EdgeInsets.all(paddingBottom)),
            ...actions?.map((widget) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: widget,
                  );
                }).toList() ??
                [],
          ],
        ),
      ),
    );
  }
}
