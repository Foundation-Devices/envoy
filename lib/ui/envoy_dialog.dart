// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';

class EnvoyDialog extends StatelessWidget {
  final String? title;
  final bool dismissible;
  final Widget? content;
  final List<Widget>? actions;
  final double paddingBottom;

  const EnvoyDialog(
      {super.key,
      this.title,
      this.content,
      this.paddingBottom = 12,
      this.actions,
      this.dismissible = true});

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
          crossAxisAlignment: CrossAxisAlignment.start,
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
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(fontWeight: FontWeight.w500, fontSize: 24))
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
