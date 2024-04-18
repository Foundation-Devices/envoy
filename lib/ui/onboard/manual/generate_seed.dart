// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/envoy_seed.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/components/envoy_scaffold.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/envoy_icons.dart';
import 'package:envoy/ui/onboard/manual/widgets/mnemonic_grid_widget.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
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

  const SeedScreen({Key? key, this.generate = true}) : super(key: key);

  @override
  State<SeedScreen> createState() => _SeedScreenState();
}

class _SeedScreenState extends State<SeedScreen> {
  PageController _pageController = PageController();
  PageController _seedDisplayPageController = PageController();
  bool _onSecondPage = false;

  List<String> seedList = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      enableSecureScreen();

      if (widget.generate) {
        await Future.delayed(Duration(seconds: 1));
        setState(() {
          seedList = Wallet.generateSeed().split(" ");
        });
        _pageController.animateToPage(1,
            duration: Duration(milliseconds: 300), curve: Curves.ease);
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
          physics: NeverScrollableScrollPhysics(),
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
                            return ManualSetupCreateAndStoreBackup();
                          }));
                        }
                      });
                    } else {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return ManualSetupCreateAndStoreBackup();
                      }));
                    }
                  } else {
                    await Future.delayed(Duration(milliseconds: 100));
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
            icon: Icon(Icons.chevron_left, color: Colors.black),
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
              Padding(padding: EdgeInsets.all(14)),
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
            icon: Icon(Icons.chevron_left, color: Colors.black),
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
                Padding(padding: EdgeInsets.all(18)),
                Expanded(
                  child: PageView(
                      controller: _seedDisplayPageController,
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        _buildTwoMnemonicColumns(0),
                        if (seedList.length > 12) _buildTwoMnemonicColumns(12),
                      ]),
                ),
                if (seedList.length > 12)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: DotsIndicator(
                        pageController: _seedDisplayPageController,
                        totalPages: 2),
                  ),
                Padding(
                  padding: const EdgeInsets.only(bottom: EnvoySpacing.medium2),
                  child: OnboardingButton(
                    onTap: () async {
                      if (seedList.length == 12 || _onSecondPage) {
                        await _pageController.nextPage(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.ease);
                      } else {
                        setState(() {
                          _onSecondPage = true;
                        });
                        await _seedDisplayPageController.nextPage(
                            duration: Duration(milliseconds: 300),
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
      constraints: BoxConstraints(maxWidth: 420),
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
    final TextStyle textTheme = TextStyle(
        fontSize: 15, color: Colors.black87, fontWeight: FontWeight.bold);
    double margin = MediaQuery.of(context).devicePixelRatio < 2.5 ? 4 : 14;

    return Column(
      children: list.map((word) {
        return Container(
          height: 40,
          margin: EdgeInsets.symmetric(vertical: margin, horizontal: 8),
          padding: EdgeInsets.symmetric(horizontal: 8),
          constraints:
              BoxConstraints(maxWidth: 220, minWidth: 160, maxHeight: 40),
          decoration: BoxDecoration(
              color: Colors.grey[300], borderRadius: BorderRadius.circular(8)),
          child: Row(
            mainAxisSize: MainAxisSize.max,
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
        final heightFactor =
            MediaQuery.sizeOf(context).width < 380 ? 0.7 : 0.38;
        return Container(
          height: MediaQuery.of(context).size.height * heightFactor,
          width: MediaQuery.of(context).size.width * 0.8,
          constraints: BoxConstraints(maxHeight: 400, maxWidth: 400),
          child: EnvoyScaffold(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(padding: EdgeInsets.all(24)),
                  Expanded(
                      child: Column(
                    children: [
                      Icon(EnvoyIcons.exclamation_warning,
                          color: EnvoyColors.darkCopper, size: 56),
                      Padding(padding: EdgeInsets.all(12)),
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
                            duration: Duration(milliseconds: 320),
                            curve: Curves.ease);
                      }),
                  Padding(padding: EdgeInsets.all(12)),
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
        Flexible(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.chevron_left,
                          color: Colors.black, size: EnvoySpacing.medium3),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.close,
                          color: Colors.black, size: EnvoySpacing.medium2),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: EnvoySpacing.medium2),
                  child: Container(
                    constraints: BoxConstraints.tight(Size.fromHeight(200)),
                    child: Image.asset(
                      "assets/shield_ok.png",
                      height: 180,
                      width: 180,
                    ),
                  ),
                ),
                Text(
                  S().manual_setup_generate_seed_verify_seed_heading,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
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
        Padding(
          padding: const EdgeInsets.only(bottom: EnvoySpacing.medium2),
          child: OnboardingButton(
              label: S().component_continue,
              fontWeight: FontWeight.w600,
              onTap: () {
                _pageController.nextPage(
                    duration: Duration(milliseconds: 300), curve: Curves.ease);
              }),
        ),
      ],
    );
  }
}
