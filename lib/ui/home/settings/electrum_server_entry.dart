// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:flutter/material.dart';
import 'package:tor/tor.dart';
import 'package:wallet/wallet.dart';
import 'package:wallet/exceptions.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/business/connectivity_manager.dart';
import 'package:envoy/business/node_url.dart';
import 'package:envoy/ui/components/text_field.dart';
import 'package:envoy/ui/pages/scanner_page.dart';
import 'package:envoy/business/settings.dart';

enum ElectrumServerEntryState { pending, valid, invalid }

class ElectrumServerEntry extends StatefulWidget {
  final Function(String) setter;
  final String Function() getter;

  ElectrumServerEntry(this.getter, this.setter);

  @override
  State<ElectrumServerEntry> createState() => _ElectrumServerEntryState();
}

class _ElectrumServerEntryState extends State<ElectrumServerEntry> {
  var _state = ElectrumServerEntryState.valid;
  final TextEditingController _controller = TextEditingController();
  String _textBelow = S().privacy_node_configure;
  Timer? _typingTimer;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _controller.text = widget.getter();
    if (_controller.text.isNotEmpty) {
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

              _typingTimer = Timer(Duration(seconds: 2), () {
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
    int port =
        Settings().turnOffTorForThisCase(address) ? -1 : Tor.instance.port;

    Wallet.getServerFeatures(address, port).then((features) {
      ConnectivityManager().electrumSuccess();
      if (mounted) {
        setState(() {
          _state = ElectrumServerEntryState.valid;
          _isError = false;
          _textBelow =
              "${S().privacy_node_connectedTo} " + features.serverVersion;
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
}
