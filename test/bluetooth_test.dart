// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/util/console.dart';
import 'package:test/test.dart';
import 'package:foundation_api/foundation_api.dart';
import 'package:foundation_api/src/rust/api/api.dart';
import 'package:foundation_api/src/rust/third_party/foundation_api/api/pairing.dart';

void main() async {
  test("Test BLE stream", skip: "not ready yet", () async {
    const qrCode =
        "UR:ENVELOPE/LFTPSPLRTPSOTANSFGINIEINJKIAJLKOIHJPKKOYTPSOTANSFLJOIDJZKPIHJYJLJLJYISGUIHJPKOINIAIHTPSOTPDAGDGRHPTOVOFETKFDJLPELORNIOOTBBCWKIOYTPSOTANSFLKTIDJZKPIHJYJLJLJYISFXISHSJPHSIAJYIHJPINJKJYINIATPSOTPDAGDFLEOLKIYDRDIFYATMWPYSGHDKGWZDIJKOYTPSOTANSFLIYJKIHJTIEIHJPTPSOTANSGYLFTANSHFHDCXZOJEKOEMMNDISNDPGTWLGSNLZMDWTYNNMWSORNRFBSSGIMPSGAOEVWZOVLOESOYTTANSGRHDCXAXJONEFTVOVOWDGSDSAATEDMBZOTETDRSPFHIDKIFYRKFWGHJZLFPKFEAHYKFXDROYAXTPSOTANSGHHDFZTAHHFLFWFRWEAYIHVDNYNEJPMSHSEMDECPCTDEIHUONLDTDANNFWIDIEDKGSTLFLGYGDQDKOSRFTEYHDWSZENNLUZEAXLDDIYNRSFMEYLFSOHTDEWNDEEEIYAMHNISTIWFPSTBWP";

    await RustLib.init();

    // 1. decode above
    // 2. store pubkey somewhere
    // 3. respond by sending chunked PairingRequest
    // TODO: get PairingRequest

    // See how BluetoothEnpoint looks in Dart


    // 4. parse PairingResponse

    final request = const PairingRequest();
    //final respones = PairingResponse(passportModel: passportModel, passportFirmwareVersion: passportFirmwareVersion, passportSerial: passportSerial)i

    //final stream = pairStream(discoveryQr: qrCode);

    // stream.listen((data) {
    //   kPrint(data);
    // });


    await Future.delayed(const Duration(seconds: 30));
  });
}
