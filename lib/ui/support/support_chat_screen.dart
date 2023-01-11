// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:chatwoot_client_sdk/chatwoot_client_sdk.dart';
import 'package:chatwoot_client_sdk/ui/chatwoot_chat_theme.dart';
import 'package:email_validator/email_validator.dart';
import 'package:envoy/business/local_storage.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/envoy_dialog.dart';
import 'package:envoy/ui/home/cards/text_entry.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:envoy/ui/widgets/toast/envoy_toast.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../envoy_colors.dart';

const CHAT_IDENTIFIER = "CHAT_IDENTIFIER";
const CHAT_EMAIL = "CHAT_EMAIL";

class SupportChatScreen extends StatefulWidget {
  const SupportChatScreen({Key? key}) : super(key: key);

  @override
  State<SupportChatScreen> createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends State<SupportChatScreen> {
  String? identifier;
  String? chatEmail;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      onViewReady();
    });
  }

  void onViewReady() async {
    LocalStorage localStorage = LocalStorage();
    String? identifierSaved = await localStorage.readSecure(CHAT_IDENTIFIER);
    String? chatEmailSaved = await localStorage.readSecure(CHAT_EMAIL);
    if (chatEmailSaved == null) {
      FocusNode focusNode = FocusNode();
      bool isKeyboardShown = false;
      await showEnvoyDialog(
        context: context,
        dismissible: false,
        dialog: Builder(
          builder: (context) {
            var textEntry = TextEntry(
              focusNode: focusNode,
              inputType: TextInputType.emailAddress,
            );
            if (!isKeyboardShown) {
              Future.delayed(Duration(milliseconds: 200)).then((value) {
                FocusScope.of(context).requestFocus(focusNode);
              });
              isKeyboardShown = true;
            }
            return EnvoyDialog(
              title: "Give the team a way to reach you",
              content: textEntry,
              actions: [
                EnvoyButton(
                  "Submit",
                  light: false,
                  onTap: () async {
                    if (textEntry.enteredText.isEmpty ||
                        !EmailValidator.validate(textEntry.enteredText)) {
                      EnvoyToast(
                        backgroundColor: Colors.lightBlue,
                        message: "Invalid email address",
                        icon: Icon(
                          Icons.error_outline_rounded,
                          color: EnvoyColors.darkCopper,
                        ),
                        duration: Duration(milliseconds: 2000),
                        onActionTap: () {
                          Navigator.pop(context);
                        },
                      ).show(context);
                      return;
                    }
                    Navigator.pop(context);
                    String uuid = Uuid().v4();
                    await localStorage.saveSecure(CHAT_IDENTIFIER, uuid);
                    await localStorage.saveSecure(
                        CHAT_EMAIL, textEntry.enteredText);
                    identifierSaved = uuid;
                    setState(() {
                      chatEmail = textEntry.enteredText;
                      identifier = identifierSaved;
                    });
                  },
                ),
              ],
            );
          },
        ),
      );
      await Future.delayed(Duration(milliseconds: 400));
      if (chatEmail == null) {
        Navigator.pop(context);
      }
    }

    if (identifierSaved != null && chatEmailSaved != null) {
      setState(() {
        identifier = identifierSaved;
        chatEmail = chatEmailSaved;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (chatEmail == null || identifier == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: BackButton(
            color: Colors.black,
          ),
          elevation: 0,
          title: Text(
            "Foundation Support",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return ChatwootChat(
      showUserNames: true,
      theme: ChatwootChatTheme(
        userAvatarImageBackgroundColor: EnvoyColors.darkCopper,
      ),
      baseUrl: "https://chatwoot.foundationdevices.com",
      inboxIdentifier: "1JpMBndDbngR2iDFhV5fWH1G",
      user: ChatwootUser(
        identifier: identifier,
        name: null,
        email: chatEmail,
      ),
      appBar: AppBar(
        leading: BackButton(
          color: Colors.black,
        ),
        elevation: 0,
        title: GestureDetector(
          onLongPress: () {
            try {
              LocalStorage().removeSecure(CHAT_EMAIL);
              LocalStorage().removeSecure(CHAT_IDENTIFIER);
              ChatwootClient.clearAllData();
            } catch (e) {
              print(e);
            }
            Navigator.pop(context);
          },
          child: Text(
            "Foundation Support",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
        backgroundColor: Colors.white,
      ),
    );
  }
}
