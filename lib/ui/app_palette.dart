import 'package:flutter/material.dart';

abstract final class AppPalette {
  static const background = Color(0xFF080B18);
  static const surface = Color(0xFF12182B);
  static const surfaceRaised = Color(0xFF171F36);
  static const border = Color(0xFF242D46);
  static const muted = Color(0xFF8D9AB8);
  static const blue = Color(0xFF8AA9FF);
  static const purple = Color(0xFF7356F5);
  static const cyan = Color(0xFF50C6E9);

  static const accent = LinearGradient(
    colors: [purple, Color(0xFF557FF2), cyan],
  );
}
