// SPDX-FileCopyrightText: 2023 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/state/home_page_state.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CoinLockWarning extends ConsumerWidget {
  final String warningMessage;
  final String buttonTitle;
  final DismissiblePrompt promptType;
  final GestureTapCallback onContinue;

  const CoinLockWarning(
      {super.key,
      required this.onContinue,
      required this.warningMessage,
      required this.buttonTitle,
      required this.promptType});

  @override
  Widget build(BuildContext context, ref) {
    bool dismissed = ref.watch(arePromptsDismissedProvider(promptType));
    return Container(
        width: 300,
        height: 420,
        padding: EdgeInsets.all(24),
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            Align(
              alignment: Alignment(1.15, -1.1),
              child: IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Padding(padding: EdgeInsets.all(12)),
                Image.asset(
                  "assets/exclamation_triangle.png",
                  height: 68,
                  width: 68,
                ),
                Padding(padding: EdgeInsets.all(12)),
                Text(
                  "WARNING",
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Padding(padding: EdgeInsets.all(12)),
                //TODO: updated copy & localization
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(warningMessage,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w500, fontSize: 12),
                      textAlign: TextAlign.center),
                ),
                Padding(padding: EdgeInsets.all(12)),
                GestureDetector(
                  onTap: () {
                    if (!dismissed) {
                      EnvoyStorage().addPromptState(promptType);
                    } else {
                      EnvoyStorage().removePromptState(promptType);
                    }
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        child: AnimatedContainer(
                          height: 16,
                          width: 16,
                          duration: Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                  color: dismissed
                                      ? Colors.black
                                      : Color(0xff808080),
                                  width: 1)),
                          child: AnimatedContainer(
                            height: 12,
                            width: 12,
                            margin: EdgeInsets.all(2),
                            duration: Duration(milliseconds: 200),
                            curve: Curves.easeInSine,
                            decoration: BoxDecoration(
                              color: dismissed
                                  ? EnvoyColors.teal
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                      Padding(padding: EdgeInsets.all(4)),
                      Text(
                        "Do not remind me",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color:
                                  dismissed ? Colors.black : Color(0xff808080),
                            ),
                      ),
                    ],
                  ),
                ),
                Padding(padding: EdgeInsets.all(12)),
                EnvoyButton(
                  buttonTitle,
                  onTap: () {
                    onContinue();
                  },
                  type: EnvoyButtonTypes.primary,
                ),
              ],
            ),
          ],
        ));
  }
}

class CreateCoinTagWarning extends ConsumerWidget {
  final GestureTapCallback onContinue;

  const CreateCoinTagWarning({super.key, required this.onContinue});

  @override
  Widget build(BuildContext context, ref) {
    bool dismissed = ref.watch(
        arePromptsDismissedProvider(DismissiblePrompt.createCoinTagWarning));
    return Container(
        width: (MediaQuery.of(context).size.width * 0.8).clamp(254, 540),
        height: (MediaQuery.of(context).size.height * 0.5).clamp(430, 540),
        padding: EdgeInsets.all(24),
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            Align(
              alignment: Alignment(1.15, -1.1),
              child: IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Padding(padding: EdgeInsets.all(12)),
                Image.asset(
                  "assets/exclamation_icon.png",
                  height: 68,
                  width: 68,
                ),
                Padding(padding: EdgeInsets.all(12)),
                Text(
                  "Create a tag",
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Padding(padding: EdgeInsets.all(12)),
                //TODO: updated copy & localization
                Text(
                    "Tags are a useful way to categorize coins within an account.",
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w400, fontSize: 12),
                    textAlign: TextAlign.center),
                Padding(padding: EdgeInsets.all(12)),
                GestureDetector(
                  onTap: () {
                    if (!dismissed) {
                      EnvoyStorage().addPromptState(
                          DismissiblePrompt.createCoinTagWarning);
                    } else {
                      EnvoyStorage().removePromptState(
                          DismissiblePrompt.createCoinTagWarning);
                    }
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        child: AnimatedContainer(
                          height: 16,
                          width: 16,
                          duration: Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                  color: dismissed
                                      ? Colors.black
                                      : Color(0xff808080),
                                  width: 1)),
                          child: AnimatedContainer(
                            height: 12,
                            width: 12,
                            margin: EdgeInsets.all(2),
                            duration: Duration(milliseconds: 200),
                            curve: Curves.easeInSine,
                            decoration: BoxDecoration(
                              color: dismissed
                                  ? EnvoyColors.teal
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                      Padding(padding: EdgeInsets.all(4)),
                      Text(
                        "Do not remind me",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color:
                                  dismissed ? Colors.black : Color(0xff808080),
                            ),
                      ),
                    ],
                  ),
                ),
                Padding(padding: EdgeInsets.all(12)),
                EnvoyButton(
                  "Return to my coins",
                  onTap: () {
                    Navigator.pop(context);
                  },
                  type: EnvoyButtonTypes.tertiary,
                ),
                Padding(padding: EdgeInsets.all(8)),
                EnvoyButton("Continue", onTap: () {
                  onContinue();
                }),
              ],
            ),
          ],
        ));
  }
}
