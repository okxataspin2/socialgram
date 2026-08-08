import 'package:flutter/material.dart';

/// Defines the color palette for the App UI Kit.
abstract class AppColors {
  /// Black
  static const Color black = Color(0xFF000000);

  /// The background color.
  static const Color background = Color.fromARGB(255, 32, 30, 30);

  /// White
  static const Color white = Color(0xFFFFFFFF);

  /// Transparent
  static const Color transparent = Color(0x00000000);

  /// The light blue color.
  static const Color lightBlue = Color.fromARGB(255, 100, 181, 246);

  /// The blue primary color and swatch.
  static const Color blue = Color(0xFF3898EC);

  /// The deep blue color.
  static const Color deepBlue = Color(0xff337eff);

  /// The border outline color.
  static const Color borderOutline = Color.fromARGB(45, 250, 250, 250);

  /// Light dark.
  static const Color lightDark = Color.fromARGB(164, 120, 119, 119);

  /// Dark.
  static const Color dark = Color.fromARGB(255, 58, 58, 58);

  /// Primary dark blue color.
  static const Color primaryDarkBlue = Color(0xff1c1e22);

  /// Grey.
  static const Color grey = Colors.grey;

  /// The bright grey color.
  static const Color brightGrey = Color.fromARGB(255, 224, 224, 224);

  /// The dark grey color.
  static const Color darkGrey = Color.fromARGB(255, 66, 66, 66);

  /// The emphasize grey color.
  static const Color emphasizeGrey = Color.fromARGB(255, 97, 97, 97);

  /// The emphasize dark grey color.
  static const Color emphasizeDarkGrey = Color.fromARGB(255, 40, 37, 37);

  /// Red material color.
  static const MaterialColor red = Colors.red;

  /// The primary Instagram gradient pallete.
  static const primaryGradient = <Color>[
    Color(0xFF833AB4), // Purple
    Color(0xFFF77737), // Orange
    Color(0xFFE1306C), // Red-pink
    Color(0xFFC13584), // Red-purple
    Color(0xFF833AB4), // Duplicate of the first color
  ];

  /// The primary Telegram gradient chat background pallete.
  static const primaryBackgroundGradient = <Color>[
    Color.fromARGB(255, 119, 69, 121),
    Color.fromARGB(255, 141, 124, 189),
    Color.fromARGB(255, 50, 94, 170),
    Color.fromARGB(255, 111, 156, 189),
  ];

  /// The primary Telegram gradient chat message bubble pallete.
  static const primaryMessageBubbleGradient = <Color>[
    Color.fromARGB(255, 226, 128, 53),
    Color.fromARGB(255, 228, 96, 182),
    Color.fromARGB(255, 107, 73, 195),
    Color.fromARGB(255, 78, 173, 195),
  ];

  // ── Glass Colors ──────────────────────────────────────────────────────

  /// Light mode glass fill (white 15% opacity).
  static const Color glassLight = Color(0x26FFFFFF);

  /// Dark mode glass fill (white 25% opacity).
  static const Color glassDark = Color(0x40FFFFFF);

  /// Light mode glass border (white 30% opacity).
  static const Color glassBorderLight = Color(0x4DFFFFFF);

  /// Dark mode glass border (white 10% opacity).
  static const Color glassBorderDark = Color(0x1AFFFFFF);

  /// Top-edge highlight for 3D depth (white 20% opacity).
  static const Color glassHighlight = Color(0x33FFFFFF);

  /// Subtle shadow for layered depth (black 20% opacity).
  static const Color glassShadow = Color(0x33000000);

  /// Light mode glass gradient.
  static const LinearGradient glassGradientLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xB3FFFFFF), Color(0x4DFFFFFF)],
  );

  /// Dark mode glass gradient.
  static const LinearGradient glassGradientDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x1FFFFFFF), Color(0x0AFFFFFF)],
  );

  // ── Glass Accent Gradients ────────────────────────────────────────────

  /// Blue accent gradient for stat cards.
  static const LinearGradient glassBlueGradient = LinearGradient(
    colors: [Color(0xFF4FC3F7), Color(0xFF2196F3)],
  );

  /// Purple accent gradient for stat cards.
  static const LinearGradient glassPurpleGradient = LinearGradient(
    colors: [Color(0xFFCE93D8), Color(0xFF9C27B0)],
  );

  /// Green accent gradient for stat cards.
  static const LinearGradient glassGreenGradient = LinearGradient(
    colors: [Color(0xFF81C784), Color(0xFF4CAF50)],
  );

  /// Orange accent gradient for stat cards.
  static const LinearGradient glassOrangeGradient = LinearGradient(
    colors: [Color(0xFFFFB74D), Color(0xFFFF9800)],
  );

  /// Pink accent gradient for stat cards.
  static const LinearGradient glassPinkGradient = LinearGradient(
    colors: [Color(0xFFF48FB1), Color(0xFFE91E63)],
  );

  /// Teal accent gradient for stat cards.
  static const LinearGradient glassTealGradient = LinearGradient(
    colors: [Color(0xFF80CBC4), Color(0xFF009688)],
  );
}
