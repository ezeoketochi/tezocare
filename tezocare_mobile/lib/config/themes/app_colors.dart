import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary palette
  static const Color primary = Color(0xFF4541F1);
  static const Color primaryLight = Color(0xFFEEEEFF);
  static const Color primarySurface = Color(0xFFF7F7F7);

  // Neutrals
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF7F7F7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color inputFill = Color(0xFFF9F9F9);
  static const Color border = Color(0xFFEDEDED);
  static const Color borderPlaceholder = Color(0xFFC8C8C8);
  static const Color divider = Color(0xFFEDEDED);
  static const Color dark = Color(0xFF242424);

  // Text
  static const Color textPrimary = Color(0xFF121212);
  static const Color textDark = Color(0xFF373737);
  static const Color textLabel = Color(0xFF494949);
  static const Color textSecondary = Color(0xFF808080);
  static const Color textHint = Color(0xFF808080);
  static const Color textOnDark = Color(0xFFFFFFFF);
  static const Color iconInactive = Color(0xFF5B5B5B);

  // Semantic
  static const Color success = Color(0xFF00A94F);
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color danger = Color(0xFFD00416);
  static const Color dangerLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF4541F1);
  static const Color infoLight = Color(0xFFEEEEFF);

  // Status chips
  static const Color chipActiveBg = Color(0xFFFEF3C7);
  static const Color chipActiveText = Color(0xFFD97706);
  static const Color chipCompletedBg = Color(0xFFDCFCE7);
  static const Color chipCompletedText = Color(0xFF16A34A);
  static const Color chipFollowUpBg = Color(0xFFEEEEFF);
  static const Color chipFollowUpText = Color(0xFF4541F1);
  static const Color chipReferredBg = Color(0xFFFEE2E2);
  static const Color chipReferredText = Color(0xFFDC2626);

  // Brand gradient (used on auth pages, profile, patient detail)
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3734C8), Color(0xFF4541F1)],
  );

  // Splash screen gradient (from Figma: #B3C6F9 -> #FFEDCE)
  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFB3C6F9), Color(0xFFFFEDCE)],
  );

  // Dashboard header gradient (from Figma: #B5B3F9 -> #FFFFFF)
  static const LinearGradient dashboardHeaderGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFB5B3F9), Color(0xFFFFFFFF)],
  );

  // Subtle full-page background gradient
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF0EEFF), Color(0xFFF7F7FF)],
  );

  static const List<Color> avatarGradients = [
    Color(0xFF4541F1),
    Color(0xFF22C55E),
    Color(0xFFEF4444),
    Color(0xFFF59E0B),
    Color(0xFF6366F1),
    Color(0xFF8B5CF6),
  ];
}
