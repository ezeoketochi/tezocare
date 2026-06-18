import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const String _fontFamily = 'Satoshi';

  static TextStyle get displayLarge => TextStyle(
    fontSize: 24.sp,
    fontWeight: FontWeight.w700,
    fontFamily: _fontFamily,
    color: AppColors.textPrimary,
    letterSpacing: -1,
    height: 1.1,
  );

  static TextStyle get displayMedium => TextStyle(
    fontSize: 20.sp,
    fontWeight: FontWeight.w700,
    fontFamily: _fontFamily,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static TextStyle get headlineLarge => TextStyle(
    fontSize: 18.sp,
    fontWeight: FontWeight.w700,
    fontFamily: _fontFamily,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static TextStyle get headlineMedium => TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w700,
    fontFamily: _fontFamily,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static TextStyle get headlineSmall => TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w700,
    fontFamily: _fontFamily,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static TextStyle get titleLarge => TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
    fontFamily: _fontFamily,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static TextStyle get titleMedium => TextStyle(
    fontSize: 13.sp,
    fontWeight: FontWeight.w700,
    fontFamily: _fontFamily,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static TextStyle get titleSmall => TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.w500,
    fontFamily: _fontFamily,
    color: AppColors.textDark,
    height: 1.4,
  );

  static TextStyle get bodyLarge => TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
    fontFamily: _fontFamily,
    color: AppColors.textPrimary,
    height: 1.6,
  );

  static TextStyle get bodyMedium => TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.w500,
    fontFamily: _fontFamily,
    color: AppColors.textDark,
    height: 1.6,
  );

  static TextStyle get bodySmall => TextStyle(
    fontSize: 11.sp,
    fontWeight: FontWeight.w500,
    fontFamily: _fontFamily,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  static TextStyle get labelLarge => TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w700,
    fontFamily: _fontFamily,
    color: AppColors.white,
    letterSpacing: 0.3,
  );

  static TextStyle get labelMedium => TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.w500,
    fontFamily: _fontFamily,
    color: AppColors.textSecondary,
    letterSpacing: 0.2,
  );

  static TextStyle get labelSmall => TextStyle(
    fontSize: 10.sp,
    fontWeight: FontWeight.w500,
    fontFamily: _fontFamily,
    color: AppColors.textHint,
    letterSpacing: 0.3,
  );

  static TextStyle get statNumber => TextStyle(
    fontSize: 18.sp,
    fontWeight: FontWeight.w700,
    fontFamily: _fontFamily,
    color: AppColors.textPrimary,
    height: 1.1,
  );

  static TextStyle get statLabel => TextStyle(
    fontSize: 11.sp,
    fontWeight: FontWeight.w500,
    fontFamily: _fontFamily,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  static TextStyle get caption => TextStyle(
    fontSize: 10.sp,
    fontWeight: FontWeight.w500,
    fontFamily: _fontFamily,
    color: AppColors.textHint,
    height: 1.4,
  );

  static TextStyle get onDarkTitle => TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w700,
    fontFamily: _fontFamily,
    color: AppColors.textOnDark,
    height: 1.4,
  );

  static TextStyle get onDarkBody => TextStyle(
    fontSize: 11.sp,
    fontWeight: FontWeight.w500,
    fontFamily: _fontFamily,
    color: AppColors.textHint,
    height: 1.5,
  );
}
