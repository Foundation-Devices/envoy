// SPDX-FileCopyrightText: 2023 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later
import 'package:envoy/ui/components/envoy_checkbox.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/state/home_page_state.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CoinLockWarning extends StatefulWidget {
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
  State<CoinLockWarning> createState() => _CoinLockWarningState();
}

class _CoinLockWarningState extends State<CoinLockWarning> {
  bool dismissed = false;

  @override
  Widget build(BuildContext context) {
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
                  "WARNING", // TODO: FIGMA
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Padding(padding: EdgeInsets.all(12)),
                //TODO: updated copy & localization
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(widget.warningMessage,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w500, fontSize: 12),
                      textAlign: TextAlign.center),
                ),
                Padding(padding: EdgeInsets.all(12)),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      dismissed = !dismissed;
                    });
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        child: EnvoyCheckbox(
                          value: dismissed,
                          onChanged: (value) {
                            if (value != null)
                              setState(() {
                                dismissed = value;
                              });
                          },
                        ),
                      ),
                      Text(
                        "Do not remind me", // TODO: FIGMA
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
                  widget.buttonTitle,
                  onTap: () {
                    if (dismissed) {
                      EnvoyStorage().addPromptState(widget.promptType);
                    } else {
                      EnvoyStorage().removePromptState(widget.promptType);
                    }
                    widget.onContinue();
                  },
                  type: EnvoyButtonTypes.primaryModal,
                ),
              ],
            ),
          ],
        ));
  }
}

class CreateCoinTagWarning extends ConsumerStatefulWidget {
  final GestureTapCallback onContinue;

  const CreateCoinTagWarning({super.key, required this.onContinue});

  @override
  ConsumerState<CreateCoinTagWarning> createState() =>
      _CreateCoinTagWarningState();
}

class _CreateCoinTagWarningState extends ConsumerState<CreateCoinTagWarning> {
  bool dismissed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        dismissed = ref.read(arePromptsDismissedProvider(
            DismissiblePrompt.createCoinTagWarning));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: (MediaQuery.of(context).size.width * 0.8).clamp(254, 540),
        height: (MediaQuery.of(context).size.height * 0.54).clamp(430, 540),
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
                  "Create a tag", // TODO: FIGMA
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Padding(padding: EdgeInsets.all(12)),
                //TODO: updated copy & localization
                Text(
                    "Tags are a useful way to categorize coins within an account.", // TODO: FIGMA
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w400, fontSize: 12),
                    textAlign: TextAlign.center),
                Padding(padding: EdgeInsets.all(12)),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      dismissed = !dismissed;
                      if (dismissed)
                        EnvoyStorage().addPromptState(
                            DismissiblePrompt.createCoinTagWarning);
                      else
                        EnvoyStorage().removePromptState(
                            DismissiblePrompt.createCoinTagWarning);
                    });
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        child: EnvoyCheckbox(
                          value: dismissed,
                          onChanged: (value) {
                            if (value != null)
                              setState(() {
                                dismissed = value;
                                if (dismissed)
                                  EnvoyStorage().addPromptState(
                                      DismissiblePrompt.createCoinTagWarning);
                                else
                                  EnvoyStorage().removePromptState(
                                      DismissiblePrompt.createCoinTagWarning);
                              });
                          },
                        ),
                      ),
                      Text(
                        "Do not remind me", // TODO: FIGMA
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
                  "Return to my coins", // TODO: FIGMA
                  onTap: () {
                    Navigator.pop(context);
                  },
                  type: EnvoyButtonTypes.tertiary,
                ),
                Padding(padding: EdgeInsets.all(8)),
                EnvoyButton(
                  "Continue", // TODO: FIGMA
                  onTap: () {
                    if (!dismissed) {
                      EnvoyStorage().addPromptState(
                          DismissiblePrompt.createCoinTagWarning);
                    } else {
                      EnvoyStorage().removePromptState(
                          DismissiblePrompt.createCoinTagWarning);
                    }
                    widget.onContinue();
                  },
                  type: EnvoyButtonTypes.primaryModal,
                ),
              ],
            ),
          ],
        ));
  }
}
