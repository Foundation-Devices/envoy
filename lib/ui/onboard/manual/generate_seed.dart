// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/envoy_seed.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/envoy_icons.dart';
import 'package:envoy/ui/onboard/manual/manual_setup_import_backup.dart';
import 'package:rive/rive.dart';
import 'package:wallet/wallet.dart';
import 'package:envoy/ui/onboard/onboard_page_wrapper.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/ui/onboard/manual/widgets/seed_word_verification.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:envoy/util/haptics.dart';
import 'package:flutter/material.dart';
import 'package:envoy/ui/secure_screen.dart';

class GenerateSeedScreen extends StatefulWidget {
  const GenerateSeedScreen({Key? key}) : super(key: key);

  @override
  State<GenerateSeedScreen> createState() => _GenerateSeedScreenState();
}

class _GenerateSeedScreenState extends State<GenerateSeedScreen> {
  PageController _pageController = PageController();
  List<String> seed = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      enableSecureScreen();
      await Future.delayed(Duration(seconds: 1));
      setState(() {
        seed = Wallet.generateSeed().split(" ");
      });
      _pageController.animateToPage(1,
          duration: Duration(milliseconds: 300), curve: Curves.ease);
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
            _buildSeedGenerating(context),
            _buildMnemonicGrid(context),
            _buildSeedVerification(context),
            VerifySeedPuzzleWidget(
                seed: seed,
                onVerificationFinished: (bool verified) async {
                  if (verified) {
                    EnvoySeed().create(seed).then((success) {
                      if (success) {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) {
                          return ManualSetupImportBackup();
                        }));
                      } else {
                        // TODO: Show a dialog of failure
                      }
                    });
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
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
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
              Text("Generating Seed",
                  style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildMnemonicGrid(BuildContext context) {
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
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Text(S().manual_setup_generate_seed_write_words_heading,
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center),
              ),
              SliverPadding(padding: EdgeInsets.all(24)),
              SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 4,
                  crossAxisSpacing: 22.0,
                  mainAxisSpacing: 30,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final TextStyle textTheme = TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                      fontWeight: FontWeight.bold);
                  return Container(
                    height: 40,
                    margin: EdgeInsets.symmetric(vertical: 0),
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    constraints: BoxConstraints(maxWidth: 200, maxHeight: 80),
                    decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      children: [
                        Text("${index + 1}. ", style: textTheme),
                        Expanded(
                            child: Text("${seed[index]}", style: textTheme)),
                      ],
                    ),
                  );
                }, childCount: seed.length),
              ),
              SliverPadding(padding: EdgeInsets.all(32)),
              SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OnboardingButton(
                      onTap: () {
                        _pageController.nextPage(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.ease);
                      },
                      label: S().manual_setup_generate_seed_write_words_CTA,
                    )
                  ],
                ),
              )
            ],
          ),
        ))
      ],
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
          constraints: BoxConstraints(maxHeight: 400, maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
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
                    label: S()
                        .manual_setup_generate_seed_verify_seed_quiz_fail_warning_modal_CTA,
                    onTap: () async {
                      await Navigator.maybePop(context);
                      _pageController.animateToPage(1,
                          duration: Duration(milliseconds: 320),
                          curve: Curves.ease);
                    }),
                Padding(padding: EdgeInsets.all(12)),
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
            icon: Icon(Icons.chevron_left, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        Padding(padding: EdgeInsets.all(14)),
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
                      Padding(padding: EdgeInsets.all(24)),
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
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox.shrink(),
                ),
                OnboardingButton(
                    label: S().manual_setup_generate_seed_verify_seed_CTA,
                    fontWeight: FontWeight.w600,
                    onTap: () {
                      _pageController.nextPage(
                          duration: Duration(milliseconds: 300),
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
