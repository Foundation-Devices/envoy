// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';

class TextEntry extends StatelessWidget {
  final _controller = TextEditingController();

  get enteredText => _controller.text;
  final FocusNode? focusNode;
  final int? maxLength;
  final TextAlign textAlign;

  TextEntry(
      {super.key,
      String placeholder = "",
      this.focusNode,
      this.maxLength,
      this.textAlign = TextAlign.start}) {
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
              focusNode: focusNode,
              controller: _controller,
              maxLength: maxLength,
              textAlign: textAlign,
              validator: (value) {
                return null;
              },
              decoration: const InputDecoration(
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
