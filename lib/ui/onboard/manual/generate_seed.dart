// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/envoy_seed.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/envoy_icons.dart';
import 'package:envoy/ui/onboard/manual/widgets/mnemonic_grid_widget.dart';
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
                        if (success) {
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
                    showVerificationFailedDialog(context);
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
        Container(
          alignment: Alignment.centerLeft,
          child: IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: 240,
                height: 240,
                child: RiveAnimation.asset(
                  "assets/envoy_loader.riv",
                  fit: BoxFit.contain,
                  onInit: (artboard) {
                    var _stateMachineController =
                        StateMachineController.fromArtboard(artboard, 'STM');
                    artboard.addController(_stateMachineController!);
                    _stateMachineController
                        .findInput<bool>("indeterminate")
                        ?.change(true);
                  },
                ),
              ),
              const Padding(padding: EdgeInsets.all(14)),
              Text("Generating Seed", // TODO: FIGMA
                  style: Theme.of(context).textTheme.titleMedium),
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
        Container(
          alignment: Alignment.centerLeft,
          child: IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        Expanded(
            child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                    seedList.length == 24
                        ? S().manual_setup_generate_seed_write_words_24_heading
                        : S().manual_setup_generate_seed_write_words_heading,
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center),
                const Padding(padding: EdgeInsets.all(18)),
                Expanded(
                  child: PageView(
                      controller: _seedDisplayPageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildTwoMnemonicColumns(0),
                        if (seedList.length > 12) _buildTwoMnemonicColumns(12),
                      ]),
                ),
                if (seedList.length > 12)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: DotsIndicator(
                        pageController: _seedDisplayPageController,
                        totalPages: 2),
                  ),
                OnboardingButton(
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
                )
              ],
            ),
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

    return SingleChildScrollView(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          Flexible(child: _buildMnemonicColumn(section1WithIndex)),
          Flexible(child: _buildMnemonicColumn(section2WithIndex)),
        ],
      ),
    );
  }

  Widget _buildMnemonicColumn(List<Tuple<int, String>> list) {
    final TextStyle textTheme = const TextStyle(
        fontSize: 15, color: Colors.black87, fontWeight: FontWeight.bold);
    return Column(
      children: list.map((word) {
        return Container(
          height: 40,
          margin: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          constraints: const BoxConstraints(maxWidth: 200, maxHeight: 80),
          decoration: BoxDecoration(
              color: Colors.grey[300], borderRadius: BorderRadius.circular(8)),
          child: Row(
            children: [
              Text("${word.item1}. ", style: textTheme),
              Expanded(child: Text("${word.item2}", style: textTheme)),
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
        return Container(
          height: MediaQuery.of(context).size.height * 0.38,
          width: MediaQuery.of(context).size.width * 0.8,
          constraints: const BoxConstraints(maxHeight: 400, maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Padding(padding: EdgeInsets.all(24)),
                Expanded(
                    child: Column(
                  children: [
                    const Icon(EnvoyIcons.exclamation_warning,
                        color: EnvoyColors.darkCopper, size: 56),
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
        );
      }),
    );
  }

  _buildSeedVerification(BuildContext context) {
    return Column(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          child: IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        const Padding(padding: EdgeInsets.all(14)),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                    child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Image.asset("assets/shield_ok.png"),
                )),
                Flexible(
                    child: Container(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        S().manual_setup_generate_seed_verify_seed_heading,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Padding(padding: EdgeInsets.all(24)),
                      Text(
                        S().manual_setup_generate_seed_verify_seed_subheading,
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .copyWith(fontSize: 13),
                      ),
                    ],
                  ),
                )),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: SizedBox.shrink(),
                ),
                OnboardingButton(
                    label: S().component_continue,
                    fontWeight: FontWeight.w600,
                    onTap: () {
                      _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.ease);
                    })
              ],
            ),
          ),
        ),
      ],
    );
  }
}
