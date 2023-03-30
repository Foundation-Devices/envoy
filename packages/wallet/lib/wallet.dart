// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:json_annotation/json_annotation.dart';
import 'package:wallet/exceptions.dart';
import 'package:wallet/generated_bindings.dart';

// Generated
part 'wallet.g.dart';

enum Network { Mainnet, Testnet, Signet, Regtest }

@JsonSerializable()
class Transaction {
  final String memo;
  final String txId;
  final DateTime date;
  final int fee;
  final int sent;
  final int received;
  final int blockHeight;

  get isConfirmed => date.compareTo(DateTime(2008)) > 0;

  get amount => received - sent;

  Transaction(this.memo, this.txId, this.date, this.fee, this.received,
      this.sent, this.blockHeight);

  // Serialisation
  factory Transaction.fromJson(Map<String, dynamic> json) =>
      _$TransactionFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionToJson(this);
}

class NativeTransactionList extends Struct {
  @Uint32()
  external int transactionsLen;
  external Pointer<NativeTransaction> transactions;
}

class NativeTransaction extends Struct {
  external Pointer<Uint8> txid;
  @Uint64()
  external int received;
  @Uint64()
  external int sent;
  @Uint64()
  external int fee;
  @Uint32()
  external int confirmationHeight;
  @Uint64()
  external int confirmationTime;
}

class NativeSeed extends Struct {
  external Pointer<Uint8> mnemonic;
  external Pointer<Uint8> xprv;
  external Pointer<Uint8> fingerprint;
}

class NativePsbt extends Struct {
  @Uint64()
  external int sent;
  @Uint64()
  external int received;
  @Uint64()
  external int fee;
  external Pointer<Uint8> base64;
  external Pointer<Uint8> txid;
  external Pointer<Uint8> rawtx;
}

class NativeServerFeatures extends Struct {
  external Pointer<Uint8> serverVersion;
  external Pointer<Uint8> protocolMin;
  external Pointer<Uint8> protocolMax;
  @Int64()
  external int pruning;
  external Pointer<Uint8> genesisHash;
}

typedef WalletInitRust = Pointer<Uint8> Function(
    Pointer<Utf8> name,
    Pointer<Utf8> externalDescriptor,
    Pointer<Utf8> internalDescriptor,
    Pointer<Utf8> dataDir,
    Uint16 network);

typedef WalletInitDart = Pointer<Uint8> Function(
    Pointer<Utf8> name,
    Pointer<Utf8> externalDescriptor,
    Pointer<Utf8> internalDescriptor,
    Pointer<Utf8> dataDir,
    int network);

typedef WalletDropRust = Pointer<Utf8> Function(Pointer<Uint8> wallet);
typedef WalletDropDart = Pointer<Utf8> Function(Pointer<Uint8> wallet);

typedef WalletGetAddressRust = Pointer<Utf8> Function(Pointer<Uint8> wallet);
typedef WalletGetAddressDart = Pointer<Utf8> Function(Pointer<Uint8> wallet);

typedef WalletSyncRust = Bool Function(
    Pointer<Uint8> wallet, Pointer<Utf8> electrumAddress, Int32 torPort);
typedef WalletSyncDart = bool Function(
    Pointer<Uint8> wallet, Pointer<Utf8> electrumAddress, int torPort);

typedef WalletGetBalanceRust = Uint64 Function(Pointer<Uint8> wallet);
typedef WalletGetBalanceDart = int Function(Pointer<Uint8> wallet);

typedef WalletGetFeeRateRust = Double Function(
    Pointer<Utf8> electrumAddress, Int32 torPort, Uint16 target);
typedef WalletGetFeeRateDart = double Function(
    Pointer<Utf8> electrumAddress, int torPort, int target);

typedef WalletGetServerFeaturesRust = NativeServerFeatures Function(
    Pointer<Utf8> electrumAddress, Int32 torPort);
typedef WalletGetServerFeaturesDart = NativeServerFeatures Function(
    Pointer<Utf8> electrumAddress, int torPort);

typedef WalletGetTransactionsRust = NativeTransactionList Function(
    Pointer<Uint8> wallet);
