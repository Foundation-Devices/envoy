// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';

import 'package:collection/collection.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wallet/exceptions.dart';
import 'package:wallet/generated_bindings.dart' as rust;
import 'package:wallet/generated_bindings.dart';

// Generated
part 'wallet.freezed.dart';

part 'wallet.g.dart';

const dustAmount = 546;

enum Network { Mainnet, Testnet, Signet, Regtest }

enum TransactionType { normal, azteco, pending, btcPay, ramp }

enum WalletType { witnessPublicKeyHash, taproot, superWallet }

/// Sort transactions by time and ancestry
extension AncestralSort on List<Transaction> {
  void ancestralSort() {
    for (var end = this.length - 1; end > 0; end--) {
      var swapped = false;
      for (var current = 0; current < end; current++) {
        if (this[current].compareTo(this[current + 1]) > 0) {
          this.swap(current, current + 1);
          swapped = true;
        }

        if (this[current].compareTo(this[current + 1]) < 0) {
          this.swap(current + 1, current);
          swapped = true;
        }
      }

      if (!swapped) return;
    }
  }
}

@JsonSerializable()
class Transaction extends Comparable {
  final String memo;
  final String txId;
  final DateTime date;
  final int fee;
  final int sent;
  final int received;
  final int blockHeight;
  final List<String>? outputs;
  final List<String>? inputs;
  final TransactionType type;
  final String? address;
  final int? vsize;
  // Variables below are used for pending Ramp/BtcPay transactions.
  String? pullPaymentId;
  final String? purchaseViewToken;
  final String? currencyAmount;
  final String? currency;

  get isConfirmed {
    /// if the tx is a pending transaction, the date will be based on the time the tx was created
    /// The tx date is sometimes shows proper date even though it is not confirmed
    if (DateTime.now().millisecondsSinceEpoch - date.millisecondsSinceEpoch <
        15000) {
      return false;
    }
    return date.compareTo(DateTime(2008)) > 0;
  }

  int get amount => received - sent;

  Transaction(
    this.memo,
    this.txId,
    this.date,
    this.fee,
    this.received,
    this.sent,
    this.blockHeight,
    this.address, {
    this.type = TransactionType.normal,
    this.outputs,
    this.inputs,
    this.vsize,
    this.pullPaymentId,
    this.purchaseViewToken,
    this.currencyAmount,
    this.currency,
  });

  // Serialisation
  factory Transaction.fromJson(Map<String, dynamic> json) =>
      _$TransactionFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionToJson(this);

  @override
  int compareTo(other) {
    // Mempool transactions go on top
    if ((date.isBefore(DateTime(2008)) &&
            other.date.isBefore(DateTime(2008))) ||
        (blockHeight == other.blockHeight)) {
      if (other.inputs == null) {
        return 1;
      }

      if (inputs == null) {
        return -1;
      }

      // Transactions whose input is other's txid go above that transaction
      if (other.inputs!.contains(txId)) {
        return 1;
      }

      if (inputs!.contains(other.txId)) {
        return -1;
      }

      return 0;
    }

    if (other.date.isBefore(DateTime(2008))) {
      return 1;
    }

    if (date.isBefore(DateTime(2008))) {
      return -1;
    }

    return other.date.compareTo(date);
  }

  void setPullPaymentId(String? newPullPaymentId) {
    pullPaymentId = newPullPaymentId;
  }
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
  @Uint8()
  external int outputsLen;
  external Pointer<Pointer<Uint8>> outputs;
  @Uint8()
  external int inputsLen;
  external Pointer<Pointer<Uint8>> inputs;
  external Pointer<Uint8> address;
  @Size()
  external int vsize;
}

class NativeSeed extends Struct {
  external Pointer<Uint8> mnemonic;
  external Pointer<Uint8> xprv;
  external Pointer<Uint8> fingerprint;
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

typedef WalletBroadcastTxRust = Pointer<Utf8> Function(
    Pointer<Utf8> electrumAddress, Int32 torPort, Pointer<Utf8> tx);
typedef WalletBroadcastTxDart = Pointer<Utf8> Function(
    Pointer<Utf8> electrumAddress, int torPort, Pointer<Utf8> tx);

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

