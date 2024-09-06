// SPDX-FileCopyrightText: 2023 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/components/button.dart';
import 'package:envoy/ui/components/envoy_checkbox.dart';
import 'package:envoy/ui/state/home_page_state.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';

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
    double contentSpacing = EnvoySpacing.medium1;
    if (MediaQuery.sizeOf(context).width < 350) {
      contentSpacing = EnvoySpacing.small;
    }

    return Container(
      //clamp the width so it doesn't stretch too much
      width: (MediaQuery.sizeOf(context).width * 0.75).clamp(280, 400),
      padding: const EdgeInsets.symmetric(
          horizontal: EnvoySpacing.medium1, vertical: EnvoySpacing.medium1),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 34,
              alignment: Alignment.centerRight,
              child: IconButton(
                padding: const EdgeInsets.all(0),
                icon: const Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            Image.asset(
              "assets/exclamation_triangle.png",
              height: 54,
              width: 54,
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: contentSpacing),
                Text(
                  S().component_warning,
                  style: EnvoyTypography.heading,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: contentSpacing),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    widget.warningMessage,
                    style: EnvoyTypography.info.copyWith(
                      color: EnvoyColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: contentSpacing),
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
                      EnvoyCheckbox(
                        value: dismissed,
                        visualDensity: VisualDensity.compact,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              dismissed = value;
                            });
                          }
                        },
                      ),
                      Text(
                        S().component_dontShowAgain,
                        style: EnvoyTypography.info.copyWith(
                          color: EnvoyColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: contentSpacing),
              ],
            ),
            Flexible(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                EnvoyButton(
                  label: S().component_back,
                  onTap: () {
                    Navigator.pop(context);
                  },
                  type: ButtonType.secondary,
                  state: ButtonState.defaultState,
                ),
                const SizedBox(height: EnvoySpacing.small),
                EnvoyButton(
                  label: widget.buttonTitle,
                  state: ButtonState.defaultState,
                  edgeInsets: const EdgeInsets.all(0),
                  onTap: () {
                    if (dismissed) {
                      EnvoyStorage().addPromptState(widget.promptType);
                    } else {
                      EnvoyStorage().removePromptState(widget.promptType);
                    }
                    widget.onContinue();
                  },
                  type: ButtonType.primary,
                ),
              ],
            ))
          ],
        ),
      ),
    );
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
      width: (MediaQuery.of(context).size.width * 0.7).clamp(300, 540),
      padding: const EdgeInsets.all(EnvoySpacing.medium1),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              padding: const EdgeInsets.all(EnvoySpacing.small),
              icon: const Icon(Icons.close),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          Image.asset(
            "assets/exclamation_icon.png",
            height: 68,
            width: 68,
          ),
          const Padding(padding: EdgeInsets.all(EnvoySpacing.xs)),
          Text(S().change_output_from_multiple_tags_modal_heading,
              style: EnvoyTypography.heading),
          const Padding(padding: EdgeInsets.all(EnvoySpacing.xs)),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: EnvoySpacing.medium1),
            child: Text(S().create_first_tag_modal_1_2_subheading,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w400, fontSize: 12),
                textAlign: TextAlign.center),
          ),
          const Padding(padding: EdgeInsets.all(EnvoySpacing.xs)),
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
                      if (value != null) {
                        setState(() {
                          dismissed = value;
                        });
                      }
                    },
                  ),
                ),
                Text(
                  S().component_dontShowAgain,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color:
                            dismissed ? Colors.black : const Color(0xff808080),
                      ),
                ),
              ],
            ),
          ),
          EnvoyButton(
            label: S().component_back,
            onTap: () {
              Navigator.pop(context);
            },
            type: ButtonType.primary,
            state: ButtonState.defaultState,
          ),
          const Padding(padding: EdgeInsets.all(EnvoySpacing.xs)),
          EnvoyButton(
            state: ButtonState.defaultState,
            label: S().component_continue,
            onTap: () {
              ///user has dismissed the prompt
              if (dismissed) {
                EnvoyStorage()
                    .addPromptState(DismissiblePrompt.createCoinTagWarning);
              } else {
                EnvoyStorage()
                    .removePromptState(DismissiblePrompt.createCoinTagWarning);
              }
              widget.onContinue();
            },
            type: ButtonType.primary,
          ),
        ],
      ),
    );
  }
}
