// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/account/accounts_manager.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/home/cards/accounts/qr_tab.dart';
import 'package:envoy/ui/home/cards/envoy_text_button.dart';
import 'package:envoy/ui/home/home_state.dart';
import 'package:envoy/ui/state/accounts_state.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/widgets/envoy_qr_widget.dart';
import 'package:envoy/util/build_context_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:envoy/ui/components/address_widget.dart';
import 'package:ngwallet/ngwallet.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';

class AddressCard extends ConsumerStatefulWidget {
  final EnvoyAccount account;

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
    final address = ref
            .watch(accountStateProvider(widget.account.id))
            ?.getPreferredAddress() ??
        "";
    AddressWidget addressWidget = AddressWidget(address: address);
    double optimalAddressHorizontalPadding =
        addressWidget.calculateOptimalPadding(address, context);
    return Padding(
      padding: const EdgeInsets.only(top: EnvoySpacing.medium2),
      child:
          Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: EnvoySpacing.medium2,
                  right: EnvoySpacing.medium2,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: QrTab(
                          title: widget.account.name,
                          subtitle: S().manage_account_address_card_subheading,
                          account: widget.account,
                          qr: EnvoyQR(
                            data: address,
                          )),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: context.isSmallScreen
                      ? EnvoySpacing.xs
                      : EnvoySpacing.medium2,
                  left: optimalAddressHorizontalPadding * 0.5,
                  right: optimalAddressHorizontalPadding * 0.5,
                ),
                child: AddressWidget(
                  address: address,
                  short: false,
                  align: TextAlign.center,
                  showWarningOnCopy: false,
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.only(
            left: EnvoySpacing.medium2,
            right: EnvoySpacing.medium2,
          ),
          child: Padding(
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
                      _copyAddressToClipboard(context, address);
                    },
                    icon: const EnvoyIcon(
                      EnvoyIcons.copy,
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
                      Share.share("bitcoin:$address");
                    },
                    icon: const EnvoyIcon(
                      EnvoyIcons.externalLink,
                      color: EnvoyColors.darkTeal,
                    )),
              ],
            ),
          ),
        ),
      ]),
    );
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
