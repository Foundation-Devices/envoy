// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:convert';

class BitcoinRequest {
  String address;
  Map<String, dynamic> options;

  BitcoinRequest({required this.address, required this.options});

  String get label => options["label"];

  String get message => options["message"];

  double get amount => options["amount"] is int
      ? options["amount"].toDouble()
      : options["amount"] is String
          ? double.parse(options["amount"])
          : options["amount"];

  set label(String newLabel) => options["label"] = newLabel;

  set message(String newMessage) => options["message"] = newMessage;

  set amount(dynamic newAmount) => options["amount"] = newAmount;

  BitcoinRequest.fromJson(Map<String, dynamic> json)
      : address = json["address"],
        options = json["options"];

  String toJson() {
    Map<String, dynamic> decodeOptions = options;
    decodeOptions.removeWhere((key, value) => value == null);
    return json.encode({
      "address": address,
      "options": decodeOptions,
    }).toString();
  }
}

class Bip21 {
  static BitcoinRequest decode(String uri, [String? urnScheme]) {
    urnScheme = urnScheme ?? "bitcoin";
    if (uri.indexOf(urnScheme) != 0 || uri[urnScheme.length] != ":")
      throw ("Invalid BIP21 URI");

    int split = uri.indexOf("?");
    Map<String, String> uriOptions = Uri.parse(uri).queryParameters;

    Map<String, dynamic> options = Map.from({
      "message": uriOptions["message"],
      "label": uriOptions["label"],
    });

    String address =
        uri.substring(urnScheme.length + 1, split == -1 ? null : split);

    if (uriOptions["amount"] != null) {
      String? amountString = uriOptions["amount"];
      if (amountString!.indexOf(",") != -1)
        throw ("Invalid amount: commas are invalid");
      double? amount = double.tryParse(amountString);
      if (amount == null || amount.isNaN)
        throw ("Invalid amount: not a number");
      if (!amount.isFinite) throw ("Invalid amount: not finite");
      if (amount < 0) throw ("Invalid amount: not positive");
      options["amount"] = amount;
    }

    return BitcoinRequest(
      address: address,
      options: options,
    );
  }
}
