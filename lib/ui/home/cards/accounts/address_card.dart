// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/account/accounts_manager.dart';
import 'package:envoy/business/bluetooth_manager.dart';
import 'package:envoy/business/devices.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/components/address_widget.dart';
import 'package:envoy/ui/components/envoy_bar.dart';
import 'package:envoy/ui/home/cards/accounts/detail/account_card.dart';
import 'package:envoy/ui/home/cards/accounts/qr_tab.dart';
import 'package:envoy/ui/home/cards/buy_bitcoin_account_selection.dart';
import 'package:envoy/ui/state/accounts_state.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:envoy/ui/widgets/envoy_qr_widget.dart';
import 'package:envoy/ui/widgets/toast/envoy_toast.dart';
import 'package:envoy/util/build_context_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ngwallet/ngwallet.dart';
import 'package:share_plus/share_plus.dart';

class AddressCard extends ConsumerStatefulWidget {
  final EnvoyAccount account;

  AddressCard(this.account) : super(key: UniqueKey());

  @override
  ConsumerState<AddressCard> createState() => _AddressCardState();
}

class _AddressCardState extends ConsumerState<AddressCard> {
  @override
  Widget build(BuildContext context) {
    final account = ref.watch(accountStateProvider(widget.account.id));
    String address = "";
    final isTaprootEnabled = Settings().enableTaprootSetting == true;
    final noTaprootXpub = accountHasNoTaprootXpub(account!);
    final Device? device =
        Devices().getDeviceBySerial(account.deviceSerial ?? "");
    bool isPrime = device?.type == DeviceType.passportPrime;
    final bool isPrimeConnected =
        ref.watch(isPrimeConnectedProvider(device?.bleId ?? ""));

    if (isTaprootEnabled && noTaprootXpub) {
      final segwitAddressRecord = account.nextAddress.firstWhere(
        (record) => record.$2 == AddressType.p2Wpkh, // native SegWit
        orElse: () => ('', AddressType.p2Wpkh),
      );

      address = segwitAddressRecord.$1;
    } else {
      // Normal case: get preferred address
      address = account.getPreferredAddress();
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
            ],
          ),
        ),

        // TODO: add other buttons/link texts !!!
        Expanded(
          child: GestureDetector(
            onTap: () {
              if (isPrimeConnected) {
                // TODO: if prime is connected via ble, verify address via QL
              } else {
                if (mounted) {
                  showEnvoyDialog(
                    context: context,
                    blurColor: Colors.black,
                    useRootNavigator: true,
                    linearGradient: true,
                    dialog: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: VerifyAddressDialog(
                        address: address,
                        accountName: account.name,
                      ),
                    ),
                  );
                }
              }
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                EnvoyIcon(
                  widget.account.isHot || isPrime
                      ? EnvoyIcons.quantum
                      : EnvoyIcons.qr_scan,
                  color: EnvoyColors.accentPrimary,
                ),
                const SizedBox(width: EnvoySpacing.small),
                Text(
                  S().buy_bitcoin_accountSelection_verify,
                  textAlign: TextAlign.center,
                  style: EnvoyTypography.button.copyWith(
                    color: EnvoyColors.accentPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
        EnvoyBar(
          items: [
            EnvoyBarItem(
              icon: EnvoyIcons.envelope,
              text: S().receive_qr_signMessage,
              onTap: () {
                // TODO: add "Sign Message" code
              },
            ),
            EnvoyBarItem(
              icon: EnvoyIcons.copy,
              text: S().receive_qr_copy,
              onTap: () => _copyAddressToClipboard(context, address),
            ),
            EnvoyBarItem(
              icon: EnvoyIcons.externalLink,
              text: S().receive_qr_share,
              onTap: () => SharePlus.instance.share(
                ShareParams(text: "bitcoin:$address"),
              ),
            ),
          ],
        )
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
