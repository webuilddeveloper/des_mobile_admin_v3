import 'package:flutter/material.dart';

class ThemeColor {
  static Color primary = const Color(0xFF0A5E4F);
  static Color primaryLight = const Color(0xFFF1FFFC);
  static Color primaryDark = const Color(0xFF0A5E4F);
  static Color secondary = const Color(0xFF1A7263);
  static Color secondary50 = const Color(0x801A7263);
  static Color greenMint = const Color(0xFFC7FFF5);
  static Color orange = const Color(0xFFD25335);
  static Color orangeLight = const Color(0xFFFFF1EE);
  static Color grey70 = const Color(0xFF707070);
  static Color greyDD = const Color(0xFFDDDDDD);
  static Color greyEE = const Color(0xFFEEEEEE);
  static Color fail = const Color(0xFF881C03);
  static LinearGradient linearRed = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [
      orange,
      const Color(0xFFC94E80),
    ],
  );
}
