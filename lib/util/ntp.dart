// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later
// ignore_for_file: constant_identifier_names
// based on  https://github.com/knezzz/ntp/blob/master/lib/ntp/ntp.dart

import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:envoy/util/bug_report_helper.dart';
import 'package:envoy/util/console.dart';

const _defaultLookup = 'pool.ntp.org';
const _defaultInterval = Duration(minutes: 2);

class NTPUtil {
  static final NTPUtil _instance = NTPUtil._();
  DateTime _dateTime = DateTime.now();
  StreamController<DateTime> ntpTimeStreamController =
      StreamController<DateTime>.broadcast();

  Stream<DateTime> getDateStream() {
    return ntpTimeStreamController.stream;
  }

  factory NTPUtil() {
    return _instance;
  }

  NTPUtil._();

  static Future<void> init() async {
    _instance._getNtpTime();
    Timer.periodic(_defaultInterval, (timer) {
      _instance._getNtpTime();
    });
  }

  DateTime get dateTime => _dateTime;

  void _getNtpTime() async {
    try {
      _dateTime = await NTP.now();
      if (!ntpTimeStreamController.isClosed) {
        ntpTimeStreamController.add(_dateTime);
      }
    } catch (e) {
      kPrint("Error getting NTP time: $e");
      EnvoyReport().log("NTP", "Error getting NTP time: $e");
    }
  }
}

/// This class represents a NTP message, as specified in RFC 2030.  The message
/// format is compatible with all versions of NTP and SNTP.
///
/// This class does not support the optional authentication protocol, and
/// ignores the key ID and message digest fields.
///
/// For convenience, this class exposes message values as native Java types, not
/// the NTP-specified data formats.  For example, timestamps are
/// stored as doubles (as opposed to the NTP unsigned 64-bit fixed point
/// format).
///
/// However, the constructor NtpMessage(byte[]) and the method toByteArray()
/// allow the import and export of the raw NTP message format.
///
/// This code is copyright (c) Adam Buckley 2004
///
/// This program is free software; you can redistribute it and/or modify it
/// under the terms of the GNU General Public License as published by the Free
/// Software Foundation; either version 2 of the License, or (at your option)
/// any later version.  A HTML version of the GNU General Public License can be
/// seen at http://www.gnu.org/licenses/gpl.html
///
/// This program is distributed in the hope that it will be useful, but WITHOUT
/// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
/// FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
/// more details.
///
///
/// Comments for member variables are taken from RFC2030 by David Mills,
/// University of Delaware.
///
/// Number format conversion code in NtpMessage(byte[] array) and toByteArray()
/// inspired by http://www.pps.jussieu.fr/~jch/enseignement/reseaux/
/// NTPMessage.java which is copyright (c) 2003 by Juliusz Chroboczek
///
/// @author Adam Buckley
/// Rewritten in dart by: Luka Knezic 2018
class _NTPMessage {
  /// Constructs a NtpMessage in client -> server mode, and sets the
  /// transmit timestamp to the current time.
  ///
  /// If byte array (raw NTP packet) is passed to constructor then the
  /// data is filled from a raw NTP packet.
  _NTPMessage([List<int>? array]) {
    if (array != null) {
      _leapIndicator = array[0] >> 6 & 0x3;
      _version = array[0] >> 3 & 0x7;
      _mode = array[0] & 0x7;
      _stratum = unsignedByteToShort(array[1]);
      _pollInterval = array[2];
      _precision = array[3];

      _rootDelay = ((array[4] * 256) +
              unsignedByteToShort(array[5]) +
              (unsignedByteToShort(array[6]) / 256) +
              (unsignedByteToShort(array[7]) / 65536))
          .toInt();

      _rootDispersion = ((unsignedByteToShort(array[8]) * 256) +
              unsignedByteToShort(array[9]) +
              (unsignedByteToShort(array[10]) / 256) +
              (unsignedByteToShort(array[11]) / 65536))
          .toInt();

      _referenceIdentifier[0] = array[12];
      _referenceIdentifier[1] = array[13];
      _referenceIdentifier[2] = array[14];
      _referenceIdentifier[3] = array[15];

      _referenceTimestamp = decodeTimestamp(array, 16);
      _originateTimestamp = decodeTimestamp(array, 24);
      _receiveTimestamp = decodeTimestamp(array, 32);
      _transmitTimestamp = decodeTimestamp(array, 40);
    } else {
      final DateTime time = DateTime.now().toLocal();
      _mode = 3;
      _transmitTimestamp = (time.millisecondsSinceEpoch / 1000.0) + timeToUtc;
    }
  }

  final double timeToUtc = 2208988800.0;

