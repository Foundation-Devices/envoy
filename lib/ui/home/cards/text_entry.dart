// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter_neumorphic/flutter_neumorphic.dart';

class TextEntry extends StatelessWidget {
  final _controller = TextEditingController();
  get enteredText => _controller.text;

  TextEntry({String placeholder: ""}) {
    _controller.text = placeholder;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Container(
        decoration: BoxDecoration(
            color: Colors.black12, borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: TextFormField(
              controller: _controller,
              validator: (value) {
                return null;
              },
              decoration: InputDecoration(
                // Disable the borders
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
              )),
        ),
      ),
    );
  }
}
