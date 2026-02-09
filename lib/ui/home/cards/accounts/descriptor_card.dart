// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/settings.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/components/select_dropdown.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/home/cards/accounts/qr_tab.dart';
import 'package:envoy/ui/home/cards/envoy_text_button.dart';
import 'package:envoy/ui/home/home_state.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/ui/widgets/envoy_qr_widget.dart';
import 'package:envoy/util/console.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ngwallet/ngwallet.dart';
import 'package:share_plus/share_plus.dart';

//ignore: must_be_immutable
class DescriptorCard extends ConsumerStatefulWidget {
  final EnvoyAccount account;

  DescriptorCard(this.account) : super(key: UniqueKey());

  @override
  ConsumerState<DescriptorCard> createState() => _DescriptorCardState();
}

class _DescriptorCardState extends ConsumerState<DescriptorCard> {
  late List<(AddressType, String)> descriptors =
      widget.account.externalPublicDescriptors;
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    try {
      setState(() {
        final addressTypeToSelect =
            Settings().taprootEnabled() ? AddressType.p2Tr : AddressType.p2Wpkh;
        selectedIndex = descriptors.indexWhere(
          (descriptor) => descriptor.$1 == addressTypeToSelect,
        );

        // In case our preferred type is not there
        if (selectedIndex == -1) {
          selectedIndex = 0;
        }
      });
    } catch (e) {
      kPrint("Error getting preferred address index $e");
    }

    Future.delayed(const Duration(milliseconds: 10)).then((value) {
      ref.read(homePageTitleProvider.notifier).state =
          S().manage_account_address_heading;
    });
  }

  String mapAddressTypeToName(AddressType addressType) {
    switch (addressType) {
      case AddressType.p2Pkh:
        return S().accountDetails_descriptor_legacy;
      case AddressType.p2Sh:
        return "P2Sh";
      case AddressType.p2Wpkh:
        return S().accountDetails_descriptor_segwit;
      case AddressType.p2Wsh:
        return "P2Wsh";
      case AddressType.p2Tr:
        return S().accountDetails_descriptor_taproot;
      case AddressType.p2ShWpkh:
        return S().accountDetails_descriptor_wrappedSegwit;
      case AddressType.p2ShWsh:
        return "P2ShWsh";
    }
  }

  late List<EnvoyDropdownOption> options = descriptors.map((descriptor) {
    return EnvoyDropdownOption(
      type: EnvoyDropdownOptionType.normal,
      label: mapAddressTypeToName(descriptor.$1),
      value: descriptors.indexOf(descriptor).toString(),
    );
  }).toList();

  @override
  Widget build(BuildContext context) {
    String descriptor = descriptors[selectedIndex].$2;
    return SingleChildScrollView(
      // ENV-2081
      physics: NeverScrollableScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Padding(
              padding: const EdgeInsets.all(EnvoySpacing.medium2),
              child: Column(
                children: [
                  QrTab(
                    title: widget.account.name,
                    subtitle: S().manage_account_descriptor_subheading,
                    account: widget.account,
                    qr: EnvoyQR(data: descriptor),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: EnvoySpacing.medium1,
                      left: EnvoySpacing.xs,
                      right: EnvoySpacing.xs,
                    ),
                    child: EnvoyDropdown(
                      options: options,
                      initialIndex: selectedIndex,
                      onOptionChanged: (selectedOption) {
                        if (selectedOption != null) {
                          setState(() {
                            selectedIndex = int.parse(selectedOption.value);
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          //TODO: add dropdown to switch between descriptors
          Padding(
            padding: const EdgeInsets.only(bottom: EnvoySpacing.large1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: EnvoySpacing.large3),
                  child: IconButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: descriptor));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Descriptor copied to clipboard!",
                          ), //TODO: FIGMA
                        ),
                      );
                    },
                    icon: const EnvoyIcon(EnvoyIcons.copy),
                  ),
                ),
                EnvoyTextButton(
                  onTap: () {
                    context.pop();
                  },
                  label: S().component_ok,
                  textStyle: EnvoyTypography.subheading.copyWith(
                    fontWeight: FontWeight.w400,
                    color: EnvoyColors.darkTeal,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: EnvoySpacing.large3),
                  child: IconButton(
                    onPressed: () {
                      SharePlus.instance.share(ShareParams(text: descriptor));
                    },
                    icon: const EnvoyIcon(EnvoyIcons.share),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
