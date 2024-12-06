// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/envoy_seed.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/components/envoy_scaffold.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/envoy_icons.dart';
import 'package:envoy/ui/onboard/manual/widgets/mnemonic_grid_widget.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/util/tuple.dart';
import 'package:rive/rive.dart';
import 'package:wallet/wallet.dart';
import 'package:envoy/ui/onboard/onboard_page_wrapper.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/ui/onboard/manual/widgets/seed_word_verification.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:envoy/util/haptics.dart';
import 'package:flutter/material.dart';
import 'package:envoy/ui/envoy_method_channel.dart';
import 'package:envoy/ui/onboard/manual/manual_setup_create_and_store_backup.dart';
import 'package:envoy/ui/envoy_button.dart';

class SeedScreen extends StatefulWidget {
  final bool generate;

  const SeedScreen({super.key, this.generate = true});

  @override
  State<SeedScreen> createState() => _SeedScreenState();
}

class _SeedScreenState extends State<SeedScreen> {
  final PageController _pageController = PageController();
  final PageController _seedDisplayPageController = PageController();
  bool _onSecondPage = false;

  List<String> seedList = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      enableSecureScreen();

      if (widget.generate) {
        await Future.delayed(const Duration(seconds: 1));
        setState(() {
          seedList = Wallet.generateSeed().split(" ");
        });
        _pageController.animateToPage(1,
            duration: const Duration(milliseconds: 300), curve: Curves.ease);
      } else {
        final seed = await EnvoySeed().get();
        setState(() {
          seedList = seed!.split(" ");
        });
      }
    });
  }

  @override
  void dispose() {
    disableSecureScreen();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OnboardPageBackground(
      child: Material(
        color: Colors.transparent,
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            if (widget.generate) _buildSeedGenerating(context),
            _buildMnemonicGrid(context),
            _buildSeedVerification(context),
            VerifySeedPuzzleWidget(
                seed: seedList,
                onVerificationFinished: (bool verified) async {
                  if (verified) {
                    if (widget.generate) {
                      EnvoySeed().create(seedList).then((success) {
                        if (success && context.mounted) {
                          Navigator.of(context, rootNavigator: true)
                              .push(MaterialPageRoute(builder: (context) {
                            return const ManualSetupCreateAndStoreBackup();
                          }));
                        }
                      });
                    } else {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return const ManualSetupCreateAndStoreBackup();
                      }));
                    }
                  } else {
                    await Future.delayed(const Duration(milliseconds: 100));
                    Haptics.heavyImpact();
                    if (context.mounted) {
                      showVerificationFailedDialog(context);
                    }
                  }
                }),
          ],
        ),
      ),
    );
  }

  Widget _buildSeedGenerating(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.all(EnvoySpacing.medium1),
            child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Icon(Icons.arrow_back_ios_rounded,
                    size: EnvoySpacing.medium2)),
          ),
        ),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                width: 240,
                height: 240,
                child: RiveAnimation.asset(
                  "assets/envoy_loader.riv",
                  fit: BoxFit.contain,
                  onInit: (artboard) {
                    var stateMachineController =
                        StateMachineController.fromArtboard(artboard, 'STM');
                    artboard.addController(stateMachineController!);
                    stateMachineController
                        .findInput<bool>("indeterminate")
                        ?.change(true);
                  },
                ),
              ),
              const Padding(padding: EdgeInsets.all(14)),
              Text(S().manual_setup_generatingSeedLoadingInfo,
                  style: EnvoyTypography.heading),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildMnemonicGrid(BuildContext context) {
    if (seedList.isEmpty) {
      return Container();
    }

    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.all(EnvoySpacing.medium1),
            child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Icon(Icons.arrow_back_ios_rounded,
                    size: EnvoySpacing.medium2)),
          ),
        ),
        Expanded(
            child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: EnvoySpacing.medium2),
                child: Text(
                    seedList.length == 24
                        ? S().manual_setup_generate_seed_write_words_24_heading
                        : S().manual_setup_generate_seed_write_words_heading,
                    style: EnvoyTypography.heading
                        .copyWith(color: EnvoyColors.textPrimary),
                    textAlign: TextAlign.center),
              ),
              const Padding(padding: EdgeInsets.all(EnvoySpacing.medium1)),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: EnvoySpacing.medium2),
                  child: PageView(
                      controller: _seedDisplayPageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildTwoMnemonicColumns(0),
                        if (seedList.length > 12) _buildTwoMnemonicColumns(12),
                      ]),
                ),
              ),
              if (seedList.length > 12)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: EnvoySpacing.small),
                  child: DotsIndicator(
                      pageController: _seedDisplayPageController,
                      totalPages: 2),
                ),
              Padding(
                padding: const EdgeInsets.only(
                    left: EnvoySpacing.xs,
                    right: EnvoySpacing.xs,
                    bottom: EnvoySpacing.medium2),
                child: OnboardingButton(
                  onTap: () async {
                    if (seedList.length == 12 || _onSecondPage) {
                      await _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.ease);
                    } else {
                      setState(() {
                        _onSecondPage = true;
                      });
                      await _seedDisplayPageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.ease);
                    }
                  },
                  label: seedList.length == 12 || _onSecondPage
                      ? S().component_done
                      : S().component_continue,
                ),
              )
            ],
          ),
        ))
      ],
    );
  }

  Widget _buildTwoMnemonicColumns(int startingIndex) {
    List<String> section1 = seedList.sublist(startingIndex, startingIndex + 6);
    List<String> section2 =
        seedList.sublist(startingIndex + 6, startingIndex + 12);
    List<Tuple<int, String>> section1WithIndex = [];
    List<Tuple<int, String>> section2WithIndex = [];

    section1.asMap().forEach((index, element) {
      section1WithIndex.add(Tuple(startingIndex + index + 1, element));
    });

    section2.asMap().forEach((index, element) {
      section2WithIndex.add(Tuple(startingIndex + index + 7, element));
    });

    // If the screen is too small, show the words as a list
    bool showWordsAsList = MediaQuery.sizeOf(context).width < 380;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: SingleChildScrollView(
        child: Container(
          child: showWordsAsList
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(child: _buildMnemonicColumn(section1WithIndex)),
                    Flexible(child: _buildMnemonicColumn(section2WithIndex)),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Flexible(child: _buildMnemonicColumn(section1WithIndex)),
                    Flexible(child: _buildMnemonicColumn(section2WithIndex)),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildMnemonicColumn(List<Tuple<int, String>> list) {
    const TextStyle textTheme = TextStyle(
        fontSize: 15, color: Colors.black87, fontWeight: FontWeight.bold);
    double margin = MediaQuery.of(context).devicePixelRatio < 2.5 ? 4 : 14;

    return Column(
      children: list.map((word) {
        return Container(
          height: 40,
          margin: EdgeInsets.symmetric(vertical: margin, horizontal: 8),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          constraints:
              const BoxConstraints(maxWidth: 220, minWidth: 160, maxHeight: 40),
          decoration: BoxDecoration(
              color: Colors.grey[300], borderRadius: BorderRadius.circular(8)),
          child: Row(
            children: [
              Text("${word.item1}. ", style: textTheme),
              Expanded(child: Text(word.item2, style: textTheme)),
            ],
          ),
        );
      }).toList(),
    );
  }

  void showVerificationFailedDialog(BuildContext context) {
    showEnvoyDialog(
      context: context,
      dismissible: false,
      builder: Builder(builder: (context) {
        final heightFactor =
            MediaQuery.sizeOf(context).width < 380 ? 0.7 : 0.38;
        return Container(
          height: MediaQuery.of(context).size.height * heightFactor,
          width: MediaQuery.of(context).size.width * 0.8,
          constraints: const BoxConstraints(maxHeight: 400, maxWidth: 400),
          child: EnvoyScaffold(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Padding(padding: EdgeInsets.all(24)),
                  Expanded(
                      child: Column(
                    children: [
                      const Icon(EnvoyIcons.exclamationWarning,
                          color: EnvoyColors.copper500, size: 56),
                      const Padding(padding: EdgeInsets.all(12)),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          S().manual_setup_generate_seed_verify_seed_quiz_fail_warning_modal_subheading,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  )),
                  OnboardingButton(
                      type: EnvoyButtonTypes.primaryModal,
                      label: S().component_back,
                      onTap: () async {
                        Navigator.pop(context);
                        _pageController.animateToPage(1,
                            duration: const Duration(milliseconds: 320),
                            curve: Curves.ease);
                      }),
                  const Padding(padding: EdgeInsets.all(12)),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  _buildSeedVerification(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left,
                      color: Colors.black, size: EnvoySpacing.medium3),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.close,
                      color: Colors.black, size: EnvoySpacing.medium2),
                  onPressed: () {
                    // Tap on "x" should exit the flow, so pop twice to navigate back two levels
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            Image.asset(
              "assets/shield_ok.png",
              height: 250,
              width: 250,
            ),
          ],
        ),
        const SizedBox(
          height: EnvoySpacing.medium2,
        ),
        Flexible(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(S().manual_setup_generate_seed_verify_seed_heading,
                    textAlign: TextAlign.center,
                    style: EnvoyTypography.heading
                        .copyWith(color: EnvoyColors.textPrimary)),
                Padding(
                  padding: const EdgeInsets.all(EnvoySpacing.medium2),
                  child: Text(
                    S().manual_setup_generate_seed_verify_seed_subheading,
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall!
                        .copyWith(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(
          height: EnvoySpacing.large2,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: EnvoySpacing.xs, vertical: EnvoySpacing.medium2),
          child: OnboardingButton(
              label: S().component_continue,
              fontWeight: FontWeight.w600,
              onTap: () {
                _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.ease);
              }),
        ),
      ],
    );
  }
}
