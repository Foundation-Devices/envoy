// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/home/cards/accounts/account_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:envoy/business/account.dart';

class StackedAccountTile extends StatefulWidget {
  final Account account;
  final Function(Account account)? onTap;
  final List<Account> filteredAccounts;

  const StackedAccountTile(
    this.account, {
    super.key,
    required this.filteredAccounts,
    this.onTap,
  });

  @override
  State<StackedAccountTile> createState() => _StackedAccountTileState();
}

class _StackedAccountTileState extends State<StackedAccountTile> {
  late List<Account> accounts = widget.filteredAccounts;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(StackedAccountTile oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    int layerNumber = widget.filteredAccounts.length;
    return SizedBox(
      height: 144,
      child: Flow(
        clipBehavior: Clip.none,
        delegate: AccountsStackFlowDelegate(),
        children: List.generate(widget.filteredAccounts.length, (index) {
          int accountIndex =
              widget.filteredAccounts.length - layerNumber + index;
          return Hero(
            tag: widget.filteredAccounts[accountIndex].id!,
            child: AccountListTile(
              widget.filteredAccounts[accountIndex],
              onTap: () {
                if (widget.onTap != null) {
                  widget.onTap!(widget.filteredAccounts[accountIndex]);
                }
              },
              draggable: false,
            ),
          );
        }),
      ),
    );
  }
}

class AccountsStackFlowDelegate extends FlowDelegate {
  AccountsStackFlowDelegate();

  @override
  void paintChildren(FlowPaintingContext context) {
    final childCount = context.childCount;

    //outside the stack, need these to be in the widget tree to be able to animate,
    //accounts that draw in this area will be invisible, but still in the widget tree
    for (int i = 0; i < (childCount > 3 ? childCount - 3 : 0); i++) {
      context.paintChild(i,
          transform: Matrix4.translationValues(0, 22, 0), opacity: 0.0);
    }

    //visible card stack, only the top 3 cards will be visible
    for (int i = childCount > 3 ? childCount - 3 : 0; i < childCount; i++) {
      context.paintChild(i,
          transform: Matrix4.translationValues(0, ((i) * 4.0), 0));
    }
  }

  @override
  bool shouldRepaint(covariant FlowDelegate oldDelegate) {
    return true;
  }
}