typedef WalletGetTransactionsDart = NativeTransactionList Function(
    Pointer<Uint8> wallet);

typedef WalletCreatePsbtRust = NativePsbt Function(
    Pointer<Uint8> wallet, Pointer<Utf8> sendTo, Uint64 amount, Double feeRate);
typedef WalletCreatePsbtDart = NativePsbt Function(
    Pointer<Uint8> wallet, Pointer<Utf8> sendTo, int amount, double feeRate);

typedef WalletBroadcastTxRust = Pointer<Utf8> Function(
    Pointer<Utf8> electrumAddress, Int32 torPort, Pointer<Utf8> tx);
typedef WalletBroadcastTxDart = Pointer<Utf8> Function(
    Pointer<Utf8> electrumAddress, int torPort, Pointer<Utf8> tx);

typedef WalletDecodePsbtRust = NativePsbt Function(
    Pointer<Uint8> wallet, Pointer<Utf8> psbt);
typedef WalletDecodePsbtDart = NativePsbt Function(
    Pointer<Uint8> wallet, Pointer<Utf8> psbt);

typedef WalletValidateAddressRust = Uint8 Function(
    Pointer<Uint8> wallet, Pointer<Utf8> address);
typedef WalletValidateAddressDart = int Function(
    Pointer<Uint8> wallet, Pointer<Utf8> address);

typedef WalletGenerateSeedRust = NativeSeed Function(Uint16 network);
typedef WalletGenerateSeedDart = NativeSeed Function(int network);

typedef WalletGetSeedWordsRust = NativeSeed Function(Pointer<Uint8> seed);
typedef WalletGetSeedWordsDart = NativeSeed Function(Pointer<Uint8> seed);

typedef WalletGetXpubDescKeyRust = Pointer<Utf8> Function(
    Pointer<Utf8> xprv, Pointer<Utf8> path);
typedef WalletGetXpubDescKeyDart = Pointer<Utf8> Function(
    Pointer<Utf8> xprv, Pointer<Utf8> path);

typedef WalletGenerateSeedWithEntropyRust = Pointer<Utf8> Function(
    Pointer<Uint8> entropy);
typedef WalletGenerateSeedWithEntropyDart = Pointer<Utf8> Function(
    Pointer<Uint8> entropy);

typedef WalletSignOfflineRust = Pointer<Utf8> Function(
    Pointer<Utf8> psbt,
    Pointer<Utf8> externalDescriptor,
    Pointer<Utf8> internalDescriptor,
    Uint16 network);
typedef WalletSignOfflineDart = Pointer<Utf8> Function(
    Pointer<Utf8> psbt,
    Pointer<Utf8> externalDescriptor,
    Pointer<Utf8> internalDescriptor,
    int network);

typedef WalletSignPsbtRust = Pointer<Utf8> Function(
    Pointer<Uint8> wallet, Pointer<Utf8> psbt);
typedef WalletSignPsbtDart = Pointer<Utf8> Function(
    Pointer<Uint8> wallet, Pointer<Utf8> psbt);

DynamicLibrary load(name) {
  if (Platform.isAndroid) {
    return DynamicLibrary.open('lib$name.so');
  } else if (Platform.isLinux) {
    return DynamicLibrary.open('target/debug/lib$name.so');
  } else if (Platform.isIOS || Platform.isMacOS) {
    // iOS and MacOS are statically linked, so it is the same as the current process
    return DynamicLibrary.process();
  } else {
    throw NotSupportedPlatform('${Platform.operatingSystem} is not supported!');
  }
}

class Psbt {
  final int sent;
  final int received;
  final int fee;
  final String base64;
  final String txid;
  final String rawTx;

  get amount => received - sent;

  Psbt(this.sent, this.received, this.fee, this.base64, this.txid, this.rawTx);

  factory Psbt.fromNative(NativePsbt psbt) {
    return Psbt(
        psbt.sent,
        psbt.received,
        psbt.fee,
        psbt.base64.cast<Utf8>().toDartString(),
        psbt.txid.cast<Utf8>().toDartString(),
        psbt.rawtx.cast<Utf8>().toDartString());
  }
}

