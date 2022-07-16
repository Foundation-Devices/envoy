import 'package:flutter_neumorphic/flutter_neumorphic.dart';

// Dart doesn't support tuples
class ColorPair {
  final Color darker;
  final Color lighter;

  ColorPair(this.darker, this.lighter);
}

class EnvoyColors {
  static const Color tilesLineDarkColor = Color.fromRGBO(35, 39, 40, 1);
  static const Color deviceBackgroundGradientGrey =
      Color.fromRGBO(211, 211, 211, 1.0);

  static const Color blue = Color.fromRGBO(80, 159, 181, 1);
  static const Color lightBlue = Color.fromRGBO(168, 221, 229, 1);

  static const Color brown = Color.fromRGBO(138, 98, 81, 1);
  static const Color lightBrown = Color.fromRGBO(238, 196, 179, 1);

  static const Color blackish = Color.fromRGBO(37, 41, 42, 1);
  static const Color lightBlackish = Color.fromRGBO(115, 122, 123, 1);

  static const Color whitePrint = Color.fromRGBO(248, 248, 248, 1);

  static const Color white95 = Color.fromRGBO(255, 255, 255, 0.95);
  static const Color white80 = Color.fromRGBO(255, 255, 255, 0.80);

  static const Color white100 = Color.fromRGBO(255, 255, 255, 1);
  static const Color grey = Color.fromRGBO(104, 104, 104, 2);
  static const Color transparent = Color.fromRGBO(255, 255, 255, 0.0);

  static const Color darkTeal = Color.fromRGBO(0, 157, 185, 1);
  static const Color teal = Color.fromRGBO(0, 189, 205, 1);

  static const Color white30 = Color.fromRGBO(255, 255, 255, 0.3);
  static const Color grey15 = Color.fromRGBO(192, 192, 192, 0.15);
  static const Color grey22 = Color.fromRGBO(192, 192, 192, 0.22);
  static const Color grey50 = Color.fromRGBO(192, 192, 192, 0.50);
  static const Color grey85 = Color.fromRGBO(192, 192, 192, 0.85);

  static const Color darkCopper = Color.fromRGBO(191, 117, 95, 1.0);
  static const Color midCopper = Color.fromRGBO(214, 139, 110, 1.0);
  static const Color lightCopper = Color.fromRGBO(251, 196, 170, 1.0);

  static const Color glowInner = Color.fromRGBO(150, 92, 75, 1.0);
  static const Color glowMiddle = midCopper;
  static const Color glowOuter = transparent;

  static List<Color> listAccountTileColors = [
    Color(0xFFBF755F),
    Color(0xFF009DB9),
    Color(0xFF007A7A),
    Color(0xFFD68B6E),
    Color(0xFF00A5B2),
    Color(0xFF2E9483),
    // Color(0xFF8A4F38),
    // Color(0xFF007A7A),
    // Color(0xFF004747),
  ];

  static List<ColorPair> listTileColorPairs = [
    ColorPair(blue, lightBlue),
    ColorPair(brown, lightBrown),
    ColorPair(blackish, lightBlackish)
  ];
}
