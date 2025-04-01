// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:ngwallet/src/wallet.dart';
import 'package:envoy/business/account.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/home/cards/accounts/account_list_tile.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/ui/onboard/onboard_welcome.dart';

class EmptyAccountsCard extends StatelessWidget {
  EmptyAccountsCard() : super(key: UniqueKey());

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: ColorFiltered(
            colorFilter: const ColorFilter.mode(
              Color.fromRGBO(255, 255, 255, 0.7),
              BlendMode.hardLight,
            ),
            child: ColorFiltered(
              colorFilter: const ColorFilter.mode(
                Colors.grey,
                BlendMode.saturation,
              ),
              // TODO: use EnvoyAccount
              // child: AccountListTile(
              //     Account(
              //         wallet: GhostWallet(),
              //         name: S().accounts_screen_walletType_defaultName,
              //         deviceSerial: 'envoy',
              //         dateAdded: DateTime.now(),
              //         number: 5,
              //         id: '',
              //         dateSynced: DateTime.now()),
              //     onTap: () {}),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              children: [
                Text(
                  S().accounts_empty_text_explainer,
                  style: EnvoyTypography.explainer,
                ),
                GestureDetector(
                  child: Text(
                    S().accounts_empty_text_learn_more,
                    style: EnvoyTypography.explainer
                        .copyWith(color: EnvoyColors.accentPrimary),
                  ),
                  onTap: () {
                    Navigator.of(context, rootNavigator: true)
                        .push(MaterialPageRoute(builder: (context) {
                      return const WelcomeScreen();
                    }));
                  },
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
