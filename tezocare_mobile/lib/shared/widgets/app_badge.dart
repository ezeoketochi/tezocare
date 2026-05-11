import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../config/themes/app_colors.dart';
import '../../config/themes/app_text_styles.dart';

enum BadgeVariant { active, inactive, pending, critical, info }

class AppBadge extends StatelessWidget {
  final String text;
  final BadgeVariant variant;

  const AppBadge({
    super.key,
    required this.text,
    this.variant = BadgeVariant.info,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        text,
        style: AppTextStyles.labelSmall.copyWith(
          color: _textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color get _backgroundColor {
    switch (variant) {
      case BadgeVariant.active:
        return AppColors.successLight;
      case BadgeVariant.inactive:
        return AppColors.divider;
      case BadgeVariant.pending:
        return AppColors.warningLight;
      case BadgeVariant.critical:
        return AppColors.errorLight;
      case BadgeVariant.info:
        return AppColors.primaryPale;
    }
  }

  Color get _textColor {
    switch (variant) {
      case BadgeVariant.active:
        return AppColors.success;
      case BadgeVariant.inactive:
        return AppColors.textTertiary;
      case BadgeVariant.pending:
        return AppColors.warning;
      case BadgeVariant.critical:
        return AppColors.error;
      case BadgeVariant.info:
        return AppColors.primary;
    }
  }
}
