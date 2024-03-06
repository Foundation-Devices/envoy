// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/account.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/home/cards/accounts/qr_tab.dart';
import 'package:envoy/ui/home/cards/envoy_text_button.dart';
import 'package:envoy/ui/home/home_state.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/ui/widgets/envoy_qr_widget.dart';
import 'package:flutter/material.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

//ignore: must_be_immutable
class DescriptorCard extends ConsumerStatefulWidget {
  final Account account;

  DescriptorCard(this.account) : super(key: UniqueKey());

  @override
  ConsumerState<DescriptorCard> createState() => _DescriptorCardState();
}

class _DescriptorCardState extends ConsumerState<DescriptorCard> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 10)).then((value) {
      ref.read(homePageTitleProvider.notifier).state =
          S().manage_account_address_heading;
    });
  }

  @override
  Widget build(BuildContext context) {
    String descriptor = widget.account.descriptor;

    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Padding(
              padding: const EdgeInsets.all(EnvoySpacing.medium2),
              child: QrTab(
                title: widget.account.name,
                subtitle: S().manage_account_descriptor_subheading,
                account: widget.account,
                qr: EnvoyQR(
                  data: descriptor,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: EnvoySpacing.xl),
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
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text(
                              "Descriptor copied to clipboard!"), //TODO: FIGMA
                        ));
                      },
                      icon: const EnvoyIcon(EnvoyIcons.copy)),
                ),
                EnvoyTextButton(
                  onTap: () {
                    context.pop();
                  },
                  label: S().OK,
                  textStyle: EnvoyTypography.subheading.copyWith(
                      fontWeight: FontWeight.w400, color: EnvoyColors.darkTeal),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: EnvoySpacing.large3),
                  child: IconButton(
                      onPressed: () {
                        Share.share(descriptor);
                      },
                      icon: const EnvoyIcon(EnvoyIcons.share)),
                ),
              ],
            ),
          ),
        ]);
  }
}
