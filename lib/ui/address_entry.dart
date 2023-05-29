// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/account.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/envoy_icons.dart';
import 'package:envoy/ui/pages/scanner_page.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

class AddressEntry extends StatefulWidget {
  final Function(bool, String)? onAddressChanged;
  final Function(int)? onAmountChanged;
  final bool canEdit;
  final Account account;
  final String? initalAddress;

  AddressEntry(
      {this.initalAddress,
      this.onAddressChanged,
      this.onAmountChanged,
      this.canEdit = true,
      required this.account});

  @override
  State<AddressEntry> createState() => _AddressEntryState();
}

class _AddressEntryState extends State<AddressEntry> {
  final _controller = TextEditingController();

  String get text => _controller.text;
  bool addressValid = false;

  set text(String newAddress) {
    _controller.text = newAddress;
  }

  @override
  void initState() {
    if (widget.initalAddress != null) {
      _controller.text = widget.initalAddress!;
    }

    super.initState();
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
              enabled: widget.canEdit,
              controller: _controller,
              style: TextStyle(
                  fontSize: 14,
                  overflow: TextOverflow.fade,
                  fontWeight: FontWeight.w500),
              onChanged: (value) async {
                await validate(value);
              },
              decoration: InputDecoration(
                // Disable the borders
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                prefixIcon: Container(
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    child: Text("To:")),
                isDense: true,
                prefixIconConstraints: BoxConstraints(
                  minWidth: 18,
                  minHeight: 12,
                ),
                suffixIconConstraints: BoxConstraints(
                  minWidth: 24,
                  minHeight: 24,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 16.0, horizontal: 0.0),
                suffixIcon: !widget.canEdit
                    ? null
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 4),
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
                                validate(text);
                              }
                            },
                          ),
                          InkWell(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 4),
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

                                  if (widget.onAddressChanged != null) {
                                    widget.onAddressChanged!(true, address);
                                  }

                                  if (widget.onAmountChanged != null) {
                                    widget.onAmountChanged!(amount);
                                  }
                                }, widget.account);
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

  Future<void> validate(String value) async {
    final check = await widget.account.wallet.validateAddress(value);
    setState(() => addressValid = check);
    widget.onAddressChanged!(addressValid, value);
  }
}
