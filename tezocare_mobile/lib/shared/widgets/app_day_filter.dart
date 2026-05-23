import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../config/themes/app_colors.dart';
import '../../config/themes/app_text_styles.dart';

class AppDayFilter extends StatelessWidget {
  final int selectedDays;
  final ValueChanged<int> onChanged;

  static const List<int> options = [1, 3, 7, 14, 30];

  const AppDayFilter({super.key, required this.selectedDays, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      child: Row(
        children: [
          Icon(Icons.date_range, size: 16.sp, color: AppColors.textSecondary),
          SizedBox(width: 8.w),
          Text('Next:', style: AppTextStyles.bodySmall),
          SizedBox(width: 8.w),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: options.map((days) {
                  final isSelected = days == selectedDays;
                  return Padding(
                    padding: EdgeInsets.only(right: 6.w),
                    child: GestureDetector(
                      onTap: () => onChanged(days),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.primarySurface,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          '$days day${days > 1 ? 's' : ''}',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: isSelected ? AppColors.white : AppColors.primary,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
