// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';

import 'package:envoy/business/settings.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/components/text_field.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/widgets/scanner/decoders/generic_qr_decoder.dart';
import 'package:envoy/ui/widgets/scanner/qr_scanner.dart';
import 'package:envoy/util/bug_report_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http_tor/http_tor.dart';

enum BlockExplorerEntryState { pending, valid, invalid }

// First non-coinbase Bitcoin transaction (block 170, Satoshi → Hal Finney) —
// indexed by every real block explorer. Used to probe `<url>/tx/<txid>`
// during validation.
const String _knownMainnetTxId =
    'f4184fc596403b9d638783cf57adfe4c75c605f6356fbc91338530e9831e9e16';

class BlockExplorerEntry extends ConsumerStatefulWidget {
  final String Function() getter;
  final Function(String) setter;

  const BlockExplorerEntry(this.getter, this.setter, {super.key});

  @override
  ConsumerState<BlockExplorerEntry> createState() => _BlockExplorerEntryState();
}

class _BlockExplorerEntryState extends ConsumerState<BlockExplorerEntry> {
  final TextEditingController _controller = TextEditingController();
  var _state = BlockExplorerEntryState.valid;
  String _textBelow = S().privacy_explorer_configure;
  bool _isError = false;
  Timer? _typingTimer;

  @override
  void initState() {
    super.initState();
    _controller.text = widget.getter();

    if (_controller.text.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkExplorer(_controller.text);
      });
    }
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    super.dispose();
  }

  void _onChange(String address) {
    widget.setter(address);

    if (address.isEmpty) {
      setState(() {
        _state = BlockExplorerEntryState.valid;
        _isError = false;
        _textBelow = S().privacy_explorer_configure;
      });
    }

    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 2), () {
      if (address.isNotEmpty) {
        _checkExplorer(address);
      }
    });
  }

  Future<void> _checkExplorer(String address) async {
    final uri = Uri.tryParse(address);
    if (uri == null ||
        (uri.scheme != 'http' && uri.scheme != 'https') ||
        uri.host.isEmpty) {
      if (mounted) {
        setState(() {
          _state = BlockExplorerEntryState.invalid;
          _isError = true;
          _textBelow =
              "URL must start with http:// or https://."; // TODO: localazy
        });
      }
      return;
    }

    setState(() {
      _state = BlockExplorerEntryState.pending;
    });

    try {
      final response = await HttpTor().get(
        '$address/tx/$_knownMainnetTxId',
      );
      // 200 = normal success.
      // 403 / 503 = server is alive and responding, but a WAF (often
      // Cloudflare over Tor) is blocking automated probes. We still treat
      // the host as reachable rather than penalising the user's URL.
      const reachableStatuses = {200, 403, 503};
      if (reachableStatuses.contains(response.statusCode)) {
        if (mounted) {
          setState(() {
            _state = BlockExplorerEntryState.valid;
            _isError = false;
            _textBelow = "Connected to block explorer."; // TODO: localazy
          });
        }
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      EnvoyReport().log("BlockExplorer", e.toString());
      if (mounted) {
        setState(() {
          _state = BlockExplorerEntryState.invalid;
          _isError = true;
          _textBelow = "Could not reach block explorer."; // TODO: localazy
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<bool>(torEnabledProvider, (prev, next) {
      if (prev != next && _controller.text.isNotEmpty) {
        _checkExplorer(_controller.text);
      }
    });

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(EnvoySpacing.medium1),
          ),
          child: EnvoyTextField(
            controller: _controller,
            onEditingComplete: () {
              FocusScope.of(context).unfocus();
              _onChange(_controller.text);
            },
            isLoading: _state == BlockExplorerEntryState.pending,
            defaultText: S().privacy_explorer_explorerAddress,
            informationalText: _state == BlockExplorerEntryState.valid
                ? _textBelow
                : S().privacy_explorer_configure,
            errorText: _textBelow,
            additionalButtons: true,
            onChanged: (address) {
              _onChange(address);
            },
            isError: _isError,
            onQrScan: () {
              showScannerDialog(
                context: context,
                onBackPressed: (context) {
                  Navigator.pop(context);
                },
                decoder: GenericQrDecoder(
                  onScan: (result) {
                    if (context.mounted) {
                      Navigator.of(context, rootNavigator: true).pop();
                    }
                    _controller.text = result;
                    widget.setter(result);
                    _checkExplorer(result);
                    return result;
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
