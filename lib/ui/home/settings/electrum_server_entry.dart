// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http_tor/http_tor.dart';
import 'package:tor/tor.dart';
import 'package:wallet/wallet.dart';
import 'package:wallet/exceptions.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/business/connectivity_manager.dart';
import 'package:envoy/business/node_url.dart';
import 'package:envoy/ui/components/text_field.dart';
import 'package:envoy/ui/pages/scanner_page.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/business/scheduler.dart';

enum ElectrumServerEntryState { pending, valid, invalid }

class ElectrumServerEntry extends ConsumerStatefulWidget {
  final Function(String) setter;
  final String Function() getter;

  const ElectrumServerEntry(this.getter, this.setter, {super.key});

  @override
  ConsumerState<ElectrumServerEntry> createState() =>
      _ElectrumServerEntryState();
}

class _ElectrumServerEntryState extends ConsumerState<ElectrumServerEntry> {
  var _state = ElectrumServerEntryState.valid;
  final TextEditingController _controller = TextEditingController();
  String _textBelow = S().privacy_node_configure;
  Timer? _typingTimer;
  bool _isError = false;
  bool _torEnabled = false;

  @override
  void initState() {
    super.initState();
    _controller.text = widget.getter();
    if (_controller.text.isNotEmpty) {
      _onAddressChanged(_controller.text);
    }
    Future.delayed(Duration.zero).then((value) {
      _updateTorEnabledStatus();
    });
  }

  void _updateTorEnabledStatus() {
    final newTorEnabled = ref.watch(torEnabledProvider);
    if (_torEnabled != newTorEnabled && _controller.text.isNotEmpty) {
      _torEnabled = newTorEnabled;
      _onAddressChanged(_controller.text);
    }
  }

  @override
  void dispose() {
    if (_typingTimer != null) {
      _typingTimer!.cancel();
    }

    super.dispose();
  }

  @override
  void didUpdateWidget(ElectrumServerEntry oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateTorEnabledStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(EnvoySpacing.medium1),
          ),
          child: EnvoyTextField(
            controller: _controller,
            isLoading: _state == ElectrumServerEntryState.pending,
            defaultText: S().privacy_node_nodeAddress,
            informationalText: _state == ElectrumServerEntryState.valid
                ? _textBelow
                : S().privacy_node_configure,
            errorText: _textBelow,
            additionalButtons: true,
            onChanged: (address) {
              widget.setter(address);

              if (address.isEmpty) {
                _state = ElectrumServerEntryState.valid;
                _isError = false;
                _textBelow = S().privacy_node_configure;
              }

              if (_typingTimer != null) {
                _typingTimer!.cancel();
              }

              _typingTimer = Timer(const Duration(seconds: 2), () {
                if (address.isNotEmpty) {
                  _onAddressChanged(parseNodeUrl(address));
                }
              });
            },
            isError: _isError,
            onQrScan: () {
              Navigator.of(context, rootNavigator: true)
                  .push(MaterialPageRoute(builder: (context) {
                return ScannerPage.nodeUrl((result) {
                  var parsedUrl = parseNodeUrl(result);
                  _controller.text = parsedUrl;
                  _onAddressChanged(parsedUrl);
                  return parsedUrl;
                });
              }));
            },
            infoContent: (isPrivateAddress(_controller.text) &&
                    ConnectivityManager().torEnabled)
                ? S().privacy_node_connection_localAddress_warning
                : null,
          ),
        ),
      ],
    );
  }

  void _onAddressChanged(String address) {
    widget.setter(address);

    setState(() {
      _state = ElectrumServerEntryState.pending;
    });

    if (address.startsWith('http')) {
      _checkEsploraServer(address);
    } else {
      _checkElectrumServer(address);
    }
  }

  void _checkElectrumServer(String address, {int retryCount = 0}) {
    bool useTor = !Settings().turnOffTorForThisCase(address);
    int port = useTor ? Tor.instance.port : -1;
    if (useTor && port == -1) {
      if (retryCount <= 3) {
        Future.delayed(const Duration(seconds: 1), () {
          _checkElectrumServer(address, retryCount: retryCount + 1);
        });
      } else {
        // Handle the case where the port is still -1 after retries
        if (mounted) {
          setState(() {
            _state = ElectrumServerEntryState.invalid;
            _isError = true;
            _textBelow = "Tor port is not available."; // TODO: Figma
          });
        }
        ConnectivityManager().electrumFailure();
      }
      return;
    }

    Wallet.getServerFeatures(address, port).then((features) {
      ConnectivityManager().electrumSuccess();
      if (mounted) {
        setState(() {
          _state = ElectrumServerEntryState.valid;
          _isError = false;
          _textBelow =
              "${S().privacy_node_connectedTo} ${features.serverVersion}";
        });
      }
    }, onError: (e) {
      ConnectivityManager().electrumFailure();
      if (mounted) {
        setState(() {
          _state = ElectrumServerEntryState.invalid;
          _isError = true;
          _textBelow = e is InvalidPort
              ? "Invalid port."
              : S().privacy_node_connection_couldNotReach;
        });
      }
    });
  }

  Future<void> _checkEsploraServer(String address) async {
    try {
      final response = await HttpTor(Tor.instance, EnvoyScheduler().parallel)
          .get(('$address/blocks/tip/height'));
      if (response.statusCode == 200) {
        final responseBody = response.body;
        final blockHeight = int.tryParse(responseBody);

        if (blockHeight != null) {
          ConnectivityManager().electrumSuccess();
          if (mounted) {
            setState(() {
              _state = ElectrumServerEntryState.valid;
              _isError = false;
              _textBelow =
                  "${S().privacy_node_connectedTo} Esplora server (Block height: $blockHeight)"; // TODO: Figma
            });
          }
        } else {
          throw Exception('Invalid block height format');
        }
      } else {
        throw Exception('Failed to connect to Esplora server');
      }
    } catch (e) {
      ConnectivityManager().electrumFailure();
      if (mounted) {
        setState(() {
          _state = ElectrumServerEntryState.invalid;
          _isError = true;
          _textBelow = "Could not connect to Esplora server.";
        });
      }
    }
  }
}
