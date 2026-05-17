import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle get displayLarge => GoogleFonts.poppins(
    fontSize: 34.sp,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: -1,
    height: 1.1,
  );

  static TextStyle get displayMedium => GoogleFonts.poppins(
    fontSize: 28.sp,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static TextStyle get headlineLarge => GoogleFonts.poppins(
    fontSize: 24.sp,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static TextStyle get headlineMedium => GoogleFonts.poppins(
    fontSize: 20.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static TextStyle get headlineSmall => GoogleFonts.poppins(
    fontSize: 18.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static TextStyle get titleLarge => GoogleFonts.poppins(
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static TextStyle get titleMedium => GoogleFonts.poppins(
    fontSize: 14.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static TextStyle get titleSmall => GoogleFonts.poppins(
    fontSize: 13.sp,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  static TextStyle get bodyLarge => GoogleFonts.inter(
    fontSize: 16.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.6,
  );

  static TextStyle get bodyMedium => GoogleFonts.inter(
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.6,
  );

  static TextStyle get bodySmall => GoogleFonts.inter(
    fontSize: 12.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  static TextStyle get labelLarge => GoogleFonts.poppins(
    fontSize: 15.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
    letterSpacing: 0.3,
  );

  static TextStyle get labelMedium => GoogleFonts.poppins(
    fontSize: 13.sp,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    letterSpacing: 0.2,
  );

  static TextStyle get labelSmall => GoogleFonts.inter(
    fontSize: 11.sp,
    fontWeight: FontWeight.w500,
    color: AppColors.textHint,
    letterSpacing: 0.3,
  );

  static TextStyle get statNumber => GoogleFonts.poppins(
    fontSize: 26.sp,
    fontWeight: FontWeight.w700,
    color: AppColors.white,
    height: 1.1,
  );

  static TextStyle get statLabel => GoogleFonts.inter(
    fontSize: 12.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.textHint,
    height: 1.4,
  );

  static TextStyle get caption => GoogleFonts.inter(
    fontSize: 11.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.textHint,
    height: 1.4,
  );

  static TextStyle get onDarkTitle => GoogleFonts.poppins(
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.textOnDark,
    height: 1.4,
  );

  static TextStyle get onDarkBody => GoogleFonts.inter(
    fontSize: 13.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.textHint,
    height: 1.5,
  );
}
