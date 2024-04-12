// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/seed_qr_extract.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  String expectedSeed =
      "word word word word word word word word word word word word";
  test("Test converting with slash", () async {
    String inputCode =
        "word/word/word/word/word/word/word/word/word/word/word/word";
    expect(extractSeedFromQRCode(inputCode), expectedSeed);
  });
  test("Test converting with spaces", () async {
    String inputCode = expectedSeed;
    expect(extractSeedFromQRCode(inputCode), expectedSeed);
  });
  test("Test converting with commas", () async {
    String inputCode =
        "word, word, word, word, word, word, word, word, word, word, word, word";
    expect(extractSeedFromQRCode(inputCode), expectedSeed);
  });

  test("Test converting with additional spaces", () async {
    String inputCode =
        "word   word   word   word   word   word   word   word   word   word   word   word";
    expect(extractSeedFromQRCode(inputCode), expectedSeed);
  });
  test("Test converting with mixed delimiters", () async {
    String inputCode =
        "word word/word, word/word word, word/word, word, word, word, word";
    expect(extractSeedFromQRCode(inputCode), expectedSeed);
  });
  test("Test converting with newlines", () async {
    String inputCode =
        "word\nword\nword\nword\nword\nword\nword\nword\nword\nword\nword\nword";
    expect(extractSeedFromQRCode(inputCode), expectedSeed);
  });

  test("Test bytestream from camera to seed", () async {
    var byteStream = [
      65,
      0,
      172,
      187,
      160,
      8,
      217,
      186,
      0,
      95,
      89,
      150,
      180,
      10,
      52,
      117,
      205,
      144,
      236
    ]; // rawBytes from scanned QR
    String seed =
        "approve fruit lens brass ring actual stool coin doll boss strong rate";
    expect(extractSeedFromQRCode("jfjbfdjbjs", rawBytes: byteStream), seed);
  });

  test("Test vector 1: 24 seed ", () async {
    String inputCode =
        "0000111001110100101101100100000100000111111110010100110011000000110011001111101011100110101000010011110111001011111011000011011001100010000101010100111111101100011001111110000011100000000010011001100111000000011110001001001001011001011111010001100100001010";
    String seed =
        "attack pizza motion avocado network gather crop fresh patrol unusual wild holiday candy pony ranch winter theme error hybrid van cereal salon goddess expire";
    expect(extractSeedFromQRCode(inputCode), seed);
  });

  test("Test vector 2: 24 seed ", () async {
    String inputCode =
        "0000111001011001110111011110001001110110000000001001001100010111111100010010011101011111000100111000100110001000100000000111100011001001100100110110100011010001111010000010010010001001101101011111011000101001010100110001111111000101101101101010010101101110";
    String standardCode =
        "011416550964188800731119157218870156061002561932122514430573003611011405110613292018175411971576";
    String seed =
        "atom solve joy ugly ankle message setup typical bean era cactus various odor refuse element afraid meadow quick medal plate wisdom swap noble shallow";
    expect(extractSeedFromQRCode(inputCode), seed);
    expect(extractSeedFromQRCode(standardCode), seed);
  });

  test("Test vector 3: 24 seed ", () async {
    String inputCode =
        "1100111111001010100011000110010110001011110010000001100101100010010101001001001001010010101111000111101011000011101110100101101100001011000000011101001001101011110010101110100010011111001010110101111011001110101111100010011000111101110010110010101000110110";
    String standardCode =
        "166206750203018810361417065805941507171219081456140818651401074412730727143709940798183613501710";
    String seed =
        "sound federal bonus bleak light raise false engage round stock update render quote truck quality fringe palace foot recipe labor glow tortoise potato still";
    expect(extractSeedFromQRCode(inputCode), seed);
    expect(extractSeedFromQRCode(standardCode), seed);
  });

  test("Test vector 4: 12-word seed ", () async {
    String inputCode =
        "01011011101111011001110101110001101010001110110001111001100100001000001100011010111111110011010110011101010000100110010101000101";
    String standardCode = "073318950739065415961602009907670428187212261116";
    String seed =
        "forum undo fragile fade shy sign arrest garment culture tube off merit";
    expect(extractSeedFromQRCode(inputCode), seed);
    expect(extractSeedFromQRCode(standardCode), seed);
  });

  test("Test vector 5: 12-word seed ", () async {
    String inputCode =
        "01100100011000100110100001100100001001110010000000110011100001011100001000110011011111011101100001001100010100001000100111111101";
    String standardCode = "080301540200062600251559007008931730078802752004";
    String seed =
        "good battle boil exact add seed angle hurry success glad carbon whisper";
    expect(extractSeedFromQRCode(inputCode), seed);
    expect(extractSeedFromQRCode(standardCode), seed);
  });

  test("Test vector 6: 12-word seed ", () async {
    String inputCode =
        "00001010110010111011101000000000100011011001101110100000000001011111010110011001011010110100000010100011010001110101110011011001";
    String standardCode = "008607501025021714880023171503630517020917211425";
    String seed =
        "approve fruit lens brass ring actual stool coin doll boss strong rate";
    expect(extractSeedFromQRCode(inputCode), seed);
    expect(extractSeedFromQRCode(standardCode), seed);
  });

  test("Additional Compact SeedQR problem: \n", () async {
    String inputCode =
        "00111110000111100000101111000001111000110001111000001110010000110001010100110100100010110111011011011111111011000000101010011000";
    String standardCode = "049619221923158517990268067811630950204300210397";
    String seed =
        "dignity utility vacant shiver thought canoe feel multiply item youth actor coyote";
    expect(extractSeedFromQRCode(inputCode), seed);
    expect(extractSeedFromQRCode(standardCode), seed);
  });

  test("Additional Compact SeedQR problem: \r", () async {
    String inputCode =
        "00110000011111101010111100000101100001100101100111001010011110100111101000001101011000110001010100100101000010011110010101000001";
    String standardCode = "038719631547010112530489185713790169032209701051";
    String seed =
        "corn voice scrap arrow original diamond trial property benefit choose junk lock";
    expect(extractSeedFromQRCode(inputCode), seed);
    expect(extractSeedFromQRCode(standardCode), seed);
  });

  test("Additional Compact SeedQR problem: \r\n", () async {
    String inputCode =
        "11110101010111001111010110000111111100100101010000111101000000010000100100001101000010101110011100010000101111010011101101101101";
    String standardCode = "196218530783182905421028028912901848107106301753";
    String seed =
        "vocal tray giggle tool duck letter category pattern train magnet excite swamp";
    expect(extractSeedFromQRCode(inputCode), seed);
    expect(extractSeedFromQRCode(standardCode), seed);
  });

  test("Test bytestream from camera to seed: 24 seed word", () async {
    var byteStream = [
      66,
      0,
      231,
      75,
      100,
      16,
      127,
      148,
      204,
      12,
      207,
      174,
      106,
      19,
      220,
      190,
      195,
      102,
      33,
      84,
      254,
      198,
      126,
      14,
      0,
      153,
      156,
      7,
      137,
      37,
      151,
      209,
      144,
      160
    ]; // rawBytes from scanned QR
    String seed =
        "attack pizza motion avocado network gather crop fresh patrol unusual wild holiday candy pony ranch winter theme error hybrid van cereal salon goddess expire";
    expect(
        extractSeedFromQRCode("t�A�L����=��6bO�g��	��x�Y}",
            rawBytes: byteStream),
        seed);
  });

  test("Test bytestream problem characters", () async {
    var byteStream = [
      65,
      3,
      225,
      224,
      188,
      30,
      49,
      224,
      228,
      49,
      83,
      72,
      183,
      109,
      254,
      192,
      169,
      128,
      236
    ]; // rawBytes from scanned QR
    String seed =
        "dignity utility vacant shiver thought canoe feel multiply item youth actor coyote";
    expect(extractSeedFromQRCode(">��C4�v��", rawBytes: byteStream), seed);
  });
}
