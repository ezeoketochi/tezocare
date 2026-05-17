import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF4B4EFC);
  static const Color primaryLight = Color(0xFFEDEDFF);
  static const Color primarySurface = Color(0xFFF5F5FF);

  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF5F5FF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFE5E7EB);

  static const Color dark = Color(0xFF0D0D0D);

  static const Color textPrimary = Color(0xFF0D0D0D);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFF9CA3AF);
  static const Color textOnDark = Color(0xFFFFFFFF);

  static const Color success = Color(0xFF22C55E);
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color danger = Color(0xFFEF4444);
  static const Color dangerLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF4B4EFC);
  static const Color infoLight = Color(0xFFEDEDFF);

  static const Color chipActiveBg = Color(0xFFFEF3C7);
  static const Color chipActiveText = Color(0xFFD97706);
  static const Color chipCompletedBg = Color(0xFFDCFCE7);
  static const Color chipCompletedText = Color(0xFF16A34A);
  static const Color chipFollowUpBg = Color(0xFFEDEDFF);
  static const Color chipFollowUpText = Color(0xFF4B4EFC);
  static const Color chipReferredBg = Color(0xFFFEE2E2);
  static const Color chipReferredText = Color(0xFFDC2626);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3B3DBF), Color(0xFF6366F1)],
  );

  static const List<Color> avatarGradients = [
    Color(0xFF4B4EFC),
    Color(0xFF22C55E),
    Color(0xFFEF4444),
    Color(0xFFF59E0B),
    Color(0xFF6366F1),
    Color(0xFF8B5CF6),
  ];
}
