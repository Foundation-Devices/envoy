// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/account.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/home/cards/accounts/qr_tab.dart';
import 'package:envoy/ui/home/cards/envoy_text_button.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:envoy/ui/home/cards/navigation_card.dart';

//ignore: must_be_immutable
class AddressCard extends StatelessWidget with NavigationCard {
  final Account account;

  AddressCard(this.account, {CardNavigator? navigationCallback})
      : super(key: UniqueKey()) {
    optionsWidget = null;
    modal = true;
    title = S().envoy_home_accounts.toUpperCase();
    navigator = navigationCallback;
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable

    return FutureBuilder<String>(
        future: account.wallet.getAddress(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: QrTab(
                        title: account.name,
                        subtitle: S().envoy_address_explainer,
                        account: account,
                        qr: QrImage(
                          data: snapshot.data!,
                          backgroundColor: Colors.white,
                        )),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 60),
                    child: GestureDetector(
                      onTap: () {
                        _copyAddressToClipboard(context, snapshot.data!);
                      },
                      child: Text(
                        snapshot.data!,
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge!
                            .copyWith(color: EnvoyColors.darkTeal),
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        EdgeInsets.only(left: 50.0, right: 50.0, bottom: 30.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IconButton(
                            onPressed: () {
                              _copyAddressToClipboard(context, snapshot.data!);
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
                              Share.share("bitcoin:" + snapshot.data!);
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
          } else {
            return Center(
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

  void _copyAddressToClipboard(BuildContext context, String address) {
    Clipboard.setData(ClipboardData(text: address));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(S().envoy_address_copied_clipboard),
    ));
  }
}
