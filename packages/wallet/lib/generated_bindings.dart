// AUTO GENERATED FILE, DO NOT EDIT.
//
// Generated by `package:ffigen`.
import 'dart:ffi' as ffi;

class NativeLibrary {
  /// Holds the symbol lookup function.
  final ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
      _lookup;

  /// The symbols are looked up in [dynamicLibrary].
  NativeLibrary(ffi.DynamicLibrary dynamicLibrary)
      : _lookup = dynamicLibrary.lookup;

  /// The symbols are looked up with [lookup].
  NativeLibrary.fromLookup(
      ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
          lookup)
      : _lookup = lookup;

  ffi.Pointer<ffi.Char> wallet_last_error_message() {
    return _wallet_last_error_message();
  }

  late final _wallet_last_error_messagePtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<ffi.Char> Function()>>(
          'wallet_last_error_message');
  late final _wallet_last_error_message = _wallet_last_error_messagePtr
      .asFunction<ffi.Pointer<ffi.Char> Function()>();

  ffi.Pointer<ffi.Char> wallet_init(
    ffi.Pointer<ffi.Char> name,
    ffi.Pointer<ffi.Char> external_descriptor,
    ffi.Pointer<ffi.Char> internal_descriptor,
    ffi.Pointer<ffi.Char> data_dir,
    int network,
  ) {
    return _wallet_init(
      name,
      external_descriptor,
      internal_descriptor,
      data_dir,
      network,
    );
  }

  late final _wallet_initPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<ffi.Char> Function(
              ffi.Pointer<ffi.Char>,
              ffi.Pointer<ffi.Char>,
              ffi.Pointer<ffi.Char>,
              ffi.Pointer<ffi.Char>,
              ffi.Int32)>>('wallet_init');
  late final _wallet_init = _wallet_initPtr.asFunction<
      ffi.Pointer<ffi.Char> Function(
          ffi.Pointer<ffi.Char>,
          ffi.Pointer<ffi.Char>,
          ffi.Pointer<ffi.Char>,
          ffi.Pointer<ffi.Char>,
          int)>();

  void wallet_drop(
    ffi.Pointer<ffi.Char> wallet,
  ) {
    return _wallet_drop(
      wallet,
    );
  }

