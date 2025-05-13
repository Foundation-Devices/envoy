// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/amount_entry.dart';
import 'package:envoy/ui/components/amount_widget.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ngwallet/ngwallet.dart';
import 'util/preload_fonts.dart';

void main() {
  testWidgets('AmountWidget', (tester) async {
    tester.view.physicalSize = const Size(1200, 700);
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
              child: const Padding(
                padding: EdgeInsets.all(10.0),
                child: AmountWidgetTestCases(),
              )),
        ),
      );
    }

    await expectLater(
        find.byType(Directionality), matchesGoldenFile('amount_widget.png'));
  });

  testWidgets('AmountWidget with testnet account', (tester) async {
    tester.view.physicalSize = const Size(400, 600);
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
              child: const Padding(
                padding: EdgeInsets.all(10.0),
                child: AmountWidgetTestnetCases(),
              )),
        ),
      );
    }

    await expectLater(find.byType(Directionality),
        matchesGoldenFile('amount_widget_testnet.png'));
  });
}

class AmountWidgetTestCases extends StatelessWidget {
  const AmountWidgetTestCases({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    const fxRateFiat = 34743.76026697552;

    return const Padding(
      padding: EdgeInsets.all(EnvoySpacing.large1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: 200,
            child: Column(
              children: [
                AmountWidget(
                  amountSats: 421,
                  primaryUnit: AmountDisplayUnit.btc,
                  secondaryUnit: AmountDisplayUnit.fiat,
                  style: AmountWidgetStyle.normal,
                  locale: 'en_US',
                  fxRateFiat: fxRateFiat,
                  symbolFiat: "\$",
                  alignToEnd: false,
                ),
                SizedBox(height: 10),
                AmountWidget(
                  amountSats: 421,
                  primaryUnit: AmountDisplayUnit.btc,
                  secondaryUnit: AmountDisplayUnit.fiat,
                  style: AmountWidgetStyle.singleLine,
                  locale: 'en_US',
                  fxRateFiat: fxRateFiat,
                  symbolFiat: "\$",
                ),
                SizedBox(height: 10),
                AmountWidget(
                  amountSats: 0,
                  primaryUnit: AmountDisplayUnit.btc,
                  secondaryUnit: AmountDisplayUnit.fiat,
                  style: AmountWidgetStyle.singleLine,
                  locale: 'en_US',
                  fxRateFiat: fxRateFiat,
                  symbolFiat: "\$",
                ),
                SizedBox(height: 10),
                AmountWidget(
                  amountSats: 0,
                  primaryUnit: AmountDisplayUnit.sat,
                  secondaryUnit: AmountDisplayUnit.fiat,
                  style: AmountWidgetStyle.singleLine,
                  locale: 'en_US',
                  fxRateFiat: fxRateFiat,
                  symbolFiat: "\$",
                ),
                SizedBox(height: 10),
                AmountWidget(
                  amountSats: -421,
                  primaryUnit: AmountDisplayUnit.btc,
                  secondaryUnit: AmountDisplayUnit.fiat,
                  style: AmountWidgetStyle.singleLine,
                  locale: 'en_US',
                  fxRateFiat: fxRateFiat,
                  symbolFiat: "\$",
                ),
                SizedBox(height: 10),
                AmountWidget(
                  amountSats: -421,
                  primaryUnit: AmountDisplayUnit.sat,
                  secondaryUnit: AmountDisplayUnit.fiat,
                  style: AmountWidgetStyle.singleLine,
                  locale: 'en_US',
                  fxRateFiat: fxRateFiat,
                  symbolFiat: "\$",
                ),
                SizedBox(height: 10),
                AmountWidget(
                  amountSats: 0,
                  primaryUnit: AmountDisplayUnit.fiat,
                  secondaryUnit: AmountDisplayUnit.btc,
                  style: AmountWidgetStyle.large,
                  locale: 'en_US',
                  fxRateFiat: fxRateFiat,
                  symbolFiat: "\$",
                ),
                AmountWidget(
                  amountSats: -421,
                  primaryUnit: AmountDisplayUnit.fiat,
                  secondaryUnit: AmountDisplayUnit.btc,
                  style: AmountWidgetStyle.large,
                  locale: 'en_US',
                  fxRateFiat: fxRateFiat,
                  symbolFiat: "\$",
                ),
                // Testing the cursed 6 digits sat amounts
                AmountWidget(
                  amountSats: -421432,
                  primaryUnit: AmountDisplayUnit.sat,
                  secondaryUnit: AmountDisplayUnit.fiat,
                  style: AmountWidgetStyle.normal,
                  locale: 'en_US',
                  fxRateFiat: fxRateFiat,
                  symbolFiat: "\$",
                  alignToEnd: false,
                ),
              ],
            ),
          ),
          Column(
            //Column for BTC
            children: [
              AmountWidget(
                amountSats: 421,
                primaryUnit: AmountDisplayUnit.btc,
                secondaryUnit: AmountDisplayUnit.fiat,
                style: AmountWidgetStyle.large,
                locale: 'en_US',
                fxRateFiat: fxRateFiat,
                symbolFiat: "\$",
              ),
              AmountWidget(
                amountSats: 43421,
                primaryUnit: AmountDisplayUnit.btc,
                secondaryUnit: AmountDisplayUnit.fiat,
                style: AmountWidgetStyle.large,
                locale: 'en_US',
                fxRateFiat: fxRateFiat,
                symbolFiat: "\$",
              ),
              AmountWidget(
                amountSats: 2343421,
                primaryUnit: AmountDisplayUnit.btc,
                secondaryUnit: AmountDisplayUnit.fiat,
                style: AmountWidgetStyle.large,
                locale: 'en_US',
                fxRateFiat: fxRateFiat,
                symbolFiat: "\$",
              ),
              AmountWidget(
                amountSats: 122343421,
                primaryUnit: AmountDisplayUnit.btc,
                secondaryUnit: AmountDisplayUnit.fiat,
                style: AmountWidgetStyle.large,
                locale: 'en_US',
                fxRateFiat: fxRateFiat,
                symbolFiat: "\$",
              ),
              AmountWidget(
                amountSats: 523722343000,
                primaryUnit: AmountDisplayUnit.btc,
                secondaryUnit: AmountDisplayUnit.fiat,
                style: AmountWidgetStyle.large,
                locale: 'en_US',
                fxRateFiat: fxRateFiat,
                symbolFiat: "\$",
              ),
              AmountWidget(
                amountSats: 12523722300000,
                primaryUnit: AmountDisplayUnit.btc,
                secondaryUnit: AmountDisplayUnit.fiat,
                style: AmountWidgetStyle.large,
                locale: 'en_US',
                fxRateFiat: fxRateFiat,
                symbolFiat: "\$",
              ),
              AmountWidget(
                amountSats: 512523722000000,
                primaryUnit: AmountDisplayUnit.btc,
                secondaryUnit: AmountDisplayUnit.fiat,
                style: AmountWidgetStyle.large,
                locale: 'en_US',
                fxRateFiat: fxRateFiat,
                symbolFiat: "\$",
              ),
              AmountWidget(
                amountSats: 2012523720000000,
                primaryUnit: AmountDisplayUnit.btc,
                secondaryUnit: AmountDisplayUnit.fiat,
                style: AmountWidgetStyle.large,
                locale: 'en_US',
                fxRateFiat: fxRateFiat,
                symbolFiat: "\$",
              ),
            ],
          ),
          SizedBox(width: 2),
          Column(//Column for sats
              children: [
            AmountWidget(
              amountSats: 421,
              primaryUnit: AmountDisplayUnit.sat,
              secondaryUnit: AmountDisplayUnit.fiat,
              style: AmountWidgetStyle.large,
              locale: 'en_US',
              fxRateFiat: fxRateFiat,
              symbolFiat: "\$",
            ),
            AmountWidget(
              amountSats: 43421,
              primaryUnit: AmountDisplayUnit.sat,
              secondaryUnit: AmountDisplayUnit.fiat,
              style: AmountWidgetStyle.large,
              locale: 'en_US',
              fxRateFiat: fxRateFiat,
              symbolFiat: "\$",
            ),
            AmountWidget(
              amountSats: 2343421,
              primaryUnit: AmountDisplayUnit.sat,
              secondaryUnit: AmountDisplayUnit.fiat,
              style: AmountWidgetStyle.large,
              locale: 'en_US',
              fxRateFiat: fxRateFiat,
              symbolFiat: "\$",
            ),
            AmountWidget(
              amountSats: 22343421,
              primaryUnit: AmountDisplayUnit.sat,
              secondaryUnit: AmountDisplayUnit.fiat,
              style: AmountWidgetStyle.large,
              locale: 'en_US',
              fxRateFiat: fxRateFiat,
              symbolFiat: "\$",
            ),
            SizedBox(height: 100),
            // section for EU

            AmountWidget(
              amountSats: 512523722000,
              primaryUnit: AmountDisplayUnit.btc,
              secondaryUnit: AmountDisplayUnit.fiat,
              style: AmountWidgetStyle.large,
              locale: 'de_DE',
              fxRateFiat: fxRateFiat,
              symbolFiat: "\$",
            ),
            AmountWidget(
              amountSats: 2343421,
              primaryUnit: AmountDisplayUnit.sat,
              secondaryUnit: AmountDisplayUnit.fiat,
              style: AmountWidgetStyle.large,
              locale: 'de_DE',
              fxRateFiat: fxRateFiat,
              symbolFiat: "\$",
            ),
            AmountWidget(
              amountSats: 122343421,
              primaryUnit: AmountDisplayUnit.sat,
              secondaryUnit: AmountDisplayUnit.fiat,
              style: AmountWidgetStyle.large,
              locale: 'de_DE',
              fxRateFiat: fxRateFiat,
              symbolFiat: "\$",
            ),
          ]),
          SizedBox(width: 2),
          Column(// Column for fiat
              children: [
            AmountWidget(
              amountSats: 421,
              primaryUnit: AmountDisplayUnit.fiat,
              secondaryUnit: AmountDisplayUnit.btc,
              style: AmountWidgetStyle.large,
              locale: 'en_US',
              fxRateFiat: fxRateFiat,
              symbolFiat: "\$",
            ),
            AmountWidget(
              amountSats: 43421,
              primaryUnit: AmountDisplayUnit.fiat,
              secondaryUnit: AmountDisplayUnit.btc,
              style: AmountWidgetStyle.large,
              locale: 'en_US',
              fxRateFiat: fxRateFiat,
              symbolFiat: "\$",
            ),
            AmountWidget(
              amountSats: 22343421,
              primaryUnit: AmountDisplayUnit.fiat,
              secondaryUnit: AmountDisplayUnit.btc,
              style: AmountWidgetStyle.large,
              locale: 'en_US',
              fxRateFiat: fxRateFiat,
              symbolFiat: "\$",
            ),
            AmountWidget(
              amountSats: 698197340,
              primaryUnit: AmountDisplayUnit.fiat,
              secondaryUnit: AmountDisplayUnit.btc,
              style: AmountWidgetStyle.large,
              locale: 'en_US',
              fxRateFiat: fxRateFiat,
              symbolFiat: "\$",
            ),
            AmountWidget(
              amountSats: 523722343000,
              primaryUnit: AmountDisplayUnit.fiat,
              secondaryUnit: AmountDisplayUnit.btc,
              style: AmountWidgetStyle.large,
              locale: 'en_US',
              fxRateFiat: fxRateFiat,
              symbolFiat: "\$",
            ),
            AmountWidget(
              amountSats: 512523722000000,
              primaryUnit: AmountDisplayUnit.fiat,
              secondaryUnit: AmountDisplayUnit.btc,
              style: AmountWidgetStyle.large,
              locale: 'en_US',
              fxRateFiat: fxRateFiat,
              symbolFiat: "\$",
            ),
          ]),
        ],
      ),
    );
  }
}

