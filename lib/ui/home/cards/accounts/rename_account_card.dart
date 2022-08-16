// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/home/cards/envoy_text_button.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/home/cards/navigation_card.dart';
import 'package:envoy/business/account.dart';
import 'package:envoy/business/account_manager.dart';
import 'package:envoy/ui/home/cards/text_entry.dart';

//ignore: must_be_immutable
class RenameAccountCard extends StatefulWidget with NavigationCard {
  final Account account;

  RenameAccountCard(this.account, {CardNavigator? navigationCallback})
      : super(key: UniqueKey()) {
    optionsWidget = null;
    modal = true;
    title = S().envoy_home_accounts.toUpperCase();
    navigator = navigationCallback;
  }

  @override
  State<RenameAccountCard> createState() => _RenameAccountCardState();
}

class _RenameAccountCardState extends State<RenameAccountCard> {
  String _actionButtonText = "Confirm";

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable

    var textEntry = TextEntry(
      placeholder: widget.account.name,
    );

    return Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20.0, bottom: 10),
            child: Text(
              "Edit account name".toUpperCase(),
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: textEntry,
          ),
        ],
      ),
      Padding(
        padding: const EdgeInsets.all(50.0),
        child: EnvoyTextButton(
            onTap: () {
              widget.account.name = textEntry.enteredText;
              AccountManager().storeAccounts();
              widget.navigator!.pop();
            },
            label: _actionButtonText),
      )
    ]);
  }
}
