// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/amount_entry.dart';
import 'package:envoy/ui/components/address_widget.dart';
import 'package:envoy/ui/components/amount_widget.dart';
import 'package:envoy/ui/components/coin_tag_list_item.dart';
import 'package:envoy/ui/components/envoy_info_card.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'util/preload_fonts.dart';

void main() {
  testWidgets('DetailsWidget', (tester) async {
    tester.view.physicalSize = Size(1200, 700);
    tester.view.devicePixelRatio = 1.0;

    await preloadFonts(tester);

    // WORKAROUND: pump the widget twice to load the icons
    // I have no idea why this works
    for (var i = 0; i < 2; i++) {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Container(
              color: Colors.white,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10.0, horizontal: 400),
                child: DetailsWidgetTestCases(),
              )),
        ),
      );
    }

    await expectLater(
        find.byType(Directionality), matchesGoldenFile('details_widget.png'));
  });
}

class DetailsWidgetTestCases extends StatelessWidget {
  const DetailsWidgetTestCases({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    String confirmationTime = "2.5h";
    final fxRateFiat = 34743.76026697552;

    return DetailsWidget(
      backgroundColor: EnvoyColors.accentSecondary,
      topWidget: AmountWidget(
        amountSats: 12345678,
        primaryUnit: AmountDisplayUnit.btc,
        secondaryUnit: AmountDisplayUnit.fiat,
        style: AmountWidgetStyle.singleLine,
        decimalDot: true,
        fxRateFiat: fxRateFiat,
        symbolFiat: "\$",
      ),
      bottomWidgets: [
        CoinTagListItem(
          title: S().coincontrol_tx_detail_expand_spentFrom,
          icon: EnvoyIcon(EnvoyIcons.utxo,
              color: EnvoyColors.textPrimary, size: EnvoyIconSize.small),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            AmountWidget(
              amountSats: 12345678,
              primaryUnit: AmountDisplayUnit.btc,
              secondaryUnit: AmountDisplayUnit.fiat,
              style: AmountWidgetStyle.normal,
              decimalDot: true,
              fxRateFiat: fxRateFiat,
              symbolFiat: "\$",
              alignToEnd: true,
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: EnvoySpacing.medium1),
          child: Container(
            height: 16,
            margin: EdgeInsets.only(
                left: EnvoySpacing.medium1, bottom: EnvoySpacing.medium1),
            child: ListView(scrollDirection: Axis.horizontal, children: [
              _coinTag("Tag"),
              _coinTag("Tag"),
              _coinTag("Tag"),
              _coinTag("Tag"),
              _coinTag("Tag"),
            ]),
          ),
        ),
        CoinTagListItem(
            flexAlignment: FlexAlignment.flexLeft,
            title: S().coindetails_overlay_address,
            icon: EnvoyIcon(EnvoyIcons.send,
                color: EnvoyColors.textPrimary, size: EnvoyIconSize.extraSmall),
            trailing: AddressWidget(
                address: "bc1qar0srrr7xfkvy5l643lydnw9re59gtzzwf5mdq",
                short: true)),
        CoinTagListItem(
          title: S().coindetails_overlay_transactionID,
          icon: EnvoyIcon(EnvoyIcons.compass,
              color: EnvoyColors.textPrimary, size: EnvoyIconSize.small),
          trailing: Text(
            "e0fe6c3e08a30b62314f7d20f66007ee440fff975491665c9d255315a0f66ecc",
            style:
                EnvoyTypography.info.copyWith(color: EnvoyColors.textPrimary),
            textAlign: TextAlign.end,
            maxLines: 4,
          ),
        ),
        CoinTagListItem(
            title: S().coindetails_overlay_confirmationIn +
                " ~" +
                confirmationTime,
            icon: EnvoyIcon(EnvoyIcons.clock,
                color: EnvoyColors.textPrimary, size: EnvoyIconSize.extraSmall),
            trailing: Container(
              height: EnvoySpacing.medium2,
              decoration: BoxDecoration(
                  color: EnvoyColors.accentPrimary,
                  borderRadius: BorderRadius.circular(EnvoySpacing.small)),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: EnvoySpacing.medium1),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    EnvoyIcon(EnvoyIcons.rbf_boost,
                        color: EnvoyColors.textPrimaryInverse,
                        size: EnvoyIconSize.small),
                    Padding(padding: const EdgeInsets.all(EnvoySpacing.xs)),
                    Text(S().coindetails_overlay_confirmation_boost,
                        style: EnvoyTypography.button.copyWith(
                          color: EnvoyColors.textPrimaryInverse,
                        ))
                  ],
                ),
              ),
            )),
        CoinTagListItem(
          title: "Boosted Fee",
          icon: EnvoyIcon(EnvoyIcons.rbf_boost,
              color: EnvoyColors.textPrimary, size: EnvoyIconSize.small),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            AmountWidget(
              amountSats: 12345678,
              primaryUnit: AmountDisplayUnit.btc,
              secondaryUnit: AmountDisplayUnit.fiat,
              style: AmountWidgetStyle.normal,
              decimalDot: true,
              fxRateFiat: fxRateFiat,
              symbolFiat: "\$",
              alignToEnd: true,
            ),
          ]),
        ),
        CoinTagListItem(
            title: S().coincontrol_tx_detail_change,
            icon: EnvoyIcon(EnvoyIcons.transfer,
                color: EnvoyColors.textPrimary, size: EnvoyIconSize.extraSmall),
            trailing: Text(
              S().coincontrol_tx_detail_no_change,
              style:
                  EnvoyTypography.body.copyWith(color: EnvoyColors.textPrimary),
              textAlign: TextAlign.end,
            )),
        CoinTagListItem(
          title: S().coincontrol_tx_detail_change,
          icon: EnvoyIcon(EnvoyIcons.transfer,
              color: EnvoyColors.textPrimary, size: EnvoyIconSize.extraSmall),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            AmountWidget(
              amountSats: 12345678,
              primaryUnit: AmountDisplayUnit.btc,
              secondaryUnit: AmountDisplayUnit.fiat,
              style: AmountWidgetStyle.normal,
              decimalDot: true,
              fxRateFiat: fxRateFiat,
              symbolFiat: "\$",
              alignToEnd: true,
            ),
          ]),
        ),
        CoinTagListItem(
            title: S().coindetails_overlay_address,
            icon: EnvoyIcon(EnvoyIcons.send,
                color: EnvoyColors.textPrimary, size: EnvoyIconSize.extraSmall),
            trailing: AddressWidget(
                address: "bc1qar0srrr7xfkvy5l643lydnw9re59gtzzwf5mdq")),
        CoinTagListItem(
          title: S().coincontrol_tx_history_tx_detail_note,
          icon: EnvoyIcon(EnvoyIcons.note,
              color: EnvoyColors.textPrimary, size: EnvoyIconSize.small),
          trailing: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: Text("Note",
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: EnvoyTypography.body
                        .copyWith(color: EnvoyColors.textPrimary),
                    textAlign: TextAlign.end),
              ),
              Padding(padding: const EdgeInsets.all(EnvoySpacing.xs)),
              EnvoyIcon(EnvoyIcons.edit,
                  color: EnvoyColors.accentPrimary, size: EnvoyIconSize.small),
            ],
          ),
        ),
      ],
    );
  }
}

Widget _coinTag(String title) {
  return Container(
    margin: EdgeInsets.only(right: EnvoySpacing.small),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        EnvoyIcon(EnvoyIcons.tag,
            color: EnvoyColors.accentPrimary, size: EnvoyIconSize.superSmall),
        Padding(padding: const EdgeInsets.only(left: EnvoySpacing.xs)),
        Text(
          "${title}",
          style:
              EnvoyTypography.label.copyWith(color: EnvoyColors.accentPrimary),
        ),
      ],
    ),
  );
}
