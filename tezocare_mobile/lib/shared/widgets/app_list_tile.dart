import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../config/themes/app_colors.dart';
import '../../config/themes/app_text_styles.dart';
import 'app_avatar.dart';
import 'app_badge.dart';

class AppListTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? avatarText;
  final String? imageUrl;
  final Widget? trailing;
  final VoidCallback? onTap;
  final String? badgeText;
  final BadgeVariant? badgeVariant;
  final Color accentColor;

  const AppListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.avatarText,
    this.imageUrl,
    this.trailing,
    this.onTap,
    this.badgeText,
    this.badgeVariant,
    this.accentColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    Container(
                      width: 4.w,
                      decoration: BoxDecoration(
                        color: accentColor,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16.r),
                          bottomLeft: Radius.circular(16.r),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Row(
                          children: [
                            if (avatarText != null || imageUrl != null) ...[
                              AppAvatar(
                                name: avatarText ?? title,
                                imageUrl: imageUrl,
                                size: AvatarSize.medium,
                              ),
                              SizedBox(width: 12.w),
                            ],
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          title,
                                          style: AppTextStyles.titleMedium,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (badgeText != null) ...[
                                        SizedBox(width: 8.w),
                                        AppBadge(
                                          text: badgeText!,
                                          variant: badgeVariant ?? BadgeVariant.info,
                                        ),
                                      ],
                                    ],
                                  ),
                                  if (subtitle != null) ...[
                                    SizedBox(height: 4.h),
                                    Text(
                                      subtitle!,
                                      style: AppTextStyles.bodySmall,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            if (trailing != null) ...[
                              SizedBox(width: 8.w),
                              trailing!,
                            ] else if (onTap != null) ...[
                              SizedBox(width: 8.w),
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 20.sp,
                                color: AppColors.textTertiary,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
