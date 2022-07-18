// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

@JS("window.wasm")
library ffi;

import 'package:js/js.dart';

@JS('add')
external int add(num1, num2);

@JS('memory')
external Object memory;

@JS('memory.buffer')
external Object buffer;

@JS("ur_encoder")
external int urEncoder(message, messageLen, maxFragmentLen);

@JS("ur_encoder_next_part")
external int urEncoderNextPart(pointer);

@JS("ur_decoder")
external int urDecoder();

@JS("ur_decoder_receive")
external int urDecoderReceive(pointer, data);
