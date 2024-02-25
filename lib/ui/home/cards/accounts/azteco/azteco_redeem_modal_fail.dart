// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/envoy_button.dart';
import 'package:flutter/material.dart';
import 'package:envoy/generated/l10n.dart';

class AztecoRedeemModalFail extends StatefulWidget {
  final PageController controller;

  const AztecoRedeemModalFail({Key? key, required this.controller})
      : super(key: key);

  @override
  State<AztecoRedeemModalFail> createState() => _AztecoRedeemModalFail();
}

class _AztecoRedeemModalFail extends State<AztecoRedeemModalFail> {
  @override
  Widget build(BuildContext context) {
    var headingTextStyle = Theme.of(context)
        .textTheme
        .bodyMedium
        ?.copyWith(fontWeight: FontWeight.w500, fontSize: 20);

    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 4 * 4, vertical: 4 * 4),
              child: IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8 * 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Image.asset("assets/exclamation_triangle.png",
                //     scale: 1.0, width: 56, height: 56, fit: BoxFit.contain),
                Padding(
                  padding: const EdgeInsets.only(top: 5 * 4),
                  child: Text(
                    S().azteco_redeem_modal_fail_heading,
                    textAlign: TextAlign.center,
                    style: headingTextStyle,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 5 * 4),
                  child: Text(
                    S().azteco_redeem_modal_fail_subheading,
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(padding: EdgeInsets.all(4)),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8 * 4, vertical: 6 * 4),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 4 * 4),
                  child: EnvoyButton(
                    S().component_continue,
                    type: EnvoyButtonTypes.primaryModal,
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
