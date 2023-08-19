// SPDX-FileCopyrightText: 2023 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/account.dart';
import 'package:envoy/business/exchange_rate.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/home/cards/accounts/detail/transaction/transactions_details.dart';
import 'package:envoy/ui/loader_ghost.dart';
import 'package:envoy/ui/state/hide_balance_state.dart';
import 'package:envoy/ui/widgets/material_transparent_router.dart';
import 'package:envoy/util/amount.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:envoy/ui/state/transactions_state.dart';
import 'package:wallet/wallet.dart';
import 'package:timeago/timeago.dart' as timeago;

class AccountCardTransactionsList extends ConsumerStatefulWidget {
  final Account account;
  const AccountCardTransactionsList(this.account, {Key? key}) : super(key: key);

  @override
  ConsumerState<AccountCardTransactionsList> createState() =>
      _AccountCardTransactionsListState();
}

class _AccountCardTransactionsListState
    extends ConsumerState<AccountCardTransactionsList> {
  @override
  Widget build(BuildContext context) {
    List<Transaction> transactions =
        ref.watch(transactionsProvider(widget.account.id));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: widget.account.dateSynced == null
          ? ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: 4,
              itemBuilder: (BuildContext context, int index) {
                return GhostListTile();
              },
            )
          : ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: transactions.length,
              itemBuilder: (BuildContext context, int index) {
                return TransactionListTile(
                    transaction: transactions[index], account: widget.account);
              },
            ),
    );
  }

  _redraw() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    // Redraw when we fetch exchange rate
    ExchangeRate().addListener(_redraw);

    // Redraw when we there are changes in accounts
    // AccountManager().addListener(_redraw);
  }

  @override
  void dispose() {
    super.dispose();
    // AccountManager().removeListener(_redraw);
    ExchangeRate().removeListener(_redraw);
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
    required this.account,
  }) : super(key: key);

  final Transaction transaction;
  final Account account;

  @override
  Widget build(BuildContext context) {
    //TODO : Add transaction type
    // TransactionType transactionType = this.transaction.type;
    // if(transaction == TransactionType.azteco){
    //   //do azteco voucher transaction
    // }
    return GestureDetector(
      onTap: () {

        return;
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
          crossAxisAlignment: Settings().selectedFiat == null
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.end,
          children: [
            // Styled as ListTile.title and ListTile.subtitle respectively
            Consumer(
              builder: (context, ref, child) {
                bool hide = ref.watch(balanceHideStateStatusProvider(account.id));
                if (hide) {
                  return SizedBox(
                      width: 100,
                      height: 15,
                      child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          decoration: BoxDecoration(
                              color: Color(0xffEEEEEE),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)))));
                } else {
                  return child ?? Container();
                }
              },
              child: Text(
                transaction.type == TransactionType.azteco
                    ? ""
                    : getFormattedAmount(transaction.amount),
                style: Settings().selectedFiat == null
                    ? Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontSize: 20.0)
                    : Theme.of(context).textTheme.titleMedium,
              ),
            ),
            if (Settings().selectedFiat != null)
              Consumer(
                builder: (context, ref, child) {
                  bool hide =
                      ref.watch(balanceHideStateStatusProvider(account.id));
                  if (hide) {
                    return Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: SizedBox(
                          width: 64,
                          height: 15,
                          child: Container(
                              width: double.infinity,
                              height: double.infinity,
                              decoration: BoxDecoration(
                                  color: Color(0xffEEEEEE),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20))))),
                    );
                  } else {
                    return child ?? Container();
                  }
                },
                child: Text(
                    transaction.type == TransactionType.azteco
                        ? ""
                        : ExchangeRate().getFormattedAmount(transaction.amount),
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Theme.of(context).textTheme.bodySmall!.color)),
              ),
          ],
        ),
      ),
    );
  }
}
