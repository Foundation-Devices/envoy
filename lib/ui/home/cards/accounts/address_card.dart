// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/account/accounts_manager.dart';
import 'package:envoy/ble/bluetooth_manager.dart';
import 'package:envoy/business/devices.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/components/address_widget.dart';
import 'package:envoy/ui/components/envoy_bar.dart';
import 'package:envoy/ui/home/cards/accounts/detail/account_card.dart';
import 'package:envoy/ui/home/cards/accounts/qr_tab.dart';
import 'package:envoy/ui/home/cards/accounts/spend/transfer_card.dart';
import 'package:envoy/ui/home/home_state.dart';
import 'package:envoy/ui/routes/accounts_router.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:envoy/ui/widgets/envoy_qr_widget.dart';
import 'package:envoy/ui/widgets/toast/envoy_toast.dart';
import 'package:envoy/util/build_context_extension.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/ui/state/accounts_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
  void initState() {
    super.initState();

    Future.delayed(const Duration()).then((value) {
      ref.read(homeShellOptionsProvider.notifier).state = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    String address = "";
    final isTaprootEnabled = Settings().enableTaprootSetting == true;
    final noTaprootXpub = accountHasNoTaprootXpub(widget.account);
    final Device? device =
        Devices().getDeviceBySerial(widget.account.deviceSerial ?? "");
    bool isPrime = device?.type == DeviceType.passportPrime;
    final bool isPrimeConnected = ref.watch(isPrimeConnectedProvider(device));

    if (isTaprootEnabled && noTaprootXpub) {
      final segwitAddressRecord = widget.account.nextAddress.firstWhere(
        (record) => record.$2 == AddressType.p2Wpkh, // native SegWit
        orElse: () => ('', AddressType.p2Wpkh),
      );

      address = segwitAddressRecord.$1;
    } else {
      // Normal case: get preferred address
      address = widget.account.getPreferredAddress();
    }

    return Padding(
      padding: const EdgeInsets.only(top: EnvoySpacing.medium2),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: EnvoySpacing.medium2,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    QrTab(
                      title: widget.account.name,
                      subtitle: S().manage_account_address_card_subheading,
                      account: widget.account,
                      qr: EnvoyQR(data: address),
                    ),
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
                    const SizedBox(height: EnvoySpacing.medium1),
                    if (widget.account.isHot)
                      _buildHotWalletPassportLink(context, ref),
                    if (!widget.account.isHot)
                      GestureDetector(
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
                                  width:
                                      MediaQuery.of(context).size.width * 0.9,
                                  child: VerifyAddressDialog(
                                    address: address,
                                    accountName: widget.account.name,
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
                              isPrime ? EnvoyIcons.quantum : EnvoyIcons.qr_scan,
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
                    const SizedBox(height: EnvoySpacing.medium1),
                  ],
                ),
              ),
            ),
          ),
          EnvoyBar(
            items: [
              EnvoyBarItem(
                icon: EnvoyIcons.envelope,
                text: S().receive_qr_signMessage,
                onTap: () {
                  context.push(ROUTE_ACCOUNT_SIGN_MESSAGE,
                      extra: widget.account.id);
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
        ],
      ),
    );
  }

  Widget _buildHotWalletPassportLink(BuildContext context, WidgetRef ref) {
    final network = widget.account.network;
    final allAccounts = switch (network) {
      Network.bitcoin => ref.watch(mainnetAccountsProvider(null)),
      Network.signet => ref.watch(signetAccountsProvider(null)),
      Network.testnet4 => ref.watch(testnetAccountsProvider(null)),
      _ => <EnvoyAccount>[],
    };
    final passportAccounts = allAccounts.where((a) => !a.isHot).toList();

    if (passportAccounts.isEmpty) {
      return const SizedBox.shrink();
    }

    final bool singlePassport = passportAccounts.length == 1;

    return LinkText(
      text: singlePassport
          ? S().receive_mobileWallet_singlePassportContent
          : S().receive_mobileWallet_multiplePassportContent,
      textStyle: EnvoyTypography.info.copyWith(color: EnvoyColors.textTertiary),
      linkStyle:
          EnvoyTypography.info.copyWith(color: EnvoyColors.accentPrimary),
      onTap: () {
        if (singlePassport) {
          context.go(ROUTE_ACCOUNT_RECEIVE, extra: passportAccounts.first.id);
        } else {
          context.go(ROUTE_ACCOUNTS_HOME);
        }
      },
    );
  }

  void _copyAddressToClipboard(BuildContext context, String address) async {
    Clipboard.setData(ClipboardData(text: address));
    if (context.mounted) {
      EnvoyToast(
        backgroundColor: Colors.lightBlue,
        replaceExisting: true,
        duration: Duration(seconds: 1),
        message: S().receive_toast_addressCopied,
        icon: EnvoyIcon(EnvoyIcons.info, color: EnvoyColors.accentPrimary),
      ).show(context, rootNavigator: true);
    }
  }
}
