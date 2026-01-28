// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/account/accounts_manager.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/components/address_widget.dart';
import 'package:envoy/ui/home/cards/accounts/detail/account_card.dart';
import 'package:envoy/ui/home/cards/accounts/qr_tab.dart';
import 'package:envoy/ui/home/home_state.dart';
import 'package:envoy/ui/state/accounts_state.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/widgets/envoy_qr_widget.dart';
import 'package:envoy/ui/widgets/toast/envoy_toast.dart';
import 'package:envoy/util/build_context_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ngwallet/ngwallet.dart';
import 'package:share_plus/share_plus.dart';
import 'package:envoy/ui/home/cards/envoy_text_button.dart';

class AddressCard extends ConsumerStatefulWidget {
  final EnvoyAccount account;

  AddressCard(this.account) : super(key: UniqueKey());

  @override
  ConsumerState<AddressCard> createState() => _AddressCardState();
}

class _AddressCardState extends ConsumerState<AddressCard> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration()).then((value) {
      ref.read(homeShellOptionsProvider.notifier).state = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final account = ref.watch(accountStateProvider(widget.account.id));
    String address = "";
    final isTaprootEnabled = Settings().enableTaprootSetting == true;
    final noTaprootXpub = accountHasNoTaprootXpub(account);

    if (isTaprootEnabled && noTaprootXpub) {
      final segwitAddressRecord = account?.nextAddress.firstWhere(
        (record) => record.$2 == AddressType.p2Wpkh, // native SegWit
        orElse: () => ('', AddressType.p2Wpkh),
      );

      address = segwitAddressRecord?.$1 ?? "";
    } else {
      // Normal case: get preferred address
      address = account?.getPreferredAddress() ?? "";
    }

    return Padding(
      padding: const EdgeInsets.only(top: EnvoySpacing.medium2),
      child:
          Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
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
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: context.isSmallScreen
                        ? EnvoySpacing.xs
                        : EnvoySpacing.medium2,
                  ),
                  child: AddressWidget(
                    address: address,
                    returnAddressHalves: true,
                    align: TextAlign.center,
                    showWarningOnCopy: false,
                  ),
                ),
                const SizedBox(height: EnvoySpacing.medium3),
              ],
            ),
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
                      color: EnvoyColors.accentPrimary,
                    )),
                EnvoyTextButton(
                  onTap: () {
                    GoRouter.of(context).pop();
                  },
                  label: S().component_ok,
                ),
                IconButton(
                    onPressed: () {
                      SharePlus.instance.share(ShareParams(
                        text: "bitcoin:$address",
                      ));
                    },
                    icon: const EnvoyIcon(
                      EnvoyIcons.externalLink,
                      color: EnvoyColors.accentPrimary,
                    )),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  void _copyAddressToClipboard(BuildContext context, String address) async {
    Clipboard.setData(ClipboardData(text: address));
    if (context.mounted) {
      EnvoyToast(
        backgroundColor: Colors.lightBlue,
        replaceExisting: true,
        duration: Duration(seconds: 1),
        message: "Address copied to clipboard",
        icon: EnvoyIcon(
          EnvoyIcons.info,
          color: EnvoyColors.accentPrimary,
        ),
      ).show(context, rootNavigator: true);
    }
  }
}
