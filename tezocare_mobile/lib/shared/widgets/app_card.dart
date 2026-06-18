import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../config/themes/app_colors.dart';

enum AppCardVariant { light, dark }

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
    final radius = borderRadius ?? 15.r;
    final effectivePadding = padding ?? EdgeInsets.all(16.w);

    Widget card = Container(
      margin: margin,
      padding: onTap != null ? EdgeInsets.zero : effectivePadding,
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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

    return card;
  }

  Color get _backgroundColor {
    switch (variant) {
      case AppCardVariant.light:
        return AppColors.white;
      case AppCardVariant.dark:
        return AppColors.dark;
    }
  }
}
