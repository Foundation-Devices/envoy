// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/components/button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';

enum SelectAccountState {
  none,
}

class SelectAccount extends StatefulWidget {
  const SelectAccount({super.key});

  @override
  State<SelectAccount> createState() => _SelectAccountState();
}

class _SelectAccountState extends State<SelectAccount> {
  SelectAccountState currentState = SelectAccountState.none;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: EnvoySpacing.medium1, horizontal: EnvoySpacing.medium2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    S().buy_bitcoin_accountSelection_heading,
                    style: EnvoyTypography.subheading,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: EnvoySpacing.medium2,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: EnvoySpacing.medium2),
            child: EnvoyButton(
              label: S().component_continue,
              type: ButtonType.primary,
              state: ButtonState.defaultState,
              onTap: () {},
            ),
          )
        ],
      ),
    );
  }
}
