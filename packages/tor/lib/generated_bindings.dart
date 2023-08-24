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

  ffi.Pointer<ffi.Char> tor_last_error_message() {
    return _tor_last_error_message();
  }

  late final _tor_last_error_messagePtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<ffi.Char> Function()>>(
          'tor_last_error_message');
  late final _tor_last_error_message =
      _tor_last_error_messagePtr.asFunction<ffi.Pointer<ffi.Char> Function()>();

  ffi.Pointer<ffi.Int> tor_start(
    int socks_port,
  ) {
    return _tor_start(
      socks_port,
    );
  }

  late final _tor_startPtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<ffi.Int> Function(ffi.Uint16)>>(
          'tor_start');
  late final _tor_start =
      _tor_startPtr.asFunction<ffi.Pointer<ffi.Int> Function(int)>();

  bool tor_bootstrap(
    ffi.Pointer<ffi.Int> client,
  ) {
    return _tor_bootstrap(
      client,
    );
  }

  late final _tor_bootstrapPtr =
      _lookup<ffi.NativeFunction<ffi.Bool Function(ffi.Pointer<ffi.Int>)>>(
          'tor_bootstrap');
  late final _tor_bootstrap =
      _tor_bootstrapPtr.asFunction<bool Function(ffi.Pointer<ffi.Int>)>();

  void tor_hello() {
    return _tor_hello();
  }

  late final _tor_helloPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function()>>('tor_hello');
  late final _tor_hello = _tor_helloPtr.asFunction<void Function()>();
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