  late final _wallet_dropPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<ffi.Char>)>>(
          'wallet_drop');
  late final _wallet_drop =
      _wallet_dropPtr.asFunction<void Function(ffi.Pointer<ffi.Char>)>();

  Wallet wallet_derive(
    ffi.Pointer<ffi.Char> seed_words,
    ffi.Pointer<ffi.Char> passphrase,
    ffi.Pointer<ffi.Char> path,
    int network,
    bool init_wallet,
    ffi.Pointer<ffi.Char> data_dir,
    bool private_,
    int wallet_type,
  ) {
    return _wallet_derive(
      seed_words,
      passphrase,
      path,
      network,
      init_wallet,
      data_dir,
      private_,
      wallet_type,
    );
  }

  late final _wallet_derivePtr = _lookup<
      ffi.NativeFunction<
          Wallet Function(
              ffi.Pointer<ffi.Char>,
              ffi.Pointer<ffi.Char>,
              ffi.Pointer<ffi.Char>,
              ffi.Int32,
              ffi.Bool,
              ffi.Pointer<ffi.Char>,
              ffi.Bool,
              ffi.Int32)>>('wallet_derive');
  late final _wallet_derive = _wallet_derivePtr.asFunction<
      Wallet Function(
          ffi.Pointer<ffi.Char>,
          ffi.Pointer<ffi.Char>,
          ffi.Pointer<ffi.Char>,
          int,
          bool,
          ffi.Pointer<ffi.Char>,
          bool,
          int)>();

  ffi.Pointer<ffi.Char> wallet_get_address(
    ffi.Pointer<ffi.Char> wallet,
  ) {
    return _wallet_get_address(
      wallet,
    );
  }

  late final _wallet_get_addressPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<ffi.Char> Function(
              ffi.Pointer<ffi.Char>)>>('wallet_get_address');
  late final _wallet_get_address = _wallet_get_addressPtr
      .asFunction<ffi.Pointer<ffi.Char> Function(ffi.Pointer<ffi.Char>)>();

  ffi.Pointer<ffi.Char> wallet_get_change_address(
    ffi.Pointer<ffi.Char> wallet,
  ) {
    return _wallet_get_change_address(
      wallet,
    );
  }

  late final _wallet_get_change_addressPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<ffi.Char> Function(
              ffi.Pointer<ffi.Char>)>>('wallet_get_change_address');
  late final _wallet_get_change_address = _wallet_get_change_addressPtr
      .asFunction<ffi.Pointer<ffi.Char> Function(ffi.Pointer<ffi.Char>)>();

  bool wallet_sync(
    ffi.Pointer<ffi.Char> wallet,
    ffi.Pointer<ffi.Char> electrum_address,
    int tor_port,
  ) {
    return _wallet_sync(
      wallet,
      electrum_address,
      tor_port,
    );
  }

  late final _wallet_syncPtr = _lookup<
      ffi.NativeFunction<
          ffi.Bool Function(ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>,
              ffi.Int32)>>('wallet_sync');
  late final _wallet_sync = _wallet_syncPtr.asFunction<
      bool Function(ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>, int)>();

  int wallet_get_balance(
    ffi.Pointer<ffi.Char> wallet,
  ) {
    return _wallet_get_balance(
      wallet,
    );
  }

  late final _wallet_get_balancePtr =
      _lookup<ffi.NativeFunction<ffi.Uint64 Function(ffi.Pointer<ffi.Char>)>>(
          'wallet_get_balance');
  late final _wallet_get_balance =
      _wallet_get_balancePtr.asFunction<int Function(ffi.Pointer<ffi.Char>)>();

  UtxoList wallet_get_utxos(
    ffi.Pointer<ffi.Char> wallet,
  ) {
    return _wallet_get_utxos(
      wallet,
    );
  }

  late final _wallet_get_utxosPtr =
      _lookup<ffi.NativeFunction<UtxoList Function(ffi.Pointer<ffi.Char>)>>(
          'wallet_get_utxos');
  late final _wallet_get_utxos = _wallet_get_utxosPtr
      .asFunction<UtxoList Function(ffi.Pointer<ffi.Char>)>();

  double wallet_get_fee_rate(
    ffi.Pointer<ffi.Char> electrum_address,
    int tor_port,
    int target,
  ) {
    return _wallet_get_fee_rate(
      electrum_address,
      tor_port,
      target,
    );
  }

  late final _wallet_get_fee_ratePtr = _lookup<
      ffi.NativeFunction<
          ffi.Double Function(ffi.Pointer<ffi.Char>, ffi.Int32,
              ffi.Uint16)>>('wallet_get_fee_rate');
  late final _wallet_get_fee_rate = _wallet_get_fee_ratePtr
      .asFunction<double Function(ffi.Pointer<ffi.Char>, int, int)>();

  ServerFeatures wallet_get_server_features(
    ffi.Pointer<ffi.Char> electrum_address,
    int tor_port,
  ) {
    return _wallet_get_server_features(
      electrum_address,
      tor_port,
    );
  }

  late final _wallet_get_server_featuresPtr = _lookup<
      ffi.NativeFunction<
          ServerFeatures Function(
              ffi.Pointer<ffi.Char>, ffi.Int32)>>('wallet_get_server_features');
  late final _wallet_get_server_features = _wallet_get_server_featuresPtr
      .asFunction<ServerFeatures Function(ffi.Pointer<ffi.Char>, int)>();

  TransactionList wallet_get_transactions(
    ffi.Pointer<ffi.Char> wallet,
  ) {
    return _wallet_get_transactions(
      wallet,
    );
  }

  late final _wallet_get_transactionsPtr = _lookup<
          ffi.NativeFunction<TransactionList Function(ffi.Pointer<ffi.Char>)>>(
      'wallet_get_transactions');
  late final _wallet_get_transactions = _wallet_get_transactionsPtr
      .asFunction<TransactionList Function(ffi.Pointer<ffi.Char>)>();

  double wallet_get_max_feerate(
    ffi.Pointer<ffi.Char> wallet,
    ffi.Pointer<ffi.Char> send_to,
    int amount,
    ffi.Pointer<UtxoList> must_spend,
    ffi.Pointer<UtxoList> dont_spend,
  ) {
    return _wallet_get_max_feerate(
      wallet,
      send_to,
      amount,
      must_spend,
      dont_spend,
    );
  }

  late final _wallet_get_max_feeratePtr = _lookup<
      ffi.NativeFunction<
          ffi.Double Function(
              ffi.Pointer<ffi.Char>,
              ffi.Pointer<ffi.Char>,
              ffi.Uint64,
              ffi.Pointer<UtxoList>,
              ffi.Pointer<UtxoList>)>>('wallet_get_max_feerate');
  late final _wallet_get_max_feerate = _wallet_get_max_feeratePtr.asFunction<
      double Function(ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>, int,
          ffi.Pointer<UtxoList>, ffi.Pointer<UtxoList>)>();

  Psbt wallet_create_psbt(
    ffi.Pointer<ffi.Char> wallet,
    ffi.Pointer<ffi.Char> send_to,
    int amount,
    double fee_rate,
    ffi.Pointer<UtxoList> must_spend,
    ffi.Pointer<UtxoList> dont_spend,
  ) {
    return _wallet_create_psbt(
      wallet,
      send_to,
      amount,
      fee_rate,
      must_spend,
      dont_spend,
    );
  }

  late final _wallet_create_psbtPtr = _lookup<
      ffi.NativeFunction<
          Psbt Function(
              ffi.Pointer<ffi.Char>,
              ffi.Pointer<ffi.Char>,
              ffi.Uint64,
              ffi.Double,
              ffi.Pointer<UtxoList>,
              ffi.Pointer<UtxoList>)>>('wallet_create_psbt');
  late final _wallet_create_psbt = _wallet_create_psbtPtr.asFunction<
      Psbt Function(ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>, int, double,
          ffi.Pointer<UtxoList>, ffi.Pointer<UtxoList>)>();

  Psbt wallet_decode_psbt(
    ffi.Pointer<ffi.Char> wallet,
    ffi.Pointer<ffi.Char> psbt,
  ) {
    return _wallet_decode_psbt(
      wallet,
      psbt,
    );
  }

  late final _wallet_decode_psbtPtr = _lookup<
      ffi.NativeFunction<
          Psbt Function(ffi.Pointer<ffi.Char>,
              ffi.Pointer<ffi.Char>)>>('wallet_decode_psbt');
  late final _wallet_decode_psbt = _wallet_decode_psbtPtr.asFunction<
      Psbt Function(ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>)>();

  RawTransaction wallet_decode_raw_tx(
    ffi.Pointer<ffi.Char> raw_tx,
    int network,
  ) {
    return _wallet_decode_raw_tx(
      raw_tx,
      network,
    );
  }

  late final _wallet_decode_raw_txPtr = _lookup<
      ffi.NativeFunction<
          RawTransaction Function(
              ffi.Pointer<ffi.Char>, ffi.Int32)>>('wallet_decode_raw_tx');
  late final _wallet_decode_raw_tx = _wallet_decode_raw_txPtr
      .asFunction<RawTransaction Function(ffi.Pointer<ffi.Char>, int)>();

  ffi.Pointer<ffi.Char> wallet_broadcast_tx(
    ffi.Pointer<ffi.Char> electrum_address,
    int tor_port,
    ffi.Pointer<ffi.Char> tx,
  ) {
    return _wallet_broadcast_tx(
      electrum_address,
      tor_port,
      tx,
    );
  }

  late final _wallet_broadcast_txPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<ffi.Char> Function(ffi.Pointer<ffi.Char>, ffi.Int32,
              ffi.Pointer<ffi.Char>)>>('wallet_broadcast_tx');
  late final _wallet_broadcast_tx = _wallet_broadcast_txPtr.asFunction<
      ffi.Pointer<ffi.Char> Function(
          ffi.Pointer<ffi.Char>, int, ffi.Pointer<ffi.Char>)>();

  bool wallet_validate_address(
    ffi.Pointer<ffi.Char> wallet,
    ffi.Pointer<ffi.Char> address,
  ) {
    return _wallet_validate_address(
      wallet,
      address,
    );
  }

  late final _wallet_validate_addressPtr = _lookup<
      ffi.NativeFunction<
          ffi.Bool Function(ffi.Pointer<ffi.Char>,
              ffi.Pointer<ffi.Char>)>>('wallet_validate_address');
  late final _wallet_validate_address = _wallet_validate_addressPtr.asFunction<
      bool Function(ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>)>();

  Psbt wallet_sign_offline(
    ffi.Pointer<ffi.Char> psbt,
    ffi.Pointer<ffi.Char> external_descriptor,
    ffi.Pointer<ffi.Char> internal_descriptor,
    int network,
  ) {
    return _wallet_sign_offline(
      psbt,
      external_descriptor,
      internal_descriptor,
      network,
    );
  }

  late final _wallet_sign_offlinePtr = _lookup<
      ffi.NativeFunction<
          Psbt Function(ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>,
              ffi.Pointer<ffi.Char>, ffi.Int32)>>('wallet_sign_offline');
  late final _wallet_sign_offline = _wallet_sign_offlinePtr.asFunction<
      Psbt Function(ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>,
          ffi.Pointer<ffi.Char>, int)>();

  Psbt wallet_sign_psbt(
    ffi.Pointer<ffi.Char> wallet,
    ffi.Pointer<ffi.Char> psbt,
  ) {
    return _wallet_sign_psbt(
      wallet,
      psbt,
    );
  }

  late final _wallet_sign_psbtPtr = _lookup<
      ffi.NativeFunction<
          Psbt Function(ffi.Pointer<ffi.Char>,
              ffi.Pointer<ffi.Char>)>>('wallet_sign_psbt');
  late final _wallet_sign_psbt = _wallet_sign_psbtPtr.asFunction<
      Psbt Function(ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>)>();

  Seed wallet_generate_seed(
    int network,
  ) {
    return _wallet_generate_seed(
      network,
    );
  }

  late final _wallet_generate_seedPtr =
      _lookup<ffi.NativeFunction<Seed Function(ffi.Int32)>>(
          'wallet_generate_seed');
  late final _wallet_generate_seed =
      _wallet_generate_seedPtr.asFunction<Seed Function(int)>();

  bool wallet_validate_seed(
    ffi.Pointer<ffi.Char> seed_words,
  ) {
    return _wallet_validate_seed(
      seed_words,
    );
  }

  late final _wallet_validate_seedPtr =
      _lookup<ffi.NativeFunction<ffi.Bool Function(ffi.Pointer<ffi.Char>)>>(
          'wallet_validate_seed');
  late final _wallet_validate_seed = _wallet_validate_seedPtr
      .asFunction<bool Function(ffi.Pointer<ffi.Char>)>();

  ffi.Pointer<ffi.Char> wallet_get_xpub_desc_key(
    ffi.Pointer<ffi.Char> xprv,
    ffi.Pointer<ffi.Char> path,
  ) {
    return _wallet_get_xpub_desc_key(
      xprv,
      path,
    );
  }

  late final _wallet_get_xpub_desc_keyPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<ffi.Char> Function(ffi.Pointer<ffi.Char>,
              ffi.Pointer<ffi.Char>)>>('wallet_get_xpub_desc_key');
  late final _wallet_get_xpub_desc_key =
      _wallet_get_xpub_desc_keyPtr.asFunction<
          ffi.Pointer<ffi.Char> Function(
              ffi.Pointer<ffi.Char>, ffi.Pointer<ffi.Char>)>();

  ffi.Pointer<ffi.Char> wallet_generate_xkey_with_entropy(
    ffi.Pointer<ffi.Uint8> entropy,
  ) {
    return _wallet_generate_xkey_with_entropy(
      entropy,
    );
  }

  late final _wallet_generate_xkey_with_entropyPtr = _lookup<
      ffi.NativeFunction<
          ffi.Pointer<ffi.Char> Function(
              ffi.Pointer<ffi.Uint8>)>>('wallet_generate_xkey_with_entropy');
  late final _wallet_generate_xkey_with_entropy =
      _wallet_generate_xkey_with_entropyPtr
          .asFunction<ffi.Pointer<ffi.Char> Function(ffi.Pointer<ffi.Uint8>)>();

  Seed wallet_get_seed_from_entropy(
    int network,
    ffi.Pointer<ffi.Uint8> entropy,
  ) {
    return _wallet_get_seed_from_entropy(
      network,
      entropy,
    );
  }

  late final _wallet_get_seed_from_entropyPtr = _lookup<
          ffi.NativeFunction<Seed Function(ffi.Int32, ffi.Pointer<ffi.Uint8>)>>(
      'wallet_get_seed_from_entropy');
  late final _wallet_get_seed_from_entropy = _wallet_get_seed_from_entropyPtr
      .asFunction<Seed Function(int, ffi.Pointer<ffi.Uint8>)>();

  void wallet_hello() {
    return _wallet_hello();
  }

  late final _wallet_helloPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function()>>('wallet_hello');
  late final _wallet_hello = _wallet_helloPtr.asFunction<void Function()>();
}

