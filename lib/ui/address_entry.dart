// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/envoy_icons.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:envoy/ui/pages/scanner_page.dart';
import 'package:wallet/wallet.dart';

class AddressEntry extends StatelessWidget {
  final _controller = TextEditingController();
  final Function(bool)? onAddressChanged;
  final Function(int)? onAmountChanged;
  final bool canEdit;
  final Wallet wallet;

  String get text => _controller.text;

  set text(String newAddress) {
    _controller.text = newAddress;
  }

  AddressEntry(
      {String? initalAddress,
      this.onAddressChanged,
      this.onAmountChanged,
      this.canEdit = true,
      required this.wallet}) {
    if (initalAddress != null) {
      _controller.text = initalAddress;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Container(
        decoration: BoxDecoration(
            color: Colors.black12, borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: TextFormField(
              enabled: canEdit,
              controller: _controller,
              validator: (value) {
                if (value!.isEmpty || !wallet.validateAddress(value)) {
                  onAddressChanged!(false);
                } else {
                  onAddressChanged!(true);
                }
                return null;
              },
              decoration: InputDecoration(
                // Disable the borders
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                prefixIcon: Padding(
                  padding:
                      const EdgeInsets.only(left: 7.0, bottom: 6.0, right: 7.0),
                  child: Text("To:"),
                ),

                prefixIconConstraints:
                    BoxConstraints(minWidth: 0, minHeight: 0),
                suffixIcon: !canEdit
                    ? null
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Icon(
                                EnvoyIcons.copy_paste,
                                color: EnvoyColors.darkTeal,
                              ),
                            ),
                            onTap: () async {
                              ClipboardData? cdata =
                                  await Clipboard.getData(Clipboard.kTextPlain);
                              String? text = cdata?.text ?? null;
                              if (text != null) {
                                _controller.text = text;
                              }
                            },
                          ),
                          InkWell(
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Icon(
                                Icons.qr_code,
                                color: EnvoyColors.darkTeal,
                              ),
                            ),
                            onTap: () {
                              // Maybe catch the result of pop instead of using callbacks?:

                              // final result = await Navigator.push(
                              //   context,
                              //   MaterialPageRoute(builder: (context) => const SelectionScreen()),
                              // );

                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (context) {
                                return ScannerPage.address((address, amount) {
                                  _controller.text = address;
                                  if (onAmountChanged != null) {
                                    onAmountChanged!(amount);
                                  }
                                }, wallet);
                              }));
                            },
                          )
                        ],
                      ),
              )),
        ),
      ),
    );
  }
}
