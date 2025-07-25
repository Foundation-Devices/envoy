// This file is automatically generated, so please do not edit it.
// @generated by `flutter_rust_bridge`@ 2.9.0.

// ignore_for_file: invalid_use_of_internal_member, unused_import, unnecessary_import

import '../frb_generated.dart';
import '../lib.dart';
import '../third_party/ngwallet/config.dart';
import '../third_party/ngwallet/send.dart';
import '../third_party/ngwallet/transaction.dart';
import 'envoy_account.dart';
import 'errors.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

// These functions are ignored because they are not marked as `pub`: `bdk_db_path`, `get_descriptor`, `get_descriptors`
// These function are ignored because they are on traits that is not defined in current crate (put an empty `#[frb]` on it to unignore): `clone`, `clone`, `fmt`

Future<ServerFeatures> getServerFeatures(
        {required String server, String? proxy}) =>
    RustLib.instance.api
        .crateApiEnvoyWalletGetServerFeatures(server: server, proxy: proxy);

// Rust type: RustOpaqueMoi<flutter_rust_bridge::for_generated::RustAutoOpaqueInner<Arc < Mutex < Option < FullScanRequest < KeychainKind > > > >>>
abstract class FullScanRequest implements RustOpaqueInterface {}

// Rust type: RustOpaqueMoi<flutter_rust_bridge::for_generated::RustAutoOpaqueInner<Arc < Mutex < Option < SyncRequest < (KeychainKind , u32) > > > >>>
abstract class SyncRequest implements RustOpaqueInterface {}

// Rust type: RustOpaqueMoi<flutter_rust_bridge::for_generated::RustAutoOpaqueInner<Arc < Mutex < Update > >>>
abstract class WalletUpdate implements RustOpaqueInterface {}

// Rust type: RustOpaqueMoi<flutter_rust_bridge::for_generated::RustAutoOpaqueInner<EnvoyAccountHandler>>
abstract class EnvoyAccountHandler implements RustOpaqueInterface {
  static Future<EnvoyAccountHandler> addAccountFromConfig(
          {required NgAccountConfig config, required String dbPath}) =>
      RustLib.instance.api
          .crateApiEnvoyWalletEnvoyAccountHandlerAddAccountFromConfig(
              config: config, dbPath: dbPath);

  Future<void> addDescriptor({required NgDescriptor ngDescriptor});

  Future<void> applyUpdate(
      {required WalletUpdate update, required AddressType addressType});

  ArcMutexNgAccountConnection get ngAccount;

  RustStreamSink<EnvoyAccount>? get streamSink;

  set ngAccount(ArcMutexNgAccountConnection ngAccount);

  set streamSink(RustStreamSink<EnvoyAccount>? streamSink);

  BigInt balance();

  static Future<String> broadcast(
          {required DraftTransaction draftTransaction,
          required String electrumServer,
          int? torPort}) =>
      RustLib.instance.api.crateApiEnvoyWalletEnvoyAccountHandlerBroadcast(
          draftTransaction: draftTransaction,
          electrumServer: electrumServer,
          torPort: torPort);

  Future<DraftTransaction> composeCancellationTx(
      {required BitcoinTransaction bitcoinTransaction});

  Future<DraftTransaction> composePsbt(
      {required TransactionParams transactionParams});

  Future<DraftTransaction> composeRbfPsbt(
      {required List<Output> selectedOutputs,
      required BigInt feeRate,
      required BitcoinTransaction bitcoinTransaction,
      String? note,
      String? tag});

  NgAccountConfig config();

  static Future<DraftTransaction> decodePsbt(
          {required DraftTransaction draftTransaction,
          required List<int> psbt}) =>
      RustLib.instance.api.crateApiEnvoyWalletEnvoyAccountHandlerDecodePsbt(
          draftTransaction: draftTransaction, psbt: psbt);

  static Future<EnvoyAccountHandler> fromConfig(
          {required String dbPath, required NgAccountConfig config}) =>
      RustLib.instance.api.crateApiEnvoyWalletEnvoyAccountHandlerFromConfig(
          dbPath: dbPath, config: config);

  Future<String> getAccountBackup();

  static NgAccountConfig getConfigFromBackup({required String backupJson}) =>
      RustLib.instance.api
          .crateApiEnvoyWalletEnvoyAccountHandlerGetConfigFromBackup(
              backupJson: backupJson);

  static Future<NgAccountConfig> getConfigFromRemote(
          {required List<int> remoteUpdate}) =>
      RustLib.instance.api
          .crateApiEnvoyWalletEnvoyAccountHandlerGetConfigFromRemote(
              remoteUpdate: remoteUpdate);

  Future<TransactionFeeResult> getMaxBumpFeeRates(
      {required List<Output> selectedOutputs,
      required BitcoinTransaction bitcoinTransaction});

  Future<TransactionFeeResult> getMaxFee(
      {required TransactionParams transactionParams});

  String id();

  bool isHot();