abstract class NetworkType {
  static const int Mainnet = 0;
  static const int Testnet = 1;
  static const int Signet = 2;
  static const int Regtest = 3;
}

abstract class WalletType {
  static const int WitnessPublicKeyHash = 0;
  static const int Taproot = 1;
}

class Wallet extends ffi.Struct {
  external ffi.Pointer<ffi.Char> name;

  @ffi.Int32()
  external int network;

  external ffi.Pointer<ffi.Char> external_pub_descriptor;

  external ffi.Pointer<ffi.Char> internal_pub_descriptor;

  external ffi.Pointer<ffi.Char> external_prv_descriptor;

  external ffi.Pointer<ffi.Char> internal_prv_descriptor;

  external ffi.Pointer<uintptr_t> bkd_wallet_ptr;
}

typedef uintptr_t = ffi.UnsignedLong;

class Utxo extends ffi.Struct {
  external ffi.Pointer<ffi.Char> txid;

  @ffi.Uint32()
  external int vout;

  @ffi.Uint64()
  external int value;
}

class UtxoList extends ffi.Struct {
  @ffi.Uint32()
  external int utxos_len;

  external ffi.Pointer<Utxo> utxos;
}

class ServerFeatures extends ffi.Struct {
  external ffi.Pointer<ffi.Char> server_version;

