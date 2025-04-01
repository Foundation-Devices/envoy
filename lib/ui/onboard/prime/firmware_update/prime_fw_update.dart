// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:animations/animations.dart';
import 'package:envoy/business/bluetooth_manager.dart';
import 'package:envoy/generated/l10n.dart';
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
import 'package:foundation_api/foundation_api.dart';
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
    fwDownloadNotifier.updateStep(
        S().firmware_updatingDownload_downloading, EnvoyStepState.LOADING);
    fwProgressNotifier.state = .4;
    await Future.delayed(const Duration(seconds: 2));
    fwProgressNotifier.state = .8;
    await Future.delayed(const Duration(seconds: 2));
    fwProgressNotifier.state = 1.0;
    await Future.delayed(const Duration(seconds: 2));
    fwDownloadNotifier.updateStep(
        S().firmware_downloadingUpdate_downloaded, EnvoyStepState.FINISHED);

    primeUpdateNotifier.state = PrimeFwUpdateStep.transferring;
    fwProgressNotifier.state = 0.0;
    fwTransferStateNotifier.updateStep(
        S().firmware_downloadingUpdate_transferring, EnvoyStepState.LOADING);
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
    _progressAnimationController?.findInput<bool>("happy")?.change(true);
    return Column(
      children: [
        Text(
          //TODO: Note to devs: {0} in firmware.updateSuccess.content1 should be programmatically replaced by the new keyOS version installed
          S().firmware_updateSuccess_content1,
          textAlign: TextAlign.center,
          style: EnvoyTypography.explainer.copyWith(fontSize: 14),
        ),
        const Padding(padding: EdgeInsets.all(EnvoySpacing.small)),
        Padding(
          padding: const EdgeInsets.all(EnvoySpacing.small),
          child: Text(
            S().firmware_updateSuccess_content2,
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
          //TODO: Note: {0} in firmware.updateAvailable.estimatedUpdateTime should be programmatically replaced by the estimated update time rounded to minutes
          S().firmware_updateAvailable_estimatedUpdateTime,
          textAlign: TextAlign.center,
          style: EnvoyTypography.explainer.copyWith(fontSize: 14),
        ),
        const Padding(padding: EdgeInsets.all(EnvoySpacing.small)),
        Padding(
          padding: const EdgeInsets.all(EnvoySpacing.small),
          child: Text(
            // TODO: Note to devs: {0} in firmware.updateAvailable.whatsNew should be programmatically replaced by the new keyOS version found
            S().firmware_updateAvailable_content2,
            textAlign: TextAlign.center,
            style: EnvoyTypography.explainer.copyWith(fontSize: 14),
          ),
        ),
        // Expanded(
        //     child: Container(
        //   width: double.infinity,
        //   padding: const EdgeInsets.symmetric(vertical: EnvoySpacing.small)
        //       .add(const EdgeInsets.only(
        //     top: EnvoySpacing.medium2,
        //   )),
        //   child: const Placeholder(),
        // )),
        // OnboardingButton(
        //     label: "Try to send",
        //     type: EnvoyButtonTypes.primary,
        //     fontWeight: FontWeight.w600,
        //     onTap: (){
        //       BluetoothManager().sendOnboardingState(OnboardingState.receivingUpdate);
        //     }),
      ],
    );
  }

  String _getTitle(BuildContext context) {
    final primeUpdateState = ref.watch(primeUpdateStateProvider);
    //TODO: copy update
    return switch (primeUpdateState) {
      PrimeFwUpdateStep.idle => S().firmware_updateAvailable_header,
      PrimeFwUpdateStep.downloading =>
        S().firmware_updatingDownload_downloading,
      PrimeFwUpdateStep.transferring ||
      PrimeFwUpdateStep.verifying ||
      PrimeFwUpdateStep.installing ||
      PrimeFwUpdateStep.rebooting =>
        S().firmware_updatingDownload_header,
      PrimeFwUpdateStep.finished => S().firmware_updateSuccess_header,
      PrimeFwUpdateStep.error => S().firmware_updateError_header,
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
            S().firmware_updatingDownload_content,
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
                        S().firmware_downloadingUpdate_timeRemaining,
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
            S().firmware_updatingDownload_content,
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
              return Text(
                S().firmware_updatingPrime_content2,
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