class ElectrumServerFeatures {
  final String serverVersion;
  final String protocolMin;
  final String protocolMax;
  final int pruning;

  final List<int> genesisHash;

  ElectrumServerFeatures(this.serverVersion, this.protocolMin, this.protocolMax,
      this.pruning, this.genesisHash);

  factory ElectrumServerFeatures.fromNative(NativeServerFeatures features) {
    List<int> genesisHash = List.from(features.genesisHash.asTypedList(32));
    //malS().free(features.genesisHash);

    return ElectrumServerFeatures(
        features.serverVersion.cast<Utf8>().toDartString(),
        features.protocolMin.cast<Utf8>().toDartString(),
        features.protocolMax.cast<Utf8>().toDartString(),
        features.pruning,
        genesisHash);
  }
}

@JsonSerializable()
class Wallet {
  static late String _libName = "wallet_ffi";
  static late DynamicLibrary _lib;

  Pointer<Uint8> _self = nullptr;
  bool _currentlySyncing = false;

  final String name;
  String? externalDescriptor;
  String? internalDescriptor;

  String? publicExternalDescriptor;
  String? publicInternalDescriptor;

  @JsonKey(
      defaultValue:
          Network.Mainnet) // Migration from binary main/testnet approach
  final Network network;

  @JsonKey(
      defaultValue: false) // Migration from time when all the Wallets were cold
  final bool hot;

  @JsonKey(
      defaultValue: false) // Migration from time when all the Wallets were cold
  final bool hasPassphrase;

  List<Transaction> transactions = [];
  int balance = 0;

  // BTC per kb
  double feeRateFast = 0;
  double feeRateSlow = 0;

  // Serialisation
  factory Wallet.fromJson(Map<String, dynamic> json) => _$WalletFromJson(json);

  Map<String, dynamic> toJson() => _$WalletToJson(this);

  // This needs to be a top-level static function in order to sync wallet in separate thread
  static _sync(Map args) {
    // A workaround as we are not able to pass DynamicLibraries to isolates:
    // "Calling this function multiple times with the same [path], even across
    // different isolates, only loads the library into the DartVM process once."
    DynamicLibrary lib = load(_libName);

    int walletPtr = args["wallet_pointer"];
    String electrumAddress = args["electrum_address"];
    int torPort = args["tor_port"];

    final rustFunction =
        lib.lookup<NativeFunction<WalletSyncRust>>('wallet_sync');
    final dartFunction = rustFunction.asFunction<WalletSyncDart>();

    bool synced = dartFunction(
      Pointer.fromAddress(walletPtr),
      electrumAddress.toNativeUtf8(),
      torPort,
    );

    if (!synced) {
      return null;
    }

    var balance = _getBalance(walletPtr);

    var feeRateFast = _getFeeRate(electrumAddress, torPort, 1);
    var feeRateSlow = _getFeeRate(electrumAddress, torPort, 24);

    var transactions = _getTransactions(walletPtr);

    return {
      "balance": balance,
      "feeRateFast": feeRateFast,
      "feeRateSlow": feeRateSlow,
      "transactions": transactions
    };
  }

  static String _getAddress(int walletAddress) {
    DynamicLibrary lib = load(_libName);

    final rustFunction =
        lib.lookup<NativeFunction<WalletGetAddressRust>>('wallet_get_address');
    final dartFunction = rustFunction.asFunction<WalletGetAddressDart>();

    return dartFunction(Pointer.fromAddress(walletAddress))
        .cast<Utf8>()
        .toDartString();
  }

  Wallet(
      this.name, this.network, this.externalDescriptor, this.internalDescriptor,
      {this.hot = false,
      this.hasPassphrase = false,
      this.publicExternalDescriptor = null,
      this.publicInternalDescriptor = null});

  init(String walletsDirectory) {
    _lib = load(_libName);

    final rustFunction =
        _lib.lookup<NativeFunction<WalletInitRust>>('wallet_init');
    final dartFunction = rustFunction.asFunction<WalletInitDart>();

    _self = dartFunction(
        name.toNativeUtf8(),
        externalDescriptor!.toNativeUtf8(),
        internalDescriptor!.toNativeUtf8(),
        (walletsDirectory + name).toNativeUtf8(),
        network.index);

    if (_self == nullptr) {
      throwRustException(_lib);
    }
  }

