// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';

import 'package:envoy/business/node_url.dart';
import 'package:envoy/ui/pages/scanner_page.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:tor/tor.dart';
import 'package:wallet/wallet.dart';
import 'package:wallet/exceptions.dart';

enum ElectrumServerEntryState { pending, valid, invalid }

class ElectrumServerEntry extends StatefulWidget {
  final Function(String) setter;
  final String Function() getter;

  ElectrumServerEntry(this.getter, this.setter);

  @override
  State<ElectrumServerEntry> createState() => _ElectrumServerEntryState();
}

class _ElectrumServerEntryState extends State<ElectrumServerEntry> {
  //ignore:unused_field
  var _state = ElectrumServerEntryState.valid;
  final _controller = TextEditingController();

  String _textBelow = "";

  Timer? _typingTimer;

  @override
  initState() {
    super.initState();
    _controller.text = widget.getter();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
              color: Colors.white10, borderRadius: BorderRadius.circular(15)),
          child: TextFormField(
              onChanged: (address) {
                widget.setter(address);
                if (_typingTimer != null) {
                  _typingTimer!.cancel();
                }
                _typingTimer = Timer(
                  Duration(seconds: 2),
                  () {
                    _validateServer(parseNodeUrl(address));
                  },
                );
              },
              style: Theme.of(context)
                  .textTheme
                  .bodyText1!
                  .copyWith(color: Colors.grey),
              controller: _controller,
              decoration: InputDecoration(
                // Disable the borders
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,

                prefixIconConstraints: BoxConstraints(
                    maxWidth: 40, maxHeight: 40, minHeight: 40, minWidth: 40),

                prefixIcon: _state == ElectrumServerEntryState.pending
                    ? Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : _state == ElectrumServerEntryState.valid
                        ? Icon(Icons.check)
                        : Icon(Icons.cancel_outlined),
                suffixIcon: IconButton(
                  icon: Icon(Icons.qr_code),
                  onPressed: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return ScannerPage.nodeUrl((result) {
                        var parsedUrl = parseNodeUrl(result);

                        _controller.text = parsedUrl;
                        widget.setter(parsedUrl);
                        // Validate
                        _validateServer(parsedUrl);
                      });
                    }));
                  },
                ),
              )),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            _textBelow,
            style: TextStyle(color: Colors.white),
          ),
        )
      ],
    );
  }

  void _validateServer(String address) {
    setState(() {
      _state = ElectrumServerEntryState.pending;
    });
    Wallet.getServerFeatures(address, Tor().port).then((features) {
      setState(() {
        _state = ElectrumServerEntryState.valid;
        _textBelow = "Connected to " + features.serverVersion;
      });
    }, onError: (e) {
      if (e is InvalidPort) {
        print("Your port is invalid");
      }
      setState(() {
        _state = ElectrumServerEntryState.invalid;
        _textBelow = e.toString();
      });
    });
  }
}
