// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:typed_data';

import 'package:envoy/util/console.dart';
import 'package:test/test.dart';
import 'package:ur/ur.dart';
import 'package:envoy/business/uniform_resource.dart';
import 'package:convert/convert.dart';
import 'package:cbor/cbor.dart' as cbor;
import 'package:typed_data/typed_data.dart';
import 'package:collection/collection.dart';

final ur = Ur();

void main() {
  test('UR encode / decode test', () {
    var list = [1, 2, 3];
    var encoder = ur.encoder('bytes', Uint8List.fromList(list), 30);
    var part = encoder.nextPart();

    expect(part, 'ur:bytes/1-1/lpadadaxcygorflacafxadaoaxihgsadlr');

    var decoder = ur.decoder();
    var decoded = decoder.receive(part);

    expect(decoded, list);
  });

  test('UR decode invalid data test', () {
    var decoder = ur.decoder();
    expect(() => decoder.receive("refrigerator"), throwsException);
  });

  test('UR encode / decode multipart test', () {
    var list = [
      42,
      81,
      85,
      8,
      82,
      84,
      76,
      73,
      70,
      88,
      2,
      74,
      40,
      48,
      77,
      54,
      88,
      7,
      5,
      88,
      37,
      25,
      82,
      13,
      69,
      59,
      30,
      39,
      11,
      82,
      19,
      99,
      45,
      87,
      30,
      15,
      32,
      22,
      89,
      44,
      92,
      77,
      29,
      78,
      4,
      92,
      44,
      68,
      92,
      69,
      1,
      42,
      89,
      50,
      37,
      84,
      63,
      34,
      32,
      3,
      17,
      62,
      40,
      98,
      82,
      89,
      24,
      43,
      85,
      39,
      15,
      3,
      99,
      29,
      20,
      42,
      27,
      10,
      85,
      66,
      50,
      35,
      69,
      70,
      70,
      74,
      30,
      13,
      72,
      54,
      11,
      5,
      70,
      55,
      91,
      52,
      10,
      43,
      43,
      52
    ];

    var expected = [
      'ur:bytes/1-4/lpadaacsiecylyaxpywzhdcfdrgygoaygmghgsgafghdaogededygtenhdatahhddacfgmbtfekblownhe',
      'ur:bytes/2-4/lpaoaacsiecylyaxpywzhdcffrckdibdgmbwiadphgckbscxcmhkdwhhgtcaglaahhdwfyhhfefxcaoeay',
      'ur:bytes/3-4/lpaxaacsiecylyaxpywzhdcfaddrhkeydaghfhcpcxaxbyfmdeidgmhkcsdngodibsaxiacabbkbltgyfz',
      'ur:bytes/4-4/lpaaaacsiecylyaxpywzhdcfdrcwbkgofweycnfefgfggeckbtfdenbdahfgemhpeebkdndneelthpceet'
    ];

    var encoder = ur.encoder('bytes', Uint8List.fromList(list), 30);
    var decoder = ur.decoder();

    for (int i = 0; i < expected.length; i++) {
      var part = encoder.nextPart();
      expect(part, expected[i]);
      var decoded = decoder.receive(part);

      if (i >= expected.length) {
        expect(decoded.isNotEmpty, true);
      }

      if (decoded.isNotEmpty) {
        expect(decoded, list);
      }
    }
  });

  test('UR encoder memory leak test', () {
    var list = [1, 2, 3];
    var encoder = ur.encoder('bytes', Uint8List.fromList(list), 30);

    for (var i = 0; i < 1000; i++) {
      encoder.nextPart();
    }
  });

  test('crypto-request UR type test', () {
    CryptoRequest request = CryptoRequest()
      ..objects.add(SeedRequest(hex.decode(
          "e824467caffeaf3bbc3e0ca095e660a9bad80ddb6a919433a37161908b9a3986")));

    var encoded = request.nextPart();
    kPrint(encoded);
  });

  test('crypto-response decode test', () {
    // UR received from Passport
    String urFromPassport =
        "ur:crypto-response/otadtpdagdjprpbgdmbnbbfwkblsluskkktpsbcxtlaotaaostoxadieioinjpjzaoihjyisihjpihaxieiohsinjtaaiyjkishsiejlktaxtaaottaoqzdpincx";
    var reader = UniformResourceReader();
    reader.receive(urFromPassport);

    assert(reader.decoded is CryptoResponse);
    CryptoResponse response = reader.decoded as CryptoResponse;

    assert(response.objects[0] is ScvChallengeResponse);
    ScvChallengeResponse scvResponse =
        response.objects[0] as ScvChallengeResponse;

    assert(response.objects[1] is PassportModel);
    PassportModel passportModel = response.objects[1] as PassportModel;

    expect(scvResponse.responseWords, ["girl", "there", "gain", "shadow"]);
    expect(passportModel.model, 2);
  });

  test('crypto-response with device firwmare version decode test', () {
    // UR received from Passport
    String urFromPassport =
        "ur:crypto-response/oxadtpdagdgohtntfhdygtgamkoeetpkhkurlkcmahaotaaostoxadioihiajljtjljnkkaoiohsjyjyjphsiajyaxihkpjtjyinjzaaihjzkpiajekkaxtaaottaoaataaxaxiheydmdydmeoeyfpmsss";
    var reader = UniformResourceReader();
    reader.receive(urFromPassport);

    assert(reader.decoded is CryptoResponse);
    CryptoResponse response = reader.decoded as CryptoResponse;

    assert(response.objects[0] is ScvChallengeResponse);
    ScvChallengeResponse scvResponse =
        response.objects[0] as ScvChallengeResponse;

    assert(response.objects[1] is PassportModel);
    PassportModel passportModel = response.objects[1] as PassportModel;

    assert(response.objects[2] is PassportFirmwareVersion);
    PassportFirmwareVersion passportFirmwareVersion =
        response.objects[2] as PassportFirmwareVersion;

    expect(scvResponse.responseWords, ["economy", "attract", "until", "lucky"]);
    expect(passportModel.model, 2);
    expect(passportFirmwareVersion.version, "2.0.3");
  });

  test('crypto-response UR type test', () {
    // Make a crypto-response with CBOR
    final inst = cbor.Cbor();
    cbor.Encoder cborEncoder = inst.encoder;
    cbor.MapBuilder tlMap = cbor.MapBuilder.builder();

    tlMap.writeInt(1);
    tlMap.writeTag(37);

    Uint8Buffer uuidBuffer = Uint8Buffer();
    uuidBuffer.addAll(hex.decode("020C223A86F7464693FC650EF3CAC047"));
    tlMap.writeBytes(uuidBuffer);

    tlMap.writeInt(2);
    tlMap.writeTag(721);

    tlMap.writeMap(<int, List<int>>{
      1: [1, 0, 8, 0]
    });

    cborEncoder.addBuilderOutput(tlMap.getData());

    var buffer = inst.output.getData().cast<int>();
    var urEncoder =
        Ur().encoder('crypto-response', Uint8List.fromList(buffer), 50);
    var part = urEncoder.nextPart();

    UniformResourceReader response = UniformResourceReader();
    response.receive(part);
  });

  test('crypto-hdkey UR type test', () {
    // UR received from Passport
    String urFromPassport =
        "ur:crypto-hdkey/onaxhdclaojlvoechgferkdpqdiabdrflawshlhdmdcemtfnlrctghchbdolvwsednvdztbgolaahdcxtottgostdkhfdahdlykkecbbweskrymwflvdylgerkloswtbrpfdbsticmwylklpahtaadehoyaoadamtaaddyoyadlecsdwykadykadykaewkadwkaycywlcscewfihbdaehn";

    var reader = UniformResourceReader();
    reader.receive(urFromPassport);

    assert(reader.decoded is CryptoHdKey);

    CryptoHdKey hdkey = reader.decoded as CryptoHdKey;

    String keyData = "";

    for (int number in hdkey.keyData!) {
      keyData = keyData + number.toRadixString(16).padLeft(2, "0");
    }

    assert(keyData ==
        "026fe2355745bb2db3630bbc80ef5d58951c963c841f54170ba6e5c12be7fc12a6");

    String chainCode = "";

    for (int number in hdkey.chainCode!) {
      chainCode = chainCode + number.toRadixString(16).padLeft(2, "0");
    }

    assert(chainCode ==
        "ced155c72456255881793514edc5bd9447e7f74abb88c6d6b6480fd016ee8c85");
    assert(hdkey.parentFingerprint == 3910671603);
    assert(hdkey.network == HdKeyNetwork.testnet);
    assert(hdkey.path == "/44h/1h/1h/0/1");
  });

  test('decode SCV crypto-request', () {
    var reader = UniformResourceReader();
    reader.receive(
        "ur:crypto-request/1-7/lpadatcfadfecywentfspfhddloeadtpdagddlhertjlhgpmfwldpezeioaxaatpsnbzaotaaoswotadksfzdyiheoieiheneoiaidiyehideeeoetiaidetoxbtdley");
    reader.receive(
        "ur:crypto-request/2-7/lpaoatcfadfecywentfspfhddliehsiyesetieeeiheohseeeciaieihidemdyeyeseseoihiyieehemeteyiheneniaenecemehecetemechsetenemeeaomeaxttzo");
    reader.receive(
        "ur:crypto-request/3-7/lpaxatcfadfecywentfspfhddlkslaiaiadyiehsiaieeneehsieeodyeoemeedyeneyiaeseniaiedyihiedyeneyeheteoemdyieenenehiyiaeeihhshsrecfsptd");
    reader.receive(
        "ur:crypto-request/4-7/lpaaatcfadfecywentfspfhddleshsihesiaeeeciydyesesidemeteyeseseeecihiehsehiheedyeteseyeneeeoeneteyeeetdyieenenehdyetideceokgidhnrl");
    reader.receive(
        "ur:crypto-request/5-7/lpahatcfadfecywentfspfhddldyhsehhsecemeniyemecidecehiddyemeyeodyiheceteheeeniheeiheyesieesidiaecidaxksiddyfgaoclaesrlkbtjyztbdcw");
    reader.receive(
        "ur:crypto-request/6-7/lpamatcfadfecywentfspfhddlsapssrmtgesrmuaxjyamdwsamtsrlgbasrmhidcsembtiyctsrlrsrpksaptsaplsansfesrpfsanlsarlsalfsanlfeaoutwsskie");
    reader.receive(
        "ur:crypto-request/7-7/lpatatcfadfecywentfspfhddlclaesrpmsaoysroxaysamoieensalffdbtiybesalugubkcyhgjlkpsarecwatcnbahdbbjtgldtsrnlsarfhpaeaeaeaezmwmjtaa");

    assert(reader.decoded is CryptoRequest);

    var request = reader.decoded as CryptoRequest;
    assert(const ListEquality().equals(request.uuid, [
      47,
      95,
      192,
      111,
      87,
      173,
      66,
      137,
      175,
      254,
      103,
      3,
      4,
      216,
      205,
      21
    ]));

    var scvRequest = request.objects[0] as ScvChallengeRequest;
    assert(scvRequest.id ==
        "0e3de63cbf1b438cb8daf98d4e3a45cdeb702993efd1782e66c65715875a8674");
    assert(scvRequest.signature ==
        "cc0dacd64ad30374062c96cd0ed06218370d661fc4eaa9ae9c45f099b7829945eda1e40892643682480d66108b530a1a576f75b51b07230e58146e4e29d9bc5b");
  });

  test('pairing crypto-request test', () {
    // Passport generates a request
    CryptoRequest request = CryptoRequest.specificUuid(
        [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16])
      ..objects.add(CryptoHdKey(
          keyData: hex.decode(
              "026fe2355745bb2db3630bbc80ef5d58951c963c841f54170ba6e5c12be7fc12a6"),
          chainCode: hex.decode(
              "ced155c72456255881793514edc5bd9447e7f74abb88c6d6b6480fd016ee8c85"),
          network: HdKeyNetwork.testnet,
          parentFingerprint: 3910671603,
          keypath: [
            Index(44, true),
            Index(1, true),
            Index(1, true),
            Index(0, false),
            Index(1, false)
          ]));

    request.objects.add(PassportModel(2));
    request.objects.add(PassportFirmwareVersion("1.0.8"));
    request.objects.add(PassportSerial("xyz-123"));

    var part1 = request.nextPart();
    var part2 = request.nextPart();
    var part3 = request.nextPart();
    var part4 = request.nextPart();

    assert(part1 ==
        "ur:crypto-request/1-4/lpadaacsolcydnmwrpwyhddronadtpdahdcxaeaeaeaeaeaeaeaeaeaeaeaeaeaeaeaeadaoaxaaahamatayasbkbdbnbtbabsbeaotaaddlsfhphnzc");
    assert(part2 ==
        "ur:crypto-request/2-4/lpaoaacsolcydnmwrpwyhddronaxhdclaojlvoechgferkdpqdiabdrflawshlhdmdcemtfnlrctghchbdolvwsednvdztbgolaahdcxtottqdhgvedw");
    assert(part3 ==
        "ur:crypto-request/3-4/lpaxaacsolcydnmwrpwyhddrgostdkhfdahdlykkecbbweskrymwflvdylgerkloswtbrpfdbsticmwylklpahoyaoadamoyadlecsdwykadwnecnyzc");
    assert(part4 ==
        "ur:crypto-request/4-4/lpaaaacsolcydnmwrpwyhddrykadykaewkadwkaycywlcscewfaxtaaottaoaataaxaxihehdmdydmetahtaaoytiokskkkndpeheyeoaeaetiwdjeos");

    // Envoy reads it into an object
    var reader = UniformResourceReader();
    reader.receive(part1);
    reader.receive(part2);
    reader.receive(part3);
    reader.receive(part4);

    assert(reader.decoded is CryptoRequest);

    var requestFromPassport = reader.decoded as CryptoRequest;
    assert(requestFromPassport.objects[0] is CryptoHdKey);
    assert(requestFromPassport.objects[1] is PassportModel);
    assert(requestFromPassport.objects[2] is PassportFirmwareVersion);
    assert(requestFromPassport.objects[3] is PassportSerial);
  });

  test('crypto-request PSBT test', () {
    CryptoRequest request = CryptoRequest()
      ..objects.add(PsbtSignatureRequest(hex.decode(
          "e824467caffeaf3bbc3e0ca095e660a9bad80ddb6a919433a37161908b9a3986"))); // TODO: get this guy from the wallet

    var encoded = request.nextPart();
    kPrint(encoded);
  });
}
