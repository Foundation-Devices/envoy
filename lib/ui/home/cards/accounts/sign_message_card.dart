// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/account/accounts_manager.dart';
import 'package:envoy/business/envoy_seed.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/home/cards/accounts/qr_tab.dart';
import 'package:envoy/ui/home/home_state.dart';
import 'package:envoy/ui/routes/accounts_router.dart';
import 'package:envoy/ui/state/accounts_state.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/widgets/toast/envoy_toast.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/ui/theme/new_envoy_color.dart';
import 'package:envoy/ui/widgets/envoy_qr_widget.dart';
import 'package:envoy/ui/widgets/scanner/decoders/generic_qr_decoder.dart';
import 'package:envoy/ui/widgets/scanner/qr_scanner.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ngwallet/ngwallet.dart';
import 'package:share_plus/share_plus.dart';
import 'package:envoy/ui/components/checkbox.dart';
import 'package:envoy/ui/home/cards/accounts/address_explorer_card.dart';

/// Data passed to the result page via route extra
class SignMessageResultData {
  final String address;
  final String signature;
  final String formattedResult;
  final String message;
  final String accountId;

  const SignMessageResultData({
    required this.address,
    required this.signature,
    required this.formattedResult,
    required this.message,
    required this.accountId,
  });
}

enum _InputPageState { input, qr }

class SignMessageCard extends ConsumerStatefulWidget {
  final EnvoyAccount account;

  SignMessageCard(this.account) : super(key: UniqueKey());

  @override
  ConsumerState<SignMessageCard> createState() => _SignMessageCardState();
}

