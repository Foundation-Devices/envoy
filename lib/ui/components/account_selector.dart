// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/home/cards/accounts/account_list_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:envoy/business/account.dart';
import 'package:flutter/widgets.dart';

class StackedAccountTile extends StatelessWidget {
  final Account account;
  final List<Account> filteredAccounts;

  const StackedAccountTile(this.account,
      {super.key, required this.filteredAccounts});

  @override
  Widget build(BuildContext context) {
    int layerNumber = filteredAccounts.length > 3 ? 3 : filteredAccounts.length;
    return SizedBox(
      height: 130,
      child: Stack(
        children: List.generate(layerNumber, (index) {
          return Positioned(
            top: index * 10.0,
            left: 0,
            right: 0,
            child: AccountListTile(
              filteredAccounts[index],
              onTap: () {},
            ),
          );
        }),
      ),
    );
  }
}
