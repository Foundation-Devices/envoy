import 'dart:math';
import 'dart:io';
import 'package:flutter/services.dart';

import 'local_storage.dart';

const String SEED_KEY = "seed";
const String LOCAL_SECRET_FILE_NAME = "local.secret";
const String LOCAL_SECRET_LAST_BACKUP_TIMESTAMP_FILE_NAME =
    LOCAL_SECRET_FILE_NAME + ".backup_timestamp";

const int SECRET_LENGTH_BYTES = 16;

class SecretsManager {
  // 12 words == 128 + 4 == 132 (4 bits are checksum)
  // 128 bits == 16 bytes
  // Checksum is first 4 bits of SHA-256 of 16 bytes

  static const _platform = MethodChannel('envoy');

  createSeed(List<int> seedOtp) async {
    final entropy = await createLocalSecret();
    final seed = xorBytes(seedOtp, entropy);

    LocalStorage().saveSecure(SEED_KEY, seed.toString());
  }

  Future<List<int>?> getSeed() async {
    if (!await LocalStorage().containsSecure(SEED_KEY)) {
      return null;
    }

    final seed = await LocalStorage().readSecure(SEED_KEY);
    return convert(seed!);
  }

  // TODO: a function to return a watch-only (temporary hot wallet to sign?)

  List<int> getRandomBytes(int len) {
    var rng = new Random.secure();
    return List.generate(len, (_) => rng.nextInt(255));
  }

  List<int> xorBytes(List<int> first, List<int> second) {
    assert(first.length == second.length);
    return List.generate(first.length, (index) => first[index] ^ second[index]);
  }

  Future<File> saveNonSecure(List<int> data, String name) async {
    return LocalStorage().saveFile(name, data.toString());
  }

  Future<List<int>> restoreNonSecure(String name) async {
    String contents = await LocalStorage().readFile(name);
    return convert(contents);
  }

  List<int> convert(String contents) {
    // Dart doesn't do nice serialization so reverse .toString() manually
    List<String> values = contents
        .substring(1, contents.length - 1) // Get rid of enclosing []
        .replaceAll(" ", "") // Get rid of spaces
        .split(",");

    return List.generate(values.length, (index) => int.parse(values[index]));
  }

  showSettingsMenu() {
    _platform.invokeMethod('show_settings');
  }

  Future<List<int>> createLocalSecret() async {
    final localBytes = getRandomBytes(SECRET_LENGTH_BYTES);
    await saveNonSecure(localBytes, LOCAL_SECRET_FILE_NAME);
    _platform.invokeMethod('data_changed');
    return localBytes;
  }

  Future<List<int>> getLocalSecret() async {
    return await restoreNonSecure(LOCAL_SECRET_FILE_NAME);
  }

  Future<DateTime> getLocalSecretLastBackupTimestamp() async {
    String timestampString = await LocalStorage()
        .readFile(LOCAL_SECRET_LAST_BACKUP_TIMESTAMP_FILE_NAME);
    int timestamp =
        int.parse(timestampString.replaceAll(".", "").substring(0, 13));
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  // TODO: function to spawn a wallet - what's the derivation path?
}
