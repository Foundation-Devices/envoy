// This file is automatically generated, so please do not edit it.
// @generated by `flutter_rust_bridge`@ 2.9.0.

// ignore_for_file: invalid_use_of_internal_member, unused_import, unnecessary_import

import '../../../frb_generated.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

class PassportFirmwareVersion {
  final String field0;

  const PassportFirmwareVersion({
    required this.field0,
  });

  @override
  int get hashCode => field0.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PassportFirmwareVersion &&
          runtimeType == other.runtimeType &&
          field0 == other.field0;
}

enum PassportModel {
  gen1,
  gen2,
  prime,
  ;
}

class PassportSerial {
  final String field0;

  const PassportSerial({
    required this.field0,
  });

  @override
  int get hashCode => field0.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PassportSerial &&
          runtimeType == other.runtimeType &&
          field0 == other.field0;
}
