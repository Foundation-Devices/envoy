// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/home/cards/accounts/account_list_tile.dart';
import 'package:envoy/ui/home/setup_overlay.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/ui/widgets/color_util.dart';
import 'package:flutter/material.dart';
import 'package:ngwallet/ngwallet.dart';

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
              child: AccountListTile(
                  draggable: false,
                  EnvoyAccount(
                      name: S().accounts_screen_walletType_defaultName,
                      deviceSerial: 'envoy',
                      dateAdded: DateTime.now().toString(),
                      index: 5,
                      id: '',
                      preferredAddressType: AddressType.p2Tr,
                      network: Network.bitcoin,
                      balance: BigInt.zero,
                      isHot: true,
                      transactions: [],
                      nextAddress: [],
                      utxo: [],
                      descriptors: [],
                      unlockedBalance: BigInt.zero,
                      seedHasPassphrase: false,
                      color: Color(0xFFBF755F).toHex(),
                      dateSynced: null,
                      tags: [],
                      xfp: "ghost",
                      externalPublicDescriptors: []),
                  onTap: () {}),
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
                    Navigator.of(context, rootNavigator: true).push(
                      PageRouteBuilder(
                        opaque: false,
                        pageBuilder: (_, __, ___) =>
                            const AnimatedBottomOverlay(),
                      ),
                    );
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
