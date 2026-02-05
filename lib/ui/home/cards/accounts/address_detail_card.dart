// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/components/address_widget.dart';
import 'package:envoy/ui/home/cards/accounts/qr_tab.dart';
import 'package:envoy/ui/home/home_state.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/ui/widgets/envoy_qr_widget.dart';
import 'package:envoy/ui/widgets/toast/envoy_toast.dart';
import 'package:envoy/util/build_context_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:envoy/ui/home/cards/envoy_text_button.dart';
import 'package:envoy/ui/home/cards/accounts/address_explorer_card.dart';
import 'package:ngwallet/ngwallet.dart';

class AddressDetailCard extends ConsumerStatefulWidget {
  final EnvoyAccount account;
  final AddressInfo addressInfo;

  AddressDetailCard({
    required this.account,
    required this.addressInfo,
  }) : super(key: UniqueKey());

  @override
  ConsumerState<AddressDetailCard> createState() => _AddressDetailCardState();
}

class _AddressDetailCardState extends ConsumerState<AddressDetailCard> {
  ProviderContainer? _container;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _container ??= ProviderScope.containerOf(context);
  }

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(homeShellOptionsProvider.notifier).state = null;
      ref.read(currentAddressDetailIndexProvider.notifier).state =
          widget.addressInfo.index;
    });
  }

  @override
  void dispose() {
    // Clear address detail index when leaving this page
    final container = _container;
    if (container != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        container.read(currentAddressDetailIndexProvider.notifier).state = null;
      });
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final address = widget.addressInfo.address;

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
                    subtitle:
                        "${S().exploreAddresses_qr_derivationPath} - ${_getDerivationPath()}",
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
                if (widget.addressInfo.isUsed) ...[
                  const SizedBox(height: EnvoySpacing.medium2),
                  const EnvoyIcon(
                    EnvoyIcons.alert,
                    color: EnvoyColors.accentSecondary,
                    size: EnvoyIconSize.normal,
                  ),
                  const SizedBox(height: EnvoySpacing.small),
                  Text(
                    S().exploreAddresses_qr_warningReused,
                    style: EnvoyTypography.info.copyWith(
                      color: EnvoyColors.accentSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
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

  String _getDerivationPath() {
    final addressIndex = widget.addressInfo.index;
    final changeIndex = widget.addressInfo.isChange ? 1 : 0;

    // Determine purpose based on preferred address type
    final addressType = widget.account.preferredAddressType;
    String purpose;
    switch (addressType) {
      case AddressType.p2Pkh:
        purpose = "44'";
      case AddressType.p2Sh:
        purpose = "45'";
      case AddressType.p2Wpkh:
        purpose = "84'";
      case AddressType.p2Wsh:
        purpose = "48'";
      case AddressType.p2Tr:
        purpose = "86'";
      case AddressType.p2ShWpkh:
        purpose = "49'";
      case AddressType.p2ShWsh:
        purpose = "48'";
    }

    return "m/$purpose/0'/0'/$changeIndex/$addressIndex";
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
