// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/pages/scv/scv_result_fail.dart';
import 'package:envoy/ui/pages/scv/scv_result_ok.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:flutter/material.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:rive/rive.dart';
import 'package:envoy/business/scv_server.dart';
import 'package:envoy/business/uniform_resource.dart';
import 'package:envoy/business/updates_manager.dart';

class ScvLoadingPage extends StatefulWidget {
  final Object scvData;
  final Challenge challengeToValidate;

  const ScvLoadingPage(this.scvData, this.challengeToValidate, {super.key});

  @override
  State<ScvLoadingPage> createState() => _ScvLoadingPageState();
}

class _ScvLoadingPageState extends State<ScvLoadingPage> {
  @override
  initState() {
    super.initState();
    _validateScvData(widget.scvData);
  }

  _validateScvData(Object? object) {
    if (object is CryptoResponse) {
      ScvChallengeResponse scvResponse =
          object.objects[0] as ScvChallengeResponse;

      ScvServer()
          .validate(widget.challengeToValidate, scvResponse.responseWords)
          .then((validated) {
        if (validated) {
          bool mustUpdateFirmware = true;

          if (object.objects.length > 2) {
            PassportModel model = object.objects[1] as PassportModel;
            PassportFirmwareVersion version =
                object.objects[2] as PassportFirmwareVersion;

            UpdatesManager()
                .shouldUpdate(version.version, model.type)
                .then((bool shouldUpdate) {
              mustUpdateFirmware = shouldUpdate;
            });
          }

          if (!context.mounted) return;

          // ignore: use_build_context_synchronously
          Navigator.of(context)
              .pushReplacement(MaterialPageRoute(builder: (context) {
            return ScvResultOkPage(mustUpdateFirmware: mustUpdateFirmware);
          }));
        } else {
          // ignore: use_build_context_synchronously
          Navigator.of(context)
              .pushReplacement(MaterialPageRoute(builder: (context) {
            return const ScvResultFailPage();
          }));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingPage(
      key: const Key("scv_loading"),
      rightFunction: null,
      leftFunction: null,
      text: [
        OnboardingText(
          header: S().scv_checkingDeviceSecurity,
        ),
      ],
      clipArt: Padding(
        padding: const EdgeInsets.only(top: EnvoySpacing.xl),
        child: SizedBox(
          width: 300,
          height: 300,
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
      ),
    );
  }
}
