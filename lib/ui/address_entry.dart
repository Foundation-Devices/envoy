// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/exchange_rate.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/routes/accounts_router.dart';
import 'package:envoy/ui/state/accounts_state.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/ui/widgets/color_util.dart';
import 'package:envoy/ui/widgets/scanner/decoders/payment_qr_decoder.dart';
import 'package:envoy/ui/widgets/scanner/qr_scanner.dart';
import 'package:envoy/ui/widgets/toast/envoy_toast.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:envoy/business/bitcoin_parser.dart';
import 'package:envoy/ui/state/app_unit_state.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:envoy/ui/home/cards/accounts/spend/state/spend_state.dart';
import 'package:go_router/go_router.dart';
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
  bool addressValid = false;
  final double _verticalPadding = EnvoySpacing.medium1;

  @override
  void initState() {
    if (widget.initalAddress != null) {
      widget.controller?.text = formatAddress(widget.initalAddress!);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var unit = ref.read(appUnitProvider);

    return Material(
      borderRadius: BorderRadius.circular(EnvoySpacing.medium3),
      child: Form(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Container(
          decoration: BoxDecoration(
            color: EnvoyColors.surface3,
            borderRadius: BorderRadius.circular(EnvoySpacing.medium3),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (ref.read(accountsCountByNetworkProvider(
                              widget.account.network)) >=
                          2) {
                        context.go(ROUTE_ACCOUNT_TRANSFER,
                            extra: widget.account.id);
                      }
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: _verticalPadding),
                      child: EnvoyIcon(EnvoyIcons.transfer,
                          size: EnvoyIconSize.extraSmall,
                          color: EnvoyColors.accentPrimary),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: EnvoySpacing.small),
                    child: Container(
                      width: 1,
                      color: EnvoyColors.textTertiary.applyOpacity(0.3),
                    ),
                  ),

                  // Text field
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                          top: _verticalPadding, bottom: _verticalPadding),
                      child: TextFormField(
                        enabled: widget.canEdit,
                        controller: widget.controller,
                        style: EnvoyTypography.body,
                        keyboardType: TextInputType.multiline,
                        minLines: 1,
                        maxLines: null,
                        onChanged: (value) async {
                          widget.onAddressChanged?.call(value);
                          setState(() {});
                        },
                        textAlignVertical: TextAlignVertical.top,
                        decoration: InputDecoration(
                          hintText: S().send_keyboard_enterAddress,
                          hintStyle: EnvoyTypography.body.copyWith(
                            color: EnvoyColors.textTertiary,
                          ),
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ),

                  if (widget.controller!.text.isNotEmpty)
                    InkWell(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: _verticalPadding,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 16,
                          color: EnvoyColors.textTertiary,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          widget.controller?.text = "";
                        });
                      },
                    ),

                  if (widget.canEdit) ...[
                    if (widget.controller!.text.isEmpty ||
                        widget.controller?.text == "")
                      InkWell(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: _verticalPadding,
                          ),
                          child: const EnvoyIcon(
                            EnvoyIcons.clipboard,
                            size: EnvoyIconSize.extraSmall,
                            color: EnvoyColors.accentPrimary,
                          ),
                        ),
                        onTap: () async {
                          if (widget.onPaste != null) {
                            ClipboardData? cdata =
                                await Clipboard.getData(Clipboard.kTextPlain);
                            String? textCopied = cdata?.text;
                            var decodedInfo = await BitcoinParser.parse(
                              textCopied!,
                              fiatExchangeRate:
                                  ExchangeRate().selectedCurrencyRate,
                              account: widget.account,
                              selectedFiat: Settings().selectedFiat,
                              currentUnit: unit,
                            );
                            widget.onPaste!(decodedInfo);
                            if (decodedInfo.address != null) {
                              validate(decodedInfo.address!);
                            }
                            widget.controller?.text =
                                formatAddress(decodedInfo.address ?? "");
                          } else {
                            ClipboardData? cdata =
                                await Clipboard.getData(Clipboard.kTextPlain);
                            String? text = cdata?.text;
                            if (text != null) {
                              widget.controller?.text = formatAddress(text);
                              validate(text);
                            }
                          }
                        },
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: EnvoySpacing.small),
                      child: Container(
                        width: 1,
                        color: EnvoyColors.textTertiary.applyOpacity(0.3),
                      ),
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(EnvoySpacing.large3),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: _verticalPadding,
                        ),
                        child: EnvoyIcon(
                          EnvoyIcons.scan,
                          color: EnvoyColors.accentPrimary,
                          size: EnvoyIconSize.extraSmall,
                        ),
                      ),
                      onTap: () {
                        showScannerDialog(
                          context: context,
                          onBackPressed: (context) {
                            Navigator.pop(context);
                          },
                          decoder: PaymentQrDecoder(
                            onAddressValidated: (address, amount, message) {
                              EnvoyToast.dismissPreviousToasts(context,
                                  rootNavigator: true);
                              Navigator.of(context, rootNavigator: true).pop();
                              widget.controller?.text = formatAddress(address);
                              ref.read(stagingTxNoteProvider.notifier).state =
                                  message;
                              widget.onAddressChanged?.call(address);
                              widget.onAmountChanged?.call(amount);
                            },
                            account: widget.account,
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String formatAddress(String address) {
    final buffer = StringBuffer();
    for (int i = 0; i < address.length; i++) {
      buffer.write(address[i]);
      if ((i + 1) % 4 == 0 && i != address.length - 1) {
        buffer.write(' ');
      }
    }
    return buffer.toString();
  }

  Future<void> validate(String value) async {
    final check = await EnvoyAccountHandler.validateAddress(
        address: value, network: widget.account.network);
    setState(() => addressValid = check);
    widget.onAddressChanged?.call(value);
  }
}
