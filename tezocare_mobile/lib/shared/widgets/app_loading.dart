import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import '../../config/themes/app_colors.dart';

class AppLoading {
  AppLoading._();

  static Widget fullScreen() {
    return Container(
      color: AppColors.background.withValues(alpha: 0.8),
      child: Center(
        child: SizedBox(
          width: 32.w,
          height: 32.w,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(
              AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }

  static Widget inline({double? size}) {
    return SizedBox(
      width: size ?? 20.w,
      height: size ?? 20.w,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        valueColor: AlwaysStoppedAnimation<Color>(
          AppColors.primary,
        ),
      ),
    );
  }

  static Widget shimmerCard() {
    return Shimmer.fromColors(
      baseColor: AppColors.divider,
      highlightColor: AppColors.white,
      child: Container(
        height: 100.h,
        decoration: BoxDecoration(
          color: AppColors.divider,
          borderRadius: BorderRadius.circular(16.r),
        ),
      ),
    );
  }

  static Widget shimmerList({int count = 3}) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
        itemBuilder: (_, _) => Padding(
        padding: EdgeInsets.only(bottom: 12.h),
        child: shimmerCard(),
      ),
    );
  }
}
