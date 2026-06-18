import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../config/themes/app_colors.dart';

class AppSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final String? hint;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSubmitted;

  const AppSearchBar({
    super.key,
    required this.controller,
    this.hint,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40.h,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(30.r),
        border: Border.all(
          color: AppColors.border,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          SizedBox(width: 12.w),
          Icon(
            Icons.search_rounded,
            size: 18.sp,
            color: AppColors.textSecondary,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: TextField(
              controller: widget.controller,
              onChanged: widget.onChanged,
              onSubmitted: (_) => widget.onSubmitted?.call(),
              style: TextStyle(
                fontSize: 13.sp,
                fontFamily: 'Satoshi',
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: widget.hint ?? 'Search...',
                hintStyle: TextStyle(
                  fontSize: 13.sp,
                  fontFamily: 'Satoshi',
                  color: AppColors.textHint,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
            ),
          ),
          if (widget.controller.text.isNotEmpty)
            IconButton(
              icon: Icon(
                Icons.close_rounded,
                size: 16.sp,
                color: AppColors.textSecondary,
              ),
              onPressed: () {
                widget.controller.clear();
                widget.onChanged?.call('');
              },
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(
                minWidth: 28.w,
                minHeight: 28.w,
              ),
            ),
          SizedBox(width: 4.w),
        ],
      ),
    );
  }
}
