// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/account.dart';
import 'package:envoy/business/bitcoin_parser.dart';
import 'package:envoy/business/fees.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/address_entry.dart';
import 'package:envoy/ui/amount_entry.dart';
import 'package:envoy/ui/home/cards/accounts/spend/spend_state.dart';
import 'package:envoy/ui/home/cards/envoy_text_button.dart';
import 'package:envoy/ui/home/home_state.dart';
import 'package:envoy/ui/routes/accounts_router.dart';
import 'package:envoy/ui/state/send_screen_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wallet/exceptions.dart';

//ignore: must_be_immutable
class SendCard extends ConsumerStatefulWidget {
  final Account account;
  String? address;
  final int? amountSats;

  SendCard(this.account, {this.address, this.amountSats})
      : super(key: UniqueKey()) {}

  // String? title = .toUpperCase();

  @override
  ConsumerState<SendCard> createState() => _SendCardState();
}

class _SendCardState extends ConsumerState<SendCard>
    with AutomaticKeepAliveClientMixin {
  String _addressText = "";
  bool _addressValid = false;
  bool _canProceed = true;
  bool _amountTooLow = false;
  TextEditingController _controller = TextEditingController();

  int _amount = 0;

  var _amountEntry = AmountEntry();

  Future<void> _onPaste(ParseResult parsed) async {
    setState(() {
      if (parsed.address != null) {
        widget.address = parsed.address!;
        _controller.text = parsed.address!;
      }

      if (parsed.amountSats != null) {
        setAmount(parsed.amountSats!);

        if (parsed.unit != null) {
          ref.read(sendScreenUnitProvider.notifier).state = parsed.unit!;
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();

    _addressText = widget.address ?? "";

    // Addresses from the scanner are already validated
    if (widget.address != null) {
      _addressValid = true;
      _addressText = widget.address!;
    }

    _amountEntry = AmountEntry(
      onAmountChanged: _updateAmount,
      onPaste: _onPaste,
    );

    if (widget.amountSats != null) {
      setAmount(widget.amountSats!);
    }
    Future.delayed(Duration(milliseconds: 10)).then((value) {
      ref.read(homePageTitleProvider.notifier).state = S().send_qr_code_heading;
    });
  }

  void setAmount(int amount) {
    setState(() {
      _amount = amount;
      _amountEntry = AmountEntry(
        onAmountChanged: _updateAmount,
        initalSatAmount: _amount,
        key: UniqueKey(),
        onPaste: _onPaste,
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

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          height: constraints.maxHeight,
          child: SingleChildScrollView(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: new AddressEntry(
                        account: widget.account,
                        initalAddress: widget.address,
                        controller: _controller,
                        onPaste: _onPaste,
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
                              ref.read(spendAddressProvider.notifier).state =
                                  _addressText;
                            }
                          });
                        }),
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
                                  onPaste: _onPaste,
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
                                      Fees().fastRate(
                                          widget.account.wallet.network));
                                } on InsufficientFunds {
                                  // If amount is equal to balance user wants to send max
                                  if (_amount !=
                                      widget.account.wallet.balance) {
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
                              // Navigator.of(context).push(
                              //     MaterialPageRoute(builder: (context) {
                              //   return  ConfirmationCard(
                              //     widget.account,
                              //     _amount,
                              //     _addressText,
                              //   );
                              // }));

                              GoRouter.of(context)
                                  .push(ROUTE_ACCOUNT_SEND_CONFIRM, extra: {
                                "account": widget.account,
                                "amount": _amount,
                                "address": _addressText,
                              });
                            }
                          },
                          error:
                              !_addressValid || !_canProceed || (_amount == 0),
                          label: _amount == 0
                              ? S().send_keyboard_send_max
                              : _canProceed
                                  ? _addressValid
                                      ? S().send_keyboard_address_confirm
                                      : S()
                                          .send_keyboard_amount_enter_valid_address
                                  : _amountTooLow
                                      ? S().send_keyboard_amount_too_low_info
                                      : S()
                                          .send_keyboard_amount_insufficient_funds_info))
                ]),
          ),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    //reset states
    super.dispose();
  }
}
