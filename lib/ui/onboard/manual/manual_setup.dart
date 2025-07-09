// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/envoy_seed.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/onboard/manual/generate_seed.dart';
import 'package:envoy/ui/onboard/manual/widgets/wordlist.dart';
import 'package:envoy/ui/onboard/onboard_page_wrapper.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/ui/onboard/routes/onboard_routes.dart';
import 'package:envoy/ui/onboard/seed_passphrase_entry.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/ui/widgets/scanner/decoders/seed_decoder.dart';
import 'package:envoy/ui/widgets/scanner/qr_scanner.dart';
import 'package:envoy/util/console.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum SeedIntroScreenType {
  generate,
  import,
  verify,
}

class SeedIntroScreen extends StatelessWidget {
  final SeedIntroScreenType mode;

  const SeedIntroScreen({super.key, required this.mode});

  @override
  Widget build(BuildContext context) {
    return OnboardPageBackground(
        child: Material(
            color: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                          onTap: () {
                            context.pop();
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(EnvoySpacing.medium1),
                            child: Icon(Icons.arrow_back_ios_rounded,
                                size: EnvoySpacing.medium2),
                          )),
                    ),
                    Container(
                      child: mode == SeedIntroScreenType.generate ||
                              mode == SeedIntroScreenType.verify
                          ? Image.asset(
                              "assets/shield_inspect.png",
                              width: 190,
                              height: 190,
                            )
                          : Image.asset(
                              "assets/fw_download.png",
                              width: 150,
                              height: 150,
                            ),
                    ),
                  ],
                ),
                Flexible(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: EnvoySpacing.medium2),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            mode == SeedIntroScreenType.generate ||
                                    mode == SeedIntroScreenType.verify
                                ? S().manual_setup_generate_seed_heading
                                : S().manual_setup_import_seed_heading,
                            textAlign: TextAlign.center,
                            style: EnvoyTypography.heading,
                          ),
                          const SizedBox(
                            height: EnvoySpacing.medium2,
                          ),
                          Text(
                            mode == SeedIntroScreenType.generate ||
                                    mode == SeedIntroScreenType.verify
                                ? S().manual_setup_generate_seed_subheading
                                : S().manual_setup_import_seed_subheading,
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(fontSize: 13),
                          ),
                          const SizedBox(
                            height: EnvoySpacing.medium2,
                          ),
                          if (mode == SeedIntroScreenType.import)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: EnvoySpacing.medium2,
                              ),
                              child: Text(
                                S().manual_setup_import_seed_passport_warning,
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                        fontSize: 13,
                                        color: EnvoyColors.accentSecondary,
                                        fontWeight: FontWeight.w700),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: EnvoySpacing.xs,
                      vertical: EnvoySpacing.medium2 + EnvoySpacing.xs),
                  child: mode == SeedIntroScreenType.generate ||
                          mode == SeedIntroScreenType.verify
                      ? OnboardingButton(
                          label: mode == SeedIntroScreenType.generate
                              ? S().manual_setup_generate_seed_CTA
                              : S()
                                  .backups_erase_wallets_and_backups_show_seed_CTA,
                          fontWeight: FontWeight.w600,
                          onTap: () {
                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: (context) {
                              return Builder(builder: (context) {
                                return SeedScreen(
                                    generate:
                                        mode == SeedIntroScreenType.generate);
                              });
                            }));
                          })
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OnboardingButton(
                                type: EnvoyButtonTypes.secondary,
                                label: S().manual_setup_import_seed_CTA3,
                                fontWeight: FontWeight.w600,
                                onTap: () {
                                  context
                                      .goNamed(ONBOARD_ENVOY_MANUAL_IMPORT_12);
                                }),
                            OnboardingButton(
                                type: EnvoyButtonTypes.secondary,
                                label: S().manual_setup_import_seed_CTA2,
                                fontWeight: FontWeight.w600,
                                onTap: () {
                                  context
                                      .goNamed(ONBOARD_ENVOY_MANUAL_IMPORT_24);
                                }),
                            OnboardingButton(
                                type: EnvoyButtonTypes.primary,
                                label: S().manual_setup_import_seed_CTA1,
                                fontWeight: FontWeight.w600,
                                onTap: () {
                                  showScannerDialog(
                                      context: context,
                                      onBackPressed: (context) {
                                        Navigator.pop(context);
                                      },
                                      decoder: SeedQrDecoder(
                                        onSeedValidated: (String result) {
                                          context.pop();
                                          List<String> seedWords =
                                              result.split(" ");
                                          bool isValid = seedWords
                                              .map((e) => seedEn.contains(e))
                                              .reduce((value, element) =>
                                                  value && element);
                                          if (!isValid) {
                                            showInvalidSeedDialog(
                                              context: context,
                                            );
                                            return;
                                          }

                                          kPrint("isValid $isValid $seedWords");
                                          Future.delayed(Duration.zero, () {
                                            if (context.mounted) {
                                              checkSeed(context, result);
                                            }
                                          });
                                        },
                                      ));
                                }),
                          ],
                        ),
                ),
              ],
            )));
  }
}

Future<void> checkSeed(BuildContext context, String seed) async {
  if (!await EnvoySeed().create(seed.split(" ")) && context.mounted) {
    showInvalidSeedDialog(
      context: context,
    );
  } else {
    context.goNamed(ONBOARD_ENVOY_MANUAL_IMPORT_SEED, extra: seed);
  }
}
