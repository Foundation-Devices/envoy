// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/account.dart';
import 'package:envoy/business/bitcoin_parser.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/address_entry.dart';
import 'package:envoy/ui/amount_entry.dart';
import 'package:envoy/ui/home/cards/accounts/accounts_state.dart';
import 'package:envoy/ui/home/cards/accounts/spend/spend_state.dart';
import 'package:envoy/ui/home/cards/envoy_text_button.dart';
import 'package:envoy/ui/home/home_state.dart';
import 'package:envoy/ui/state/send_screen_state.dart';
import 'package:envoy/util/console.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';

//ignore: must_be_immutable
class SendCard extends ConsumerStatefulWidget {
  SendCard() : super(key: UniqueKey());

  @override
  ConsumerState<SendCard> createState() => _SendCardState();
}

class _SendCardState extends ConsumerState<SendCard>
    with AutomaticKeepAliveClientMixin {
  Account? account;
  final TextEditingController _controller = TextEditingController();

  var _amountEntry = const AmountEntry();

  Future<void> _onPaste(ParseResult parsed) async {
    setState(() {
      if (parsed.address != null) {
        _controller.text = parsed.address!;
        ref.read(spendAddressProvider.notifier).state = parsed.address!;
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
    _amountEntry = AmountEntry(
      onAmountChanged: _updateAmount,
      onPaste: _onPaste,
      account: ref.read(selectedAccountProvider),
    );
    Future.delayed(const Duration(milliseconds: 10)).then((_) {
      ref.read(homePageTitleProvider.notifier).state =
          S().receive_tx_list_send.toUpperCase();
      account = ref.read(selectedAccountProvider);
      if (ref.read(spendAmountProvider) != 0) {
        setAmount(ref.read(spendAmountProvider));
      }
      if (ref.read(spendTransactionProvider).loading) {
        ref.read(spendTransactionProvider.notifier).reset();
      }
      if (account == null && context.mounted) {
        // ignore: use_build_context_synchronously
        context.pop();
        return;
      }
    });
  }

  void setAmount(int amount) {
    ref.read(spendAmountProvider.notifier).state = amount;
    setState(() {
      _amountEntry = AmountEntry(
        onAmountChanged: _updateAmount,
        key: UniqueKey(),
        account: account,
        initalSatAmount: amount,
        onPaste: _onPaste,
      );
    });
  }

  _updateAmount(amount) {
    ref.read(spendAmountProvider.notifier).state = amount;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    account = ref.read(selectedAccountProvider);
    String addressText = ref.read(spendAddressProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = MediaQuery.sizeOf(context).width;
        double addressEntryBottomPadding = EnvoySpacing.medium2;
        if (width <= 380) {
          addressEntryBottomPadding = EnvoySpacing.medium1;
        }
        if (width < 350) {
          addressEntryBottomPadding = EnvoySpacing.small;
        }
        if (width <= 320) {
          addressEntryBottomPadding = EnvoySpacing.xs;
        }
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        top: EnvoySpacing.medium2,
                        left: EnvoySpacing.medium2,
                        right: EnvoySpacing.medium2,
                        bottom: addressEntryBottomPadding,
                      ),
                      child: AddressEntry(
                        account: account!,
                        initalAddress: addressText,
                        controller: _controller,
                        onPaste: _onPaste,
                        onAmountChanged: (amount) {
                          if (amount != 0) {
                            setAmount(amount);
                          }
                        },
                        onAddressChanged: (text) {
                          ref.read(spendAddressProvider.notifier).state = text;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: EnvoySpacing.medium1),
                      child: _amountEntry,
                    ),
                  ],
                ),
              ),
            ),
            Container(
              constraints: const BoxConstraints(minHeight: 64, maxHeight: 140),
              height: MediaQuery.sizeOf(context).height * 0.1,
              alignment: Alignment.topCenter,
              padding: const EdgeInsets.only(top: EnvoySpacing.xs),
              child: Consumer(
                builder: (context, ref, child) {
                  final isCoinSelected = ref.watch(isCoinsSelectedProvider);
                  final formValidation = ref.watch(spendValidationProvider);
                  int spendAmount = ref.watch(spendAmountProvider);
                  int spendableBalance =
                      ref.watch(totalSpendableAmountProvider);
                  TransactionModel tx = ref.watch(spendTransactionProvider);
                  bool txValidation = tx.valid;
                  bool valid = formValidation;

                  final addressEmpty = ref.watch(spendAddressProvider).isEmpty;
                  final validationError =
                      ref.watch(spendValidationErrorProvider);
                  String buttonText = "";
                  bool isFormEmpty = addressEmpty || spendAmount == 0;

                  if (isFormEmpty) {
                    valid = true;
                    buttonText = S().send_keyboard_address_confirm;
                    if (spendAmount == 0) {
                      if (isCoinSelected) {
                        buttonText = S().tagged_tagDetails_sheet_cta1;
                      } else {
                        buttonText = S().send_keyboard_send_max;
                      }
                    }
                    if (spendAmount != 0 && addressEmpty) {
                      buttonText = (spendAmount > spendableBalance)
                          ? S().send_keyboard_amount_insufficient_funds_info
                          : S().send_keyboard_amount_enter_valid_address;
                      valid = false;
                    }
                  } else {
                    if (addressEmpty) {
                      if (spendAmount == 0) {
                        if (isCoinSelected) {
                          buttonText = S().tagged_tagDetails_sheet_cta1;
                        } else {
                          buttonText = S().send_keyboard_send_max;
                        }
                      }
                      buttonText = S().send_keyboard_address_confirm;
                    } else {
                      if (validationError == null) {
                        buttonText = S().send_keyboard_address_confirm;
                      } else {
                        valid = txValidation && formValidation;
                        if (valid) {
                          buttonText = S().send_keyboard_address_confirm;
                        } else {
                          buttonText = validationError;
                        }
                      }
                    }
                  }
                  if (tx.loading) {
                    buttonText = S().send_keyboard_address_loading;
                  }
                  return EnvoyTextButton(
                    onTap: () async {
                      if (tx.loading) {
                        return;
                      }
                      if (formValidation) {
                        try {
                          ref.read(spendTransactionProvider.notifier).reset();
                          bool valid = await ref
                              .read(spendTransactionProvider.notifier)
                              .validate(ProviderScope.containerOf(context));
                          if (valid) {
                            if (context.mounted) {
                              GoRouter.of(context).goNamed('spend_confirm');
                            }
                          }
                        } catch (e) {
                          kPrint(e);
                        }
                      }
                      if (spendAmount == 0) {
                        ref.read(spendAmountProvider.notifier).state =
                            ref.read(totalSpendableAmountProvider);
                        setState(() {
                          _amountEntry = AmountEntry(
                            onAmountChanged: _updateAmount,
                            initalSatAmount:
                                ref.read(totalSpendableAmountProvider),
                            key: UniqueKey(),
                            account: account!,
                            onPaste: _onPaste,
                          );
                        });
                        return;
                      }
                    },
                    error: !valid,
                    label: buttonText,
                    isDisabled: !valid || tx.loading,
                  );
                },
              ),
            ),
          ],
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