  Wallet.fromPointer(this.name, this.network, this.externalDescriptor,
      this.internalDescriptor, this._self,
      {this.hot = false,
      this.hasPassphrase = false,
      this.publicExternalDescriptor = null,
      this.publicInternalDescriptor = null,
      required DynamicLibrary lib}) {
    _lib = lib;
  }

  drop() {
    final rustFunction =
        _lib.lookup<NativeFunction<WalletDropRust>>('wallet_drop');
    final dartFunction = rustFunction.asFunction<WalletDropDart>();

    dartFunction(_self);
  }

  Future<String> getAddress() async {
    return compute(_getAddress, _self.address);
  }

  // Returns true if there have been changes
  Future<bool?> sync(String electrumAddress, int torPort) async {
    if (_currentlySyncing) {
      return null;
    }

    _currentlySyncing = true;

    // Unfortunately we need to pass maps onto computes if there is more than one arg
    Map map = Map();
    map['wallet_pointer'] = _self.address;
    map['electrum_address'] = electrumAddress;
    map['tor_port'] = torPort;

    return compute(_sync, map).then((var walletState) {
      _currentlySyncing = false;

      if (walletState == null) {
        throw Exception("Couldn't sync");
      }

      bool changed = false;

      if (balance != walletState["balance"]) {
        changed = true;
      }

      if (transactions.length != walletState["transactions"].length) {
        changed = true;
      }

      balance = walletState["balance"];
      transactions = walletState["transactions"];

      // Sort transactions by date
      transactions.sort((t1, t2) {
        // Mempool transactions go on top
        if (t1.date.isBefore(DateTime(2008)) &&
            t2.date.isBefore(DateTime(2008))) {
          return 0;
        }

        if (t2.date.isBefore(DateTime(2008))) {
          return 1;
        }

        if (t1.date.isBefore(DateTime(2008))) {
          return -1;
        }

        return t2.date.compareTo(t1.date);
      });

      // Don't update fees if they error out
      if (walletState["feeRateFast"] >= 0) {
        feeRateFast = walletState["feeRateFast"];
      }

      if (walletState["feeRateSlow"] >= 0) {
        feeRateSlow = walletState["feeRateSlow"];
      }

      return changed;
    }).timeout(Duration(seconds: 30), onTimeout: () {
      _currentlySyncing = false;
      throw TimeoutException;
    });
  }

  Future<Psbt> createPsbt(String sendTo, int amount, double feeRate) async {
    final rustFunction =
        _lib.lookup<NativeFunction<WalletCreatePsbtRust>>('wallet_create_psbt');
    final dartFunction = rustFunction.asFunction<WalletCreatePsbtDart>();

    return Future(() {
      NativePsbt psbt =
          dartFunction(_self, sendTo.toNativeUtf8(), amount, feeRate);
      if (psbt.base64 == nullptr) {
        throwRustException(_lib);
      }

      return Psbt.fromNative(psbt);
    });
  }

  Future<Psbt> decodePsbt(String base64Psbt) async {
    final rustFunction =
        _lib.lookup<NativeFunction<WalletDecodePsbtRust>>('wallet_decode_psbt');
    final dartFunction = rustFunction.asFunction<WalletDecodePsbtDart>();

    return Future(() {
      NativePsbt psbt = dartFunction(_self, base64Psbt.toNativeUtf8());

      if (psbt.base64 == nullptr) {
        throwRustException(_lib);
      }

      return Psbt.fromNative(psbt);
    });
  }

  static int _getBalance(int walletAddress) {
    DynamicLibrary lib = load(_libName);

    final rustFunction =
        lib.lookup<NativeFunction<WalletGetBalanceRust>>('wallet_get_balance');
    final dartFunction = rustFunction.asFunction<WalletGetBalanceDart>();

    return dartFunction(Pointer.fromAddress(walletAddress));
  }

