// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/home/cards/envoy_text_button.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/home/cards/navigation_card.dart';
import 'package:envoy/business/account.dart';

//ignore: must_be_immutable
class DeleteAccountCard extends StatefulWidget with NavigationCard {
  final Account account;

  DeleteAccountCard(this.account, {CardNavigator? navigationCallback})
      : super(key: UniqueKey()) {
    optionsWidget = null;
    modal = true;
    title = S().envoy_home_accounts.toUpperCase();
    navigator = navigationCallback;
  }

  @override
  State<DeleteAccountCard> createState() => _DeleteAccountCardState();
}

class _DeleteAccountCardState extends State<DeleteAccountCard> {
  String _actionButtonText = "Confirm";

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable

    return Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Padding(
        padding: const EdgeInsets.all(50),
        child: Text(
          "Are you sure you wish to delete " +
              widget.account.name +
              "?\n\nThis only removes the account from Envoy.",
          style: TextStyle(fontWeight: FontWeight.w400),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(50.0),
        child: EnvoyTextButton(onTap: () {}, label: _actionButtonText),
      )
    ]);
  }
}
