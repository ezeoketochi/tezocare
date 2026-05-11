import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../config/themes/app_colors.dart';
import '../../config/themes/app_text_styles.dart';

enum StatCardVariant { primary, success, gold, coral }

class AppStatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final StatCardVariant variant;
  final double? changePercent;
  final bool isPositiveChange;

  const AppStatCard({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    this.variant = StatCardVariant.primary,
    this.changePercent,
    this.isPositiveChange = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        gradient: _gradient,
        boxShadow: [
          BoxShadow(
            color: _shadowColor.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10.w,
            top: -10.h,
            child: Container(
              width: 60.w,
              height: 60.w,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 4.w,
            top: 8.h,
            child: Container(
              width: 32.w,
              height: 32.w,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 16.sp),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                Text(
                  value,
                  style: AppTextStyles.statNumber.copyWith(
                    color: _textColor,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  label,
                  style: AppTextStyles.statLabel.copyWith(
                    color: _labelColor,
                  ),
                ),
                if (changePercent != null) ...[
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Icon(
                        isPositiveChange
                            ? Icons.trending_up_rounded
                            : Icons.trending_down_rounded,
                        size: 14.sp,
                        color: isPositiveChange
                            ? AppColors.success
                            : AppColors.coral,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '${isPositiveChange ? '+' : ''}$changePercent%',
                        style: AppTextStyles.caption.copyWith(
                          color: isPositiveChange
                              ? AppColors.success
                              : AppColors.coral,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  LinearGradient get _gradient {
    switch (variant) {
      case StatCardVariant.primary:
        return AppColors.darkCardGradient;
      case StatCardVariant.success:
        return AppColors.successGradient;
      case StatCardVariant.gold:
        return AppColors.goldGradient;
      case StatCardVariant.coral:
        return AppColors.coralGradient;
    }
  }

  Color get _shadowColor {
    switch (variant) {
      case StatCardVariant.primary:
        return AppColors.darkCard;
      case StatCardVariant.success:
        return AppColors.success;
      case StatCardVariant.gold:
        return AppColors.gold;
      case StatCardVariant.coral:
        return AppColors.coral;
    }
  }

  Color get _textColor {
    return variant == StatCardVariant.gold
        ? AppColors.textPrimary
        : AppColors.white;
  }

  Color get _labelColor {
    return variant == StatCardVariant.gold
        ? AppColors.textSecondary
        : AppColors.textOnDarkSecondary;
  }
}
