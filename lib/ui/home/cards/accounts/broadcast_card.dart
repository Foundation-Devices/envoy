// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/exchange_rate.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/home/cards/navigation_card.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/pages/scanner_page.dart';
import 'package:wallet/wallet.dart';
import 'package:envoy/ui/envoy_icons.dart';
import 'package:envoy/util/amount.dart';

//ignore: must_be_immutable
class BroadcastCard extends StatelessWidget with NavigationCard {
  final Psbt psbt;

  BroadcastCard(this.psbt, {CardNavigator? navigationCallback})
      : super(key: UniqueKey()) {
    optionsWidget = null;
    modal = true;
    title = S().envoy_home_accounts.toUpperCase();
    navigator = navigationCallback;
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.all(50.0),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  "Are you sure you want to send Bitcoin?",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                SizedBox(
                  height: 40,
                ),
                ListTile(
                  title: Text("Amount"),
                  leading: Icon(EnvoyIcons.accounts),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        getFormattedAmount(-psbt.amount),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(ExchangeRate().getFormattedAmount(-psbt.amount),
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .color))
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                ListTile(
                  title: Text("Fee"),
                  leading: Icon(Icons.transfer_within_a_station_rounded),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        getFormattedAmount(psbt.fee),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(ExchangeRate().getFormattedAmount(psbt.fee),
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .color))
                    ],
                  ),
                ),
                SizedBox(
                  height: 40,
                ),
                Text(
                  "Transaction ID:",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  psbt.txid,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ]),
        ),
        Padding(
          padding: EdgeInsets.all(50.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                  onPressed: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return ScannerPage.tx((result) {
                        // If result is okay return account page
                        print(result);
                      });
                    }));
                  },
                  icon: Icon(
                    Icons.check,
                    size: 50,
                    color: EnvoyColors.darkTeal,
                  )),
            ],
          ),
        ),
      ],
    );
  }
}
