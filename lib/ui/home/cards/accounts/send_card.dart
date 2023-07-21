// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/amount_entry.dart';
import 'package:envoy/ui/home/cards/envoy_text_button.dart';
import 'package:flutter/material.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wallet/exceptions.dart';
import 'package:envoy/ui/home/cards/accounts/confirmation_card.dart';
import 'package:envoy/ui/address_entry.dart';
import 'package:envoy/ui/home/cards/navigation_card.dart';
import 'package:envoy/business/account.dart';
import 'package:envoy/business/fees.dart';

//For review screens
final spendAddressProvider = StateProvider((ref) => "");
final spendAmountProvider = StateProvider((ref) => 0);

//ignore: must_be_immutable
class SendCard extends ConsumerStatefulWidget with NavigationCard {
  final Account account;
  final String? address;
  final int? amountSats;

  SendCard(this.account,
      {this.address, CardNavigator? navigationCallback, this.amountSats})
      : super(key: UniqueKey()) {
    optionsWidget = null;
    modal = true;
    title = S().send_qr_code_heading.toUpperCase();
    navigator = navigationCallback;
  }

  @override
  ConsumerState<SendCard> createState() => _SendCardState();
}

class _SendCardState extends ConsumerState<SendCard>
    with AutomaticKeepAliveClientMixin {
  String _addressText = "";
  bool _addressValid = false;
  bool _canProceed = true;
  bool _amountTooLow = false;

  int _amount = 0;

  AddressEntry? _address;
  var _amountEntry = AmountEntry();

  @override
  void initState() {
    super.initState();

    _address = AddressEntry(
        account: widget.account,
        initalAddress: widget.address,
        onAmountChanged: (amount) {
          if (amount != 0) {
            setAmount(amount);
          }
        },
        onAddressChanged: (valid, text) {
          Future.delayed(Duration.zero, () async {
            setState(() {
              _addressValid = valid;
            });
            if (valid) {
              _addressText = text;
              ref.read(spendAddressProvider.notifier).state = _addressText;
            }
          });
        });

    // Addresses from the scanner are already validated
    if (widget.address != null) {
      _addressValid = true;
      _addressText = widget.address!;
    }

    _amountEntry = AmountEntry(
      onAmountChanged: _updateAmount,
      wallet: widget.account.wallet,
    );

    if (widget.amountSats != null) {
      setAmount(widget.amountSats!);
    }
  }

  void setAmount(int amount) {
    setState(() {
      _amount = amount;
      _amountEntry = AmountEntry(
        onAmountChanged: _updateAmount,
        initalSatAmount: _amount,
        key: UniqueKey(),
        wallet: widget.account.wallet,
      );
    });
  }

  _updateAmount(amount) {
    setState(() {
      _amount = amount;
      _canProceed = !(amount > widget.account.wallet.balance);
      _amountTooLow = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Padding(
        padding: const EdgeInsets.all(15.0),
        child: _address,
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: _amountEntry,
      ),
      Padding(
          padding: const EdgeInsets.all(50.0),
          child: EnvoyTextButton(
              onTap: () async {
                if (_amount == 0) {
                  setState(() {
                    _amount = widget.account.wallet.balance;
                    _amountEntry = AmountEntry(
                      onAmountChanged: _updateAmount,
                      initalSatAmount: _amount,
                      key: UniqueKey(),
                      wallet: widget.account.wallet,
                    );
                  });
                  return;
                }

                if (_addressValid && _canProceed && (_amount > 0)) {
                  // Only check amount if we are not sending max
                  if (_amount != widget.account.wallet.balance) {
                    try {
                      await widget.account.wallet.createPsbt(
                          _addressText,
                          _amount,
                          Fees().fastRate(widget.account.wallet.network));
                    } on InsufficientFunds {
                      // If amount is equal to balance user wants to send max
                      if (_amount != widget.account.wallet.balance) {
                        setState(() {
                          _canProceed = false;
                        });
                      }
                      return;
                    } on BelowDustLimit {
                      setState(() {
                        _canProceed = false;
                        _amountTooLow = true;
                      });
                      return;
                    }
                  }
                  widget.navigator!.push(ConfirmationCard(
                    widget.account,
                    _amount,
                    _addressText,
                    pushCallback: widget.navigator,
                  ));
                }
              },
              error: !_addressValid || !_canProceed || (_amount == 0),
              label: _amount == 0
                  ? S().send_keyboard_send_max
                  : _canProceed
                      ? _addressValid
                          ? S().send_keyboard_address_confirm
                          : S().send_keyboard_amount_enter_valid_address
                      : _amountTooLow
                          ? S().send_keyboard_amount_too_low_info
                          : S().send_keyboard_amount_insufficient_funds_info))
    ]);
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    //reset states
    super.dispose();
  }
}
