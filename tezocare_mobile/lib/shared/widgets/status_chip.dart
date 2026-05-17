import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/themes/app_colors.dart';

enum StatusChipVariant { active, completed, followUpPending, referred }

class StatusChip extends StatelessWidget {
  final String text;
  final StatusChipVariant variant;

  const StatusChip({
    super.key,
    required this.text,
    this.variant = StatusChipVariant.active,
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
        style: GoogleFonts.inter(
          fontSize: 11.sp,
          fontWeight: FontWeight.w500,
          color: _textColor,
        ),
      ),
    );
  }

  Color get _backgroundColor {
    switch (variant) {
      case StatusChipVariant.active:
        return AppColors.chipActiveBg;
      case StatusChipVariant.completed:
        return AppColors.chipCompletedBg;
      case StatusChipVariant.followUpPending:
        return AppColors.chipFollowUpBg;
      case StatusChipVariant.referred:
        return AppColors.chipReferredBg;
    }
  }

  Color get _textColor {
    switch (variant) {
      case StatusChipVariant.active:
        return AppColors.chipActiveText;
      case StatusChipVariant.completed:
        return AppColors.chipCompletedText;
      case StatusChipVariant.followUpPending:
        return AppColors.chipFollowUpText;
      case StatusChipVariant.referred:
        return AppColors.chipReferredText;
    }
  }
}
