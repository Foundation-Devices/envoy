// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/account.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/home/cards/accounts/qr_tab.dart';
import 'package:envoy/ui/home/cards/envoy_text_button.dart';
import 'package:envoy/ui/home/home_state.dart';
import 'package:flutter/material.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

//ignore: must_be_immutable
class DescriptorCard extends ConsumerStatefulWidget {
  final Account account;

  DescriptorCard(this.account) : super(key: UniqueKey()) {}

  @override
  ConsumerState<DescriptorCard> createState() => _DescriptorCardState();
}

class _DescriptorCardState extends ConsumerState<DescriptorCard> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 10)).then((value) {
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
              padding: const EdgeInsets.all(15.0),
              child: QrTab(
                title: widget.account.name,
                subtitle:
                    "Make sure not to share this descriptor unless you are comfortable with your transactions being public.", //TODO: FIGMA
                account: widget.account,
                qr: QrImage(
                  data: descriptor,
                  backgroundColor: Colors.white,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 50.0, right: 50.0, bottom: 30.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: descriptor));
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                            "Descriptor copied to clipboard!"), //TODO: FIGMA
                      ));
                    },
                    icon: Icon(
                      Icons.copy,
                      size: 20,
                      color: EnvoyColors.darkTeal,
                    )),
                EnvoyTextButton(
                  onTap: () {
                    context.pop();
                  },
                  label: S().OK,
                ),
                IconButton(
                    onPressed: () {
                      Share.share(descriptor);
                    },
                    icon: Icon(
                      Icons.share,
                      size: 20,
                      color: EnvoyColors.darkTeal,
                    )),
              ],
            ),
          ),
        ]);
  }
}
