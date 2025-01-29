// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:animations/animations.dart';
import 'package:envoy/ui/components/envoy_scaffold.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/onboard/onboard_page_wrapper.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/ui/onboard/prime/firmware_update/prime_fw_update_state.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/ui/widgets/envoy_gradient_progress.dart';
import 'package:envoy/ui/widgets/envoy_step_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rive/rive.dart';

class OnboardPrimeFwUpdate extends ConsumerStatefulWidget {
  const OnboardPrimeFwUpdate({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _OnboardPrimeFwUpdateState();
}

class _OnboardPrimeFwUpdateState extends ConsumerState<OnboardPrimeFwUpdate> {
  StateMachineController? _progressAnimationController;
  @override
  Widget build(BuildContext context) {
    final primeUpdateState = ref.watch(primeUpdateStateProvider);

    Widget downloadImage = Image.asset(
      "assets/images/fw_download.png",
      alignment: Alignment.bottomCenter,
      width: 230,
      height: 230,
    );

    Widget progressAnimation = Transform.scale(
      scale: 1.2,
      child: SizedBox(
        width: 230,
        height: 230,
        child: RiveAnimation.asset(
          "assets/envoy_loader.riv",
          fit: BoxFit.contain,
          alignment: Alignment.center,
          onInit: (artboard) {
            _progressAnimationController =
                StateMachineController.fromArtboard(artboard, 'STM');
            artboard.addController(_progressAnimationController!);
            _progressAnimationController
                ?.findInput<bool>("indeterminate")
                ?.change(true);
          },
        ),
      ),
    );

    return PopScope(
      canPop: false,
      child: OnboardPageBackground(
          child: EnvoyScaffold(
        removeAppBarPadding: true,
        // topBarActions: [
        //   OnboardingButton(
        //     label: "Cancel",
        //     type: EnvoyButtonTypes.secondary,
        //     onTap: () {
        //        ref.read(primeUpdateStateProvider.notifier).state = PrimeFwUpdateStep.idle;
        //     },
        //   )
        // ],
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: EnvoySpacing.small, vertical: EnvoySpacing.small),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            spacing: 24,
            children: [
              _pageTransitionBuilder(
                  context: context,
                  child: switch (primeUpdateState) {
                    PrimeFwUpdateStep.idle ||
                    PrimeFwUpdateStep.downloading ||
                    PrimeFwUpdateStep.transferring =>
                      downloadImage,
                    _ => progressAnimation
                  }),
              Expanded(
                  child: Column(
                children: [
                  Text(
                    key: ValueKey(_getTitle(context)),
                    _getTitle(context),
                    textAlign: TextAlign.center,
                    style: EnvoyTypography.heading,
                  ),
                  const Padding(padding: EdgeInsets.all(EnvoySpacing.small)),
                  Expanded(
                    child: _pageTransitionBuilder(
                      context: context,
                      child: switch (primeUpdateState) {
                        PrimeFwUpdateStep.idle => _updateIntroWidget(context),
                        PrimeFwUpdateStep.downloading ||
                        PrimeFwUpdateStep.transferring =>
                          const PrimeFwDownloadProgress(),
                        PrimeFwUpdateStep.verifying ||
                        PrimeFwUpdateStep.installing ||
                        PrimeFwUpdateStep.rebooting =>
                          const PrimeFwFlashProgress(),
                        PrimeFwUpdateStep.finished =>
                          _updateFinishedWidget(context),
                        PrimeFwUpdateStep.error => _updateErrorWidget(context),
                        // TODO: Handle this case.
                      },
                    ),
                  )
                ],
              )),
            ],
          ),
        ),
      )),
    );
  }

  Widget _pageTransitionBuilder(
      {required BuildContext context, required Widget child}) {
    return PageTransitionSwitcher(
      child: child,
      transitionBuilder: (child, animation, secondaryAnimation) {
        return SharedAxisTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          transitionType: SharedAxisTransitionType.vertical,
          fillColor: Colors.transparent,
          child: child,
        );
      },
    );
  }

  initFWUpdate() async {
    final primeUpdateNotifier = ref.read(primeUpdateStateProvider.notifier);
    final fwDownloadNotifier = ref.read(fwDownloadStateProvider.notifier);
    final fwTransferStateNotifier = ref.read(fwTransferStateProvider.notifier);
    final fwProgressNotifier = ref.read(fwDownloadProgressProvider.notifier);
    final primFwVerifyStateNotifier =
        ref.read(primeFwSigVerifyStateProvider.notifier);
    final primFwInstallStateNotifier =
        ref.read(primeFwInstallStateProvider.notifier);
    final primFwRebootStateNotifier =
        ref.read(primeFwRebootStateProvider.notifier);

    primeUpdateNotifier.state = PrimeFwUpdateStep.downloading;
    fwDownloadNotifier.updateStep("Downloading Update", EnvoyStepState.LOADING);
    fwProgressNotifier.state = .4;
    await Future.delayed(const Duration(seconds: 2));
    fwProgressNotifier.state = .8;
    await Future.delayed(const Duration(seconds: 2));
    fwProgressNotifier.state = 1.0;
    await Future.delayed(const Duration(seconds: 2));
    fwDownloadNotifier.updateStep("Update downloaded", EnvoyStepState.FINISHED);

    primeUpdateNotifier.state = PrimeFwUpdateStep.transferring;
    fwProgressNotifier.state = 0.0;
    fwTransferStateNotifier.updateStep(
        "Transfering to Passport Prime", EnvoyStepState.LOADING);
    await Future.delayed(const Duration(seconds: 1));
    fwProgressNotifier.state = 0.3;
    await Future.delayed(const Duration(seconds: 1));
    fwProgressNotifier.state = .5;
    await Future.delayed(const Duration(seconds: 2));
    fwProgressNotifier.state = .8;
    await Future.delayed(const Duration(seconds: 2));
    fwProgressNotifier.state = 1.0;
    fwTransferStateNotifier.updateStep(
        "Transferred to Passport Prime", EnvoyStepState.FINISHED);
    await Future.delayed(const Duration(seconds: 2));

    primeUpdateNotifier.state = PrimeFwUpdateStep.verifying;
    primFwVerifyStateNotifier.updateStep(
        "Verifying Signatures", EnvoyStepState.LOADING);
    await Future.delayed(const Duration(seconds: 2));
    primeUpdateNotifier.state = PrimeFwUpdateStep.installing;
    primFwVerifyStateNotifier.updateStep(
        "Signatures verified", EnvoyStepState.FINISHED);
    primFwInstallStateNotifier.updateStep(
        "Installing Update", EnvoyStepState.LOADING);
    await Future.delayed(const Duration(seconds: 2));

    primeUpdateNotifier.state = PrimeFwUpdateStep.rebooting;
    primFwInstallStateNotifier.updateStep(
        "Update installed", EnvoyStepState.FINISHED);
    primFwRebootStateNotifier.updateStep(
        "Passport Prime is rebooting", EnvoyStepState.LOADING);
    await Future.delayed(const Duration(seconds: 2));
    primFwRebootStateNotifier.updateStep(
        "Passport Prime is rebooting", EnvoyStepState.FINISHED);
    await Future.delayed(const Duration(seconds: 1));
    _progressAnimationController
        ?.findInput<bool>("indeterminate")
        ?.change(false);
    _progressAnimationController?.findInput<bool>("happy")?.change(true);
    _progressAnimationController?.findInput<bool>("unhappy")?.change(false);

    primeUpdateNotifier.state = PrimeFwUpdateStep.finished;
  }

  Widget _updateFinishedWidget(BuildContext context) {
    return Column(
      children: [
        Text(
          //TODO: copy update
          "Passport Prime was successfully\nupdated to Version 2.4.1.",
          textAlign: TextAlign.center,
          style: EnvoyTypography.explainer.copyWith(fontSize: 14),
        ),
        const Padding(padding: EdgeInsets.all(EnvoySpacing.small)),
        Padding(
          padding: const EdgeInsets.all(EnvoySpacing.small),
          child: Text(
            "Continue the setup on Passport Prime.",
            textAlign: TextAlign.center,
            style: EnvoyTypography.explainer.copyWith(fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _updateIntroWidget(BuildContext context) {
    return Column(
      children: [
        Text(
          //TODO: copy update
          "Estimated Update Time ~5 min.",
          textAlign: TextAlign.center,
          style: EnvoyTypography.explainer.copyWith(fontSize: 14),
        ),
        const Padding(padding: EdgeInsets.all(EnvoySpacing.small)),
        Padding(
          padding: const EdgeInsets.all(EnvoySpacing.small),
          child: Text(
            "Your device is on Version 2.3.0 and there is an update available. We strongly suggest to update the device now.\n\nBut you could also trigger the update later from the settings menu. ",
            textAlign: TextAlign.center,
            style: EnvoyTypography.explainer.copyWith(fontSize: 14),
          ),
        ),
        Expanded(
            child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: EnvoySpacing.small)
              .add(const EdgeInsets.only(
            top: EnvoySpacing.medium2,
          )),
          child: const Placeholder(),
        )),
        OnboardingButton(
            label: "Begin Firmware Update",
            type: EnvoyButtonTypes.primary,
            fontWeight: FontWeight.w600,
            onTap: initFWUpdate),
      ],
    );
  }

  String _getTitle(BuildContext context) {
    final primeUpdateState = ref.watch(primeUpdateStateProvider);
    //TODO: copy update
    return switch (primeUpdateState) {
      PrimeFwUpdateStep.idle => "Firmware Update Available",
      PrimeFwUpdateStep.downloading => "Updating Passport Prime",
      PrimeFwUpdateStep.transferring ||
      PrimeFwUpdateStep.verifying ||
      PrimeFwUpdateStep.installing ||
      PrimeFwUpdateStep.rebooting =>
        "Updating Passport Prime…",
      PrimeFwUpdateStep.finished => "Update successful",
      PrimeFwUpdateStep.error => "Firmware Update Error",
    };
  }

  //TODO: add error screen
  _updateErrorWidget(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class PrimeFwDownloadProgress extends ConsumerStatefulWidget {
  const PrimeFwDownloadProgress({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PrimeFwDownloadProgressState();
}

class _PrimeFwDownloadProgressState
    extends ConsumerState<PrimeFwDownloadProgress> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: EnvoySpacing.medium1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            //TODO: copy update
            "Keep both Devices nearby.",
            textAlign: TextAlign.center,
            style: EnvoyTypography.explainer.copyWith(fontSize: 14),
          ),
          const Padding(padding: EdgeInsets.all(EnvoySpacing.small)),
          Expanded(
              child: Padding(
            padding: const EdgeInsets.only(
              left: EnvoySpacing.medium1,
            ),
            child: Wrap(
              alignment: WrapAlignment.center,
              direction: Axis.horizontal,
              crossAxisAlignment: WrapCrossAlignment.center,
              runSpacing: EnvoySpacing.medium1,
              children: [
                const Padding(padding: EdgeInsets.all(EnvoySpacing.xs)),
                EnvoyStepItem(
                    step: ref.watch(fwDownloadStateProvider), highlight: false),
                EnvoyStepItem(
                    step: ref.watch(fwTransferStateProvider), highlight: false),
                const Padding(padding: EdgeInsets.all(EnvoySpacing.small)),
                Consumer(builder: (context, ref, child) {
                  final progress = ref.watch(fwDownloadProgressProvider);
                  return Column(
                    children: [
                      EnvoyGradientProgress(
                        progress: progress,
                      ),
                      const Padding(
                          padding: EdgeInsets.all(EnvoySpacing.small)),
                      //TODO: update with time remaining
                      Text(
                        "2 min remaining",
                        style: EnvoyTypography.explainer.copyWith(fontSize: 14),
                      ),
                    ],
                  );
                })
              ],
            ),
          ))
        ],
      ),
    );
  }
}

class PrimeFwFlashProgress extends ConsumerStatefulWidget {
  const PrimeFwFlashProgress({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PrimeFwFlashProgressState();
}

class _PrimeFwFlashProgressState extends ConsumerState<PrimeFwFlashProgress> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: EnvoySpacing.medium1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            //TODO: copy update
            "Keep both Devices nearby.",
            textAlign: TextAlign.center,
            style: EnvoyTypography.explainer.copyWith(fontSize: 14),
          ),
          const Padding(padding: EdgeInsets.all(EnvoySpacing.small)),
          Padding(
            padding: const EdgeInsets.only(
              left: EnvoySpacing.medium2,
            ),
            child: Wrap(
              alignment: WrapAlignment.center,
              direction: Axis.horizontal,
              crossAxisAlignment: WrapCrossAlignment.center,
              runSpacing: EnvoySpacing.medium1,
              children: [
                const Padding(padding: EdgeInsets.all(EnvoySpacing.xs)),
                EnvoyStepItem(
                    step: ref.watch(primeFwSigVerifyStateProvider),
                    highlight: false),
                EnvoyStepItem(
                    step: ref.watch(primeFwInstallStateProvider),
                    highlight: false),
                EnvoyStepItem(
                    step: ref.watch(primeFwRebootStateProvider),
                    highlight: false),
                const Padding(padding: EdgeInsets.all(EnvoySpacing.small)),
              ],
            ),
          ),
          Consumer(builder: (context, ref, child) {
            final progress = ref.watch(primeFwRebootStateProvider);
            if (progress.state == EnvoyStepState.LOADING) {
              //TODO: copy update
              return Text(
                "Setup will resume afterwards automatically.",
                textAlign: TextAlign.center,
                style: EnvoyTypography.explainer.copyWith(fontSize: 12),
              );
            } else {
              return const SizedBox.shrink();
            }
          })
        ],
      ),
    );
  }
}
