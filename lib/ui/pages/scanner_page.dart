// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

// ignore_for_file: use_key_in_widget_constructors

import 'dart:async';
import 'dart:io';
import 'package:envoy/business/account_manager.dart';
import 'package:envoy/business/azteco_voucher.dart';
import 'package:envoy/business/bip21.dart';
import 'package:envoy/business/btcpay_voucher.dart';
import 'package:envoy/business/updates_manager.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/home/cards/accounts/btcPay/btcpay_dialog.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/ui/pages/scv/scv_result_fail.dart';
import 'package:envoy/ui/pages/scv/scv_result_ok.dart';
import 'package:envoy/ui/pages/wallet/single_wallet_pair_success.dart';
import 'package:envoy/util/console.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:envoy/business/uniform_resource.dart';
import 'package:envoy/business/scv_server.dart';
import 'package:envoy/ui/home/cards/accounts/azteco/azteco_dialog.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:envoy/business/account.dart';
import 'package:wallet/wallet.dart';

enum ScannerType {
  generic,
  scv,
  pair,
  validate,
  address,
  tx,
  nodeUrl,
  seed,
  azteco,
  btcPay,
}

const SnackBar invalidAddressSnackbar = SnackBar(
  content: Text("Not a valid address"), // TODO: FIGMA
);

const SnackBar invalidSeedSnackbar = SnackBar(
  content: Text("Not a valid seed"), // TODO: FIGMA
);

class ScannerPage extends StatefulWidget {
  final UniformResourceReader _urDecoder = UniformResourceReader();
  final List<ScannerType> _acceptableTypes;

  final Account? account;
  final Challenge? challengeToValidate;
  final Function(String)? onTxParsed;
  final Function(String)? onSeedValidated;
  final Function(String)? onNodeUrlParsed;
  final Function(String, int)? onAddressValidated;

  ScannerPage(this._acceptableTypes,
      {super.key,
      this.account,
      this.challengeToValidate,
      this.onTxParsed,
      this.onSeedValidated,
      this.onNodeUrlParsed,
      this.onAddressValidated});

  ScannerPage.address(Function(String, int) onAddressValidated, Account account)
      : this([ScannerType.address],
            onAddressValidated: onAddressValidated, account: account);

  ScannerPage.tx(Function(String) onTxParsed)
      : this([ScannerType.tx], onTxParsed: onTxParsed);

  ScannerPage.nodeUrl(Function(String) onNodeUrlParsed)
      : this([ScannerType.nodeUrl], onNodeUrlParsed: onNodeUrlParsed);

  ScannerPage.validate(Account account)
      : this([ScannerType.validate], account: account);

  ScannerPage.scv(Challenge challengeToValidate)
      : this([ScannerType.scv], challengeToValidate: challengeToValidate);

  //TODO: fix scanner widget with proper widget convention
  @override
  // ignore: no_logic_in_create_state
  State<StatefulWidget> createState() => ScannerPageState(_urDecoder);
}

class ScannerPageState extends State<ScannerPage> {
  late UniformResourceReader _urDecoder;
  bool _processing = false;

  double _progress = 0.0;

  final Completer<void> _permissionsCompleter = Completer();
  late Future<void> _permissionsGranted;

  QRViewController? controller;
  final GlobalKey qrViewKey = GlobalKey(debugLabel: "qr_view");

  String _lastCodeDetected = "";

  Timer? _snackbarTimer;

  ScannerPageState(UniformResourceReader urDecoder) {
    _urDecoder = urDecoder;
  }

