import 'package:flutter/material.dart';

class EnvoyDialog extends StatelessWidget {
  final Widget? title;
  final Widget? content;
  final List<Widget>? actions;

  EnvoyDialog({this.title, this.content, this.actions});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(25.0))),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        buttonPadding: EdgeInsets.zero,
        titlePadding: EdgeInsets.only(left: 25, right: 25, bottom: 10, top: 20),
        contentPadding:
            EdgeInsets.only(left: 25, right: 25, bottom: 10, top: 10),
        actionsPadding:
            EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 10),
        title: title,
        content: content,
        actions: actions);
  }
}