  /// This is a two-bit code warning of an impending leap second to be
  /// inserted/deleted in the last minute of the current day.  It's values
  /// may be as follows:
  /// Value     Meaning
  /// -----     -------
  /// 0         no warning
  /// 1         last minute has 61 seconds
  /// 2         last minute has 59 seconds
  /// 3         alarm condition (clock not synchronized)
  int _leapIndicator = 0;

  /// This value indicates the NTP/SNTP version number.  The version number
  /// is 3 for Version 3 (IPv4 only) and 4 for Version 4 (IPv4, IPv6 and OSI).
  /// If necessary to distinguish between IPv4, IPv6 and OSI, the
  /// encapsulating context must be inspected.
  int _version = 3;

  /// This value indicates the mode, with values defined as follows:
  /// Mode     Meaning
  /// ----     -------
  /// 0        reserved
  /// 1        symmetric active
  /// 2        symmetric passive
  /// 3        client
  /// 4        server
  /// 5        broadcast
  /// 6        reserved for NTP control message
  /// 7        reserved for private use
  ///
  /// In unicast and anycast modes, the client sets this field to 3 (client)
  /// in the request and the server sets it to 4 (server) in the reply. In
  /// multicast mode, the server sets this field to 5 (broadcast).
  int _mode = 0;

  /// This value indicates the stratum level of the local clock, with values
  /// defined as follows:
  /// Stratum  Meaning
  /// ----------------------------------------------
  /// 0        unspecified or unavailable
  /// 1        primary reference (e.g., radio clock)
  /// 2-15     secondary reference (via NTP or SNTP)
  /// 16-255   reserved
  int _stratum = 0;

  /// This value indicates the maximum interval between successive messages,
  /// in seconds to the nearest power of two. The values that can appear in
  /// this field presently range from 4 (16 s) to 14 (16284 s); however, most
  /// applications use only the sub-range 6 (64 s) to 10 (1024 s).
  int _pollInterval = 0;

  /// This value indicates the precision of the local clock, in seconds to
  /// the nearest power of two.  The values that normally appear in this field
  /// range from -6 for mains-frequency clocks to -20 for microsecond clocks
  /// found in some workstations.
  int _precision = 0;

  /// This value indicates the total roundtrip delay to the primary reference
  /// source, in seconds.  Note that this variable can take on both positive
  /// and negative values, depending on the relative time and frequency
  /// offsets. The values that normally appear in this field range from
  /// negative values of a few milliseconds to positive values of several
  /// hundred milliseconds.
  int _rootDelay = 0;

  /// This value indicates the nominal error relative to the primary reference
  /// source, in seconds.  The values  that normally appear in this field
  /// range from 0 to several hundred milliseconds.
  int _rootDispersion = 0;

  /// This is a 4-byte array identifying the particular reference source.
  /// In the case of NTP Version 3 or Version 4 stratum-0 (unspecified) or
  /// stratum-1 (primary) servers, this is a four-character ASCII string, left
  /// justified and zero padded to 32 bits. In NTP Version 3 secondary
  /// servers, this is the 32-bit IPv4 address of the reference source. In NTP
  /// Version 4 secondary servers, this is the low order 32 bits of the latest
  /// transmit timestamp of the reference source. NTP primary (stratum 1)
  /// servers should set this field to a code identifying the external
  /// reference source according to the following list. If the external
  /// reference is one of those listed, the associated code should be used.
  /// Codes for sources not listed can be contrived as appropriate.
  /// Code     External Reference Source
  /// ----     -------------------------
  /// LOCL     uncalibrated local clock used as a primary reference for
  /// a subnet without external means of synchronization
  /// PPS      atomic clock or other pulse-per-second source
  /// individually calibrated to national standards
  /// ACTS     NIST dialup modem service
  /// USNO     USNO modem service
  /// PTB      PTB (Germany) modem service
  /// TDF      Allouis (France) Radio 164 kHz
  /// DCF      Mainflingen (Germany) Radio 77.5 kHz
  /// MSF      Rugby (UK) Radio 60 kHz
  /// WWV      Ft. Collins (US) Radio 2.5, 5, 10, 15, 20 MHz
  /// WWVB     Boulder (US) Radio 60 kHz
  /// WWVH     Kaui Hawaii (US) Radio 2.5, 5, 10, 15 MHz
  /// CHU      Ottawa (Canada) Radio 3330, 7335, 14670 kHz
  /// LORC     LORAN-C radionavigation system
  /// OMEG     OMEGA radionavigation system
  /// GPS      Global Positioning Service
  /// GOES     Geostationary Orbit Environment Satellite
  final List<int> _referenceIdentifier = <int>[0, 0, 0, 0];

