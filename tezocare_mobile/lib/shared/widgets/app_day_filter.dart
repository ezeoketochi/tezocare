import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../config/themes/app_colors.dart';
import '../../config/themes/app_text_styles.dart';

class AppDayFilter extends StatelessWidget {
  final int selectedDays;
  final ValueChanged<int> onChanged;

  const AppDayFilter({
    super.key,
    required this.selectedDays,
    required this.onChanged,
  });

  bool get _isAll => selectedDays == 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.date_range,
                size: 16.sp,
                color: AppColors.textSecondary,
              ),
              SizedBox(width: 8.w),
              Text('Next:', style: AppTextStyles.bodySmall),
              SizedBox(width: 8.w),
              GestureDetector(
                onTap: () => onChanged(0),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: _isAll
                        ? AppColors.primary
                        : AppColors.primarySurface,
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
                  _dayLabel,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ],
          ),
          if (_isAll)
            Padding(
              padding: EdgeInsets.only(top: 4.h),
              child: SliderTheme(
                data: SliderThemeData(
                  trackHeight: 4.h,
                  thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8.r),
                  activeTrackColor: AppColors.primary,
                  inactiveTrackColor: AppColors.primarySurface,
                  thumbColor: AppColors.primary,
                  overlayColor: AppColors.primary.withValues(alpha: 0.12),
                ),
                child: Slider(
                  value: selectedDays.clamp(1, 30).toDouble(),
                  min: 1,
                  max: 30,
                  divisions: 29,
                  label: _dayLabel,
                  onChanged: (v) => onChanged(v.round()),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String get _dayLabel => '$selectedDays day${selectedDays > 1 ? 's' : ''}';
}
