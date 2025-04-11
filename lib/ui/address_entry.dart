// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/exchange_rate.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/widgets/scanner/decoders/payment_qr_decoder.dart';
import 'package:envoy/ui/widgets/scanner/qr_scanner.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:envoy/business/bitcoin_parser.dart';
import 'package:envoy/ui/state/send_screen_state.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:envoy/ui/home/cards/accounts/spend/spend_state.dart';
import 'package:ngwallet/ngwallet.dart';

class AddressEntry extends ConsumerStatefulWidget {
  final Function(String)? onAddressChanged;
  final Function(int)? onAmountChanged;
  final bool canEdit;
  final EnvoyAccount account;
  final String? initalAddress;
  final TextEditingController? controller;
  final Function(ParseResult)? onPaste;

  const AddressEntry(
      {super.key,
      this.initalAddress,
      this.onAddressChanged,
      this.onAmountChanged,
      this.canEdit = true,
      this.controller,
      this.onPaste,
      required this.account});

  @override
  ConsumerState<AddressEntry> createState() => _AddressEntryState();
}

class _AddressEntryState extends ConsumerState<AddressEntry> {
  String get text => widget.controller?.text ?? "";
  bool addressValid = false;

  set text(String newAddress) {
    widget.controller?.text = newAddress;
  }

  @override
  void initState() {
    if (widget.initalAddress != null) {
      widget.controller?.text = widget.initalAddress!;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var unit = ref.read(sendScreenUnitProvider);

    return Material(
      borderRadius: BorderRadius.circular(15),
      child: Form(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Container(
          decoration: BoxDecoration(
              color: EnvoyColors.surface3,
              borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: EnvoySpacing.small, vertical: EnvoySpacing.medium1),
            child: TextFormField(
                enabled: widget.canEdit,
                controller: widget.controller,
                style: const TextStyle(
                    fontSize: 14,
                    overflow: TextOverflow.fade,
                    fontWeight: FontWeight.w500),
                onChanged: (value) async {
                  widget.onAddressChanged?.call(value);
                },
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  // Disable the borders
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  prefixIcon: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(S().send_keyboard_to)),
                  isDense: true,
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 12,
                  ),
                  suffixIconConstraints: const BoxConstraints(
                    minWidth: 24,
                    minHeight: 24,
                  ),
                  contentPadding: const EdgeInsets.only(bottom: 2),
                  suffixIcon: !widget.canEdit
                      ? null
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 4, horizontal: 4),
                                child: Icon(
                                  Icons.paste,
                                  size: 21,
                                  color: EnvoyColors.accentPrimary,
                                ),
                              ),
                              onTap: () async {
                                if (widget.onPaste != null) {
                                  ClipboardData? cdata =
                                      await Clipboard.getData(
                                          Clipboard.kTextPlain);
                                  String? textCopied = cdata?.text;
                                  var decodedInfo = await BitcoinParser.parse(
                                      textCopied!,
                                      fiatExchangeRate:
                                          ExchangeRate().selectedCurrencyRate,
                                      account: widget.account,
                                      selectedFiat: Settings().selectedFiat,
                                      currentUnit: unit);
                                  widget.onPaste!(decodedInfo);
                                  if (decodedInfo.address != null) {
                                    validate(decodedInfo.address!);
                                  }
                                } else {
                                  ClipboardData? cdata =
                                      await Clipboard.getData(
                                          Clipboard.kTextPlain);
                                  String? text = cdata?.text;
                                  if (text != null) {
                                    widget.controller?.text = text;
                                    validate(text);
                                  }
                                }
                              },
                            ),
                            InkWell(
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 4, horizontal: 4),
                                child: Icon(
                                  EnvoyIcons.qrScan,
                                  size: 20,
                                  color: EnvoyColors.accentPrimary,
                                ),
                              ),
                              onTap: () {
                                // Maybe catch the result of pop instead of using callbacks?:

                                // final result = await Navigator.push(
                                //   context,
                                //   MaterialPageRoute(builder: (context) => const SelectionScreen()),
                                // );
                                showScannerDialog(
                                    context: context,
                                    onBackPressed: (context) {
                                      Navigator.pop(context);
                                    },
                                    decoder: PaymentQrDecoder(
                                        onAddressValidated:
                                            (address, amount, message) {
                                          widget.controller?.text = address;
                                          ref
                                              .read(stagingTxNoteProvider
                                                  .notifier)
                                              .state = message;
                                          if (widget.onAddressChanged != null) {
                                            widget.onAddressChanged
                                                ?.call(address);
                                          }
                                          if (widget.onAmountChanged != null) {
                                            widget.onAmountChanged!(amount);
                                          }
                                        },
                                        account: widget.account));
                              },
                            )
                          ],
                        ),
                )),
          ),
        ),
      ),
    );
  }

  Future<void> validate(String value) async {
    final check = await EnvoyAccountHandler.validateAddress(
        address: value, network: widget.account.network);
    setState(() => addressValid = check);
    widget.onAddressChanged?.call(value);
  }
}