class _SignMessageCardState extends ConsumerState<SignMessageCard> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  _InputPageState _pageState = _InputPageState.input;

  // Address resolution
  String? _resolvedDerivationPath;
  String? _addressWarning;
  bool _isResolvingAddress = false;

  // Signing
  bool _signing = false;

  // QR state (cold wallet)
  String? _qrData;
  bool _scannedByPassport = false;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 10)).then((_) {
      ref.read(homeShellOptionsProvider.notifier).state = null;
    });
  }

  @override
  void dispose() {
    _addressController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  // --- Address Resolution ---

  String _getPurpose(AddressType addressType) {
    switch (addressType) {
      case AddressType.p2Pkh:
        return "44'";
      case AddressType.p2Sh:
        return "45'";
      case AddressType.p2Wpkh:
        return "84'";
      case AddressType.p2Wsh:
        return "48'";
      case AddressType.p2Tr:
        return "86'";
      case AddressType.p2ShWpkh:
        return "49'";
      case AddressType.p2ShWsh:
        return "48'";
    }
  }

  String _buildDerivationPath(int index, bool isChange) {
    final account =
        ref.read(accountStateProvider(widget.account.id)) ?? widget.account;
    final addressType = account.preferredAddressType;
    final purpose = _getPurpose(addressType);
    final coinType = account.network == Network.bitcoin ? "0'" : "1'";
    final changeIndex = isChange ? 1 : 0;
    return "m/$purpose/$coinType/0'/$changeIndex/$index";
  }

  Future<void> _resolveAddress(String address) async {
    if (address.isEmpty) {
      setState(() {
        _resolvedDerivationPath = null;
        _addressWarning = null;
      });
      return;
    }

    final handler = widget.account.handler;
    if (handler == null) {
      setState(() {
        _addressWarning = "Account handler not available";
        _resolvedDerivationPath = null;
      });
      return;
    }

    setState(() {
      _isResolvingAddress = true;
      _addressWarning = null;
      _resolvedDerivationPath = null;
    });

    final account =
        ref.read(accountStateProvider(widget.account.id)) ?? widget.account;
    final addressType = account.preferredAddressType;

    // Search receive addresses first (batches of 50, up to 200)
    for (int batchEnd = 50; batchEnd <= 200; batchEnd += 50) {
      try {
        final peeked = await handler.peekAddresses(
          addressType: addressType,
          fromIndex: 0,
          toIndex: batchEnd,
          isChange: false,
        );
        final match = peeked.where((t) => t.$2 == address).firstOrNull;
        if (match != null) {
          setState(() {
            _resolvedDerivationPath = _buildDerivationPath(match.$1, false);
            _addressWarning = null;
            _isResolvingAddress = false;
          });
          return;
        }
      } catch (_) {
        break;
      }
    }

    // Search change addresses (batches of 50, up to 200)
    for (int batchEnd = 50; batchEnd <= 200; batchEnd += 50) {
      try {
        final peeked = await handler.peekAddresses(
          addressType: addressType,
          fromIndex: 0,
          toIndex: batchEnd,
          isChange: true,
        );
        final match = peeked.where((t) => t.$2 == address).firstOrNull;
        if (match != null) {
          setState(() {
            _resolvedDerivationPath = _buildDerivationPath(match.$1, true);
            _addressWarning = null;
            _isResolvingAddress = false;
          });
          return;
        }
      } catch (_) {
        break;
      }
    }

    setState(() {
      _addressWarning = S().signMessage_main_addressDoesNotBelong;
      _resolvedDerivationPath = null;
      _isResolvingAddress = false;
    });
  }

  // --- Navigation to result ---

  void _navigateToResult(SignMessageResultData data) {
    context.go(ROUTE_ACCOUNT_SIGN_MESSAGE_RESULT, extra: data);
  }

  // --- Hot Wallet Sign ---

  Future<void> _signHot() async {
    final message = _messageController.text.trim();
    final address = _addressController.text.trim();
    if (message.isEmpty || address.isEmpty) return;
    if (_resolvedDerivationPath == null) return;

    setState(() {
      _signing = true;
    });

    try {
      final seed = await EnvoySeed().get();
      if (seed == null) {
        setState(() {
          _signing = false;
        });
        return;
      }

      final signed = await EnvoySignMessage.signMessage(
        seedWords: seed,
        derivationPath: _resolvedDerivationPath!,
        message: message,
        network: widget.account.network,
      );

      final formatted =
          await EnvoySignMessage.formatSignedMessage(signed: signed);

      setState(() {
        _signing = false;
      });

      _navigateToResult(SignMessageResultData(
        address: signed.address,
        signature: signed.signature,
        formattedResult: formatted,
        message: message,
        accountId: widget.account.id,
      ));
    } catch (e) {
      setState(() {
        _signing = false;
      });
    }
  }

  // --- Cold Wallet Flow ---

  void _signCold() {
    final message = _messageController.text.trim();
    if (message.isEmpty || _resolvedDerivationPath == null) return;

    setState(() {
      _qrData = "signmessage $_resolvedDerivationPath ascii:$message";
      _pageState = _InputPageState.qr;
    });
  }

  void _scanSignature() {
    showScannerDialog(
      context: context,
      onBackPressed: (context) {
        Navigator.of(context).pop();
      },
      decoder: GenericQrDecoder(
        onScan: (code) {
          Navigator.of(context, rootNavigator: true).pop();
          _onSignatureScanned(code);
        },
      ),
    );
  }

  Future<void> _onSignatureScanned(String signature) async {
    final address = _addressController.text.trim();
    final message = _messageController.text.trim();

    final signed = SignedMessage(
      message: message,
      address: address,
      signature: signature.trim(),
    );

    final formatted =
        await EnvoySignMessage.formatSignedMessage(signed: signed);

    _navigateToResult(SignMessageResultData(
      address: address,
      signature: signature.trim(),
      formattedResult: formatted,
      message: message,
      accountId: widget.account.id,
    ));
  }

  // --- Build ---

  @override
  Widget build(BuildContext context) {
    switch (_pageState) {
      case _InputPageState.input:
        return _buildInputView();
      case _InputPageState.qr:
        return _buildQrView();
    }
  }

  Widget _buildInputView() {
    final isHot = widget.account.isHot;
    final canSign = _addressController.text.trim().isNotEmpty &&
        _messageController.text.trim().isNotEmpty &&
        _resolvedDerivationPath != null &&
        !_isResolvingAddress;

    return Padding(
      padding: const EdgeInsets.only(top: EnvoySpacing.medium2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: EnvoySpacing.medium1,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AddressSearchEntry(
                    controller: _addressController,
                    icon: EnvoyIcons.list,
                    onChanged: (value) {
                      setState(() {});
                      _resolveAddress(value.trim());
                    },
                  ),

                  if (_addressWarning != null) ...[
                    const SizedBox(height: EnvoySpacing.small),
                    Center(
                      child: Text(
                        _addressWarning!,
                        style: EnvoyTypography.body.copyWith(
                          color: EnvoyColors.accentSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],

                  const SizedBox(height: EnvoySpacing.medium2),

                  // Message field
                  Center(
                    child: Text(
                      S().signMessage_main_messageHeader,
                      style: EnvoyTypography.subheading
                          .copyWith(
                            color: EnvoyColors.textPrimary,
                          )
                          .setWeight(FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: EnvoySpacing.small),
                  Container(
                    decoration: BoxDecoration(
                      color: EnvoyColors.surface3,
                      borderRadius: BorderRadius.circular(EnvoySpacing.medium1),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: EnvoySpacing.small),
                      child: TextField(
                          controller: _messageController,
                          maxLines: 10,
                          textInputAction: TextInputAction.done,
                          onChanged: (_) => setState(() {}),
                          style: EnvoyTypography.body,
                          cursorColor: EnvoyColors.accentPrimary,
                          decoration: InputDecoration(
                            hint: Text(
                              S().signMessage_main_enterPasteMessage,
                              style: EnvoyTypography.body.copyWith(
                                color: NewEnvoyColor.contentSecondary,
                              ),
                            ),
                            //,
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            focusedErrorBorder: InputBorder.none,
                          )),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Sign buttons
          if (isHot)
            Padding(
              padding: const EdgeInsets.only(
                  bottom: EnvoySpacing.large2,
                  left: EnvoySpacing.medium1,
                  right: EnvoySpacing.medium1),
              child: SizedBox(
                width: double.infinity,
                child: EnvoyButton(
                  S().receive_qr_signMessage,
                  enabled: canSign,
                  onTap: canSign && !_signing ? _signHot : null,
                  type: EnvoyButtonTypes.primary,
                ),
              ),
            ),
          if (!isHot)
            Padding(
              padding: const EdgeInsets.only(
                  bottom: EnvoySpacing.large2,
                  left: EnvoySpacing.medium1,
                  right: EnvoySpacing.medium1),
              child: SizedBox(
                width: double.infinity,
                child: EnvoyButton(
                  S().coincontrol_txDetail_cta1_passport,
                  onTap: canSign ? _signCold : null,
                  enabled: canSign,
                  type: EnvoyButtonTypes.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQrView() {
    return Padding(
      padding: const EdgeInsets.only(top: EnvoySpacing.medium2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: EnvoySpacing.medium1,
              ),
              child: Column(
                children: [
                  QrTab(
                    title: S().signMessage_qr_header,
                    subtitle: S().signMessage_qr_subheader,
                    account: widget.account,
                    qr: EnvoyQR(data: _qrData!),
                  ),
                  const SizedBox(height: EnvoySpacing.medium2),
                  DialogCheckBox(
                    label: S().signMessage_qr_scannedSignedByPassport,
                    labelTextStyle: EnvoyTypography.body.copyWith(
                      color: EnvoyColors.textPrimary,
                    ),
                    isChecked: _scannedByPassport,
                    onChanged: (value) =>
                        setState(() => _scannedByPassport = value ?? false),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: EnvoySpacing.medium1,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: EnvoyButton(
                    S().signMessage_qr_saveToFile,
                    onTap: () {
                      SharePlus.instance.share(
                        ShareParams(text: _qrData!),
                      );
                    },
                    type: EnvoyButtonTypes.secondary,
                    leading: const EnvoyIcon(
                      EnvoyIcons.save,
                      color: EnvoyColors.textSecondary,
                      size: EnvoyIconSize.extraSmall,
                    ),
                  ),
                ),
                const SizedBox(height: EnvoySpacing.medium1),
                SizedBox(
                  width: double.infinity,
                  child: EnvoyButton(
                    S().component_continue,
                    enabled: _scannedByPassport,
                    onTap: _scannedByPassport ? _scanSignature : null,
                    type: EnvoyButtonTypes.primary,
                  ),
                ),
                const SizedBox(height: EnvoySpacing.large2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SignMessageResultCard extends ConsumerStatefulWidget {
  final SignMessageResultData data;

  const SignMessageResultCard({super.key, required this.data});

  @override
  ConsumerState<SignMessageResultCard> createState() =>
      _SignMessageResultCardState();
}

class _SignMessageResultCardState extends ConsumerState<SignMessageResultCard> {
  bool _showQr = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 10)).then((_) {
      ref.read(homeShellOptionsProvider.notifier).state = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    if (_showQr) return _buildQrView(data);
    return _buildResultView(data);
  }

  Widget _buildQrView(SignMessageResultData data) {
    final account = NgAccountManager().getAccountById(data.accountId);
    return Padding(
      padding: const EdgeInsets.only(top: EnvoySpacing.medium2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: EnvoySpacing.medium1,
              ),
              child: Column(
                children: [
                  if (account != null)
                    QrTab(
                      title: S().signMessage_mainSignedQr_scanQr,
                      subtitle: S().signMessage_mainSignedQr_scanQrSubheader,
                      account: account,
                      qr: EnvoyQR(data: data.signature),
                    )
                  else
                    EnvoyQR(data: data.signature),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: EnvoySpacing.medium1,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: EnvoyButton(
                    S().component_back,
                    onTap: () => setState(() => _showQr = false),
                    type: EnvoyButtonTypes.primary,
                  ),
                ),
                const SizedBox(height: EnvoySpacing.large2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultView(SignMessageResultData data) {
    return Padding(
      padding: const EdgeInsets.only(top: EnvoySpacing.medium2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: EnvoySpacing.medium1,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Address in grey rounded container
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: EnvoySpacing.medium1,
                      vertical: EnvoySpacing.small,
                    ),
                    decoration: BoxDecoration(
                      color: EnvoyColors.surface3,
                      borderRadius: BorderRadius.circular(EnvoySpacing.medium2),
                    ),
                    child: Text(
                      data.address,
                      style: EnvoyTypography.body.copyWith(
                        color: EnvoyColors.textTertiary,
                      ),
                    ),
                  ),
                  const SizedBox(height: EnvoySpacing.medium2),

                  Text(
                    S().signMessage_main_messageHeader,
                    style:
                        EnvoyTypography.subheading.setWeight(FontWeight.w500),
                  ),
                  const SizedBox(height: EnvoySpacing.small),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: EnvoySpacing.medium1,
                      vertical: EnvoySpacing.medium1,
                    ),
                    decoration: BoxDecoration(
                      color: EnvoyColors.surface3,
                      borderRadius: BorderRadius.circular(EnvoySpacing.medium2),
                    ),
                    child: Text(
                      data.message,
                      style: EnvoyTypography.body.copyWith(
                        color: EnvoyColors.textTertiary,
                      ),
                    ),
                  ),
                  const SizedBox(height: EnvoySpacing.medium2),

                  Text(
                    S().signMessage_main_signatureHeader,
                    style:
                        EnvoyTypography.subheading.setWeight(FontWeight.w500),
                  ),
                  const SizedBox(height: EnvoySpacing.small),

                  // Signature in bordered container
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(EnvoySpacing.medium1),
                    decoration: BoxDecoration(
                      color: EnvoyColors.surface3,
                      borderRadius: BorderRadius.circular(EnvoySpacing.medium2),
                    ),
                    child: SelectableText(
                      data.signature,
                      style: EnvoyTypography.body.copyWith(
                        color: EnvoyColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: EnvoySpacing.small),

                  // Action buttons
                ],
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: EnvoySpacing.medium1),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: EnvoyButton(
                    "Show Signature as QR", // TODO: localize
                    onTap: () => setState(() => _showQr = true),
                    type: EnvoyButtonTypes.secondary,
                    leading: const EnvoyIcon(
                      EnvoyIcons.scan,
                      color: EnvoyColors.textSecondary,
                      size: EnvoyIconSize.extraSmall,
                    ),
                  ),
                ),
                const SizedBox(height: EnvoySpacing.medium1),
                SizedBox(
                  width: double.infinity,
                  child: EnvoyButton(
                    S().signMessage_mainSigned_copySignature,
                    onTap: () {
                      Clipboard.setData(
                        ClipboardData(text: data.signature),
                      );
                      EnvoyToast(
                        backgroundColor: Colors.lightBlue,
                        replaceExisting: true,
                        duration: const Duration(seconds: 1),
                        message:
                            "Signature copied to clipboard", // TODO: localazy
                        icon: const EnvoyIcon(
                          EnvoyIcons.info,
                          color: EnvoyColors.accentPrimary,
                        ),
                      ).show(context, rootNavigator: true);
                    },
                    type: EnvoyButtonTypes.secondary,
                    leading: const EnvoyIcon(
                      EnvoyIcons.copy,
                      color: EnvoyColors.textSecondary,
                      size: EnvoyIconSize.extraSmall,
                    ),
                  ),
                ),
                const SizedBox(height: EnvoySpacing.medium1),
                SizedBox(
                  width: double.infinity,
                  child: EnvoyButton(
                    S().signMessage_mainSigned_saveSignatureToFile,
                    onTap: () {
                      SharePlus.instance.share(
                        ShareParams(text: data.formattedResult),
                      );
                    },
                    type: EnvoyButtonTypes.secondary,
                    leading: const EnvoyIcon(
                      EnvoyIcons.save,
                      color: EnvoyColors.textSecondary,
                      size: EnvoyIconSize.extraSmall,
                    ),
                  ),
                ),
                const SizedBox(height: EnvoySpacing.medium1),

                // Done button
                SizedBox(
                  width: double.infinity,
                  child: EnvoyButton(
                    S().component_done,
                    onTap: () => context.go(ROUTE_ACCOUNT_DETAIL),
                    type: EnvoyButtonTypes.primary,
                  ),
                ),
                const SizedBox(height: EnvoySpacing.large2),
              ],
            ),
          )
        ],
      ),
    );
  }
}
