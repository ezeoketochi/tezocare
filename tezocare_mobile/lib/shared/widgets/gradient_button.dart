import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../config/themes/app_colors.dart';
import '../../config/themes/app_text_styles.dart';

class GradientButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final bool isLoading;
  final bool isFullWidth;
  final double? height;
  final double? width;

  const GradientButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.isLoading = false,
    this.isFullWidth = true,
    this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final buttonHeight = height ?? 56.h;
    return Material(
      borderRadius: BorderRadius.circular(16.r),
      child: Ink(
        width: isFullWidth ? double.infinity : width,
        height: buttonHeight,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: isLoading ? null : onPressed,
          child: Center(
            child: isLoading
                ? SizedBox(
                    height: 24.h,
                    width: 24.h,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : DefaultTextStyle(
                    style: AppTextStyles.button,
                    child: child,
                  ),
          ),
        ),
      ),
    );
  }
}
