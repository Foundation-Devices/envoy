import 'dart:convert';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/home/cards/accounts/qr_tab.dart';
import 'package:envoy/ui/home/cards/navigation_card.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:envoy/ui/animated_qr_image.dart';
import 'package:envoy/ui/pages/scanner_page.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tor/tor.dart';
import 'package:wallet/wallet.dart';
import 'package:envoy/ui/envoy_icons.dart';
import 'package:envoy/ui/background.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/business/account.dart';

//ignore: must_be_immutable
class PsbtCard extends StatelessWidget with NavigationCard {
  final Psbt psbt;
  final Account account;

  PsbtCard(this.psbt, this.account, {CardNavigator? navigationCallback})
      : super(key: UniqueKey()) {
    optionsWidget = null;
    modal = true;
    title = "Accounts".toUpperCase();
    navigator = navigationCallback;
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final loc = AppLocalizations.of(context)!;
    return Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
      Padding(
          padding: const EdgeInsets.all(25.0),
          child: QrTab(
            title: "Scan the QR on your Passport",
            subtitle: "It contains the transaction for your Passport to sign.",
            account: account,
            qr: AnimatedQrImage(
              base64Decode(psbt.base64),
              urType: "crypto-psbt",
              binaryCborTag: true,
            ),
          )),
      Padding(
        padding: EdgeInsets.only(left: 50.0, right: 50.0, bottom: 30.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: psbt.base64));
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("PSBT copied to clipboard!"),
                  ));
                },
                icon: Icon(
                  Icons.copy,
                  size: 20,
                  color: EnvoyColors.darkTeal,
                )),
            IconButton(
                onPressed: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return ScannerPage.tx((psbt) {
                      print(psbt);
                      account.wallet.decodePsbt(psbt).then((decoded) {
                        account.wallet
                            .broadcastTx(Settings().electrumAddress(),
                                Tor().port, decoded.rawTx)
                            .then((_) {
                          navigator!.pop(depth: 3);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("Transaction sent!"),
                          ));
                        });
                      });
                    });
                  }));
                },
                icon: Icon(
                  EnvoyIcons.qr_scan,
                  size: 20,
                  color: EnvoyColors.darkTeal,
                )),
            IconButton(
                onPressed: () {
                  Share.share(psbt.base64);
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

class PsbtTile extends StatelessWidget {
  PsbtTile({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRect(
        child: GestureDetector(
      child: Container(
          height: 100,
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  EnvoyColors.listTileColorPairs[0].lighter,
                  EnvoyColors.listTileColorPairs[0].darker,
                ]),
          ),
          child: Stack(children: [
            Positioned.fill(
              child: CustomPaint(
                painter: LinesPainter(),
              ),
            ),
            Center(
                child: ListTile(
              title: Text(
                "Scan the QR on your Passport",
                style: Theme.of(context)
                    .textTheme
                    .bodyText1!
                    .copyWith(color: Colors.white),
              ),
              subtitle: Text(
                "It contains the transaction for your Passport to sign.",
                style: Theme.of(context)
                    .textTheme
                    .caption!
                    .copyWith(color: Colors.white70),
              ),
              trailing: Icon(
                Icons.info_outline,
                color: Colors.white70,
              ),
            )),
          ])),
    ));
  }
}