  factory Psbt.fromNative(rust.Psbt psbt) {
    return Psbt(
        psbt.sent,
        psbt.received,
        psbt.fee,
        psbt.base64.cast<Utf8>().toDartString(),
        psbt.txid.cast<Utf8>().toDartString(),
        psbt.raw_tx.cast<Utf8>().toDartString());
  }
}

class RawTransaction {
  final int version;
  final List<RawTransactionOutput> outputs;
  final List<RawTransactionInput> inputs;

  RawTransaction(this.version, this.outputs, this.inputs);

  factory RawTransaction.fromNative(rust.RawTransaction tx) {
    List<RawTransactionOutput> outputs = [];
    List<RawTransactionInput> inputs = [];

    for (var i = 0; i < tx.outputs_len; i++) {
      rust.RawTransactionOutput nativeOutput = (tx.outputs + i).ref;
      outputs.add(RawTransactionOutput(
          address: nativeOutput.address.cast<Utf8>().toDartString(),
          amount: nativeOutput.amount,
          path: TxOutputPath.values[nativeOutput.path]));
    }

    for (var i = 0; i < tx.inputs_len; i++) {
      rust.RawTransactionInput nativeInput = (tx.inputs + i).ref;
      inputs.add(RawTransactionInput(
          previousOutputHash:
              nativeInput.previous_output.cast<Utf8>().toDartString(),
          previousOutputIndex: nativeInput.previous_output_index));
    }

    return RawTransaction(tx.version, outputs, inputs);
  }
}

class RawTransactionInput {
  final int previousOutputIndex;
  final String previousOutputHash;

  RawTransactionInput(
      {required this.previousOutputIndex, required this.previousOutputHash});

  String get id => "$previousOutputHash:$previousOutputIndex";
}

/// enum positions matters, this will be mapped to [OutputPath]
enum TxOutputPath {
  External,
  Internal,
  NotMine,
}

class RawTransactionOutput {
  final int amount;
  final String address;
  final TxOutputPath path;

  RawTransactionOutput(
      {required this.amount,
      required this.address,
      this.path = TxOutputPath.NotMine});
}

@freezed
class Utxo with _$Utxo {
  const factory Utxo({
    required String txid,
    required int vout,
    required int value,
  }) = _Utxo;

  factory Utxo.fromJson(Map<String, Object?> json) => _$UtxoFromJson(json);
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

// Dummy placeholder wallet for greying out
class GhostWallet extends Wallet {
  GhostWallet() : super("", Network.Mainnet, "", "", hot: true);
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
      defaultValue: WalletType
          .witnessPublicKeyHash) // Migration from time when all the Wallets were wpkh
  final WalletType type;

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
  @JsonKey(defaultValue: []) // Migration from before UTXOs
  List<Utxo> utxos = [];
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
    String electrumAddress = args["server_address"];
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
    var utxos = _getUtxos(walletPtr);

