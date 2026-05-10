import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF1565C0);
  static const Color primaryLight = Color(0xFF5E92F3);
  static const Color primaryDark = Color(0xFF003C8F);
  static const Color secondary = Color(0xFF26A69A);
  static const Color secondaryLight = Color(0xFF64D8CB);
  static const Color secondaryDark = Color(0xFF00766C);
  static const Color accent = Color(0xFFFF7043);
  static const Color error = Color(0xFFD32F2F);
  static const Color warning = Color(0xFFFFA000);
  static const Color success = Color(0xFF388E3C);
  static const Color surface = Color(0xFFF5F5F5);
  static const Color surfaceContainer = Color(0xFFF0F4FA);
  static const Color background = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFFE5E7EB);
  static const Color scaffoldBg = Color(0xFFF8FAFC);
  static const Color cardBg = Color(0xFFFFFFFF);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1565C0), Color(0xFF5E92F3)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient primaryGradientVertical = LinearGradient(
    colors: [Color(0xFF1565C0), Color(0xFF5E92F3)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient splashGradient = LinearGradient(
    colors: [Color(0xFF0D47A1), Color(0xFF1565C0), Color(0xFF1976D2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const List<Color> statCardColors = [
    Color(0xFF1565C0),
    Color(0xFF26A69A),
    Color(0xFFFF7043),
    Color(0xFFD32F2F),
  ];

  static BoxShadow cardShadow = BoxShadow(
    color: Colors.black.withValues(alpha: 0.06),
    blurRadius: 16,
    offset: const Offset(0, 4),
  );

  static BoxShadow elevatedShadow = BoxShadow(
    color: Colors.black.withValues(alpha: 0.12),
    blurRadius: 24,
    offset: const Offset(0, 8),
  );
}