  static double _getFeeRate(String electrumAddress, int torPort, int target) {
    DynamicLibrary lib = load(_libName);

    final rustFunction =
        lib.lookup<NativeFunction<WalletGetFeeRateRust>>('wallet_get_fee_rate');
    final dartFunction = rustFunction.asFunction<WalletGetFeeRateDart>();

    return dartFunction(electrumAddress.toNativeUtf8(), torPort, target);
  }

  static Future<ElectrumServerFeatures> getServerFeatures(
      String electrumAddress, int torPort) async {
    Map map = Map();
    map['electrum_address'] = electrumAddress;
    map['tor_port'] = torPort;

    return compute(_getServerFeatures, map).then((var features) => features,
        onError: (e) {
      throw getIsolateException(e.message);
    });
  }

  static Future<ElectrumServerFeatures> _getServerFeatures(Map args) async {
    DynamicLibrary lib = load(_libName);

    String electrumAddress = args["electrum_address"];
    int torPort = args["tor_port"];

    final rustFunction =
        lib.lookup<NativeFunction<WalletGetServerFeaturesRust>>(
            'wallet_get_server_features');
    final dartFunction = rustFunction.asFunction<WalletGetServerFeaturesDart>();

    NativeServerFeatures features =
        dartFunction(electrumAddress.toNativeUtf8(), torPort);

    if (features.serverVersion == nullptr) {
      throwRustException(lib);
    }

    return ElectrumServerFeatures.fromNative(features);
  }

  static List<Transaction> _getTransactions(int walletAddress) {
    DynamicLibrary lib = load(_libName);

    final rustFunction = lib.lookup<NativeFunction<WalletGetTransactionsRust>>(
        'wallet_get_transactions');
    final dartFunction = rustFunction.asFunction<WalletGetTransactionsDart>();

    NativeTransactionList txList =
        dartFunction(Pointer.fromAddress(walletAddress));

    List<Transaction> transactions = [];
    for (var i = 0; i < txList.transactionsLen; i++) {
      var tx = txList.transactions.elementAt(i).ref;
      transactions.add(Transaction(
          "",
          tx.txid.cast<Utf8>().toDartString(),
          DateTime.fromMillisecondsSinceEpoch(tx.confirmationTime * 1000),
          tx.fee,
          tx.received,
          tx.sent,
          tx.confirmationHeight));
    }

    return transactions;
  }

  Future<String> broadcastTx(
      String electrumAddress, int torPort, String tx) async {
    final rustFunction = _lib
        .lookup<NativeFunction<WalletBroadcastTxRust>>('wallet_broadcast_tx');
    final dartFunction = rustFunction.asFunction<WalletBroadcastTxDart>();

    return Future(() {
      var txid = dartFunction(
              electrumAddress.toNativeUtf8(), torPort, tx.toNativeUtf8())
          .cast<Utf8>()
          .toDartString();

      if (txid.isEmpty) {
        throwRustException(_lib);
      }

      return txid;
    });
  }

  bool validateAddress(String address) {
    final rustFunction = _lib.lookup<NativeFunction<WalletValidateAddressRust>>(
        'wallet_validate_address');
    final dartFunction = rustFunction.asFunction<WalletValidateAddressDart>();

    return dartFunction(
                Pointer.fromAddress(_self.address), address.toNativeUtf8()) ==
            1
        ? true
        : false;
  }

  static String signOffline(String psbt, String externalDescriptor,
      String internalDescriptor, bool testnet) {
    var lib = NativeLibrary(load(_libName));

    return lib
        .wallet_sign_offline(
            psbt.toNativeUtf8().cast(),
            externalDescriptor.toNativeUtf8().cast(),
            internalDescriptor.toNativeUtf8().cast(),
            testnet ? Network.Testnet.index : Network.Mainnet.index)
        .raw_tx
        .cast<Utf8>()
        .toDartString();
  }

  static String generateSeed({bool testnet = false}) {
    final lib = load(_libName);

    final rustFunction = lib
        .lookup<NativeFunction<WalletGenerateSeedRust>>('wallet_generate_seed');
    final dartFunction = rustFunction.asFunction<WalletGenerateSeedDart>();

    NativeSeed seed =
        dartFunction(testnet ? Network.Testnet.index : Network.Mainnet.index);

    final words = seed.mnemonic.cast<Utf8>().toDartString();
    return words;
  }

