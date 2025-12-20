import 'package:flutter/material.dart';

class DesignColors {
  static const Color primary = Color(0xFFE67E22); // Orange
  static const Color darkPrimary = Color(0xFFD35400); // Dark Orange
  static const Color lightPrimary = Color(0xFFFFE5D9); // Light Orange
  static const Color darkBlueGrey = Color(0xFF2C3E50); // Authority
  static const Color lightGrey = Color(0xFF95A5A6); // Neutral
  static const Color success = Color(0xFF27AE60);
  static const Color warning = Color(0xFFF39C12);
  static const Color error = Color(0xFFE74C3C);
  static const Color info = Color(0xFF3498DB);
  static const Color favoritePink = Color(0xFFE91E63);
  static const Color ratingAmber = Color(0xFFFFC107);
}

class DesignRadius {
  static const double small = 8.0;
  static const double medium = 12.0;
  static const double large = 16.0;
}

class DesignText {
  // Using Poppins family; ensure it's added in pubspec if not already.
  static const String family = 'Poppins';

  static const TextStyle displayLarge = TextStyle(
    fontFamily: family,
    fontSize: 32,
    fontWeight: FontWeight.bold,
    height: 1.2,
  );

  static const TextStyle headlineLarge = TextStyle(
    fontFamily: family,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static const TextStyle titleLarge = TextStyle(
    fontFamily: family,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: family,
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  static const TextStyle labelLarge = TextStyle(
    fontFamily: family,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );
}
