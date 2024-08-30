// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/account.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/background.dart';
import 'package:envoy/ui/home/cards/accounts/account_list_tile.dart';
import 'package:envoy/ui/home/cards/accounts/accounts_state.dart';
import 'package:envoy/ui/home/cards/accounts/detail/coins/coin_tag_list_screen.dart';
import 'package:envoy/ui/home/cards/accounts/spend/spend_state.dart';
import 'package:envoy/ui/shield.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChooseCoinsWidget extends ConsumerStatefulWidget {
  const ChooseCoinsWidget({super.key});

  @override
  ConsumerState createState() => _ChooseCoinsWidget();
}

class _ChooseCoinsWidget extends ConsumerState<ChooseCoinsWidget> {
  @override
  Widget build(BuildContext context) {
    Account? account = ref.watch(selectedAccountProvider);
    if (account == null) {
      return Container();
    }

    final shieldTotalHeight = MediaQuery.of(context).size.height * .98;

    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          ref.read(spendEditModeProvider.notifier).state =
              SpendOverlayContext.hidden;
        }
      },
      child: Stack(
        children: [
          const Positioned.fill(
              child: AppBackground(
            showRadialGradient: true,
          )),
          Positioned(
            height: shieldTotalHeight,
            width: MediaQuery.of(context).size.width,
            child: SizedBox(
              child: Scaffold(
                appBar: AppBar(
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  centerTitle: true,
                  title: Text(
                    S().manage_account_address_heading,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                backgroundColor: Colors.transparent,
                body: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Shield(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 20,
                            bottom: 0,
                            left: 20,
                            right: 20,
                          ),
                          child: AccountListTile(account, onTap: () {
                            // ref.read(fullscreenHomePageProvider.notifier).state = true;
                            Navigator.pop(context);
                          }),
                        ),
                        const SizedBox(height: EnvoySpacing.small),
                        Expanded(
                            child: Padding(
                                padding: const EdgeInsets.only(

                                    ///proper padding to align with top sections, based on UI design
                                    left: 20,
                                    right: 20,
                                    top: EnvoySpacing.small),
                                child: CoinsList(account: account)))
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