  static Future<EnvoyAccountHandler> migrate(
          {required String name,
          required String id,
          String? deviceSerial,
          String? dateAdded,
          required AddressType addressType,
          required String color,
          required int index,
          required List<NgDescriptor> descriptors,
          required String dbPath,
          required List<String> legacySledDbPath,
          required Network network}) =>
      RustLib.instance.api.crateApiEnvoyWalletEnvoyAccountHandlerMigrate(
          name: name,
          id: id,
          deviceSerial: deviceSerial,
          dateAdded: dateAdded,
          addressType: addressType,
          color: color,
          index: index,
          descriptors: descriptors,
          dbPath: dbPath,
          legacySledDbPath: legacySledDbPath,
          network: network);

  Future<void> migrateMeta(
      {required Map<String, String> notes,
      required Map<String, String> tags,
      required Map<String, bool> doNotSpend});

  static Future<EnvoyAccountHandler> newFromDescriptor(
          {required String name,
          String? deviceSerial,
          String? dateAdded,
          required AddressType addressType,
          required String color,
          required int index,
          required List<NgDescriptor> descriptors,
          required String dbPath,
          required Network network,
          required String id}) =>
      RustLib.instance.api
          .crateApiEnvoyWalletEnvoyAccountHandlerNewFromDescriptor(
              name: name,
              deviceSerial: deviceSerial,
              dateAdded: dateAdded,
              addressType: addressType,
              color: color,
              index: index,
              descriptors: descriptors,
              dbPath: dbPath,
              network: network,
              id: id);

  Future<List<(String, AddressType)>> nextAddress();

  static Future<EnvoyAccountHandler> openAccount({required String dbPath}) =>
      RustLib.instance.api
          .crateApiEnvoyWalletEnvoyAccountHandlerOpenAccount(dbPath: dbPath);

  Future<void> renameAccount({required String name});

  Future<void> renameTag({required String existingTag, String? newTag});

  Future<FullScanRequest> requestFullScan({required AddressType addressType});

  static Future<EnvoyAccountHandler> restoreFromBackup(
          {required String backupJson,
          required String dbPath,
          String? seed,
          String? passphrase}) =>
      RustLib.instance.api
          .crateApiEnvoyWalletEnvoyAccountHandlerRestoreFromBackup(
              backupJson: backupJson,
              dbPath: dbPath,
              seed: seed,
              passphrase: passphrase);

  static Future<WalletUpdate> scanWallet(
          {required FullScanRequest scanRequest,
          required String electrumServer,
          int? torPort}) =>
      RustLib.instance.api.crateApiEnvoyWalletEnvoyAccountHandlerScanWallet(
          scanRequest: scanRequest,
          electrumServer: electrumServer,
          torPort: torPort);

  Future<void> sendUpdate();

  Future<void> setDoNotSpend({required Output utxo, required bool doNotSpend});

  Future<void> setDoNotSpendMultiple(
      {required List<String> utxo, required bool doNotSpend});

  Future<bool> setNote({required String txId, required String note});

  Future<void> setPreferredAddressType({required AddressType addressType});

  Future<bool> setTag({required Output utxo, required String tag});

  Future<void> setTagMultiple(
      {required List<String> utxo, required String tag});

  Future<bool> setTags({required List<Output> utxo, required String tag});

  Future<EnvoyAccount> state();

  Stream<EnvoyAccount> stream();

  Future<SyncRequest> syncRequest({required AddressType addressType});

  static Future<WalletUpdate> syncWallet(
          {required SyncRequest syncRequest,
          required String electrumServer,
          int? torPort}) =>
      RustLib.instance.api.crateApiEnvoyWalletEnvoyAccountHandlerSyncWallet(
          syncRequest: syncRequest,
          electrumServer: electrumServer,
          torPort: torPort);

  Future<List<BitcoinTransaction>> transactions();

  Future<void> updateBroadcastState(
      {required DraftTransaction draftTransaction});

  Future<List<Output>> utxo();

  static Future<bool> validateAddress(
          {required String address, Network? network}) =>
      RustLib.instance.api
          .crateApiEnvoyWalletEnvoyAccountHandlerValidateAddress(
              address: address, network: network);
}

enum Network {
  /// Mainnet Bitcoin.
  bitcoin,

  /// Bitcoin's testnet network. (In future versions this will be combined
  /// into a single variant containing the version)
  testnet,

  /// Bitcoin's testnet4 network. (In future versions this will be combined
  /// into a single variant containing the version)
  testnet4,

  /// Bitcoin's signet network.
  signet,

  /// Bitcoin's regtest network.
  regtest,
  ;
}

class ServerFeatures {
  final String? serverVersion;
  final Uint8List? genesisHash;
  final String? protocolMin;
  final String? protocolMax;
  final String? hashFunction;
  final PlatformInt64? pruning;

  const ServerFeatures({
    this.serverVersion,
    this.genesisHash,
    this.protocolMin,
    this.protocolMax,
    this.hashFunction,
    this.pruning,
  });

  @override
  int get hashCode =>
      serverVersion.hashCode ^
      genesisHash.hashCode ^
      protocolMin.hashCode ^
      protocolMax.hashCode ^
      hashFunction.hashCode ^
      pruning.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServerFeatures &&
          runtimeType == other.runtimeType &&
          serverVersion == other.serverVersion &&
          genesisHash == other.genesisHash &&
          protocolMin == other.protocolMin &&
          protocolMax == other.protocolMax &&
          hashFunction == other.hashFunction &&
          pruning == other.pruning;
}
