import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF0A6E6E);
  static const Color primaryDark = Color(0xFF054F4F);
  static const Color primaryLight = Color(0xFF0D8F8F);
  static const Color primaryPale = Color(0xFFE0F4F4);
  static const Color primarySurface = Color(0xFFF0FAFA);

  static const Color accent = Color(0xFF2DD4BF);
  static const Color accentLight = Color(0xFF99F0E6);
  static const Color accentPale = Color(0xFFE6FBF8);

  static const Color coral = Color(0xFFFF6B6B);
  static const Color coralLight = Color(0xFFFFE5E5);

  static const Color gold = Color(0xFFFFC947);
  static const Color goldLight = Color(0xFFFFF3D6);

  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFFEEF2F6);

  static const Color darkCard = Color(0xFF0D2137);
  static const Color darkCardSecondary = Color(0xFF1A3A52);
  static const Color darkCardAccent = Color(0xFF1E4D6B);

  static const Color textPrimary = Color(0xFF0D2137);
  static const Color textSecondary = Color(0xFF5A7184);
  static const Color textTertiary = Color(0xFF9DB0C0);
  static const Color textOnDark = Color(0xFFFFFFFF);
  static const Color textOnDarkSecondary = Color(0xFFB8D4E3);

  static const Color success = Color(0xFF00C897);
  static const Color successLight = Color(0xFFE0FAF4);
  static const Color error = Color(0xFFFF4757);
  static const Color errorLight = Color(0xFFFFECEE);
  static const Color warning = Color(0xFFFFC947);
  static const Color warningLight = Color(0xFFFFF8E6);
  static const Color info = Color(0xFF0A6E6E);
  static const Color infoLight = Color(0xFFE0F4F4);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF054F4F), Color(0xFF0A6E6E), Color(0xFF0D8F8F)],
  );

  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF032E2E), Color(0xFF054F4F), Color(0xFF0A6E6E)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0D8F8F), Color(0xFF2DD4BF)],
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0D2137), Color(0xFF1A3A52)],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFC947), Color(0xFFFFD97D)],
  );

  static const LinearGradient coralGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00C897), Color(0xFF2DD4BF)],
  );

  static const List<Color> avatarGradients = [
    Color(0xFF0A6E6E),
    Color(0xFF2DD4BF),
    Color(0xFFFF6B6B),
    Color(0xFFFFC947),
    Color(0xFF00C897),
    Color(0xFF7C3AED),
  ];
}
