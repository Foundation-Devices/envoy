import 'dart:convert';
import 'dart:ui';

String colorToJson(Color color) => jsonEncode(color.value);
Color colorFromJson(String json) => Color(jsonDecode(json));
