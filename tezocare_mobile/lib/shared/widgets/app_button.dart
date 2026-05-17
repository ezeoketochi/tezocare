import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/themes/app_colors.dart';

enum AppButtonVariant { primary, outline, destructive }

class AppButton extends StatefulWidget {
  final AppButtonVariant variant;
  final String? label;
  final Widget? child;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final Widget? prefixIcon;
  final double? width;
  final double? height;

  const AppButton({
    super.key,
    this.variant = AppButtonVariant.primary,
    this.label,
    this.child,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.prefixIcon,
    this.width,
    this.height,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool get _isActive => widget.onPressed != null && !widget.isDisabled;

  @override
  Widget build(BuildContext context) {
    final height = widget.height ?? 48.h;
    final width = widget.width ?? double.infinity;

    return GestureDetector(
      onTap: _isActive ? widget.onPressed : null,
      child: Opacity(
        opacity: widget.isDisabled ? 1.0 : 1.0,
        child: _buildButton(height, width),
      ),
    );
  }

  Widget _buildButton(double height, double width) {
    switch (widget.variant) {
      case AppButtonVariant.primary:
        return _buildPrimaryButton(height, width);
      case AppButtonVariant.outline:
        return _buildOutlineButton(height, width);
      case AppButtonVariant.destructive:
        return _buildDestructiveButton(height, width);
    }
  }

  Widget _buildPrimaryButton(double height, double width) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: widget.isDisabled ? const Color(0xFFC7C8FE) : AppColors.primary,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: _buildButtonContent(textColor: AppColors.white),
    );
  }

  Widget _buildOutlineButton(double height, double width) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: widget.isDisabled ? const Color(0xFFC7C8FE) : AppColors.primary,
          width: 1.5,
        ),
      ),
      child: _buildButtonContent(
        textColor: widget.isDisabled ? const Color(0xFFC7C8FE) : AppColors.primary,
      ),
    );
  }

  Widget _buildDestructiveButton(double height, double width) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: widget.isDisabled ? const Color(0xFFC7C8FE) : AppColors.danger,
          width: 1.5,
        ),
      ),
      child: _buildButtonContent(
        textColor: widget.isDisabled ? const Color(0xFFC7C8FE) : AppColors.danger,
      ),
    );
  }

  Widget _buildButtonContent({required Color textColor}) {
    return Center(
      child: widget.isLoading
          ? SizedBox(
              width: 20.w,
              height: 20.w,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(textColor),
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.prefixIcon != null) ...[
                  widget.prefixIcon!,
                  const SizedBox(width: 8),
                ],
                widget.child ??
                    Text(
                      widget.label ?? '',
                      style: GoogleFonts.poppins(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
              ],
            ),
    );
  }
}
