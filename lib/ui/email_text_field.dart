// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';

class EmailTextField extends StatefulWidget {
  const EmailTextField({
    super.key,
  });

  @override
  EmailTextFieldState createState() => EmailTextFieldState();
}

class EmailTextFieldState extends State<EmailTextField> {
  bool _isValid = false;
  final emailController = TextEditingController();
  final validationCodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: emailController,
            onChanged: (value) => {
              setState(() {
                _isValid = EmailValidator.validate(value);
              }),
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(_isValid ? 'Email is valid.' : 'Email is not valid.'),
        ),
      ],
    );
  }
}
