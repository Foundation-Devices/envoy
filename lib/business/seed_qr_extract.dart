// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:envoy/ui/onboard/manual/widgets/wordlist.dart';

String extractSeedFromQRCode(String code, {List<int>? rawBytes}) {
  // Split the code based on various delimiters
  final seedList = code.split(RegExp(r'\s+|,|/'));

  // Join the separated words to form a single seed string
  final parsedSeed = seedList.join(" ");

  // Remove consecutive white spaces
  String cleanedSeed = parsedSeed.replaceAll(RegExp(r'\s+'), ' ');
  if (!isValidSeedLength(cleanedSeed)) {
    String seedFromStandardQR = decodeStandardSeedQR(code);
    if (!isValidSeedLength(seedFromStandardQR)) {
      String seedFromCompactQR = fromCompactToSeed(code);
      if (!isValidSeedLength(seedFromCompactQR)) {
        if (rawBytes != null) {
          String compactBitStream = byteStreamToBitStream(rawBytes);
          return fromCompactToSeed(compactBitStream);
        } else {
          return code;
        }
      } else {
        return seedFromCompactQR;
      }
    } else {
      return seedFromStandardQR;
    }
  }

  return cleanedSeed;
}

bool isValidSeedLength(String seed) {
  final seedLength = seed.split(" ").length;
  return (seedLength == 12 || seedLength == 24);
}

String decodeStandardSeedQR(String seedQR) {
  // If the input is not valid return it unchanged
  if (seedQR.length % 4 != 0 || !seedQR.contains(RegExp(r'^[0-9]+$'))) {
    return seedQR;
  }
  // Split the SeedQR string into 4-digit individual indices
  List<String> indices = [];
  for (int i = 0; i < seedQR.length; i += 4) {
    indices.add(seedQR.substring(i, i + 4));
  }

  // Look up each index number in the BIP-39 word list and concatenate them into a single string
  StringBuffer decodedSeeds = StringBuffer();
  for (String index in indices) {
    int parsedIndex = int.parse(index);

    String seed = seedEn[parsedIndex];
    decodedSeeds.write('$seed ');
  }

  // Return the concatenated string of all seeds
  return decodedSeeds.toString().trim();
}

String compactToStandard(String compactBitstream) {
  // Check if the length of compactBitstream is divisible by 11
  if (compactBitstream.length % 11 != 0) {
    return compactBitstream;
  }

  // Split the compact bitstream into 11-bit binary chunks
  List<String> chunks = [];
  for (int i = 0; i < compactBitstream.length; i += 11) {
    chunks.add(compactBitstream.substring(i, i + 11));
  }

  // Convert each 11-bit binary chunk to decimal and then to 4-digit strings
  String standardDigits = chunks.map((chunk) {
    int index = int.parse(chunk, radix: 2);
    return index.toString().padLeft(4, '0');
  }).join('');

  return standardDigits;
}

String calculateChecksum(String bitstream) {
  bool is24seedWord = bitstream.length >= 256;
  // Take the first 128 bits of the bitstream
  String firstBits = bitstream.substring(0, is24seedWord ? 256 : 128);

  // Convert the bitstream to bytes
  Uint8List bytes = Uint8List.fromList(List.generate(
      firstBits.length ~/ 8,
      (index) => int.parse(firstBits.substring(index * 8, (index + 1) * 8),
          radix: 2)));

  // Calculate the SHA-256 hash of the bytes
  Digest hash = sha256.convert(bytes);

  // Determine the number of bits for the checksum
  int checksumBits = is24seedWord ? 8 : 4;

  // Extract the necessary number of bits from the hash to form the checksum
  int checksum = hash.bytes[0] >> (8 - checksumBits);

  // Convert the checksum to binary representation
  String checksumBinary = checksum.toRadixString(2).padLeft(checksumBits, '0');

  return checksumBinary;
}

String fromCompactToSeed(String compact) {
  // If the input is not valid return it unchanged
  if (!RegExp(r'^[01]+$').hasMatch(compact)) {
    return compact;
  }

  // Check if compact is shorter than 128 characters
  if (compact.length < 128) {
    return compact;
  }
  String checkSum = calculateChecksum(compact);
  compact = compact + checkSum;
  String standard = compactToStandard(compact);
  return decodeStandardSeedQR(standard);
}

String byteStreamToBitStream(List<int> byteStream) {
  String bitStream = '';

  for (int byte in byteStream) {
    String bits = byte.toRadixString(2).padLeft(8, '0');
    bitStream += bits;
  }

  // Remove first 12 bits get from QR scanner
  bitStream = bitStream.substring(12);

  // Remove last unnecessary bits from QR scanner
  if (bitStream.length < 256) {
    bitStream = bitStream.substring(0, 128);
  } else {
    bitStream = bitStream.substring(0, 256);
  }

  return bitStream;
}
