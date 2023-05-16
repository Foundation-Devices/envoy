// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter_neumorphic/flutter_neumorphic.dart';

import 'envoy_colors.dart';

class EnvoyToggleOption {
  final String name;
  final String? innerDescription;
  final String? outerDescription;

  EnvoyToggleOption(this.name, this.innerDescription, this.outerDescription);
}

class EnvoyToggle extends StatefulWidget {
  final double width;
  final double height;
  final List<EnvoyToggleOption> options;

  final Color selectedOptionColor = EnvoyColors.teal;
  final Color selectedOptionSecondaryColor = Colors.white;
  final Color deselectedOptionColor = Colors.black;

  final Color backgroundColor = Colors.grey;

  final double outerDescriptionHeight = 70.0;

  final Function(int)? onToggled;

  EnvoyToggle(
      {Key? key,
      this.width = 500,
      this.height = 200,
      required this.options,
      this.onToggled})
      : super(key: key);

  @override
  State<EnvoyToggle> createState() => _EnvoyToggleState();
}

class _EnvoyToggleState extends State<EnvoyToggle> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Column(children: [
        NeumorphicToggle(
          padding: const EdgeInsets.all(0),
          style: NeumorphicToggleStyle(
              backgroundColor: widget.backgroundColor, disableDepth: true),
          width: widget.width,
          height: widget.height - widget.outerDescriptionHeight,
          selectedIndex: _selectedIndex,
          displayForegroundOnlyIfSelected: false,
          onChanged: (value) {
            setState(() {
              _selectedIndex = value;

              if (widget.onToggled != null) {
                widget.onToggled!(value);
              }
            });
          },
          children: widget.options
              .map(
                (o) => ToggleElement(
                  background: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          o.name,
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: widget.deselectedOptionColor),
                        ),
                        Text(
                          o.innerDescription!,
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: widget.deselectedOptionColor),
                        )
                      ],
                    ),
                  ),
                  foreground: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          o.name,
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: widget.selectedOptionSecondaryColor),
                        ),
                        Text(
                          o.innerDescription!,
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: widget.selectedOptionSecondaryColor),
                        )
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
          thumb: Container(
              decoration: BoxDecoration(
            color: EnvoyColors.teal,
          )),
        ),
        Row(
            //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: widget.options.map((o) {
          // One cannot access the index during a List.map operation in Dart
          int index = widget.options.indexOf(o);
          return SizedBox(
            height: widget.outerDescriptionHeight,
            width: widget.width / widget.options.length,
            child: Center(
              child: Text(
                o.outerDescription!,
                style: index == _selectedIndex
                    ? TextStyle(
                        fontWeight: FontWeight.w700,
                        color: widget.selectedOptionColor)
                    : TextStyle(
                        fontWeight: FontWeight.w500,
                        color: widget.deselectedOptionColor),
              ),
            ),
          );
        }).toList())
      ]),
    );
  }
}
