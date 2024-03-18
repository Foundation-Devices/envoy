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
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/widgets/envoy_qr_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:envoy/ui/components/address_widget.dart';

class AddressCard extends ConsumerStatefulWidget {
  final Account account;

  AddressCard(this.account) : super(key: UniqueKey());

  @override
  ConsumerState<AddressCard> createState() => _AddressCardState();
}

class _AddressCardState extends ConsumerState<AddressCard> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(const Duration(milliseconds: 10)).then((value) {
      ref.read(homePageTitleProvider.notifier).state =
          S().receive_qr_code_heading;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
        future: widget.account.wallet.getAddress(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Padding(
              padding: const EdgeInsets.only(
                  left: EnvoySpacing.medium2,
                  right: EnvoySpacing.medium2,
                  top: EnvoySpacing.medium2),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            child: QrTab(
                                title: widget.account.name,
                                subtitle:
                                    S().manage_account_address_card_subheading,
                                account: widget.account,
                                qr: EnvoyQR(
                                  data: snapshot.data!,
                                )),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: EnvoySpacing.medium2),
                            child: GestureDetector(
                              onTap: () {
                                _copyAddressToClipboard(
                                    context, snapshot.data!);
                              },
                              child: AddressWidget(
                                address: snapshot.data!,
                                short: false,
                                align: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: EnvoySpacing.large2,
                          right: EnvoySpacing.large2,
                          bottom: EnvoySpacing.large1),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          IconButton(
                              onPressed: () {
                                _copyAddressToClipboard(
                                    context, snapshot.data!);
                              },
                              icon: const EnvoyIcon(
                                icon: "ic_copy.svg",
                                size: 21,
                                color: EnvoyColors.darkTeal,
                              )),
                          EnvoyTextButton(
                            onTap: () {
                              GoRouter.of(context).pop();
                            },
                            label: S().component_ok,
                          ),
                          IconButton(
                              onPressed: () {
                                Share.share("bitcoin:${snapshot.data!}");
                              },
                              icon: const EnvoyIcon(
                                icon: "ic_envoy_share.svg",
                                size: 21,
                                color: EnvoyColors.darkTeal,
                              )),
                        ],
                      ),
                    ),
                  ]),
            );
          } else {
            return const Center(
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
    final scaffold = ScaffoldMessenger.of(context);
    ClipboardData? cdata = await Clipboard.getData(Clipboard.kTextPlain);
    String? text = cdata?.text;
    if (text != address) {
      Clipboard.setData(ClipboardData(text: address));
      scaffold.showSnackBar(const SnackBar(
        content: Text("Address copied to clipboard!"), //TODO: FIGMA
      ));
    }
  }
}
