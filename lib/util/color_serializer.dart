// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:convert';
import 'dart:ui';

String colorToJson(Color color) => jsonEncode(color.value);
Color colorFromJson(String json) => Color(jsonDecode(json));
