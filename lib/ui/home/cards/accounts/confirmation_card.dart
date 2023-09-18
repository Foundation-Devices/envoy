// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/amount_display.dart';
import 'package:envoy/ui/home/cards/accounts/psbt_card.dart';
import 'package:envoy/ui/home/cards/accounts/send_card.dart';
import 'package:envoy/ui/home/cards/accounts/tx_review.dart';
import 'package:flutter/material.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wallet/exceptions.dart';
import 'package:wallet/wallet.dart';
import 'package:envoy/ui/address_entry.dart';
import 'package:envoy/ui/home/cards/envoy_text_button.dart';
import 'package:envoy/ui/home/cards/navigation_card.dart';
import 'package:envoy/ui/home/cards/accounts/fee_toggle.dart';
import 'package:envoy/business/account.dart';
import 'package:envoy/business/fees.dart';

//ignore: must_be_immutable
class ConfirmationCard extends StatefulWidget with NavigationCard {
  final Account account;
  final bool sendMax;
  final int amount;

  final String initialAddress;

  ConfirmationCard(
      this.account, this.amount, this.initialAddress, this.navigator)
      : this.sendMax = amount == account.wallet.balance,
        super(key: UniqueKey()) {}

  @override
  IconData? rightFunctionIcon = null;

  @override
  bool modal = true;

  @override
  CardNavigator? navigator;

  @override
  Function()? onPop;

  @override
  Widget? optionsWidget = null;

  @override
  Function()? rightFunction;

  @override
  String? title = S().send_qr_code_heading.toUpperCase();

  @override
  State<ConfirmationCard> createState() => _ConfirmationCardState();
}

class _ConfirmationCardState extends State<ConfirmationCard> {
  static Psbt _emptyPtsb = Psbt(0, 0, 0, "", "", "");

  Psbt _currentPsbt = _emptyPtsb;
  Psbt _currentPsbtBoost = _emptyPtsb;

  bool _boostEnabled = false;
  int _amount = 0;

  late AddressEntry address;

  @override
  void initState() {
    super.initState();
    _amount = widget.amount;

    address = AddressEntry(
      initalAddress: widget.initialAddress,
      canEdit: false,
      account: widget.account,
    );

    _getPsbts();
  }

  Future<void> _getPsbts() async {
    final normalPsbt =
        await _getPsbt(Fees().slowRate(widget.account.wallet.network));
    final boostPsbt =
        await _getPsbt(Fees().fastRate(widget.account.wallet.network));

    setState(() {
      // SFT-1949: if boost fee is smaller than normal switch 'em
      if (boostPsbt.fee < normalPsbt.fee) {
        _currentPsbt = boostPsbt;
        _currentPsbtBoost = normalPsbt;
      } else {
        _currentPsbt = normalPsbt;
        _currentPsbtBoost = boostPsbt;
      }

      if (widget.sendMax) {
        _amount = _currentPsbt.amount.abs();
      }
    });
  }

  Future<Psbt> _getPsbt(double feeRate) async {
    Psbt _returnPsbt = _emptyPtsb;

    try {
      _returnPsbt = await widget.account.wallet
          .createPsbt(widget.initialAddress, widget.amount, feeRate);
    } on InsufficientFunds catch (e) {
      // Get another one with correct amount
      var fee = e.needed - e.available;
      try {
        _returnPsbt = await widget.account.wallet
            .createPsbt(widget.initialAddress, e.available - fee, feeRate);
      } on InsufficientFunds catch (e) {
        print("Something is seriously wrong! Available: " +
            e.available.toString() +
            " Needed: " +
            e.needed.toString());
      }
    }

    return _returnPsbt;
  }

  @override
  Widget build(BuildContext context) {
    var _feeToggle = FeeToggle(
      wallet: widget.account.wallet,
      standardFee: _currentPsbt.fee,
      boostFee: _currentPsbtBoost.fee,
      key: UniqueKey(),
      initialIndex: _boostEnabled ? 1 : 0,
      onToggled: (int fee, bool usingBoost) {
        _boostEnabled = usingBoost;
        if (widget.sendMax) {
          setState(() {
            _amount = widget.amount - fee;
          });
        }
      },
    );

    return Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Padding(
        padding: const EdgeInsets.all(15.0),
        child: address,
      ),
      Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: FittedBox(
            fit: BoxFit.fitWidth,
            child: AmountDisplay(
              account: widget.account,
              amountSats: _amount,
              testnet: widget.account.wallet.network == Network.Testnet,
              key: UniqueKey(),
            ),
          )),
      _feeToggle,
      Padding(
          padding: const EdgeInsets.all(50.0),
          child: Consumer(
            builder: (context, ref, child) {
              return EnvoyTextButton(
                  onTap: () {
                    ref.read(spendAmountProvider.notifier).state = _amount;
                    ref.read(spendAddressProvider.notifier).state =
                        widget.initialAddress;

                    if (!widget.account.wallet.hot) {
                      // Increment the change index before displaying the PSBT
                      widget.account.wallet.getChangeAddress();

                      widget.navigator!.push(PsbtCard(
                        _boostEnabled ? _currentPsbtBoost : _currentPsbt,
                        widget.account,
                        widget.navigator,
                      ));
                    } else {
                      widget.navigator!.push(TxReview(
                        _boostEnabled ? _currentPsbtBoost : _currentPsbt,
                        widget.account,
                        navigator: widget.navigator,
                        onFinishNavigationClick: () {
                          widget.navigator?.pop(depth: 3);
                        },
                      ));
                    }
                  },
                  label: S().envoy_confirmation_confirm);
            },
          ))
    ]);
  }
}
