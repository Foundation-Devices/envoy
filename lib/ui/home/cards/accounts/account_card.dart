// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/exchange_rate.dart';
import 'package:envoy/business/account.dart';
import 'package:envoy/ui/amount.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/envoy_dialog.dart';
import 'package:envoy/ui/envoy_icons.dart';
import 'package:envoy/ui/home/cards/accounts/address_card.dart';
import 'package:envoy/ui/home/cards/accounts/send_card.dart';
import 'package:envoy/ui/home/cards/accounts/descriptor_card.dart';
import 'package:envoy/ui/home/cards/envoy_text_button.dart';
import 'package:envoy/ui/loader_ghost.dart';
import 'package:envoy/ui/pages/scanner_page.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:wallet/wallet.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:envoy/ui/home/cards/navigation_card.dart';
import 'package:envoy/business/account_manager.dart';
import 'package:envoy/ui/home/cards/text_entry.dart';
import 'package:envoy/ui/home/cards/accounts/account_list_tile.dart';

//ignore: must_be_immutable
class AccountCard extends StatefulWidget with NavigationCard {
  final Account account;

  AccountCard(this.account, {CardNavigator? navigationCallback})
      : super(key: UniqueKey()) {
    optionsWidget = AccountOptions(
      account,
      navigator: navigationCallback,
    );
    modal = false;
    title = S().envoy_home_accounts.toUpperCase();
    navigator = navigationCallback;
  }

  @override
  State<AccountCard> createState() => _AccountCardState();
}

class _AccountCardState extends State<AccountCard> {
  _redraw() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    // Redraw when we fetch exchange rate
    ExchangeRate().addListener(_redraw);

    // Redraw when we there are changes in accounts
    AccountManager().addListener(_redraw);
  }

  @override
  void dispose() {
    super.dispose();
    AccountManager().removeListener(_redraw);
    ExchangeRate().removeListener(_redraw);
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable

    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(20.0),
        child: AccountListTile(widget.account, onTap: () {
          widget.navigator!.pop();
        }),
      ),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: !widget.account.initialSyncCompleted
              ? ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: 4,
                  itemBuilder: (BuildContext context, int index) {
                    return GhostListTile();
                  },
                )
              : ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: widget.account.wallet.transactions.length,
                  itemBuilder: (BuildContext context, int index) {
                    return TransactionListTile(
                        transaction: widget.account.wallet.transactions[index]);
                  },
                ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(
            left: 50.0, right: 50.0, bottom: 50.0, top: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            EnvoyTextButton(
              onTap: () {
                widget.navigator!.push(SendCard(widget.account,
                    navigationCallback: widget.navigator));
              },
              label: "Send",
            ),
            IconButton(
              icon: Icon(
                EnvoyIcons.qr_scan,
                size: 30,
                color: EnvoyColors.darkTeal,
              ),
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return ScannerPage.address((address, amount) {
                    widget.navigator!.push(SendCard(widget.account,
                        address: address,
                        navigationCallback: widget.navigator));
                  }, widget.account.wallet);
                }));
              },
            ),
            EnvoyTextButton(
                label: "Receive",
                onTap: () {
                  widget.navigator!.push(AddressCard(
                    widget.account,
                    navigationCallback: widget.navigator,
                  ));
                })
          ],
        ),
      )
    ]);
  }
}

class GhostListTile extends StatelessWidget {
  const GhostListTile({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Padding(
        padding: const EdgeInsets.only(top: 2, right: 50),
        child: LoaderGhost(
          width: 10,
          height: 15,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 3.0, right: 80),
        child: LoaderGhost(
          width: 30,
          height: 15,
        ),
      ),
      leading: LoaderGhost(
        width: 50,
        height: 50,
        diagonal: true,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          LoaderGhost(
            width: 50,
            height: 15,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 3.0),
            child: LoaderGhost(
              width: 40,
              height: 15,
            ),
          )
        ],
      ),
    );
  }
}

class TransactionListTile extends StatelessWidget {
  const TransactionListTile({
    Key? key,
    required this.transaction,
  }) : super(key: key);

  final Transaction transaction;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        Clipboard.setData(ClipboardData(text: transaction.txId));
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(S().envoy_account_transaction_copied_clipboard),
        ));
      },
      child: ListTile(
        title: transaction.amount < 0
            ? Text(S().envoy_account_sent)
            : Text(S().envoy_account_received),
        subtitle: transaction.isConfirmed
            ? Text(timeago.format(transaction.date))
            : Text(S().envoy_account_awaiting_confirmation),
        leading: transaction.amount < 0
            ? Icon(Icons.call_made)
            : Icon(Icons.call_received),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Styled as ListTile.title and ListTile.subtitle respectively
            Text(
              getFormattedAmount(transaction.amount),
              style: Theme.of(context).textTheme.subtitle1,
            ),
            Text(ExchangeRate().getFormattedAmount(transaction.amount),
                style: Theme.of(context).textTheme.bodyText2!.copyWith(
                    color: Theme.of(context).textTheme.caption!.color))
          ],
        ),
      ),
    );
  }
}

class AccountOptions extends StatelessWidget {
  final Account account;
  final CardNavigator? navigator;

  AccountOptions(this.account, {this.navigator});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Divider(),
        SizedBox(
          height: 10,
        ),
        GestureDetector(
          child: Text(
            S().envoy_account_show_descriptor.toUpperCase(),
            style: TextStyle(color: Colors.white),
          ),
          onTap: () {
            navigator!.push(DescriptorCard(
              account,
              navigationCallback: navigator,
            ));
          },
        ),
        SizedBox(
          height: 10,
        ),
        GestureDetector(
          child: Text(
            S().envoy_account_edit_name.toUpperCase(),
            style: TextStyle(color: Colors.white),
          ),
          onTap: () {
            navigator!.hideOptions();
            FocusNode focusNode = FocusNode();
            bool isKeyboardShown = false;
            showEnvoyDialog(
              context: context,
              dialog: Builder(
                builder: (context) {
                  var textEntry = TextEntry(
                    focusNode: focusNode,
                    maxLength: 20,
                    placeholder: account.name,
                  );
                  if (!isKeyboardShown) {
                    Future.delayed(Duration(milliseconds: 200)).then((value) {
                      FocusScope.of(context).requestFocus(focusNode);
                    });
                    isKeyboardShown = true;
                  }
                  return EnvoyDialog(
                    title: S().envoy_account_rename,
                    content: textEntry,
                    actions: [
                      EnvoyButton(
                        S().component_save.toUpperCase(),
                        light: false,
                        onTap: () {
                          AccountManager()
                              .renameAccount(account, textEntry.enteredText);
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  );
                },
              ),
            );
          },
        ),
        SizedBox(
          height: 10,
        ),
        GestureDetector(
          child: Text(S().component_delete.toUpperCase(),
              style: TextStyle(color: EnvoyColors.lightCopper)),
          onTap: () {
            navigator!.hideOptions();
            showEnvoyDialog(
                context: context,
                dialog: EnvoyDialog(
                  title: S().envoy_account_delete_are_you_sure,
                  content: Text(S().envoy_account_delete_explainer),
                  actions: [
                    EnvoyButton(
                      S().component_delete.toUpperCase(),
                      light: false,
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      onTap: () {
                        AccountManager().deleteAccount(account);
                        navigator!.pop();
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ));
          },
        ),
      ],
    );
  }
}
