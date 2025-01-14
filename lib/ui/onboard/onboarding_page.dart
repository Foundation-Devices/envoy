// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:typed_data';

import 'package:dots_indicator/dots_indicator.dart';
import 'package:envoy/business/uniform_resource.dart';
import 'package:envoy/ui/animated_qr_image.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/onboard/onboard_page_wrapper.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/ui/widgets/envoy_qr_widget.dart';
import 'package:envoy/util/build_context_extension.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:go_router/go_router.dart';
import 'package:envoy/ui/theme/envoy_colors.dart' as new_color_scheme;
import 'package:envoy/ui/components/address_widget.dart';

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
    Navigator.pop(context);
  }

  static popBackToHome(BuildContext context) {
    context.go("/");
  }

  const OnboardingPage({
    super.key,
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
    this.rightFunction = popBackToHome,
    this.leftFunction = goBack,
    this.right,
  });

  Widget? _determineQr() {
    if (qrCode != null) {
      return FutureBuilder<String>(
          future: qrCode,
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            return SizedBox(
              width: double.infinity,
              child: snapshot.hasData
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          EnvoyQR(
                            //TODO: adjust Qr for Boomers
                            dimension: 230,
                            data: snapshot.data!,
                          ),
                          SizedBox(
                            width: 250,
                            child: AddressWidget(
                              address: snapshot.data!,
                              short: false,
                              align: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Center(
                      child: SizedBox(
                        height: 260,
                        child: RiveAnimation.asset(
                          "assets/envoy_loader.riv",
                          fit: BoxFit.contain,
                          animations: const ["indeterminate"],
                          onInit: (artboard) {
                            var stateMachineController =
                                StateMachineController.fromArtboard(
                                    artboard, 'STM');
                            artboard.addController(stateMachineController!);
                            stateMachineController
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
                return const SizedBox(
                  height: 150,
                  width: 150,
                  child: CircularProgressIndicator(
                    color: EnvoyColors.accentPrimary,
                    backgroundColor: EnvoyColors.textTertiary,
                    strokeWidth: 8,
                  ),
                );
              }
            }),
      );
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
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
                              padding:
                                  const EdgeInsets.all(EnvoySpacing.medium1),
                              child: GestureDetector(
                                  onTap: () {
                                    leftFunction!(context);
                                  },
                                  child: const Icon(
                                      Icons.arrow_back_ios_rounded,
                                      size: 20)),
                            )
                          : const SizedBox.shrink(),
                      rightFunction != null
                          ? Padding(
                              padding:
                                  const EdgeInsets.all(EnvoySpacing.medium1),
                              child: GestureDetector(
                                  onTap: () {
                                    rightFunction!(context);
                                  },
                                  child:
                                      right ?? const Icon(Icons.close_rounded)),
                            )
                          : const SizedBox.shrink()
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
                child: SingleChildScrollView(
                  child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [...?text]),
                ),
              ),
            ]),
          ),
          Padding(
            padding: EdgeInsets.only(
                left: EnvoySpacing.xs,
                right: EnvoySpacing.xs,
                bottom: context.isSmallScreen
                    ? EnvoySpacing.medium1
                    : EnvoySpacing.medium2),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                navigationDots != 0
                    ? Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: DotsIndicator(
                          decorator: const DotsDecorator(
                              size: Size.square(5.0),
                              activeSize: Size.square(5.0),
                              spacing: EdgeInsets.symmetric(horizontal: 5)),
                          dotsCount: navigationDots,
                          position: navigationDotsIndex.toDouble(),
                        ),
                      )
                    : const SizedBox.shrink(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: helperTextAbove ?? const SizedBox.shrink(),
                ),
                ...?buttons,
                helperTextBelow ?? const SizedBox.shrink()
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
  final double subtitleTopPadding;

  const OnboardingText(
      {this.header,
      this.text,
      super.key,
      this.subtitleTopPadding = EnvoySpacing.large2});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 18),
        child: Column(
          children: [
            header != null
                ? Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(header!,
                        textAlign: TextAlign.center,
                        style: EnvoyTypography.heading))
                : const SizedBox.shrink(),
            text != null
                ? Padding(
                    padding: EdgeInsets.only(top: subtitleTopPadding),
                    child: Text(
                      text!,
                      textAlign: TextAlign.center,
                      style: EnvoyTypography.info.copyWith(
                        height: 1.2,
                        color: new_color_scheme.EnvoyColors.inactiveDark,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  )
                : const SizedBox.shrink()
          ],
        ),
      ),
    );
  }
}

class ActionText extends StatelessWidget {
  final String header;
  final String text;
  final Function() action;

  const ActionText(
      {super.key,
      required this.header,
      required this.text,
      required this.action});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
          onTap: action,
          child: Column(
            children: [
              Text(header,
                  textAlign: TextAlign.center, style: EnvoyTypography.heading),
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

  final TextAlign textAlign;
  final TextStyle? textStyle;
  final TextStyle? linkStyle;

  const LinkText(
      {super.key,
      required this.text,
      this.onTap,
      this.textStyle,
      this.linkStyle,
      this.textAlign = TextAlign.center});

  @override
  Widget build(BuildContext context) {
    TextStyle textStyleBuild = textStyle == null
        ? Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 13)
        : textStyle!;
    TextStyle linkStyleBuild = linkStyle == null
        ? const TextStyle(color: EnvoyColors.accentPrimary)
        : linkStyle!;

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
      textAlign: textAlign,
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
  final bool enabled;

  const OnboardingButton(
      {super.key,
      required this.label,
      this.type = EnvoyButtonTypes.primary,
      this.textStyle,
      this.fontWeight,
      this.enabled = true,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
      child: EnvoyButton(
        label,
        onTap: onTap,
        fontWeight: fontWeight,
        textStyle: textStyle,
        type: type,
      ),
    );
  }
}
