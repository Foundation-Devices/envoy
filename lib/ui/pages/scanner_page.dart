// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'dart:io';
import 'package:envoy/business/account_manager.dart';
import 'package:envoy/business/azteco_voucher.dart';
import 'package:envoy/business/bip21.dart';
import 'package:envoy/business/updates_manager.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/pages/scv/scv_result_fail.dart';
import 'package:envoy/ui/pages/scv/scv_result_ok.dart';
import 'package:envoy/ui/pages/wallet/single_wallet_pair_success.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:envoy/business/uniform_resource.dart';
import 'package:envoy/business/scv_server.dart';
import 'package:envoy/ui/home/cards/accounts/azteco/azteco_dialog.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:envoy/business/account.dart';

enum ScannerType {
  generic,
  scv,
  pair,
  validate,
  address,
  tx,
  nodeUrl,
  seed,
  azteco
}

class ScannerPage extends StatefulWidget {
  final UniformResourceReader _urDecoder = UniformResourceReader();
  final List<ScannerType> _acceptableTypes;

  final Account? account;
  final Challenge? challengeToValidate;
  final Function(String)? callback;
  final Function(String, int)? addressCallback;

  ScannerPage(this._acceptableTypes,
      {this.account,
      this.challengeToValidate,
      this.callback,
      this.addressCallback});

  ScannerPage.address(Function(String, int) callback, Account account)
      : this([ScannerType.address],
            addressCallback: callback, account: account);

  ScannerPage.tx(Function(String) callback)
      : this([ScannerType.tx], callback: callback);

  ScannerPage.nodeUrl(Function(String) callback)
      : this([ScannerType.nodeUrl], callback: callback);

  ScannerPage.validate(Account account)
      : this([ScannerType.validate], account: account);

  ScannerPage.scv(Challenge challengeToValidate)
      : this([ScannerType.scv], challengeToValidate: challengeToValidate);

  @override
  State<StatefulWidget> createState() => _ScannerPageState(_urDecoder);
}

class _ScannerPageState extends State<ScannerPage> {
  late UniformResourceReader _urDecoder;
  bool _processing = false;

  bool _showIndeterminateSpinner = false;

  double _progress = 0.0;

  Completer<void> _permissionsCompleter = Completer();
  late Future<void> _permissionsGranted;

  QRViewController? controller;
  final GlobalKey qrViewKey = GlobalKey(debugLabel: "qr_view");

  String _lastCodeDetected = "";

  _ScannerPageState(UniformResourceReader urDecoder) {
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
              icon: Icon(
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

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((barcode) {
      if (barcode.code != null && barcode.code != _lastCodeDetected) {
        _lastCodeDetected = barcode.code!;
        _onDetect(barcode.code!);
      }
    });

    // ENV-252: hack to get camera on CalyxOS
    controller.pauseCamera();
    controller.resumeCamera();
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
                  onQRViewCreated: _onQRViewCreated,
                );
              } else {
                return SizedBox.shrink();
              }
            }),
        ViewFinder(),
        Center(
            child: SizedBox(
                height: 200,
                width: 200,
                child: _showIndeterminateSpinner
                    ? CircularProgressIndicator(
                        color: EnvoyColors.white80,
                        strokeWidth: 5,
                      )
                    : TweenAnimationBuilder(
                        duration: const Duration(milliseconds: 500),
                        tween: Tween<double>(
                          begin: 0.00,
                          end: _progress,
                        ),
                        builder: (BuildContext context, double? value,
                            Widget? child) {
                          return CircularProgressIndicator(
                            value: value,
                            color: EnvoyColors.white80,
                            strokeWidth: 5,
                          );
                        })))
      ],
    );
  }

  _onDetect(String code) async {
    if (widget._acceptableTypes.contains(ScannerType.azteco)) {
      if (AztecoVoucher.isVoucher(code)) {
        final voucher = AztecoVoucher(code);
        Navigator.of(context).pop();
        showEnvoyDialog(
            context: context, dialog: AztecoDialog(voucher, widget.account!));
      }
    }

    // Seed recovery flow
    if (widget._acceptableTypes.contains(ScannerType.seed)) {
      widget.callback!(code);
      Navigator.of(context).pop();
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
        print(e);
        debugPrintStack(stackTrace: s);
        // TODO
      }

      // Remove bitcoin: prefix in case BIP-21 parsing failed
      address = address.replaceFirst("bitcoin:", "");

      if (!await widget.account!.wallet.validateAddress(address)) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Not a valid address"),
        ));
      } else {
        widget.addressCallback!(address, amount);
        Navigator.of(context).pop();
      }
      return;
    }

    String scannedData = code.toLowerCase();

    if (widget._acceptableTypes.contains(ScannerType.nodeUrl)) {
      widget.callback!(scannedData);
      Navigator.of(context).pop();
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
        widget.callback!((_urDecoder.decoded as CryptoPsbt).decoded);
        Navigator.of(context).pop();
      } else if (widget._acceptableTypes.contains(ScannerType.pair)) {
        if (_validatePairData(_urDecoder.decoded) &&
            _urDecoder.decoded is Binary) {
          _binaryValidated(_urDecoder.decoded as Binary);
        } else {
          // Tell the user to use testnet
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Please use Testnet"),
          ));
        }
      }
    }
  }

  _validateScvData(Object? object) {
    if (object is CryptoResponse) {
      ScvChallengeResponse scvResponse =
          object.objects[0] as ScvChallengeResponse;

      setState(() {
        _showIndeterminateSpinner = true;
      });

      ScvServer()
          .validate(widget.challengeToValidate!, scvResponse.responseWords)
          .then((validated) {
        setState(() {
          _showIndeterminateSpinner = false;
        });

        if (validated) {
          bool mustUpdateFirmware = true;

          if (object.objects.length > 2) {
            PassportModel model = object.objects[1] as PassportModel;
            PassportFirmwareVersion version =
                object.objects[2] as PassportFirmwareVersion;
            mustUpdateFirmware =
                UpdatesManager().shouldUpdate(version.version, model.type);
          }

          Navigator.of(context)
              .pushReplacement(MaterialPageRoute(builder: (context) {
            return ScvResultOkPage(mustUpdateFirmware: mustUpdateFirmware);
          }));
        } else {
          Navigator.of(context)
              .pushReplacement(MaterialPageRoute(builder: (context) {
            return ScvResultFailPage();
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

  void _binaryValidated(Binary binary) {
    AccountManager().addEnvoyAccountFromJson(binary).catchError((_) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Account already connected"),
      ));
      return null;
    }, test: (e) => e is AccountAlreadyPaired).then((account) {
      if (account == null) {
        Navigator.of(context).popUntil(ModalRoute.withName("/"));
      } else {
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (context) {
          return SingleWalletPairSuccessPage(account.wallet);
        }));
      }
    });
  }
}

class ViewFinder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final stroke = Padding(
        padding: EdgeInsets.all(65),
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
