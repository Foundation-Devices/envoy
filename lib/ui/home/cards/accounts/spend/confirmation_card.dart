// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/amount_display.dart';
import 'package:envoy/ui/home/cards/accounts/spend/spend_state.dart';
import 'package:envoy/ui/home/home_state.dart';
import 'package:flutter/material.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wallet/wallet.dart';
import 'package:envoy/ui/address_entry.dart';
import 'package:envoy/ui/home/cards/envoy_text_button.dart';
import 'package:envoy/ui/home/cards/accounts/fee_toggle.dart';
import 'package:envoy/business/account.dart';
import 'package:envoy/business/fees.dart';

//ignore: must_be_immutable
class ConfirmationCard extends ConsumerStatefulWidget {
  final Account account;
  final bool sendMax;
  final int amount;

  final String initialAddress;

  ConfirmationCard(this.account, this.amount, this.initialAddress)
      : this.sendMax = amount == account.wallet.balance,
        super(key: UniqueKey()) {}

  // String? title = S().send_qr_code_heading.toUpperCase();

  @override
  ConsumerState<ConfirmationCard> createState() => _ConfirmationCardState();
}

class _ConfirmationCardState extends ConsumerState<ConfirmationCard> {
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

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ref.read(fullscreenHomePageProvider.notifier).state = true;
    });
    _getPsbts();
  }

  Future<void> _getPsbts() async {
    final normalPsbt = await getPsbt(
        Fees().slowRate(widget.account.wallet.network),
        widget.account,
        widget.initialAddress,
        widget.amount);
    final boostPsbt = await getPsbt(
        Fees().fastRate(widget.account.wallet.network),
        widget.account,
        widget.initialAddress,
        widget.amount);

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

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            GoRouter.of(context).pop();
          },
        ),
      ),
      body:
          Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
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
                      GoRouter.of(context).pop();
                      return;
                    },
                    label: S().send_keyboard_address_confirm);
              },
            ))
      ]),
    );
  }
}
