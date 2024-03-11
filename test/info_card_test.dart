// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/amount_entry.dart';
import 'package:envoy/ui/components/address_widget.dart';
import 'package:envoy/ui/components/amount_widget.dart';
import 'package:envoy/ui/components/envoy_tag_list_item.dart';
import 'package:envoy/ui/components/envoy_info_card.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'util/preload_fonts.dart';
import 'package:envoy/ui/components/envoy_tag.dart';

void main() {
  testWidgets('DetailsWidget', (tester) async {
    tester.view.physicalSize = const Size(1200, 700);
    tester.view.devicePixelRatio = 1.0;

    // WORKAROUND: pump the widget twice to load the icons
    // I have no idea why this works
    for (var i = 0; i < 2; i++) {
      await preloadFonts(tester);
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Container(
              color: Colors.white,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 400),
                child: DetailsWidgetTestCases(),
              )),
        ),
      );
    }

    await expectLater(
        find.byType(Directionality), matchesGoldenFile('envoy_info_card.png'));
  });
}

class DetailsWidgetTestCases extends StatelessWidget {
  const DetailsWidgetTestCases({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    String confirmationTime = "2.5h";
    const fxRateFiat = 34743.76026697552;

    return EnvoyInfoCard(
      backgroundColor: EnvoyColors.accentSecondary,
      topWidget: const AmountWidget(
        amountSats: 12345678,
        primaryUnit: AmountDisplayUnit.btc,
        secondaryUnit: AmountDisplayUnit.fiat,
        style: AmountWidgetStyle.singleLine,
        decimalDot: true,
        fxRateFiat: fxRateFiat,
        symbolFiat: "\$",
      ),
      bottomWidgets: [
        EnvoyInfoCardListItem(
          title: S().coincontrol_tx_detail_expand_spentFrom,
          icon: const EnvoyIcon(EnvoyIcons.utxo,
              color: EnvoyColors.textPrimary, size: EnvoyIconSize.small),
          trailing: const Row(mainAxisSize: MainAxisSize.min, children: [
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
            margin: const EdgeInsets.only(
                left: EnvoySpacing.medium1, bottom: EnvoySpacing.medium1),
            child: ListView(scrollDirection: Axis.horizontal, children: const [
              EnvoyTag(title: "Tag", icon: EnvoyIcons.tag),
              EnvoyTag(title: "Tag", icon: EnvoyIcons.tag),
              EnvoyTag(title: "Tag", icon: EnvoyIcons.tag),
              EnvoyTag(title: "Tag", icon: EnvoyIcons.tag),
              EnvoyTag(title: "Tag", icon: EnvoyIcons.tag),
            ]),
          ),
        ),
        EnvoyInfoCardListItem(
            flexAlignment: FlexAlignment.flexLeft,
            title: S().coindetails_overlay_address,
            icon: const EnvoyIcon(EnvoyIcons.send,
                color: EnvoyColors.textPrimary, size: EnvoyIconSize.extraSmall),
            trailing: AddressWidget(
                address: "bc1qar0srrr7xfkvy5l643lydnw9re59gtzzwf5mdq",
                short: true)),
        EnvoyInfoCardListItem(
          title: S().coindetails_overlay_transactionID,
          icon: const EnvoyIcon(EnvoyIcons.compass,
              color: EnvoyColors.textPrimary, size: EnvoyIconSize.small),
          trailing: Text(
            "e0fe6c3e08a30b62314f7d20f66007ee440fff975491665c9d255315a0f66ecc",
            style: EnvoyTypography.body
                .copyWith(
                  color: EnvoyColors.textTertiary,
                )
                .setWeight(FontWeight.w400),
            textAlign: TextAlign.end,
            maxLines: 4,
          ),
        ),
        EnvoyInfoCardListItem(
            title:
                '${S().coindetails_overlay_confirmationIn} ~$confirmationTime',
            icon: const EnvoyIcon(EnvoyIcons.clock,
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
                    const EnvoyIcon(EnvoyIcons.rbf_boost,
                        color: EnvoyColors.textPrimaryInverse,
                        size: EnvoyIconSize.small),
                    const Padding(padding: EdgeInsets.all(EnvoySpacing.xs)),
                    Text(S().coindetails_overlay_confirmation_boost,
                        style: EnvoyTypography.button.copyWith(
                          color: EnvoyColors.textPrimaryInverse,
                        ))
                  ],
                ),
              ),
            )),
        const EnvoyInfoCardListItem(
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
        EnvoyInfoCardListItem(
            title: S().coincontrol_tx_detail_change,
            icon: const EnvoyIcon(EnvoyIcons.transfer,
                color: EnvoyColors.textPrimary, size: EnvoyIconSize.extraSmall),
            trailing: Text(
              S().coincontrol_tx_detail_no_change,
              style: EnvoyTypography.body.copyWith(
                color: EnvoyColors.textTertiary,
              ),
              textAlign: TextAlign.end,
            )),
        EnvoyInfoCardListItem(
          title: S().coincontrol_tx_detail_change,
          icon: const EnvoyIcon(EnvoyIcons.transfer,
              color: EnvoyColors.textPrimary, size: EnvoyIconSize.extraSmall),
          trailing: const Row(mainAxisSize: MainAxisSize.min, children: [
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
        EnvoyInfoCardListItem(
            title: S().coindetails_overlay_address,
            icon: const EnvoyIcon(EnvoyIcons.send,
                color: EnvoyColors.textPrimary, size: EnvoyIconSize.extraSmall),
            trailing: AddressWidget(
                address: "bc1qar0srrr7xfkvy5l643lydnw9re59gtzzwf5mdq")),
        EnvoyInfoCardListItem(
          title: S().coincontrol_tx_history_tx_detail_note,
          icon: const EnvoyIcon(EnvoyIcons.note,
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
              const Padding(padding: EdgeInsets.all(EnvoySpacing.xs)),
              const EnvoyIcon(EnvoyIcons.edit,
                  color: EnvoyColors.accentPrimary, size: EnvoyIconSize.small),
            ],
          ),
        ),
      ],
    );
  }
}
