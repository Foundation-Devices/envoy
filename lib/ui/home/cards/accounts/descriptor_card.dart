// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/account.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/home/cards/accounts/qr_tab.dart';
import 'package:envoy/ui/home/cards/envoy_text_button.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:envoy/ui/home/cards/navigation_card.dart';

//ignore: must_be_immutable
class DescriptorCard extends StatelessWidget with NavigationCard {
  final Account account;

  DescriptorCard(this.account, {CardNavigator? navigationCallback})
      : super(key: UniqueKey()) {
    optionsWidget = null;
    modal = true;
    title = S().envoy_home_accounts.toUpperCase();
    navigator = navigationCallback;
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable

    // Multipath specifier as per https://github.com/bitcoin/bitcoin/pull/22838
    // Not yet supported in BDK but showing it as such
    String descriptor = (account.wallet.publicExternalDescriptor == null
            ? account.wallet.externalDescriptor
            : account.wallet.publicExternalDescriptor!)
        .replaceAll("/0/", "/<0;1>/");

    return Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
      Padding(
        padding: const EdgeInsets.all(25.0),
        child: QrTab(
          title: account.name,
          subtitle: S().envoy_descriptor_explainer,
          account: account,
          qr: QrImage(
            data: descriptor,
            backgroundColor: Colors.white,
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
                    content: Text(S().envoy_descriptor_copied_clipboard),
                  ));
                },
                icon: Icon(
                  Icons.copy,
                  size: 20,
                  color: EnvoyColors.darkTeal,
                )),
            EnvoyTextButton(
              onTap: () {
                navigator!.pop();
              },
              label: S().component_ok,
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
