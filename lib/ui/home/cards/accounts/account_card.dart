// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/exchange_rate.dart';
import 'package:envoy/business/account.dart';
import 'package:envoy/ui/amount.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/envoy_dialog.dart';
import 'package:envoy/ui/envoy_icons.dart';
import 'package:envoy/ui/home/cards/accounts/address_card.dart';
import 'package:envoy/ui/home/cards/accounts/send_card.dart';
import 'package:envoy/ui/home/cards/accounts/descriptor_card.dart';
import 'package:envoy/ui/home/cards/envoy_text_button.dart';
import 'package:envoy/ui/pages/scanner_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
    title = "Accounts".toUpperCase();
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

    // Redraw when we there are changes in accounts
    AccountManager().addListener(_redraw);
  }

  @override
  void dispose() {
    super.dispose();
    AccountManager().removeListener(_redraw);
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final loc = AppLocalizations.of(context)!;
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
          child: ListView.builder(
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
                  return ScannerPage.address((address) {
                    widget.navigator!.push(SendCard(widget.account,
                        address: address,
                        navigationCallback: widget.navigator));
                  });
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
          content: Text("Transaction ID copied to clipboard!"),
        ));
      },
      child: ListTile(
        title: transaction.amount < 0 ? Text("Sent") : Text("Received"),
        subtitle: transaction.isConfirmed
            ? Text(timeago.format(transaction.date))
            : Text("Awaiting confirmation"),
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
            "Show Descriptor".toUpperCase(),
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
            "Edit account name".toUpperCase(),
            style: TextStyle(color: Colors.white),
          ),
          onTap: () {
            navigator!.hideOptions();
            showDialog(
              context: context,
              builder: (BuildContext context) {
                var textEntry = TextEntry(
                  placeholder: account.name,
                );
                return EnvoyDialog(
                  title: Text('Rename Account'),
                  content: textEntry,
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Cancel'.toUpperCase(),
                        style: TextStyle(color: EnvoyColors.darkCopper),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        AccountManager()
                            .renameAccount(account, textEntry.enteredText);
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Save'.toUpperCase(),
                        style: TextStyle(color: EnvoyColors.darkTeal),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
        SizedBox(
          height: 10,
        ),
        GestureDetector(
          child: Text("Delete".toUpperCase(),
              style: TextStyle(color: EnvoyColors.lightCopper)),
          onTap: () {
            navigator!.hideOptions();
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return EnvoyDialog(
                  title: Text('Are you sure?'),
                  content: Text('This only removes the account from Envoy.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Cancel'.toUpperCase(),
                        style: TextStyle(color: EnvoyColors.darkCopper),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        AccountManager().deleteAccount(account);
                        navigator!.pop();
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Delete'.toUpperCase(),
                        style: TextStyle(color: EnvoyColors.darkTeal),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ],
    );
  }
}
