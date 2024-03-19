// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:ui';

import 'package:envoy/business/account_manager.dart';
import 'package:envoy/ui/components/address_widget.dart';
import 'package:envoy/ui/components/button.dart';
import 'package:envoy/ui/home/cards/accounts/account_list_tile.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:flutter/material.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:wallet/wallet.dart';
import 'package:envoy/business/account.dart';
import 'package:envoy/ui/components/account_selector.dart';

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
  Account selectedAccount = AccountManager()
      .accounts
      .firstWhere((account) => account.wallet.network != Network.Testnet);
  List<Account> accounts = AccountManager().accounts;
  String? address;

  @override
  void initState() {
    super.initState();
    selectedAccount.wallet.getAddress().then((value) {
      setState(() {
        address = value;
      });
    }).catchError((error) {});
  }

  void updateSelectedAccount(Account account) {
    setState(() {
      selectedAccount = account;
    });
  }

  @override
  Widget build(BuildContext context) {
    var filteredAccounts = filterAccounts(accounts, selectedAccount);
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
                  StackedAccountTile(
                    selectedAccount,
                    filteredAccounts: filteredAccounts,
                  ),
                  const SizedBox(
                    height: EnvoySpacing.small,
                  ),
                  GestureDetector(
                    child: Text(
                      S().buy_bitcoin_accountSelection_chooseAccount,
                      style: EnvoyTypography.info
                          .copyWith(color: EnvoyColors.accentPrimary),
                      textAlign: TextAlign.center,
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                              child: ChooseAccount(
                                accounts: filteredAccounts,
                                onSelectAccount: updateSelectedAccount,
                              ));
                        },
                      );
                    },
                  ),
                  const SizedBox(
                    height: EnvoySpacing.medium2,
                  ),
                  Text(
                    S().buy_bitcoin_accountSelection_subheading,
                    style: EnvoyTypography.info
                        .copyWith(color: EnvoyColors.textTertiary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: EnvoySpacing.medium1,
                  ),
                  if (address != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: EnvoySpacing.medium2,
                      ),
                      child: AddressWidget(
                        address: address!,
                        align: TextAlign.center,
                      ),
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
              onTap: () {
                // TODO: implement
              },
            ),
          )
        ],
      ),
    );
  }
}

List<Account> filterAccounts(List<Account> accounts, Account selectedAccount) {
  accounts.removeWhere((account) => account.wallet.network == Network.Testnet);
  accounts.remove(selectedAccount);
  accounts.add(selectedAccount); // add on the end of list

  return accounts;
}

class ChooseAccount extends StatelessWidget {
  const ChooseAccount({
    super.key,
    required this.accounts,
    required this.onSelectAccount,
  });

  final List<Account> accounts;
  final Function(Account) onSelectAccount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [
        Colors.black,
        Color(0x00000000),
      ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
      child: Column(
        children: [
          SizedBox(
            height: 100,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      S().header_chooseAccount,
                      style:
                          EnvoyTypography.heading.copyWith(color: Colors.white),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Material(
                      color: Colors.transparent,
                      child: IconButton(
                        color: Colors.white,
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: accounts.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: EnvoySpacing.medium2,
                      horizontal: EnvoySpacing.medium1),
                  child: AccountListTile(accounts[index], onTap: () {
                    onSelectAccount(accounts[index]);
                    Navigator.of(context).pop();
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
