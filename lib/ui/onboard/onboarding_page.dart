// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:typed_data';

import 'package:dots_indicator/dots_indicator.dart';
import 'package:envoy/business/connectivity_manager.dart';
import 'package:envoy/business/uniform_resource.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/animated_qr_image.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/onboard/onboard_page_wrapper.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:rive/rive.dart';

class OnboardingPage extends StatelessWidget {
  final Function(BuildContext)? leftFunction;
  final Function(BuildContext)? rightFunction;
  final Future<String>? qrCode;
  final Uint8List? qrCodeUrBinary;
  final Future<CryptoRequest>? qrCodeUrCryptoRequest;
  final Widget? clipArt;
  final Widget? right;
  final List<Widget>? text; // Header/text pairs
  final int navigationDots;
  final int navigationDotsIndex;
  final LinkText? helperTextAbove;
  final List<Widget>? buttons;
  final LinkText? helperTextBelow;

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
    this.rightFunction = goHome,
    this.leftFunction = goBack,
    this.right,
  }) : super(key: key);

  Widget? _determineQr() {
    if (qrCode != null) {
      return FutureBuilder<String>(
          future: qrCode,
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            return Container(
              width: double.infinity,
              child: snapshot.hasData
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox.square(
                            dimension: 230,
                            child: QrImage(
                              data: snapshot.data!,
                              backgroundColor: Colors.transparent,
                            ),
                          ),
                          Text(
                            "${snapshot.data ?? ""}",
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleSmall,
                          )
                        ],
                      ),
                    )
                  : Center(
                      child: Container(
                        height: 260,
                        child: RiveAnimation.asset(
                          "assets/envoy_loader.riv",
                          fit: BoxFit.contain,
                          animations: ["indeterminate"],
                          onInit: (artboard) {
                            var _stateMachineController =
                                StateMachineController.fromArtboard(
                                    artboard, 'STM');
                            artboard.addController(_stateMachineController!);
                            _stateMachineController
                                .findInput<bool>("indeterminate")
                                ?.change(true);
                          },
                        ),
                      ),
                    ),
            );
          });
    }

    if (qrCodeUrBinary != null) {
      return AnimatedQrImage(
        Uint8List.fromList(qrCodeUrBinary!),
      );
    }

    if (qrCodeUrCryptoRequest != null) {
      return Center(
        child: FutureBuilder<CryptoRequest>(
            future: qrCodeUrCryptoRequest,
            builder:
                (BuildContext context, AsyncSnapshot<CryptoRequest> snapshot) {
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
                      child: Text(ConnectivityManager().torEnabled &&
                              !ConnectivityManager().torCircuitEstablished
                          ? S().envoy_video_player_connecting_tor
                          : S().envoy_video_player_loading_tor),
                    )
                  ],
                );
              }
            }),
      );
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => false,
        child: OnboardPageBackground(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Flexible(
                child: Column(children: <Widget>[
                  Align(
                    alignment: Alignment.topCenter,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          leftFunction != null
                              ? Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: GestureDetector(
                                      onTap: () {
                                        leftFunction!(context);
                                      },
                                      child: Icon(Icons.arrow_back_ios_rounded,
                                          size: 20)),
                                )
                              : SizedBox.shrink(),
                          rightFunction != null
                              ? Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: GestureDetector(
                                      onTap: () {
                                        rightFunction!(context);
                                      },
                                      child: this.right == null
                                          ? Icon(Icons.close_rounded)
                                          : this.right),
                                )
                              : SizedBox.shrink()
                        ]),
                  ),
                  if (clipArt != null || _determineQr() != null)
                    Flexible(
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: clipArt != null ? clipArt! : _determineQr(),
                      ),
                    ),
                  Flexible(
                    child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [...?text]),
                  ),
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
                            padding: const EdgeInsets.all(2.0),
                            child: DotsIndicator(
                              decorator: DotsDecorator(
                                  size: Size.square(5.0),
                                  activeSize: Size.square(5.0),
                                  spacing: EdgeInsets.symmetric(horizontal: 5)),
                              dotsCount: navigationDots,
                              position: navigationDotsIndex.toDouble(),
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
        ));
  }
}

class OnboardingText extends StatelessWidget {
  final String? header;
  final String? text;

  const OnboardingText({this.header, this.text, Key? key}) : super(key: key);

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
                    style: Theme.of(context).textTheme.titleLarge,
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
                        .bodySmall!
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
                style: Theme.of(context).textTheme.titleLarge,
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

class LinkText extends StatelessWidget {
  final String text;
  final Function? onTap;

  final TextStyle? textStyle;
  final TextStyle? linkStyle;

  LinkText({required this.text, this.onTap, this.textStyle, this.linkStyle});

  @override
  Widget build(BuildContext context) {
    TextStyle textStyleBuild = textStyle == null
        ? Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 13)
        : textStyle!;
    TextStyle linkStyleBuild =
        linkStyle == null ? TextStyle(color: EnvoyColors.darkTeal) : linkStyle!;

    List<TextSpan> spans = [];

    // Due to intl weirdness let's split on either {{ or [[
    String openingBraces = "{{";
    String closingBraces = "}}";

    var firstPass = text.split(openingBraces);

    if (firstPass.length == 1) {
      openingBraces = "[[";
      closingBraces = "]]";
      firstPass = text.split(openingBraces);
    }

    for (var span in firstPass) {
      if (!span.contains(closingBraces)) {
        spans.add(TextSpan(text: span));
      } else {
        spans.add(TextSpan(
            text: span.split(closingBraces)[0],
            style: linkStyleBuild,
            recognizer: TapGestureRecognizer()
              ..onTap = onTap as GestureTapCallback?));

        spans.add(TextSpan(text: span.split(closingBraces)[1]));
      }
    }

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: textStyleBuild,
        children: <TextSpan>[...spans],
      ),
    );
  }
}

class OnboardingButton extends StatelessWidget {
  final String label;
  final void Function() onTap;
  final TextStyle? textStyle;
  final FontWeight? fontWeight;

  final EnvoyButtonTypes type;

  const OnboardingButton(
      {Key? key,
      required this.label,
      this.type = EnvoyButtonTypes.primary,
      this.textStyle,
      this.fontWeight = null,
      required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
      child: EnvoyButton(
        label,
        onTap: onTap,
        fontWeight: fontWeight,
        textStyle: this.textStyle,
        type: type,
      ),
    );
  }
}
