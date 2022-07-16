import 'package:envoy/business/uniform_resource.dart';
import 'package:envoy/ui/background.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:envoy/ui/animated_qr_image.dart';
import 'dart:typed_data';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/shield.dart';

class OnboardingPage extends StatelessWidget {
  final Function(BuildContext)? leftFunction;
  final Function(BuildContext)? rightFunction;
  final Future<String>? qrCode;
  final Uint8List? qrCodeUrBinary;
  final Future<CryptoRequest>? qrCodeUrCryptoRequest;
  final Widget? clipArt;
  final List<Widget>? text; // Header/text pairs
  final int navigationDots;
  final int navigationDotsIndex;
  final OnboardingHelperText? helperTextAbove;
  final List<OnboardingButton>? buttons;
  final OnboardingHelperText? helperTextBelow;

  // Default functions need to be static:
  //https://github.com/dart-lang/language/issues/1048
  //https://stackoverflow.com/a/62379038
  static goBack(context) {
    Navigator.of(context).pop();
  }

  static goHome(context) {
    Navigator.of(context).popUntil(ModalRoute.withName("/"));
  }

  OnboardingPage({
    Key? key,
    this.qrCode,
    this.clipArt,
    this.text,
    this.navigationDots = 0,
    this.navigationDotsIndex = 0,
    this.helperTextAbove,
    this.buttons,
    this.helperTextBelow,
    this.qrCodeUrBinary,
    this.qrCodeUrCryptoRequest,
    this.rightFunction: goHome,
    this.leftFunction: goBack,
  }) : super(key: key);

  Widget _determineQr() {
    if (qrCode != null) {
      return FutureBuilder<String>(
          future: qrCode,
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (snapshot.hasData) {
              return QrImage(
                data: snapshot.data!,
                backgroundColor: Colors.transparent,
              );
            } else {
              return CircularProgressIndicator();
            }
          });
    }

    if (qrCodeUrBinary != null) {
      return AnimatedQrImage(
        Uint8List.fromList(qrCodeUrBinary!),
      );
    }

    if (qrCodeUrCryptoRequest != null) {
      return Expanded(
        child: Center(
          child: FutureBuilder<CryptoRequest>(
              future: qrCodeUrCryptoRequest,
              builder: (BuildContext context,
                  AsyncSnapshot<CryptoRequest> snapshot) {
                if (snapshot.hasData) {
                  return AnimatedQrImage.fromUrCryptoRequest(snapshot.data!
                    ..fragmentLength = 20); // NOTE: Adjusted for Jean-Pierre
                } else {
                  return Column(
                    children: [
                      CircularProgressIndicator(
                        color: EnvoyColors.darkTeal,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Securely loading QR code"),
                      )
                    ],
                  );
                }
              }),
        ),
      );
    }

    return SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    double _shieldTop = MediaQuery.of(context).padding.top + 6.0;
    double _shieldBottom = MediaQuery.of(context).padding.bottom + 6.0;