  static Wallet deriveWallet(
      String seed, String path, String directory, Network network,
      {String? passphrase, bool privateKey = false, bool initWallet = true}) {
    final lib = load(_libName);
    final native = NativeLibrary(lib);
    var wallet = native.wallet_derive(
        seed.toNativeUtf8().cast(),
        passphrase != null ? passphrase.toNativeUtf8().cast() : nullptr,
        path.toNativeUtf8().cast(),
        network.index,
        initWallet,
        directory.toNativeUtf8().cast(),
        privateKey);

    if (wallet.name == nullptr) {
      throwRustException(lib);
    }

    final name = wallet.name.cast<Utf8>().toDartString();

    final externalDescriptor = privateKey
        ? wallet.external_prv_descriptor.cast<Utf8>().toDartString()
        : wallet.external_pub_descriptor.cast<Utf8>().toDartString();

    final internalDescriptor = privateKey
        ? wallet.internal_prv_descriptor.cast<Utf8>().toDartString()
        : wallet.internal_pub_descriptor.cast<Utf8>().toDartString();

    final publicExternalDescriptor = privateKey
        ? wallet.external_pub_descriptor.cast<Utf8>().toDartString()
        : null;
    final publicInternalDescriptor = privateKey
        ? wallet.internal_pub_descriptor.cast<Utf8>().toDartString()
        : null;

    return Wallet.fromPointer(name, network, externalDescriptor,
        internalDescriptor, wallet.bkd_wallet_ptr.cast(),
        hot: privateKey,
        hasPassphrase: passphrase != null,
        publicExternalDescriptor: publicExternalDescriptor,
        publicInternalDescriptor: publicInternalDescriptor,
        lib: lib);
  }

  static String getSeedWords(List<int> binarySeed) {
    final lib = load(_libName);

    final rustFunction = lib.lookup<NativeFunction<WalletGetSeedWordsRust>>(
        'wallet_get_seed_words');
    final dartFunction = rustFunction.asFunction<WalletGetSeedWordsDart>();

    final Pointer<Uint8> messagePointer = malloc.allocate<Uint8>(32);
    final pointerList = messagePointer.asTypedList(32);
    pointerList.setAll(0, binarySeed);

    NativeSeed seed = dartFunction(messagePointer);

    final xprv = seed.xprv.cast<Utf8>().toDartString();
    return xprv;
  }

  static String getXpubDescKey(String xprv, String path) {
    final lib = load(_libName);

    final rustFunction = lib.lookup<NativeFunction<WalletGetXpubDescKeyRust>>(
        'wallet_get_xpub_desc_key');
    final dartFunction = rustFunction.asFunction<WalletGetXpubDescKeyDart>();

    return dartFunction(xprv.toNativeUtf8(), path.toNativeUtf8())
        .cast<Utf8>()
        .toDartString();
  }

  static String generateXKeyWithEntropy(Uint8List entropy) {
    final lib = load(_libName);

    final rustFunction =
        lib.lookup<NativeFunction<WalletGenerateSeedWithEntropyRust>>(
            'wallet_generate_xkey_with_entropy');
    final dartFunction =
        rustFunction.asFunction<WalletGenerateSeedWithEntropyDart>();

    final Pointer<Uint8> messagePointer = malloc.allocate<Uint8>(32);
    final pointerList = messagePointer.asTypedList(32);
    pointerList.setAll(0, entropy);

    String seed = dartFunction(messagePointer).cast<Utf8>().toDartString();

    malloc.free(messagePointer);
    return seed;
  }

  Future<String> signPsbt(String psbt) async {
    final rustFunction =
        _lib.lookup<NativeFunction<WalletSignPsbtRust>>('wallet_sign_psbt');
    final dartFunction = rustFunction.asFunction<WalletSignPsbtDart>();

    return Future(() =>
        dartFunction(_self, psbt.toNativeUtf8()).cast<Utf8>().toDartString());
  }
}