  external ffi.Pointer<ffi.Char> protocol_min;

  external ffi.Pointer<ffi.Char> protocol_max;

  @ffi.Int64()
  external int pruning;

  external ffi.Pointer<ffi.Uint8> genesis_hash;
}

class Transaction extends ffi.Struct {
  external ffi.Pointer<ffi.Char> txid;

  @ffi.Uint64()
  external int received;

  @ffi.Uint64()
  external int sent;

  @ffi.Uint64()
  external int fee;

  @ffi.Uint32()
  external int confirmation_height;

  @ffi.Uint64()
  external int confirmation_time;

  @ffi.Uint8()
  external int outputs_len;

  external ffi.Pointer<ffi.Pointer<ffi.Char>> outputs;

  @ffi.Uint8()
  external int inputs_len;

  external ffi.Pointer<ffi.Pointer<ffi.Char>> inputs;

  external ffi.Pointer<ffi.Char> address;
}

class TransactionList extends ffi.Struct {
  @ffi.Uint32()
  external int transactions_len;

  external ffi.Pointer<Transaction> transactions;
}

class Psbt extends ffi.Struct {
  @ffi.Uint64()
  external int sent;

  @ffi.Uint64()
  external int received;

  @ffi.Uint64()
  external int fee;

  external ffi.Pointer<ffi.Char> base64;