class AmountWidgetTestnetCases extends StatelessWidget {
  const AmountWidgetTestnetCases({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(EnvoySpacing.large1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: 200,
            child: Column(
              children: [
                AmountWidget(
                  amountSats: 421,
                  primaryUnit: AmountDisplayUnit.btc,
                  style: AmountWidgetStyle.normal,
                  locale: 'en_US',
                  badgeColor: Colors.blue,
                  network: Network.Testnet,
                ),
                SizedBox(height: 10),
                AmountWidget(
                  amountSats: 421,
                  primaryUnit: AmountDisplayUnit.sat,
                  style: AmountWidgetStyle.normal,
                  locale: 'en_US',
                  badgeColor: Colors.blue,
                  network: Network.Testnet,
                ),
                SizedBox(height: 10),
                AmountWidget(
                  amountSats: 421,
                  primaryUnit: AmountDisplayUnit.btc,
                  style: AmountWidgetStyle.singleLine,
                  locale: 'en_US',
                  badgeColor: Color(0xFFBF755F),
                  network: Network.Testnet,
                ),
                AmountWidget(
                  amountSats: 421,
                  primaryUnit: AmountDisplayUnit.sat,
                  style: AmountWidgetStyle.singleLine,
                  locale: 'en_US',
                  badgeColor: Color(0xFFBF755F),
                  network: Network.Testnet,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
