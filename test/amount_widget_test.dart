// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/amount_entry.dart';
import 'package:envoy/ui/components/amount_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'util/preload_fonts.dart';

void main() {
  testWidgets('AmountWidget', (tester) async {
    tester.view.physicalSize = Size(1000, 600);
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
                padding: const EdgeInsets.all(20.0),
                child: AmountWidgetTestCases(),
              )),
        ),
      );
    }

    await expectLater(
        find.byType(Container), matchesGoldenFile('amount_widget.png'));
  });
}

class AmountWidgetTestCases extends StatelessWidget {
  const AmountWidgetTestCases({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Column(
          //Column for BTC
          children: [
            AmountWidget(
              amountSats: 421,
              unit: AmountDisplayUnit.btc,
              decimalDot: true,
              fxRateFiat: 2871.759259259,
              symbolFiat: "\$",
            ),
            AmountWidget(
              amountSats: 43421,
              unit: AmountDisplayUnit.btc,
              decimalDot: true,
              fxRateFiat: 2871.759259259,
              symbolFiat: "\$",
            ),
            AmountWidget(
              amountSats: 2343421,
              unit: AmountDisplayUnit.btc,
              decimalDot: true,
              fxRateFiat: 2871.759259259,
              symbolFiat: "\$",
            ),
            AmountWidget(
              amountSats: 122343421,
              unit: AmountDisplayUnit.btc,
              decimalDot: true,
              fxRateFiat: 2871.759259259,
              symbolFiat: "\$",
            ),
            AmountWidget(
              amountSats: 523722343000,
              unit: AmountDisplayUnit.btc,
              decimalDot: true,
              fxRateFiat: 2871.759259259,
              symbolFiat: "\$",
            ),
            AmountWidget(
              amountSats: 12523722300000,
              unit: AmountDisplayUnit.btc,
              decimalDot: true,
              fxRateFiat: 2871.759259259,
              symbolFiat: "\$",
            ),
            AmountWidget(
              amountSats: 512523722000000,
              unit: AmountDisplayUnit.btc,
              decimalDot: true,
              fxRateFiat: 2871.759259259,
              symbolFiat: "\$",
            ),
            AmountWidget(
              amountSats: 2012523720000000,
              unit: AmountDisplayUnit.btc,
              decimalDot: true,
              fxRateFiat: 2871.759259259,
              symbolFiat: "\$",
            ),
          ],
        ),
        SizedBox(width: 2),
        Column(//Column for sats
            children: [
          AmountWidget(
            amountSats: 421,
            unit: AmountDisplayUnit.sat,
            decimalDot: true,
            fxRateFiat: 2871.759259259,
            symbolFiat: "\$",
          ),
          AmountWidget(
            amountSats: 43421,
            unit: AmountDisplayUnit.sat,
            decimalDot: true,
            fxRateFiat: 2871.759259259,
            symbolFiat: "\$",
          ),
          AmountWidget(
            amountSats: 2343421,
            unit: AmountDisplayUnit.sat,
            decimalDot: true,
            fxRateFiat: 2871.759259259,
            symbolFiat: "\$",
          ),
          AmountWidget(
            amountSats: 22343421,
            unit: AmountDisplayUnit.sat,
            decimalDot: true,
            fxRateFiat: 2871.759259259,
            symbolFiat: "\$",
          ),
          SizedBox(height: 100),
          // section for EU
          AmountWidget(
            amountSats: 512523722000,
            unit: AmountDisplayUnit.btc,
            decimalDot: false,
            fxRateFiat: 2871.759259259,
            symbolFiat: "\$",
          ),
          AmountWidget(
            amountSats: 2343421,
            unit: AmountDisplayUnit.sat,
            decimalDot: false,
            fxRateFiat: 2871.759259259,
            symbolFiat: "\$",
          ),
          AmountWidget(
            amountSats: 122343421,
            unit: AmountDisplayUnit.sat,
            decimalDot: false,
            fxRateFiat: 2871.759259259,
            symbolFiat: "\$",
          ),
        ]),
        SizedBox(width: 2),
        Column(// Column for fiat
            children: [
          AmountWidget(
            amountSats: 421,
            unit: AmountDisplayUnit.fiat,
            decimalDot: true,
            fxRateFiat: 2871.759259259,
            symbolFiat: "\$",
          ),
          AmountWidget(
            amountSats: 43421,
            unit: AmountDisplayUnit.fiat,
            decimalDot: true,
            fxRateFiat: 2871.759259259,
            symbolFiat: "\$",
          ),
          AmountWidget(
            amountSats: 22343421,
            unit: AmountDisplayUnit.fiat,
            decimalDot: true,
            fxRateFiat: 2871.759259259,
            symbolFiat: "\$",
          ),
          AmountWidget(
            amountSats: 698197340,
            unit: AmountDisplayUnit.fiat,
            decimalDot: true,
            fxRateFiat: 2871.759259259,
            symbolFiat: "\$",
          ),
          AmountWidget(
            amountSats: 523722343000,
            unit: AmountDisplayUnit.fiat,
            decimalDot: true,
            fxRateFiat: 2871.759259259,
            symbolFiat: "\$",
          ),
          AmountWidget(
            amountSats: 512523722000000,
            unit: AmountDisplayUnit.fiat,
            decimalDot: true,
            fxRateFiat: 2871.759259259,
            symbolFiat: "\$",
          ),
        ]),
      ],
    );
  }
}
