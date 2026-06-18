import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../config/themes/app_colors.dart';

enum AppStatCardVariant { light, primary }

class AppStatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final AppStatCardVariant variant;

  const AppStatCard({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    this.variant = AppStatCardVariant.light,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: _iconColor, size: 20.sp),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
              fontFamily: 'Satoshi',
              color: _valueColor,
              height: 1.1,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              fontFamily: 'Satoshi',
              color: _labelColor,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Color get _backgroundColor {
    switch (variant) {
      case AppStatCardVariant.light:
        return AppColors.primaryLight;
      case AppStatCardVariant.primary:
        return AppColors.primary;
    }
  }

  Color get _iconColor {
    switch (variant) {
      case AppStatCardVariant.light:
        return AppColors.primary;
      case AppStatCardVariant.primary:
        return AppColors.white;
    }
  }

  Color get _valueColor {
    switch (variant) {
      case AppStatCardVariant.light:
        return AppColors.textPrimary;
      case AppStatCardVariant.primary:
        return AppColors.white;
    }
  }

  Color get _labelColor {
    switch (variant) {
      case AppStatCardVariant.light:
        return AppColors.textSecondary;
      case AppStatCardVariant.primary:
        return AppColors.white.withValues(alpha: 0.8);
    }
  }
}