    return WillPopScope(
        onWillPop: () async => false,
        child: Stack(
          children: [
            AppBackground(),
            Padding(
              padding: EdgeInsets.only(
                  right: 5.0,
                  left: 5.0,
                  top: _shieldTop,
                  bottom: _shieldBottom),
              child: Hero(
                tag: "shield",
                transitionOnUserGestures: true,
                flightShuttleBuilder: (
                  BuildContext flightContext,
                  Animation<double> animation,
                  HeroFlightDirection flightDirection,
                  BuildContext fromHeroContext,
                  BuildContext toHeroContext,
                ) {
                  return AnimatedBuilder(
                    animation: animation,
                    builder: (BuildContext context, Widget? child) {
                      return Stack(children: [
                        flightDirection == HeroFlightDirection.push
                            ? toHeroContext.widget
                            : fromHeroContext.widget,
                        Opacity(
                          opacity: 1 - animation.value,
                          child: flightDirection == HeroFlightDirection.push
                              ? fromHeroContext.widget
                              : toHeroContext.widget,
                        )
                      ]);
                    },
                  );
                },
                child: Shield(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        right: 15, left: 15, top: 15, bottom: 50),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Flexible(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Flexible(
                                  child: Stack(
                                    alignment: Alignment.topCenter,
                                    children: [
                                      clipArt != null
                                          ? clipArt!
                                          : SizedBox.shrink(),
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            leftFunction != null
                                                ? Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            16.0),
                                                    child: GestureDetector(
                                                        onTap: () {
                                                          leftFunction!(
                                                              context);
                                                        },
                                                        child: Icon(
                                                            Icons
                                                                .arrow_back_ios_rounded,
                                                            size: 20)),
                                                  )
                                                : SizedBox.shrink(),
                                            rightFunction != null
                                                ? Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            16.0),
                                                    child: GestureDetector(
                                                        onTap: () {
                                                          rightFunction!(
                                                              context);
                                                        },
                                                        child: Icon(Icons
                                                            .close_rounded)),
                                                  )
                                                : SizedBox.shrink()
                                          ])
                                    ],
                                  ),
                                ),
                                _determineQr(),
                                ...?text,
                              ]),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              navigationDots != 0
                                  ? Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: DotsIndicator(
                                        decorator: DotsDecorator(
                                            size: Size.square(5.0),
                                            activeSize: Size.square(5.0),
                                            spacing: EdgeInsets.symmetric(
                                                horizontal: 5)),
                                        dotsCount: navigationDots,
                                        position:
                                            navigationDotsIndex.toDouble(),
                                      ),
                                    )
                                  : SizedBox.shrink(),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: helperTextAbove ?? SizedBox.shrink(),
                              ),
                              ...?buttons,
                              helperTextBelow ?? SizedBox.shrink()
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ));
  }
}

class OnboardingText extends StatelessWidget {
  final String? header;
  final String? text;

  const OnboardingText({this.header, this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          header != null
              ? Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    header!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headline6,
                  ),
                )
              : SizedBox.shrink(),
          text != null
              ? Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    text!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .caption!
                        .copyWith(fontSize: 13),
                  ),
                )
              : SizedBox.shrink()
        ],
      ),
    );
  }
}

class ActionText extends StatelessWidget {
  final String header;
  final String text;
  final Function() action;

  const ActionText(
      {required this.header, required this.text, required this.action});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
          onTap: action,
          child: Column(
            children: [
              Text(
                header,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headline6,
              ),
              Text(
                text,
                textAlign: TextAlign.center,
              )
            ],
          )),
    );
  }
}

class OnboardingHelperText extends StatelessWidget {
  final String text;
  final Function onTap;

  const OnboardingHelperText({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    TextStyle defaultStyle =
        Theme.of(context).textTheme.caption!.copyWith(fontSize: 13);
    TextStyle linkStyle = TextStyle(color: EnvoyColors.darkTeal);

    List<TextSpan> spans = [];

    var firstPass = text.split("{{");

    for (var span in firstPass) {
      if (!span.contains("}}")) {
        spans.add(TextSpan(text: span));
      } else {
        spans.add(TextSpan(
            text: span.split("}}")[0],
            style: linkStyle,
            recognizer: TapGestureRecognizer()
              ..onTap = onTap as GestureTapCallback?));

        spans.add(TextSpan(text: span.split("}}")[1]));
      }
    }

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: defaultStyle,
        children: <TextSpan>[...spans],
      ),
    );
  }
}

class OnboardingButton extends StatelessWidget {
  final String label;
  final void Function() onTap;
  final bool light;

  const OnboardingButton(
      {Key? key, required this.label, required this.onTap, this.light: false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
      child: GestureDetector(
          onTap: onTap,
          child: EnvoyButton(
            label,
            light: light,
          )),
    );
  }
}