  external ffi.Pointer<ffi.Char> txid;

  external ffi.Pointer<ffi.Char> raw_tx;
}

class RawTransactionOutput extends ffi.Struct {
  @ffi.Uint64()
  external int amount;

  external ffi.Pointer<ffi.Char> address;
}

class RawTransactionInput extends ffi.Struct {
  @ffi.Uint32()
  external int previous_output_index;

  external ffi.Pointer<ffi.Char> previous_output;
}

class RawTransaction extends ffi.Struct {
  @ffi.Int32()
  external int version;

  @ffi.Uint8()
  external int outputs_len;

  external ffi.Pointer<RawTransactionOutput> outputs;

  @ffi.Uint8()
  external int inputs_len;

  external ffi.Pointer<RawTransactionInput> inputs;
}

class Seed extends ffi.Struct {
  external ffi.Pointer<ffi.Char> mnemonic;

  external ffi.Pointer<ffi.Char> xprv;

  external ffi.Pointer<ffi.Char> fingerprint;
}

const int INT8_MIN = -128;

const int INT16_MIN = -32768;

const int INT32_MIN = -2147483648;

const int INT64_MIN = -9223372036854775808;

const int INT8_MAX = 127;

const int INT16_MAX = 32767;

const int INT32_MAX = 2147483647;

const int INT64_MAX = 9223372036854775807;

const int UINT8_MAX = 255;

const int UINT16_MAX = 65535;

