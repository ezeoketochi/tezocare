import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../config/themes/app_colors.dart';
import '../../config/themes/app_text_styles.dart';

class AppDayFilter extends StatelessWidget {
  final int? selectedDays;
  final ValueChanged<int?> onChanged;

  const AppDayFilter({super.key, required this.selectedDays, required this.onChanged});

  bool get _isAll => selectedDays == null;

  @override
  Widget build(BuildContext context) {
    final sliderValue = (selectedDays ?? 7).clamp(1, 30).toDouble();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.date_range, size: 16.sp, color: AppColors.textSecondary),
              SizedBox(width: 8.w),
              Text('Next:', style: AppTextStyles.bodySmall),
              SizedBox(width: 8.w),
              GestureDetector(
                onTap: () => onChanged(null),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: _isAll ? AppColors.primary : AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    'All',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: _isAll ? AppColors.white : AppColors.primary,
                      fontWeight: _isAll ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
              if (!_isAll) ...[
                SizedBox(width: 4.w),
                Text(
                  '$selectedDays day${selectedDays! > 1 ? 's' : ''}',
                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary),
                ),
              ],
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: 4.h),
            child: SliderTheme(
              data: SliderThemeData(
                trackHeight: 4.h,
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8.r),
                activeTrackColor: _isAll ? AppColors.border : AppColors.primary,
                inactiveTrackColor: _isAll ? AppColors.primarySurface : AppColors.primarySurface,
                thumbColor: _isAll ? AppColors.textHint : AppColors.primary,
                overlayColor: AppColors.primary.withValues(alpha: 0.12),
              ),
              child: Slider(
                value: sliderValue,
                min: 1,
                max: 30,
                divisions: 29,
                label: '${sliderValue.round()} days',
                onChanged: (v) => onChanged(v.round()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
