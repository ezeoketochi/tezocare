import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/themes/app_colors.dart';
import '../../config/themes/app_text_styles.dart';

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

class _AppSearchBarState extends State<AppSearchBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _focusController;
  late Animation<double> _scaleAnimation;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _focusController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _focusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: Focus(
        onFocusChange: (focused) {
          setState(() => _isFocused = focused);
          if (focused) {
            _focusController.forward();
          } else {
            _focusController.reverse();
          }
        },
        child: Container(
          height: 52.h,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(30.r),
            border: Border.all(
              color: _isFocused ? AppColors.primary : AppColors.divider,
              width: _isFocused ? 2 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              SizedBox(width: 16.w),
              Icon(
                Icons.search_rounded,
                size: 20.sp,
                color: AppColors.primary,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  onChanged: widget.onChanged,
                  onSubmitted: (_) => widget.onSubmitted?.call(),
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.hint ?? 'Search...',
                    hintStyle: AppTextStyles.bodyMedium,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                ),
              ),
              if (widget.controller.text.isNotEmpty)
                IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    size: 18.sp,
                    color: AppColors.textTertiary,
                  ),
                  onPressed: () {
                    widget.controller.clear();
                    widget.onChanged?.call('');
                  },
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(
                    minWidth: 32.w,
                    minHeight: 32.w,
                  ),
                ),
              SizedBox(width: 8.w),
            ],
          ),
        ),
      ),
    );
  }
}