  /// This is the time at which the local clock was last set or corrected, in
  /// seconds since 00:00 1-Jan-1900.
  double _referenceTimestamp = 0.0;

  /// This is the time at which the request departed the client for the
  /// server, in seconds since 00:00 1-Jan-1900.
  double _originateTimestamp = 0.0;

  /// This is the time at which the request arrived at the server, in seconds
  /// since 00:00 1-Jan-1900.
  double _receiveTimestamp = 0.0;

  /// This is the time at which the reply departed the server for the client,
  /// in seconds since 00:00 1-Jan-1900.
  double _transmitTimestamp = 0.0;

  double get referenceTimestamp => _referenceTimestamp;
  double get originateTimestamp => _originateTimestamp;
  double get receiveTimestamp => _receiveTimestamp;
  double get transmitTimestamp => _transmitTimestamp;

  /// This method constructs the data bytes of a raw NTP packet.
  List<int> toByteArray() {
    final List<int> rawNtp = List.filled(48, 0);

    rawNtp[0] = _leapIndicator << 6 | _version << 3 | _mode;
    rawNtp[1] = _stratum;
    rawNtp[2] = _pollInterval;
    rawNtp[3] = _precision;

    /// root delay is a signed 16.16-bit FP, in Java an int is 32-bits
    final int l = _rootDelay * 65536;
    rawNtp[4] = l >> 24 & 0xFF;
    rawNtp[5] = l >> 16 & 0xFF;
    rawNtp[6] = l >> 8 & 0xFF;
    rawNtp[7] = l & 0xFF;

    /// root dispersion is an unsigned 16.16-bit FP, in Java there are no
    /// unsigned primitive types, so we use a long which is 64-bits
    final int ul = _rootDispersion * 65536;
    rawNtp[8] = ul >> 24 & 0xFF;
    rawNtp[9] = ul >> 16 & 0xFF;
    rawNtp[10] = ul >> 8 & 0xFF;
    rawNtp[11] = ul & 0xFF;

    rawNtp[12] = _referenceIdentifier[0];
    rawNtp[13] = _referenceIdentifier[1];
    rawNtp[14] = _referenceIdentifier[2];
    rawNtp[15] = _referenceIdentifier[3];

    encodeTimestamp(rawNtp, 16, _referenceTimestamp);
    encodeTimestamp(rawNtp, 24, _originateTimestamp);
    encodeTimestamp(rawNtp, 32, _receiveTimestamp);
    encodeTimestamp(rawNtp, 40, _transmitTimestamp);

    return rawNtp;
  }

  /// Converts an unsigned byte to a short.  By default, Java assumes that
  /// a byte is signed.
  int unsignedByteToShort(int i) {
    if ((i & 0x80) == 0x80) {
      return 128 + (i & 0x7f);
    } else {
      return i;
    }
  }

  /// Will read 8 bytes of a message beginning at <code>pointer</code>
  /// and return it as a double, according to the NTP 64-bit timestamp
  /// format.
  double decodeTimestamp(List<int> array, int pointer) {
    double r = 0.0;

    for (int i = 0; i < 8; i++) {
      r += unsignedByteToShort(array[pointer + i]) * pow(2.0, (3 - i) * 8);
    }

    return r;
  }

  /// Encodes a timestamp in the specified position in the message
  void encodeTimestamp(List<int> array, int pointer, double timestamp) {
    /// Converts a double into a 64-bit fixed point
    for (int i = 0; i < 8; i++) {
      /// 2^24, 2^16, 2^8, .. 2^-32
      final num base = pow(2.0, (3 - i) * 8);

      /// Capture byte value
      array[pointer + i] = timestamp ~/ base;

      /// Subtract captured value from remaining total
      timestamp = timestamp - (unsignedByteToShort(array[pointer + i]) * base);
    }

    /// From RFC 2030: It is advisable to fill the non-significant
    /// low order bits of the timestamp with a random, unbiased
    /// bit-string, both to avoid systematic round-off errors and as
    /// a means of loop detection and replay detection.
    array[7] = Random().nextInt(255);
  }

  @override
  String toString() {
    return 'Leap indicator: $_leapIndicator\n'
        'Version: $_version \n'
        'Mode: $_mode\n'
        'Stratum: $_stratum\n'
        'Poll: $_pollInterval\n'
        'Precision: $_precision\n'
        'Root delay: ${_rootDelay * 1000.0} ms\n'
        'Root dispersion: ${_rootDispersion * 1000.0}ms\n'
        'Reference identifier: ${referenceIdentifierToString(_referenceIdentifier, _stratum, _version)}\n'
        'Reference timestamp: ${timestampToString(_referenceTimestamp)}\n'
        'Originate timestamp: ${timestampToString(_originateTimestamp)}\n'
        'Receive timestamp:   ${timestampToString(_receiveTimestamp)}\n'
        'Transmit timestamp:  ${timestampToString(_transmitTimestamp)}';
  }

