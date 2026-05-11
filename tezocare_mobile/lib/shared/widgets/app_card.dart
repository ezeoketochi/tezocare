import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../config/themes/app_colors.dart';

enum AppCardVariant { light, dark, glass }

class AppCard extends StatelessWidget {
  final AppCardVariant variant;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final double? borderRadius;

  const AppCard({
    super.key,
    this.variant = AppCardVariant.light,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? 20.r;
    final effectivePadding = padding ?? EdgeInsets.all(16.w);

    Widget card = Container(
      margin: margin,
      padding: onTap != null ? EdgeInsets.zero : effectivePadding,
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(radius),
        border: variant == AppCardVariant.glass
            ? Border.all(color: AppColors.primary.withValues(alpha: 0.2))
            : null,
        boxShadow: variant == AppCardVariant.light
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
        gradient: variant == AppCardVariant.dark
            ? AppColors.darkCardGradient
            : null,
      ),
      child: onTap != null
          ? Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(radius),
              child: InkWell(
                borderRadius: BorderRadius.circular(radius),
                onTap: onTap,
                child: Padding(
                  padding: effectivePadding,
                  child: child,
                ),
              ),
            )
          : child,
    );

    if (variant == AppCardVariant.glass) {
      card = ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: _blur,
          child: card,
        ),
      );
    }

    return card;
  }

  Color get _backgroundColor {
    switch (variant) {
      case AppCardVariant.light:
        return AppColors.white;
      case AppCardVariant.dark:
        return Colors.transparent;
      case AppCardVariant.glass:
        return AppColors.white.withValues(alpha: 0.8);
    }
  }

  static final _blur = ImageFilter.blur(sigmaX: 10, sigmaY: 10);
}