  @override
  void initState() {
    super.initState();

    _permissionsGranted = _permissionsCompleter.future;
    if (Platform.isAndroid || Platform.isIOS) {
      Permission.camera.status.then((status) {
        if (status.isDenied) {
          Permission.camera.request().then((status) {
            if (status.isPermanentlyDenied) {
              openAppSettings();
            }
            _permissionsCompleter.complete();
          });
        } else if (status.isPermanentlyDenied) {
          openAppSettings();
          _permissionsCompleter.complete();
        } else {
          _permissionsCompleter.complete();
        }
      });
    } else {
      _permissionsCompleter.complete();
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    _snackbarTimer?.cancel();
    super.dispose();
  }

  // Fix hot reload
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    }
    controller?.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
          // Get rid of the shadow
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: IconButton(
              icon: const Icon(
                Icons.close_rounded,
                size: 25,
                color: Colors.white54,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              })),
      body: _buildQrView(context),
    );
  }

  void _onQRViewCreated(QRViewController controller, BuildContext context) {
    this.controller = controller;
    controller.scannedDataStream.listen((barcode) {
      if (barcode.code != null && barcode.code != _lastCodeDetected) {
        _lastCodeDetected = barcode.code!;
        _onDetect(barcode.code!, context);
      }
    });

    // ENV-252: hack to get camera on CalyxOS
    if (Platform.isAndroid) {
      controller.pauseCamera();
      controller.resumeCamera();
    }
  }

  Widget _buildQrView(BuildContext context) {
    return Stack(
      children: [
        FutureBuilder(
            future: _permissionsGranted,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return QRView(
                  key: qrViewKey,
                  onQRViewCreated: (controller) =>
                      _onQRViewCreated(controller, context),
                );
              } else {
                return const SizedBox.shrink();
              }
            }),
        const ViewFinder(),
        Center(
            child: SizedBox(
                height: 200,
                width: 200,
                child: TweenAnimationBuilder(
                    duration: const Duration(milliseconds: 500),
                    tween: Tween<double>(
                      begin: 0.00,
                      end: _progress,
                    ),
                    builder:
                        (BuildContext context, double? value, Widget? child) {
                      return CircularProgressIndicator(
                        value: value,
                        color: EnvoyColors.white80,
                        strokeWidth: 5,
                      );
                    })))
      ],
    );
  }

  _onDetect(String code, BuildContext context) async {
    final NavigatorState navigator = Navigator.of(context);
    final scaffold = ScaffoldMessenger.of(context);
    if (widget._acceptableTypes.contains(ScannerType.azteco)) {
      if (AztecoVoucher.isVoucher(code)) {
        final voucher = AztecoVoucher(code);
        navigator.pop();
        showEnvoyDialog(
            context: context, dialog: AztecoDialog(voucher, widget.account!));
        return;
      }
    }
    if (widget._acceptableTypes.contains(ScannerType.btcPay)) {
      if (BtcPayVoucher.isVoucher(code)) {
        final voucher = BtcPayVoucher(code);
        Navigator.of(context).pop();
        showEnvoyDialog(
            context: context, dialog: BtcPayDialog(voucher, widget.account!));
        return;
      }
    }

    // Seed recovery flow
    if (widget._acceptableTypes.contains(ScannerType.seed)) {
      code = extractSeedFromQRCode(code);
      final seedLength = code.split(" ").length;
      // TODO: account for passphrases (when we reenable that feature)
      if ((seedLength == 12 || seedLength == 24) && Wallet.validateSeed(code)) {
        widget.onSeedValidated!(code);
        navigator.pop();
        return;
      }
      showSnackbar(invalidSeedSnackbar);
      return;
    }

    if (widget._acceptableTypes.contains(ScannerType.address)) {
      String address = code;
      int amount = 0;

      // Try to decode with BIP21
      try {
        var bip21 = Bip21.decode(address);

        address = bip21.address;

        // BIP-21 amounts are in BTC
        amount = (bip21.amount * 100000000.0).toInt();
      } catch (e, s) {
        kPrint(e);
        debugPrintStack(stackTrace: s);
        // TODO
      }

      // Remove bitcoin: prefix in case BIP-21 parsing failed
      address = address.replaceFirst("bitcoin:", "");

      if (!await widget.account!.wallet.validateAddress(address)) {
        showSnackbar(invalidAddressSnackbar);
      } else {
        widget.onAddressValidated!(address, amount);
        navigator.pop();
        return;
      }
    }

    String scannedData = code.toLowerCase();

    if (widget._acceptableTypes.contains(ScannerType.nodeUrl)) {
      widget.onNodeUrlParsed!(scannedData);
      navigator.pop();
      return;
    }

    _urDecoder.receive(scannedData);
    setState(() {
      _progress = _urDecoder.urDecoder.progress;
    });

    if (_urDecoder.decoded != null && !_processing) {
      _processing = true;
      if (widget._acceptableTypes.contains(ScannerType.scv)) {
        _validateScvData(_urDecoder.decoded);
      } else if (widget._acceptableTypes.contains(ScannerType.tx)) {
        await widget.onTxParsed!((_urDecoder.decoded as CryptoPsbt).decoded);

        ///popping this page
        navigator.pop();
      } else if (widget._acceptableTypes.contains(ScannerType.pair)) {
        if (_validatePairData(_urDecoder.decoded) &&
            _urDecoder.decoded is Binary) {
          _binaryValidated(_urDecoder.decoded as Binary);
        } else {
          // Tell the user to use testnet
          scaffold.showSnackBar(const SnackBar(
            content: Text("Please use Testnet"), // TODO: FIGMA
          ));
        }
      }
    }
  }

  void showSnackbar(SnackBar snackBar) {
    if ((_snackbarTimer == null || !_snackbarTimer!.isActive) &&
        _progress == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      _snackbarTimer = Timer(const Duration(seconds: 5), () {});
    }
  }

  _validateScvData(Object? object) {
    if (object is CryptoResponse) {
      ScvChallengeResponse scvResponse =
          object.objects[0] as ScvChallengeResponse;

      ScvServer()
          .validate(widget.challengeToValidate!, scvResponse.responseWords)
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

          Navigator.of(context)
              .pushReplacement(MaterialPageRoute(builder: (context) {
            return ScvResultOkPage(mustUpdateFirmware: mustUpdateFirmware);
          }));
        } else {
          Navigator.of(context)
              .pushReplacement(MaterialPageRoute(builder: (context) {
            return const ScvResultFailPage();
          }));
        }
      });
    }
  }

  bool _validatePairData(Object? object) {
    if (object is Binary) {
      return true;
    }

    if (object is CryptoRequest) {
      var hdkey = ((object).objects[1]) as CryptoHdKey;
      if (hdkey.network! == HdKeyNetwork.testnet) {
        return true;
      }
    }
    return false;
  }

  void _binaryValidated(Binary binary) async {
    final navigator = Navigator.of(context);
    final scaffold = ScaffoldMessenger.of(context);
    Account? pairedAccount;
    try {
      pairedAccount = await AccountManager().addPassportAccounts(binary);
    } on AccountAlreadyPaired catch (_) {
      scaffold.showSnackBar(const SnackBar(
        content: Text("Account already connected"), // TODO: FIGMA
      ));
      return;
    }

    if (pairedAccount == null) {
      if (mounted) {
        OnboardingPage.popUntilHome(context);
      }
    } else {
      navigator.pushReplacement(MaterialPageRoute(builder: (context) {
        return SingleWalletPairSuccessPage(pairedAccount!.wallet);
      }));
    }
  }
}

class ViewFinder extends StatelessWidget {
  const ViewFinder({super.key});

  @override
  Widget build(BuildContext context) {
    final stroke = Padding(
        padding: const EdgeInsets.all(65),
        child: SvgPicture.asset("assets/viewfinder_stroke.svg"));
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          stroke,
          RotatedBox(
            quarterTurns: 1,
            child: stroke,
          )
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RotatedBox(
            quarterTurns: 3,
            child: stroke,
          ),
          RotatedBox(
            quarterTurns: 2,
            child: stroke,
          )
        ],
      ),
    ]);
  }
}

String extractSeedFromQRCode(String code) {
  // Split the code based on various delimiters
  final seedList = code.split(RegExp(r'\s+|,|/'));

  // Join the separated words to form a single seed string
  final parsedSeed = seedList.join(" ");

  // Remove consecutive white spaces
  final cleanedSeed = parsedSeed.replaceAll(RegExp(r'\s+'), ' ');

  return cleanedSeed;
}