const int UINT32_MAX = 4294967295;

const int UINT64_MAX = -1;

const int INT_LEAST8_MIN = -128;

const int INT_LEAST16_MIN = -32768;

const int INT_LEAST32_MIN = -2147483648;

const int INT_LEAST64_MIN = -9223372036854775808;

const int INT_LEAST8_MAX = 127;

const int INT_LEAST16_MAX = 32767;

const int INT_LEAST32_MAX = 2147483647;

const int INT_LEAST64_MAX = 9223372036854775807;

const int UINT_LEAST8_MAX = 255;

const int UINT_LEAST16_MAX = 65535;

const int UINT_LEAST32_MAX = 4294967295;

const int UINT_LEAST64_MAX = -1;

const int INT_FAST8_MIN = -128;

const int INT_FAST16_MIN = -9223372036854775808;

const int INT_FAST32_MIN = -9223372036854775808;

const int INT_FAST64_MIN = -9223372036854775808;

const int INT_FAST8_MAX = 127;

const int INT_FAST16_MAX = 9223372036854775807;

const int INT_FAST32_MAX = 9223372036854775807;

const int INT_FAST64_MAX = 9223372036854775807;

const int UINT_FAST8_MAX = 255;

const int UINT_FAST16_MAX = -1;

const int UINT_FAST32_MAX = -1;

const int UINT_FAST64_MAX = -1;

const int INTPTR_MIN = -9223372036854775808;

const int INTPTR_MAX = 9223372036854775807;

const int UINTPTR_MAX = -1;

const int INTMAX_MIN = -9223372036854775808;

const int INTMAX_MAX = 9223372036854775807;

const int UINTMAX_MAX = -1;

const int PTRDIFF_MIN = -9223372036854775808;

const int PTRDIFF_MAX = 9223372036854775807;

const int SIG_ATOMIC_MIN = -2147483648;

const int SIG_ATOMIC_MAX = 2147483647;

const int SIZE_MAX = -1;

const int WCHAR_MIN = -2147483648;

const int WCHAR_MAX = 2147483647;

const int WINT_MIN = 0;

const int WINT_MAX = 4294967295;

const int INT8_WIDTH = 8;

const int UINT8_WIDTH = 8;

const int INT16_WIDTH = 16;

const int UINT16_WIDTH = 16;

const int INT32_WIDTH = 32;

const int UINT32_WIDTH = 32;

const int INT64_WIDTH = 64;

const int UINT64_WIDTH = 64;

const int INT_LEAST8_WIDTH = 8;

const int UINT_LEAST8_WIDTH = 8;

const int INT_LEAST16_WIDTH = 16;

const int UINT_LEAST16_WIDTH = 16;

const int INT_LEAST32_WIDTH = 32;

const int UINT_LEAST32_WIDTH = 32;

const int INT_LEAST64_WIDTH = 64;

const int UINT_LEAST64_WIDTH = 64;

const int INT_FAST8_WIDTH = 8;

const int UINT_FAST8_WIDTH = 8;

const int INT_FAST16_WIDTH = 64;

const int UINT_FAST16_WIDTH = 64;

const int INT_FAST32_WIDTH = 64;

const int UINT_FAST32_WIDTH = 64;

const int INT_FAST64_WIDTH = 64;

const int UINT_FAST64_WIDTH = 64;

const int INTPTR_WIDTH = 64;

const int UINTPTR_WIDTH = 64;

const int INTMAX_WIDTH = 64;

const int UINTMAX_WIDTH = 64;

const int PTRDIFF_WIDTH = 64;

const int SIG_ATOMIC_WIDTH = 32;

const int SIZE_WIDTH = 64;

const int WCHAR_WIDTH = 32;

const int WINT_WIDTH = 32;

const int NULL = 0;

const int WNOHANG = 1;

const int WUNTRACED = 2;

const int WSTOPPED = 2;

const int WEXITED = 4;

const int WCONTINUED = 8;

const int WNOWAIT = 16777216;

const int RAND_MAX = 2147483647;

const int EXIT_FAILURE = 1;

const int EXIT_SUCCESS = 0;

const int LITTLE_ENDIAN = 1234;

const int BIG_ENDIAN = 4321;

const int PDP_ENDIAN = 3412;

const int BYTE_ORDER = 1234;

const int FD_SETSIZE = 1024;

const int NFDBITS = 64;
