// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/home/cards/navigation_card.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

import 'package:envoy/ui/shield_path.dart';

//ignore: must_be_immutable
class EmptyCard extends StatelessWidget with NavigationCard {
  final List<Widget> buttons;
  final EmptyCardHelperText helperText;

  EmptyCard(
    Function() addFunction, {
    required this.buttons,
    required this.helperText,
  }) : super(key: UniqueKey()) {
    modal = false;
    rightFunction = addFunction;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          helperText,
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Column(
                children: buttons
                    .map((e) => Padding(
                        padding: const EdgeInsets.only(top: 10.0), child: e))
                    .toList()),
          )
        ],
      ),
    );
  }
}

class EmptyCardHelperText extends StatelessWidget {
  final String text;
  final Function onTap;

  const EmptyCardHelperText({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    TextStyle defaultStyle = Theme.of(context).textTheme.bodyText1!;
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

class EmptyCardButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final void Function() onClicked;
  final bool shieldShape;

  const EmptyCardButton({
    Key? key,
    required this.label,
    required this.onClicked,
    required this.icon,
    this.shieldShape: false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NeumorphicButton(
      style: NeumorphicStyle(
          boxShape: shieldShape ? NeumorphicBoxShape.path(ShieldPath()) : null,
          shape: NeumorphicShape.flat,
          border: NeumorphicBorder(
            color: Color(0xFF00BDCD), // TODO: Add these to a library
            width: 3,
          ),
          depth: 8,
          lightSource: LightSource.topLeft,
          intensity: 1,
          shadowLightColor: Colors.transparent),
      onPressed: onClicked,
      child: Icon(icon, color: Color(0xFF00BDCD)),
    );
  }
}
