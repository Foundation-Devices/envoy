// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:http_tor/http_tor.dart';
import 'package:tor/tor.dart';

class AztecoVoucher {
  List<String> code = [];

  AztecoVoucher(String url) {
    // Parse the url to code
    //"https://azte.co/?c1=1111&c2=2222&c3=3333&c4=4444";

    Uri uri = Uri.parse(url);
    Map<String, dynamic> queryParams = uri.queryParameters;

    code = [
      queryParams['c1'],
      queryParams['c2'],
      queryParams['c3'],
      queryParams['c4']
    ];
  }

  Future<bool> redeem(String address) async {
    String url = getRedeemUrl(address);

    HttpTor _http = HttpTor(Tor());

    final response = await _http.get(url);
    switch (response.statusCode) {
      case 200:
        // Request succeeded, parse the response
        return true;

      default:
        // Request failed
        break;
    }

    return false;
  }

  String getRedeemUrl(String address) {
    return "https://azte.co/fd_despatch.php?CODE_1=" +
        code[0] +
        "&CODE_2=" +
        code[1] +
        "&CODE_3=" +
        code[2] +
        "&CODE_4=" +
        code[3] +
        "&ADDRESS=" +
        address;
  }

  static bool isVoucher(String url) {
    Uri uri = Uri.parse(url);
    return uri.host == "azte.co";
  }
}