    return {
      "balance": balance,
      "feeRateFast": feeRateFast,
      "feeRateSlow": feeRateSlow,
      "transactions": transactions,
      "utxos": utxos
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

  static String _getChangeAddress(int walletAddress) {
    var lib = rust.NativeLibrary(load(_libName));
    return lib
        .wallet_get_change_address(Pointer.fromAddress(walletAddress))
        .cast<Utf8>()
        .toDartString();
  }

  Wallet(
      this.name, this.network, this.externalDescriptor, this.internalDescriptor,
      {this.hot = false,
      this.hasPassphrase = false,
      this.publicExternalDescriptor = null,
      this.publicInternalDescriptor = null,
      this.type = WalletType.witnessPublicKeyHash});

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
      this.type = WalletType.witnessPublicKeyHash,
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

  Future<String> getChangeAddress() async {
    return compute(_getChangeAddress, _self.address);
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
    map['server_address'] = electrumAddress;
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
      utxos = walletState["utxos"];

      // Don't update fees if they error out
      if (walletState["feeRateFast"] >= 0) {
        feeRateFast = walletState["feeRateFast"];
      }

      if (walletState["feeRateSlow"] >= 0) {
        feeRateSlow = walletState["feeRateSlow"];
      }

      return changed;
    });
  }

  static Pointer<rust.UtxoList> _createUtxoListPointer(List<Utxo>? utxos) {
    final listPointer = calloc<rust.UtxoList>(1);
    final len = utxos?.length ?? 0;

    listPointer.ref.utxos_len = len;
    listPointer.ref.utxos = calloc<rust.Utxo>(len);

    utxos?.forEachIndexed((index, utxo) {
      (listPointer.ref.utxos + index).ref.value = utxo.value;
      (listPointer.ref.utxos + index).ref.vout = utxo.vout;
      (listPointer.ref.utxos + index).ref.txid =
          utxo.txid.toNativeUtf8().cast();
    });

    return listPointer;
  }

  Future<int> getMaxFeeRate(String sendTo, int amount,
      {List<Utxo>? mustSpendUtxos, List<Utxo>? dontSpendUtxos}) async {
    final walletAddress = _self.address;

    return Isolate.run(() {
      final lib = load(_libName);
      final native = rust.NativeLibrary(lib);

      Pointer<rust.UtxoList> mustSpendUtxoList =
          _createUtxoListPointer(mustSpendUtxos);
      Pointer<rust.UtxoList> dontSpendUtxoList =
          _createUtxoListPointer(dontSpendUtxos);

      final maxFeeRate = native
          .wallet_get_max_feerate(
              Pointer.fromAddress(walletAddress),
              sendTo.toNativeUtf8() as Pointer<Char>,
              amount,
              mustSpendUtxoList,
              dontSpendUtxoList)
          .toInt();

      calloc.free(mustSpendUtxoList);
      calloc.free(dontSpendUtxoList);

      if (maxFeeRate == 0) {
        throwRustException(lib);
      }

      return maxFeeRate;
    });
  }

  Future<Psbt> createPsbt(String sendTo, int amount, double feeRate,
      {required List<Utxo>? mustSpendUtxos,
      required List<Utxo>? dontSpendUtxos}) async {
    final walletAddress = _self.address;

    return Isolate.run(() {
      DynamicLibrary library = load(_libName);
      final lib = rust.NativeLibrary(library);

      Pointer<rust.UtxoList> mustSpendUtxoList =
          _createUtxoListPointer(mustSpendUtxos);
      Pointer<rust.UtxoList> dontSpendUtxoList =
          _createUtxoListPointer(dontSpendUtxos);

      rust.Psbt psbt = lib.wallet_create_psbt(
          Pointer.fromAddress(walletAddress),
          sendTo.toNativeUtf8() as Pointer<Char>,
          amount,
          feeRate,
          mustSpendUtxoList,
          dontSpendUtxoList);

      if (psbt.base64 == nullptr) {
        throwRustException(library);
      }

      calloc.free(mustSpendUtxoList);
      calloc.free(dontSpendUtxoList);

      return Psbt.fromNative(psbt);
    });
  }

  Future<Psbt> decodePsbt(String base64Psbt) async {
    final walletAddress = _self.address;

    return Isolate.run(() {
      final lib = load(_libName);
      final native = rust.NativeLibrary(lib);

      rust.Psbt psbt = native.wallet_decode_psbt(
          Pointer.fromAddress(walletAddress),
          base64Psbt.toNativeUtf8() as Pointer<Char>);

      if (psbt.base64 == nullptr) {
        throwRustException(lib);
      }

      return Psbt.fromNative(psbt);
    });
  }

  Future<Psbt> getBumpedPSBT(
      String txId, double feeRate, List<Utxo>? doNotSpend) async {
    final walletAddress = _self.address;

    return Isolate.run(() {
      final lib = load(_libName);
      Pointer<rust.UtxoList> doNotSpendPointer =
          _createUtxoListPointer(doNotSpend);
      final native = rust.NativeLibrary(lib);

      rust.Psbt psbt = native.wallet_get_bumped_psbt(
          Pointer.fromAddress(walletAddress),
          txId.toNativeUtf8() as Pointer<Char>,
          feeRate,
          doNotSpendPointer);

      if (psbt.base64 == nullptr) {
        throwRustException(lib);
      }

      return Psbt.fromNative(psbt);
    });
  }

  ///Decode raw transaction
  Future<RawTransaction> decodeWalletRawTx(
      String rawTransaction, Network network) async {
    final walletAddress = _self.address;

    return Isolate.run(() {
      final dynlib = load(_libName);
      final lib = rust.NativeLibrary(dynlib);

      rust.RawTransaction rawTx = lib.wallet_decode_raw_tx(
          rawTransaction.toNativeUtf8() as Pointer<Char>,
          network.index,
          Pointer.fromAddress(walletAddress));

      if (rawTx.version == -1) {
        throwRustException(dynlib);
      }

      return RawTransaction.fromNative(rawTx);
    });
  }

  Future<RBFfeeRates> getBumpedPSBTMaxFeeRate(
      String txId, List<Utxo>? doNotSpend) async {
    final walletAddress = _self.address;
    return Isolate.run(() {
      final lib = load(_libName);
      Pointer<rust.UtxoList> doNotSpendPointer =
          _createUtxoListPointer(doNotSpend);
      final native = rust.NativeLibrary(lib);
      RBFfeeRates feeRates = native.wallet_get_max_bumped_fee_rate(
          Pointer.fromAddress(walletAddress),
          txId.toNativeUtf8() as Pointer<Char>,
          doNotSpendPointer);
      if (kDebugMode) {
        print(
            "Fee rate min: ${feeRates.min_fee_rate} \n Fee rate max: ${feeRates.max_fee_rate}");
      }
      if (feeRates.min_fee_rate <= 1) {
        if (feeRates.min_fee_rate == -1.1) {
          throw Exception("Transaction cannot be boosted");
        }
        if (feeRates.min_fee_rate == -1.6) {
          throw Exception("Unlock coin to boost transaction");
        }
        if (feeRates.min_fee_rate == -1.2) {
          throw Exception("Insufficient balance to boost transaction");
        }
        if (feeRates.min_fee_rate == -1.5) {
          throw Exception("Unable to boost transaction");
        }
        if (feeRates.max_fee_rate == 0.404) {
          throw Exception("Transaction not found");
        }
        throwRustException(lib);
      }
      return feeRates;
    });
  }

  static Future<RawTransaction> decodeRawTx(
      String rawTransaction, Network network) async {
    return Isolate.run(() {
      final dynlib = load(_libName);
      final lib = rust.NativeLibrary(dynlib);

      rust.RawTransaction rawTx = lib.wallet_decode_raw_tx(
          rawTransaction.toNativeUtf8() as Pointer<Char>,
          network.index,
          nullptr);

      if (rawTx.version == -1) {
        throwRustException(dynlib);
      }

      return RawTransaction.fromNative(rawTx);
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
    map['server_address'] = electrumAddress;
    map['tor_port'] = torPort;

    return compute(_getServerFeatures, map).then((var features) => features,
        onError: (e) {
      throw e;
    });
  }

  static Future<ElectrumServerFeatures> _getServerFeatures(Map args) async {
    DynamicLibrary lib = load(_libName);

    String electrumAddress = args["server_address"];
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

  static List<Utxo> _getUtxos(int walletAddress) {
    final lib = rust.NativeLibrary(load(_libName));

    rust.UtxoList utxoList =
        lib.wallet_get_utxos(Pointer.fromAddress(walletAddress));

    List<Utxo> utxos = [];
    for (var i = 0; i < utxoList.utxos_len; i++) {
      rust.Utxo nativeUtxo = (utxoList.utxos + i).ref;
      utxos.add(Utxo(
          txid: nativeUtxo.txid.cast<Utf8>().toDartString(),
          vout: nativeUtxo.vout,
          value: nativeUtxo.value));
    }

    return utxos;
  }

  static List<Transaction> _getTransactions(int walletAddress) {
    DynamicLibrary lib = load(_libName);

    final rustFunction = lib.lookup<NativeFunction<WalletGetTransactionsRust>>(
        'wallet_get_transactions');
    final dartFunction = rustFunction.asFunction<WalletGetTransactionsDart>();

    NativeTransactionList txList =
        dartFunction(Pointer.fromAddress(walletAddress));

    if (txList.transactions == nullptr) {
      throwRustException(lib);
    }

    List<Transaction> transactions = [];
    for (var i = 0; i < txList.transactionsLen; i++) {
      var tx = (txList.transactions + i).ref;
      transactions.add(Transaction(
          "",
          tx.txid.cast<Utf8>().toDartString(),
          DateTime.fromMillisecondsSinceEpoch(tx.confirmationTime * 1000),
          tx.fee,
          tx.received,
          tx.sent,
          tx.confirmationHeight,
          tx.address.cast<Utf8>().toDartString(),
          outputs: _extractStringList(tx.outputs, tx.outputsLen),
          inputs: _extractStringList(tx.inputs, tx.inputsLen),
          vsize: tx.vsize));
    }

    return transactions;
  }

  static List<String> _extractStringList(
      Pointer<Pointer<Uint8>> strings, int stringsLen) {
    List<String> ret = [];
    for (var i = 0; i < stringsLen; i++) {
      ret.add((strings + i).value.cast<Utf8>().toDartString());
    }

    return ret;
  }

  Future<String> broadcastTx(
      String electrumAddress, int torPort, String tx) async {
    Future<String> _broadcastTx(Map params) async {
      DynamicLibrary lib = load(_libName);

      int _torPort = params['port'];
      String _tx = params['tx'];

      final rustFunction = lib
          .lookup<NativeFunction<WalletBroadcastTxRust>>('wallet_broadcast_tx');
      final dartFunction = rustFunction.asFunction<WalletBroadcastTxDart>();
      var txid = dartFunction(
              electrumAddress.toNativeUtf8(), _torPort, _tx.toNativeUtf8())
          .cast<Utf8>()
          .toDartString();

      if (txid.isEmpty) {
        throwRustException(lib);
      }
      return txid;
    }

    return compute(_broadcastTx, {"tx": tx, "port": torPort});
  }

  Future<bool> validateAddress(String address) {
    int walletPointer = _self.address;

    return Isolate.run(() async {
      var lib = load(_libName);

      final rustFunction =
          lib.lookup<NativeFunction<WalletValidateAddressRust>>(
              'wallet_validate_address');

      final dartFunction = rustFunction.asFunction<WalletValidateAddressDart>();

      return dartFunction(
              Pointer.fromAddress(walletPointer), address.toNativeUtf8()) ==
          1;
    });
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

  static bool validateSeed(String seed) {
    final native = NativeLibrary(load(_libName));
    return native.wallet_validate_seed(seed.toNativeUtf8().cast());
  }

  static Wallet deriveWallet(
      String seed, String path, String directory, Network network,
      {String? passphrase,
      bool privateKey = false,
      bool initWallet = true,
      required WalletType type}) {
    final lib = load(_libName);
    final native = rust.NativeLibrary(lib);
    var wallet = native.wallet_derive(
        seed.toNativeUtf8().cast(),
        passphrase != null ? passphrase.toNativeUtf8().cast() : nullptr,
        path.toNativeUtf8().cast(),
        network.index,
        initWallet,
        directory.toNativeUtf8().cast(),
        privateKey,
        type.index);

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
        lib: lib,
        type: type);
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

  Future<Psbt> cancelTx(
      String txId, List<Utxo>? doNotSpend, double feeRate) async {
    final walletAddress = _self.address;

    return Isolate.run(() {
      final lib = load(_libName);
      Pointer<rust.UtxoList> doNotSpendPointer =
          _createUtxoListPointer(doNotSpend);
      final native = rust.NativeLibrary(lib);

      rust.Psbt psbt = native.wallet_cancel_tx(
          Pointer.fromAddress(walletAddress),
          txId.toNativeUtf8() as Pointer<Char>,
          //feeRate,
          doNotSpendPointer);

      if (psbt.base64 == nullptr) {
        if (psbt.sent == 1) {
          throw Exception("Unlock coins to cancel transaction");
        }
        throwRustException(lib);
      }
      return Psbt.fromNative(psbt);
    });
  }

  Future<String> getRawTxFromTxId(String txId) {
    final walletAddress = _self.address;

    return Isolate.run(() {
      final lib = load(_libName);

      final native = rust.NativeLibrary(lib);

      final rawHex = native.wallet_get_raw_tx_from_txid(
          Pointer.fromAddress(walletAddress),
          txId.toNativeUtf8() as Pointer<Char>);

      if (rawHex == nullptr) {
        throwRustException(lib);
      }
      return rawHex.cast<Utf8>().toDartString();
    });
  }
}
