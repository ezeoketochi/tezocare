import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/themes/app_colors.dart';

enum AppButtonVariant { primary, secondary, ghost, danger }

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

class _AppButtonState extends State<AppButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isActive => widget.onPressed != null && !widget.isDisabled;

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
      child: GestureDetector(
        onTapDown: _isActive ? (_) => _onPressStart() : null,
        onTapUp: _isActive ? (_) => _onPressEnd() : null,
        onTapCancel: _isActive ? _onPressEnd : null,
        onTap: _isActive ? widget.onPressed : null,
        child: Opacity(
          opacity: widget.isDisabled ? 0.5 : 1.0,
          child: _buildButton(),
        ),
      ),
    );
  }

  void _onPressStart() {
    _controller.forward();
  }

  void _onPressEnd() {
    _controller.reverse();
  }

  Widget _buildButton() {
    final buttonHeight = widget.height ?? 56.h;
    final buttonWidth = widget.width ?? double.infinity;

    switch (widget.variant) {
      case AppButtonVariant.primary:
        return _buildGradientButton(buttonHeight, buttonWidth);
      case AppButtonVariant.secondary:
        return _buildOutlinedButton(buttonHeight, buttonWidth);
      case AppButtonVariant.ghost:
        return _buildGhostButton(buttonHeight, buttonWidth);
      case AppButtonVariant.danger:
        return _buildDangerButton(buttonHeight, buttonWidth);
    }
  }

  Widget _buildGradientButton(double height, double width) {
    return Container(
      width: width,
      height: height,
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
      child: _buildButtonContent(isWhiteText: true),
    );
  }

  Widget _buildOutlinedButton(double height, double width) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.primary, width: 1.5),
      ),
      child: _buildButtonContent(isWhiteText: false, textColor: AppColors.primary),
    );
  }

  Widget _buildGhostButton(double height, double width) {
    return Container(
      width: width,
      height: height,
      child: _buildButtonContent(isWhiteText: false, textColor: AppColors.primary),
    );
  }

  Widget _buildDangerButton(double height, double width) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: AppColors.coralGradient,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.coral.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: _buildButtonContent(isWhiteText: true),
    );
  }

  Widget _buildButtonContent({required bool isWhiteText, Color? textColor}) {
    return Center(
      child: widget.isLoading
          ? SizedBox(
              width: 20.w,
              height: 20.w,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isWhiteText ? AppColors.white : AppColors.primary,
                ),
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
                        color: textColor ?? (isWhiteText ? AppColors.white : AppColors.primary),
                        letterSpacing: 0.3,
                      ),
                    ),
              ],
            ),
    );
  }
}