  String timestampToString(double timestamp) {
    if (timestamp == 0) {
      return '0';
    }

    final double utc = timestamp - timeToUtc;
    final double ms = utc * 1000.0;

    return DateTime.fromMillisecondsSinceEpoch(ms.toInt()).toString();
  }

  String referenceIdentifierToString(List<int> ref, int stratum, int version) {
    /// From the RFC 2030:
    /// In the case of NTP Version 3 or Version 4 stratum-0 (unspecified)
    /// or stratum-1 (primary) servers, this is a four-character ASCII
    /// string, left justified and zero padded to 32 bits.
    if (stratum == 0 || stratum == 1) {
      return ref.toString();
    }

    /// In NTP Version 3 secondary servers, this is the 32-bit IPv4
    /// address of the reference source.
    else if (version == 3) {
      return '${unsignedByteToShort(ref[0])}.${unsignedByteToShort(ref[1])}.'
          '${unsignedByteToShort(ref[2])}.${unsignedByteToShort(ref[3])}';
    }

    /// In NTP Version 4 secondary servers, this is the low order 32 bits
    /// of the latest transmit timestamp of the reference source.
    else if (version == 4) {
      return '${unsignedByteToShort(ref[0]) / 256.0 + unsignedByteToShort(ref[1]) / 65536.0 + unsignedByteToShort(ref[2]) / 16777216.0 + unsignedByteToShort(ref[3]) / 4294967296.0}';
    }

    return '';
  }
}

class NTP {
  /// Return NTP delay in milliseconds
  static Future<int> getNtpOffset({
    String lookUpAddress = _defaultLookup,
    int port = 123,
    DateTime? localTime,
    Duration? timeout,
  }) async {
    final List<InternetAddress> addresses =
        await InternetAddress.lookup(lookUpAddress);

    if (addresses.isEmpty) {
      return Future.error('Could not resolve address for $lookUpAddress.');
    }

    final InternetAddress serverAddress = addresses.first;
    InternetAddress clientAddress = InternetAddress.anyIPv4;
    if (serverAddress.type == InternetAddressType.IPv6) {
      clientAddress = InternetAddress.anyIPv6;
    }

    // Init datagram socket to anyIPv4 and to port 0
    final RawDatagramSocket datagramSocket =
        await RawDatagramSocket.bind(clientAddress, 0);

    final _NTPMessage ntpMessage = _NTPMessage();
    final List<int> buffer = ntpMessage.toByteArray();
    final DateTime time = localTime ?? DateTime.now();
    ntpMessage.encodeTimestamp(buffer, 40,
        (time.millisecondsSinceEpoch / 1000.0) + ntpMessage.timeToUtc);

    // Send buffer packet to the address [serverAddress] and port [port]
    datagramSocket.send(buffer, serverAddress, port);
    // Receive packet from socket
    Datagram? packet;

    receivePacket(RawSocketEvent event) {
      if (event == RawSocketEvent.read) {
        packet = datagramSocket.receive();
      }
      return packet != null;
    }

    try {
      if (timeout != null) {
        await datagramSocket.timeout(timeout).firstWhere(receivePacket);
      } else {
        await datagramSocket.firstWhere(receivePacket);
      }
    } catch (e) {
      rethrow;
    } finally {
      datagramSocket.close();
    }

    if (packet == null) {
      return Future<int>.error('Received empty response.');
    }

    final int offset = _parseData(packet!.data, DateTime.now());
    return offset;
  }

  /// Get current NTP time
  static Future<DateTime> now({
    String lookUpAddress = _defaultLookup,
    int port = 123,
    Duration? timeout,
  }) async {
    final DateTime localTime = DateTime.now();
    final int offset = await getNtpOffset(
      lookUpAddress: lookUpAddress,
      port: port,
      localTime: localTime,
      timeout: timeout,
    );

    return localTime.add(Duration(milliseconds: offset));
  }

  /// Parse data from datagram socket.
  static int _parseData(List<int> data, DateTime time) {
    final _NTPMessage ntpMessage = _NTPMessage(data);
    final double destinationTimestamp =
        (time.millisecondsSinceEpoch / 1000.0) + 2208988800.0;
    final double localClockOffset =
        ((ntpMessage._receiveTimestamp - ntpMessage._originateTimestamp) +
                (ntpMessage._transmitTimestamp - destinationTimestamp)) /
            2;

    return (localClockOffset * 1000).toInt();
  }
}
