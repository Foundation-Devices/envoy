import 'package:flutter/foundation.dart';

kPrint(Object? message) {
  if (kDebugMode) {
    print(message);
  }
}
