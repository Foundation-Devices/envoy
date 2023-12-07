// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/account.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/envoy_icons.dart';
import 'package:envoy/ui/home/cards/accounts/qr_tab.dart';
import 'package:envoy/ui/home/cards/envoy_text_button.dart';
import 'package:envoy/ui/home/home_state.dart';
import 'package:envoy/ui/widgets/envoy_qr_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wallet/wallet.dart';

//ignore: must_be_immutable
class AddressCard extends ConsumerStatefulWidget {
  final Account account;

  AddressCard(this.account) : super(key: UniqueKey()) {}

  @override
  ConsumerState<AddressCard> createState() => _AddressCardState();
}

class _AddressCardState extends ConsumerState<AddressCard> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(milliseconds: 10)).then((value) {
      ref.read(homePageTitleProvider.notifier).state =
          S().receive_qr_code_heading;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isTaproot = widget.account.wallet.type == WalletType.taproot;
    // ignore: unused_local_variable
    return FutureBuilder<String>(
        future: widget.account.wallet.getAddress(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Container(
                            margin: EdgeInsets.all(12),
                            padding: const EdgeInsets.all(6.0),
                            child: QrTab(
                                title: widget.account.name,
                                subtitle:
                                    S().manage_account_address_card_subheading,
                                account: widget.account,
                                qr: Stack(
                                  children: <Widget>[
                                    EnvoyQR(
                                      data: snapshot.data!,
                                      embeddedImage: isTaproot
                                          ? Image.asset(
                                              'assets/taproot_qr.png',
                                            ).image
                                          : null,
                                      embeddedImageSize: Size(128, 66),
                                    ),
                                    if (isTaproot) // This code is for testing purposes; a new image may be required.
                                      Center(
                                        child: Container(
                                          width: 102,
                                          // This is set through the visual interface.
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: Colors.transparent,
                                            border: Border.all(
                                                color: widget.account.color,
                                                width: 3),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(6.0) //
                                                ),
                                          ),
                                        ),
                                      ),
                                  ],
                                )),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 20),
                          child: GestureDetector(
                            onTap: () {
                              _copyAddressToClipboard(context, snapshot.data!);
                            },
                            child: Text(
                              snapshot.data!,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium!
                                  .copyWith(
                                      color: EnvoyColors.darkTeal,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding:
                        EdgeInsets.only(left: 50.0, right: 50.0, bottom: 40.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IconButton(
                            onPressed: () {
                              _copyAddressToClipboard(context, snapshot.data!);
                            },
                            icon: EnvoyIcon(
                              icon: "ic_copy.svg",
                              size: 21,
                              color: EnvoyColors.darkTeal,
                            )),
                        EnvoyTextButton(
                          onTap: () {
                            GoRouter.of(context).pop();
                          },
                          label: S().OK,
                        ),
                        IconButton(
                            onPressed: () {
                              Share.share("bitcoin:" + snapshot.data!);
                            },
                            icon: EnvoyIcon(
                              icon: "ic_envoy_share.svg",
                              size: 21,
                              color: EnvoyColors.darkTeal,
                            )),
                      ],
                    ),
                  ),
                ]);
          } else {
            return Center(
              child: SizedBox(
                height: 100,
                width: 100,
                child: CircularProgressIndicator(
                  color: EnvoyColors.darkTeal,
                ),
              ),
            );
          }
        });
  }

  void _copyAddressToClipboard(BuildContext context, String address) async {
    ClipboardData? cdata = await Clipboard.getData(Clipboard.kTextPlain);
    String? text = cdata?.text ?? null;
    if (text != address) {
      Clipboard.setData(ClipboardData(text: address));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Address copied to clipboard!"), //TODO: FIGMA
      ));
    }
  }
}
