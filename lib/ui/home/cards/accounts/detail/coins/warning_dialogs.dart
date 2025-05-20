// SPDX-FileCopyrightText: 2023 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/components/button.dart';
import 'package:envoy/ui/components/envoy_checkbox.dart';
import 'package:envoy/ui/home/cards/accounts/accounts_state.dart';
import 'package:envoy/ui/home/cards/accounts/spend/coin_selection_overlay.dart';
import 'package:envoy/ui/home/cards/accounts/spend/state/spend_state.dart';
import 'package:envoy/ui/state/home_page_state.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/ui/components/pop_up.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';

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
    return EnvoyPopUp(
        icon: EnvoyIcons.alert,
        typeOfMessage: PopUpState.warning,
        title: S().component_warning,
        showCloseButton: true,
        content: widget.warningMessage,
        primaryButtonLabel: widget.buttonTitle,
        onPrimaryButtonTap: (context) {
          if (dismissed) {
            EnvoyStorage().addPromptState(widget.promptType);
          } else {
            EnvoyStorage().removePromptState(widget.promptType);
          }
          widget.onContinue();
        },
        secondaryButtonLabel: S().component_back,
        onSecondaryButtonTap: (context) {
          Navigator.pop(context);
        },
        checkBoxText: S().component_dontShowAgain,
        checkedValue: false,
        onCheckBoxChanged: (checkedValue) {
          dismissed = checkedValue;
        });
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
      padding: const EdgeInsets.all(EnvoySpacing.medium2),
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
                if (ref.read(selectedAccountProvider) != null) {
                  coinSelectionOverlayKey.currentState
                      ?.show(SpendOverlayContext.preselectCoins);
                }
                Navigator.of(context).pop();
              },
            ),
          ),
          Image.asset(
            "assets/exclamation_icon.png",
            height: 68,
            width: 68,
          ),
          const SizedBox(height: EnvoySpacing.medium1),
          Text(S().change_output_from_multiple_tags_modal_heading,
              style: EnvoyTypography.heading),
          const SizedBox(height: EnvoySpacing.medium1),
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
          const SizedBox(height: EnvoySpacing.medium1),
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
          const SizedBox(height: EnvoySpacing.medium1),
          EnvoyButton(
            label: S().component_back,
            onTap: () {
              if (ref.read(selectedAccountProvider) != null) {
                coinSelectionOverlayKey.currentState
                    ?.show(SpendOverlayContext.preselectCoins);
              }
              Navigator.pop(context);
            },
            type: ButtonType.secondary,
            state: ButtonState.defaultState,
            height: 36,
          ),
          const SizedBox(height: EnvoySpacing.medium1),
          EnvoyButton(
            state: ButtonState.defaultState,
            label: S().component_continue,
            height: 36,
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
